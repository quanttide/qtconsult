from abc import ABC, abstractmethod
from pathlib import Path

from app.models import Project


class StorageBackend(ABC):
    @abstractmethod
    def load(self, project_id: str) -> Project:
        ...

    @abstractmethod
    def save(self, project_id: str, project: Project) -> None:
        ...


class LocalStorage(StorageBackend):
    def __init__(self, data_dir: str | Path):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)

    def _path(self, project_id: str) -> Path:
        return self.data_dir / f"{project_id}.json"

    def load(self, project_id: str) -> Project:
        raw = self._path(project_id).read_text("utf-8")
        return Project.model_validate_json(raw)

    def save(self, project_id: str, project: Project) -> None:
        self._path(project_id).write_text(
            project.model_dump_json(indent=2, exclude_none=True),
            encoding="utf-8",
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

    def _key(self, project_id: str) -> str:
        if self.prefix:
            return f"{self.prefix}/{project_id}.json"
        return f"{project_id}.json"

    def load(self, project_id: str) -> Project:
        try:
            obj = self.client.get_object(Bucket=self.bucket, Key=self._key(project_id))
        except Exception as exc:
            code = getattr(exc, "response", {}).get("Error", {}).get("Code")
            if code in {"NoSuchKey", "404", "NotFound"}:
                raise FileNotFoundError(self._key(project_id)) from exc
            raise
        raw = obj["Body"].read().decode("utf-8")
        return Project.model_validate_json(raw)

    def save(self, project_id: str, project: Project) -> None:
        self.client.put_object(
            Bucket=self.bucket,
            Key=self._key(project_id),
            Body=project.model_dump_json(indent=2, exclude_none=True).encode("utf-8"),
            ContentType="application/json",
        )
