#!/bin/bash
# 💥 COMPLETE CLEANUP - Stopping ALL n8n and other containers

set -e

# Determine script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
    
    return 0
}

# Run permissions check
fix_permissions || {
    echo -e "${RED}❌ Permission issues detected. Please fix manually or run with appropriate permissions.${NC}"
    exit 1
}

echo -e "${RED}💥 COMPLETE CLEANUP - STOPPING EVERYTHING${NC}"
echo "================================================"

# 1. Stop ALL n8n containers by name
echo -e "${YELLOW}⏹️  FORCE stopping all n8n containers...${NC}"

# List all containers with n8n in the name and stop them
docker ps -a --format "{{.Names}}" | grep -i "n8n\|caddy\|grafana\|prometheus\|flowise\|portainer\|uptime\|watchtower\|node-exporter\|cadvisor" | while read container; do
    echo "🛑 Force stopping: $container"
    docker stop "$container" 2>/dev/null || true
    docker rm "$container" 2>/dev/null || true
done

# 2. Alternative method: stop by image
echo -e "${YELLOW}🔍 Stopping by Docker image...${NC}"
for image in "n8n" "caddy" "grafana" "prometheus" "flowise" "portainer" "uptime-kuma" "watchtower" "node-exporter" "cadvisor"; do
    containers=$(docker ps -a -q --filter ancestor="*$image*" 2>/dev/null || true)
    if [ ! -z "$containers" ]; then
        echo "🛑 Stopping containers $image: $containers"
        docker stop $containers 2>/dev/null || true
        docker rm $containers 2>/dev/null || true
    fi
done

# 3. Attempt to stop with docker-compose in different directories
echo -e "${YELLOW}🔍 Searching for active docker-compose...${NC}"
for compose_file in "docker-compose.yml" "docker-compose-pro.yml" "docker-compose-monitoring.yml" "docker-compose-basic.yml"; do
    if [ -f "$PROJECT_ROOT/$compose_file" ]; then
        echo "📁 Attempting to stop: $compose_file"
        docker compose -f "$PROJECT_ROOT/$compose_file" down --remove-orphans 2>/dev/null || true
    fi
done

# 4. FORCE deletion of volumes
echo -e "${RED}💥 FORCE DELETION OF VOLUMES${NC}"
echo "⚠️  ALL DATA WILL BE LOST !"
read -p "Continue? [y/N]: " CONFIRM_NUCLEAR
if [[ "$CONFIRM_NUCLEAR" =~ ^[Yy]$ ]]; then
    
    # Delete all volumes with suspicious names
    docker volume ls -q | grep -E "(caddy|n8n|flowise|grafana|prometheus|portainer|uptime)" | while read volume; do
        echo "💥 Deleting volume: $volume"
        docker volume rm "$volume" --force 2>/dev/null || true
    done
    
    # Delete volumes with project prefix
    docker volume ls -q | grep "n8n.*docker.*caddy" | while read volume; do
        echo "💥 Deleting project volume: $volume"
        docker volume rm "$volume" --force 2>/dev/null || true
    done
    
fi

# 5. Docker system cleanup
echo -e "${YELLOW}🧹 Cleaning Docker system...${NC}"
docker container prune -f
docker network prune -f
docker volume prune -f

# 6. Deleting files and directories
echo -e "${YELLOW}📁 Deleting config files...${NC}"
rm -f "$PROJECT_ROOT/.env" "$PROJECT_ROOT/credentials.txt" "$PROJECT_ROOT/docker-compose.yml" 2>/dev/null || true
sudo rm -rf "$PROJECT_ROOT/grafana/" 2>/dev/null || true
rm -f "$PROJECT_ROOT/caddy_config/Caddyfile" 2>/dev/null || true

# Recreate example Caddyfile
if [ -f "$PROJECT_ROOT/caddy_config/Caddyfile.example" ]; then
    cp "$PROJECT_ROOT/caddy_config/Caddyfile.example" "$PROJECT_ROOT/caddy_config/Caddyfile"
    echo "✅ Example Caddyfile restored"
fi

echo ""
echo -e "${GREEN}💥 NUCLEAR CLEANUP COMPLETED${NC}"
echo ""

# 7. Final verification
echo -e "${BLUE}🔍 Final verification:${NC}"
echo ""
echo -e "${YELLOW}Remaining containers:${NC}"
remaining_containers=$(docker ps -a --format "{{.Names}}" | grep -iE "(n8n|caddy|grafana|prometheus|flowise|portainer|uptime|watchtower|node-exporter|cadvisor)" || echo "None")
if [ "$remaining_containers" = "None" ]; then
    echo -e "${GREEN}✅ No n8n containers remaining${NC}"
else
    echo -e "${RED}❌ Remaining containers:${NC}"
    echo "$remaining_containers"
fi

echo ""
echo -e "${YELLOW}Remaining volumes:${NC}"
remaining_volumes=$(docker volume ls -q | grep -iE "(caddy|n8n|flowise|grafana|prometheus|portainer|uptime)" || echo "None")
if [ "$remaining_volumes" = "None" ]; then
    echo -e "${GREEN}✅ No n8n volumes remaining${NC}"
else
    echo -e "${RED}❌ Remaining volumes:${NC}"
    echo "$remaining_volumes"
fi

echo ""
echo -e "${GREEN}🎯 System COMPLETELY cleaned!${NC}"
echo -e "${BLUE}🚀 You can now rerun setup.sh${NC}"