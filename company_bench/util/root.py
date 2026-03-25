from pathlib import Path


def get_project_root() -> Path:
    """向上查找 pyproject.toml 所在目录作为项目根目录。"""
    path = Path(__file__).resolve().parent
    while path != path.parent:
        if (path / "pyproject.toml").exists():
            return path
        path = path.parent
    raise FileNotFoundError("找不到 pyproject.toml")


PROJECT_ROOT = get_project_root()
