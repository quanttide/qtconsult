import os
from pathlib import Path


class Settings:
    api_token: str = os.getenv("QTCONSULT_API_TOKEN", "")
    workspace_id: str = os.getenv("QTCONSULT_WORKSPACE_ID", "")

    storage_backend: str = os.getenv("QTCONSULT_STORAGE", "local")

    data_dir: Path = Path(
        os.getenv("QTCONSULT_DATA_DIR", Path(__file__).resolve().parent.parent / "data")
    )

    s3_bucket: str = os.getenv("QTCONSULT_S3_BUCKET", "")
    s3_prefix: str = os.getenv("QTCONSULT_S3_PREFIX", "")
    s3_region: str = os.getenv("QTCONSULT_S3_REGION", "cn-hangzhou")
    s3_endpoint_url: str = os.getenv("QTCONSULT_S3_ENDPOINT_URL", "")
    s3_access_key_id: str = os.getenv("QTCONSULT_S3_ACCESS_KEY_ID", "")
    s3_secret_access_key: str = os.getenv("QTCONSULT_S3_SECRET_ACCESS_KEY", "")
    s3_addressing_style: str = os.getenv("QTCONSULT_S3_ADDRESSING_STYLE", "virtual")


settings = Settings()
