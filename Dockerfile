ARG BASE_IMAGE=ghcr.io/lncrawl/lncrawl-base:latest

FROM ${BASE_IMAGE} AS app

WORKDIR /app

# Install dependencies and project with uv
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Copy files
COPY LICENSE ./
COPY README* ./
COPY lncrawl ./lncrawl
COPY sources ./sources

# Custom data path
ENV LNCRAWL_DATA_PATH=/data

ENTRYPOINT ["uv", "run", "python", "-m", "lncrawl"]
