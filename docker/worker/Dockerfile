# VitalFlow Worker Service Dockerfile (Celery)
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
    ffmpeg \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r vitalflow && useradd -r -g vitalflow vitalflow

# Copy requirements first for better caching
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Install additional worker dependencies
RUN pip install --no-cache-dir celery[redis] flower

# Copy application code
COPY src/ /app/src/
COPY config/ /app/config/
COPY scripts/ /app/scripts/
COPY assets/ /app/assets/

# Copy worker-specific files
COPY vitalflow_content_generator.py /app/

# Create necessary directories
RUN mkdir -p /app/data /app/logs /app/generated_content /app/templates

# Set permissions
RUN chown -R vitalflow:vitalflow /app
USER vitalflow

# Health check (check if worker is responsive)
HEALTHCHECK --interval=60s --timeout=30s --start-period=10s --retries=3 \
    CMD celery -A src.worker inspect ping || exit 1

# Default command (will be overridden in docker-compose)
CMD ["celery", "-A", "src.worker", "worker", "--loglevel=info", "--concurrency=4"]

