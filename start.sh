#!/bin/bash
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
