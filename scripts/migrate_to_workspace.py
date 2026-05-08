"""
迁移 v0.1.0 存量数据到 workspace 结构。

用法:
    python scripts/migrate_to_workspace.py

将 src/provider/data/ 下的扁平 project1.json 迁移到 workspace1/project1.json，
并补充 workspace_id 字段。
"""

import json
import shutil
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parent.parent / "src" / "provider" / "data"


def migrate_project(data_dir: Path, project_id: str, workspace_id: str = "workspace1"):
    old_path = data_dir / f"{project_id}.json"
    if not old_path.exists():
        print(f"[跳过] {old_path} 不存在")
        return

    new_dir = data_dir / workspace_id
    new_dir.mkdir(parents=True, exist_ok=True)
    new_path = new_dir / f"{project_id}.json"

    if new_path.exists():
        print(f"[跳过] 目标已存在 {new_path}")
        return

    raw = old_path.read_text("utf-8")
    data = json.loads(raw)
    data["workspace_id"] = workspace_id

    new_path.write_text(
        json.dumps(data, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"[迁移] {old_path} → {new_path} (added workspace_id={workspace_id})")

    backup = old_path.with_suffix(".json.bak")
    shutil.move(str(old_path), str(backup))
    print(f"[备份] {old_path} → {backup}")


def main():
    migrate_project(DATA_DIR, "project1", "workspace1")
    print("[完成] 存量数据迁移结束")


if __name__ == "__main__":
    main()
