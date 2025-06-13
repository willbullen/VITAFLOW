# VitalFlow Analytics Service Dockerfile
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

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

# Copy application code
COPY src/ /app/src/
COPY config/ /app/config/
COPY scripts/ /app/scripts/

# Copy analytics-specific files
COPY vitalflow_analytics.py /app/

# Create necessary directories
RUN mkdir -p /app/data /app/logs /app/reports

# Set permissions
RUN chown -R vitalflow:vitalflow /app
USER vitalflow

# Expose port
EXPOSE 5002

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5002/health || exit 1

# Default command
CMD ["python", "-m", "gunicorn", "--bind", "0.0.0.0:5002", "--workers", "2", "--timeout", "120", "--keep-alive", "2", "src.analytics.main:app"]

