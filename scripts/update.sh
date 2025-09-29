#!/bin/bash
# 🔄 n8n-docker-caddy Update Script

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

# Hybrid permission management for update operations
check_update_permissions() {
    local needs_sudo=false
    local reasons=()
    
    # Check Docker access
    if ! docker info &>/dev/null 2>&1; then
        if ! groups | grep -q docker; then
            needs_sudo=true
            reasons+=("Not in docker group - Docker commands may need sudo")
        fi
    fi
    
    # Update usually doesn't need file system writes, but check backup creation
    if [[ ! -w "$PROJECT_ROOT" ]]; then
        echo -e "${YELLOW}⚠️  Limited file system access - backup creation may fail${NC}"
    fi
    
    # If we need sudo, inform user
    if [[ "$needs_sudo" == true ]]; then
        echo -e "${YELLOW}⚠️  This script may require elevated permissions:${NC}"
        for reason in "${reasons[@]}"; do
            echo -e "   • $reason"
        done
        echo ""
        echo -e "${BLUE}💡 If Docker commands fail, try: ${GREEN}sudo $0 $@${NC}"
        echo ""
    fi
}

# Auto-fix permissions function (minimal for updates)
fix_permissions() {
    # Make all scripts executable
    chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
    
    return 0
}

# Run permission check
check_update_permissions "$@"
fix_permissions

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
    cd $PROJECT_ROOT
    
    # Check for active containers to determine which compose file is in use
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

echo -e "${BLUE}🔄 n8n-docker-caddy Update${NC}"
echo ""

# Function to display current versions
show_current_versions() {
    echo -e "${YELLOW}📋 Current versions:${NC}"
    
    # n8n
    if $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" ps n8n 2>/dev/null | grep -q "Up"; then
        N8N_VERSION=$($DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" exec -T n8n n8n --version 2>/dev/null || echo "N/A")
        echo -e "  n8n: ${GREEN}$N8N_VERSION${NC}"
    fi
    
    # Caddy
    if $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" ps caddy 2>/dev/null | grep -q "Up"; then
        CADDY_VERSION=$($DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" exec -T caddy caddy version 2>/dev/null || echo "N/A")
        echo -e "  Caddy: ${GREEN}$CADDY_VERSION${NC}"
    fi
    
    # Flowise
    if $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" ps flowise 2>/dev/null | grep -q "Up"; then
        FLOWISE_TAG=$($DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" images flowise --format "table {{.Tag}}" 2>/dev/null | tail -n +2 | head -1 || echo "N/A")
        echo -e "  Flowise: ${GREEN}$FLOWISE_TAG${NC}"
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
    
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" pull n8n
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" up -d n8n
    
    echo -e "${GREEN}✅ n8n updated!${NC}"
}

# Update all services
update_all() {
    echo -e "${BLUE}📦 Complete update...${NC}"
    
    # Download new images
    echo -e "${YELLOW}⬇️ Downloading new images...${NC}"
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" pull
    
    # Restart services
    echo -e "${YELLOW}🔄 Restarting services...${NC}"
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" up -d
    
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
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" pull
    
    # Stop services
    echo -e "${YELLOW}⏹️ Stopping services...${NC}"
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" down
    
    # Restart with recreation
    echo -e "${YELLOW}🚀 Recreating containers...${NC}"
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" up -d --force-recreate
    
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
    $DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" ps
    
    echo ""
    echo -e "${YELLOW}🌐 Connectivity test:${NC}"
    
    # Test n8n
    if command -v curl &> /dev/null; then
        if [[ -f "$PROJECT_ROOT/.env" ]]; then
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
    fi
    
    echo ""
}

# Preventive backup
backup_before_update() {
    echo -e "${YELLOW}💾 Preventive backup recommended${NC}"
    read -p "Create backup before update? [Y/n]: " DO_BACKUP
    
    if [[ ! "$DO_BACKUP" =~ ^[Nn]$ ]]; then
        if [[ -f "$SCRIPT_DIR/backup.sh" ]]; then
            echo -e "${BLUE}📦 Creating backup...${NC}"
            "$SCRIPT_DIR/backup.sh"
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
    # Check that we are in the right directory and find compose file
    COMPOSE_FILE=$(find_compose_file)
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ No docker-compose file found${NC}"
        echo -e "${YELLOW}💡 Available files in $PROJECT_ROOT:${NC}"
        ls -la "$PROJECT_ROOT"/docker-compose*.yml 2>/dev/null || echo "No docker-compose files found"
        echo -e "${YELLOW}💡 Run setup.sh first to create the configuration${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}📁 Using compose file: $COMPOSE_FILE${NC}"
    
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
    echo "  • Monitor logs: $DOCKER_COMPOSE_CMD -f $COMPOSE_FILE logs -f"
    
    if [[ -f "$PROJECT_ROOT/credentials.txt" ]]; then
        echo "  • Your credentials are in: credentials.txt"
    fi
    
    # Return to root directory to facilitate next steps
    cd $PROJECT_ROOT
}

# Check if launched with arguments
if [[ $# -gt 0 ]]; then
    # Find compose file for command line usage
    COMPOSE_FILE=$(find_compose_file)
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ No docker-compose file found${NC}"
        exit 1
    fi
    cd $PROJECT_ROOT
    
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