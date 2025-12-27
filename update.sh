#!/bin/bash
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

# NEU: Funktion zur System-Wartung
perform_system_update() {
    echo ""
    echo "======================================================="
    echo "💻 STARTE HOST-SYSTEM-WARTUNG (APT)"
    echo "======================================================="
    
    # Befehle zur Systemaktualisierung (erfordert sudo/Root-Rechte)
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

# ... (Git-Klonen/Update-Logik) ...

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
