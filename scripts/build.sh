#!/usr/bin/env sh

VERSION=$(head -n 1 ./lncrawl/VERSION)

rm -rf .venv build dist *.egg-info

uv venv .venv
export UV_PROJECT_ENVIRONMENT=.venv
uv sync --extra dev

uv run python -m build -w
uv run python setup_pyi.py

rm -rf .venv build *.egg-info

# FINISHED
