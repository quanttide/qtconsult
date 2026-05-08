from abc import ABC, abstractmethod
from pathlib import Path

from app.models import Project


class StorageBackend(ABC):
    @abstractmethod
    def load(self, workspace_id: str, project_id: str) -> Project:
        ...

    @abstractmethod
    def save(self, workspace_id: str, project_id: str, project: Project) -> None:
        ...

    @abstractmethod
    def list_workspaces(self) -> list[str]:
        ...

    @abstractmethod
    def list_projects(self, workspace_id: str) -> list[str]:
        ...


class LocalStorage(StorageBackend):
    def __init__(self, data_dir: str | Path):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)

    def _path(self, workspace_id: str, project_id: str) -> Path:
        return self.data_dir / workspace_id / f"{project_id}.json"

    def load(self, workspace_id: str, project_id: str) -> Project:
        raw = self._path(workspace_id, project_id).read_text("utf-8")
        return Project.model_validate_json(raw)

    def save(self, workspace_id: str, project_id: str, project: Project) -> None:
        path = self._path(workspace_id, project_id)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            project.model_dump_json(indent=2, exclude_none=True),
            encoding="utf-8",
        )

    def list_workspaces(self) -> list[str]:
        if not self.data_dir.is_dir():
            return []
        return sorted(
            p.name for p in self.data_dir.iterdir() if p.is_dir() and not p.name.startswith(".")
        )

    def list_projects(self, workspace_id: str) -> list[str]:
        workspace_dir = self.data_dir / workspace_id
        if not workspace_dir.is_dir():
            return []
        return sorted(
            p.stem for p in workspace_dir.iterdir()
            if p.suffix == ".json" and not p.name.startswith(".")
        )


class S3Storage(StorageBackend):
    def __init__(
        self,
        bucket: str,
        prefix: str = "",
        *,
        region: str = "cn-hangzhou",
        endpoint_url: str = "",
        access_key_id: str = "",
        secret_access_key: str = "",
        addressing_style: str = "virtual",
        client=None,
    ):
        if not bucket:
            raise ValueError("S3 bucket is required")
        self.bucket = bucket
        self.prefix = prefix.strip("/")
        if client is not None:
            self.client = client
            return

        import boto3
        from botocore.config import Config

        kwargs = {
            "service_name": "s3",
            "region_name": region,
            "config": Config(s3={"addressing_style": addressing_style}),
        }
        if endpoint_url:
            kwargs["endpoint_url"] = endpoint_url
        if access_key_id and secret_access_key:
            kwargs["aws_access_key_id"] = access_key_id
            kwargs["aws_secret_access_key"] = secret_access_key
        self.client = boto3.client(**kwargs)

    def _key(self, workspace_id: str, project_id: str) -> str:
        parts = [self.prefix, workspace_id, f"{project_id}.json"] if self.prefix else [workspace_id, f"{project_id}.json"]
        return "/".join(parts)

    def load(self, workspace_id: str, project_id: str) -> Project:
        key = self._key(workspace_id, project_id)
        try:
            obj = self.client.get_object(Bucket=self.bucket, Key=key)
        except Exception as exc:
            code = getattr(exc, "response", {}).get("Error", {}).get("Code")
            if code in {"NoSuchKey", "404", "NotFound"}:
                raise FileNotFoundError(key) from exc
            raise
        raw = obj["Body"].read().decode("utf-8")
        return Project.model_validate_json(raw)

    def save(self, workspace_id: str, project_id: str, project: Project) -> None:
        self.client.put_object(
            Bucket=self.bucket,
            Key=self._key(workspace_id, project_id),
            Body=project.model_dump_json(indent=2, exclude_none=True).encode("utf-8"),
            ContentType="application/json",
        )

    def list_workspaces(self) -> list[str]:
        prefix = f"{self.prefix}/" if self.prefix else ""
        resp = self.client.list_objects_v2(
            Bucket=self.bucket, Prefix=prefix, Delimiter="/"
        )
        return sorted(
            p["Prefix"].removeprefix(prefix).rstrip("/")
            for p in resp.get("CommonPrefixes", [])
        )

    def list_projects(self, workspace_id: str) -> list[str]:
        prefix = f"{self.prefix}/{workspace_id}/" if self.prefix else f"{workspace_id}/"
        resp = self.client.list_objects_v2(
            Bucket=self.bucket, Prefix=prefix
        )
        return sorted(
            p["Key"].removeprefix(prefix).removesuffix(".json")
            for p in resp.get("Contents", [])
            if p["Key"].endswith(".json")
        )
