# 🚀 n8n-docker-caddy Community Edition

> **Easy n8n deployment with Docker and Caddy - Automatic SSL and 5-minute setup!**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://docker.com)
[![n8n](https://img.shields.io/badge/n8n-Latest-orange)](https://n8n.io)
[![SSL](https://img.shields.io/badge/SSL-Auto--Generated-green)](https://letsencrypt.org)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

This is a community fork of the original n8n-docker-caddy project, enhanced with interactive installation scripts and multiple deployment options for VPS providers like Hetzner Cloud and DigitalOcean.

## ✨ What's New

🎯 **Interactive Setup Script**
- Guided configuration with multiple installation levels
- Automatic password generation
- SSL certificate automation
- Firewall configuration

🔧 **Multiple Deployment Options**
- **Basic**: n8n + Flowise + Caddy
- **Monitoring**: + Prometheus + Grafana
- **Pro**: + Portainer + Watchtower + Uptime Kuma

🛡️ **Enhanced Security**
- Authentication enabled by default
- Strong password generation
- UFW firewall integration
- Secure defaults

## 🚀 Quick Start

```bash
git clone https://github.com/QuantumCraftr/n8n-docker-caddy.git
cd n8n-docker-caddy
cd scripts
chmod +x setup.sh
./setup.sh
```

The setup script will guide you through:
- Choosing your installation type
- Configuring your domain and subdomains
- Setting up SSL certificates
- Generating secure passwords
- Creating Docker volumes

## 📖 Documentation

- **[🇺🇸 English Guide](README-EASYINSTALL-ENG.MD)** - Complete installation and usage guide
- **[🇫🇷 Guide Français](README-EASYINSTALL-FR.MD)** - Guide complet d'installation et d'utilisation

## 💡 Key Features

- **Zero-config SSL** with Let's Encrypt via Caddy
- **Multiple services** in one deployment
- **Backup & update scripts** included
- **Production-ready** configurations
- **VPS optimized** for cloud providers

## 🛠️ Requirements

- Linux server (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- Docker & Docker Compose
- Domain name pointing to your server
- Ports 80 and 443 open

## 🚀 Services Included

| Service | Purpose | Installation Level |
|---------|---------|-------------------|
| **n8n** | Workflow automation | All |
| **Flowise** | AI chatbots | All |
| **Caddy** | Reverse proxy + SSL | All |
| **Prometheus** | Metrics collection | Monitoring + Pro |
| **Grafana** | Monitoring dashboards | Monitoring + Pro |
| **Portainer** | Docker management | Pro only |
| **Watchtower** | Auto updates | Pro only |
| **Uptime Kuma** | Service monitoring | Pro only |

## 📋 Quick Commands

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f

# Update services
cd scripts && ./update.sh

# Backup data
cd scripts && ./backup.sh

# Stop services
docker compose down
```

## 🤝 Contributing

This is a community project! Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share your workflows

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Credits

- Original [n8n-docker-caddy](https://github.com/n8n-io/n8n-docker-caddy) project
- [n8n.io](https://n8n.io) for the amazing automation platform
- [Caddy](https://caddyserver.com) for the fantastic reverse proxy
- [Flowise](https://flowiseai.com) for AI capabilities

---

**⭐ If this project helps you, please give it a star!**

Made with ❤️ for the n8n community
