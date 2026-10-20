# Scripts de monitoring Linux

Cette section regroupe plusieurs scripts Bash utilisés pour automatiser des contrôles de supervision sur des serveurs Linux.

L'objectif est de construire des checks simples, lisibles et exploitables par des outils de supervision comme Nagios ou Centreon.

Les scripts utilisent notamment les codes de retour classiques :

| Code | État |
|---|---|
| `0` | OK |
| `1` | WARNING |
| `2` | CRITICAL |
| `3` | UNKNOWN |

---

## Scripts disponibles

### Vérification de la synchronisation NTP

Contrôle permettant de vérifier qu'un serveur Linux est correctement synchronisé avec une source NTP.

Le script :

- interroge `ntpq` ;
- identifie la source NTP active ;
- récupère l'offset ;
- retourne un état `OK` ou `CRITICAL`.

👉 [Voir le check NTP](./ntp-check/)

---

### Recherche d'une phrase dans un fichier de log

Contrôle permettant de vérifier la présence d'une chaîne de caractères précise dans un fichier de log.

Le script :

- analyse un fichier de log ;
- recherche une phrase avec `grep` ;
- retourne `OK` si elle est trouvée ;
- retourne `CRITICAL` si elle est absente.

👉 [Voir le check de fichier de log](./log-pattern-check/)

---

### Supervision des fichiers ouverts par slapd

Contrôle permettant de surveiller le nombre de fichiers ouverts par le processus `slapd`.

Le script :

- vérifie que `slapd` est démarré ;
- récupère son PID ;
- utilise `lsof` pour compter les fichiers ouverts ;
- compare le résultat à des seuils `WARNING` et `CRITICAL`.

👉 [Voir le check slapd](./slapd_open_files_check/)

---

## Fonctionnement général

Les scripts suivent une logique de supervision simple :

```text
Collecte d'une information système
            │
            ▼
       Analyse du résultat
            │
            ▼
     Comparaison / validation
            │
            ▼
  OK / WARNING / CRITICAL
            │
            ▼
        Code de retour
```

---

## Objectifs

Ces scripts permettent de travailler sur :

- Bash ;
- supervision Linux ;
- analyse de fichiers de log ;
- surveillance de processus ;
- traitement de sorties de commandes ;
- gestion de seuils ;
- codes de retour ;
- intégration Nagios / Centreon.

---

## Évolutions possibles

Plusieurs améliorations peuvent être ajoutées progressivement :

- gestion systématique du code `UNKNOWN` ;
- paramètres en ligne de commande ;
- options `--help` ;
- seuils configurables ;
- données de performance au format Nagios ;
- gestion plus complète des erreurs ;
- ajout de tests ;
- factorisation de certaines fonctions communes.

---

## Notes

Ces scripts sont volontairement simples et pédagogiques.

Ils constituent une base pour construire des contrôles de supervision plus complets et adaptés à différents services Linux.
