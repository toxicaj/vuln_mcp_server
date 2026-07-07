FROM python:3.12-slim

WORKDIR /app

# CAUTION: The image keeps deliberately lax settings for classroom work:
# - packages install without supply-chain hardening
# - the workload executes as root
# - writable directories remain available
# Do not mirror these choices in real deployments.
COPY requirements.txt pyproject.toml README.md ./
COPY toxy_vulnerable_mcp ./toxy_vulnerable_mcp
COPY lab-data ./lab-data
COPY secrets ./secrets

RUN pip install --no-cache-dir -r requirements.txt && pip install --no-cache-dir .

ENV APP_ENV=training \
    DEBUG=true \
    LOG_LEVEL=DEBUG \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=8000 \
    MCP_TRANSPORT=streamable-http \
    DATABASE_PATH=/data/toxy_vulnerable_mcp.sqlite \
    TRAINING_SECRET=practice_env_value_leaked_by_system_info

RUN mkdir -p /data /lab-data /app/secrets && chmod -R 777 /data /lab-data /app/secrets

# FLAW: Root execution is intentional so filesystem labs have maximum impact.
# Hardening: drop to a service account, tighten mounts, and prefer read-only layers.
USER root

EXPOSE 8000

CMD ["uvicorn", "toxy_vulnerable_mcp.http_app:app", "--host", "0.0.0.0", "--port", "8000", "--log-level", "debug"]