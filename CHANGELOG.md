# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Homepage Installation Option** ⭐ - New recommended installation level featuring:
  - Modern, lightweight dashboard for service management
  - Docker container monitoring and statistics
  - Integrated with n8n, Flowise, and Caddy
  - Cleaner alternative to full Grafana/Prometheus stack
- **Diun Integration** - Docker Image Update Notifier:
  - Replaces Watchtower for safer update management
  - Notifies when updates are available without auto-updating
  - Checks every 6 hours for new image versions
  - Optional webhook notifications to n8n
- `docker-compose-homepage.yml` - Configuration file for Homepage stack
- Homepage directory creation in setup script
- Homepage volume (`homepage_data`) and Diun volume (`diun_data`) support

### Changed
- **Replaced Watchtower with Diun** in Pro installation:
  - Watchtower was outdated (2023) and auto-updated without control
  - Diun provides notifications without automatic updates
  - Better control over when updates are applied
- Updated `scripts/setup.sh`:
  - Added Homepage as 4th installation option (recommended)
  - Added subdomain configuration for Homepage dashboard
  - Added Homepage URL to configuration summary
  - Added Homepage to credentials.txt generation
  - Updated to create homepage and diun volumes
- Updated `scripts/update.sh`:
  - Added `docker-compose-homepage.yml` to compose file detection
  - Ensures Homepage installations are properly updated
- Updated `scripts/clean_rebuild.sh`:
  - Added `docker-compose-homepage.yml` to cleanup search
  - Added homepage and diun volumes to deletion patterns
- Updated `.gitignore`:
  - Added `backup-*/` pattern for backup directories
  - Added `.claude/` for Claude Code directories
- Updated `README.md`:
  - Added Homepage installation option to deployment options
  - Updated Watchtower references to Diun
  - Added Homepage and Diun to services table
  - Updated installation guide with Homepage option

### Fixed
- Permission issues in setup scripts with improved directory creation
- Watchtower self-update issue (replaced with Diun)

## [1.0.0] - Initial Release

### Added
- Interactive setup script with guided configuration
- Three installation levels: Basic, Monitoring, Pro
- Automatic SSL certificate generation via Caddy
- Password generation for all services
- Support for multiple VPS providers (Hetzner, DigitalOcean, etc.)
- Grafana dashboards with automatic provisioning
- Node Exporter for system metrics
- Docker container monitoring with cAdvisor
- Portainer for Docker management
- Watchtower for automatic updates (later replaced)
- Uptime Kuma for service monitoring
- Backup and update utility scripts
- Comprehensive documentation in English and French
- UFW firewall configuration support

---

## Installation Levels Comparison

| Feature | Basic | Monitoring | Pro | Homepage ⭐ |
|---------|-------|------------|-----|-----------|
| n8n | ✅ | ✅ | ✅ | ✅ |
| Flowise | ✅ | ✅ | ✅ | ✅ |
| Caddy (SSL) | ✅ | ✅ | ✅ | ✅ |
| Homepage Dashboard | ❌ | ❌ | ❌ | ✅ |
| Diun (Update Notifier) | ❌ | ❌ | ✅ | ✅ |
| Prometheus | ❌ | ✅ | ✅ | ❌ |
| Grafana | ❌ | ✅ | ✅ | ❌ |
| Node Exporter | ❌ | ✅ | ✅ | ❌ |
| cAdvisor | ❌ | ✅ | ✅ | ❌ |
| Portainer | ❌ | ❌ | ✅ | ❌ |
| Uptime Kuma | ❌ | ❌ | ✅ | ❌ |
| **Services Count** | 3 | 7 | 10 | 5 |
| **Recommended For** | Minimal | Power Users | Advanced | Most Users ⭐ |
