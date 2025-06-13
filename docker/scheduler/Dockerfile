# VitalFlow Scheduler Service Dockerfile (Celery Beat)
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    C_FORCE_ROOT=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    postgresql-client \
    redis-tools \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r vitalflow && useradd -r -g vitalflow vitalflow

# Copy requirements first for better caching
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Install additional scheduler dependencies
RUN pip install --no-cache-dir celery[redis] django-celery-beat

# Copy application code
COPY src/ /app/src/
COPY config/ /app/config/
COPY scripts/ /app/scripts/

# Create necessary directories
RUN mkdir -p /app/data /app/logs

# Set permissions
RUN chown -R vitalflow:vitalflow /app
USER vitalflow

# Health check (check if beat scheduler is running)
HEALTHCHECK --interval=60s --timeout=30s --start-period=10s --retries=3 \
    CMD pgrep -f "celery.*beat" || exit 1

# Default command (will be overridden in docker-compose)
CMD ["celery", "-A", "src.scheduler", "beat", "--loglevel=info", "--schedule=/app/data/celerybeat-schedule"]

