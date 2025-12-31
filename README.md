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
- **Pro**: + Portainer + Diun + Uptime Kuma
- **Homepage** ⭐ (Recommended): Basic + Homepage Dashboard + Diun

🛡️ **Enhanced Security**
- Authentication enabled by default
- Strong password generation
- UFW firewall integration
- Secure defaults

## 📋 Prerequisites

- **VPS Hetzner, DigitalOcean, or personal VPS** (Ubuntu 22.04/24.04 LTS)
- **SSH** access enabled
- **Domain name** (optional but recommended) with subdomain (A) records registered
- Terminal Client (iTerm, PowerShell, etc.)

## 🚀 Quick Start

**📖 For detailed step-by-step instructions, refer to our comprehensive guides:**
- **[🇺🇸 English Guide](README-EASYINSTALL-ENG.MD)** - Complete installation and usage guide
- **[🇫🇷 Guide Français](README-EASYINSTALL-FR.MD)** - Guide complet d'installation et d'utilisation

### 1️⃣ Initial Server Setup

#### 🔐 SSH Connection

```bash
ssh root@YOUR_SERVER_IP
# Or to specify a different path for the ssh key:
ssh -i ~/.ssh/my-key root@YOUR_SERVER_IP
```

#### 🔄 System Update

```bash
apt update && apt upgrade -y && apt autoremove -y
```

#### 🛡️ Create a Dedicated User (Best Practice)

```bash
adduser n8n-admin --gecos ""
usermod -aG sudo,docker n8n-admin
rsync --archive --chown=n8n-admin:n8n-admin ~/.ssh /home/n8n-admin

# Or alternative command:
# rsync -ahv --chown=n8n-admin:n8n-admin /root/.ssh /home/n8n-admin/
```
> **Why?** Avoids using `root` directly and isolates permissions for better security.

#### 🔄 Switch to the New User

```bash
su - n8n-admin
```

### 2️⃣ Docker & Docker Compose Installation

#### 🐳 Install Docker (as n8n-admin)

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker  # Reloads groups without reconnecting
```

### 3️⃣ Clone the Project

```bash
git clone https://github.com/QuantumCraftr/n8n-docker-caddy-easyinstall
cd n8n-docker-caddy-easyinstall
```

### 4️⃣ Run the Interactive Setup Script

```bash
chmod +x scripts/*.sh # Make scripts executable for the first time
./scripts/setup.sh
```

> **The setup script will guide you through:**
> - Choosing your installation type (Basic/Monitoring/Pro/Homepage)
> - Configuring your domain and subdomains
> - Setting up SSL certificates
> - Generating secure passwords
> - Optional advanced monitoring setup with beautiful dashboards
>
> Scripts automatically manage further permissions and can be run from anywhere in the project after the initial `chmod`.
>
> ⭐ **New**: Homepage option provides a modern, lightweight dashboard with Docker monitoring and image update notifications via Diun.

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

## 📖 Full Documentation

For a complete and detailed guide, please refer to:
- **[🇺🇸 English Guide](README-EASYINSTALL-ENG.MD)**
- **[🇫🇷 Guide Français](README-EASYINSTALL-FR.MD)**

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

### 🔧 Intelligent Permission Management

✅ **Hybrid Approach** - Scripts detect permission needs upfront and recommend sudo when necessary
✅ **Smart Detection** - Checks Docker group membership, directory permissions, and file access
✅ **Clear Guidance** - Provides specific reasons why sudo might be needed
✅ **Graceful Fallback** - Continues with limited functionality when possible
✅ **Location Independent** - Run scripts from anywhere in the project
✅ **Robust Path Resolution** - Works regardless of execution directory

### 📋 Permission Requirements by Script

| Script | Typical Usage | Sudo Recommended When |
|--------|---------------|----------------------|
| [`setup.sh`](scripts/setup.sh) | `./scripts/setup.sh` | First install, not in docker group |
| [`update.sh`](scripts/update.sh) | `./scripts/update.sh` | Docker access issues |
| [`backup.sh`](scripts/backup.sh) | `sudo ./scripts/backup.sh` | For complete backup including all files |
| [`clean_rebuild.sh`](scripts/clean_rebuild.sh) | `sudo ./scripts/clean_rebuild.sh` | **Always required** (destructive operations) |
| [`grafana_setup.sh`](scripts/grafana_setup.sh) | `./scripts/grafana_setup.sh` | If grafana directory exists from Docker |

## 🚀 Services Included

| Service | Purpose | Installation Level | Dashboard |
|---------|---------|-------------------|-----------|
| **n8n** | Workflow automation | All | ✅ |
| **Flowise** | AI chatbots | All | ✅ |
| **Caddy** | Reverse proxy + SSL | All | - |
| **Homepage** | Dashboard + monitoring | Homepage | 🏠 |
| **Diun** | Docker image update notifier | Homepage + Pro | 🔔 |
| **Prometheus** | Metrics collection | Monitoring + Pro | ✅ |
| **Grafana** | Monitoring dashboards | Monitoring + Pro | 📊 |
| **Node Exporter** | System metrics | Monitoring + Pro | ✅ |
| **cAdvisor** | Container metrics | Monitoring + Pro | ✅ |
| **Portainer** | Docker management | Pro only | 🐳 |
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

### 🔔 Watchtower Email Notifications

Watchtower is configured to automatically update your services (except Portainer and itself) every Sunday at 4 AM. To receive email notifications about these updates:

1.  **Edit your `.env` file**:
    ```bash
    nano .env
    ```
2.  **Uncomment and configure the SMTP variables**:
    ```dotenv
    # 🔄 Watchtower notifications (optional for pro install)
    WATCHTOWER_NOTIFICATIONS=email
    SMTP_SERVER=your.smtp.server.com
    SMTP_PORT=587
    SMTP_USER=your-smtp-username
    SMTP_PASSWORD=your-smtp-password
    WATCHTOWER_NOTIFICATION_EMAIL_FROM=${SSL_EMAIL} # Reuses the SSL_EMAIL for sender
    WATCHTOWER_NOTIFICATION_EMAIL_TO=${SSL_EMAIL}   # Reuses the SSL_EMAIL for recipient
    ```
    > **Note**: Replace `your.smtp.server.com`, `587`, `your-smtp-username`, and `your-smtp-password` with your actual SMTP server details. For Gmail, you might need an App Password.
3.  **Restart Watchtower** to apply changes:
    ```bash
    docker compose -f docker-compose-pro.yml restart watchtower
    ```

## 🎯 Access Your Services

After installation, access your services at:
- **n8n**: `https://automation.yourdomain.com`
- **Flowise**: `https://flowise.yourdomain.com`
- **Grafana**: `https://monitoring.yourdomain.com` (Monitoring/Pro)
- **Portainer**: `https://portainer.yourdomain.com` (Pro only)
- **Uptime Kuma**: `https://uptime.yourdomain.com` (Pro only)

Login credentials are saved in `credentials.txt` after setup. You can view them with:
```bash
cat credentials.txt
```

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
# Recommended usage patterns:
./scripts/setup.sh              # Initial setup (will prompt for sudo if needed)
./scripts/update.sh             # Update services (usually no sudo needed)
sudo ./scripts/backup.sh        # Complete backup (recommended with sudo)
sudo ./scripts/clean_rebuild.sh # Destructive cleanup (always requires sudo)
./scripts/grafana_setup.sh      # Monitoring setup (sudo if grafana/ exists)
```

### 🚨 When to Use Sudo

**Always use sudo:**
- [`clean_rebuild.sh`](scripts/clean_rebuild.sh) - Deletes Docker volumes and system files
- [`backup.sh`](scripts/backup.sh) - For complete backup including protected files

**Use sudo if prompted:**
- [`setup.sh`](scripts/setup.sh) - Script will detect and ask if needed
- [`grafana_setup.sh`](scripts/grafana_setup.sh) - If Docker created grafana directory

**Usually no sudo needed:**
- [`update.sh`](scripts/update.sh) - Only updates containers (if in docker group)

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