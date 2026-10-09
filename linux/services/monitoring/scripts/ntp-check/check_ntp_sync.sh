#!/bin/bash

COMMAND=$(ntpq -pn | grep -F '*' | awk '{print $1}' | cut -d "*" -f 2)
TIME=$(ntpq -pn | grep -F '*' | awk '{print $9}')

if [ -z "$COMMAND" ]; then
  echo "CRITICAL - NTP Server no synchronize"
  exit 2
else
  echo "OK - Synchronized with the server : $COMMAND Time: $TIME"
  exit 0
fi
