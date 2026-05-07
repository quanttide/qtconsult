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
    def __init__(self, bucket: str, prefix: str = ""):
        self.bucket = bucket
        self.prefix = prefix.strip("/")
        try:
            import boto3
            self.client = boto3.client("s3")
        except ImportError:
            raise ImportError("boto3 is required for S3 storage")

    def _key(self, project_id: str) -> str:
        if self.prefix:
            return f"{self.prefix}/{project_id}.json"
        return f"{project_id}.json"

    def load(self, project_id: str) -> Project:
        import json
        obj = self.client.get_object(Bucket=self.bucket, Key=self._key(project_id))
        raw = obj["Body"].read().decode("utf-8")
        return Project.model_validate_json(raw)

    def save(self, project_id: str, project: Project) -> None:
        self.client.put_object(
            Bucket=self.bucket,
            Key=self._key(project_id),
            Body=project.model_dump_json(indent=2, exclude_none=True).encode("utf-8"),
            ContentType="application/json",
        )
