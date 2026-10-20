#!/bin/bash

LOG_FILE="/var/log/application.log"
PATTERN="phrase à rechercher"

if grep -q "$PATTERN" "$LOG_FILE"; then
    echo "OK - La phrase a été trouvée dans le fichier de log"
    exit 0
else
    echo "CRITICAL - La phrase n'a pas été trouvée dans le fichier de log"
    exit 2
fi
