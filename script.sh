#!/bin/bash
# ============================================================
#               SCRIPT SMS
# ------------------------------------------------------------
# Creator   : Tayssir Mlaiki
# Function  : Lecture fichier données + génération & envoi SMS
# Version   : 3.0
# Created   : 2026-04-08
# Updated   : $(date +%Y-%m-%d)
# Location  : /home//reporting_automation/scripts/sms/
# Notes     : Script utilise config.txt pour rendre le traitement
#             totalement dynamique (destinations, from, data_file).
# ============================================================


# ------------------------------------------
# CHARGER CONFIGURATION EXTERNE
# ------------------------------------------
CONFIG_FILE="/home/reporting_automation/scripts/sms/config.txt"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERREUR : config.txt non trouvé !" >&2
    exit 1
fi

# Charger les variables depuis config.txt
source "$CONFIG_FILE"

DESTINATIONS="$destinations"
FROM_SMS="$from_sms"
DATA_FILE="$data_file"

# ------------------------------------------
# Paramètres
# ------------------------------------------
dir="/home/reporting_automation/scripts/sms/"
sysdate=$(date +%Y-%m-%d)
repertoire="$dir"
mkdir -p "${dir}archive/$sysdate/"
rep_archive="${dir}archive/$sysdate/"
BI_CONTENT_SMS="${dir}sms_$sysdate.txt"

# Répertoire des logs
mkdir -p "${dir}log"
log_file="${dir}log/execution_sms_${sysdate}.log"
touch "$log_file"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$log_file"
}

# Réinitialiser fichier SMS
> "$BI_CONTENT_SMS"

cd "$repertoire" || { log "ERREUR : impossible d'entrer dans $repertoire"; exit 1; }

BI_SEND_SMS="FALSE"

# ------------------------------------------
# FONCTION : Lire les données depuis fichier
# ------------------------------------------
lecture_fichier_donnees() {

    log "Début lecture du fichier de données : $DATA_FILE"

    if [ ! -f "$DATA_FILE" ]; then
        log "ERREUR : fichier de données introuvable : $DATA_FILE"
        exit 1
    fi

    if [ ! -s "$DATA_FILE" ]; then
        log "ERREUR : fichier de données vide !"
        exit 1
    fi

    # Lecture du fichier CSV : colonne "message" (colonne 1), triée par "ordre" (colonne 2)
    # Format attendu du fichier : message|ordre
    mapfile -t LINES < <(awk -F'|' 'NR>1 {gsub(/^[ \t]+|[ \t]+$/, "", $1); if ($1!="") print NR-1, $0}' "$DATA_FILE" \
        | sort -k1,1n \
        | awk -F'|' '{gsub(/^[0-9]+ /, "", $1); gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')

    if [ ${#LINES[@]} -eq 0 ]; then
        log "ERREUR : aucune ligne valide trouvée dans le fichier !"
        exit 1
    fi

    log "Lecture OK : ${#LINES[@]} ligne(s) récupérée(s)"

    printf "%s|" "${LINES[@]}"
}

# Lecture fichier données
msg=$(lecture_fichier_donnees)
log "DEBUG msg = $msg"

IFS='|' read -ra LINES <<< "$msg"

# ------------------------------------------
# FONCTION : Générer contenu SMS
# ------------------------------------------
SEND_ALERTE() {
    for l in "${LINES[@]}"; do
        [ -n "$l" ] && printf "%-1s\n" "$l" >> "$BI_CONTENT_SMS"
    done

    BI_SEND_SMS="TRUE"
    log "Contenu SMS généré"
}

# ------------------------------------------
# FONCTION : Envoi SMS
# ------------------------------------------
SEND_SMS() {

    log "Début envoi SMS"

    from="$FROM_SMS"
    days="$(date +'%Y%m%d%H%M')"
    baseFile="POCVF"
    Message="$(tr -d '\n' < "$BI_CONTENT_SMS")"

    IFS=',' read -ra nums <<< "$DESTINATIONS"
    for i in "${nums[@]}"; do

        bid="${days}${i}${baseFile}"

        json=$(printf '{
            "from":"%s","validity":6,"priority":1,"update":1,"updates":"1h",
            "canal":"SMS","bid":"%s","differed":1,"type":2000,"text":"%s",
            "callback":"http://127.0.0.1/smsing/callback/save",
            "actions":[{"idAction":111,"to":"%s"}]
        }' "$from" "$bid" "$Message" "$i")

        curl -s -X POST "votre_api" \
            -H "Content-Type: application/json" \
            -H "Authorization: 123" \
            -d "$json" >> "$log_file" 2>&1
    done

    log "SMS envoyés ✔"
}

# ------------------------------------------
# Main
# ------------------------------------------
SEND_ALERTE

if [ "$BI_SEND_SMS" = "TRUE" ]; then
    SEND_SMS
    mv "$BI_CONTENT_SMS" "$rep_archive"
    log "Fichier SMS archivé"
else
    log "Aucun SMS à envoyer"
fi

log "==== Fin du script ===="
