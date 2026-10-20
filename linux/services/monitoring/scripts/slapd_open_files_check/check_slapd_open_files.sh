#!/bin/bash

WARNING=500
CRITICAL=800

PID=$(pgrep -x slapd)

if [ -z "$PID" ]; then
    echo "CRITICAL - Le processus slapd n'est pas démarré"
    exit 2
fi

OPEN_FILES=$(lsof -p "$PID" 2>/dev/null | tail -n +2 | wc -l)

if [ "$OPEN_FILES" -ge "$CRITICAL" ]; then
    echo "CRITICAL - slapd utilise $OPEN_FILES fichiers ouverts"
    exit 2
elif [ "$OPEN_FILES" -ge "$WARNING" ]; then
    echo "WARNING - slapd utilise $OPEN_FILES fichiers ouverts"
    exit 1
else
    echo "OK - slapd utilise $OPEN_FILES fichiers ouverts"
    exit 0
fi
