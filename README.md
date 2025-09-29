# 🚀 n8n-docker-caddy Community Edition

> **Easy n8n deployment with Docker and Caddy - Automatic SSL and 5-minute setup!**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://docker.com)
[![n8n](https://img.shields.io/badge/n8n-Latest-orange)](https://n8n.io)
[![SSL](https://img.shields.io/badge/SSL-Auto--Generated-green)](https://letsencrypt.org)
[![Monitoring](https://img.shields.io/badge/Monitoring-Grafana-red)](https://grafana.com)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

This is a community fork of the original n8n-docker-caddy project, enhanced with interactive installation scripts, advanced monitoring capabilities, and multiple deployment options for VPS providers like Hetzner Cloud and DigitalOcean.

## ✨ What's New

🎯 **Interactive Setup Script**
- Guided configuration with multiple installation levels
- Automatic password generation
- SSL certificate automation
- Firewall configuration

📊 **Advanced Monitoring Suite**
- Professional Grafana dashboards
- Node Exporter for system metrics
- Docker container monitoring
- Automatic dashboard provisioning

🔧 **Multiple Deployment Options**
- **Basic**: n8n + Flowise + Caddy
- **Monitoring**: + Prometheus + Grafana + Node Exporter
- **Pro**: + Portainer + Watchtower + Uptime Kuma

🛡️ **Enhanced Security**
- Authentication enabled by default
- Strong password generation
- UFW firewall integration
- Secure defaults

## 🚀 Quick Start

```bash
git clone https://github.com/QuantumCraftr/n8n-docker-caddy-easyinstall
cd n8n-docker-caddy-easyinstall
./scripts/setup.sh
```

> **Note**: Scripts automatically fix permissions and can be run from anywhere in the project.

The setup script will guide you through:
- Choosing your installation type (Basic/Monitoring/Pro)
- Configuring your domain and subdomains
- Setting up SSL certificates
- Generating secure passwords
- **NEW**: Optional advanced monitoring setup with beautiful dashboards

## 📊 Monitoring Features

The **Monitoring** and **Pro** installation levels now include:

- 🎨 **Beautiful Grafana Dashboards** - Pre-configured and auto-loaded
- 🖥️ **System Metrics** - CPU, memory, disk, network via Node Exporter
- 🐳 **Container Monitoring** - Docker stats and health
- 📈 **Real-time Alerts** - Monitor your n8n workflows and system health
- 📊 **Professional Charts** - Production-ready visualization

### Sample Dashboards Included:
- **n8n & Docker Dashboard** - Container resources and health
- **System Overview** - Server performance metrics  
- **Ready-to-import IDs**: Node Exporter (1860), Docker (10619)

## 📖 Documentation

- **[🇺🇸 English Guide](README-EASYINSTALL-ENG.MD)** - Complete installation and usage guide
- **[🇫🇷 Guide Français](README-EASYINSTALL-FR.MD)** - Guide complet d'installation et d'utilisation

## 💡 Key Features

- **Zero-config SSL** with Let's Encrypt via Caddy
- **Multiple services** in one deployment
- **Professional monitoring** with Grafana + Prometheus
- **Backup & update scripts** included
- **Production-ready** configurations
- **VPS optimized** for cloud providers

## 🛠️ Requirements

- Linux server (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- Docker & Docker Compose
- Domain name pointing to your server
- Ports 80 and 443 open
- **Recommended**: 2+ GB RAM for monitoring features

### 🔧 Automatic Setup Features

✅ **Smart Permission Management** - Scripts automatically detect and fix permission issues
✅ **Location Independent** - Run scripts from anywhere in the project
✅ **Error Recovery** - Intelligent handling of common setup problems
✅ **Robust Path Resolution** - Works regardless of execution directory

## 🚀 Services Included

| Service | Purpose | Installation Level | Dashboard |
|---------|---------|-------------------|-----------|
| **n8n** | Workflow automation | All | ✅ |
| **Flowise** | AI chatbots | All | ✅ |
| **Caddy** | Reverse proxy + SSL | All | - |
| **Prometheus** | Metrics collection | Monitoring + Pro | ✅ |
| **Grafana** | Monitoring dashboards | Monitoring + Pro | 📊 |
| **Node Exporter** | System metrics | Monitoring + Pro | ✅ |
| **cAdvisor** | Container metrics | Monitoring + Pro | ✅ |
| **Portainer** | Docker management | Pro only | 🐳 |
| **Watchtower** | Auto updates | Pro only | - |
| **Uptime Kuma** | Service monitoring | Pro only | 📈 |

## 📋 Quick Commands

```bash
# Start services (use your specific compose file)
docker compose -f docker-compose-pro.yml up -d

# View logs
docker compose -f docker-compose-pro.yml logs -f

# Update services
./scripts/update.sh

# Backup data
./scripts/backup.sh

# Setup advanced monitoring (optional)
./scripts/grafana_setup.sh

# Complete cleanup (if needed)
./scripts/clean_rebuild.sh

# Stop services
docker compose -f docker-compose-pro.yml down
```

> **✨ New**: All scripts are now **location-independent** and include **automatic permission management**!

## 🎯 Access Your Services

After installation, access your services at:
- **n8n**: `https://automation.yourdomain.com`
- **Flowise**: `https://flowise.yourdomain.com`
- **Grafana**: `https://monitoring.yourdomain.com` (Monitoring/Pro)
- **Portainer**: `https://portainer.yourdomain.com` (Pro only)
- **Uptime Kuma**: `https://uptime.yourdomain.com` (Pro only)

Login credentials are saved in `credentials.txt` after setup.

## 🔧 Advanced Configuration

### Manual Grafana Dashboard Import
If you prefer manual setup, import these dashboard IDs:
- **Node Exporter Full**: `1860` (recommended)
- **Docker Container & Host**: `10619`
- **cAdvisor**: `14282`

### Custom Monitoring Setup
Run the Grafana setup script separately:
```bash
./scripts/grafana_setup.sh
```

### 🛡️ Permission Management

All scripts now include **automatic permission detection and fixing**:

- **Auto-executable**: Scripts automatically make themselves and siblings executable
- **Smart ownership**: Detects and fixes directory ownership issues using `sudo` when needed
- **Safe fallbacks**: Provides clear instructions if automatic fixes fail
- **Cross-directory**: Works whether run from project root or `scripts/` directory

```bash
# These commands now work from anywhere in the project:
./scripts/setup.sh      # Run initial setup
./scripts/update.sh     # Update your installation
./scripts/backup.sh     # Create backups
./scripts/clean_rebuild.sh  # Nuclear cleanup option
```

## 🤝 Contributing

This is a community project! We welcome:
- 🐛 Bug reports and fixes
- ✨ New feature suggestions
- 📚 Documentation improvements
- 🎨 Dashboard enhancements
- 🔧 Infrastructure improvements

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/QuantumCraftr/n8n-docker-caddy-easyinstall/issues)
- **Discussions**: [GitHub Discussions](https://github.com/QuantumCraftr/n8n-docker-caddy-easyinstall/discussions)
- **n8n Community**: [n8n Community Forum](https://community.n8n.io)

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Credits

- Original [n8n-docker-caddy](https://github.com/n8n-io/n8n-docker-caddy) project
- [n8n.io](https://n8n.io) for the amazing automation platform
- [Caddy](https://caddyserver.com) for the fantastic reverse proxy
- [Flowise](https://flowiseai.com) for AI capabilities
- [Grafana](https://grafana.com) & [Prometheus](https://prometheus.io) for monitoring

---

**⭐ If this project helps you, please give it a star!**

Made with ❤️ for the n8n community | Enhanced with 📊 professional monitoring