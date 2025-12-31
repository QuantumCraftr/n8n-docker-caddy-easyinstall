# 🚀 n8n-docker-caddy Community Edition

> **Simplified n8n installation with Docker and Caddy - Automatic SSL and configuration in 5 minutes!**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://docker.com)
[![n8n](https://img.shields.io/badge/n8n-Latest-orange)](https://n8n.io)
[![SSL](https://img.shields.io/badge/SSL-Auto--Generated-green)](https://letsencrypt.org)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

## ✨ Features

🎯 **Interactive guided installation**
- Automatic configuration with just a few questions
- Secure password generation
- Multi-level support (Basic → Pro)

🔐 **Integrated security**
- Automatic SSL with Let's Encrypt
- Authentication enabled by default
- Automatically configured firewall

🚀 **Included services**
- **n8n**: Automation workflow
- **Flowise**: Conversational AI
- **Caddy**: Reverse proxy with SSL
- **Grafana + Prometheus**: Monitoring (optional)
- **Portainer**: Docker management (optional)
- **Watchtower**: Automatic updates (optional)
- **Uptime Kuma**: Service monitoring (optional)

## 🛠️ Quick installation

### Prerequisites

- Linux server (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- Docker & Docker Compose installed
- Domain name pointing to your server
- Ports 80 and 443 open

### 🔧 Automatic Setup Features

✅ **Smart Permission Management** - Scripts automatically detect and fix permission issues
✅ **Location Independent** - Run scripts from anywhere in the project
✅ **Error Recovery** - Intelligent handling of common setup problems
✅ **Robust Path Resolution** - Works regardless of execution directory

### Installation in 1 command

```bash
git clone https://github.com/QuantumCraftr/n8n-docker-caddy-easyinstall
cd n8n-docker-caddy-easyinstall
./scripts/setup.sh
```

> **Note**: Before running any script for the first time, ensure they are executable: `chmod +x scripts/*.sh`. Scripts then automatically manage further permissions and can be run from anywhere in the project.

The script will guide you through the configuration!

## 📋 Installation types

### 🚀 Basic Installation
**Perfect for beginners**
- n8n (workflow automation)
- Flowise (AI chatbots)
- Caddy (reverse proxy + SSL)

### 🏠 Homepage Installation ⭐ **Recommended**
**Simple and modern**
- Everything from the basic installation
- Homepage (modern dashboard)
- Diun (update notifications)

### 📊 Installation with Monitoring
**For advanced users**
- Everything from the basic installation
- Prometheus (metrics collection)
- Grafana (dashboards)

### 🔧 Pro Installation
**For production**
- Everything from the monitoring installation
- Portainer (Docker interface)
- Diun (update notifications)
- Uptime Kuma (monitoring)

## 🌐 DNS Configuration

Before installation, configure your DNS records:

```
Type  | Name            | Value
------|----------------|----------------
A     | automation     | YOUR_SERVER_IP
A     | flowise        | YOUR_SERVER_IP
A     | monitoring     | YOUR_SERVER_IP
A     | portainer      | YOUR_SERVER_IP
A     | uptime         | YOUR_SERVER_IP
```

## 📖 User Guide

### Starting services

```bash
# Start according to your installation
# Basic installation
docker compose -f docker-compose-basic.yml up -d

# Installation with monitoring
docker compose -f docker-compose-monitoring.yml up -d

# Pro installation
docker compose -f docker-compose-pro.yml up -d

# View service status
docker compose -f docker-compose-[level].yml ps

# Follow logs in real-time
docker compose -f docker-compose-[level].yml logs -f
```

### Accessing services

After installation, your services will be available at:

- **n8n**: https://automation.your-domain.com
- **Flowise**: https://flowise.your-domain.com
- **Grafana**: https://monitoring.your-domain.com
- **Portainer**: https://portainer.your-domain.com
- **Uptime Kuma**: https://uptime.your-domain.com

Credentials are in the `credentials.txt` file generated during installation. You can view them with:
```bash
cat credentials.txt
```

### Useful commands

```bash
# Restart a specific service (replace [level] with basic/monitoring/pro)
docker compose -f docker-compose-[level].yml restart n8n

# View logs for a service
docker compose -f docker-compose-[level].yml logs n8n

# Update images
docker compose -f docker-compose-[level].yml pull
docker compose -f docker-compose-[level].yml up -d

# Backup data
./scripts/backup.sh

# Update with script
./scripts/update.sh

# Complete cleanup (if needed)
./scripts/clean_rebuild.sh

# Stop all services
docker compose -f docker-compose-[level].yml down
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

## 🔧 Advanced configuration

### Environment variables (.env)

The `.env` file contains all the configuration:

```bash
# Domain
DOMAIN_NAME=your-domain.com
SUBDOMAIN=automation

# Security
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your-password

# Flowise
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=your-password

# SSL
SSL_EMAIL=your-email@example.com
```

### Customizing the Caddyfile

The `caddy_config/Caddyfile` file manages the reverse proxy:

```caddy
your-domain.com {
    reverse_proxy n8n:5678 {
        flush_interval -1
    }
}
```

## 📊 Monitoring and maintenance

### Service monitoring

With the Pro installation, you have access to:

- **Grafana**: Performance dashboards
- **Prometheus**: Metrics collection
- **Uptime Kuma**: Alerts in case of outage

### Automatic backups

```bash
# Manual backup script
./scripts/backup.sh

# Schedule automatic backups
crontab -e
# Add: 0 3 * * * /path/to/n8n-docker-caddy-easyinstall/scripts/backup.sh
```

### Updates

```bash
# Manual update
./scripts/update.sh

# With Watchtower (automatic)
# Updates are done automatically on Sunday at 4am
```

## 🔧 Troubleshooting

### Common issues

**SSL not working**
```bash
# Check Caddy logs (replace [level] with your installation)
docker compose -f docker-compose-[level].yml logs caddy

# Verify that DNS points to your server
nslookup your-domain.com
or 
https://dnschecker.org/
```

**Service not starting**
```bash
# See errors (replace [level] with your installation)
docker compose -f docker-compose-[level].yml logs [service-name]

# Restart the service
docker compose -f docker-compose-[level].yml restart [service-name]
```

**Disk space full**
```bash
# Clean Docker
docker system prune -a

# View usage
docker system df
df -h
```

### Logs and diagnostics

```bash
# Complete logs (replace [level] with your installation)
docker compose -f docker-compose-[level].yml logs -f --tail=100

# Container status
docker compose -f docker-compose-[level].yml ps

# Resource usage
docker stats --no-stream
```

## 🤝 Support and community

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and help
- **Wiki**: Detailed documentation
- **Skool Community**: [Link to your group]

## 📚 Documentation

- [Detailed installation guide](docs/installation.md)
- [Advanced configuration](docs/advanced-config.md)
- [Troubleshooting](docs/troubleshooting.md)
- [API and webhooks](docs/api.md)
- [Workflow examples](docs/examples/)

## 🔐 Security

### Best practices

- ✅ Always use HTTPS
- ✅ Strong passwords automatically generated
- ✅ Firewall configured by default
- ✅ Automatic updates with Watchtower
- ✅ Regular backups
- ✅ **New**: Automatic permission management
- ✅ **New**: Robust and secure scripts

### 🛡️ Permission Management

All scripts now include **automatic permission detection and fixing**:

- **Auto-executable**: Scripts automatically make themselves and siblings executable
- **Smart ownership**: Detects and fixes directory ownership issues using `sudo` when needed
- **Safe fallbacks**: Provides clear instructions if automatic fixes fail
- **Cross-directory**: Works whether run from project root or `scripts/` directory

```bash
# These commands now work from anywhere in the project:
./scripts/setup.sh          # Run initial setup
./scripts/update.sh         # Update your installation
./scripts/backup.sh         # Create backups
./scripts/clean_rebuild.sh  # Nuclear cleanup option
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

### Hardening

To strengthen security:

```bash
# Disable SSH root access
sudo nano /etc/ssh/sshd_config
# PermitRootLogin no
# PasswordAuthentication no

# Install fail2ban
sudo apt install fail2ban
```

## 📈 Performance

### Recommended optimizations

**For n8n:**
```bash
# In .env
N8N_EXECUTIONS_DATA_PRUNE=true
N8N_EXECUTIONS_DATA_MAX_AGE=168  # 7 days
```

**For server:**
```bash
# Increase limits if needed
echo "fs.file-max = 65536" >> /etc/sysctl.conf
```

## 🎯 Roadmap

- [ ] ARM64 support (Raspberry Pi)
- [ ] Web administration interface
- [ ] Ready-to-use workflow templates
- [ ] CI/CD integration
- [ ] Kubernetes support

## 🤝 Contribution

Contributions are welcome!

1. Fork the project
2. Create a branch (`git checkout -b feature/amazing-feature`)
3. Commit (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is under the MIT license. See [LICENSE](LICENSE) for more details.

## 🙏 Acknowledgements

- [n8n.io](https://n8n.io) for the automation tool
- [Caddy](https://caddyserver.com) for the reverse proxy
- [Flowise](https://flowiseai.com) for conversational AI
- The community for feedback and contributions

---

**⭐ If this project helps you, please give it a star!**

Made with ❤️ for the n8n community