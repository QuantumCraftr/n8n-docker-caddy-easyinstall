#!/bin/bash
# 🚀 n8n-docker-caddy Interactive Setup
# Community project for easy n8n installation

set -e

# Ensure all scripts are executable
chmod +x scripts/*.sh 2>/dev/null || true

# Colors for display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Path to parent directory (project root)
PROJECT_ROOT=".."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}"
cat << "EOF"
    ███╗   ██╗ █████╗ ███╗   ██╗    ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗ 
    ████╗  ██║██╔══██╗████╗  ██║    ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
    ██╔██╗ ██║╚█████╔╝██╔██╗ ██║    ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝
    ██║╚██╗██║██╔══██╗██║╚██╗██║    ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
    ██║ ╚████║╚█████╔╝██║ ╚████║    ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║
    ╚═╝  ╚═══╝ ╚════╝ ╚═╝  ╚═══╝    ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${NC}"

echo -e "${GREEN}🎯 n8n Installation with Docker & Caddy${NC}"
echo -e "${YELLOW}💡 Automated setup for beginners and experts${NC}"
echo ""

# Function to generate a secure password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Prerequisites check
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo -e "${YELLOW}📖 Follow instructions: https://docs.docker.com/get-docker/${NC}"
    exit 1
fi

# Function to install Docker Compose v2
install_docker_compose_v2() {
    echo -e "${BLUE}🔧 Installing Docker Compose v2...${NC}"
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
        mkdir -p $DOCKER_CONFIG/cli-plugins
        
        # Get latest version
        LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        
        echo -e "${YELLOW}📥 Downloading Docker Compose $LATEST_VERSION...${NC}"
        curl -SL "https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-linux-x86_64" -o $DOCKER_CONFIG/cli-plugins/docker-compose
        chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
        
        echo -e "${GREEN}✅ Docker Compose v2 installed successfully!${NC}"
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - usually comes with Docker Desktop
        echo -e "${YELLOW}ℹ️  On macOS, update Docker Desktop to get Docker Compose v2${NC}"
        echo -e "${BLUE}📖 Download from: https://www.docker.com/products/docker-desktop${NC}"
        
    else
        echo -e "${YELLOW}⚠️  Please install Docker Compose v2 manually for your OS${NC}"
        echo -e "${BLUE}📖 Instructions: https://docs.docker.com/compose/install/linux/${NC}"
    fi
}

# Check Docker Compose and determine version
DOCKER_COMPOSE_CMD=""

if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    # Docker Compose v2 (integrated with Docker)
    DOCKER_COMPOSE_CMD="docker compose"
    COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✅ Docker Compose v2 detected (version: $COMPOSE_VERSION)${NC}"
    
elif command -v docker-compose &> /dev/null; then
    # Docker Compose v1 (standalone)
    COMPOSE_VERSION=$(docker-compose version --short 2>/dev/null || echo "unknown")
    echo -e "${YELLOW}⚠️  Docker Compose v1 detected (version: $COMPOSE_VERSION)${NC}"
    echo -e "${BLUE}💡 Docker Compose v2 is recommended for better performance and features${NC}"
    echo ""
    read -p "Would you like to install Docker Compose v2? [Y/n]: " INSTALL_V2
    
    if [[ ! "$INSTALL_V2" =~ ^[Nn]$ ]]; then
        install_docker_compose_v2
        
        # Re-check after installation
        if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
            DOCKER_COMPOSE_CMD="docker compose"
            echo -e "${GREEN}✅ Now using Docker Compose v2${NC}"
        else
            echo -e "${YELLOW}⚠️  Falling back to Docker Compose v1${NC}"
            DOCKER_COMPOSE_CMD="docker-compose"
        fi
    else
        DOCKER_COMPOSE_CMD="docker-compose"
        echo -e "${YELLOW}⏭️  Continuing with Docker Compose v1${NC}"
    fi
    
else
    # No Docker Compose found
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo ""
    read -p "Would you like to install Docker Compose v2? [Y/n]: " INSTALL_COMPOSE
    
    if [[ ! "$INSTALL_COMPOSE" =~ ^[Nn]$ ]]; then
        install_docker_compose_v2
        
        # Check if installation was successful
        if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
            DOCKER_COMPOSE_CMD="docker compose"
            echo -e "${GREEN}✅ Docker Compose v2 installed and ready!${NC}"
        else
            echo -e "${RED}❌ Installation failed. Please install Docker Compose manually${NC}"
            echo -e "${YELLOW}📖 Instructions: https://docs.docker.com/compose/install/${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Docker Compose is required for this installation${NC}"
        echo -e "${YELLOW}📖 Follow instructions: https://docs.docker.com/compose/install/${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Prerequisites OK${NC}"
echo -e "${BLUE}🐳 Using command: ${GREEN}$DOCKER_COMPOSE_CMD${NC}"
echo ""

# Interactive configuration
echo -e "${BLUE}📝 Configure your installation${NC}"
echo ""

# Installation type
echo -e "${YELLOW}🛠️ What type of installation do you want?${NC}"
echo "1) 🚀 Basic (n8n + Caddy + Flowise)"
echo "2) 📊 Complete (+ Monitoring Prometheus/Grafana)"
echo "3) 🔧 Pro (+ Portainer + Watchtower + Uptime Kuma)"
echo ""
read -p "Your choice [1-3]: " INSTALL_TYPE

case $INSTALL_TYPE in
    1) INSTALL_LEVEL="basic" ;;
    2) INSTALL_LEVEL="monitoring" ;;
    3) INSTALL_LEVEL="pro" ;;
    *) echo -e "${RED}❌ Invalid choice${NC}"; exit 1 ;;
esac

echo ""

# Domain configuration
echo -e "${YELLOW}🌐 Domain configuration${NC}"
echo "Examples: example.com, my-domain.fr, myserver.local"
read -p "Your domain name: " DOMAIN_NAME

if [[ -z "$DOMAIN_NAME" ]]; then
    echo -e "${RED}❌ Domain name is required${NC}"
    exit 1
fi

# Subdomains
echo ""
echo -e "${YELLOW}📡 Subdomains configuration${NC}"
read -p "Subdomain for n8n [automation]: " N8N_SUBDOMAIN
N8N_SUBDOMAIN=${N8N_SUBDOMAIN:-automation}

read -p "Subdomain for Flowise [flowise]: " FLOWISE_SUBDOMAIN
FLOWISE_SUBDOMAIN=${FLOWISE_SUBDOMAIN:-flowise}

if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    read -p "Subdomain for Grafana [monitoring]: " GRAFANA_SUBDOMAIN
    GRAFANA_SUBDOMAIN=${GRAFANA_SUBDOMAIN:-monitoring}
fi

if [[ "$INSTALL_LEVEL" == "pro" ]]; then
    read -p "Subdomain for Portainer [portainer]: " PORTAINER_SUBDOMAIN
    PORTAINER_SUBDOMAIN=${PORTAINER_SUBDOMAIN:-portainer}
    
    read -p "Subdomain for Uptime Kuma [uptime]: " UPTIME_SUBDOMAIN
    UPTIME_SUBDOMAIN=${UPTIME_SUBDOMAIN:-uptime}
fi

# Email for SSL
echo ""
echo -e "${YELLOW}📧 Email for SSL certificates (Let's Encrypt)${NC}"
read -p "Your email: " SSL_EMAIL

if [[ -z "$SSL_EMAIL" ]]; then
    echo -e "${RED}❌ Email is required for SSL${NC}"
    exit 1
fi

# Timezone
echo ""
echo -e "${YELLOW}🕐 Timezone${NC}"
echo "Examples: Europe/Paris, America/New_York, Asia/Tokyo"
read -p "Timezone [Europe/Paris]: " TIMEZONE
TIMEZONE=${TIMEZONE:-Europe/Paris}

# Password generation
echo ""
echo -e "${YELLOW}🔐 Generating secure passwords...${NC}"

N8N_PASSWORD=$(generate_password)
FLOWISE_PASSWORD=$(generate_password)
GRAFANA_PASSWORD=$(generate_password)

echo -e "${GREEN}✅ Passwords generated${NC}"

# Configuration summary
echo ""
echo -e "${BLUE}📋 Configuration summary:${NC}"
echo -e "🌐 Domain: ${GREEN}$DOMAIN_NAME${NC}"
echo -e "🚀 n8n: ${GREEN}https://$N8N_SUBDOMAIN.$DOMAIN_NAME${NC}"
echo -e "🤖 Flowise: ${GREEN}https://$FLOWISE_SUBDOMAIN.$DOMAIN_NAME${NC}"

if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    echo -e "📊 Grafana: ${GREEN}https://$GRAFANA_SUBDOMAIN.$DOMAIN_NAME${NC}"
fi

if [[ "$INSTALL_LEVEL" == "pro" ]]; then
    echo -e "🐳 Portainer: ${GREEN}https://$PORTAINER_SUBDOMAIN.$DOMAIN_NAME${NC}"
    echo -e "📈 Uptime Kuma: ${GREEN}https://$UPTIME_SUBDOMAIN.$DOMAIN_NAME${NC}"
fi

echo -e "📧 SSL Email: ${GREEN}$SSL_EMAIL${NC}"
echo -e "🕐 Timezone: ${GREEN}$TIMEZONE${NC}"
echo ""

read -p "Continue with this configuration? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⏹️ Installation cancelled${NC}"
    exit 0
fi

# Creating configuration files
echo ""
echo -e "${BLUE}🔧 Creating configuration files...${NC}"

# Create caddy_config directory if needed
mkdir -p $PROJECT_ROOT/caddy_config

# Generate .env file
cat > $PROJECT_ROOT/.env << EOF
# 🌐 Domain configuration
DATA_FOLDER=.
DOMAIN_NAME=$DOMAIN_NAME
SUBDOMAIN=$N8N_SUBDOMAIN
GENERIC_TIMEZONE=$TIMEZONE
SSL_EMAIL=$SSL_EMAIL

# 🔐 n8n Authentication
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD

# 🤖 Flowise
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=$FLOWISE_PASSWORD

# 📊 Grafana (if installed)
GRAFANA_PASSWORD=$GRAFANA_PASSWORD

# 🔄 Watchtower notifications (optional)
# GMAIL_USER=your-email@gmail.com
# GMAIL_APP_PASSWORD=your-app-password
EOF

# Generate Caddyfile
cat > $PROJECT_ROOT/caddy_config/Caddyfile << EOF
$N8N_SUBDOMAIN.$DOMAIN_NAME {
    reverse_proxy n8n:5678 {
        flush_interval -1
    }
}

$FLOWISE_SUBDOMAIN.$DOMAIN_NAME {
    reverse_proxy flowise:3000 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
    }
}
EOF

# Add services according to installation level
if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    cat >> $PROJECT_ROOT/caddy_config/Caddyfile << EOF

$GRAFANA_SUBDOMAIN.$DOMAIN_NAME {
    reverse_proxy grafana:3000
}
EOF
fi

if [[ "$INSTALL_LEVEL" == "pro" ]]; then
    cat >> $PROJECT_ROOT/caddy_config/Caddyfile << EOF

$PORTAINER_SUBDOMAIN.$DOMAIN_NAME {
    reverse_proxy portainer:9443 {
        transport http {
            tls_insecure_skip_verify
        }
    }
}

$UPTIME_SUBDOMAIN.$DOMAIN_NAME {
    reverse_proxy uptime-kuma:3001
}
EOF
fi

# Set the appropriate Docker Compose file based on level
case $INSTALL_LEVEL in
    "basic")
        COMPOSE_FILE="docker-compose-basic.yml"
        ;;
    "monitoring")
        COMPOSE_FILE="docker-compose-monitoring.yml"
        ;;
    "pro")
        COMPOSE_FILE="docker-compose-pro.yml"
        ;;
esac

# Create Docker volumes
echo -e "${BLUE}🐳 Creating Docker volumes...${NC}"

# Execute Docker commands from root directory
cd $PROJECT_ROOT

# Check if Docker is working before creating volumes
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running or accessible${NC}"
    echo -e "${YELLOW}💡 Try: sudo systemctl start docker${NC}"
    exit 1
fi

docker volume create caddy_data 2>/dev/null || true
docker volume create n8n_data 2>/dev/null || true
docker volume create flowise_data 2>/dev/null || true

if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    docker volume create grafana_data 2>/dev/null || true
    docker volume create prometheus_data 2>/dev/null || true
fi

if [[ "$INSTALL_LEVEL" == "pro" ]]; then
    docker volume create portainer_data 2>/dev/null || true
    docker volume create uptime_data 2>/dev/null || true
fi

echo -e "${GREEN}✅ Volumes created${NC}"

# Firewall configuration (if ufw is available)
if command -v ufw &> /dev/null; then
    echo -e "${BLUE}🛡️ Firewall configuration...${NC}"
    
    read -p "Configure UFW firewall? [y/N]: " SETUP_FIREWALL
    if [[ "$SETUP_FIREWALL" =~ ^[Yy]$ ]]; then
        sudo ufw allow 22/tcp  # SSH
        sudo ufw allow 80/tcp  # HTTP
        sudo ufw allow 443/tcp # HTTPS
        sudo ufw --force enable
        echo -e "${GREEN}✅ Firewall configured${NC}"
    fi
fi

# Save credentials
echo ""
echo -e "${BLUE}📋 Creating credentials.txt file...${NC}"

# Build credentials content in one go
CREDENTIALS_CONTENT="🔐 YOUR n8n INSTALLATION CREDENTIALS

🌐 Access URLs:
- n8n: https://$N8N_SUBDOMAIN.$DOMAIN_NAME
- Flowise: https://$FLOWISE_SUBDOMAIN.$DOMAIN_NAME"

# Add conditional URLs
if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    CREDENTIALS_CONTENT="$CREDENTIALS_CONTENT
- Grafana: https://$GRAFANA_SUBDOMAIN.$DOMAIN_NAME"
fi

if [[ "$INSTALL_LEVEL" == "pro" ]]; then
    CREDENTIALS_CONTENT="$CREDENTIALS_CONTENT
- Portainer: https://$PORTAINER_SUBDOMAIN.$DOMAIN_NAME
- Uptime Kuma: https://$UPTIME_SUBDOMAIN.$DOMAIN_NAME"
fi

# Add login credentials
CREDENTIALS_CONTENT="$CREDENTIALS_CONTENT

🔑 Login credentials:
- n8n: admin / $N8N_PASSWORD
- Flowise: admin / $FLOWISE_PASSWORD"

# Add conditional credentials
if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    CREDENTIALS_CONTENT="$CREDENTIALS_CONTENT
- Grafana: admin / $GRAFANA_PASSWORD"
fi

# Add final instructions
CREDENTIALS_CONTENT="$CREDENTIALS_CONTENT

⚠️  IMPORTANT: 
1. Save this file in a secure location
2. Delete this file from the server after backup
3. Passwords are also stored in the .env file

🚀 Useful commands:
- Start: $DOCKER_COMPOSE_CMD -f $COMPOSE_FILE up -d
- Stop: $DOCKER_COMPOSE_CMD -f $COMPOSE_FILE down
- Logs: $DOCKER_COMPOSE_CMD -f $COMPOSE_FILE logs -f
- Restart: $DOCKER_COMPOSE_CMD -f $COMPOSE_FILE restart
- Update: cd scripts && ./update.sh
- Backup: cd scripts && ./backup.sh
"

# Write the complete content in one operation
echo "$CREDENTIALS_CONTENT" > "$PROJECT_ROOT/credentials.txt"

# Verify file was created successfully
if [[ -f "$PROJECT_ROOT/credentials.txt" ]]; then
    echo -e "${GREEN}✅ credentials.txt created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create credentials.txt${NC}"
    echo -e "${YELLOW}💡 Check directory permissions: ls -la $PROJECT_ROOT${NC}"
fi

echo -e "${GREEN}✅ Configuration completed!${NC}"
echo ""
echo -e "${YELLOW}📋 Important information saved in credentials.txt${NC}"
echo -e "${RED}⚠️  READ the credentials.txt file and save it!${NC}"
echo ""

# Propose to display credentials
read -p "Display your credentials now? [Y/n]: " SHOW_CREDENTIALS
if [[ ! "$SHOW_CREDENTIALS" =~ ^[Nn]$ ]]; then
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}📋 YOUR GENERATED CREDENTIALS${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    cat "$PROJECT_ROOT/credentials.txt"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}🔴 SECURITY REMINDER:${NC}"
    echo -e "${YELLOW}1. 📷 Screenshot or copy these credentials to a safe place${NC}"
    echo -e "${YELLOW}2. 🗑️  Delete credentials.txt after saving: ${GREEN}rm credentials.txt${NC}"
    echo -e "${YELLOW}3. 🔐 Passwords are also stored in .env file${NC}"
    echo ""
    read -p "Press Enter to continue..."
fi
echo ""

# Information about optional Grafana setup
if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    echo -e "${BLUE}📊 Optional: Enhanced Monitoring Setup${NC}"
    echo "After starting your services, you can configure advanced Grafana dashboards"
    echo "with system metrics by running the grafana setup script."
    echo ""
    echo -e "${YELLOW}💡 After installation: ${GREEN}cd scripts && ./grafana_setup.sh${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Next steps:${NC}"
echo "1. Verify that your DNS points to this server"
echo -e "2. Go back to root directory: ${GREEN}cd \"$PROJECT_ROOT\"${NC}"
echo -e "3. Start the installation: ${GREEN}$DOCKER_COMPOSE_CMD -f $COMPOSE_FILE up -d${NC}"
echo "4. Wait 2-3 minutes for SSL certificates to be generated"
echo "5. Access your services via the URLs provided"

if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    echo -e "6. ${YELLOW}Optional:${NC} Enhanced monitoring: ${GREEN}cd scripts && ./grafana_setup.sh${NC}"
fi

echo ""
echo -e "${YELLOW}💡 To manage your installation:${NC}"
echo -e "   - View logs: ${GREEN}$DOCKER_COMPOSE_CMD -f $COMPOSE_FILE logs -f${NC}"
echo -e "   - Stop services: ${GREEN}$DOCKER_COMPOSE_CMD -f $COMPOSE_FILE down${NC}"
echo -e "   - Restart: ${GREEN}$DOCKER_COMPOSE_CMD -f $COMPOSE_FILE restart${NC}"
echo ""
echo -e "${BLUE}📋 Your Docker Compose command: ${GREEN}$DOCKER_COMPOSE_CMD${NC}"
echo ""
echo -e "${GREEN}✨ Installation configured successfully!${NC}"
echo ""
echo -e "${RED}🔴 FINAL SECURITY REMINDER:${NC}"
echo -e "${YELLOW}Don't forget to delete credentials.txt after installation: ${GREEN}rm credentials.txt${NC}"

# Return to root directory to facilitate next steps
cd "$PROJECT_ROOT"