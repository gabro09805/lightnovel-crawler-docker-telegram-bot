ifeq ($(OS),Windows_NT)
	PYTHON := python
	VENV := .venv-win
	UV_VENV := set VIRTUAL_ENV=$(VENV) && set UV_PROJECT_ENVIRONMENT=$(VENV) && uv
	YARN := yarn --cwd lncrawl-web
else
	PYTHON := python3
	VENV := .venv-posix
	UV_VENV := VIRTUAL_ENV=$(VENV) UV_PROJECT_ENVIRONMENT=$(VENV) uv
	ifneq ($(wildcard $(NVM_DIR)/nvm-exec),)
		YARN := "$(NVM_DIR)/nvm-exec" yarn --cwd lncrawl-web
	else
		YARN := yarn --cwd lncrawl-web
	endif
endif

PKG := $(word 2,$(MAKECMDGOALS))
VERSION := $(shell $(PYTHON) -c "print(open('lncrawl/VERSION').read().strip())")

.PHONY: all version clean ensure-uv setup install-py install-web install add-dep add-dev rm-dep rm-dev build-web build-wheel build-exe build start-server watch-server start-web start lint-py lint-web lint pull remove-tag push-tag push-tag-force docker-build docker-up docker-down docker-logs
all: version

version:
	@echo Current version: $(VERSION)

clean:
ifeq ($(OS),Windows_NT)
	@powershell -Command "try { Remove-Item -ErrorAction SilentlyContinue -Recurse -Force $(VENV), logs, build, dist } catch {}; exit 0"
	@powershell -Command "Get-ChildItem -ErrorAction SilentlyContinue -Recurse -Directory -Filter '*.egg-info' | Remove-Item -Recurse -Force"
	@powershell -Command "Get-ChildItem -ErrorAction SilentlyContinue -Recurse -Directory -Filter '__pycache__' | Remove-Item -Recurse -Force"
	@powershell -Command "Get-ChildItem -ErrorAction SilentlyContinue -Recurse -Directory -Filter 'node_modules' | Remove-Item -Recurse -Force"
else
	@rm -rf $(VENV) logs build dist
	@find . -depth -name '*.egg-info' -type d -exec rm -rf '{}' \; 2>/dev/null || true
	@find . -depth -name '__pycache__' -type d -exec rm -rf '{}' \; 2>/dev/null || true
	@find . -depth -name 'node_modules' -type d -exec rm -rf '{}' \; 2>/dev/null || true
endif

ensure-uv:
ifeq ($(OS),Windows_NT)
	@where uv >nul 2>nul || powershell -NoProfile -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
else
	@command -v uv >/dev/null 2>&1 || (curl -LsSf https://astral.sh/uv/install.sh | sh)
endif

setup: ensure-uv
ifeq ($(wildcard $(VENV)/pyvenv.cfg),)
	uv venv $(VENV) --python $(PYTHON)
else
	$(info $(VENV) already exists.)
endif

install-py: setup
	$(UV_VENV) sync --extra dev

install-web:
	$(YARN) install

install: install-py install-web

build-web:
	$(YARN) build

build-wheel:
	$(UV_VENV) run python -m build -w

build-exe:
	$(UV_VENV) run python setup_pyi.py

build: version install build-web build-wheel build-exe

start-server:
	$(UV_VENV) run python -m lncrawl -ll server

watch-server:
	$(UV_VENV) run python -m lncrawl -ll server --watch

start-web:
	$(YARN) dev -- --host

start:
	+$(MAKE) -j2 watch-server start-web

add-dep: ensure-uv
	@test -n "$(PKG)" || (echo "Usage: make add-dep <package>  e.g. make add-dep httpx" && exit 1)
	uv add $(PKG)
	$(UV_VENV) sync --extra dev

add-dev: ensure-uv
	@test -n "$(PKG)" || (echo "Usage: make add-dev <package>  e.g. make add-dev pytest" && exit 1)
	uv add --optional dev $(PKG)
	$(UV_ENV) sync --extra dev

rm-dep: ensure-uv
	@test -n "$(PKG)" || (echo "Usage: make rm-dep <package>  e.g. make rm-dep httpx" && exit 1)
	uv remove $(PKG)
	$(UV_ENV) uv sync --extra dev

rm-dev: ensure-uv
	@test -n "$(PKG)" || (echo "Usage: make rm-dev <package>  e.g. make rm-dev pytest" && exit 1)
	uv remove --optional dev $(PKG)
	$(UV_ENV) sync --extra dev

lint-py:
	$(UV_VENV) run flake8 --config .flake8 -v --count --show-source --statistics

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

docker-build:
	docker build -t lncrawl .

docker-up:
	docker compose -f scripts/local-compose.yml up -d

docker-down:
	docker compose -f scripts/local-compose.yml down

docker-logs:
	docker compose -f scripts/local-compose.yml logs -f

ifneq (,$(filter add-dep add-dev rm-dep rm-dev,$(MAKECMDGOALS)))
$(word 2,$(MAKECMDGOALS)):
	@:
endif
