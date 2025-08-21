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

### Installation in 1 command

```bash
git clone https://github.com/QuantumCraftr/n8n-docker-caddy.git
cd n8n-docker-caddy
cd scripts
chmod +x setup.sh
./setup.sh
```

The script will guide you through the configuration!

## 📋 Installation types

### 🚀 Basic Installation
**Perfect for beginners**
- n8n (workflow automation)
- Flowise (AI chatbots)
- Caddy (reverse proxy + SSL)

### 📊 Installation with Monitoring
**For advanced users**
- Everything from the basic installation
- Prometheus (metrics collection)
- Grafana (dashboards)

### 🔧 Pro Installation
**For production**
- Everything from the monitoring installation
- Portainer (Docker interface)
- Watchtower (automatic updates)
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
# Start all services
docker compose up -d

# View service status
docker compose ps

# Follow logs in real-time
docker compose logs -f
```

### Accessing services

After installation, your services will be available at:

- **n8n**: https://automation.your-domain.com
- **Flowise**: https://flowise.your-domain.com
- **Grafana**: https://monitoring.your-domain.com
- **Portainer**: https://portainer.your-domain.com
- **Uptime Kuma**: https://uptime.your-domain.com

Credentials are in the `credentials.txt` file generated during installation.

### Useful commands

```bash
# Restart a specific service
docker compose restart n8n

# View logs for a service
docker compose logs n8n

# Update images
docker compose pull
docker compose up -d

# Backup data
cd scripts && ./backup.sh

# Stop all services
docker compose down
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
cd scripts && ./backup.sh

# Schedule automatic backups
crontab -e
# Add: 0 3 * * * /path/to/scripts/backup.sh
```

### Updates

```bash
# Manual update
cd scripts && ./update.sh

# With Watchtower (automatic)
# Updates are done automatically on Sunday at 4am
```

## 🔧 Troubleshooting

### Common issues

**SSL not working**
```bash
# Check Caddy logs
docker compose logs caddy

# Verify that DNS points to your server
nslookup your-domain.com
```

**Service not starting**
```bash
# See errors
docker compose logs [service-name]

# Restart the service
docker compose restart [service-name]
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
# Complete logs
docker compose logs -f --tail=100

# Container status
docker compose ps

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