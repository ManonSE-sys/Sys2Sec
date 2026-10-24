#!/bin/bash

BASELINE="baseline.txt"
CONFIG="files.conf"

case "$1" in
	--init)
		echo "Création de la baseline..."
		> "$BASELINE"

		while read -r FILE; do
			if [ -f "$FILE" ]; then
				sha256sum "$FILE" >> "$BASELINE"
			else
				echo "WARNING - Fichier introuvable : $FILE"
			fi
		done < "$CONFIG"

		echo "Baseline crée dans $BASELINE"
		;;

	--check)
		echo "Vérification de l'intégrité..."

		STATUS=0

		while read -r EXPECTED_HASH FILE; do
			if [ ! "$FILE" ]; then
				echo "CRITICAL - Fichier absent : $FILE"
				STATUS=2
				continue
			fi

			CURRENT_HASH=$(sha256sum "$FILE" | awk '{print $1}')

			if [ "$CURRENT_HASH" = "$EXPECTED_HASH" ]; then
				echo "OK - $FILE inchangé"
			else
				echo "CRITICAL - $FILE modifié"
				STATUS=2
			fi

		done < "$BASELINE"
		exit $STATUS
		;;
	
	*)
		echo "Usage : $0 --init | --check"
		exit 3
		;;
esac
