# QtConsult Provider

Backend data provider for the QtConsult board.

## Stack

- Python 3.12+
- FastAPI
- Local JSON or S3-compatible storage

## Quick Start

```bash
python -m uvicorn app.main:app --reload
```

## Configuration

| Variable | Description | Default |
| --- | --- | --- |
| `QTCONSULT_API_TOKEN` | Bearer token for write APIs. Empty disables auth. | `""` |
| `QTCONSULT_STORAGE` | Storage backend: `local` or `s3`. | `local` |
| `QTCONSULT_DATA_DIR` | Local data directory. | `src/provider/data` |
| `QTCONSULT_S3_BUCKET` | S3-compatible bucket name. | `""` |
| `QTCONSULT_S3_PREFIX` | Object key prefix. Use `platform` for provider-owned archive paths. | `""` |
| `QTCONSULT_S3_REGION` | S3 region. | `cn-hangzhou` |
| `QTCONSULT_S3_ENDPOINT_URL` | S3-compatible endpoint, such as Aliyun OSS. | `""` |
| `QTCONSULT_S3_ACCESS_KEY_ID` | S3 access key ID. Falls back to normal boto3 credential resolution if empty. | `""` |
| `QTCONSULT_S3_SECRET_ACCESS_KEY` | S3 secret access key. | `""` |
| `QTCONSULT_S3_ADDRESSING_STYLE` | `virtual` or `path`. | `virtual` |

Aliyun OSS S3-compatible example:

```bash
QTCONSULT_STORAGE=s3
QTCONSULT_S3_BUCKET=qtconsult-provider
QTCONSULT_S3_PREFIX=platform
QTCONSULT_S3_REGION=cn-hangzhou
QTCONSULT_S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
QTCONSULT_S3_ACCESS_KEY_ID=...
QTCONSULT_S3_SECRET_ACCESS_KEY=...
QTCONSULT_S3_ADDRESSING_STYLE=virtual
```

The `platform/` prefix aligns provider-owned data with the hot archive layout in `docs/dev/storage.md`.

## API

| Method | Path | Description | Auth |
| --- | --- | --- | --- |
| `GET` | `/project` | Get the full project. | No |
| `GET` | `/project/lists/{name}` | Get one board list. | No |
| `GET` | `/project/cards/{id}` | Get one card. | No |
| `POST` | `/project/cards?list_name={name}` | Create a card. | Yes |
| `PUT` | `/project/cards/{id}` | Patch a card. | Yes |
| `DELETE` | `/project/cards/{id}` | Delete a card. | Yes |

## Test

```bash
python -m pytest tests -q
```
