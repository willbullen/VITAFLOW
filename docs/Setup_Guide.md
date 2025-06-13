# VitalFlow Automation Setup Guide

## Prerequisites

Before setting up VitalFlow Automation, ensure you have the following prerequisites installed and configured on your system.

### System Requirements

**Minimum Requirements:**
- **Operating System**: Ubuntu 20.04+ / macOS 10.15+ / Windows 10+
- **CPU**: 2 cores, 2.4 GHz
- **RAM**: 4 GB
- **Storage**: 20 GB free space
- **Network**: Stable internet connection

**Recommended Requirements:**
- **Operating System**: Ubuntu 22.04 LTS
- **CPU**: 4 cores, 3.0 GHz
- **RAM**: 8 GB
- **Storage**: 50 GB SSD
- **Network**: High-speed internet (100+ Mbps)

### Software Dependencies

**Required Software:**
- **Python**: 3.11 or higher
- **Node.js**: 18.0 or higher
- **Git**: Latest version
- **SQLite**: 3.35 or higher

**Optional but Recommended:**
- **Redis**: For caching and background tasks
- **Docker**: For containerized deployment
- **Nginx**: For production reverse proxy

## Installation Steps

### Step 1: Clone the Repository

```bash
# Clone the VitalFlow Automation repository
git clone https://github.com/yourusername/vitalflow-automation.git
cd vitalflow-automation

# Verify repository structure
ls -la
```

### Step 2: Set Up Python Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On Linux/macOS:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Upgrade pip
pip install --upgrade pip

# Install Python dependencies
pip install -r requirements.txt
```

### Step 3: Install Node.js Dependencies

```bash
# Install Node.js dependencies globally
npm install -g n8n

# Install project dependencies
npm install

# Verify n8n installation
n8n --version
```

### Step 4: Configure Environment Variables

```bash
# Copy environment template
cp config/.env.example .env

# Edit configuration file
nano .env
```

**Essential Configuration Variables:**

```env
# Basic Configuration
ENVIRONMENT=production
DEBUG=false
SECRET_KEY=your_super_secret_key_here

# TikTok API (Required)
TIKTOK_CLIENT_KEY=your_tiktok_client_key
TIKTOK_CLIENT_SECRET=your_tiktok_client_secret
TIKTOK_ACCESS_TOKEN=your_tiktok_access_token

# Supliful Integration (Required)
SUPLIFUL_API_KEY=your_supliful_api_key
SUPLIFUL_STORE_ID=your_supliful_store_id

# Content Generation (Optional but Recommended)
OPENAI_API_KEY=your_openai_api_key

# Posting Schedule
POSTING_SCHEDULE=08:00,12:00,18:00
MAX_POSTS_PER_DAY=3
```

### Step 5: Initialize Database

```bash
# Create data directory
mkdir -p data logs backups

# Initialize main database
python scripts/init_database.py

# Initialize analytics database
python scripts/init_analytics_db.py

# Verify database creation
ls -la data/
```

### Step 6: Set Up n8n Workflows

```bash
# Start n8n in background
n8n start --tunnel &

# Wait for n8n to start
sleep 10

# Import VitalFlow workflows
curl -X POST http://localhost:5678/rest/workflows/import \
  -H "Content-Type: application/json" \
  -d @config/n8n_workflow_vitalflow.json

# Verify workflow import
curl http://localhost:5678/rest/workflows
```

## Account Setup

### TikTok for Business Account

1. **Create TikTok for Business Account:**
   - Visit https://ads.tiktok.com/
   - Sign up with your business email
   - Complete business verification

2. **Create TikTok App:**
   - Go to https://developers.tiktok.com/
   - Create new app
   - Configure app permissions:
     - `user.info.basic`
     - `video.upload`
     - `video.publish`

3. **Get API Credentials:**
   ```bash
   # Test TikTok API connection
   curl -X GET "https://open-api.tiktok.com/platform/oauth/connect/" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
   ```

### Supliful Account Setup

1. **Create Supliful Account:**
   - Visit https://supliful.com/
   - Sign up for dropshipping account
   - Complete store setup

2. **Get API Credentials:**
   - Navigate to API settings in dashboard
   - Generate API key and store ID
   - Configure webhook endpoints

3. **Product Catalog Setup:**
   ```bash
   # Sync product catalog
   python scripts/sync_supliful_products.py
   
   # Verify product import
   python scripts/list_products.py
   ```

### OpenAI Account (Optional)

1. **Create OpenAI Account:**
   - Visit https://platform.openai.com/
   - Sign up and verify account
   - Add payment method

2. **Generate API Key:**
   - Go to API keys section
   - Create new secret key
   - Set usage limits

3. **Test API Connection:**
   ```bash
   # Test OpenAI API
   curl https://api.openai.com/v1/models \
     -H "Authorization: Bearer YOUR_OPENAI_API_KEY"
   ```

## Service Configuration

### API Service Configuration

```bash
# Configure API service
nano src/api/main.py

# Key configuration options:
# - Host: 0.0.0.0 (for external access)
# - Port: 5000
# - Debug: False (production)
# - CORS: Enabled for frontend access
```

### TikTok Automation Configuration

```bash
# Configure automation service
nano src/automation/tiktok_automation.py

# Key configuration options:
# - Posting schedule
# - Content queue management
# - Error handling and retries
# - Performance monitoring
```

### Analytics Configuration

```bash
# Configure analytics service
nano src/analytics/vitalflow_analytics.py

# Key configuration options:
# - Data collection intervals
# - Metric calculations
# - Dashboard refresh rates
# - Export capabilities
```

## Testing the Setup

### Basic Functionality Test

```bash
# Run comprehensive health check
python scripts/health_check.py --environment production --detailed

# Test content generation
curl -X POST http://localhost:5000/api/automation/generate-content \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"product_category": "energy", "content_type": "transformation"}'

# Test TikTok posting (dry run)
python src/automation/tiktok_automation.py --dry-run

# Test analytics dashboard
curl http://localhost:5002/api/analytics/dashboard
```

### Integration Tests

```bash
# Run full integration test suite
python -m pytest tests/integration/ -v

# Test external API connections
python scripts/test_external_apis.py

# Verify database operations
python scripts/test_database_operations.py
```

## Deployment

### Development Deployment

```bash
# Start all services for development
./scripts/start_dev.sh

# Services will be available at:
# - API: http://localhost:5000
# - TikTok Automation: http://localhost:5001
# - Analytics: http://localhost:5002
# - n8n: http://localhost:5678
```

### Production Deployment

```bash
# Deploy to production
./scripts/deploy.sh production

# Verify deployment
python scripts/health_check.py --environment production

# Monitor logs
tail -f logs/api.log
tail -f logs/tiktok.log
tail -f logs/analytics.log
```

### Docker Deployment (Alternative)

```bash
# Build Docker image
docker build -t vitalflow-automation .

# Run container
docker run -d \
  --name vitalflow \
  -p 5000:5000 \
  -p 5001:5001 \
  -p 5002:5002 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/logs:/app/logs \
  --env-file .env \
  vitalflow-automation

# Check container status
docker ps
docker logs vitalflow
```

## Security Configuration

### SSL/TLS Setup

```bash
# Generate SSL certificates (Let's Encrypt)
sudo certbot certonly --standalone -d api.yourdomain.com
sudo certbot certonly --standalone -d analytics.yourdomain.com

# Configure Nginx reverse proxy
sudo nano /etc/nginx/sites-available/vitalflow

# Nginx configuration example:
server {
    listen 443 ssl;
    server_name api.yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Firewall Configuration

```bash
# Configure UFW firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 5000  # API (if not using reverse proxy)
sudo ufw allow 5002  # Analytics (if not using reverse proxy)

# Check firewall status
sudo ufw status
```

### API Security

```bash
# Generate secure JWT secret
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Configure rate limiting
nano .env
# Add:
API_RATE_LIMIT_ENABLED=true
API_RATE_LIMIT_REQUESTS=100
API_RATE_LIMIT_WINDOW=60

# Enable API authentication
AUTH_REQUIRED=true
JWT_SECRET_KEY=your_generated_secret_key
```

## Monitoring Setup

### System Monitoring

```bash
# Install monitoring tools
pip install psutil prometheus-client

# Configure system monitoring
python scripts/setup_monitoring.py

# Set up automated health checks
crontab -e
# Add:
*/5 * * * * /path/to/vitalflow/scripts/health_check.py --quiet
0 2 * * * /path/to/vitalflow/scripts/daily_backup.sh
```

### Log Management

```bash
# Configure log rotation
sudo nano /etc/logrotate.d/vitalflow

# Log rotation configuration:
/path/to/vitalflow/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 ubuntu ubuntu
}

# Test log rotation
sudo logrotate -d /etc/logrotate.d/vitalflow
```

### Performance Monitoring

```bash
# Enable performance monitoring
echo "PERFORMANCE_MONITORING=true" >> .env

# Set up performance alerts
python scripts/setup_performance_alerts.py

# Configure external monitoring (optional)
# Sentry for error tracking
echo "SENTRY_DSN=your_sentry_dsn" >> .env

# Datadog for infrastructure monitoring
echo "DATADOG_API_KEY=your_datadog_key" >> .env
```

## Backup Configuration

### Automated Backups

```bash
# Configure automated backups
python scripts/setup_backups.py

# Set up backup schedule
crontab -e
# Add:
0 2 * * * /path/to/vitalflow/scripts/daily_backup.sh
0 1 * * 0 /path/to/vitalflow/scripts/weekly_backup.sh
0 0 1 * * /path/to/vitalflow/scripts/monthly_backup.sh
```

### Cloud Backup Setup

```bash
# AWS S3 backup configuration
echo "AWS_ACCESS_KEY_ID=your_aws_key" >> .env
echo "AWS_SECRET_ACCESS_KEY=your_aws_secret" >> .env
echo "AWS_S3_BUCKET=your_backup_bucket" >> .env

# Test cloud backup
python scripts/test_cloud_backup.py

# Google Cloud Storage (alternative)
echo "GOOGLE_CLOUD_PROJECT=your_project" >> .env
echo "GOOGLE_CLOUD_BUCKET=your_backup_bucket" >> .env
```

## Troubleshooting Common Issues

### Service Startup Issues

```bash
# Check service status
ps aux | grep -E "(main.py|tiktok_automation|analytics|n8n)"

# Check logs for errors
grep -i "error\|exception" logs/*.log

# Restart services
./scripts/deploy.sh production
```

### Database Connection Issues

```bash
# Check database files
ls -la data/

# Test database connectivity
sqlite3 data/vitalflow.db ".tables"

# Repair database if needed
python scripts/repair_database.py
```

### API Authentication Issues

```bash
# Verify API credentials
python scripts/verify_api_credentials.py

# Regenerate JWT tokens
python scripts/regenerate_jwt_tokens.py

# Test API endpoints
curl -X GET http://localhost:5000/api/system/status \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Optimization and Scaling

### Performance Optimization

```bash
# Optimize database
python scripts/optimize_database.py

# Enable caching
echo "CACHE_TYPE=redis" >> .env
echo "REDIS_URL=redis://localhost:6379/0" >> .env

# Configure worker processes
echo "WORKER_PROCESSES=4" >> .env
echo "WORKER_THREADS=2" >> .env
```

### Scaling Considerations

1. **Horizontal Scaling:**
   - Load balancer configuration
   - Multiple API instances
   - Shared database and cache

2. **Vertical Scaling:**
   - Increase server resources
   - Optimize database queries
   - Enable connection pooling

3. **Content Delivery:**
   - CDN for static assets
   - Image optimization
   - Caching strategies

## Maintenance Schedule

### Daily Tasks (Automated)

- Health checks every 5 minutes
- Log monitoring and alerting
- Backup verification
- Performance metrics collection

### Weekly Tasks

```bash
# Run weekly maintenance
./scripts/weekly_maintenance.sh

# Tasks include:
# - Database optimization
# - Log rotation
# - Security scans
# - Performance analysis
```

### Monthly Tasks

```bash
# Run monthly maintenance
./scripts/monthly_maintenance.sh

# Tasks include:
# - Full system backup
# - Dependency updates
# - Security patches
# - Capacity planning
```

## Support and Resources

### Documentation

- **API Documentation**: `docs/API_Documentation.md`
- **Troubleshooting Guide**: `docs/Troubleshooting_Guide.md`
- **FAQ**: `docs/FAQ.md`

### Community Support

- **GitHub Issues**: https://github.com/yourusername/vitalflow-automation/issues
- **Discord Community**: https://discord.gg/vitalflow
- **Knowledge Base**: https://docs.vitalflow.com

### Professional Support

- **Email**: support@vitalflow.com
- **Phone**: +1-555-VITAL-FLOW
- **Emergency**: emergency@vitalflow.com

### Getting Help

When requesting support, please include:

1. **System Information:**
   ```bash
   python scripts/system_info.py
   ```

2. **Health Check Results:**
   ```bash
   python scripts/health_check.py --detailed
   ```

3. **Support Bundle:**
   ```bash
   python scripts/generate_support_bundle.py
   ```

4. **Error Logs:**
   ```bash
   grep -i "error\|exception" logs/*.log | tail -50
   ```

## Next Steps

After completing the setup:

1. **Content Strategy:**
   - Review content templates in `assets/templates/`
   - Customize content for your brand
   - Set up content approval workflows

2. **Marketing Integration:**
   - Connect social media accounts
   - Set up analytics tracking
   - Configure conversion tracking

3. **Business Optimization:**
   - Monitor performance metrics
   - Optimize posting schedules
   - Scale content production

4. **Advanced Features:**
   - Multi-platform posting
   - Advanced analytics
   - Custom integrations

Congratulations! Your VitalFlow Automation system is now ready to generate passive income through automated TikTok Shop management.

