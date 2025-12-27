#!/bin/bash
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
    # ... (kubectl scale --replicas=0 Logik) ...
}

# Funktion zum Starten (Skalieren auf 1 Replika)
start_deployment() {
    # ... (kubectl scale --replicas=1 Logik) ...
}

# Funktion zum Neustarten (Rolling Restart)
restart_deployment() {
    # ... (kubectl rollout restart Logik) ...
}

# Funktion zur vollständigen Deinstallation
uninstall_homeassistant() {
    # ... (kubectl delete Logik für Deployment, Service, PVC, Namespace) ...
}

# Hauptmenü für Steuerung
control_menu() {
    # ... (Menü-Ausgabe und case-Anweisung) ...
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    control_menu
fi
