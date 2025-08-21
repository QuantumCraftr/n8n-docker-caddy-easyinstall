#!/bin/bash
# 💾 Script de sauvegarde n8n-docker-caddy

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_ROOT=".."
BACKUP_DIR="$PROJECT_ROOT/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="n8n-backup-$DATE"

echo -e "${GREEN}💾 Démarrage de la sauvegarde...${NC}"

# Créer le dossier de sauvegarde
mkdir -p "$BACKUP_DIR"

# Fonction de sauvegarde d'un volume Docker
backup_volume() {
    local volume_name=$1
    local backup_file="$BACKUP_DIR/${BACKUP_NAME}_${volume_name}.tar.gz"
    
    echo -e "${YELLOW}📦 Sauvegarde du volume $volume_name...${NC}"
    
    if docker volume inspect "$volume_name" &>/dev/null; then
        # Exécuter depuis le répertoire racine pour assurer que les chemins Docker sont corrects
        (cd $PROJECT_ROOT && docker run --rm \
            -v "$volume_name":/data:ro \
            -v "$(pwd)/backups":/backup \
            alpine:latest \
            tar czf "/backup/${BACKUP_NAME}_${volume_name}.tar.gz" -C /data .)
        
        echo -e "${GREEN}✅ Volume $volume_name sauvegardé${NC}"
    else
        echo -e "${RED}❌ Volume $volume_name non trouvé${NC}"
    fi
}

# Sauvegarder la configuration
echo -e "${YELLOW}📝 Sauvegarde de la configuration...${NC}"
(cd $PROJECT_ROOT && tar czf "backups/${BACKUP_NAME}_config.tar.gz" \
    --exclude='backups' \
    --exclude='.git' \
    --exclude='*.log' \
    .)

# Sauvegarder les volumes Docker
# Exécuter les commandes Docker depuis le répertoire racine
cd $PROJECT_ROOT
backup_volume "n8n_data"
backup_volume "flowise_data"
backup_volume "caddy_data"

# Sauvegarder les volumes optionnels s'ils existent
backup_volume "grafana_data" 2>/dev/null || true
backup_volume "prometheus_data" 2>/dev/null || true
backup_volume "portainer_data" 2>/dev/null || true
backup_volume "uptime_data" 2>/dev/null || true

# Créer un fichier d'informations sur la sauvegarde
cat > "$BACKUP_DIR/${BACKUP_NAME}_info.txt" << EOF
🔍 INFORMATIONS DE SAUVEGARDE

📅 Date: $(date)
🖥️  Hostname: $(hostname)
📋 Compose file: $([ -f docker-compose.yml ] && echo "docker-compose.yml" || echo "Non trouvé")
🐳 Services actifs:
$(docker compose ps --format "- {{.Name}}: {{.Status}}" 2>/dev/null || echo "Impossible de lister les services")

📦 Volumes sauvegardés:
$(ls -1 $BACKUP_DIR/${BACKUP_NAME}_*.tar.gz | sed 's|.*/||' | sed 's/^/- /')

💾 Taille totale: $(du -sh $BACKUP_DIR/${BACKUP_NAME}_* | awk '{print $1}' | paste -sd+ | bc 2>/dev/null || echo "N/A") 

🔧 Pour restaurer:
cd scripts && ./restore.sh $BACKUP_NAME

EOF

# Nettoyer les anciennes sauvegardes (garder les 7 dernières)
echo -e "${YELLOW}🧹 Nettoyage des anciennes sauvegardes...${NC}"
find "$BACKUP_DIR" -name "n8n-backup-*" -type f -mtime +7 -delete 2>/dev/null || true

# Résumé
echo -e "${GREEN}✅ Sauvegarde terminée !${NC}"
echo -e "${YELLOW}📁 Fichiers créés:${NC}"
ls -la "$BACKUP_DIR/${BACKUP_NAME}"*

echo ""
echo -e "${GREEN}💡 Conseil: Copiez ces fichiers vers un stockage externe${NC}"
echo -e "${YELLOW}🔧 Restauration: cd scripts && ./restore.sh $BACKUP_NAME${NC}"

# Retourner au répertoire racine pour faciliter les prochaines étapes
cd $PROJECT_ROOT