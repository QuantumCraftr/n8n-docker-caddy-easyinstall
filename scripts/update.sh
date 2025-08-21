#!/bin/bash
# 🔄 Script de mise à jour n8n-docker-caddy

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Chemin vers le répertoire parent (racine du projet)
PROJECT_ROOT=".."

echo -e "${BLUE}🔄 Mise à jour n8n-docker-caddy${NC}"
echo ""

# Fonction pour afficher les versions actuelles
show_current_versions() {
    echo -e "${YELLOW}📋 Versions actuelles:${NC}"
    
    # n8n
    if docker compose ps n8n | grep -q "Up"; then
        N8N_VERSION=$(docker compose exec -T n8n n8n --version 2>/dev/null || echo "N/A")
        echo -e "  n8n: ${GREEN}$N8N_VERSION${NC}"
    fi
    
    # Caddy
    if docker compose ps caddy | grep -q "Up"; then
        CADDY_VERSION=$(docker compose exec -T caddy caddy version 2>/dev/null || echo "N/A")
        echo -e "  Caddy: ${GREEN}$CADDY_VERSION${NC}"
    fi
    
    # Flowise
    if docker compose ps flowise | grep -q "Up"; then
        echo -e "  Flowise: ${GREEN}$(docker compose images flowise --format "{{.Tag}}")${NC}"
    fi
    
    echo ""
}

# Fonction de mise à jour avec choix
update_choice() {
    echo -e "${YELLOW}🎯 Type de mise à jour:${NC}"
    echo "1) 🚀 Rapide (n8n seulement)"
    echo "2) 📦 Complète (tous les services)"
    echo "3) 🔧 Avec recreation des conteneurs"
    echo "4) ❌ Annuler"
    echo ""
    read -p "Votre choix [1-4]: " UPDATE_TYPE
    
    case $UPDATE_TYPE in
        1) update_n8n_only ;;
        2) update_all ;;
        3) update_recreate ;;
        4) echo -e "${YELLOW}⏹️ Mise à jour annulée${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Choix invalide${NC}"; exit 1 ;;
    esac
}

# Mise à jour n8n seulement
update_n8n_only() {
    echo -e "${BLUE}🚀 Mise à jour rapide de n8n...${NC}"
    
    docker compose pull n8n
    docker compose up -d n8n
    
    echo -e "${GREEN}✅ n8n mis à jour !${NC}"
}

# Mise à jour de tous les services
update_all() {
    echo -e "${BLUE}📦 Mise à jour complète...${NC}"
    
    # Télécharger les nouvelles images
    echo -e "${YELLOW}⬇️ Téléchargement des nouvelles images...${NC}"
    docker compose pull
    
    # Redémarrer les services
    echo -e "${YELLOW}🔄 Redémarrage des services...${NC}"
    docker compose up -d
    
    echo -e "${GREEN}✅ Tous les services mis à jour !${NC}"
}

# Mise à jour avec recréation
update_recreate() {
    echo -e "${BLUE}🔧 Mise à jour avec recréation...${NC}"
    echo -e "${RED}⚠️ Cette opération va recréer tous les conteneurs${NC}"
    
    read -p "Continuer? [y/N]: " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏹️ Opération annulée${NC}"
        exit 0
    fi
    
    # Télécharger les nouvelles images
    echo -e "${YELLOW}⬇️ Téléchargement des nouvelles images...${NC}"
    docker compose pull
    
    # Arrêter les services
    echo -e "${YELLOW}⏹️ Arrêt des services...${NC}"
    docker compose down
    
    # Redémarrer avec recréation
    echo -e "${YELLOW}🚀 Recréation des conteneurs...${NC}"
    docker compose up -d --force-recreate
    
    echo -e "${GREEN}✅ Mise à jour complète terminée !${NC}"
}

# Fonction de nettoyage
cleanup_docker() {
    echo -e "${YELLOW}🧹 Nettoyage Docker...${NC}"
    
    # Images inutilisées
    docker image prune -f
    
    # Volumes anonymes
    docker volume prune -f
    
    # Réseaux inutilisés
    docker network prune -f
    
    echo -e "${GREEN}✅ Nettoyage terminé${NC}"
}

# Vérifier l'état après mise à jour
check_status() {
    echo -e "${BLUE}🔍 Vérification de l'état des services...${NC}"
    
    sleep 5  # Attendre que les services démarrent
    
    echo -e "${YELLOW}📊 État des conteneurs:${NC}"
    docker compose ps
    
    echo ""
    echo -e "${YELLOW}🌐 Test de connectivité:${NC}"
    
    # Tester n8n
    if command -v curl &> /dev/null; then
        DOMAIN=$(grep DOMAIN_NAME $PROJECT_ROOT/.env | cut -d '=' -f2)
        SUBDOMAIN=$(grep SUBDOMAIN $PROJECT_ROOT/.env | cut -d '=' -f2)
        
        if [[ -n "$DOMAIN" && -n "$SUBDOMAIN" ]]; then
            N8N_URL="https://$SUBDOMAIN.$DOMAIN"
            if curl -s -o /dev/null -w "%{http_code}" "$N8N_URL" | grep -q "200\|401\|302"; then
                echo -e "  n8n: ${GREEN}✅ Accessible${NC}"
            else
                echo -e "  n8n: ${RED}❌ Non accessible${NC}"
            fi
        fi
    fi
    
    echo ""
}

# Sauvegarde préventive
backup_before_update() {
    echo -e "${YELLOW}💾 Sauvegarde préventive recommandée${NC}"
    read -p "Faire une sauvegarde avant la mise à jour? [Y/n]: " DO_BACKUP
    
    if [[ ! "$DO_BACKUP" =~ ^[Nn]$ ]]; then
        if [[ -f "backup.sh" ]]; then
            echo -e "${BLUE}📦 Création de la sauvegarde...${NC}"
            ./backup.sh
        else
            echo -e "${RED}❌ Script backup.sh non trouvé${NC}"
            echo -e "${YELLOW}💾 Sauvegarde manuelle recommandée${NC}"
            read -p "Continuer sans sauvegarde? [y/N]: " CONTINUE
            if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
                exit 0
            fi
        fi
    fi
}

# Programme principal
main() {
    # Vérifier que nous sommes dans le bon dossier
    if [[ ! -f "$PROJECT_ROOT/docker-compose.yml" ]]; then
        echo -e "${RED}❌ Fichier docker-compose.yml non trouvé${NC}"
        echo -e "${YELLOW}💡 Exécutez ce script depuis le dossier scripts de n8n-docker-caddy${NC}"
        exit 1
    fi
    
    # Se déplacer dans le répertoire racine pour les commandes Docker
    cd $PROJECT_ROOT
    
    # Afficher les versions actuelles
    show_current_versions
    
    # Proposer une sauvegarde
    backup_before_update
    
    # Choix du type de mise à jour
    update_choice
    
    # Vérifier l'état
    check_status
    
    # Proposer le nettoyage
    echo ""
    read -p "Faire le nettoyage Docker? [y/N]: " DO_CLEANUP
    if [[ "$DO_CLEANUP" =~ ^[Yy]$ ]]; then
        cleanup_docker
    fi
    
    # Afficher les nouvelles versions
    echo ""
    echo -e "${BLUE}🎉 Mise à jour terminée !${NC}"
    show_current_versions
    
    # Conseils post-mise à jour
    echo -e "${YELLOW}💡 Conseils post-mise à jour:${NC}"
    echo "  • Vérifiez que vos workflows n8n fonctionnent"
    echo "  • Testez l'accès à Flowise"
    echo "  • Surveillez les logs: docker compose logs -f"
    
    if [[ -f "$PROJECT_ROOT/credentials.txt" ]]; then
        echo "  • Vos identifiants sont dans: credentials.txt"
    fi
    
    # Retourner au répertoire racine pour faciliter les prochaines étapes
    cd $PROJECT_ROOT
}

# Vérifier si lancé avec des arguments
if [[ $# -gt 0 ]]; then
    case $1 in
        --n8n-only) update_n8n_only ;;
        --all) update_all ;;
        --recreate) update_recreate ;;
        --cleanup) cleanup_docker ;;
        --help|help)
            echo "Usage: $0 [option]"
            echo "Options:"
            echo "  --n8n-only    Mettre à jour n8n seulement"
            echo "  --all         Mettre à jour tous les services"
            echo "  --recreate    Recréer tous les conteneurs"
            echo "  --cleanup     Nettoyer Docker seulement"
            echo "  --help        Afficher cette aide"
            exit 0
            ;;
        *) echo -e "${RED}❌ Option inconnue: $1${NC}"; exit 1 ;;
    esac
else
    main
fi