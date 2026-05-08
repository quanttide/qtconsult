from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from app.config import settings

security = HTTPBearer(auto_error=False)


def _parse_workspace_from_token(token: str) -> str | None:
    """Token format: '{workspace_id}:{secret}' or plain '{secret}'."""
    if ":" in token:
        parts = token.split(":", 1)
        return parts[0]
    return None


def _matches_secret(token: str) -> bool:
    if ":" in token:
        return token.split(":", 1)[1] == settings.api_token
    return token == settings.api_token


async def verify_token(request: Request, credentials: HTTPAuthorizationCredentials | None = Depends(security)):
    if not settings.api_token:
        return

    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing token")

    token = credentials.credentials
    if not _matches_secret(token):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    # Validate workspace scope from token
    token_wid = _parse_workspace_from_token(token)
    if token_wid:
        url_wid = request.path_params.get("workspace_id")
        if url_wid and token_wid != url_wid:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Token scoped to workspace '{token_wid}', cannot access '{url_wid}'",
            )
