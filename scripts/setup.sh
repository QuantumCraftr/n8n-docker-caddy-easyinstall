#!/bin/bash
# 🚀 n8n-docker-caddy Interactive Setup
# Projet communautaire pour installer n8n facilement

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Chemin vers le répertoire parent (racine du projet)
PROJECT_ROOT=".."

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

echo -e "${GREEN}🎯 Installation n8n avec Docker & Caddy${NC}"
echo -e "${YELLOW}💡 Configuration automatisée pour débutants et experts${NC}"
echo ""

# Fonction pour générer un mot de passe sécurisé
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Vérification des prérequis
echo -e "${BLUE}🔍 Vérification des prérequis...${NC}"

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    echo -e "${YELLOW}📖 Suivez les instructions : https://docs.docker.com/get-docker/${NC}"
    exit 1
fi

# Vérifier Docker Compose
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé${NC}"
    echo -e "${YELLOW}📖 Suivez les instructions : https://docs.docker.com/compose/install/${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prérequis OK${NC}"
echo ""

# Configuration interactive
echo -e "${BLUE}📝 Configuration de votre installation${NC}"
echo ""

# Type d'installation
echo -e "${YELLOW}🛠️ Quel type d'installation souhaitez-vous ?${NC}"
echo "1) 🚀 Basique (n8n + Caddy + Flowise)"
echo "2) 📊 Complète (+ Monitoring Prometheus/Grafana)"
echo "3) 🔧 Pro (+ Portainer + Watchtower + Uptime Kuma)"
echo ""
read -p "Votre choix [1-3]: " INSTALL_TYPE

case $INSTALL_TYPE in
    1) INSTALL_LEVEL="basic" ;;
    2) INSTALL_LEVEL="monitoring" ;;
    3) INSTALL_LEVEL="pro" ;;
    *) echo -e "${RED}❌ Choix invalide${NC}"; exit 1 ;;
esac

echo ""

# Configuration du domaine
echo -e "${YELLOW}🌐 Configuration du domaine${NC}"
echo "Exemples: example.com, mon-domaine.fr, myserver.local"
read -p "Votre nom de domaine: " DOMAIN_NAME

if [[ -z "$DOMAIN_NAME" ]]; then
    echo -e "${RED}❌ Le nom de domaine est obligatoire${NC}"
    exit 1
fi

# Sous-domaines
echo ""
echo -e "${YELLOW}📡 Configuration des sous-domaines${NC}"
read -p "Sous-domaine pour n8n [automation]: " N8N_SUBDOMAIN
N8N_SUBDOMAIN=${N8N_SUBDOMAIN:-automation}

read -p "Sous-domaine pour Flowise [flowise]: " FLOWISE_SUBDOMAIN
FLOWISE_SUBDOMAIN=${FLOWISE_SUBDOMAIN:-flowise}

if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    read -p "Sous-domaine pour Grafana [monitoring]: " GRAFANA_SUBDOMAIN
    GRAFANA_SUBDOMAIN=${GRAFANA_SUBDOMAIN:-monitoring}
fi

if [[ "$INSTALL_LEVEL" == "pro" ]]; then
    read -p "Sous-domaine pour Portainer [portainer]: " PORTAINER_SUBDOMAIN
    PORTAINER_SUBDOMAIN=${PORTAINER_SUBDOMAIN:-portainer}
    
    read -p "Sous-domaine pour Uptime Kuma [uptime]: " UPTIME_SUBDOMAIN
    UPTIME_SUBDOMAIN=${UPTIME_SUBDOMAIN:-uptime}
fi

# Email pour SSL
echo ""
echo -e "${YELLOW}📧 Email pour les certificats SSL (Let's Encrypt)${NC}"
read -p "Votre email: " SSL_EMAIL

if [[ -z "$SSL_EMAIL" ]]; then
    echo -e "${RED}❌ L'email est obligatoire pour SSL${NC}"
    exit 1
fi

# Timezone
echo ""
echo -e "${YELLOW}🕐 Fuseau horaire${NC}"
echo "Exemples: Europe/Paris, America/New_York, Asia/Tokyo"
read -p "Timezone [Europe/Paris]: " TIMEZONE
TIMEZONE=${TIMEZONE:-Europe/Paris}

# Génération des mots de passe
echo ""
echo -e "${YELLOW}🔐 Génération des mots de passe sécurisés...${NC}"

N8N_PASSWORD=$(generate_password)
FLOWISE_PASSWORD=$(generate_password)
GRAFANA_PASSWORD=$(generate_password)

echo -e "${GREEN}✅ Mots de passe générés${NC}"

# Résumé de la configuration
echo ""
echo -e "${BLUE}📋 Résumé de votre configuration:${NC}"
echo -e "🌐 Domaine: ${GREEN}$DOMAIN_NAME${NC}"
echo -e "🚀 n8n: ${GREEN}https://$N8N_SUBDOMAIN.$DOMAIN_NAME${NC}"
echo -e "🤖 Flowise: ${GREEN}https://$FLOWISE_SUBDOMAIN.$DOMAIN_NAME${NC}"

if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    echo -e "📊 Grafana: ${GREEN}https://$GRAFANA_SUBDOMAIN.$DOMAIN_NAME${NC}"
fi

if [[ "$INSTALL_LEVEL" == "pro" ]]; then
    echo -e "🐳 Portainer: ${GREEN}https://$PORTAINER_SUBDOMAIN.$DOMAIN_NAME${NC}"
    echo -e "📈 Uptime Kuma: ${GREEN}https://$UPTIME_SUBDOMAIN.$DOMAIN_NAME${NC}"
fi

echo -e "📧 Email SSL: ${GREEN}$SSL_EMAIL${NC}"
echo -e "🕐 Timezone: ${GREEN}$TIMEZONE${NC}"
echo ""

read -p "Continuer avec cette configuration? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⏹️ Installation annulée${NC}"
    exit 0
fi

# Création des fichiers de configuration
echo ""
echo -e "${BLUE}🔧 Création des fichiers de configuration...${NC}"

# Création du répertoire caddy_config si nécessaire
mkdir -p $PROJECT_ROOT/caddy_config

# Génération du .env
cat > $PROJECT_ROOT/.env << EOF
# 🌐 Configuration du domaine
DATA_FOLDER=.
DOMAIN_NAME=$DOMAIN_NAME
SUBDOMAIN=$N8N_SUBDOMAIN
GENERIC_TIMEZONE=$TIMEZONE
SSL_EMAIL=$SSL_EMAIL

# 🔐 Authentification n8n
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD

# 🤖 Flowise
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=$FLOWISE_PASSWORD

# 📊 Grafana (si installé)
GRAFANA_PASSWORD=$GRAFANA_PASSWORD

# 🔄 Watchtower notifications (optionnel)
# GMAIL_USER=your-email@gmail.com
# GMAIL_APP_PASSWORD=your-app-password
EOF

# Génération du Caddyfile
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

# Ajout des services selon le niveau d'installation
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

# Génération du docker-compose.yml selon le niveau
case $INSTALL_LEVEL in
    "basic")
        cp $PROJECT_ROOT/docker-compose-basic.yml $PROJECT_ROOT/docker-compose.yml
        ;;
    "monitoring")
        cp $PROJECT_ROOT/docker-compose-monitoring.yml $PROJECT_ROOT/docker-compose.yml
        ;;
    "pro")
        cp $PROJECT_ROOT/docker-compose-pro.yml $PROJECT_ROOT/docker-compose.yml
        ;;
esac

# Création des volumes Docker
echo -e "${BLUE}🐳 Création des volumes Docker...${NC}"

# Exécuter les commandes Docker depuis le répertoire racine
cd $PROJECT_ROOT
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

echo -e "${GREEN}✅ Volumes créés${NC}"

# Configuration du firewall (si ufw est disponible)
if command -v ufw &> /dev/null; then
    echo -e "${BLUE}🛡️ Configuration du firewall...${NC}"
    
    read -p "Configurer le firewall UFW? [y/N]: " SETUP_FIREWALL
    if [[ "$SETUP_FIREWALL" =~ ^[Yy]$ ]]; then
        sudo ufw allow 22/tcp  # SSH
        sudo ufw allow 80/tcp  # HTTP
        sudo ufw allow 443/tcp # HTTPS
        sudo ufw --force enable
        echo -e "${GREEN}✅ Firewall configuré${NC}"
    fi
fi

# Sauvegarde des credentials
echo ""
echo -e "${BLUE}📋 Création du fichier credentials.txt...${NC}"

cat > $PROJECT_ROOT/credentials.txt << EOF
🔐 CREDENTIALS DE VOTRE INSTALLATION n8n

🌐 URLs d'accès:
- n8n: https://$N8N_SUBDOMAIN.$DOMAIN_NAME
- Flowise: https://$FLOWISE_SUBDOMAIN.$DOMAIN_NAME
EOF

if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    cat >> $PROJECT_ROOT/credentials.txt << EOF
- Grafana: https://$GRAFANA_SUBDOMAIN.$DOMAIN_NAME
EOF
fi

if [[ "$INSTALL_LEVEL" == "pro" ]]; then
    cat >> $PROJECT_ROOT/credentials.txt << EOF
- Portainer: https://$PORTAINER_SUBDOMAIN.$DOMAIN_NAME
- Uptime Kuma: https://$UPTIME_SUBDOMAIN.$DOMAIN_NAME
EOF
fi

cat >> $PROJECT_ROOT/credentials.txt << EOF

🔑 Identifiants:
- n8n: admin / $N8N_PASSWORD
- Flowise: admin / $FLOWISE_PASSWORD
EOF

if [[ "$INSTALL_LEVEL" != "basic" ]]; then
    cat >> $PROJECT_ROOT/credentials.txt << EOF
- Grafana: admin / $GRAFANA_PASSWORD
EOF
fi

cat >> $PROJECT_ROOT/credentials.txt << EOF

⚠️  IMPORTANT: 
1. Sauvegardez ce fichier dans un endroit sûr
2. Supprimez ce fichier du serveur après sauvegarde
3. Les mots de passe sont aussi dans le fichier .env

🚀 Commandes utiles:
- Démarrer: docker compose up -d
- Arrêter: docker compose down
- Logs: docker compose logs -f
- Mise à jour: ./update.sh

EOF

echo -e "${GREEN}✅ Configuration terminée!${NC}"
echo ""
echo -e "${YELLOW}📋 Informations importantes sauvegardées dans credentials.txt${NC}"
echo -e "${RED}⚠️  LISEZ le fichier credentials.txt et sauvegardez-le !${NC}"
echo ""
echo -e "${BLUE}🚀 Étapes suivantes:${NC}"
echo "1. Vérifiez que vos DNS pointent vers ce serveur"
echo "2. Retournez au répertoire racine: ${GREEN}cd ..${NC}"
echo "3. Lancez l'installation: ${GREEN}docker compose up -d${NC}"
echo "4. Attendez 2-3 minutes que les certificats SSL se génèrent"
echo "5. Accédez à vos services via les URLs indiquées"
echo ""
echo -e "${GREEN}✨ Installation configurée avec succès !${NC}"

# Retourner au répertoire racine pour faciliter les prochaines étapes
cd $PROJECT_ROOT