#!/bin/bash
# 📊 Setup Grafana with beautiful dashboards for n8n monitoring
# This script creates all necessary configuration files for the n8n-docker-caddy project

set -e

# Determine script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if .env file exists and load variables
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    echo -e "${BLUE}📊 Loading configuration from .env file...${NC}"
    source "$PROJECT_ROOT/.env"
    DOMAIN=${DOMAIN_NAME}
else
    echo -e "${YELLOW}⚠️  .env file not found. Please run setup.sh first or enter your domain manually.${NC}"
    read -p "Enter your domain name (e.g., yourdomain.com): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        echo -e "${RED}❌ Domain name is required${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}📊 Setting up Grafana configuration for domain: ${GREEN}$DOMAIN${NC}"

# Create directory structure
echo "Creating directory structure..."

# Check if grafana directory exists and handle permissions
if [[ -d "$PROJECT_ROOT/grafana" ]]; then
    echo -e "${YELLOW}📁 Grafana directory already exists (created by Docker)${NC}"
    echo -e "${BLUE}🔧 Fixing permissions...${NC}"
    
    # Try to fix permissions, use sudo if needed
    if ! mkdir -p "$PROJECT_ROOT/grafana/datasources" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Need elevated permissions to create directories${NC}"
        read -p "Use sudo to fix permissions? [Y/n]: " USE_SUDO
        
        if [[ ! "$USE_SUDO" =~ ^[Nn]$ ]]; then
            sudo chown -R $(whoami):$(whoami) "$PROJECT_ROOT/grafana" 2>/dev/null || true
            sudo mkdir -p "$PROJECT_ROOT/grafana/datasources" 2>/dev/null || true
            sudo mkdir -p "$PROJECT_ROOT/grafana/dashboards" 2>/dev/null || true
            sudo mkdir -p "$PROJECT_ROOT/grafana/provisioning" 2>/dev/null || true
            sudo chown -R $(whoami):$(whoami) "$PROJECT_ROOT/grafana" 2>/dev/null || true
        else
            echo -e "${RED}❌ Cannot create directories without proper permissions${NC}"
            echo -e "${YELLOW}💡 Please run: sudo chown -R \$(whoami):\$(whoami) grafana/${NC}"
            exit 1
        fi
    fi
else
    # Directory doesn't exist, create normally
    mkdir -p "$PROJECT_ROOT/grafana/datasources"
    mkdir -p "$PROJECT_ROOT/grafana/dashboards"
    mkdir -p "$PROJECT_ROOT/grafana/provisioning"
fi

# 1. Prometheus datasource configuration
cat > "$PROJECT_ROOT/grafana/datasources/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# 2. Dashboard provisioning configuration
cat > "$PROJECT_ROOT/grafana/dashboards/dashboard.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# 3. Enhanced Prometheus configuration with Node Exporter
cat > "$PROJECT_ROOT/prometheus/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"

scrape_configs:
  # System metrics via Node Exporter (recommended)
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 15s
    metrics_path: '/metrics'

  # Docker metrics via cAdvisor (backup option)
  - job_name: 'docker'
    static_configs:
      - targets: ['cadvisor:8080']
    scrape_interval: 15s
    metrics_path: '/metrics'

  # n8n application metrics (if available)
  - job_name: 'n8n'
    static_configs:
      - targets: ['n8n:5678']
    scrape_interval: 30s
    metrics_path: '/metrics'
    scrape_timeout: 10s

  # Prometheus self-monitoring
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Grafana metrics
  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
    metrics_path: '/metrics'

  # Caddy metrics (if enabled)
  - job_name: 'caddy'
    static_configs:
      - targets: ['caddy:2019']
    metrics_path: '/metrics'
    scrape_timeout: 5s
EOF

# 4. Create Docker Containers Dashboard
cat > "$PROJECT_ROOT/grafana/dashboards/docker-containers.json" << 'EOF'
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "panels": [
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "vis": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "percent"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 2,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom"
        },
        "tooltip": {
          "mode": "single"
        }
      },
      "targets": [
        {
          "expr": "rate(container_cpu_usage_seconds_total{name=~\"n8n.*\"}[5m]) * 100",
          "interval": "",
          "legendFormat": "n8n CPU",
          "refId": "A"
        },
        {
          "expr": "rate(container_cpu_usage_seconds_total{name=~\"caddy.*\"}[5m]) * 100",
          "interval": "",
          "legendFormat": "Caddy CPU",
          "refId": "B"
        },
        {
          "expr": "rate(container_cpu_usage_seconds_total{name=~\"flowise.*\"}[5m]) * 100",
          "interval": "",
          "legendFormat": "Flowise CPU",
          "refId": "C"
        }
      ],
      "title": "🖥️ Container CPU Usage",
      "type": "timeseries"
    },
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "vis": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "bytes"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "id": 3,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom"
        },
        "tooltip": {
          "mode": "single"
        }
      },
      "targets": [
        {
          "expr": "container_memory_usage_bytes{name=~\"n8n.*\"}",
          "interval": "",
          "legendFormat": "n8n Memory",
          "refId": "A"
        },
        {
          "expr": "container_memory_usage_bytes{name=~\"caddy.*\"}",
          "interval": "",
          "legendFormat": "Caddy Memory",
          "refId": "B"
        },
        {
          "expr": "container_memory_usage_bytes{name=~\"flowise.*\"}",
          "interval": "",
          "legendFormat": "Flowise Memory",
          "refId": "C"
        }
      ],
      "title": "🧠 Container Memory Usage",
      "type": "timeseries"
    },
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 6,
        "x": 0,
        "y": 8
      },
      "id": 4,
      "options": {
        "colorMode": "background",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "values": false,
          "calcs": [
            "lastNotNull"
          ],
          "fields": ""
        },
        "textMode": "auto"
      },
      "pluginVersion": "8.0.0",
      "targets": [
        {
          "expr": "up{job=\"docker\"}",
          "interval": "",
          "legendFormat": "cAdvisor",
          "refId": "A"
        }
      ],
      "title": "🐳 Docker Monitoring",
      "type": "stat"
    },
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 6,
        "x": 6,
        "y": 8
      },
      "id": 5,
      "options": {
        "colorMode": "background",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "values": false,
          "calcs": [
            "lastNotNull"
          ],
          "fields": ""
        },
        "textMode": "auto"
      },
      "pluginVersion": "8.0.0",
      "targets": [
        {
          "expr": "up{job=\"n8n\"}",
          "interval": "",
          "legendFormat": "n8n",
          "refId": "A"
        }
      ],
      "title": "🚀 n8n Status",
      "type": "stat"
    },
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 12,
        "x": 12,
        "y": 8
      },
      "id": 6,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "values": false,
          "calcs": [
            "lastNotNull"
          ],
          "fields": ""
        },
        "textMode": "auto"
      },
      "pluginVersion": "8.0.0",
      "targets": [
        {
          "expr": "count(container_last_seen{name=~\".+\"})",
          "interval": "",
          "legendFormat": "Running Containers",
          "refId": "A"
        }
      ],
      "title": "📦 Total Containers",
      "type": "stat"
    }
  ],
  "schemaVersion": 27,
  "style": "dark",
  "tags": ["docker", "n8n", "monitoring"],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "🚀 n8n & Docker Dashboard",
  "uid": "n8n-docker-dashboard",
  "version": 1
}
EOF

# 5. Create System Overview Dashboard
cat > "$PROJECT_ROOT/grafana/dashboards/system-overview.json" << 'EOF'
{
  "annotations": {
    "list": []
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "panels": [
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "vis": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "bytes"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 9,
        "w": 24,
        "x": 0,
        "y": 0
      },
      "id": 1,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "table",
          "placement": "right"
        },
        "tooltip": {
          "mode": "single"
        }
      },
      "targets": [
        {
          "expr": "container_fs_usage_bytes{device=\"/dev/vda1\"}",
          "interval": "",
          "legendFormat": "Disk Usage",
          "refId": "A"
        },
        {
          "expr": "sum(container_memory_usage_bytes)",
          "interval": "",
          "legendFormat": "Total Memory Usage",
          "refId": "B"
        }
      ],
      "title": "💾 System Resources Overview",
      "type": "timeseries"
    }
  ],
  "schemaVersion": 27,
  "style": "dark",
  "tags": ["system", "overview"],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "🖥️ System Overview",
  "uid": "system-overview",
  "version": 1
}
EOF

echo -e "${GREEN}✅ Configuration files created successfully!${NC}"
echo ""
echo -e "${BLUE}📂 Created files:${NC}"
echo "├── grafana/datasources/prometheus.yml"
echo "├── grafana/dashboards/dashboard.yml"
echo "├── grafana/dashboards/docker-containers.json"
echo "├── grafana/dashboards/system-overview.json"
echo "└── prometheus/prometheus.yml"
echo ""
echo -e "${YELLOW}🚀 Next steps:${NC}"
echo "1. Restart your stack to load new configurations"
echo "2. Wait for all services to start (2-3 minutes)"
echo -e "3. Access Grafana at: ${GREEN}https://monitoring.$DOMAIN${NC}"
echo "4. Login with admin / [your-grafana-password from credentials.txt]"
echo "5. The dashboards should be automatically loaded!"
echo ""
echo -e "${BLUE}🎯 Ready-made dashboard IDs to import manually:${NC}"
echo "- Node Exporter Full: 1860"
echo "- Docker Container & Host Metrics: 10619"  
echo "- cAdvisor exporter: 14282"
echo ""
echo -e "${BLUE}💡 Pro tip:${NC} Import dashboard 1860 for comprehensive system monitoring!"