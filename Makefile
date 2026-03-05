.PHONY: all version clean setup install add-dep add-dev rm-dep rm-dev build-wheel build-exe build start watch lint pull remove-tag push-tag push-tag-force docker-build docker-up docker-down docker-logs
all: version

VERSION := $(strip $(file < lncrawl/VERSION))
version:
	@echo Current version: $(VERSION)

clean:
ifeq ($(OS),Windows_NT)
	@powershell -Command "try { Remove-Item -ErrorAction SilentlyContinue -Recurse -Force .venv, logs, build, dist } catch {}; exit 0"
	@powershell -Command "Get-ChildItem -ErrorAction SilentlyContinue -Recurse -Directory -Filter '*.egg-info' | Remove-Item -Recurse -Force"
	@powershell -Command "Get-ChildItem -ErrorAction SilentlyContinue -Recurse -Directory -Filter '__pycache__' | Remove-Item -Recurse -Force"
else
	@rm -rf .venv logs build dist
	@find . -depth -name '*.egg-info' -type d -exec rm -rf '{}' \; 2>/dev/null || true
	@find . -depth -name '__pycache__' -type d -exec rm -rf '{}' \; 2>/dev/null || true
endif

setup:
ifeq ($(OS),Windows_NT)
	@where uv >nul 2>nul || powershell -NoProfile -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
else
	@command -v uv >/dev/null 2>&1 || (curl -LsSf https://astral.sh/uv/install.sh | sh)
endif

install: setup
	uv sync --extra dev

lint:
	uv run flake8 --config .flake8 -v --count --show-source --statistics

start:
	uv run python -m lncrawl -ll server

watch:
	uv run python -m lncrawl -ll server --watch

build-wheel:
	uv run python -m build -w

build-exe:
	uv run python setup_pyi.py

build: version install build-wheel build-exe

add-dep: setup
	uv add $(word 2,$(MAKECMDGOALS))
	uv sync --extra dev

add-dev: setup
	uv add --optional dev $(word 2,$(MAKECMDGOALS))
	uv sync --extra dev

rm-dep: setup
	uv remove $(word 2,$(MAKECMDGOALS))
	uv sync --extra dev

rm-dev: setup
	uv remove --optional dev $(word 2,$(MAKECMDGOALS))
	uv sync --extra dev

pull:
	git pull --rebase --autostash

remove-tag:
	git push --delete origin "v$(VERSION)"
	git tag -d "v$(VERSION)"

push-tag: pull
	git tag "v$(VERSION)"
	git push --tags

push-tag-force: pull
	git push --delete origin "v$(VERSION)"
	git tag -d "v$(VERSION)"
	git tag "v$(VERSION)"
	git push --tags

docker-base:
	docker build -t lncrawl-base -f Dockerfile.base .

docker-build: docker-base
	docker build -t lncrawl --build-arg BASE_IMAGE=lncrawl-base .

docker-up:
	docker compose -f scripts/local-compose.yml up -d

docker-down:
	docker compose -f scripts/local-compose.yml down

docker-logs:
	docker compose -f scripts/local-compose.yml logs -f
