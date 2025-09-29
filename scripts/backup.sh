#!/bin/bash
# 💾 n8n-docker-caddy Backup Script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Determine script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Auto-fix permissions function
fix_permissions() {
    echo -e "${YELLOW}🔧 Checking and fixing permissions...${NC}"
    
    # Make all scripts executable
    chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
    
    # Ensure project directories are accessible
    if [[ ! -w "$PROJECT_ROOT" ]]; then
        echo -e "${YELLOW}⚠️  Project directory not writable. Attempting to fix...${NC}"
        if command -v sudo &> /dev/null; then
            sudo chown -R $(whoami):$(whoami) "$PROJECT_ROOT" 2>/dev/null || {
                echo -e "${RED}❌ Cannot fix permissions. Please run: sudo chown -R \$(whoami):\$(whoami) $PROJECT_ROOT${NC}"
                return 1
            }
        else
            echo -e "${RED}❌ No sudo available and directory not writable${NC}"
            return 1
        fi
    fi
    
    # Create backup directory if it doesn't exist
    mkdir -p "$PROJECT_ROOT/backups" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Cannot create backup directory. Trying with sudo...${NC}"
        if command -v sudo &> /dev/null; then
            sudo mkdir -p "$PROJECT_ROOT/backups"
            sudo chown $(whoami):$(whoami) "$PROJECT_ROOT/backups"
        else
            echo -e "${RED}❌ Cannot create backup directory${NC}"
            return 1
        fi
    }
    
    return 0
}

# Run permissions check
fix_permissions || {
    echo -e "${RED}❌ Permission issues detected. Please fix manually or run with appropriate permissions.${NC}"
    exit 1
}

# Detect Docker Compose command
DOCKER_COMPOSE_CMD=""
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}❌ Docker Compose not found${NC}"
    exit 1
fi

# Function to find the active docker-compose file
find_compose_file() {
    cd "$PROJECT_ROOT"
    
    for file in "docker-compose-pro.yml" "docker-compose-monitoring.yml" "docker-compose-basic.yml" "docker-compose.yml"; do
        if [[ -f "$file" ]]; then
            # Test if this compose file has running containers
            if $DOCKER_COMPOSE_CMD -f "$file" ps --services --filter "status=running" 2>/dev/null | grep -q .; then
                echo "$file"
                return 0
            fi
        fi
    done
    
    # Fallback: check which files exist
    for file in "docker-compose-pro.yml" "docker-compose-monitoring.yml" "docker-compose-basic.yml" "docker-compose.yml"; do
        if [[ -f "$file" ]]; then
            echo "$file"
            return 0
        fi
    done
    
    return 1
}

BACKUP_DIR="$PROJECT_ROOT/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="n8n-backup-$DATE"

echo -e "${GREEN}💾 Starting backup...${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Docker volume backup function
backup_volume() {
    local volume_name=$1
    local backup_file="${BACKUP_NAME}_${volume_name}.tar.gz"
    
    echo -e "${YELLOW}📦 Backing up volume $volume_name...${NC}"
    
    if docker volume inspect "$volume_name" &>/dev/null; then
        # Execute from root directory to ensure Docker paths are correct
        (cd "$PROJECT_ROOT" && docker run --rm \
            -v "$volume_name":/data:ro \
            -v "$(pwd)/backups":/backup \
            alpine:latest \
            tar czf "/backup/$backup_file" -C /data .)
        
        if [[ -f "$BACKUP_DIR/$backup_file" ]]; then
            echo -e "${GREEN}✅ Volume $volume_name backed up${NC}"
        else
            echo -e "${RED}❌ Failed to backup volume $volume_name${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Volume $volume_name not found${NC}"
    fi
}

# Backup configuration with permission handling
echo -e "${YELLOW}📝 Backing up configuration...${NC}"

# Use sudo for files with permission issues, or skip them
(cd "$PROJECT_ROOT" && {
    # Create temp directory for accessible files only
    temp_config="/tmp/n8n_config_backup_$$"
    mkdir -p "$temp_config"
    
    # Copy files we can access
    cp -r caddy_config "$temp_config/" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  caddy_config has permission issues, using Docker to backup...${NC}"
        if docker ps -q | head -1 | xargs -I {} docker run --rm \
            -v "$(pwd)/caddy_config":/source:ro \
            -v "$temp_config":/dest \
            alpine:latest \
            cp -r /source /dest/caddy_config 2>/dev/null; then
            echo -e "${GREEN}✅ caddy_config backed up via Docker${NC}"
        else
            echo -e "${RED}❌ Could not backup caddy_config${NC}"
        fi
    }
    
    # Copy other config files
    [[ -f .env ]] && cp .env "$temp_config/"
    [[ -f credentials.txt ]] && cp credentials.txt "$temp_config/"
    [[ -f docker-compose*.yml ]] && cp docker-compose*.yml "$temp_config/" 2>/dev/null || true
    [[ -d prometheus ]] && cp -r prometheus "$temp_config/" 2>/dev/null || true
    [[ -d grafana ]] && cp -r grafana "$temp_config/" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  grafana directory has permission issues, skipping...${NC}"
    }
    
    # Create archive from temp directory
    tar czf "backups/${BACKUP_NAME}_config.tar.gz" -C "$temp_config" . 2>/dev/null
    
    # Cleanup
    rm -rf "$temp_config"
    
    if [[ -f "backups/${BACKUP_NAME}_config.tar.gz" ]]; then
        echo -e "${GREEN}✅ Configuration backed up${NC}"
    else
        echo -e "${RED}❌ Configuration backup failed${NC}"
    fi
})

# Find compose file
COMPOSE_FILE=$(find_compose_file)
if [[ $? -ne 0 ]]; then
    echo -e "${YELLOW}⚠️  No active docker-compose file found, backing up all volumes...${NC}"
    COMPOSE_FILE=""
fi

# Move to root directory for Docker commands
cd "$PROJECT_ROOT"

# Backup Docker volumes
backup_volume "n8n_data"
backup_volume "flowise_data" 
backup_volume "caddy_data"

# Backup optional volumes if they exist
backup_volume "grafana_data"
backup_volume "prometheus_data"
backup_volume "portainer_data"
backup_volume "uptime_data"

# Create backup information file
cat > "$BACKUP_DIR/${BACKUP_NAME}_info.txt" << EOF
🔍 BACKUP INFORMATION

📅 Date: $(date)
🖥️  Hostname: $(hostname)
📋 Compose file: ${COMPOSE_FILE:-"Not detected"}
🐳 Active services:
$(if [[ -n "$COMPOSE_FILE" ]]; then 
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" ps --format "- {{.Name}}: {{.Status}}" 2>/dev/null || echo "Unable to list services"
else
    echo "No compose file detected"
fi)

📦 Backed up volumes:
$(ls -1 $BACKUP_DIR/${BACKUP_NAME}_*.tar.gz 2>/dev/null | sed 's|.*/||' | sed 's/^/- /' || echo "No volume backups found")

💾 Total size: $(du -sh $BACKUP_DIR/${BACKUP_NAME}_* 2>/dev/null | awk '{total += $1} END {print total "B"}' || echo "N/A")

🔧 To restore:
cd scripts && ./restore.sh $BACKUP_NAME

⚠️  Note: Some files may have been skipped due to permission issues.
Use 'sudo' if needed for complete restoration.

EOF

# Clean old backups (keep last 7)
echo -e "${YELLOW}🧹 Cleaning old backups...${NC}"
find "$BACKUP_DIR" -name "n8n-backup-*" -type f -mtime +7 -delete 2>/dev/null || true

# Summary
echo -e "${GREEN}✅ Backup completed!${NC}"
echo ""
echo -e "${YELLOW}📁 Files created:${NC}"
ls -la "$BACKUP_DIR/${BACKUP_NAME}"* 2>/dev/null || echo "No backup files found"

echo ""
echo -e "${GREEN}💡 Tip: Copy these files to external storage${NC}"
if [[ -f "$BACKUP_DIR/${BACKUP_NAME}_info.txt" ]]; then
    echo -e "${YELLOW}🔧 Restore: $SCRIPT_DIR/restore.sh $BACKUP_NAME${NC}"
fi

# Return to root directory to facilitate next steps
cd "$PROJECT_ROOT"