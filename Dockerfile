ARG BASE_IMAGE=ghcr.io/lncrawl/lncrawl-base:latest

##
# Web assets
##
FROM node:20-alpine AS web

WORKDIR /app/lncrawl-web

COPY lncrawl-web/package.json lncrawl-web/yarn.lock ./
RUN yarn install --frozen-lockfile

COPY lncrawl-web .
RUN yarn build

##
# Application
##
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
COPY --from=web /app/lncrawl/server/web ./lncrawl/server/web

# Custom data path
ENV LNCRAWL_DATA_PATH=/data

ENTRYPOINT ["uv", "run", "lncrawl"]