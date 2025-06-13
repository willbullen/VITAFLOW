# VitalFlow Automation System Startup Script for Windows
# PowerShell script to start the VitalFlow Docker environment

param(
    [string]$Action = "start",
    [switch]$Help,
    [switch]$Status,
    [switch]$Health,
    [switch]$Logs,
    [switch]$Force
)

# Script configuration
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$DockerComposeFile = Join-Path $ProjectRoot "docker-compose.yml"
$EnvFile = Join-Path $ProjectRoot ".env"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Purple = "Magenta"
    Cyan = "Cyan"
}

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Colors.Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Colors.Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Red
}

function Write-Header {
    param([string]$Message)
    Write-Host "================================" -ForegroundColor $Colors.Purple
    Write-Host $Message -ForegroundColor $Colors.Purple
    Write-Host "================================" -ForegroundColor $Colors.Purple
}

# Function to show help
function Show-Help {
    Write-Header "VITALFLOW AUTOMATION SYSTEM - WINDOWS STARTUP"
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor $Colors.Cyan
    Write-Host "  .\scripts\startup.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor $Colors.Cyan
    Write-Host "  -Action <action>    Action to perform (start, stop, restart, build)"
    Write-Host "  -Status             Show system status"
    Write-Host "  -Health             Run health checks"
    Write-Host "  -Logs               Show service logs"
    Write-Host "  -Force              Force restart all services"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor $Colors.Cyan
    Write-Host "  .\scripts\startup.ps1                    # Start system"
    Write-Host "  .\scripts\startup.ps1 -Status            # Show status"
    Write-Host "  .\scripts\startup.ps1 -Health            # Health checks"
    Write-Host "  .\scripts\startup.ps1 -Action restart    # Restart system"
    Write-Host "  .\scripts\startup.ps1 -Logs              # View logs"
    Write-Host ""
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Status "Checking system prerequisites..."
    
    # Check Docker
    try {
        $dockerVersion = docker --version
        Write-Success "Docker found: $dockerVersion"
    }
    catch {
        Write-Error "Docker not found. Please install Docker Desktop for Windows."
        Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor $Colors.Cyan
        exit 1
    }
    
    # Check Docker Compose
    try {
        $composeVersion = docker compose version
        Write-Success "Docker Compose found: $composeVersion"
    }
    catch {
        Write-Error "Docker Compose not found. Please update Docker Desktop."
        exit 1
    }
    
    # Check if Docker is running
    try {
        docker info | Out-Null
        Write-Success "Docker daemon is running"
    }
    catch {
        Write-Error "Docker daemon is not running. Please start Docker Desktop."
        exit 1
    }
    
    # Check Docker Compose file
    if (-not (Test-Path $DockerComposeFile)) {
        Write-Error "Docker Compose file not found: $DockerComposeFile"
        exit 1
    }
    Write-Success "Docker Compose file found"
    
    # Check environment file
    if (-not (Test-Path $EnvFile)) {
        Write-Warning "Environment file not found. Creating from template..."
        $EnvTemplate = Join-Path $ProjectRoot ".env.example"
        if (Test-Path $EnvTemplate) {
            Copy-Item $EnvTemplate $EnvFile
            Write-Warning "Please edit .env file with your configuration before starting services"
            Write-Host "Required: POSTGRES_PASSWORD, REDIS_PASSWORD, SECRET_KEY, API keys" -ForegroundColor $Colors.Yellow
            return $false
        }
        else {
            Write-Error "Environment template not found: $EnvTemplate"
            exit 1
        }
    }
    Write-Success "Environment file found"
    
    return $true
}

# Function to validate environment configuration
function Test-Environment {
    Write-Status "Validating environment configuration..."
    
    $envContent = Get-Content $EnvFile -Raw
    $requiredVars = @(
        "POSTGRES_PASSWORD",
        "REDIS_PASSWORD", 
        "SECRET_KEY",
        "JWT_SECRET_KEY",
        "N8N_BASIC_AUTH_USER",
        "N8N_BASIC_AUTH_PASSWORD"
    )
    
    $missingVars = @()
    foreach ($var in $requiredVars) {
        if ($envContent -notmatch "$var=.+") {
            $missingVars += $var
        }
    }
    
    if ($missingVars.Count -gt 0) {
        Write-Error "Missing required environment variables:"
        foreach ($var in $missingVars) {
            Write-Host "  - $var" -ForegroundColor $Colors.Red
        }
        Write-Host ""
        Write-Host "Please edit .env file and set these variables before starting." -ForegroundColor $Colors.Yellow
        return $false
    }
    
    Write-Success "Environment configuration is valid"
    return $true
}

# Function to check port availability
function Test-Ports {
    Write-Status "Checking port availability..."
    
    $ports = @(80, 5000, 5001, 5002, 5432, 5555, 5678, 6379, 9000, 9090, 3000)
    $busyPorts = @()
    
    foreach ($port in $ports) {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            $busyPorts += $port
        }
    }
    
    if ($busyPorts.Count -gt 0) {
        Write-Warning "The following ports are already in use:"
        foreach ($port in $busyPorts) {
            Write-Host "  - Port $port" -ForegroundColor $Colors.Yellow
        }
        Write-Host ""
        Write-Host "This may cause conflicts. Consider stopping other services or using -Force to restart." -ForegroundColor $Colors.Yellow
        return $false
    }
    
    Write-Success "All required ports are available"
    return $true
}

# Function to pull Docker images
function Update-Images {
    Write-Status "Pulling latest Docker images..."
    
    try {
        Set-Location $ProjectRoot
        docker compose pull
        Write-Success "Docker images updated successfully"
    }
    catch {
        Write-Error "Failed to pull Docker images: $_"
        return $false
    }
    
    return $true
}

# Function to build custom images
function Build-Images {
    Write-Status "Building custom Docker images..."
    
    try {
        Set-Location $ProjectRoot
        docker compose build --no-cache
        Write-Success "Docker images built successfully"
    }
    catch {
        Write-Error "Failed to build Docker images: $_"
        return $false
    }
    
    return $true
}

# Function to start services
function Start-Services {
    Write-Status "Starting VitalFlow services..."
    
    try {
        Set-Location $ProjectRoot
        
        # Start core infrastructure first
        Write-Status "Starting core infrastructure (PostgreSQL, Redis)..."
        docker compose up -d postgres redis
        
        # Wait for database to be ready
        Write-Status "Waiting for database to be ready..."
        $maxAttempts = 30
        $attempt = 0
        
        do {
            Start-Sleep -Seconds 2
            $attempt++
            try {
                docker exec vitalflow_postgres pg_isready -U vitalflow | Out-Null
                $dbReady = $true
                break
            }
            catch {
                $dbReady = $false
            }
        } while ($attempt -lt $maxAttempts -and -not $dbReady)
        
        if (-not $dbReady) {
            Write-Error "Database failed to start within timeout period"
            return $false
        }
        Write-Success "Database is ready"
        
        # Start application services
        Write-Status "Starting application services..."
        docker compose up -d vitalflow-api vitalflow-automation vitalflow-analytics
        
        # Start background services
        Write-Status "Starting background services..."
        docker compose up -d vitalflow-worker vitalflow-scheduler flower
        
        # Start n8n
        Write-Status "Starting n8n workflow platform..."
        docker compose up -d n8n
        
        # Start Portainer
        Write-Status "Starting Portainer container management..."
        docker compose up -d portainer
        
        # Start Cloudflare Tunnel
        Write-Status "Starting Cloudflare Tunnel..."
        docker compose up -d cloudflaretunnel
        
        # Start reverse proxy
        Write-Status "Starting Nginx reverse proxy..."
        docker compose up -d nginx
        
        # Start monitoring (if enabled)
        if ($envContent -match "MONITORING_ENABLED=true") {
            Write-Status "Starting monitoring services..."
            docker compose up -d prometheus grafana
        }
        
        Write-Success "All services started successfully"
    }
    catch {
        Write-Error "Failed to start services: $_"
        return $false
    }
    
    return $true
}

# Function to wait for services to be ready
function Wait-ForServices {
    Write-Status "Waiting for services to be ready..."
    
    $services = @(
        @{ Name = "VitalFlow API"; Url = "http://localhost:5000/health"; MaxAttempts = 30 },
        @{ Name = "VitalFlow Automation"; Url = "http://localhost:5001/health"; MaxAttempts = 30 },
        @{ Name = "VitalFlow Analytics"; Url = "http://localhost:5002/dashboard"; MaxAttempts = 30 },
        @{ Name = "n8n"; Url = "http://localhost:5678/healthz"; MaxAttempts = 30 },
        @{ Name = "Portainer"; Url = "http://localhost:9000"; MaxAttempts = 20 },
        @{ Name = "Nginx"; Url = "http://localhost:80/health"; MaxAttempts = 20 }
    )
    
    foreach ($service in $services) {
        Write-Status "Checking $($service.Name)..."
        $attempt = 0
        $ready = $false
        
        do {
            Start-Sleep -Seconds 2
            $attempt++
            try {
                $response = Invoke-WebRequest -Uri $service.Url -TimeoutSec 5 -UseBasicParsing
                if ($response.StatusCode -eq 200) {
                    $ready = $true
                    Write-Success "$($service.Name) is ready"
                    break
                }
            }
            catch {
                # Service not ready yet
            }
        } while ($attempt -lt $service.MaxAttempts)
        
        if (-not $ready) {
            Write-Warning "$($service.Name) is not responding (may still be starting)"
        }
    }
}

# Function to run database migrations
function Invoke-Migrations {
    Write-Status "Running database migrations..."
    
    try {
        docker exec vitalflow_api flask db upgrade
        Write-Success "Database migrations completed"
    }
    catch {
        Write-Warning "Database migrations failed (may not be needed): $_"
    }
}

# Function to import n8n workflows
function Import-Workflows {
    Write-Status "Importing n8n workflows..."
    
    $workflowsDir = Join-Path $ProjectRoot "docker\n8n\workflows"
    if (Test-Path $workflowsDir) {
        Write-Status "Workflow files found, import manually through n8n interface"
        Write-Host "  1. Access n8n at http://localhost:5678" -ForegroundColor $Colors.Cyan
        Write-Host "  2. Go to Workflows → Import from File" -ForegroundColor $Colors.Cyan
        Write-Host "  3. Select files from: $workflowsDir" -ForegroundColor $Colors.Cyan
    }
    else {
        Write-Warning "No workflow files found in $workflowsDir"
    }
}

# Function to show service status
function Show-Status {
    Write-Header "VITALFLOW SYSTEM STATUS"
    
    try {
        Set-Location $ProjectRoot
        docker compose ps
        
        Write-Host ""
        Write-Header "SERVICE ACCESS URLS"
        Write-Host "VitalFlow API:        http://localhost:5000" -ForegroundColor $Colors.Green
        Write-Host "VitalFlow Analytics:  http://localhost:5002/dashboard" -ForegroundColor $Colors.Green
        Write-Host "n8n Workflows:        http://localhost:5678" -ForegroundColor $Colors.Green
        Write-Host "Portainer:            http://localhost:9000" -ForegroundColor $Colors.Green
        Write-Host "Celery Flower:        http://localhost:5555" -ForegroundColor $Colors.Green
        Write-Host "Nginx Proxy:          http://localhost:80" -ForegroundColor $Colors.Green
        
        $envContent = Get-Content $EnvFile -Raw
        if ($envContent -match "MONITORING_ENABLED=true") {
            Write-Host "Prometheus:           http://localhost:9090" -ForegroundColor $Colors.Green
            Write-Host "Grafana:              http://localhost:3000" -ForegroundColor $Colors.Green
        }
        
        Write-Host ""
        Write-Header "SYSTEM RESOURCES"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    }
    catch {
        Write-Error "Failed to get system status: $_"
    }
}

# Function to run health checks
function Test-Health {
    Write-Header "VITALFLOW HEALTH CHECKS"
    
    $healthChecks = @(
        @{ Name = "Docker Daemon"; Command = { docker info | Out-Null } },
        @{ Name = "PostgreSQL"; Command = { docker exec vitalflow_postgres pg_isready -U vitalflow | Out-Null } },
        @{ Name = "Redis"; Command = { docker exec vitalflow_redis redis-cli ping | Out-Null } },
        @{ Name = "VitalFlow API"; Command = { Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing | Out-Null } },
        @{ Name = "VitalFlow Automation"; Command = { Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing | Out-Null } },
        @{ Name = "VitalFlow Analytics"; Command = { Invoke-WebRequest -Uri "http://localhost:5002/dashboard" -UseBasicParsing | Out-Null } },
        @{ Name = "n8n"; Command = { Invoke-WebRequest -Uri "http://localhost:5678/healthz" -UseBasicParsing | Out-Null } },
        @{ Name = "Portainer"; Command = { Invoke-WebRequest -Uri "http://localhost:9000" -UseBasicParsing | Out-Null } },
        @{ Name = "Nginx"; Command = { Invoke-WebRequest -Uri "http://localhost:80/health" -UseBasicParsing | Out-Null } }
    )
    
    $healthyServices = 0
    $totalServices = $healthChecks.Count
    
    foreach ($check in $healthChecks) {
        try {
            & $check.Command
            Write-Host "✓ $($check.Name)" -ForegroundColor $Colors.Green
            $healthyServices++
        }
        catch {
            Write-Host "✗ $($check.Name)" -ForegroundColor $Colors.Red
        }
    }
    
    Write-Host ""
    Write-Host "Health Score: $healthyServices/$totalServices services healthy" -ForegroundColor $(if ($healthyServices -eq $totalServices) { $Colors.Green } else { $Colors.Yellow })
    
    if ($healthyServices -eq $totalServices) {
        Write-Success "All services are healthy!"
    }
    else {
        Write-Warning "Some services are not responding. Check logs with: .\scripts\startup.ps1 -Logs"
    }
}

# Function to show logs
function Show-Logs {
    Write-Header "VITALFLOW SERVICE LOGS"
    
    try {
        Set-Location $ProjectRoot
        docker compose logs --tail=50 -f
    }
    catch {
        Write-Error "Failed to show logs: $_"
    }
}

# Function to restart services
function Restart-Services {
    Write-Status "Restarting VitalFlow services..."
    
    try {
        Set-Location $ProjectRoot
        docker compose restart
        Write-Success "Services restarted successfully"
        
        # Wait for services to be ready
        Wait-ForServices
    }
    catch {
        Write-Error "Failed to restart services: $_"
        return $false
    }
    
    return $true
}

# Function to stop services
function Stop-Services {
    Write-Status "Stopping VitalFlow services..."
    
    try {
        Set-Location $ProjectRoot
        docker compose stop
        Write-Success "Services stopped successfully"
    }
    catch {
        Write-Error "Failed to stop services: $_"
        return $false
    }
    
    return $true
}

# Function to show final status
function Show-FinalStatus {
    Write-Header "VITALFLOW STARTUP COMPLETE"
    
    Write-Host ""
    Write-Host "🚀 VitalFlow TikTok Shop Automation is now running!" -ForegroundColor $Colors.Green
    Write-Host ""
    Write-Host "ACCESS YOUR SERVICES:" -ForegroundColor $Colors.Cyan
    Write-Host "  📊 Analytics Dashboard:  http://localhost:5002/dashboard" -ForegroundColor $Colors.Green
    Write-Host "  🤖 n8n Workflows:        http://localhost:5678" -ForegroundColor $Colors.Green
    Write-Host "  🐳 Portainer:            http://localhost:9000" -ForegroundColor $Colors.Green
    Write-Host "  🌸 Celery Flower:        http://localhost:5555" -ForegroundColor $Colors.Green
    Write-Host "  🌐 Main Proxy:           http://localhost:80" -ForegroundColor $Colors.Green
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor $Colors.Cyan
    Write-Host "  1. Configure n8n workflows at http://localhost:5678" -ForegroundColor $Colors.Yellow
    Write-Host "  2. Set up TikTok API credentials in .env file" -ForegroundColor $Colors.Yellow
    Write-Host "  3. Monitor system health with: .\scripts\startup.ps1 -Health" -ForegroundColor $Colors.Yellow
    Write-Host "  4. View logs with: .\scripts\startup.ps1 -Logs" -ForegroundColor $Colors.Yellow
    Write-Host ""
    Write-Host "MANAGEMENT COMMANDS:" -ForegroundColor $Colors.Cyan
    Write-Host "  Status:    .\scripts\startup.ps1 -Status" -ForegroundColor $Colors.Blue
    Write-Host "  Health:    .\scripts\startup.ps1 -Health" -ForegroundColor $Colors.Blue
    Write-Host "  Logs:      .\scripts\startup.ps1 -Logs" -ForegroundColor $Colors.Blue
    Write-Host "  Restart:   .\scripts\startup.ps1 -Action restart" -ForegroundColor $Colors.Blue
    Write-Host "  Stop:      .\scripts\shutdown.ps1" -ForegroundColor $Colors.Blue
    Write-Host ""
    Write-Success "Your automated TikTok Shop business is ready! 💰"
}

# Main execution function
function Main {
    if ($Help) {
        Show-Help
        return
    }
    
    if ($Status) {
        Show-Status
        return
    }
    
    if ($Health) {
        Test-Health
        return
    }
    
    if ($Logs) {
        Show-Logs
        return
    }
    
    Write-Header "VITALFLOW AUTOMATION SYSTEM STARTUP"
    
    # Change to project root directory
    Set-Location $ProjectRoot
    
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Error "Prerequisites check failed. Please fix the issues above."
        exit 1
    }
    
    # Validate environment
    if (-not (Test-Environment)) {
        Write-Error "Environment validation failed. Please configure .env file."
        exit 1
    }
    
    # Check ports (warning only)
    Test-Ports | Out-Null
    
    # Handle different actions
    switch ($Action.ToLower()) {
        "start" {
            Write-Status "Starting VitalFlow system..."
            
            if (-not (Update-Images)) {
                Write-Error "Failed to update Docker images"
                exit 1
            }
            
            if (-not (Start-Services)) {
                Write-Error "Failed to start services"
                exit 1
            }
            
            Wait-ForServices
            Invoke-Migrations
            Import-Workflows
            Show-FinalStatus
        }
        
        "stop" {
            if (-not (Stop-Services)) {
                Write-Error "Failed to stop services"
                exit 1
            }
        }
        
        "restart" {
            if (-not (Restart-Services)) {
                Write-Error "Failed to restart services"
                exit 1
            }
            Show-FinalStatus
        }
        
        "build" {
            if (-not (Build-Images)) {
                Write-Error "Failed to build images"
                exit 1
            }
            
            if (-not (Start-Services)) {
                Write-Error "Failed to start services"
                exit 1
            }
            
            Wait-ForServices
            Show-FinalStatus
        }
        
        default {
            Write-Error "Unknown action: $Action"
            Write-Host "Use -Help for available options" -ForegroundColor $Colors.Yellow
            exit 1
        }
    }
}

# Handle Ctrl+C gracefully
$null = Register-EngineEvent PowerShell.Exiting -Action {
    Write-Host ""
    Write-Warning "Startup interrupted by user"
}

# Run main function
try {
    Main
}
catch {
    Write-Error "Startup failed: $_"
    Write-Host "Check logs with: .\scripts\startup.ps1 -Logs" -ForegroundColor $Colors.Yellow
    exit 1
}

