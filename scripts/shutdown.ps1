# VitalFlow Automation System Shutdown Script for Windows
# PowerShell script to stop the VitalFlow Docker environment

param(
    [string]$Action = "graceful",
    [switch]$Help,
    [switch]$Force,
    [switch]$Backup,
    [switch]$Clean,
    [switch]$RemoveVolumes,
    [switch]$RemoveImages
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
    Write-Header "VITALFLOW AUTOMATION SYSTEM - WINDOWS SHUTDOWN"
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor $Colors.Cyan
    Write-Host "  .\scripts\shutdown.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor $Colors.Cyan
    Write-Host "  -Action <action>     Shutdown action (graceful, force, clean)"
    Write-Host "  -Backup              Create backup before shutdown"
    Write-Host "  -Force               Force stop all containers"
    Write-Host "  -Clean               Remove containers and networks"
    Write-Host "  -RemoveVolumes       Remove all volumes (DESTRUCTIVE)"
    Write-Host "  -RemoveImages        Remove all images"
    Write-Host "  -Help                Show this help message"
    Write-Host ""
    Write-Host "ACTIONS:" -ForegroundColor $Colors.Cyan
    Write-Host "  graceful             Stop services gracefully (default)"
    Write-Host "  force                Force stop all containers"
    Write-Host "  clean                Remove containers, networks, and unused resources"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor $Colors.Cyan
    Write-Host "  .\scripts\shutdown.ps1                    # Graceful shutdown"
    Write-Host "  .\scripts\shutdown.ps1 -Backup            # Backup then shutdown"
    Write-Host "  .\scripts\shutdown.ps1 -Force             # Force stop"
    Write-Host "  .\scripts\shutdown.ps1 -Clean             # Clean shutdown"
    Write-Host "  .\scripts\shutdown.ps1 -Action clean -RemoveVolumes  # Complete cleanup"
    Write-Host ""
}

# Function to create backup before shutdown
function New-Backup {
    Write-Status "Creating backup before shutdown..."
    
    $BackupDir = Join-Path $ProjectRoot "backups"
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $BackupFile = Join-Path $BackupDir "vitalflow_backup_$Timestamp.sql"
    
    # Create backup directory
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir | Out-Null
    }
    
    # Backup PostgreSQL databases
    try {
        $postgresRunning = docker ps --filter "name=vitalflow_postgres" --format "{{.Names}}" | Select-String "vitalflow_postgres"
        if ($postgresRunning) {
            Write-Status "Backing up PostgreSQL databases..."
            docker exec vitalflow_postgres pg_dumpall -U vitalflow | Out-File -FilePath $BackupFile -Encoding UTF8
            Write-Success "Database backup created: $BackupFile"
        }
        else {
            Write-Warning "PostgreSQL container not running, skipping database backup"
        }
    }
    catch {
        Write-Warning "Database backup failed: $_"
    }
    
    # Backup generated content
    $ContentDir = Join-Path $ProjectRoot "generated_content"
    if (Test-Path $ContentDir) {
        Write-Status "Backing up generated content..."
        $ContentBackup = Join-Path $BackupDir "generated_content_$Timestamp.zip"
        Compress-Archive -Path $ContentDir -DestinationPath $ContentBackup -Force
        Write-Success "Generated content backup created: $ContentBackup"
    }
    
    # Backup configuration
    if (Test-Path $EnvFile) {
        Write-Status "Backing up configuration..."
        $ConfigBackup = Join-Path $BackupDir ".env_$Timestamp"
        Copy-Item $EnvFile $ConfigBackup
        Write-Success "Configuration backup created: $ConfigBackup"
    }
    
    # Backup n8n workflows
    $N8nDir = Join-Path $ProjectRoot "data\n8n"
    if (Test-Path $N8nDir) {
        Write-Status "Backing up n8n workflows..."
        $N8nBackup = Join-Path $BackupDir "n8n_workflows_$Timestamp.zip"
        Compress-Archive -Path $N8nDir -DestinationPath $N8nBackup -Force
        Write-Success "n8n workflows backup created: $N8nBackup"
    }
    
    Write-Success "Backup completed successfully"
}

# Function to stop services gracefully
function Stop-Services {
    Write-Status "Stopping VitalFlow services gracefully..."
    
    try {
        Set-Location $ProjectRoot
        
        # Stop services in reverse dependency order
        Write-Status "Stopping reverse proxy..."
        docker compose stop nginx
        
        Write-Status "Stopping monitoring services..."
        docker compose stop prometheus grafana
        
        Write-Status "Stopping Cloudflare Tunnel..."
        docker compose stop cloudflaretunnel
        
        Write-Status "Stopping Portainer..."
        docker compose stop portainer
        
        Write-Status "Stopping n8n..."
        docker compose stop n8n
        
        Write-Status "Stopping background services..."
        docker compose stop flower vitalflow-scheduler vitalflow-worker
        
        Write-Status "Stopping application services..."
        docker compose stop vitalflow-analytics vitalflow-automation vitalflow-api
        
        Write-Status "Stopping infrastructure services..."
        docker compose stop redis postgres
        
        Write-Success "Services stopped successfully"
    }
    catch {
        Write-Error "Failed to stop services gracefully: $_"
        return $false
    }
    
    return $true
}

# Function to force stop services
function Stop-ServicesForce {
    Write-Status "Force stopping all VitalFlow containers..."
    
    try {
        # Get all VitalFlow containers
        $containers = docker ps -q --filter "name=vitalflow" --filter "name=cloudflaretunnel" --filter "name=portainer"
        
        if ($containers) {
            Write-Status "Killing containers: $($containers -join ', ')"
            docker kill $containers
            Write-Status "Removing containers..."
            docker rm $containers
        }
        else {
            Write-Status "No VitalFlow containers found running"
        }
        
        Write-Success "Force stop completed"
    }
    catch {
        Write-Error "Failed to force stop containers: $_"
        return $false
    }
    
    return $true
}

# Function to remove containers
function Remove-Containers {
    Write-Status "Removing containers..."
    
    try {
        Set-Location $ProjectRoot
        docker compose down
        Write-Success "Containers removed successfully"
    }
    catch {
        Write-Error "Failed to remove containers: $_"
        return $false
    }
    
    return $true
}

# Function to remove volumes
function Remove-Volumes {
    Write-Warning "This will permanently delete all data including databases!"
    $confirmation = Read-Host "Are you sure you want to remove all volumes? (y/N)"
    
    if ($confirmation -eq "y" -or $confirmation -eq "Y") {
        Write-Status "Removing volumes..."
        
        try {
            Set-Location $ProjectRoot
            docker compose down -v
            Write-Success "Volumes removed successfully"
        }
        catch {
            Write-Error "Failed to remove volumes: $_"
            return $false
        }
    }
    else {
        Write-Status "Volumes preserved"
    }
    
    return $true
}

# Function to remove images
function Remove-Images {
    Write-Warning "This will remove all VitalFlow Docker images!"
    $confirmation = Read-Host "Are you sure you want to remove all images? (y/N)"
    
    if ($confirmation -eq "y" -or $confirmation -eq "Y") {
        Write-Status "Removing images..."
        
        try {
            Set-Location $ProjectRoot
            docker compose down --rmi all
            Write-Success "Images removed successfully"
        }
        catch {
            Write-Error "Failed to remove images: $_"
            return $false
        }
    }
    else {
        Write-Status "Images preserved"
    }
    
    return $true
}

# Function to clean up Docker system
function Clear-DockerSystem {
    Write-Status "Cleaning up Docker system..."
    
    try {
        # Remove unused networks
        Write-Status "Removing unused networks..."
        docker network prune -f
        
        # Remove unused volumes (only if not used by other containers)
        Write-Status "Removing unused volumes..."
        docker volume prune -f
        
        # Remove unused images
        Write-Status "Removing unused images..."
        docker image prune -f
        
        # Remove build cache
        Write-Status "Removing build cache..."
        docker builder prune -f
        
        Write-Success "Docker system cleaned up"
    }
    catch {
        Write-Warning "Docker cleanup partially failed: $_"
    }
}

# Function to show final status
function Show-FinalStatus {
    Write-Header "SHUTDOWN COMPLETE"
    
    # Check if any VitalFlow containers are still running
    $runningContainers = docker ps --filter "name=vitalflow" --filter "name=cloudflaretunnel" --filter "name=portainer" --format "table {{.Names}}\t{{.Status}}"
    
    if (-not $runningContainers -or $runningContainers.Count -eq 0) {
        Write-Success "All VitalFlow containers have been stopped"
    }
    else {
        Write-Warning "Some containers are still running:"
        Write-Host $runningContainers -ForegroundColor $Colors.Yellow
    }
    
    # Show disk space usage
    Write-Status "Current disk usage:"
    $drive = (Get-Location).Drive
    $driveInfo = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$($drive.Name)'"
    $freeSpaceGB = [math]::Round($driveInfo.FreeSpace / 1GB, 2)
    $totalSpaceGB = [math]::Round($driveInfo.Size / 1GB, 2)
    $usedSpaceGB = $totalSpaceGB - $freeSpaceGB
    Write-Host "Drive $($drive.Name) - Used: $usedSpaceGB GB, Free: $freeSpaceGB GB, Total: $totalSpaceGB GB" -ForegroundColor $Colors.Cyan
    
    # Show backup information
    $BackupDir = Join-Path $ProjectRoot "backups"
    if (Test-Path $BackupDir) {
        $backupFiles = Get-ChildItem $BackupDir | Measure-Object
        Write-Status "Backups available: $($backupFiles.Count) files"
        Write-Status "Backup location: $BackupDir"
    }
    
    Write-Host ""
    Write-Header "RESTART INSTRUCTIONS"
    Write-Host "To restart VitalFlow:" -ForegroundColor $Colors.Cyan
    Write-Host "  .\scripts\startup.ps1" -ForegroundColor $Colors.Green
    Write-Host ""
    Write-Host "To restore from backup:" -ForegroundColor $Colors.Cyan
    Write-Host "  1. Start the system: .\scripts\startup.ps1" -ForegroundColor $Colors.Yellow
    Write-Host "  2. Restore database: docker exec -i vitalflow_postgres psql -U vitalflow < backups\vitalflow_backup_TIMESTAMP.sql" -ForegroundColor $Colors.Yellow
    Write-Host "  3. Extract content: Expand-Archive backups\generated_content_TIMESTAMP.zip -DestinationPath ." -ForegroundColor $Colors.Yellow
    Write-Host ""
    Write-Success "VitalFlow shutdown complete!"
}

# Function to show interactive shutdown menu
function Show-ShutdownMenu {
    Write-Header "VITALFLOW SHUTDOWN OPTIONS"
    Write-Host ""
    Write-Host "Select shutdown option:" -ForegroundColor $Colors.Cyan
    Write-Host "1. Graceful stop (preserve data)" -ForegroundColor $Colors.Green
    Write-Host "2. Stop and remove containers (preserve volumes)" -ForegroundColor $Colors.Yellow
    Write-Host "3. Complete cleanup (remove everything)" -ForegroundColor $Colors.Red
    Write-Host "4. Emergency stop (force stop all)" -ForegroundColor $Colors.Red
    Write-Host "5. Backup only (no shutdown)" -ForegroundColor $Colors.Blue
    Write-Host ""
    
    do {
        $choice = Read-Host "Enter your choice (1-5)"
    } while ($choice -notmatch "^[1-5]$")
    
    return [int]$choice
}

# Main execution function
function Main {
    if ($Help) {
        Show-Help
        return
    }
    
    Write-Header "VITALFLOW AUTOMATION SYSTEM SHUTDOWN"
    
    # Change to project root directory
    Set-Location $ProjectRoot
    
    # Handle backup-only request
    if ($Backup -and $Action -eq "graceful") {
        New-Backup
        return
    }
    
    # Determine shutdown action
    $shutdownChoice = 0
    
    if ($Force) {
        $shutdownChoice = 4
    }
    elseif ($Clean) {
        $shutdownChoice = 3
    }
    elseif ($Action -eq "force") {
        $shutdownChoice = 4
    }
    elseif ($Action -eq "clean") {
        $shutdownChoice = 3
    }
    elseif ($Action -eq "graceful") {
        $shutdownChoice = 1
    }
    else {
        $shutdownChoice = Show-ShutdownMenu
    }
    
    # Execute shutdown based on choice
    switch ($shutdownChoice) {
        1 {
            Write-Status "Performing graceful shutdown..."
            if ($Backup -or (Read-Host "Create backup before shutdown? (y/N)") -eq "y") {
                New-Backup
            }
            Stop-Services
        }
        
        2 {
            Write-Status "Stopping and removing containers..."
            if ($Backup -or (Read-Host "Create backup before shutdown? (y/N)") -eq "y") {
                New-Backup
            }
            Remove-Containers
        }
        
        3 {
            Write-Status "Performing complete cleanup..."
            if ($Backup -or (Read-Host "Create backup before cleanup? (y/N)") -eq "y") {
                New-Backup
            }
            Remove-Containers
            if ($RemoveVolumes -or (Read-Host "Remove all volumes? This will delete all data! (y/N)") -eq "y") {
                Remove-Volumes
            }
            if ($RemoveImages -or (Read-Host "Remove all images? (y/N)") -eq "y") {
                Remove-Images
            }
            Clear-DockerSystem
        }
        
        4 {
            Write-Warning "Performing emergency stop..."
            Stop-ServicesForce
        }
        
        5 {
            Write-Status "Creating backup only..."
            New-Backup
            Write-Success "Backup completed. System remains running."
            return
        }
        
        default {
            Write-Error "Invalid option selected"
            return
        }
    }
    
    Show-FinalStatus
}

# Handle Ctrl+C gracefully
$null = Register-EngineEvent PowerShell.Exiting -Action {
    Write-Host ""
    Write-Warning "Shutdown interrupted by user"
}

# Run main function
try {
    Main
}
catch {
    Write-Error "Shutdown failed: $_"
    Write-Host "You may need to manually stop containers with: docker stop `$(docker ps -q)" -ForegroundColor $Colors.Yellow
    exit 1
}

