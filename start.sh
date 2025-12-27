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

# -----------------------------------------------------------------------------
# 2. Debugging-Funktionen
# -----------------------------------------------------------------------------

analyze_with_gemini() {
    local DEBUG_PROMPT="$1" 

    if [ -z "$GEMINI_API_KEY" ]; then
        echo "⚠️ Gemini API Key fehlt. KI-Analyse übersprungen."
        return
    }
    
    echo ""
    echo "====================================================="
    echo "🧠 STARTE KI-ANALYSE MIT GOOGLE GEMINI"
    echo "====================================================="
    
    local FINAL_PROMPT="Analysiere die folgenden Kubernetes-Deployment- und Pod-Zustandsdaten für Home Assistant. Identifiziere die Hauptursache für den Fehler, gib eine kurze Zusammenfassung und schlage die spezifische kubectl-Lösung zur Behebung des Problems vor. \n\n Daten: \n\n ${DEBUG_PROMPT}"

    RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "{
            \"contents\": [{\"parts\": [{\"text\": \"${FINAL_PROMPT}\"}]}]
        }")

    ANALYSIS=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
    
    if [ ! -z "$ANALYSIS" ] && [ "$ANALYSIS" != "null" ]; then
        echo "🤖 GEMINI FEHLERANALYSE:"
        echo "-----------------------------------------------------"
        echo "$ANALYSIS"
    else
        echo "❌ Fehler beim Empfangen oder Parsen der Analyse von der Gemini API."
    fi
    echo "====================================================="
}

perform_auto_debug() {
    echo ""
    echo "====================================================="
    echo "🐛 STARTE AUTO-DEBUGGING UND FEHLERANALYSE"
    echo "====================================================="
    
    DEBUG_DATA=""

    echo "--- 1. Home Assistant Deployment Status ---"
    DEPLOYMENT_DESCRIBE=$(kubectl describe deployment home-assistant-deployment -n "$K8S_NAMESPACE")
    echo "$DEPLOYMENT_DESCRIBE"
    DEBUG_DATA+="Deployment Describe:\n$DEPLOYMENT_DESCRIBE\n"

    HA_POD_NAME=$(kubectl get pods -n "$K8S_NAMESPACE" -l app=home-assistant -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ ! -z "$HA_POD_NAME" ]; then
        echo ""
        echo "--- 2. Home Assistant Pod Zustand (Events) ---"
        POD_DESCRIBE=$(kubectl describe pod "$HA_POD_NAME" -n "$K8S_NAMESPACE")
        echo "$POD_DESCRIBE" | grep -E "State:|Last State:|Ready:|Restarts:|Events:"
        DEBUG_DATA+="Pod Describe (Auszug):\n$(echo "$POD_DESCRIBE" | grep -E "State:|Last State:|Ready:|Restarts:|Events:")\n"
        
        echo ""
        echo "--- 3. Letzte 20 Zeilen der Home Assistant Logs ---"
        POD_LOGS=$(kubectl logs "$HA_POD_NAME" -n "$K8S_NAMESPACE" --tail=20 2>/dev/null)
        echo "$POD_LOGS"
        DEBUG_DATA+="Pod Logs (Tail 20):\n$POD_LOGS\n"
    else
        echo "Kein Home Assistant Pod gefunden. Überprüfen Sie das Deployment."
        DEBUG_DATA+="Kein Home Assistant Pod gefunden."
    fi

    echo ""
    echo "--- 4. Persistent Volume Claim (PVC) Status ---"
    PVC_STATUS=$(kubectl get pvc -n "$K8S_NAMESPACE")
    echo "$PVC_STATUS"
    DEBUG_DATA+="PVC Status:\n$PVC_STATUS\n"
    
    analyze_with_gemini "$DEBUG_DATA"
    
    echo "====================================================="
    echo "🐛 AUTO-DEBUGGING BEENDET"
    echo "====================================================="
}


check_status() {
    STEP_MSG="$1"
    if [ $? -eq 0 ]; then
        echo "✅ ERFOLG: $STEP_MSG"
    else
        echo "❌ FEHLER: $STEP_MSG fehlgeschlagen!"
        echo "-----------------------------------------------------"
        echo "Das Skript wird beendet und startet die Fehleranalyse."
        echo "-----------------------------------------------------"
        perform_auto_debug
        exit 1
    fi
}


# -----------------------------------------------------------------------------
# 3. Interaktive Benutzerabfrage (Nur leere Werte abfragen)
# -----------------------------------------------------------------------------

collect_user_input() {
    echo "### ⚙️ Konfiguration für Home Assistant auf k3s ###"
    echo "-----------------------------------------------------"
    
    # KI-Analyse: Nur abfragen, wenn der Key in der Conf-Datei leer ist
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "### Optionale KI-Analyse ###"
        read -rp "Möchten Sie den Gemini API Key für die Fehleranalyse eingeben? (Leer lassen für Nein): " input_key
        GEMINI_API_KEY=${input_key:-$GEMINI_API_KEY} # Behalte den alten Wert, falls Eingabe leer
    fi
    
    # Standard-Konfigurationen: Nur abfragen, wenn der Wert leer ist
    read -rp "1. Domänen-/Host-Name (Aktuell: ${HA_DOMAIN:-<Leer>}, Eingabe überschreibt): " input_domain
    HA_DOMAIN=${input_domain:-$HA_DOMAIN}
    
    read -rp "2. Zeitzone (Aktuell: ${HA_TIMEZONE:-<Leer>}, Eingabe überschreibt): " input_tz
    HA_TIMEZONE=${input_tz:-$HA_TIMEZONE}
    
    read -rp "3. Speichergröße (Aktuell: ${HA_STORAGE_SIZE:-<Leer>}, Eingabe überschreibt): " input_size
    HA_STORAGE_SIZE=${input_size:-$HA_STORAGE_SIZE}
    
    read -rp "4. StorageClass (Aktuell: ${HA_STORAGE_CLASS:-<Leer>}, Eingabe überschreibt): " input_class
    HA_STORAGE_CLASS=${input_class:-$HA_STORAGE_CLASS}

    # Load Balancer IPs: Manuell oder Automatisch
    if [ -n "$HA_LOAD_BALANCER_IPS" ]; then
        IFS=',' read -r -a HA_NODE_IPS <<< "$HA_LOAD_BALANCER_IPS"
        HA_SERVICE_TYPE="LoadBalancer"
        echo ""
        echo "### Load Balancer IP Konfiguration (Statisch aus settings.conf) ###"
        echo "➡️ Service-Typ wird auf 'LoadBalancer' gesetzt."
        echo "➡️ Statische IPs werden verwendet: ${HA_NODE_IPS[*]}"
        
    elif [ ${#HA_NODE_IPS[@]} -gt 0 ]; then
        HA_SERVICE_TYPE="LoadBalancer"
        echo ""
        echo "### Load Balancer IP Konfiguration (Automatisch) ###"
        echo "➡️ Service-Typ wird auf 'LoadBalancer' gesetzt."
        echo "➡️ Folgende Node-IPs werden verwendet: ${HA_NODE_IPS[*]}"
        
    else
        HA_SERVICE_TYPE="ClusterIP"
        echo ""
        echo "### Load Balancer IP Konfiguration (Deaktiviert) ###"
        echo "➡️ Keine externen/statischen IPs gefunden. Service-Typ bleibt auf 'ClusterIP'."
    fi
    
    echo "--- Aktuelle Ressourcen (Aus settings.conf) ---"
    echo "CPU Request/Limit: $HA_CPU_REQUEST / $HA_CPU_LIMIT"
    echo "Memory Request/Limit: $HA_MEMORY_REQUEST / $HA_MEMORY_LIMIT"

    echo "-----------------------------------------------------"
    read -rp "Sind diese Einstellungen korrekt? (j/n): " confirm
    if [[ ! "$confirm" =~ ^[Jj]$ ]]; then
        echo "Installation abgebrochen."
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# 4. Cluster-Metriken Abfragen und IPs sammeln 
# -----------------------------------------------------------------------------
display_cluster_metrics_and_collect_ips() {
    echo "### 📊 Aktuelle k3s Cluster-Metriken & IP-Erkennung ###"
    
    echo "--- 1. Node-Status & IP-Adressen ---"
    
    NODE_INFO=$(kubectl get nodes -o json | jq -r '.items[] | select(.status.conditions[] | .type == "Ready" and .status == "True") | .metadata.name + " " + (.status.addresses[] | select(.type == "ExternalIP").address) + " " + .status.capacity.cpu + " " + .status.capacity.memory')
    
    if [ -z "$NODE_INFO" ]; then
        echo "⚠️ Externe IP-Adressen der Nodes konnten nicht gefunden werden. Versuche Interne IP..."
        NODE_INFO=$(kubectl get nodes -o json | jq -r '.items[] | select(.status.conditions[] | .type == "Ready" and .status == "True") | .metadata.name + " " + (.status.addresses[] | select(.type == "InternalIP").address) + " " + .status.capacity.cpu + " " + .status.capacity.memory')
    fi
    
    if [ -z "$NODE_INFO" ]; then
        check_status "Node-Informationen konnten nicht ermittelt werden. Ist der Cluster bereit?"
    fi

    TOTAL_CPU_CORES=0
    TOTAL_MEMORY_Mi=0
    
    echo "Gefundene Nodes:"
    echo "-------------------------"

    while read -r NODE_NAME NODE_IP CPU_CAP MEM_CAP; do
        if [[ "$NODE_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            if [ -z "$HA_LOAD_BALANCER_IPS" ]; then
                 HA_NODE_IPS+=("$NODE_IP")
            fi
        else
            echo "WARNUNG: Ungültige oder fehlende IP für Node ${NODE_NAME}. Wird ignoriert."
            continue
        fi

        TOTAL_CPU_CORES=$((TOTAL_CPU_CORES + CPU_CAP))
        if [[ "$MEM_CAP" =~ ^([0-9]+)Mi ]]; then
             TOTAL_MEMORY_Mi=$((TOTAL_MEMORY_Mi + ${BASH_REMATCH[1]}))
        elif [[ "$MEM_CAP" =~ ^([0-9]+)Gi ]]; then
             TOTAL_MEMORY_Mi=$((TOTAL_MEMORY_Mi + (${BASH_REMATCH[1]} * 1024)))
        fi
        
        echo "Node: ${NODE_NAME} (IP: ${NODE_IP}) - CPU: ${CPU_CAP}, RAM: ${MEM_CAP}"
    done <<< "$NODE_INFO"

    TOTAL_MEMORY_Gi=$(echo "scale=2; $TOTAL_MEMORY_Mi / 1024" | bc)

    echo "-------------------------"
    echo ""
    echo "--- 2. Gesamt-Ressourcen-Übersicht ---"
    echo "Gesamt CPU-Kerne (Capacity): ${TOTAL_CPU_CORES}"
    echo "Gesamt RAM (Capacity): ${TOTAL_MEMORY_Gi} GiB"
    echo "-----------------------------------------------------"
}
# -----------------------------------------------------------------------------
# 5. Dynamische Generierung der YAML-Manifeste
# -----------------------------------------------------------------------------

generate_manifests() {
    echo "### Generiere Kubernetes Manifeste (.yaml Dateien) ###"
    
    echo "➡️ Erstelle ha-pvc.yaml..."
    # ha-pvc.yaml
    cat <<EOF > ha-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ha-config-pvc
  namespace: ${K8S_NAMESPACE}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: ${HA_STORAGE_SIZE}
  storageClassName: ${HA_STORAGE_CLASS}
EOF
    check_status "ha-pvc.yaml erstellt"

    echo "➡️ Erstelle ha-deployment.yaml mit konfigurierten Ressourcen..."
    # ha-deployment.yaml
    cat <<EOF > ha-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: home-assistant-deployment
  namespace: ${K8S_NAMESPACE}
  labels:
    app: home-assistant
spec:
  replicas: 1
  selector:
    matchLabels:
      app: home-assistant
  template:
    metadata:
      labels:
        app: home-assistant
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
        - name: config-volume
          mountPath: /config
        securityContext:
          privileged: true 
      volumes:
      - name: config-volume
        persistentVolumeClaim:
          claimName: ha-config-pvc
EOF
    check_status "ha-deployment.yaml erstellt"

    echo "➡️ Erstelle ha-service.yaml (Typ: ${HA_SERVICE_TYPE})..."
    # ha-service.yaml
    cat <<EOF > ha-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ${HA_SERVICE_NAME}
  namespace: ${K8S_NAMESPACE}
spec:
  selector:
    app: home-assistant
  ports:
    - port: 8123
      targetPort: 8123
      protocol: TCP
      name: http
  type: ${HA_SERVICE_TYPE}
EOF
    
    if [ "${HA_SERVICE_TYPE}" == "LoadBalancer" ] && [ ${#HA_NODE_IPS[@]} -gt 0 ]; then
        echo "  loadBalancerIPs:" >> ha-service.yaml
        for ip in "${HA_NODE_IPS[@]}"; do
            echo "    - ${ip}" >> ha-service.yaml
        done
        echo "  externalTrafficPolicy: Cluster" >> ha-service.yaml
    fi
    
    check_status "ha-service.yaml erstellt (Typ: ${HA_SERVICE_TYPE})"

    echo "➡️ Erstelle ha-ingress.yaml (Host: ${HA_DOMAIN})..."
    # ha-ingress.yaml
    cat <<EOF > ha-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: home-assistant-ingress
  namespace: ${K8S_NAMESPACE}
spec:
  rules:
  - host: ${HA_DOMAIN}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ${HA_SERVICE_NAME}
            port:
              number: 8123
EOF
    check_status "ha-ingress.yaml erstellt"
}

# -----------------------------------------------------------------------------
# 6. Hauptinstallationslogik 
# -----------------------------------------------------------------------------

# NEUE Funktion für den Ticker
wait_for_pod_ready() {
    local TIMEOUT=300
    local INTERVAL=5
    local ELAPSED=0
    local SPINNER=('/' '-' '\' '|')
    local SPINNER_INDEX=0

    echo -n "Starte Home Assistant Pods (max. ${TIMEOUT}s)..."

    while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
        if kubectl get pod -n "$K8S_NAMESPACE" -l app=home-assistant -o jsonpath='{.items[0].status.containerStatuses[*].ready}' 2>/dev/null | grep -q "true"; then
            echo -e "\r✅ Pod bereit. Warte auf Home Assistant App-Start..."
            return 0 # Erfolg
        fi

        SPINNER_INDEX=$(( (SPINNER_INDEX + 1) % 4 ))
        echo -en "\r[${SPINNER[$SPINNER_INDEX]}] Warte auf Pod-Ready (${ELAPSED}/${TIMEOUT}s)... "
        
        sleep "$INTERVAL"
        ELAPSED=$((ELAPSED + INTERVAL))
    done

    echo -e "\r❌ Zeitüberschreitung (${TIMEOUT}s) beim Warten auf Pod-Ready."
    return 1 # Fehler
}


main_installation() {
    echo "### 🚀 Starte Kubernetes Deployment ###"

    echo "1/5: Erstelle/Prüfe Namespace '$K8S_NAMESPACE'..."
    kubectl create namespace "$K8S_NAMESPACE" 2>/dev/null || true
    check_status "Namespace '$K8S_NAMESPACE' erstellt/bestätigt"

    echo "2/5: Wende PVC-Definition an (Speicher: ${HA_STORAGE_SIZE})..."
    kubectl apply -f ha-pvc.yaml -n "$K8S_NAMESPACE"
    check_status "PVC angewendet"
    
    echo "3/5: Wende Service-Definition an (Typ: ${HA_SERVICE_TYPE})..."
    kubectl apply -f ha-service.yaml -n "$K8S_NAMESPACE"
    check_status "Service angewendet"
    
    echo "4/5: Wende Deployment-Definition an (Image: homeassistant/home-assistant:stable)..."
    kubectl apply -f ha-deployment.yaml -n "$K8S_NAMESPACE"
    kubectl wait --for=condition=available deployment/home-assistant-deployment -n "$K8S_NAMESPACE" --timeout=30s 2>/dev/null || true
    check_status "Deployment angewendet"
    
    echo "5/5: Wende Ingress-Definition an (Host: ${HA_DOMAIN})..."
    kubectl apply -f ha-ingress.yaml -n "$K8S_NAMESPACE"
    check_status "Ingress-Ressource angewendet"

    echo ""
    echo "### Starte: Finale Überprüfung des Home Assistant Pods ###"
    
    # Warte mit Ticker auf Pod-Ready
    wait_for_pod_ready
    check_status "Home Assistant Pod ist gestartet und bereit"

    echo ""
    echo "-----------------------------------------------------"
    echo "🎉 Installation erfolgreich abgeschlossen!"
    echo "➡️ Zugriffs-URL (über Ingress): http://$HA_DOMAIN"
    
    if [ "${HA_SERVICE_TYPE}" == "LoadBalancer" ]; then
        echo "➡️ Service Typ: LoadBalancer. Externe IPs: ${HA_NODE_IPS[*]}"
    fi
    echo "-----------------------------------------------------"
}
# -----------------------------------------------------------------------------
# 7. Skript Ausführung
# -----------------------------------------------------------------------------

if ! command -v jq &> /dev/null || ! command -v bc &> /dev/null || ! command -v curl &> /dev/null; then
    echo "❌ FEHLER: Die Tools 'jq', 'bc' und 'curl' sind für dieses Skript erforderlich."
    exit 1
fi

display_cluster_metrics_and_collect_ips
check_status "Cluster-Metriken und Node-IPs erfolgreich gesammelt"

collect_user_input

generate_manifests

main_installation

echo "--- Letzter Deployment-Zustand ---"
kubectl get deployment home-assistant-deployment -n "$K8S_NAMESPACE"
echo "------------------------------------"
