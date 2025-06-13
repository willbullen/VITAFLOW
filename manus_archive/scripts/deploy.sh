#!/bin/bash

# VitalFlow Automation Deployment Script
# Usage: ./deploy.sh [staging|production]

set -e  # Exit on any error

# Configuration
ENVIRONMENT=${1:-staging}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    error "Invalid environment: $ENVIRONMENT. Use 'staging' or 'production'"
    exit 1
fi

log "🚀 Starting VitalFlow Automation deployment to $ENVIRONMENT"

# Load environment variables
if [[ -f "$PROJECT_ROOT/.env.$ENVIRONMENT" ]]; then
    log "📄 Loading environment variables from .env.$ENVIRONMENT"
    source "$PROJECT_ROOT/.env.$ENVIRONMENT"
elif [[ -f "$PROJECT_ROOT/.env" ]]; then
    log "📄 Loading environment variables from .env"
    source "$PROJECT_ROOT/.env"
else
    warning "No environment file found. Using system environment variables."
fi

# Pre-deployment checks
log "🔍 Running pre-deployment checks..."

# Check Python version
if ! python3 --version | grep -q "3.11\|3.12"; then
    error "Python 3.11+ is required"
    exit 1
fi

# Check required environment variables
required_vars=("TIKTOK_ACCESS_TOKEN" "SUPLIFUL_API_KEY")
for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        error "Required environment variable $var is not set"
        exit 1
    fi
done

# Create necessary directories
log "📁 Creating deployment directories..."
mkdir -p logs data backups

# Backup current deployment (production only)
if [[ "$ENVIRONMENT" == "production" ]]; then
    log "💾 Creating backup of current deployment..."
    backup_dir="backups/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup database
    if [[ -f "data/vitalflow.db" ]]; then
        cp data/vitalflow.db "$backup_dir/"
        log "✅ Database backed up"
    fi
    
    # Backup configuration
    if [[ -f ".env" ]]; then
        cp .env "$backup_dir/"
        log "✅ Configuration backed up"
    fi
    
    # Backup logs
    if [[ -d "logs" ]]; then
        cp -r logs "$backup_dir/"
        log "✅ Logs backed up"
    fi
fi

# Install/Update dependencies
log "📦 Installing Python dependencies..."
python3 -m pip install --upgrade pip
pip3 install -r requirements.txt

# Install Node.js dependencies
if [[ -f "package.json" ]]; then
    log "📦 Installing Node.js dependencies..."
    npm ci --production
fi

# Database migration
log "🗄️ Running database migrations..."
python3 scripts/migrate_database.py --environment "$ENVIRONMENT"

# Build application
log "🏗️ Building application..."
python3 scripts/build.py --environment "$ENVIRONMENT"

# Stop existing services
log "🛑 Stopping existing services..."
pkill -f "python.*main.py" || true
pkill -f "python.*tiktok_automation.py" || true
pkill -f "python.*vitalflow_analytics.py" || true
pkill -f "n8n" || true

# Wait for services to stop
sleep 5

# Start services
log "🚀 Starting VitalFlow services..."

# Start API service
log "🔧 Starting API service..."
nohup python3 src/api/main.py > logs/api.log 2>&1 &
API_PID=$!
echo $API_PID > logs/api.pid

# Start TikTok automation
log "📱 Starting TikTok automation service..."
nohup python3 src/automation/tiktok_automation.py > logs/tiktok.log 2>&1 &
TIKTOK_PID=$!
echo $TIKTOK_PID > logs/tiktok.pid

# Start analytics service
log "📊 Starting analytics service..."
nohup python3 src/analytics/vitalflow_analytics.py > logs/analytics.log 2>&1 &
ANALYTICS_PID=$!
echo $ANALYTICS_PID > logs/analytics.pid

# Start n8n workflows
log "🔄 Starting n8n workflows..."
nohup n8n start --tunnel > logs/n8n.log 2>&1 &
N8N_PID=$!
echo $N8N_PID > logs/n8n.pid

# Wait for services to start
log "⏳ Waiting for services to start..."
sleep 10

# Health checks
log "🏥 Running health checks..."
python3 scripts/health_check.py --environment "$ENVIRONMENT"

if [[ $? -eq 0 ]]; then
    success "✅ All services are healthy!"
else
    error "❌ Health check failed!"
    
    # Show recent logs
    log "📋 Recent API logs:"
    tail -20 logs/api.log
    
    log "📋 Recent TikTok automation logs:"
    tail -20 logs/tiktok.log
    
    log "📋 Recent analytics logs:"
    tail -20 logs/analytics.log
    
    exit 1
fi

# Update monitoring configuration
log "📊 Updating monitoring configuration..."
python3 scripts/update_monitoring.py --environment "$ENVIRONMENT"

# Generate deployment report
log "📈 Generating deployment report..."
python3 scripts/deployment_report.py --environment "$ENVIRONMENT"

# Set up log rotation
log "🔄 Setting up log rotation..."
cat > /etc/logrotate.d/vitalflow << EOF
$PROJECT_ROOT/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 ubuntu ubuntu
    postrotate
        # Restart services if needed
        systemctl reload vitalflow || true
    endscript
}
EOF

# Set up systemd services (production only)
if [[ "$ENVIRONMENT" == "production" ]]; then
    log "⚙️ Setting up systemd services..."
    
    # Create systemd service files
    cat > /etc/systemd/system/vitalflow-api.service << EOF
[Unit]
Description=VitalFlow API Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=$PROJECT_ROOT
ExecStart=/usr/bin/python3 src/api/main.py
Restart=always
RestartSec=10
Environment=ENVIRONMENT=production

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/systemd/system/vitalflow-automation.service << EOF
[Unit]
Description=VitalFlow TikTok Automation Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=$PROJECT_ROOT
ExecStart=/usr/bin/python3 src/automation/tiktok_automation.py
Restart=always
RestartSec=10
Environment=ENVIRONMENT=production

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/systemd/system/vitalflow-analytics.service << EOF
[Unit]
Description=VitalFlow Analytics Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=$PROJECT_ROOT
ExecStart=/usr/bin/python3 src/analytics/vitalflow_analytics.py
Restart=always
RestartSec=10
Environment=ENVIRONMENT=production

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable services
    systemctl daemon-reload
    systemctl enable vitalflow-api vitalflow-automation vitalflow-analytics
    
    log "✅ Systemd services configured"
fi

# Final status check
log "🔍 Final status check..."
sleep 5
python3 scripts/health_check.py --environment "$ENVIRONMENT" --detailed

# Deployment summary
log "📋 Deployment Summary:"
log "   Environment: $ENVIRONMENT"
log "   Timestamp: $(date)"
log "   API PID: $API_PID"
log "   TikTok Automation PID: $TIKTOK_PID"
log "   Analytics PID: $ANALYTICS_PID"
log "   n8n PID: $N8N_PID"

# Service URLs
if [[ "$ENVIRONMENT" == "production" ]]; then
    log "🌐 Service URLs:"
    log "   API: https://api.vitalflow.com"
    log "   Analytics: https://analytics.vitalflow.com"
    log "   n8n: https://workflows.vitalflow.com"
else
    log "🌐 Service URLs:"
    log "   API: http://localhost:5000"
    log "   TikTok Automation: http://localhost:5001"
    log "   Analytics: http://localhost:5002"
    log "   n8n: http://localhost:5678"
fi

success "🎉 VitalFlow Automation successfully deployed to $ENVIRONMENT!"

# Post-deployment notifications
if [[ "$ENVIRONMENT" == "production" ]]; then
    log "📢 Sending deployment notifications..."
    python3 scripts/notify_deployment.py --environment "$ENVIRONMENT" --status "success"
fi

log "🚀 Deployment completed successfully!"

