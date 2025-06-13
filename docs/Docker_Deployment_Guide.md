# VitalFlow Docker Deployment Guide

## Overview

This comprehensive guide provides detailed instructions for deploying the VitalFlow TikTok Shop automation system using Docker Compose. The containerized deployment includes all necessary services: n8n workflow automation, PostgreSQL database, Redis cache, and the complete VitalFlow application stack.

## Architecture

The VitalFlow Docker deployment consists of the following services:

### Core Services
- **VitalFlow API**: Main application API server (Port 5000)
- **VitalFlow Automation**: TikTok posting automation service (Port 5001)  
- **VitalFlow Analytics**: Analytics and monitoring dashboard (Port 5002)
- **n8n**: Workflow automation platform (Port 5678)
- **PostgreSQL**: Primary database server (Port 5432)
- **Redis**: Cache and message broker (Port 6379)
- **Nginx**: Reverse proxy and load balancer (Port 80)

### Background Services
- **Celery Worker**: Background task processing
- **Celery Scheduler**: Scheduled task management
- **Celery Flower**: Task monitoring dashboard (Port 5555)

### Optional Services
- **Prometheus**: Metrics collection (Port 9090)
- **Grafana**: Monitoring dashboards (Port 3000)

## Prerequisites

Before deploying VitalFlow, ensure your system meets the following requirements:

### System Requirements
- **Operating System**: Linux (Ubuntu 20.04+ recommended), macOS, or Windows with WSL2
- **RAM**: Minimum 8GB, recommended 16GB or more
- **Storage**: Minimum 50GB free space, recommended 100GB or more
- **CPU**: Minimum 4 cores, recommended 8 cores or more
- **Network**: Stable internet connection for API integrations

### Software Requirements
- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 2.0 or later
- **Git**: For repository management
- **curl**: For health checks and testing

### API Keys Required
- **TikTok Developer Account**: For TikTok Shop integration
- **Supliful API Key**: For product management
- **OpenAI API Key**: For AI content generation

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/willbullen/VITAFLOW.git
cd VITAFLOW
```

### Step 2: Environment Configuration

Copy the environment template and configure your settings:

```bash
cp .env.example .env
```

Edit the `.env` file with your specific configuration:

```bash
nano .env
```

#### Critical Configuration Items

**Database Configuration**
```env
POSTGRES_PASSWORD=your_secure_database_password
REDIS_PASSWORD=your_secure_redis_password
```

**Application Security**
```env
SECRET_KEY=your_super_secret_application_key
JWT_SECRET_KEY=your_jwt_signing_key
```

**n8n Authentication**
```env
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_n8n_password
```

**API Integrations**
```env
TIKTOK_CLIENT_KEY=your_tiktok_client_key
TIKTOK_CLIENT_SECRET=your_tiktok_client_secret
SUPLIFUL_API_KEY=your_supliful_api_key
OPENAI_API_KEY=your_openai_api_key
```

### Step 3: Start the System

Use the provided startup script for automated deployment:

```bash
./scripts/startup.sh
```

The startup script will:
1. Validate your environment configuration
2. Pull and build all Docker images
3. Start all services in the correct order
4. Wait for services to become ready
5. Run database migrations
6. Create initial system data
7. Display service status and access URLs

### Step 4: Verify Deployment

After startup completes, verify all services are running:

```bash
./scripts/startup.sh status
```

Access the services:
- **VitalFlow API**: http://localhost:5000
- **VitalFlow Analytics**: http://localhost:5002/dashboard
- **n8n Workflows**: http://localhost:5678
- **Nginx Proxy**: http://localhost:80

## Service Configuration

### n8n Workflow Setup

1. Access n8n at http://localhost:5678
2. Login with credentials from your `.env` file
3. Import the VitalFlow master workflow:
   - Go to Workflows → Import from File
   - Select `docker/n8n/workflows/vitalflow-master-automation.json`
4. Configure webhook URLs and API connections
5. Activate the workflow

### Database Management

The PostgreSQL database is automatically configured with multiple databases:
- `vitalflow`: Main application database
- `n8n`: n8n workflow data
- `analytics`: Analytics and reporting data
- `automation`: Automation task data

#### Database Access

Connect to the database:
```bash
docker exec -it vitalflow_postgres psql -U vitalflow -d vitalflow
```

#### Database Backup

Create a backup:
```bash
docker exec vitalflow_postgres pg_dump -U vitalflow vitalflow > backup.sql
```

Restore from backup:
```bash
docker exec -i vitalflow_postgres psql -U vitalflow -d vitalflow < backup.sql
```

### Redis Configuration

Redis is configured for multiple use cases:
- **Database 0**: General caching
- **Database 1**: Celery message broker
- **Database 2**: Celery result backend

#### Redis Access

Connect to Redis:
```bash
docker exec -it vitalflow_redis redis-cli
```

Monitor Redis activity:
```bash
docker exec vitalflow_redis redis-cli monitor
```

## Monitoring and Maintenance

### Health Checks

Run comprehensive health checks:
```bash
./scripts/startup.sh health
```

### Log Management

View real-time logs:
```bash
docker-compose logs -f
```

View logs for specific service:
```bash
docker-compose logs -f vitalflow-api
```

### Performance Monitoring

If Prometheus and Grafana are enabled:
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000

Default Grafana credentials:
- Username: admin
- Password: (configured in .env file)

### Backup Strategy

The system includes automated backup capabilities:

#### Automated Backups
- Database backups: Daily at 2:00 AM
- Content backups: Daily retention
- Configuration backups: Version controlled

#### Manual Backup
```bash
./scripts/shutdown.sh backup
```

### Scaling Configuration

#### Horizontal Scaling

Scale specific services:
```bash
docker-compose up -d --scale vitalflow-worker=3
docker-compose up -d --scale vitalflow-api=2
```

#### Resource Limits

Configure resource limits in `docker-compose.yml`:
```yaml
services:
  vitalflow-api:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
```

## Troubleshooting

### Common Issues

#### Service Won't Start
1. Check Docker daemon is running
2. Verify port availability
3. Check environment configuration
4. Review service logs

#### Database Connection Issues
1. Verify PostgreSQL container is running
2. Check database credentials
3. Ensure database initialization completed
4. Test connection manually

#### n8n Workflow Issues
1. Verify n8n service is accessible
2. Check webhook URLs are correct
3. Validate API credentials
4. Review workflow execution logs

#### Performance Issues
1. Monitor resource usage
2. Check database query performance
3. Review Redis memory usage
4. Analyze application logs

### Diagnostic Commands

Check container status:
```bash
docker ps
docker-compose ps
```

View resource usage:
```bash
docker stats
```

Inspect container configuration:
```bash
docker inspect vitalflow_api
```

Check network connectivity:
```bash
docker network ls
docker network inspect vitalflow_network
```

### Recovery Procedures

#### Service Recovery
```bash
# Restart specific service
docker-compose restart vitalflow-api

# Rebuild and restart
docker-compose up -d --build vitalflow-api
```

#### Database Recovery
```bash
# Stop services
docker-compose stop

# Restore database from backup
docker-compose up -d postgres
docker exec -i vitalflow_postgres psql -U vitalflow -d vitalflow < backup.sql

# Restart all services
docker-compose up -d
```

#### Complete System Recovery
```bash
# Stop and remove all containers
docker-compose down

# Remove volumes (if necessary)
docker-compose down -v

# Restart from clean state
./scripts/startup.sh
```

## Security Considerations

### Network Security

The Docker deployment includes several security measures:

#### Network Isolation
- Services communicate through isolated Docker networks
- External access limited to necessary ports
- Internal service communication encrypted

#### Access Control
- n8n protected with basic authentication
- Database access restricted to application services
- Redis password protected

#### SSL/TLS Configuration

For production deployment, enable SSL:

1. Obtain SSL certificates
2. Update nginx configuration
3. Set SSL environment variables:
```env
SSL_ENABLED=true
SSL_CERT_PATH=/etc/nginx/ssl/cert.pem
SSL_KEY_PATH=/etc/nginx/ssl/key.pem
```

### Data Protection

#### Encryption at Rest
- Database encryption available through PostgreSQL configuration
- File system encryption recommended for production

#### Encryption in Transit
- All API communications use HTTPS in production
- Internal service communication secured

#### Backup Security
- Backups encrypted before storage
- Access controls on backup locations
- Regular backup integrity verification

### Compliance

The system supports various compliance requirements:

#### GDPR Compliance
- Data anonymization capabilities
- User data deletion procedures
- Audit logging enabled

#### SOC 2 Compliance
- Access logging and monitoring
- Change management procedures
- Security incident response

## Production Deployment

### Environment Preparation

For production deployment, additional considerations apply:

#### Infrastructure Requirements
- Load balancer for high availability
- Separate database server for performance
- Content delivery network for static assets
- Monitoring and alerting systems

#### Configuration Changes

Production environment variables:
```env
FLASK_ENV=production
FLASK_DEBUG=false
SSL_ENABLED=true
BACKUP_ENABLED=true
MONITORING_ENABLED=true
```

#### Database Optimization

PostgreSQL production configuration:
```sql
-- Increase connection limits
ALTER SYSTEM SET max_connections = 200;

-- Optimize memory settings
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';

-- Enable query optimization
ALTER SYSTEM SET random_page_cost = 1.1;
```

### Deployment Automation

#### CI/CD Pipeline

GitHub Actions workflow for automated deployment:
```yaml
name: Deploy to Production
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to server
        run: |
          ssh user@server 'cd /opt/vitalflow && git pull && ./scripts/startup.sh'
```

#### Blue-Green Deployment

For zero-downtime deployments:
1. Deploy to staging environment
2. Run automated tests
3. Switch traffic to new deployment
4. Monitor for issues
5. Rollback if necessary

### Monitoring and Alerting

#### Metrics Collection

Key metrics to monitor:
- API response times
- Database query performance
- Content generation success rate
- TikTok posting success rate
- System resource utilization

#### Alert Configuration

Critical alerts:
- Service downtime
- Database connection failures
- High error rates
- Resource exhaustion
- Security incidents

#### Dashboard Setup

Grafana dashboard panels:
- System overview
- Application performance
- Business metrics
- Error tracking
- User activity

## Maintenance Procedures

### Regular Maintenance

#### Daily Tasks
- Review system logs
- Check service health
- Monitor resource usage
- Verify backup completion

#### Weekly Tasks
- Update system packages
- Review security logs
- Analyze performance metrics
- Test backup restoration

#### Monthly Tasks
- Security vulnerability scan
- Performance optimization review
- Capacity planning assessment
- Documentation updates

### Update Procedures

#### Application Updates
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart services
docker-compose up -d --build

# Run database migrations
docker exec vitalflow_api flask db upgrade
```

#### System Updates
```bash
# Update Docker
sudo apt update && sudo apt upgrade docker-ce

# Update Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

### Disaster Recovery

#### Recovery Planning

Recovery time objectives:
- Critical services: 15 minutes
- Full system: 1 hour
- Data recovery: 4 hours

#### Backup Strategy

Multi-tier backup approach:
- Real-time replication for critical data
- Daily incremental backups
- Weekly full system backups
- Monthly off-site backup verification

#### Recovery Procedures

1. **Service Recovery**
   - Restart failed services
   - Verify data integrity
   - Resume operations

2. **Data Recovery**
   - Restore from latest backup
   - Replay transaction logs
   - Validate data consistency

3. **Full System Recovery**
   - Rebuild infrastructure
   - Restore all data
   - Reconfigure services
   - Resume full operations

## Advanced Configuration

### Custom Service Configuration

#### Environment-Specific Settings

Development environment:
```env
FLASK_ENV=development
FLASK_DEBUG=true
LOG_LEVEL=DEBUG
CACHE_TYPE=simple
```

Staging environment:
```env
FLASK_ENV=staging
FLASK_DEBUG=false
LOG_LEVEL=INFO
CACHE_TYPE=redis
```

Production environment:
```env
FLASK_ENV=production
FLASK_DEBUG=false
LOG_LEVEL=WARNING
CACHE_TYPE=redis
```

#### Service Customization

Custom Docker Compose overrides:
```yaml
# docker-compose.override.yml
version: '3.8'
services:
  vitalflow-api:
    environment:
      - CUSTOM_SETTING=value
    volumes:
      - ./custom-config:/app/config
```

### Integration Configuration

#### External Service Integration

Configure additional services:
```env
# CRM Integration
HUBSPOT_API_KEY=your_hubspot_key
SALESFORCE_CLIENT_ID=your_salesforce_id

# Analytics Integration
GOOGLE_ANALYTICS_ID=your_ga_id
FACEBOOK_PIXEL_ID=your_pixel_id

# Communication Integration
SLACK_WEBHOOK_URL=your_slack_webhook
TWILIO_ACCOUNT_SID=your_twilio_sid
```

#### Webhook Configuration

Configure webhooks for external integrations:
```bash
# Register webhook endpoints
curl -X POST http://localhost:5000/api/webhooks/register \
  -H "Content-Type: application/json" \
  -d '{"url": "https://external-service.com/webhook", "events": ["post_created", "analytics_updated"]}'
```

### Performance Optimization

#### Database Optimization

PostgreSQL performance tuning:
```sql
-- Connection pooling
ALTER SYSTEM SET max_connections = 100;

-- Memory optimization
ALTER SYSTEM SET shared_buffers = '512MB';
ALTER SYSTEM SET work_mem = '4MB';

-- Query optimization
ALTER SYSTEM SET effective_cache_size = '2GB';
ALTER SYSTEM SET random_page_cost = 1.1;

-- Logging optimization
ALTER SYSTEM SET log_min_duration_statement = 1000;
```

#### Redis Optimization

Redis performance configuration:
```conf
# Memory optimization
maxmemory 1gb
maxmemory-policy allkeys-lru

# Persistence optimization
save 900 1
save 300 10
save 60 10000

# Network optimization
tcp-keepalive 300
timeout 0
```

#### Application Optimization

Flask application optimization:
```python
# Enable response compression
COMPRESS_MIMETYPES = [
    'text/html', 'text/css', 'text/xml',
    'application/json', 'application/javascript'
]

# Configure caching
CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_URL': 'redis://redis:6379/0',
    'CACHE_DEFAULT_TIMEOUT': 300
}

# Database connection pooling
SQLALCHEMY_ENGINE_OPTIONS = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True
}
```

## Conclusion

This comprehensive Docker deployment guide provides everything needed to successfully deploy and maintain the VitalFlow TikTok Shop automation system. The containerized architecture ensures consistent deployment across environments while providing scalability and maintainability for production use.

For additional support and updates, refer to the project repository and documentation at https://github.com/willbullen/VITAFLOW.

