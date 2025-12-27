Absolut! Um Ihnen das Kopieren und Speichern zu erleichtern, habe ich alle sechs Dateien in einem Markdown-Format zusammengefasst, wobei jede Datei klar durch einen Header getrennt ist.Anleitung zur Verwendung:Kopieren Sie den gesamten folgenden Textblock.Fügen Sie ihn in Ihren bevorzugten Texteditor ein (z. B. VS Code, Sublime Text, oder Vim).Erstellen Sie dann manuell die sechs einzelnen Dateien, indem Sie den Inhalt zwischen den Trennlinien (--- DATEI: [Name] ---) in die jeweilige Datei kopieren.💾 Exportfähiges K3S HA Installer Projektpaket1. Datei: README.mdMarkdown# 🏠 K3S Home Assistant Installer

Willkommen beim K3S Home Assistant Installer – Ihrem umfassenden Toolset zur automatisierten Bereitstellung und Wartung von Home Assistant in einem K3S- oder generischen Kubernetes-Cluster.

Dieses Projekt bietet ein vollautomatisches Menü-gesteuertes Erlebnis, das von der Erstanalyse der Cluster-Ressourcen bis hin zu Start/Stopp-Operationen und Updates alles abdeckt.

---

## ✨ Features im Überblick

* **Menü-Gesteuert (`start.sh`):** Einfacher Zugriff auf alle Funktionen über ein Hauptmenü.
* **Persistente Konfiguration:** Alle Einstellungen (Domain, Speicher, Ressourcen) werden in der Datei `settings.conf` gespeichert.
* **Dynamische Manifeste:** YAML-Dateien werden basierend auf den Einstellungen und den erkannten Node-IPs zur Laufzeit generiert.
* **Ressourcen-Management:** Konfigurierbare CPU- und Memory Requests/Limits zur Sicherstellung der Dienstqualität (QoS).
* **Auto-Debugging & KI-Analyse (Optional):** Bei Installationsfehlern werden automatisch Logs und Zustände gesammelt und optional zur KI-gestützten Fehleranalyse an die Google Gemini API gesendet. 
* **Wartungs-Tools:** Direkte Steuerung über **`control.sh`** (Start, Stopp, Neustart, Deinstallation).
* **Automatischer Updater:** Integrierte Git-Update-Logik über **`update.sh`** inklusive **Host-System-Wartung (apt)**.

---

## 🛠️ Voraussetzungen

Bevor Sie das Tool verwenden, stellen Sie sicher, dass Ihr Hostsystem folgende Voraussetzungen erfüllt:

1.  **k3s/Kubernetes:** Ein funktionierender Cluster muss installiert und der `kubectl`-Zugriff konfiguriert sein.
2.  **Bash:** Ein Linux-basisiertes System (oder WSL) mit Bash-Unterstützung.
3.  **Befehlszeilen-Tools:** Die folgenden Pakete müssen installiert sein: `kubectl`, `git`, `jq`, `bc` und `curl`.

---

## 🚀 Installation und erster Start

Der schnellste Weg, das Installationspaket zu klonen und zu starten:

```bash
sudo apt update && sudo apt install git -y && git clone [https://github.com/diggerwf/K3S-Home-Assistant-installer.git](https://github.com/diggerwf/K3S-Home-Assistant-installer.git) && cd K3S-Home-Assistant-installer && chmod +x start.sh && ./start.sh
Manuelle Schritte (Falls der Ein-Zeilen-Befehl fehlschlägt)Klone das Repository:Bashgit clone [https://github.com/diggerwf/K3S-Home-Assistant-installer.git](https://github.com/diggerwf/K3S-Home-Assistant-installer.git)
cd K3S-Home-Assistant-installer
Ausführberechtigung setzen:Bashchmod +x start.sh
Starten des Hauptmenüs:Bash./start.sh
⚙️ Konfiguration (settings.conf)Die Datei settings.conf enthält alle permanenten Konfigurationen. Es wird empfohlen, diese Datei vor dem ersten Start anzupassen.VariableBeispielwertBeschreibungHA_DOMAINha.meinecloud.deHostname für den Kubernetes Ingress-Zugriff.HA_STORAGE_SIZE5GiGröße des persistenten Speichervolumens (PVC).HA_CPU_REQUEST500mCPU-Anforderung für den Home Assistant Pod (500m = 0.5 Cores).HA_MEMORY_LIMIT2GiMaximaler RAM-Verbrauch des Home Assistant Pods.HA_LOAD_BALANCER_IPS""Leer lassen für automatische Node-IPs.GEMINI_API_KEY""Ihr API-Schlüssel für die optionale KI-gestützte Fehleranalyse.📝 Funktionsanleitung (Menü-Optionen)1) Installer / Konfiguration starten (HA-Installer.sh)Dieser Menüpunkt wendet die Konfiguration aus settings.conf an und startet das Deployment. Im Fehlerfall wird ein Auto-Debugging durchgeführt, das Logs und Zustände sammelt.2) Update prüfen und durchführen (update.sh)Dieser Punkt führt zwei kritische Aufgaben aus:Projekt-Update: Holt die neuesten Skripte vom Git-Repository.Host-Wartung: Führt sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y aus, um das zugrundeliegende Betriebssystem aktuell zu halten.3) Steuerung und Wartung (control.sh)Öffnet das Untermenü für Wartungsoperationen auf dem laufenden Deployment.🗃️ DateistrukturDas vollständige Paket besteht aus den sechs Dateien: README.md, start.sh, settings.conf, HA-Installer.sh, control.sh, update.sh.
--- DATEI: `README.md` ENDE ---

### 2. Datei: `settings.conf`

```ini
# -----------------------------------------------------------------------------
# settings.conf - HA K3S Installer Konfiguration
# 
# Diese Datei wird von HA-Installer.sh und start.sh gelesen.
# Wenn Werte hier gesetzt sind, werden sie NICHT interaktiv abgefragt.
# -----------------------------------------------------------------------------

# ==================================
# Allgemeine Konfiguration
# ==================================
HA_DOMAIN="ha.ihredomain.local"
HA_TIMEZONE="Europe/Berlin"
HA_STORAGE_SIZE="5Gi"
HA_STORAGE_CLASS="local-path"

# ==================================
# Kubernetes Ressourcen
# (Werte für das Deployment-Template)
# ==================================
# CPU: in m (Millicores, z.B. 1000m = 1 CPU-Kern)
# RAM: in Mi (Mebibytes) oder Gi (Gibibytes)
HA_CPU_REQUEST="500m"
HA_CPU_LIMIT="1000m"
HA_MEMORY_REQUEST="1Gi"
HA_MEMORY_LIMIT="2Gi"

# ==================================
# Load Balancer & Debugging
# ==================================
# Load Balancer IPs: Leer lassen für automatische Node-IP-Erkennung (empfohlen).
# Oder feste IPs für MetalLB eintragen (z.B. "192.168.1.10,192.168.1.11")
HA_LOAD_BALANCER_IPS=""

# Gemini API Key für erweiterte Fehleranalyse. Leer lassen, um abzuschalten.
GEMINI_API_KEY=""
--- DATEI: settings.conf ENDE ---3. Datei: start.shBash#!/bin/bash
#
# start.sh - Hauptmenü und Kontrollzentrum für den K3S Home Assistant Installer

# -----------------------------------------------------------------------------
# 1. Konfiguration und Pfade
# -----------------------------------------------------------------------------
INSTALLER_SCRIPT="./HA-Installer.sh"
UPDATE_SCRIPT="./update.sh"
CONTROL_SCRIPT="./control.sh"
SETTINGS_FILE="./settings.conf"

# Liste aller benötigten Skripte/Dateien im aktuellen Verzeichnis
REQUIRED_FILES=(
    "start.sh"
    "$INSTALLER_SCRIPT"
    "$UPDATE_SCRIPT"
    "$CONTROL_SCRIPT"
    "$SETTINGS_FILE"
)

# -----------------------------------------------------------------------------
# 2. Berechtigungsprüfung und -korrektur
# -----------------------------------------------------------------------------

check_and_set_permissions() {
    local PERMISSION_CHECK=0
    
    echo "### ⚙️ Berechtigungsprüfung und Dateiverfügbarkeit ###"

    # Prüfen, ob alle notwendigen Dateien existieren
    for file in "${REQUIRED_FILES[@]}"; do
        if [ ! -f "$file" ]; then
            echo "❌ FEHLER: Benötigte Datei '$file' nicht gefunden."
            if [ "$file" == "$SETTINGS_FILE" ]; then
                echo "➡️ VERSUCHE: Erstelle leere $SETTINGS_FILE..."
                touch "$SETTINGS_FILE"
                if [ $? -ne 0 ]; then
                    echo "❌ FEHLER: Konnte '$SETTINGS_FILE' nicht erstellen. Berechtigungen prüfen."
                    exit 1
                fi
            else
                echo "Das Skript kann ohne diese Datei nicht fortfahren."
                exit 1
            fi
        fi
    done
    
    # Prüfen und Setzen der Berechtigungen für alle *Skripte*
    if [ ! -x "./start.sh" ] || [ ! -x "$INSTALLER_SCRIPT" ] || [ ! -x "$UPDATE_SCRIPT" ] || [ ! -x "$CONTROL_SCRIPT" ]; then
        echo "⚠️ ACHTUNG: Eines oder mehrere Skripte haben keine Ausführberechtigung."
        PERMISSION_CHECK=1
    fi
    
    if [ "$PERMISSION_CHECK" -eq 1 ]; then
        echo "➡️ Korrigiere Berechtigungen automatisch..."
        chmod +x "$INSTALLER_SCRIPT" "$UPDATE_SCRIPT" "$CONTROL_SCRIPT" "./start.sh"
        
        if [ $? -eq 0 ]; then
            echo "✅ Berechtigungen (+x) für alle Skripte erfolgreich gesetzt."
        else
            echo "❌ FEHLER: Konnte Berechtigungen nicht automatisch setzen. Führen Sie 'chmod +x *.sh' manuell aus."
            exit 1
        fi
    else
        echo "✅ Alle benötigten Dateien sind vorhanden und Skripte sind ausführbar."
    fi
    echo "--------------------------------------------------------"
}

# -----------------------------------------------------------------------------
# 3. Hauptlogik Funktionen
# -----------------------------------------------------------------------------

run_installer_check() {
    echo "Starte: Home Assistant Installer oder Einstellungsprüfung..."
    bash "$INSTALLER_SCRIPT"
    echo "--------------------------------------------------------"
}

run_update() {
    echo "Starte: Update-Prozess..."
    bash "$UPDATE_SCRIPT"
    echo "--------------------------------------------------------"
}

run_control_menu() {
    echo "Starte: Steuerung und Wartung..."
    bash "$CONTROL_SCRIPT"
    echo "--------------------------------------------------------"
}


# -----------------------------------------------------------------------------
# 4. Hauptmenü
# -----------------------------------------------------------------------------

main_menu() {
    # Lade die Konfiguration, um aktuelle Werte anzuzeigen
    if [ -f "$SETTINGS_FILE" ]; then
        source "$SETTINGS_FILE" 2>/dev/null
    fi
    
    while true; do
        echo ""
        echo "======================================================="
        echo "🏠 K3S Home Assistant Installer - Hauptmenü"
        echo "======================================================="
        echo "   Host/Domain: $HA_DOMAIN" 
        echo "   Speicher: $HA_STORAGE_SIZE ($HA_STORAGE_CLASS)" 
        echo "======================================================="
        echo "1) Installer / Konfiguration starten (HA-Installer.sh)"
        echo "2) Update prüfen und durchführen (update.sh)"
        echo "3) 🔧 Steuerung und Wartung (Start/Stopp/Deinstall. -> control.sh)"
        echo "4) Exit"
        echo "-------------------------------------------------------"
        read -rp "Wählen Sie eine Option (1-4): " choice

        case "$choice" in
            1)
                run_installer_check
                ;;
            2)
                run_update
                ;;
            3)
                run_control_menu
                ;;
            4)
                echo "Installation beendet. Auf Wiedersehen!"
                exit 0
                ;;
            *)
                echo "Ungültige Auswahl. Bitte geben Sie 1 bis 4 ein."
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# 5. Skript-Ausführung
# -----------------------------------------------------------------------------

check_and_set_permissions
main_menu
--- DATEI: start.sh ENDE ---4. Datei: HA-Installer.shBash#!/bin/bash
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
    fi
    
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
        GEMINI_API_KEY=${input_key}
    fi
    
    # Standard-Konfigurationen: Nur abfragen, wenn der Wert leer ist
    read -rp "1. Domänen-/Host-Name (Aktuell: $HA_DOMAIN): " input_domain
    HA_DOMAIN=${input_domain:-$HA_DOMAIN}
    
    read -rp "2. Zeitzone (Aktuell: $HA_TIMEZONE): " input_tz
    HA_TIMEZONE=${input_tz:-$HA_TIMEZONE}
    
    read -rp "3. Speichergröße (Aktuell: $HA_STORAGE_SIZE): " input_size
    HA_STORAGE_SIZE=${input_size:-$HA_STORAGE_SIZE}
    
    read -rp "4. StorageClass (Aktuell: $HA_STORAGE_CLASS): " input_class
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
# 5. Dynamische Generierung der YAML-Manifeste (AKTUALISIERT mit Ressourcen)
# -----------------------------------------------------------------------------

generate_manifests() {
    echo "### Generiere Kubernetes Manifeste (.yaml Dateien) ###"
    
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

    # ha-deployment.yaml (NEU: Requests/Limits aus settings.conf)
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
main_installation() {
    echo "### 🚀 Starte Kubernetes Deployment ###"

    kubectl create namespace "$K8S_NAMESPACE" 2>/dev/null || true
    check_status "Namespace '$K8S_NAMESPACE' erstellt/bestätigt"

    kubectl apply -f ha-pvc.yaml -n "$K8S_NAMESPACE"
    check_status "1/4: PVC angewendet"
    kubectl apply -f ha-service.yaml -n "$K8S_NAMESPACE"
    check_status "2/4: Service angewendet"
    kubectl apply -f ha-deployment.yaml -n "$K8S_NAMESPACE"
    kubectl wait --for=condition=available deployment/home-assistant-deployment -n "$K8S_NAMESPACE" --timeout=30s 2>/dev/null || true
    check_status "3/4: Deployment angewendet"
    kubectl apply -f ha-ingress.yaml -n "$K8S_NAMESPACE"
    check_status "4/4: Ingress-Ressource angewendet"

    echo "### Starte: Finale Überprüfung des Home Assistant Pods ###"
    echo "Warte maximal 300 Sekunden, bis der Home Assistant Pod bereit ist..."
    kubectl wait --for=condition=ready pod -l app=home-assistant -n "$K8S_NAMESPACE" --timeout=300s
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
--- DATEI: HA-Installer.sh ENDE ---5. Datei: control.shBash#!/bin/bash
#
# control.sh - Steuerung und Wartung des Home Assistant Deployments
#
K8S_NAMESPACE="home-assistant"
HA_DEPLOYMENT="home-assistant-deployment"
HA_PVC="ha-config-pvc"
HA_SERVICE="home-assistant-service"
HA_INGRESS="home-assistant-ingress"

# Funktion zum Stoppen (Skalieren auf 0 Replikas)
stop_deployment() {
    echo "--- 🛑 Stoppe Home Assistant Deployment ---"
    kubectl scale deployment "$HA_DEPLOYMENT" -n "$K8S_NAMESPACE" --replicas=0
    if [ $? -eq 0 ]; then
        echo "✅ Home Assistant Deployment erfolgreich gestoppt (Replikas: 0)."
    else
        echo "❌ FEHLER: Stoppen fehlgeschlagen. Ist der Namespace '$K8S_NAMESPACE' aktiv?"
    fi
}

# Funktion zum Starten (Skalieren auf 1 Replika)
start_deployment() {
    echo "--- ▶️ Starte Home Assistant Deployment ---"
    kubectl scale deployment "$HA_DEPLOYMENT" -n "$K8S_NAMESPACE" --replicas=1
    if [ $? -eq 0 ]; then
        echo "✅ Home Assistant Deployment erfolgreich gestartet (Replikas: 1)."
        echo "Warte auf Ready-Status (max. 60s)..."
        kubectl wait --for=condition=ready pod -l app=home-assistant -n "$K8S_NAMESPACE" --timeout=60s 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✅ Home Assistant Pod ist wieder bereit."
        else
            echo "⚠️ Zeitüberschreitung: Pod wurde gestartet, ist aber noch nicht Ready."
        fi
    else
        echo "❌ FEHLER: Starten fehlgeschlagen. Ist das Deployment '$HA_DEPLOYMENT' vorhanden?"
    fi
}

# Funktion zum Neustarten (Rolling Restart)
restart_deployment() {
    echo "--- 🔄 Starte Home Assistant Deployment neu ---"
    kubectl rollout restart deployment "$HA_DEPLOYMENT" -n "$K8S_NAMESPACE"
    if [ $? -eq 0 ]; then
        echo "✅ Neustart (Rolling Update) ausgelöst."
        echo "Warte auf Abschluss des Rollouts (max. 120s)..."
        kubectl rollout status deployment "$HA_DEPLOYMENT" -n "$K8S_NAMESPACE" --timeout=120s
        if [ $? -eq 0 ]; then
            echo "✅ Neustart erfolgreich abgeschlossen."
        fi
    else
        echo "❌ FEHLER: Neustart fehlgeschlagen."
    fi
}

# Funktion zur vollständigen Deinstallation
uninstall_homeassistant() {
    echo ""
    echo "====================================================="
    echo "⚠️ WARNUNG: Deinstallation von Home Assistant"
    echo "====================================================="
    echo "Alle zugehörigen Kubernetes-Ressourcen werden GELÖSCHT."
    read -rp "Sind Sie SICHER, dass Sie Home Assistant deinstallieren möchten? (ja/nein): " confirm

    if [[ "$confirm" == "ja" ]]; then
        echo "--- Starte Deinstallation ---"
        
        kubectl delete deployment "$HA_DEPLOYMENT" -n "$K8S_NAMESPACE" 2>/dev/null
        kubectl delete service "$HA_SERVICE" -n "$K8S_NAMESPACE" 2>/dev/null
        kubectl delete ingress "$HA_INGRESS" -n "$K8S_NAMESPACE" 2>/dev/null
        
        kubectl delete pvc "$HA_PVC" -n "$K8S_NAMESPACE" 2>/dev/null

        kubectl delete namespace "$K8S_NAMESPACE" 2>/dev/null
        
        echo ""
        echo "🎉 Deinstallation abgeschlossen. Der Namespace '$K8S_NAMESPACE' wird gelöscht."
        
    else
        echo "Deinstallation abgebrochen."
    fi
}

# Hauptmenü für Steuerung
control_menu() {
    while true; do
        echo ""
        echo "======================================================="
        echo "🔧 Steuerung Home Assistant Deployment"
        echo "======================================================="
        echo "1) ▶️ Starten des Deployments"
        echo "2) 🛑 Stoppen des Deployments (Replikas = 0)"
        echo "3) 🔄 Neustart (Rolling Update)"
        echo "4) 🗑️ Deinstallation (Löscht alle Ressourcen und den PVC/Daten!)"
        echo "5) ↩️ Zurück zum Hauptmenü"
        echo "-------------------------------------------------------"
        read -rp "Wählen Sie eine Option (1-5): " choice

        case "$choice" in
            1)
                start_deployment
                ;;
            2)
                stop_deployment
                ;;
            3)
                restart_deployment
                ;;
            4)
                uninstall_homeassistant
                return
                ;;
            5)
                return 
                ;;
            *)
                echo "Ungültige Auswahl. Bitte geben Sie 1 bis 5 ein."
                ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    control_menu
fi
--- DATEI: control.sh ENDE ---6. Datei: update.shBash#!/bin/bash
#
# update.sh - Vollautomatische Prüfung und Durchführung von Updates
#
REPO_URL="https://github.com/diggerwf/K3S-Home-Assistant-installer.git"
BRANCH="main"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Pfade zu den wichtigsten Skripten
INSTALLER_SCRIPT="$REPO_DIR/HA-Installer.sh"
MAIN_SCRIPT="$REPO_DIR/start.sh" 
CONTROL_SCRIPT="$REPO_DIR/control.sh"
UPDATE_SCRIPT="$REPO_DIR/update.sh"

# Funktion: Aktuellen Commit-Hash lokal abrufen
get_current_hash() {
    git rev-parse HEAD 2>/dev/null
}

# Funktion: Remote-Commit-Hash vom Repository abrufen
get_remote_hash() {
    git ls-remote "$REPO_URL" "$BRANCH" | awk '{print $1}'
}

# Funktion: Stellt sicher, dass die wichtigen Skripte ausführbar sind
set_permissions() {
    chmod +x "$INSTALLER_SCRIPT" "$MAIN_SCRIPT" "$CONTROL_SCRIPT" "$UPDATE_SCRIPT" 2>/dev/null
}

# Funktion zur System-Wartung (APT)
perform_system_update() {
    echo ""
    echo "======================================================="
    echo "💻 STARTE HOST-SYSTEM-WARTUNG (APT)"
    echo "======================================================="
    
    if command -v apt &> /dev/null; then
        echo "➡️ Führe apt update, full-upgrade und autoremove durch..."
        
        sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y
        
        if [ $? -eq 0 ]; then
            echo "✅ Host-System-Wartung abgeschlossen."
        else
            echo "❌ FEHLER: Host-System-Wartung fehlgeschlagen (Prüfen Sie sudo/Root-Rechte)."
        fi
    else
        echo "⚠️ APT nicht gefunden. Überspringe System-Wartung."
    fi
}


echo "======================================================="
echo "🔄 K3S HA Installer - Automatischer Update-Dienst"
echo "======================================================="

cd "$REPO_DIR" || { echo "❌ FEHLER: Konnte nicht in das Repository-Verzeichnis ($REPO_DIR) wechseln."; exit 1; }

if [ -d "$REPO_DIR/.git" ]; then
    
    echo "Status: Repository (.git) gefunden. Prüfe auf neue Commits..."

    git fetch origin > /dev/null 2>&1
    
    LOCAL_HASH=$(get_current_hash)
    REMOTE_HASH=$(get_remote_hash)

    if [ -z "$REMOTE_HASH" ]; then
        echo "❌ FEHLER: Konnte den Remote-Hash nicht abrufen. Überprüfen Sie die URL und die Internetverbindung."
        exit 1
    fi

    if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
        echo "✅ Update erkannt. Starte automatischen Pull von $BRANCH..."

        git reset --hard > /dev/null 2>&1
        git pull origin "$BRANCH" || { echo "❌ FEHLER: Git Pull fehlgeschlagen."; exit 1; }
        
        set_permissions
        
        echo "🎉 Projekt-Update abgeschlossen!"
        
    else
        echo "Das Projekt ist bereits aktuell (Hash: $LOCAL_HASH). Keine Aktion erforderlich."
    fi

else
    
    echo "Status: Repository (.git) nicht gefunden. Starte Klonen..."
    
    git clone "$REPO_URL" "$REPO_DIR/temp_clone" || { echo "❌ FEHLER: Klonen fehlgeschlagen."; exit 1; }
    
    mv "$REPO_DIR/temp_clone"/* "$REPO_DIR"/
    rm -rf "$REPO_DIR/temp_clone"
    
    set_permissions
    
    echo "🎉 Repository erfolgreich von $REPO_URL geklont."
fi

# Führe System-Wartung durch, unabhängig vom Git-Ergebnis
perform_system_update

echo "======================================================="
echo "Update-Prozess beendet."
exit 0
