# Vérification de la synchronisation NTP

## Présentation

Ce projet contient un script Bash permettant de vérifier si un serveur Linux est correctement synchronisé avec une source NTP.

Le script s'appuie sur la commande :

```bash
ntpq -pn
```

Il recherche la source NTP actuellement sélectionnée, identifiée par le caractère `*`.

Si aucune source synchronisée n'est trouvée, le script retourne un état critique.

---

## Objectif

Ce script permet de :

- vérifier la présence d'une source NTP synchronisée ;
- identifier le serveur NTP utilisé ;
- récupérer l'offset associé ;
- retourner un code de sortie exploitable par un outil de supervision.

---

## Fonctionnement

Le script interroge `ntpq` afin d'identifier la source NTP active.

Exemple simplifié de sortie :

```text
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*192.0.2.10      203.0.113.1      2 u   32   64  377    0.421   -0.214   0.128
```

Le caractère `*` indique la source actuellement utilisée pour la synchronisation.

Le script récupère ensuite :

- l'adresse du serveur NTP ;
- la valeur d'offset.

---

## Script

Le script Bash est disponible ici :

[`check_ntp_sync.sh`](check_ntp_sync.sh)

---

## Codes de retour

Le script utilise deux codes de sortie :

| Code | État | Description |
|---|---|---|
| `0` | OK | Une source NTP synchronisée a été trouvée |
| `2` | CRITICAL | Aucune source NTP synchronisée n'a été trouvée |

Ces codes permettent d'intégrer facilement le script à une solution de supervision.

---

## Exemple d'exécution

### Synchronisation présente

```text
OK - Synchronized with the server : 192.0.2.10 Time: -0.214
```

Code retour :

```text
0
```

### Aucune synchronisation

```text
CRITICAL - NTP Server no synchronize
```

Code retour :

```text
2
```

---

## Prérequis

Le script nécessite :

- Bash ;
- la commande `ntpq` ;
- un service NTP compatible avec cette commande.

La commande suivante doit être disponible :

```bash
ntpq -pn
```

---

## Utilisation

Rendre le script exécutable :

```bash
chmod +x check_ntp_sync.sh
```

Puis l'exécuter :

```bash
./check_ntp_sync.sh
```

---

## Intégration supervision

Le script peut être utilisé comme base pour un contrôle de supervision.

Son fonctionnement repose sur un principe simple :

```text
Vérification NTP
      │
      ▼
Source synchronisée ?
      │
   ┌──┴──┐
   │     │
  Oui   Non
   │     │
   ▼     ▼
  OK   CRITICAL
exit 0  exit 2
```

---

## Ce que ce script met en pratique

Ce projet m'a permis de travailler sur :

- Bash ;
- traitement de sortie de commande ;
- utilisation de `grep`, `awk` et `cut` ;
- vérification d'un service système ;
- codes de retour ;
- logique de supervision Linux.

---

## Améliorations possibles

Plusieurs évolutions peuvent être envisagées :

- gérer le code `1` pour un état `WARNING` ;
- vérifier que la commande `ntpq` est disponible ;
- gérer explicitement les erreurs d'exécution de `ntpq` ;
- éviter d'exécuter deux fois la même commande ;
- ajouter des seuils sur l'offset ;
- rendre le format de sortie compatible avec les performances Nagios ;
- ajouter une aide avec une option `--help`.

---

## Notes

Ce script est volontairement simple.

Il constitue une base pour construire des contrôles de supervision Linux plus complets.
