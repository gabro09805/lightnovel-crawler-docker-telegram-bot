# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Setup virtual environment and Install Python dependencies
make install

# Run development servers
make start         # Backend server only
make watch         # Backend with auto-reload

# Build
make build         # Full build (web + wheel + exe)
make build-wheel   # Python wheel only
make build-exe     # PyInstaller executable

# Linting
make lint          # Both Python and web
make lint-py       # Python (flake8)
make lint-web      # Web frontend (eslint)

# Dependencies (uv)
make add-dep httpx          # Add runtime dependency
make add-dev black          # Add dev dependency
make rm-dep httpx           # Remove runtime dependency
make rm-dev black           # Remove dev dependency

# Docker Commands
make docker-build       # Build application Docker image
make docker-up          # Start containers in background
make docker-down        # Stop containers
make docker-logs

# Run from source directly
uv run python -m lncrawl
```

## Architecture Overview

### Entry Point & Application Context

- **`lncrawl/__main__.py`**: Entry point, calls `main()` from `lncrawl.app`
- **`lncrawl/context.py`**: `AppContext` singleton manages all services via lazy-loaded properties
- **`lncrawl/app.py`**: CLI setup using Typer, registers subcommands (crawl, search, server, sources, config)

### Source Crawlers

**Location**: `sources/` - Organized by language (`en/`, `zh/`, `ja/`, etc.), English further split alphabetically

**Key Base Classes**:

- `lncrawl/core/crawler.py`: `Crawler` class - extend this to create new source crawlers
  - Required: `read_novel_info()`, `download_chapter_body()`
  - Optional: `initialize()`, `login()`, `search_novel()`
- `lncrawl/core/scraper.py`: `Scraper` base - HTTP requests, BeautifulSoup parsing, Cloudflare handling
- `lncrawl/core/taskman.py`: `TaskManager` - ThreadPoolExecutor for concurrent operations

**Crawler Registration**: `lncrawl/services/sources/service.py`

- Crawlers auto-discovered by importing Python files from source directories
- Each crawler has: `__id__`, `base_url`, `version` metadata
- Full-text search index for fast source lookup

### Server/API

**FastAPI Server**: `lncrawl/server/app.py`

- REST API at `/api`, frontend at `/`
- Endpoints in `lncrawl/server/api/`: novels, chapters, volumes, jobs, artifacts, auth, libraries

### Output Generation

**Binder Service**: `lncrawl/services/binder/`

- `epub.py`: Native EPUB generation (primary format)
- `calibre.py`: Converts EPUB to other formats (MOBI, PDF, DOCX, etc.) via Calibre
- `json.py`, `text.py`: JSON and plain text formats

### Data Models

- **`lncrawl/models/`**: Chapter, Volume, Novel, SearchResult, Session
- **`lncrawl/dao/`**: Database access objects (SQLAlchemy/SQLModel)

### Services (via AppContext)

`lncrawl` is structured around a set of **services**, each responsible for a major piece of application functionality. All core services are accessed via the singleton `AppContext` (usually as `ctx` in code). This allows shared, on-demand initialization and simple dependency management throughout the app.

**Key services available from the app context:**

- **config**: Configuration manager (loads and saves user settings, environment variables, CLI flags)
- **db**: Database access (SQLModel, manages library, jobs, novels, chapters)
- **http**: HTTP client (handles web requests, session, caching, retries, Cloudflare support)
- **sources**: Source crawler registry/discovery (loads all available crawlers, search/index)
- **crawler**: The currently selected/active crawler instance (handles all scraping logic for a selected source)
- **binder**: Output/binding manager (handles EPUB generation, invoking Calibre for conversions, text export)
- **jobs**: Background job/task queue (for crawling, downloads, conversions)
- **novels**: Novel library management (add/remove novels, metadata)
- **chapters**: Chapters manager (fetch/save chapter data)
- **volumes**: Volumes manager (volume/chapter grouping, manipulation)

All services are **lazily loaded** as properties of the context to optimize performance and resource use.

For command-line tools, FastAPI server endpoints, and crawlers, you should always access shared services via `ctx` for consistency and compatibility.

## Creating a New Source Crawler

**Full guide:** [.github/docs/CREATING_CRAWLERS.md](.github/docs/CREATING_CRAWLERS.md)

**Recommended:** Copy **`sources/_examples/_01_general_soup.py`** and use **`GeneralSoupTemplate`** (`lncrawl.templates.soup.general`). Implement:

- **Required:** `parse_title(soup)`, `parse_cover(soup)`, `parse_chapter_list(soup)` (yield `Chapter`/`Volume`), `select_chapter_body(soup)` (return the chapter text Tag).
- **Optional:** `parse_authors(soup)`, `parse_summary(soup)`, `get_novel_soup()`, `initialize()`, `login()`.

For search use `_02_searchable_soup.py` (SearchableSoupTemplate)

For volumes use `_05_with_volume_soup.py` or `_07_optional_volume_soup.py`

For JS-heavy sites use browser examples (`_09`–`_17`).

Alternative: base **`Crawler`** with `read_novel_info()` and `download_chapter_body()` via `_00_basic.py`.

Test: `uv run python -m lncrawl -s "URL" --first 3 -f` and `uv run python -m lncrawl sources list | grep mysite`.
