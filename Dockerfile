FROM python:3.11-slim

# build-essential + libpq-dev: some transitive deps (psycopg2, MetricFlow's C-extension
# requirements) need to compile against libpq when a prebuilt wheel isn't available for the
# target platform (e.g. arm64). git: dbt's dependency check (`dbt debug`) and `dbt deps` for
# git-sourced packages both require the git binary on PATH.
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libpq-dev git \
    && rm -rf /var/lib/apt/lists/*

ENV PIP_NO_CACHE_DIR=1 \
    DBT_PROFILES_DIR=/usr/app \
    DBT_PROJECT_DIR=/usr/app

WORKDIR /usr/app

# Installed before the rest of the project so this layer only rebuilds when dependencies change.
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . .

# Keeps the container alive for `docker compose exec dbt <command>`; docker-compose.yml
# bind-mounts the project over this COPY so local edits are picked up without a rebuild.
CMD ["tail", "-f", "/dev/null"]
