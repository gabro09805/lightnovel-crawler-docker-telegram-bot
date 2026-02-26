ifeq ($(OS),Windows_NT)
	PYTHON := python
	YARN := yarn --cwd lncrawl-web
else
	PYTHON := python3
	ifneq ($(wildcard $(NVM_DIR)/nvm-exec),)
		YARN := "$(NVM_DIR)/nvm-exec" yarn --cwd lncrawl-web
	else
		YARN := yarn --cwd lncrawl-web
	endif
endif

VERSION := $(shell $(PYTHON) -c "print(open('lncrawl/VERSION').read().strip())")

.PHONY: all version clean setup install-py install-web install add-dep add-dev rm-dep rm-dev build-web build-wheel build-exe build start-server watch-server start-web start lint-py lint-web lint pull remove-tag push-tag push-tag-force docker-build docker-up docker-down docker-logs
all: version

version:
	@echo Current version: $(VERSION)

clean:
ifeq ($(OS),Windows_NT)
	@powershell -Command "try { Remove-Item -ErrorAction SilentlyContinue -Recurse -Force .venv, logs, build, dist } catch {}; exit 0"
	@powershell -Command "Get-ChildItem -ErrorAction SilentlyContinue -Recurse -Directory -Filter '*.egg-info' | Remove-Item -Recurse -Force"
	@powershell -Command "Get-ChildItem -ErrorAction SilentlyContinue -Recurse -Directory -Filter '__pycache__' | Remove-Item -Recurse -Force"
	@powershell -Command "Get-ChildItem -ErrorAction SilentlyContinue -Recurse -Directory -Filter 'node_modules' | Remove-Item -Recurse -Force"
else
	@rm -rf .venv logs build dist
	@find . -depth -name '*.egg-info' -type d -exec rm -rf '{}' \; 2>/dev/null || true
	@find . -depth -name '__pycache__' -type d -exec rm -rf '{}' \; 2>/dev/null || true
	@find . -depth -name 'node_modules' -type d -exec rm -rf '{}' \; 2>/dev/null || true
endif

setup:
ifeq ($(OS),Windows_NT)
	@where uv >nul 2>nul || powershell -NoProfile -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
else
	@command -v uv >/dev/null 2>&1 || (curl -LsSf https://astral.sh/uv/install.sh | sh)
endif

install-py: setup
	uv sync --extra dev

install-web:
	$(YARN) install

install: install-py install-web

build-web:
	$(YARN) build

build-wheel:
	uv run python -m build -w

build-exe:
	uv run python setup_pyi.py

build: version install build-web build-wheel build-exe

start-server:
	uv run python -m lncrawl -ll server

watch-server:
	uv run python -m lncrawl -ll server --watch

start-web:
	$(YARN) dev --host

start:
	+$(MAKE) -j2 watch-server start-web

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

lint-py:
	uv run flake8 --config .flake8 -v --count --show-source --statistics

lint-web:
	$(YARN) lint

lint: lint-py lint-web

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
