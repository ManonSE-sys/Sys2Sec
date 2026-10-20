# Vérification de la présence d'une phrase dans un fichier de log

## Présentation

Ce projet contient un script Bash permettant de vérifier si une phrase précise est présente dans un fichier de log.

Le script s'appuie sur la commande :

```bash
grep
```

Il recherche une chaîne de caractères définie dans un fichier de log donné.

Si la phrase est trouvée, le script retourne un état `OK`.

Si la phrase n'est pas trouvée, le script retourne un état `CRITICAL`.

---

## Objectif

Ce script permet de :

- vérifier automatiquement la présence d'un message attendu dans un fichier de log ;
- détecter l'absence d'un événement ou d'une information importante ;
- retourner un code de sortie exploitable par un outil de supervision ;
- automatiser un contrôle simple sur les journaux d'une application ou d'un service.

---

## Fonctionnement

Le script définit deux variables :

```bash
LOG_FILE="/var/log/application.log"
PATTERN="phrase à rechercher"
```

La variable `LOG_FILE` contient le chemin du fichier de log à analyser.

La variable `PATTERN` contient la phrase recherchée.

Le script utilise ensuite :

```bash
grep -q "$PATTERN" "$LOG_FILE"
```

L'option `-q` permet à `grep` de fonctionner en mode silencieux.

Aucun résultat n'est affiché directement par `grep`. Le script utilise uniquement son code de retour pour déterminer si la phrase a été trouvée.

Le fonctionnement est donc le suivant :

```text
Lecture du fichier de log
        │
        ▼
Recherche de la phrase
        │
     ┌──┴──┐
     │     │
   Trouvée Absente
     │     │
     ▼     ▼
    OK   CRITICAL
 exit 0   exit 2
```

---

## Script

Le script Bash peut être stocké dans un fichier comme :

[`check_log_pattern.sh`](check_log_pattern.sh)

Son contenu :

```bash
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
```

---

## Codes de retour

Le script utilise deux codes de sortie :

| Code | État | Description |
|---|---|---|
| `0` | OK | La phrase recherchée a été trouvée |
| `2` | CRITICAL | La phrase recherchée n'a pas été trouvée |

Ces codes permettent d'intégrer facilement le script à une solution de supervision.

---

## Exemple d'exécution

### Phrase présente

Si le fichier contient :

```text
Application started successfully
```

et que la variable contient :

```bash
PATTERN="Application started successfully"
```

le script retourne :

```text
OK - La phrase a été trouvée dans le fichier de log
```

Code retour :

```text
0
```

---

### Phrase absente

Si la phrase recherchée n'est pas présente dans le fichier :

```text
CRITICAL - La phrase n'a pas été trouvée dans le fichier de log
```

Code retour :

```text
2
```

---

## Prérequis

Le script nécessite :

- Bash ;
- la commande `grep` ;
- un fichier de log accessible par l'utilisateur exécutant le script.

Le fichier défini dans :

```bash
LOG_FILE="/var/log/application.log"
```

doit être lisible.

---

## Utilisation

Rendre le script exécutable :

```bash
chmod +x check_log_pattern.sh
```

Puis l'exécuter :

```bash
./check_log_pattern.sh
```

Avant l'exécution, adapter les variables :

```bash
LOG_FILE="/var/log/application.log"
PATTERN="phrase à rechercher"
```

---

## Intégration supervision

Ce type de script peut être utilisé comme contrôle personnalisé dans un outil de supervision.

Le principe repose sur le code de retour :

```text
Analyse du log
      │
      ▼
Phrase présente ?
      │
   ┌──┴──┐
   │     │
  Oui   Non
   │     │
   ▼     ▼
  OK   CRITICAL
exit 0  exit 2
```

Le script peut ainsi être utilisé comme base pour un plugin de supervision Linux.

---

## Ce que ce script met en pratique

Ce projet permet de travailler sur :

- Bash ;
- lecture et analyse de fichiers de log ;
- utilisation de `grep` ;
- conditions avec `if` ;
- codes de retour ;
- automatisation de contrôles ;
- logique de supervision Linux.

---

## Améliorations possibles

Plusieurs évolutions peuvent être envisagées :

- vérifier que le fichier de log existe ;
- vérifier que le fichier est lisible ;
- gérer un état `UNKNOWN` avec le code `3` ;
- gérer un état `WARNING` avec le code `1` ;
- passer le chemin du fichier en paramètre ;
- passer la phrase recherchée en paramètre ;
- limiter la recherche aux dernières lignes du fichier avec `tail` ;
- rechercher une expression régulière ;
- ajouter une option `--help` ;
- adapter le format de sortie à Nagios ou Centreon.

Par exemple :

```bash
./check_log_pattern.sh \
  -f /var/log/application.log \
  -p "Application started successfully"
```

---

## Notes

Ce script est volontairement simple.

Il constitue une base pour construire des contrôles de supervision plus complets autour de l'analyse de fichiers de log.
