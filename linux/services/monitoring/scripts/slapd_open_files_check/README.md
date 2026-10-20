# Supervision du nombre de fichiers ouverts par slapd

## Présentation

Ce projet contient un script Bash permettant de surveiller le nombre de fichiers ouverts par le processus `slapd`.

`slapd` correspond au démon principal d'OpenLDAP.

Le script s'appuie notamment sur les commandes :

```bash
pgrep
```

et :

```bash
lsof
```

Il récupère le PID du processus `slapd`, compte le nombre de fichiers ouverts par celui-ci, puis compare le résultat à deux seuils :

- un seuil `WARNING` ;
- un seuil `CRITICAL`.

Le script retourne ensuite un code de sortie compatible avec une logique de supervision.

---

## Objectif

Ce script permet de :

- vérifier que le processus `slapd` est bien démarré ;
- récupérer son PID ;
- compter le nombre de fichiers ouverts par le processus ;
- détecter une consommation anormalement élevée ;
- retourner un état `OK`, `WARNING` ou `CRITICAL` ;
- intégrer facilement ce contrôle dans une solution de supervision.

---

## Fonctionnement

Le script commence par définir deux seuils :

```bash
WARNING=500
CRITICAL=800
```

Dans cet exemple :

```text
moins de 500 fichiers ouverts     → OK
de 500 à 799 fichiers ouverts     → WARNING
800 fichiers ouverts ou davantage → CRITICAL
```

> Les valeurs utilisées ici sont des exemples et doivent être adaptées à l'environnement surveillé.

---

## Vérification du processus slapd

Le script récupère le PID de `slapd` avec :

```bash
pgrep -x slapd
```

Le résultat est stocké dans :

```bash
PID=$(pgrep -x slapd)
```

Si aucun PID n'est trouvé, cela signifie que le processus n'est pas démarré.

Le script retourne alors :

```text
CRITICAL - Le processus slapd n'est pas démarré
```

avec le code :

```text
2
```

---

## Comptage des fichiers ouverts

Lorsque `slapd` fonctionne, le script utilise :

```bash
lsof -p "$PID"
```

La commande `lsof` permet d'afficher les fichiers et descripteurs ouverts par un processus.

Le résultat est ensuite traité avec :

```bash
tail -n +2
```

afin d'ignorer la ligne d'en-tête générée par `lsof`.

Enfin :

```bash
wc -l
```

permet de compter le nombre de lignes restantes.

La commande complète est :

```bash
OPEN_FILES=$(lsof -p "$PID" 2>/dev/null | tail -n +2 | wc -l)
```

Le résultat est stocké dans la variable :

```bash
OPEN_FILES
```

---

## Script

Le script Bash est disponible ici :

[`check_slapd_open_files.sh`](check_slapd_open_files.sh)

---

## Gestion des seuils

Le script compare ensuite le nombre de fichiers ouverts avec les seuils définis.

### État CRITICAL

```bash
if [ "$OPEN_FILES" -ge "$CRITICAL" ]; then
```

Si le nombre de fichiers ouverts est supérieur ou égal au seuil critique :

```text
CRITICAL - slapd utilise 850 fichiers ouverts
```

Code retour :

```text
2
```

---

### État WARNING

```bash
elif [ "$OPEN_FILES" -ge "$WARNING" ]; then
```

Si le seuil critique n'est pas atteint mais que le seuil d'avertissement l'est :

```text
WARNING - slapd utilise 620 fichiers ouverts
```

Code retour :

```text
1
```

---

### État OK

Si aucun seuil n'est dépassé :

```text
OK - slapd utilise 245 fichiers ouverts
```

Code retour :

```text
0
```

---

## Codes de retour

| Code | État | Description |
|---|---|---|
| `0` | OK | Le nombre de fichiers ouverts reste inférieur au seuil WARNING |
| `1` | WARNING | Le seuil WARNING est atteint |
| `2` | CRITICAL | Le seuil CRITICAL est atteint ou `slapd` n'est pas démarré |

Ces codes permettent d'utiliser le script dans une solution de supervision comme Nagios ou Centreon.

---

## Exemple de fonctionnement

```text
Recherche du processus slapd
          │
          ▼
      PID trouvé ?
          │
       ┌──┴──┐
       │     │
      Oui   Non
       │     │
       │     ▼
       │  CRITICAL
       │   exit 2
       ▼
Comptage des fichiers ouverts
       │
       ▼
Comparaison aux seuils
       │
 ┌─────┼─────────┐
 │     │         │
OK   WARNING   CRITICAL
 │     │         │
 ▼     ▼         ▼
0      1         2
```

---

## Prérequis

Le script nécessite :

- Bash ;
- la commande `pgrep` ;
- la commande `lsof` ;
- un processus `slapd` en cours d'exécution.

La commande suivante doit être disponible :

```bash
lsof
```

Si nécessaire, elle peut être installée avec :

```bash
sudo apt install lsof
```

---

## Utilisation

Rendre le script exécutable :

```bash
chmod +x check_slapd_open_files.sh
```

Puis l'exécuter :

```bash
./check_slapd_open_files.sh
```

---

## Intégration supervision

Le script peut être utilisé comme contrôle personnalisé dans un outil de supervision.

Exemple de résultat :

```text
OK - slapd utilise 312 fichiers ouverts
```

ou :

```text
WARNING - slapd utilise 610 fichiers ouverts
```

ou :

```text
CRITICAL - slapd utilise 902 fichiers ouverts
```

---

## Ce que ce script met en pratique

Ce projet permet de travailler sur :

- Bash ;
- supervision de processus Linux ;
- utilisation de `pgrep` ;
- utilisation de `lsof` ;
- traitement de sortie avec `tail` et `wc` ;
- comparaison de seuils ;
- codes de retour ;
- logique de supervision Nagios/Centreon.

---

## Améliorations possibles

Plusieurs évolutions peuvent être envisagées :

- rendre les seuils `WARNING` et `CRITICAL` configurables en paramètres ;
- vérifier explicitement que `lsof` est installé ;
- gérer un état `UNKNOWN` avec le code `3` ;
- ajouter une option `--help` ;
- ajouter des données de performance au format Nagios ;
- comparer le nombre de fichiers ouverts à la limite autorisée pour le processus ;
- superviser également les sockets réseau ouverts par `slapd` ;
- rendre le nom du processus configurable afin de réutiliser le script pour d'autres services.

---

## Notes

Ce script est volontairement simple.

Il constitue une base pour mettre en place un contrôle de supervision autour de l'utilisation des descripteurs de fichiers par un service Linux.
