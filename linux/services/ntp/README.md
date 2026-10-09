# NTP — Installation, vérification et monitoring

Ce dossier regroupe plusieurs ressources autour de la mise en place et de la supervision d'un service NTP sous Linux.

## Contenu

- [`installation.md`](installation.md)  
  Installation et configuration d'un serveur NTP sous Ubuntu.

- [`ntpq-reference.md`](ntpq-reference.md)  
  Explication de la commande `ntpq -p`, de ses colonnes et des symboles utilisés pour identifier les sources de synchronisation.

- [`check_ntp_sync.sh`](check_ntp_sync.sh)  
  Script Bash permettant de vérifier automatiquement si une source NTP synchronisée est présente.

## Objectifs

Ce mini-projet permet de travailler plusieurs notions :

- administration Linux ;
- configuration d'un service NTP ;
- compréhension de la synchronisation temporelle ;
- analyse de la sortie `ntpq` ;
- scripting Bash ;
- codes de retour de supervision.

## Parcours conseillé

1. Installer et configurer le serveur NTP.
2. Comprendre la sortie de `ntpq -p`.
3. Automatiser la vérification avec le script de monitoring.
