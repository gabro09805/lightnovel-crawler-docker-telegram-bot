@ECHO OFF

SET /P VERSION=<lncrawl\VERSION

RD /S /Q "dist" ".venv" "build" "lightnovel_crawler.egg-info" 2>nul

uv venv .venv
SET UV_PROJECT_ENVIRONMENT=.venv
uv sync --extra dev

uv run python -m build -w
uv run python setup_pyi.py

RD /S /Q ".venv" "build" "lightnovel_crawler.egg-info" 2>nul

ECHO ON
