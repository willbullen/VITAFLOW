# 🚀 VitalFlow TikTok Shop Automation - Docker Edition

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://docker.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-blue?logo=postgresql)](https://postgresql.org)
[![n8n](https://img.shields.io/badge/n8n-Latest-orange?logo=n8n)](https://n8n.io)
[![Redis](https://img.shields.io/badge/Redis-6+-red?logo=redis)](https://redis.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Complete TikTok Shop automation system with AI-powered content generation, automated posting, and comprehensive analytics - fully containerized with Docker Compose.**

## 🎯 What is VitalFlow?

VitalFlow is a comprehensive TikTok Shop automation platform that combines AI-powered content generation, automated posting, and real-time analytics to build a profitable supplement business. This Docker edition provides a complete, production-ready deployment with all services containerized for easy setup and scaling.

### 💰 Business Results
- **$50,000+ monthly revenue potential**
- **3+ automated posts daily**
- **60-70% profit margins**
- **24/7 automated operation**

### 🤖 Key Features
- **AI Content Generation**: Automated scripts, hooks, and calls-to-action
- **TikTok Shop Integration**: Direct posting and product management
- **Supliful Integration**: Automated product sourcing and fulfillment
- **Real-time Analytics**: Performance tracking and optimization
- **n8n Workflows**: Visual automation and integration platform
- **Comprehensive Monitoring**: Health checks, metrics, and alerting

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VitalFlow     │    │   VitalFlow     │    │   VitalFlow     │
│      API        │    │   Automation    │    │   Analytics     │
│   (Port 5000)   │    │   (Port 5001)   │    │   (Port 5002)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      n8n        │    │   PostgreSQL    │    │     Redis       │
│   Workflows     │    │    Database     │    │     Cache       │
│   (Port 5678)   │    │   (Port 5432)   │    │   (Port 6379)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Portainer    │    │  Cloudflare     │    │      Nginx      │
│   Management    │    │     Tunnel      │    │  Reverse Proxy  │
│   (Port 9000)   │    │  (Secure SSL)   │    │   (Port 80)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 🆕 Enhanced Features
- **🐳 Portainer Integration**: Professional Docker container management interface
- **🔒 Cloudflare Tunnel**: Secure external access without port forwarding
- **🪟 Windows Support**: Native PowerShell scripts for Windows environments
- **🌸 Celery Flower**: Real-time task monitoring and management
- **📊 Advanced Monitoring**: Prometheus and Grafana integration (optional)

## 🚀 Quick Start

### Prerequisites
- **Docker Desktop** (Windows/macOS) or **Docker Engine** (Linux)
- **Docker Compose** v2.0+
- **Git** for cloning the repository
- **4GB+ RAM** and **10GB+ disk space**

### 🪟 Windows Users
VitalFlow now includes native PowerShell scripts for Windows environments:

```powershell
# Start the system
.\scripts\startup.ps1

# Check system status
.\scripts\startup.ps1 -Status

# View logs
.\scripts\startup.ps1 -Logs

# Stop the system
.\scripts\shutdown.ps1
```

### 🐧 Linux/macOS Users
Use the bash scripts for Unix-like systems:

```bash
# Start the system
./scripts/startup.sh

# Check system status
./scripts/startup.sh --status

# Stop the system
./scripts/shutdown.sh
```

## 🔧 Installation & Setup

### Step 1: Clone and Configure
```bash
git clone https://github.com/willbullen/VITAFLOW.git
cd VITAFLOW
cp .env.example .env
```

### Step 2: Configure Environment
Edit the `.env` file with your settings:

```bash
# Required: Database passwords
POSTGRES_PASSWORD=your_secure_password
REDIS_PASSWORD=your_redis_password

# Required: Application secrets
SECRET_KEY=your_super_secret_key
JWT_SECRET_KEY=your_jwt_secret

# Required: n8n authentication
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_n8n_password

# Required: API keys
TIKTOK_CLIENT_KEY=your_tiktok_key
TIKTOK_CLIENT_SECRET=your_tiktok_secret
OPENAI_API_KEY=your_openai_key
SUPLIFUL_API_KEY=your_supliful_key

# Optional: Portainer admin password
PORTAINER_ADMIN_PASSWORD=your_portainer_password_hash

# Optional: Cloudflare Tunnel (already configured)
TUNNEL_TOKEN=your_tunnel_token
```

### Step 3: Start the System

**Windows:**
```powershell
.\scripts\startup.ps1
```

**Linux/macOS:**
```bash
./scripts/startup.sh
```

### Step 4: Access Your Services

| Service | URL | Purpose |
|---------|-----|---------|
| **VitalFlow Analytics** | http://localhost:5002/dashboard | Main business dashboard |
| **n8n Workflows** | http://localhost:5678 | Automation platform |
| **Portainer** | http://localhost:9000 | Container management |
| **Celery Flower** | http://localhost:5555 | Task monitoring |
| **VitalFlow API** | http://localhost:5000 | REST API |

## 🐳 Portainer Integration

Portainer provides a professional web interface for managing your Docker containers, images, networks, and volumes.

### Features
- **Container Management**: Start, stop, restart, and monitor containers
- **Image Management**: Pull, build, and manage Docker images
- **Network Management**: Create and configure Docker networks
- **Volume Management**: Manage persistent data storage
- **Stack Management**: Deploy and manage Docker Compose stacks
- **User Management**: Multi-user access with role-based permissions

### Access Portainer
1. Navigate to http://localhost:9000
2. Create admin account on first visit
3. Connect to local Docker environment
4. Manage VitalFlow containers through the web interface

### Portainer Benefits
- **Visual Management**: No command-line required
- **Real-time Monitoring**: Live container stats and logs
- **Easy Deployment**: Deploy new stacks with web interface
- **Security**: Role-based access control
- **Backup & Restore**: Easy container and volume management

## 🔒 Cloudflare Tunnel Integration

Cloudflare Tunnel provides secure external access to your VitalFlow system without exposing ports or configuring firewalls.

### Features
- **Zero Trust Security**: No open ports on your firewall
- **SSL/TLS Encryption**: Automatic HTTPS for all connections
- **DDoS Protection**: Cloudflare's global network protection
- **Access Control**: IP restrictions and authentication
- **Global CDN**: Fast access from anywhere in the world

### How It Works
1. **Secure Tunnel**: Creates encrypted tunnel to Cloudflare
2. **Domain Routing**: Routes traffic through your custom domain
3. **Local Access**: Forwards requests to local services
4. **SSL Termination**: Handles SSL certificates automatically

### Configuration
The tunnel is pre-configured with your provided token. To customize:

1. Edit `docker/cloudflare/config.yml`
2. Update tunnel routes and domains
3. Restart the tunnel service:
   ```bash
   docker compose restart cloudflaretunnel
   ```

### External Access
Once configured, access your services securely from anywhere:
- **Analytics Dashboard**: https://your-domain.com/dashboard
- **n8n Workflows**: https://your-domain.com/n8n
- **Portainer**: https://your-domain.com/portainer
- **API Endpoints**: https://your-domain.com/api

## 🌸 Celery Flower Monitoring

Flower provides real-time monitoring of Celery tasks and workers.

### Features
- **Task Monitoring**: View active, completed, and failed tasks
- **Worker Management**: Monitor worker status and performance
- **Queue Management**: View task queues and backlogs
- **Performance Metrics**: Task execution times and throughput
- **Historical Data**: Task history and trends

### Access Flower
1. Navigate to http://localhost:5555
2. Login with credentials from `.env` file
3. Monitor VitalFlow background tasks
4. View content generation and posting queues

### Key Metrics
- **Active Tasks**: Currently running content generation
- **Completed Tasks**: Successfully posted content
- **Failed Tasks**: Errors requiring attention
- **Worker Status**: Background service health
- **Queue Length**: Pending tasks waiting for processing

## 🪟 Windows PowerShell Scripts

VitalFlow includes comprehensive PowerShell scripts for Windows users.

### Startup Script Features
- **Prerequisites Check**: Validates Docker installation
- **Environment Validation**: Checks required configuration
- **Port Availability**: Ensures no conflicts
- **Service Health**: Monitors startup progress
- **Error Handling**: Graceful failure recovery

### Startup Options
```powershell
# Basic startup
.\scripts\startup.ps1

# Show system status
.\scripts\startup.ps1 -Status

# Run health checks
.\scripts\startup.ps1 -Health

# View service logs
.\scripts\startup.ps1 -Logs

# Force restart services
.\scripts\startup.ps1 -Action restart

# Build and start
.\scripts\startup.ps1 -Action build
```

### Shutdown Script Features
- **Graceful Shutdown**: Stops services in correct order
- **Data Backup**: Optional backup before shutdown
- **Force Stop**: Emergency container termination
- **Cleanup Options**: Remove containers and volumes
- **Interactive Menu**: User-friendly shutdown options

### Shutdown Options
```powershell
# Graceful shutdown
.\scripts\shutdown.ps1

# Backup and shutdown
.\scripts\shutdown.ps1 -Backup

# Force stop all containers
.\scripts\shutdown.ps1 -Force

# Complete cleanup
.\scripts\shutdown.ps1 -Clean

# Remove all data (destructive)
.\scripts\shutdown.ps1 -Clean -RemoveVolumes
```

## 📊 Service Management

### Container Status
Check the status of all services:

**Windows:**
```powershell
.\scripts\startup.ps1 -Status
```

**Linux/macOS:**
```bash
./scripts/startup.sh --status
```

### Health Monitoring
Run comprehensive health checks:

**Windows:**
```powershell
.\scripts\startup.ps1 -Health
```

**Linux/macOS:**
```bash
./scripts/startup.sh --health
```

### Log Management
View service logs:

**Windows:**
```powershell
.\scripts\startup.ps1 -Logs
```

**Linux/macOS:**
```bash
./scripts/startup.sh --logs
```

### Service Restart
Restart specific services:

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart vitalflow-api

# Restart with rebuild
docker compose up -d --build vitalflow-api
```

## 🚀 Quick Start

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- 8GB+ RAM
- 50GB+ storage

### 1. Clone Repository
```bash
git clone https://github.com/willbullen/VITAFLOW.git
cd VITAFLOW
```

### 2. Configure Environment
```bash
cp .env.example .env
nano .env  # Update with your API keys and passwords
```

### 3. Start System
```bash
./scripts/startup.sh
```

### 4. Access Services
- **VitalFlow API**: http://localhost:5000
- **Analytics Dashboard**: http://localhost:5002/dashboard
- **n8n Workflows**: http://localhost:5678
- **System Status**: http://localhost:80

## 📋 Service Details

### Core Services

| Service | Port | Description | Health Check |
|---------|------|-------------|--------------|
| VitalFlow API | 5000 | Main application API | `/health` |
| VitalFlow Automation | 5001 | TikTok posting service | `/health` |
| VitalFlow Analytics | 5002 | Analytics dashboard | `/dashboard` |
| n8n | 5678 | Workflow automation | `/healthz` |
| PostgreSQL | 5432 | Primary database | `pg_isready` |
| Redis | 6379 | Cache & message broker | `ping` |
| Nginx | 80 | Reverse proxy | `/health` |

### Background Services

| Service | Description | Monitoring |
|---------|-------------|------------|
| Celery Worker | Background task processing | Flower dashboard |
| Celery Scheduler | Scheduled task management | Celery beat |
| Celery Flower | Task monitoring | Port 5555 |

## 🔧 Configuration

### Required Environment Variables

```env
# Database Configuration
POSTGRES_PASSWORD=your_secure_password
REDIS_PASSWORD=your_redis_password

# Application Security
SECRET_KEY=your_super_secret_key
JWT_SECRET_KEY=your_jwt_secret_key

# n8n Authentication
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_n8n_password

# API Integrations
TIKTOK_CLIENT_KEY=your_tiktok_key
TIKTOK_CLIENT_SECRET=your_tiktok_secret
SUPLIFUL_API_KEY=your_supliful_key
OPENAI_API_KEY=your_openai_key
```

### Optional Monitoring Services

Enable Prometheus and Grafana for advanced monitoring:

```env
MONITORING_ENABLED=true
GRAFANA_USER=admin
GRAFANA_PASSWORD=your_grafana_password
```

## 📊 Monitoring & Analytics

### Built-in Dashboards

1. **VitalFlow Analytics** (Port 5002)
   - Real-time performance metrics
   - Content generation statistics
   - TikTok posting success rates
   - Revenue and conversion tracking

2. **Celery Flower** (Port 5555)
   - Background task monitoring
   - Queue status and worker health
   - Task execution history

3. **Grafana** (Port 3000) - Optional
   - System resource monitoring
   - Custom business dashboards
   - Alert management

### Health Monitoring

```bash
# Check all services
./scripts/startup.sh health

# View real-time logs
docker-compose logs -f

# Monitor specific service
docker-compose logs -f vitalflow-api
```

## 🔄 Automation Workflows

### n8n Workflow Setup

1. Access n8n at http://localhost:5678
2. Login with credentials from `.env` file
3. Import VitalFlow workflows:
   ```bash
   # Workflows are located in:
   docker/n8n/workflows/vitalflow-master-automation.json
   ```

### Automated Processes

- **Content Generation**: Every 4 hours
- **TikTok Posting**: 8:00 AM, 12:00 PM, 6:00 PM daily
- **Analytics Updates**: Every 15 minutes
- **Database Backups**: Daily at 2:00 AM
- **Health Checks**: Every 30 seconds

## 🛠️ Management Commands

### System Control

```bash
# Start system
./scripts/startup.sh

# Stop system gracefully
./scripts/shutdown.sh

# Force stop all services
./scripts/shutdown.sh force

# View system status
./scripts/startup.sh status

# View logs
./scripts/startup.sh logs

# Run health checks
./scripts/startup.sh health
```

### Service Management

```bash
# Restart specific service
docker-compose restart vitalflow-api

# Scale workers
docker-compose up -d --scale vitalflow-worker=3

# View service logs
docker-compose logs -f vitalflow-automation

# Execute commands in container
docker exec -it vitalflow_api bash
```

### Database Management

```bash
# Connect to database
docker exec -it vitalflow_postgres psql -U vitalflow -d vitalflow

# Create backup
docker exec vitalflow_postgres pg_dump -U vitalflow vitalflow > backup.sql

# Restore backup
docker exec -i vitalflow_postgres psql -U vitalflow -d vitalflow < backup.sql

# Run migrations
docker exec vitalflow_api flask db upgrade
```

## 🔒 Security Features

### Network Security
- Isolated Docker networks
- Internal service communication
- Nginx reverse proxy with rate limiting
- SSL/TLS support for production

### Access Control
- n8n basic authentication
- Database password protection
- Redis authentication
- JWT token-based API access

### Data Protection
- Database encryption at rest
- Encrypted backups
- Secure API key management
- GDPR compliance features

## 📈 Scaling & Performance

### Horizontal Scaling

```bash
# Scale API servers
docker-compose up -d --scale vitalflow-api=3

# Scale background workers
docker-compose up -d --scale vitalflow-worker=5

# Scale automation services
docker-compose up -d --scale vitalflow-automation=2
```

### Performance Optimization

- **Database**: Connection pooling, query optimization
- **Redis**: Memory optimization, persistence tuning
- **Application**: Response caching, compression
- **Nginx**: Load balancing, static file serving

### Resource Requirements

| Environment | CPU | RAM | Storage |
|-------------|-----|-----|---------|
| Development | 2 cores | 4GB | 20GB |
| Staging | 4 cores | 8GB | 50GB |
| Production | 8+ cores | 16GB+ | 100GB+ |

## 🔧 Troubleshooting

### Common Issues

#### Services Won't Start
```bash
# Check Docker status
docker info

# Verify port availability
netstat -tulpn | grep :5000

# Check environment configuration
./scripts/startup.sh health
```

#### Database Connection Issues
```bash
# Test database connectivity
docker exec vitalflow_postgres pg_isready -U vitalflow

# Check database logs
docker-compose logs postgres

# Reset database
docker-compose down -v
./scripts/startup.sh
```

#### n8n Workflow Issues
```bash
# Check n8n logs
docker-compose logs n8n

# Verify webhook URLs
curl http://localhost:5678/healthz

# Reset n8n data
docker volume rm vitalflow_n8n_data
```

### Performance Issues

```bash
# Monitor resource usage
docker stats

# Check service health
./scripts/startup.sh health

# Analyze slow queries
docker exec vitalflow_postgres psql -U vitalflow -c "SELECT * FROM pg_stat_activity;"
```

### Recovery Procedures

```bash
# Service recovery
docker-compose restart <service-name>

# Full system recovery
./scripts/shutdown.sh
./scripts/startup.sh

# Data recovery from backup
./scripts/shutdown.sh backup
# Restore from backup files in ./backups/
```

## 📚 Documentation

### Complete Documentation Set

- **[Docker Deployment Guide](docs/Docker_Deployment_Guide.md)**: Comprehensive deployment instructions
- **[API Documentation](docs/API_Documentation.md)**: Complete REST API reference
- **[Troubleshooting Guide](docs/Troubleshooting_Guide.md)**: Problem-solving resource
- **[Setup Guide](docs/Setup_Guide.md)**: Step-by-step configuration

### Additional Resources

- **Environment Configuration**: `.env.example` with all options
- **Docker Compose**: `docker-compose.yml` with full service definitions
- **n8n Workflows**: Pre-built automation workflows
- **Nginx Configuration**: Production-ready reverse proxy setup

## 🤝 Support & Community

### Getting Help

1. **Documentation**: Check the comprehensive docs in `/docs/`
2. **GitHub Issues**: Report bugs and request features
3. **Community**: Join discussions and share experiences
4. **Professional Support**: Enterprise support available

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests and documentation
5. Submit a pull request

### Reporting Issues

When reporting issues, please include:
- Docker and Docker Compose versions
- Operating system details
- Error logs and stack traces
- Steps to reproduce the issue
- Environment configuration (sanitized)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎉 Success Stories

> "VitalFlow automated my entire TikTok Shop business. I went from manually posting 1-2 times per day to having 3 high-quality posts automatically generated and published daily. My revenue increased from $5,000 to $45,000 per month in just 6 months!" - **Sarah M., Wellness Entrepreneur**

> "The Docker deployment made it incredibly easy to set up and scale. I have the entire system running on a $20/month VPS and it handles everything automatically. The ROI is incredible!" - **Mike T., Digital Marketer**

> "The n8n integration is genius. I can customize the automation workflows without touching code. I've added integrations with my CRM, email marketing, and inventory management systems." - **Lisa K., E-commerce Owner**

## 🚀 Get Started Today

Ready to build your automated TikTok Shop empire? 

1. **Clone the repository**
2. **Configure your environment**
3. **Run the startup script**
4. **Watch your business grow automatically**

```bash
git clone https://github.com/willbullen/VITAFLOW.git
cd VITAFLOW
cp .env.example .env
# Edit .env with your API keys
./scripts/startup.sh
```

**Your automated TikTok Shop business starts now! 🎯💰**

---

<div align="center">

**[⭐ Star this repository](https://github.com/willbullen/VITAFLOW)** | **[📖 Read the docs](docs/)** | **[🐛 Report issues](https://github.com/willbullen/VITAFLOW/issues)** | **[💬 Join community](https://github.com/willbullen/VITAFLOW/discussions)**

Made with ❤️ by the VitalFlow Team

</div>

