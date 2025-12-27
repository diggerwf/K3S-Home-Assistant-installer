#!/bin/bash
#
# HA-Installer.sh - Installiert Home Assistant in einem k3s/Kubernetes Cluster

# Lade Konfiguration, falls vorhanden (Überschreibt die Standardwerte)
SETTINGS_FILE="./settings.conf"
if [ -f "$SETTINGS_FILE" ]; then
    source "$SETTINGS_FILE"
fi

# -----------------------------------------------------------------------------
# 1. Konfiguration
# -----------------------------------------------------------------------------
K8S_NAMESPACE="home-assistant"
HA_SERVICE_NAME="home-assistant-service"
HA_NODE_IPS=() 

# ... (Debugging-Funktionen analyze_with_gemini, perform_auto_debug, check_status) ...

# -----------------------------------------------------------------------------
# 3. Interaktive Benutzerabfrage (Nur leere Werte abfragen)
# -----------------------------------------------------------------------------

collect_user_input() {
    echo "### ⚙️ Konfiguration für Home Assistant auf k3s ###"
    # ... (Code für interaktive Abfragen, die nur bei leeren Werten aus settings.conf greifen) ...
    # ... (Load Balancer Logik, die HA_NODE_IPS befüllt oder HA_LOAD_BALANCER_IPS aus settings.conf nutzt) ...
    
    echo "--- Aktuelle Ressourcen (Aus settings.conf) ---"
    echo "CPU Request/Limit: $HA_CPU_REQUEST / $HA_CPU_LIMIT"
    echo "Memory Request/Limit: $HA_MEMORY_REQUEST / $HA_MEMORY_LIMIT"
    # ... (Bestätigungsabfrage) ...
}

# -----------------------------------------------------------------------------
# 5. Dynamische Generierung der YAML-Manifeste (AKTUALISIERT mit Ressourcen)
# -----------------------------------------------------------------------------

generate_manifests() {
    echo "### Generiere Kubernetes Manifeste (.yaml Dateien) ###"
    
    # ha-pvc.yaml...
    
    # ha-deployment.yaml (NEU: Requests/Limits aus settings.conf)
    cat <<EOF > ha-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: home-assistant-deployment
  namespace: ${K8S_NAMESPACE}
# ...
    spec:
      containers:
      - name: home-assistant
        image: homeassistant/home-assistant:stable
        env:
          - name: TZ
            value: "${HA_TIMEZONE}"
        ports:
          - containerPort: 8123
            name: http
        resources: 
          requests:
            cpu: "${HA_CPU_REQUEST}"
            memory: "${HA_MEMORY_REQUEST}"
          limits:
            cpu: "${HA_CPU_LIMIT}"
            memory: "${HA_MEMORY_LIMIT}"
        volumeMounts:
# ...
EOF
    check_status "ha-deployment.yaml erstellt"

    # ... (ha-service.yaml mit LoadBalancerIPs-Logik) ...
    # ... (ha-ingress.yaml mit HA_DOMAIN) ...
}

# -----------------------------------------------------------------------------
# 7. Skript Ausführung
# -----------------------------------------------------------------------------
# ... (Aufruf der Funktionen: display_cluster_metrics_and_collect_ips, collect_user_input, generate_manifests, main_installation) ...
