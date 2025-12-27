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
