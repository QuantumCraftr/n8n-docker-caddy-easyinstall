#!/bin/bash
# 🔄 n8n-docker-caddy Update Script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Path to parent directory (project root)
PROJECT_ROOT=".."

# Detect Docker Compose command (same logic as setup.sh)
DOCKER_COMPOSE_CMD=""
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}❌ Docker Compose not found${NC}"
    exit 1
fi

echo -e "${BLUE}🔄 n8n-docker-caddy Update${NC}"
echo ""

# Function to display current versions
show_current_versions() {
    echo -e "${YELLOW}📋 Current versions:${NC}"
    
    # n8n
    if $DOCKER_COMPOSE_CMD ps n8n 2>/dev/null | grep -q "Up"; then
        N8N_VERSION=$($DOCKER_COMPOSE_CMD exec -T n8n n8n --version 2>/dev/null || echo "N/A")
        echo -e "  n8n: ${GREEN}$N8N_VERSION${NC}"
    fi
    
    # Caddy
    if $DOCKER_COMPOSE_CMD ps caddy 2>/dev/null | grep -q "Up"; then
        CADDY_VERSION=$($DOCKER_COMPOSE_CMD exec -T caddy caddy version 2>/dev/null || echo "N/A")
        echo -e "  Caddy: ${GREEN}$CADDY_VERSION${NC}"
    fi
    
    # Flowise
    if $DOCKER_COMPOSE_CMD ps flowise 2>/dev/null | grep -q "Up"; then
        echo -e "  Flowise: ${GREEN}$($DOCKER_COMPOSE_CMD images flowise --format "{{.Tag}}")${NC}"
    fi
    
    echo ""
}

# Update function with choice
update_choice() {
    echo -e "${YELLOW}🎯 Update type:${NC}"
    echo "1) 🚀 Quick (n8n only)"
    echo "2) 📦 Complete (all services)"
    echo "3) 🔧 With container recreation"
    echo "4) ❌ Cancel"
    echo ""
    read -p "Your choice [1-4]: " UPDATE_TYPE
    
    case $UPDATE_TYPE in
        1) update_n8n_only ;;
        2) update_all ;;
        3) update_recreate ;;
        4) echo -e "${YELLOW}⏹️ Update cancelled${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid choice${NC}"; exit 1 ;;
    esac
}

# Update n8n only
update_n8n_only() {
    echo -e "${BLUE}🚀 Quick n8n update...${NC}"
    
    $DOCKER_COMPOSE_CMD pull n8n
    $DOCKER_COMPOSE_CMD up -d n8n
    
    echo -e "${GREEN}✅ n8n updated!${NC}"
}

# Update all services
update_all() {
    echo -e "${BLUE}📦 Complete update...${NC}"
    
    # Download new images
    echo -e "${YELLOW}⬇️ Downloading new images...${NC}"
    $DOCKER_COMPOSE_CMD pull
    
    # Restart services
    echo -e "${YELLOW}🔄 Restarting services...${NC}"
    $DOCKER_COMPOSE_CMD up -d
    
    echo -e "${GREEN}✅ All services updated!${NC}"
}

# Update with recreation
update_recreate() {
    echo -e "${BLUE}🔧 Update with recreation...${NC}"
    echo -e "${RED}⚠️ This operation will recreate all containers${NC}"
    
    read -p "Continue? [y/N]: " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏹️ Operation cancelled${NC}"
        exit 0
    fi
    
    # Download new images
    echo -e "${YELLOW}⬇️ Downloading new images...${NC}"
    $DOCKER_COMPOSE_CMD pull
    
    # Stop services
    echo -e "${YELLOW}⏹️ Stopping services...${NC}"
    $DOCKER_COMPOSE_CMD down
    
    # Restart with recreation
    echo -e "${YELLOW}🚀 Recreating containers...${NC}"
    $DOCKER_COMPOSE_CMD up -d --force-recreate
    
    echo -e "${GREEN}✅ Complete update finished!${NC}"
}

# Cleanup function
cleanup_docker() {
    echo -e "${YELLOW}🧹 Docker cleanup...${NC}"
    
    # Unused images
    docker image prune -f
    
    # Anonymous volumes
    docker volume prune -f
    
    # Unused networks
    docker network prune -f
    
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Check status after update
check_status() {
    echo -e "${BLUE}🔍 Checking services status...${NC}"
    
    sleep 5  # Wait for services to start
    
    echo -e "${YELLOW}📊 Containers status:${NC}"
    $DOCKER_COMPOSE_CMD ps
    
    echo ""
    echo -e "${YELLOW}🌐 Connectivity test:${NC}"
    
    # Test n8n
    if command -v curl &> /dev/null; then
        DOMAIN=$(grep DOMAIN_NAME $PROJECT_ROOT/.env | cut -d '=' -f2)
        SUBDOMAIN=$(grep SUBDOMAIN $PROJECT_ROOT/.env | cut -d '=' -f2)
        
        if [[ -n "$DOMAIN" && -n "$SUBDOMAIN" ]]; then
            N8N_URL="https://$SUBDOMAIN.$DOMAIN"
            if curl -s -o /dev/null -w "%{http_code}" "$N8N_URL" | grep -q "200\|401\|302"; then
                echo -e "  n8n: ${GREEN}✅ Accessible${NC}"
            else
                echo -e "  n8n: ${RED}❌ Not accessible${NC}"
            fi
        fi
    fi
    
    echo ""
}

# Preventive backup
backup_before_update() {
    echo -e "${YELLOW}💾 Preventive backup recommended${NC}"
    read -p "Create backup before update? [Y/n]: " DO_BACKUP
    
    if [[ ! "$DO_BACKUP" =~ ^[Nn]$ ]]; then
        if [[ -f "backup.sh" ]]; then
            echo -e "${BLUE}📦 Creating backup...${NC}"
            ./backup.sh
        else
            echo -e "${RED}❌ backup.sh script not found${NC}"
            echo -e "${YELLOW}💾 Manual backup recommended${NC}"
            read -p "Continue without backup? [y/N]: " CONTINUE
            if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
                exit 0
            fi
        fi
    fi
}

# Main program
main() {
    # Check that we are in the right directory
    if [[ ! -f "$PROJECT_ROOT/docker-compose.yml" ]]; then
        echo -e "${RED}❌ docker-compose.yml file not found${NC}"
        echo -e "${YELLOW}💡 Run this script from the scripts folder of n8n-docker-caddy${NC}"
        exit 1
    fi
    
    # Move to root directory for Docker commands
    cd $PROJECT_ROOT
    
    # Display current versions
    show_current_versions
    
    # Propose backup
    backup_before_update
    
    # Choice of update type
    update_choice
    
    # Check status
    check_status
    
    # Propose cleanup
    echo ""
    read -p "Perform Docker cleanup? [y/N]: " DO_CLEANUP
    if [[ "$DO_CLEANUP" =~ ^[Yy]$ ]]; then
        cleanup_docker
    fi
    
    # Display new versions
    echo ""
    echo -e "${BLUE}🎉 Update completed!${NC}"
    show_current_versions
    
    # Post-update tips
    echo -e "${YELLOW}💡 Post-update tips:${NC}"
    echo "  • Check that your n8n workflows work"
    echo "  • Test Flowise access"
    echo "  • Monitor logs: $DOCKER_COMPOSE_CMD logs -f"
    
    if [[ -f "$PROJECT_ROOT/credentials.txt" ]]; then
        echo "  • Your credentials are in: credentials.txt"
    fi
    
    # Return to root directory to facilitate next steps
    cd $PROJECT_ROOT
}

# Check if launched with arguments
if [[ $# -gt 0 ]]; then
    case $1 in
        --n8n-only) update_n8n_only ;;
        --all) update_all ;;
        --recreate) update_recreate ;;
        --cleanup) cleanup_docker ;;
        --help|help)
            echo "Usage: $0 [option]"
            echo "Options:"
            echo "  --n8n-only    Update n8n only"
            echo "  --all         Update all services"
            echo "  --recreate    Recreate all containers"
            echo "  --cleanup     Docker cleanup only"
            echo "  --help        Show this help"
            exit 0
            ;;
        *) echo -e "${RED}❌ Unknown option: $1${NC}"; exit 1 ;;
    esac
else
    main
fi