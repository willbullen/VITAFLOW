#!/bin/bash

# VitalFlow Automation System Shutdown Script
# This script gracefully stops the VitalFlow Docker environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"

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

# Function to create backup before shutdown
create_backup() {
    print_status "Creating backup before shutdown..."
    
    BACKUP_DIR="$PROJECT_ROOT/backups"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUP_DIR/vitalflow_backup_$TIMESTAMP.sql"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup PostgreSQL databases
    if docker ps | grep -q vitalflow_postgres; then
        print_status "Backing up PostgreSQL databases..."
        docker exec vitalflow_postgres pg_dumpall -U vitalflow > "$BACKUP_FILE"
        print_success "Database backup created: $BACKUP_FILE"
    else
        print_warning "PostgreSQL container not running, skipping database backup"
    fi
    
    # Backup generated content
    if [ -d "$PROJECT_ROOT/generated_content" ]; then
        print_status "Backing up generated content..."
        tar -czf "$BACKUP_DIR/generated_content_$TIMESTAMP.tar.gz" -C "$PROJECT_ROOT" generated_content/
        print_success "Generated content backup created"
    fi
    
    # Backup configuration
    if [ -f "$PROJECT_ROOT/.env" ]; then
        print_status "Backing up configuration..."
        cp "$PROJECT_ROOT/.env" "$BACKUP_DIR/.env_$TIMESTAMP"
        print_success "Configuration backup created"
    fi
}

# Function to stop services gracefully
stop_services() {
    print_status "Stopping VitalFlow services gracefully..."
    
    # Stop services in reverse dependency order
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" stop
    else
        docker compose -f "$DOCKER_COMPOSE_FILE" stop
    fi
    
    print_success "Services stopped successfully"
}

# Function to remove containers
remove_containers() {
    print_status "Removing containers..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" down
    else
        docker compose -f "$DOCKER_COMPOSE_FILE" down
    fi
    
    print_success "Containers removed successfully"
}

# Function to remove volumes (optional)
remove_volumes() {
    print_warning "This will permanently delete all data including databases!"
    read -p "Are you sure you want to remove all volumes? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removing volumes..."
        
        if command -v docker-compose &> /dev/null; then
            docker-compose -f "$DOCKER_COMPOSE_FILE" down -v
        else
            docker compose -f "$DOCKER_COMPOSE_FILE" down -v
        fi
        
        print_success "Volumes removed successfully"
    else
        print_status "Volumes preserved"
    fi
}

# Function to remove images (optional)
remove_images() {
    print_warning "This will remove all VitalFlow Docker images!"
    read -p "Are you sure you want to remove all images? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removing images..."
        
        if command -v docker-compose &> /dev/null; then
            docker-compose -f "$DOCKER_COMPOSE_FILE" down --rmi all
        else
            docker compose -f "$DOCKER_COMPOSE_FILE" down --rmi all
        fi
        
        print_success "Images removed successfully"
    else
        print_status "Images preserved"
    fi
}

# Function to clean up Docker system
cleanup_docker() {
    print_status "Cleaning up Docker system..."
    
    # Remove unused networks
    docker network prune -f
    
    # Remove unused volumes (only if not used by other containers)
    docker volume prune -f
    
    # Remove unused images
    docker image prune -f
    
    print_success "Docker system cleaned up"
}

# Function to show final status
show_final_status() {
    print_header "SHUTDOWN COMPLETE"
    
    # Check if any VitalFlow containers are still running
    RUNNING_CONTAINERS=$(docker ps --filter "name=vitalflow" --format "table {{.Names}}\t{{.Status}}" | tail -n +2)
    
    if [ -z "$RUNNING_CONTAINERS" ]; then
        print_success "All VitalFlow containers have been stopped"
    else
        print_warning "Some containers are still running:"
        echo "$RUNNING_CONTAINERS"
    fi
    
    # Show disk space usage
    print_status "Current disk usage:"
    df -h "$PROJECT_ROOT" | tail -n 1
    
    # Show backup information
    if [ -d "$PROJECT_ROOT/backups" ]; then
        BACKUP_COUNT=$(ls -1 "$PROJECT_ROOT/backups" | wc -l)
        print_status "Backups available: $BACKUP_COUNT files"
        print_status "Backup location: $PROJECT_ROOT/backups"
    fi
}

# Main execution function
main() {
    print_header "VITALFLOW AUTOMATION SYSTEM SHUTDOWN"
    
    # Change to project root directory
    cd "$PROJECT_ROOT"
    
    # Ask for shutdown type
    echo "Select shutdown option:"
    echo "1. Graceful stop (preserve data)"
    echo "2. Stop and remove containers (preserve volumes)"
    echo "3. Complete cleanup (remove everything)"
    echo "4. Emergency stop (force stop all)"
    read -p "Enter your choice (1-4): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            print_status "Performing graceful shutdown..."
            create_backup
            stop_services
            ;;
        2)
            print_status "Stopping and removing containers..."
            create_backup
            remove_containers
            ;;
        3)
            print_status "Performing complete cleanup..."
            create_backup
            remove_containers
            remove_volumes
            remove_images
            cleanup_docker
            ;;
        4)
            print_warning "Performing emergency stop..."
            docker kill $(docker ps -q --filter "name=vitalflow") 2>/dev/null || true
            docker rm $(docker ps -aq --filter "name=vitalflow") 2>/dev/null || true
            ;;
        *)
            print_error "Invalid option. Performing graceful shutdown..."
            create_backup
            stop_services
            ;;
    esac
    
    show_final_status
    
    echo ""
    print_header "RESTART INSTRUCTIONS"
    echo "To restart VitalFlow:"
    echo "  ./scripts/startup.sh"
    echo ""
    echo "To restore from backup:"
    echo "  1. Start the system: ./scripts/startup.sh"
    echo "  2. Restore database: docker exec -i vitalflow_postgres psql -U vitalflow < backups/vitalflow_backup_TIMESTAMP.sql"
    echo "  3. Restore content: tar -xzf backups/generated_content_TIMESTAMP.tar.gz"
    echo ""
    print_success "VitalFlow shutdown complete!"
}

# Handle command line arguments
case "${1:-}" in
    "force")
        print_warning "Force stopping all VitalFlow containers..."
        docker kill $(docker ps -q --filter "name=vitalflow") 2>/dev/null || true
        docker rm $(docker ps -aq --filter "name=vitalflow") 2>/dev/null || true
        print_success "Force stop complete"
        ;;
    "backup")
        create_backup
        ;;
    "clean")
        remove_containers
        remove_volumes
        remove_images
        cleanup_docker
        ;;
    *)
        main
        ;;
esac

