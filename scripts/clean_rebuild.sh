#!/bin/bash
# 🧹 Complete cleanup script to test the new version
# Keeps Docker images to save bandwidth

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧹 Complete cleanup of n8n installation${NC}"
echo "=================================================="

# 1. Stop all n8n-related containers
echo -e "${YELLOW}⏹️  Stopping all containers...${NC}"
docker compose -f docker-compose-pro.yml down 2>/dev/null || true
docker compose -f docker-compose-monitoring.yml down 2>/dev/null || true  
docker compose -f docker-compose-basic.yml down 2>/dev/null || true
docker compose -f docker-compose.yml down 2>/dev/null || true

# 2. Remove all n8n containers (even stopped ones)
echo -e "${YELLOW}🗑️  Removing stopped containers...${NC}"
docker container prune -f

# 3. Remove all n8n volumes (DATA WILL BE LOST!)
echo -e "${RED}⚠️  WARNING: Removing volumes (data will be lost)${NC}"
read -p "Are you sure you want to delete ALL data? [y/N]: " CONFIRM_DELETE
if [[ "$CONFIRM_DELETE" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🗄️  Removing volumes...${NC}"
    
    # List all n8n volumes
    docker volume ls -q | grep -E "(caddy_data|n8n_data|flowise_data|grafana_data|prometheus_data|portainer_data|uptime_data)" | while read volume; do
        echo "Removing volume: $volume"
        docker volume rm "$volume" 2>/dev/null || true
    done
    
    # Alternative if names have project prefix
    docker volume ls -q | grep -E "n8n.*docker.*caddy" | while read volume; do
        echo "Removing project volume: $volume"
        docker volume rm "$volume" 2>/dev/null || true
    done
else
    echo -e "${GREEN}✅ Volumes preserved${NC}"
fi

# 4. Clean orphaned networks
echo -e "${YELLOW}🌐 Cleaning networks...${NC}"
docker network prune -f

# 5. Remove configuration files (keep images)
echo -e "${YELLOW}📁 Cleaning configuration files...${NC}"
rm -f .env 2>/dev/null || true
rm -f credentials.txt 2>/dev/null || true
rm -f docker-compose.yml 2>/dev/null || true
rm -rf caddy_config/Caddyfile 2>/dev/null || true
rm -rf grafana/ 2>/dev/null || true

# Recreate example Caddyfile
echo -e "${BLUE}📝 Recreating example Caddyfile...${NC}"
cp caddy_config/Caddyfile.example caddy_config/Caddyfile 2>/dev/null || true

echo ""
echo -e "${GREEN}✅ Cleanup completed!${NC}"
echo ""

# 6. Display preserved images
echo -e "${BLUE}🖼️  Preserved Docker images:${NC}"
docker images | grep -E "(n8n|caddy|grafana|prometheus|portainer|flowise|watchtower|uptime)" || echo "No n8n images found"

echo ""
echo -e "${BLUE}🚀 Steps to retest:${NC}"
echo "1. cd scripts"
echo "2. ./setup.sh"
echo "3. Follow the installation process"
echo "4. cd .."
echo "5. docker compose -f docker-compose-[level].yml up -d"
echo "6. Test all services"
echo ""
echo -e "${YELLOW}💡 Note: Docker images are preserved to speed up redeployment${NC}"

# 7. Current state verification
echo ""
echo -e "${BLUE}📊 Current system state:${NC}"
echo -e "${YELLOW}Running containers:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "No containers"

echo ""
echo -e "${YELLOW}Existing volumes:${NC}"
docker volume ls | grep -E "(caddy|n8n|flowise|grafana|prometheus|portainer|uptime)" || echo "No n8n volumes"

echo ""
echo -e "${GREEN}🎯 System ready for a fresh installation!${NC}"