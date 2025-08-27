#!/bin/bash
# 💾 n8n-docker-caddy Backup Script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_ROOT=".."
BACKUP_DIR="$PROJECT_ROOT/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="n8n-backup-$DATE"

echo -e "${GREEN}💾 Starting backup...${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Docker volume backup function
backup_volume() {
    local volume_name=$1
    local backup_file="$BACKUP_DIR/${BACKUP_NAME}_${volume_name}.tar.gz"
    
    echo -e "${YELLOW}📦 Backing up volume $volume_name...${NC}"
    
    if docker volume inspect "$volume_name" &>/dev/null; then
        # Execute from root directory to ensure Docker paths are correct
        (cd $PROJECT_ROOT && docker run --rm \
            -v "$volume_name":/data:ro \
            -v "$(pwd)/backups":/backup \
            alpine:latest \
            tar czf "/backup/${BACKUP_NAME}_${volume_name}.tar.gz" -C /data .)
        
        echo -e "${GREEN}✅ Volume $volume_name backed up${NC}"
    else
        echo -e "${RED}❌ Volume $volume_name not found${NC}"
    fi
}

# Backup configuration
echo -e "${YELLOW}📝 Backing up configuration...${NC}"
(cd $PROJECT_ROOT && tar czf "backups/${BACKUP_NAME}_config.tar.gz" \
    --exclude='backups' \
    --exclude='.git' \
    --exclude='*.log' \
    .)

# Backup Docker volumes
# Execute Docker commands from root directory
cd $PROJECT_ROOT
backup_volume "n8n_data"
backup_volume "flowise_data"
backup_volume "caddy_data"

# Backup optional volumes if they exist
backup_volume "grafana_data" 2>/dev/null || true
backup_volume "prometheus_data" 2>/dev/null || true
backup_volume "portainer_data" 2>/dev/null || true
backup_volume "uptime_data" 2>/dev/null || true

# Create backup information file
cat > "$BACKUP_DIR/${BACKUP_NAME}_info.txt" << EOF
🔍 BACKUP INFORMATION

📅 Date: $(date)
🖥️  Hostname: $(hostname)
📋 Compose file: $([ -f docker-compose.yml ] && echo "docker-compose.yml" || echo "Not found")
🐳 Active services:
$(docker compose ps --format "- {{.Name}}: {{.Status}}" 2>/dev/null || echo "Unable to list services")

📦 Backed up volumes:
$(ls -1 $BACKUP_DIR/${BACKUP_NAME}_*.tar.gz | sed 's|.*/||' | sed 's/^/- /')

💾 Total size: $(du -sh $BACKUP_DIR/${BACKUP_NAME}_* | awk '{print $1}' | paste -sd+ | bc 2>/dev/null || echo "N/A")

🔧 To restore:
cd scripts && ./restore.sh $BACKUP_NAME

EOF

# Clean old backups (keep last 7)
echo -e "${YELLOW}🧹 Cleaning old backups...${NC}"
find "$BACKUP_DIR" -name "n8n-backup-*" -type f -mtime +7 -delete 2>/dev/null || true

# Summary
echo -e "${GREEN}✅ Backup completed!${NC}"
echo -e "${YELLOW}📁 Files created:${NC}"
ls -la "$BACKUP_DIR/${BACKUP_NAME}"*

echo ""
echo -e "${GREEN}💡 Tip: Copy these files to external storage${NC}"
echo -e "${YELLOW}🔧 Restore: cd scripts && ./restore.sh $BACKUP_NAME${NC}"

# Return to root directory to facilitate next steps
cd $PROJECT_ROOT