import os
from pathlib import Path


class Settings:
    api_token: str = os.getenv("QTCONSULT_API_TOKEN", "")

    storage_backend: str = os.getenv("QTCONSULT_STORAGE", "local")

    data_dir: Path = Path(
        os.getenv("QTCONSULT_DATA_DIR", Path(__file__).resolve().parent.parent / "data")
    )

    s3_bucket: str = os.getenv("QTCONSULT_S3_BUCKET", "")
    s3_prefix: str = os.getenv("QTCONSULT_S3_PREFIX", "")


settings = Settings()
