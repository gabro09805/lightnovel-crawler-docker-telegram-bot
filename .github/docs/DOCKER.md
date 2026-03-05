# Docker Usage

This guide covers using Docker to run Lightnovel Crawler.

## Quick Start

### Pull and Run

```bash
# Pull the latest image
docker pull ghcr.io/lncrawl/lightnovel-crawler:latest

# Run interactively
docker run -it --rm ghcr.io/lncrawl/lightnovel-crawler:latest

# Run with a specific command
docker run -it --rm ghcr.io/lncrawl/lightnovel-crawler:latest -h
```

### Persist Downloads

Mount a volume to persist downloaded novels:

```bash
docker run -it --rm \
  -v $(pwd)/downloads:/data \
  ghcr.io/lncrawl/lightnovel-crawler:latest
```

## Server Mode

Run the web server with docker compose:

```bash
# Using make (recommended)
make docker-up

# Or directly
docker compose -f scripts/local-compose.yml up -d
```

The server will be available at `http://localhost:23457`. To view logs: `make docker-logs`. To stop: `make docker-down`.

### Server Environment Variables

| Variable            | Description                  | Default |
| ------------------- | ---------------------------- | ------- |
| `LNCRAWL_DATA_PATH` | Data storage path            | `/data` |
| `DATABASE_URL`      | PostgreSQL connection string | SQLite  |
| `PYTHONUNBUFFERED`  | Unbuffered Python output     | `1`     |

## Building Locally

### Build Application Image

```bash
# Using make (builds base image first, then app)
make docker-build

# Or directly (requires an existing base image)
docker build -t lncrawl .
```

### Build Base Image

The base image includes Calibre and system dependencies. Required before `make docker-build` if you don't pull it:

```bash
make docker-base

# Or directly
docker build -t lncrawl-base -f Dockerfile.base .
```

### Build with Custom Base Image

If you've built a custom base image:

```bash
docker build --build-arg BASE_IMAGE=ghcr.io/myuser/lncrawl-base -t lncrawl .
```

## Multi-Architecture Support

Images are built for both `linux/amd64` and `linux/arm64`:

```bash
# Build multi-arch image with buildx
docker buildx build --platform linux/amd64,linux/arm64 -t lncrawl .
```

## Docker Compose Files

### Local Development (`scripts/local-compose.yml`)

Basic setup for local development with PostgreSQL.

### Server Deployment (`scripts/server-compose.yml`)

Production setup with:

- PostgreSQL with resource limits
- Server mode with auto-restart
- Volume persistence

### Discord Bot (`scripts/discord-compose.yml`)

Discord bot integration setup.

## Customization

### Using Your Own Base Image

1. Modify `Dockerfile.base` as needed
2. Build and push your base image:
   ```bash
   docker build -f Dockerfile.base -t ghcr.io/myuser/lncrawl-base .
   docker push ghcr.io/myuser/lncrawl-base
   ```
3. Build the application with your base:
   ```bash
   docker build --build-arg BASE_IMAGE=ghcr.io/myuser/lncrawl-base -t lncrawl .
   ```

### Adding Custom Sources

Mount your custom sources directory:

```bash
docker run -it --rm \
  -v $(pwd)/my-sources:/app/sources/custom \
  ghcr.io/lncrawl/lightnovel-crawler:latest
```

## Troubleshooting

### Container Won't Start

Check logs:

```bash
docker logs <container_id>
```

### Permission Issues

The container runs as root by default. For volume mounts, ensure proper permissions:

```bash
sudo chown -R 1000:1000 ./downloads
```

### Calibre Not Working

Calibre requires GUI libraries. The base image includes these, but headless operation should work. If you encounter issues, ensure you're using the official base image.

### ARM64 Build Issues

ARM64 builds use QEMU emulation in CI and may take longer. If local builds fail:

1. Ensure Docker buildx is configured
2. Ensure QEMU is installed for cross-platform builds

## Makefile Targets

| Target              | Description                       |
| ------------------- | --------------------------------- |
| `make docker-base`  | Build base image (Calibre + deps) |
| `make docker-build` | Build base then application image |
| `make docker-up`    | Start server stack (compose)      |
| `make docker-down`  | Stop server stack                 |
| `make docker-logs`  | Stream compose logs               |

## Image Tags

| Tag      | Description             |
| -------- | ----------------------- |
| `latest` | Latest stable release   |
| `v4.x.x` | Specific version        |
| `server` | Server deployment image |
| `<sha>`  | Specific commit         |
