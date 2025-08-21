# 🚀 n8n-docker-caddy Community Edition

> **Installation n8n simplifiée avec Docker et Caddy - SSL automatique et configuration en 5 minutes !**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://docker.com)
[![n8n](https://img.shields.io/badge/n8n-Latest-orange)](https://n8n.io)
[![SSL](https://img.shields.io/badge/SSL-Auto--Generated-green)](https://letsencrypt.org)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

## ✨ Fonctionnalités

🎯 **Installation guidée interactive**
- Configuration automatique en quelques questions
- Génération de mots de passe sécurisés
- Support multi-niveaux (Basique → Pro)

🔐 **Sécurité intégrée**
- SSL automatique avec Let's Encrypt
- Authentification activée par défaut
- Firewall configuré automatiquement

🚀 **Services inclus**
- **n8n**: Automation workflow
- **Flowise**: IA conversationnelle
- **Caddy**: Reverse proxy avec SSL
- **Grafana + Prometheus**: Monitoring (option)
- **Portainer**: Gestion Docker (option)
- **Watchtower**: Mise à jour automatique (option)
- **Uptime Kuma**: Surveillance des services (option)

## 🛠️ Installation rapide

### Prérequis

- Serveur Linux (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- Docker & Docker Compose installés
- Nom de domaine pointant vers votre serveur
- Ports 80 et 443 ouverts

### Installation en 1 commande

```bash
git clone https://github.com/QuantumCraftr/n8n-docker-caddy.git
cd n8n-docker-caddy
cd scripts
chmod +x setup.sh
./setup.sh
```

Le script vous guidera à travers la configuration !

## 📋 Types d'installation

### 🚀 Installation Basique
**Parfait pour débuter**
- n8n (workflow automation)
- Flowise (chatbots IA)
- Caddy (reverse proxy + SSL)

### 📊 Installation avec Monitoring
**Pour les utilisateurs avancés**
- Tout de l'installation basique
- Prometheus (collecte de métriques)
- Grafana (tableaux de bord)

### 🔧 Installation Pro
**Pour la production**
- Tout de l'installation monitoring
- Portainer (interface Docker)
- Watchtower (mises à jour auto)
- Uptime Kuma (surveillance)

## 🌐 Configuration DNS

Avant l'installation, configurez vos enregistrements DNS :

```
Type  | Nom            | Valeur
------|----------------|----------------
A     | automation     | VOTRE_IP_SERVEUR
A     | flowise        | VOTRE_IP_SERVEUR
A     | monitoring     | VOTRE_IP_SERVEUR
A     | portainer      | VOTRE_IP_SERVEUR
A     | uptime         | VOTRE_IP_SERVEUR
```

## 📖 Guide d'utilisation

### Démarrage des services

```bash
# Démarrer tous les services
docker compose up -d

# Voir l'état des services
docker compose ps

# Suivre les logs en temps réel
docker compose logs -f
```

### Accès aux services

Après installation, vos services seront disponibles sur :

- **n8n**: https://automation.votre-domaine.com
- **Flowise**: https://flowise.votre-domaine.com
- **Grafana**: https://monitoring.votre-domaine.com
- **Portainer**: https://portainer.votre-domaine.com
- **Uptime Kuma**: https://uptime.votre-domaine.com

Les identifiants sont dans le fichier `credentials.txt` généré lors de l'installation.

### Commandes utiles

```bash
# Redémarrer un service spécifique
docker compose restart n8n

# Voir les logs d'un service
docker compose logs n8n

# Mettre à jour les images
docker compose pull
docker compose up -d

# Sauvegarder les données
cd scripts && ./backup.sh

# Arrêter tous les services
docker compose down
```

## 🔧 Configuration avancée

### Variables d'environnement (.env)

Le fichier `.env` contient toute la configuration :

```bash
# Domaine
DOMAIN_NAME=votre-domaine.com
SUBDOMAIN=automation

# Sécurité
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=votre-mot-de-passe

# Flowise
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=votre-mot-de-passe

# SSL
SSL_EMAIL=votre-email@exemple.com
```

### Personnaliser le Caddyfile

Le fichier `caddy_config/Caddyfile` gère le reverse proxy :

```caddy
votre-domaine.com {
    reverse_proxy n8n:5678 {
        flush_interval -1
    }
}
```

## 📊 Monitoring et maintenance

### Surveillance des services

Avec l'installation Pro, vous avez accès à :

- **Grafana**: Tableaux de bord de performance
- **Prometheus**: Collecte des métriques
- **Uptime Kuma**: Alertes en cas de panne

### Sauvegardes automatiques

```bash
# Script de sauvegarde manuel
./backup.sh

# Programmer des sauvegardes automatiques
crontab -e
# Ajouter: 0 3 * * * /chemin/vers/backup.sh
```

### Mises à jour

```bash
# Mise à jour manuelle
cd scripts && ./update.sh

# Avec Watchtower (automatique)
# Les mises à jour se font automatiquement le dimanche à 4h
```

## 🔧 Dépannage

### Problèmes courants

**SSL ne fonctionne pas**
```bash
# Vérifier les logs de Caddy
docker compose logs caddy

# Vérifier que les DNS pointent bien vers votre serveur
nslookup votre-domaine.com
```

**Service ne démarre pas**
```bash
# Voir les erreurs
docker compose logs [nom-service]

# Redémarrer le service
docker compose restart [nom-service]
```

**Espace disque plein**
```bash
# Nettoyer Docker
docker system prune -a

# Voir l'utilisation
docker system df
df -h
```

### Logs et diagnostics

```bash
# Logs complets
docker compose logs -f --tail=100

# État des conteneurs
docker compose ps

# Utilisation des ressources
docker stats --no-stream
```

## 🤝 Support et communauté

- **GitHub Issues**: Pour les bugs et demandes de fonctionnalités
- **Discussions**: Pour les questions et aide
- **Wiki**: Documentation détaillée
- **Skool Community**: [Lien vers votre groupe]

## 📚 Documentation

- [Guide d'installation détaillé](docs/installation.md)
- [Configuration avancée](docs/advanced-config.md)
- [Dépannage](docs/troubleshooting.md)
- [API et webhooks](docs/api.md)
- [Exemples de workflows](docs/examples/)

## 🔐 Sécurité

### Bonnes pratiques

- ✅ Utilisez toujours HTTPS
- ✅ Mots de passe forts générés automatiquement
- ✅ Firewall configuré par défaut
- ✅ Mises à jour automatiques avec Watchtower
- ✅ Sauvegardes régulières

### Durcissement

Pour renforcer la sécurité :

```bash
# Désactiver l'accès root SSH
sudo nano /etc/ssh/sshd_config
# PermitRootLogin no
# PasswordAuthentication no

# Installer fail2ban
sudo apt install fail2ban
```

## 📈 Performance

### Optimisations recommandées

**Pour n8n:**
```bash
# Dans .env
N8N_EXECUTIONS_DATA_PRUNE=true
N8N_EXECUTIONS_DATA_MAX_AGE=168  # 7 jours
```

**Pour serveur:**
```bash
# Augmenter les limites si nécessaire
echo "fs.file-max = 65536" >> /etc/sysctl.conf
```

## 🎯 Roadmap

- [ ] Support ARM64 (Raspberry Pi)
- [ ] Interface web d'administration
- [ ] Templates de workflows prêts à l'emploi
- [ ] Intégration CI/CD
- [ ] Support Kubernetes

## 🤝 Contribution

Les contributions sont les bienvenues !

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amazing-feature`)
3. Commit (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

- [n8n.io](https://n8n.io) pour l'outil d'automation
- [Caddy](https://caddyserver.com) pour le reverse proxy
- [Flowise](https://flowiseai.com) pour l'IA conversationnelle
- La communauté pour les retours et contributions

---

**⭐ Si ce projet vous aide, n'hésitez pas à lui donner une étoile !**

Made with ❤️ for the n8n community