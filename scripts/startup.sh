#!/bin/bash

# VitalFlow Automation System Startup Script
# This script initializes and starts the complete VitalFlow Docker environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env"
DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
BACKUP_DIR="$PROJECT_ROOT/backups"
LOG_DIR="$PROJECT_ROOT/logs"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Function to check if Docker is installed and running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Function to check if Docker Compose is installed
check_docker_compose() {
    print_status "Checking Docker Compose installation..."
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker Compose is available"
}

# Function to create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p "$PROJECT_ROOT/data"
    mkdir -p "$PROJECT_ROOT/logs"
    mkdir -p "$PROJECT_ROOT/generated_content/images"
    mkdir -p "$PROJECT_ROOT/generated_content/videos"
    mkdir -p "$PROJECT_ROOT/assets/templates"
    mkdir -p "$PROJECT_ROOT/reports"
    mkdir -p "$PROJECT_ROOT/backups"
    mkdir -p "$PROJECT_ROOT/docker/postgres/backups"
    mkdir -p "$PROJECT_ROOT/docker/nginx/ssl"
    
    print_success "Directories created successfully"
}

# Function to check and create environment file
setup_environment() {
    print_status "Setting up environment configuration..."
    
    if [ ! -f "$ENV_FILE" ]; then
        if [ -f "$PROJECT_ROOT/.env.example" ]; then
            cp "$PROJECT_ROOT/.env.example" "$ENV_FILE"
            print_warning "Environment file created from template. Please update the values in .env file."
            print_warning "Important: Update the following before starting:"
            echo "  - Database passwords"
            echo "  - Redis password"
            echo "  - Secret keys"
            echo "  - API keys (TikTok, Supliful, OpenAI)"
            echo "  - n8n authentication"
            read -p "Press Enter to continue after updating .env file..."
        else
            print_error "No .env.example file found. Cannot create environment configuration."
            exit 1
        fi
    else
        print_success "Environment file exists"
    fi
}

# Function to validate environment variables
validate_environment() {
    print_status "Validating environment configuration..."
    
    source "$ENV_FILE"
    
    # Check critical environment variables
    REQUIRED_VARS=(
        "POSTGRES_PASSWORD"
        "REDIS_PASSWORD"
        "SECRET_KEY"
        "JWT_SECRET_KEY"
        "N8N_BASIC_AUTH_PASSWORD"
    )
    
    MISSING_VARS=()
    
    for var in "${REQUIRED_VARS[@]}"; do
        if [ -z "${!var}" ] || [ "${!var}" = "change_this" ] || [[ "${!var}" == *"your_"* ]]; then
            MISSING_VARS+=("$var")
        fi
    done
    
    if [ ${#MISSING_VARS[@]} -ne 0 ]; then
        print_error "The following environment variables need to be configured:"
        for var in "${MISSING_VARS[@]}"; do
            echo "  - $var"
        done
        print_error "Please update these values in the .env file before continuing."
        exit 1
    fi
    
    print_success "Environment configuration is valid"
}

# Function to pull Docker images
pull_images() {
    print_status "Pulling Docker images..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" pull
    else
        docker compose -f "$DOCKER_COMPOSE_FILE" pull
    fi
    
    print_success "Docker images pulled successfully"
}

# Function to build custom images
build_images() {
    print_status "Building custom Docker images..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" build --no-cache
    else
        docker compose -f "$DOCKER_COMPOSE_FILE" build --no-cache
    fi
    
    print_success "Custom Docker images built successfully"
}

# Function to start the services
start_services() {
    print_status "Starting VitalFlow services..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
    else
        docker compose -f "$DOCKER_COMPOSE_FILE" up -d
    fi
    
    print_success "VitalFlow services started successfully"
}

# Function to wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for PostgreSQL
    print_status "Waiting for PostgreSQL..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker exec vitalflow_postgres pg_isready -U vitalflow -d vitalflow &> /dev/null; then
            break
        fi
        sleep 2
        ((timeout-=2))
    done
    
    if [ $timeout -le 0 ]; then
        print_error "PostgreSQL failed to start within 60 seconds"
        exit 1
    fi
    print_success "PostgreSQL is ready"
    
    # Wait for Redis
    print_status "Waiting for Redis..."
    timeout=30
    while [ $timeout -gt 0 ]; do
        if docker exec vitalflow_redis redis-cli ping &> /dev/null; then
            break
        fi
        sleep 2
        ((timeout-=2))
    done
    
    if [ $timeout -le 0 ]; then
        print_error "Redis failed to start within 30 seconds"
        exit 1
    fi
    print_success "Redis is ready"
    
    # Wait for VitalFlow API
    print_status "Waiting for VitalFlow API..."
    timeout=120
    while [ $timeout -gt 0 ]; do
        if curl -f http://localhost:5000/health &> /dev/null; then
            break
        fi
        sleep 3
        ((timeout-=3))
    done
    
    if [ $timeout -le 0 ]; then
        print_error "VitalFlow API failed to start within 120 seconds"
        exit 1
    fi
    print_success "VitalFlow API is ready"
    
    # Wait for n8n
    print_status "Waiting for n8n..."
    timeout=120
    while [ $timeout -gt 0 ]; do
        if curl -f http://localhost:5678/healthz &> /dev/null; then
            break
        fi
        sleep 3
        ((timeout-=3))
    done
    
    if [ $timeout -le 0 ]; then
        print_error "n8n failed to start within 120 seconds"
        exit 1
    fi
    print_success "n8n is ready"
    
    print_success "All services are ready!"
}

# Function to run database migrations
run_migrations() {
    print_status "Running database migrations..."
    
    # Run migrations for main database
    docker exec vitalflow_api flask db upgrade
    
    print_success "Database migrations completed"
}

# Function to import n8n workflows
import_workflows() {
    print_status "Importing n8n workflows..."
    
    # Import the VitalFlow master workflow
    if [ -f "$PROJECT_ROOT/docker/n8n/workflows/vitalflow-master-automation.json" ]; then
        # Note: This would require n8n CLI or API call
        print_status "n8n workflows are available for manual import"
        print_status "Access n8n at http://localhost:5678 to import workflows"
    fi
    
    print_success "Workflow import information provided"
}

# Function to display service status
show_status() {
    print_header "VITALFLOW SERVICE STATUS"
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" ps
    else
        docker compose -f "$DOCKER_COMPOSE_FILE" ps
    fi
    
    echo ""
    print_header "SERVICE URLS"
    echo -e "${CYAN}VitalFlow API:${NC}        http://localhost:5000"
    echo -e "${CYAN}VitalFlow Automation:${NC} http://localhost:5001"
    echo -e "${CYAN}VitalFlow Analytics:${NC}  http://localhost:5002"
    echo -e "${CYAN}n8n Workflows:${NC}        http://localhost:5678"
    echo -e "${CYAN}Nginx Proxy:${NC}          http://localhost:80"
    echo -e "${CYAN}PostgreSQL:${NC}           localhost:5432"
    echo -e "${CYAN}Redis:${NC}                localhost:6379"
    
    if docker ps | grep -q vitalflow_prometheus; then
        echo -e "${CYAN}Prometheus:${NC}           http://localhost:9090"
    fi
    
    if docker ps | grep -q vitalflow_grafana; then
        echo -e "${CYAN}Grafana:${NC}              http://localhost:3000"
    fi
    
    echo ""
    print_header "AUTHENTICATION"
    source "$ENV_FILE"
    echo -e "${CYAN}n8n Username:${NC}         ${N8N_BASIC_AUTH_USER}"
    echo -e "${CYAN}n8n Password:${NC}         ${N8N_BASIC_AUTH_PASSWORD}"
    
    if [ ! -z "${GRAFANA_USER}" ]; then
        echo -e "${CYAN}Grafana Username:${NC}     ${GRAFANA_USER}"
        echo -e "${CYAN}Grafana Password:${NC}     ${GRAFANA_PASSWORD}"
    fi
}

# Function to show logs
show_logs() {
    print_header "RECENT LOGS"
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" logs --tail=50
    else
        docker compose -f "$DOCKER_COMPOSE_FILE" logs --tail=50
    fi
}

# Function to create initial data
create_initial_data() {
    print_status "Creating initial data..."
    
    # Create default system settings
    docker exec vitalflow_api python -c "
from src.api.models import SystemSetting, db
from src.api.main import app

with app.app_context():
    # Create default settings if they don't exist
    settings = [
        ('posting_schedule', '[\"08:00\", \"12:00\", \"18:00\"]', 'Default posting times'),
        ('max_posts_per_day', '3', 'Maximum posts per day'),
        ('auto_posting_enabled', 'true', 'Enable automatic posting'),
        ('content_generation_enabled', 'true', 'Enable automatic content generation'),
        ('ai_creativity_level', '0.8', 'AI creativity level (0-1)'),
        ('content_safety_filter', 'true', 'Enable content safety filtering')
    ]
    
    for key, value, description in settings:
        existing = SystemSetting.query.filter_by(key=key).first()
        if not existing:
            setting = SystemSetting(key=key, value=value, description=description)
            db.session.add(setting)
    
    db.session.commit()
    print('Initial system settings created')
"
    
    print_success "Initial data created"
}

# Function to run health checks
run_health_checks() {
    print_status "Running health checks..."
    
    # Check API health
    if curl -f http://localhost:5000/health &> /dev/null; then
        print_success "VitalFlow API: Healthy"
    else
        print_error "VitalFlow API: Unhealthy"
    fi
    
    # Check automation service health
    if curl -f http://localhost:5001/health &> /dev/null; then
        print_success "VitalFlow Automation: Healthy"
    else
        print_error "VitalFlow Automation: Unhealthy"
    fi
    
    # Check analytics service health
    if curl -f http://localhost:5002/health &> /dev/null; then
        print_success "VitalFlow Analytics: Healthy"
    else
        print_error "VitalFlow Analytics: Unhealthy"
    fi
    
    # Check n8n health
    if curl -f http://localhost:5678/healthz &> /dev/null; then
        print_success "n8n: Healthy"
    else
        print_error "n8n: Unhealthy"
    fi
    
    # Check database connectivity
    if docker exec vitalflow_postgres pg_isready -U vitalflow -d vitalflow &> /dev/null; then
        print_success "PostgreSQL: Healthy"
    else
        print_error "PostgreSQL: Unhealthy"
    fi
    
    # Check Redis connectivity
    if docker exec vitalflow_redis redis-cli ping &> /dev/null; then
        print_success "Redis: Healthy"
    else
        print_error "Redis: Unhealthy"
    fi
}

# Main execution function
main() {
    print_header "VITALFLOW AUTOMATION SYSTEM STARTUP"
    
    # Change to project root directory
    cd "$PROJECT_ROOT"
    
    # Run all setup steps
    check_docker
    check_docker_compose
    create_directories
    setup_environment
    validate_environment
    pull_images
    build_images
    start_services
    wait_for_services
    run_migrations
    create_initial_data
    import_workflows
    run_health_checks
    
    # Show final status
    echo ""
    print_header "STARTUP COMPLETE"
    print_success "VitalFlow Automation System is now running!"
    echo ""
    
    show_status
    
    echo ""
    print_header "NEXT STEPS"
    echo "1. Access n8n at http://localhost:5678 to configure workflows"
    echo "2. Access the VitalFlow API at http://localhost:5000"
    echo "3. Check the analytics dashboard at http://localhost:5002/dashboard"
    echo "4. Configure your TikTok, Supliful, and OpenAI API keys in the .env file"
    echo "5. Import the VitalFlow workflows in n8n"
    echo ""
    print_status "To view logs: ./scripts/startup.sh logs"
    print_status "To stop services: docker-compose down"
    print_status "To restart services: docker-compose restart"
}

# Handle command line arguments
case "${1:-}" in
    "logs")
        show_logs
        ;;
    "status")
        show_status
        ;;
    "health")
        run_health_checks
        ;;
    *)
        main
        ;;
esac

