# File Integrity Monitoring en Python

## Présentation

Ce projet contient un script Python permettant de vérifier l'intégrité de fichiers sensibles à l'aide de sommes de contrôle SHA-256.

Le script fonctionne à partir d'une baseline enregistrée au format JSON.

Il permet de :

- créer un état de référence des fichiers surveillés ;
- recalculer leur empreinte SHA-256 ;
- détecter les fichiers modifiés ;
- détecter les fichiers absents ;
- retourner un code de sortie exploitable par un outil de supervision ;
- générer un rapport JSON horodaté.

L'objectif est de mettre en pratique les principes de base du File Integrity Monitoring.

---

## Objectif

Le File Integrity Monitoring permet de détecter des changements inattendus sur des fichiers importants.

Une modification peut par exemple être liée à :

- une modification de configuration ;
- une erreur d'administration ;
- une compromission ;
- une modification non autorisée ;
- la suppression d'un fichier critique.

Le script compare l'état actuel des fichiers à une baseline créée précédemment.

---

## Fonctionnement général

Le script dispose de deux modes :

```bash
python3 fim.py --init
```

et :

```bash
python3 fim.py --check
```

Le fonctionnement est le suivant :

```text
              ┌─────────────────┐
              │   files.conf    │
              └────────┬────────┘
                       │
                       ▼
                Calcul SHA-256
                       │
                       ▼
              ┌─────────────────┐
              │ baseline.json   │
              └────────┬────────┘
                       │
                 --check
                       │
                       ▼
              Nouveau calcul
                 SHA-256
                       │
                       ▼
                 Comparaison
                       │
             ┌─────────┴─────────┐
             │                   │
          Identique           Différent
             │                   │
             ▼                   ▼
            OK               CRITICAL
```

---

## Structure du projet

Exemple d'organisation :

```text
file-integrity-monitoring/
├── fim.py
├── files.conf
├── baseline.json
├── fim-report.json
└── README.md
```

### `fim.py`

Script principal.

### `files.conf`

Contient la liste des fichiers à surveiller.

Exemple :

```text
/etc/passwd
/etc/ssh/sshd_config
```

### `baseline.json`

Contient les empreintes SHA-256 de référence.

### `fim-report.json`

Contient le résultat du dernier contrôle d'intégrité.

---

## Création de la baseline

La baseline est créée avec :

```bash
python3 fim.py --init
```

Le script lit les fichiers définis dans :

```text
files.conf
```

Puis il calcule leur empreinte SHA-256.

La fonction de calcul repose sur le module :

```python
hashlib
```

et sur l'algorithme :

```text
SHA-256
```

Le résultat est enregistré dans :

```text
baseline.json
```

Exemple :

```json
{
    "/etc/passwd": {
        "sha256": "..."
    },
    "/etc/ssh/sshd_config": {
        "sha256": "..."
    }
}
```

Cette baseline représente l'état de référence des fichiers surveillés.

---

## Vérification de l'intégrité

Le contrôle est lancé avec :

```bash
python3 fim.py --check
```

Le script :

1. charge `baseline.json` ;
2. parcourt les fichiers surveillés ;
3. vérifie leur présence ;
4. recalcule leur empreinte SHA-256 ;
5. compare le hash actuel au hash de référence ;
6. affiche le résultat ;
7. génère un rapport JSON.

---

## Exemple : fichier inchangé

Si le hash actuel correspond au hash enregistré :

```text
2026-10-23 21:25:14 - OK - /etc/passwd inchangé
```

Le fichier est considéré comme intact.

---

## Exemple : fichier modifié

Si le contenu d'un fichier change, son empreinte SHA-256 change également.

Le script retourne alors :

```text
2026-10-23 21:25:14 - CRITICAL - /etc/ssh/sshd_config modifié
```

Cela indique que le fichier ne correspond plus à la baseline.

---

## Exemple : fichier absent

Si un fichier présent dans la baseline n'existe plus :

```text
2026-10-23 21:25:14 - CRITICAL - Fichier absent : /etc/ssh/sshd_config
```

Le contrôle passe également en état critique.

---

## Codes de retour

Le script utilise les codes suivants :

| Code | État | Description |
|---|---|---|
| `0` | OK | Tous les fichiers correspondent à la baseline |
| `2` | CRITICAL | Au moins un fichier est modifié ou absent |
| `3` | UNKNOWN | La baseline est introuvable ou le contrôle ne peut pas être effectué |

Ces codes peuvent être utilisés par une solution de supervision.

---

## Rapport JSON

À chaque contrôle, le script génère :

```text
fim-report.json
```

Exemple :

```json
{
    "timestamp": "2026-10-23 21:25:14",
    "status": "CRITICAL",
    "checked_files": 2,
    "ok": 1,
    "modified": 1,
    "missing": 0
}
```

Le rapport permet de conserver un résultat structuré pouvant ensuite être exploité par :

- un autre script ;
- un outil de supervision ;
- un système de collecte de logs ;
- un SIEM ;
- un outil de reporting.

---

## Horodatage

Chaque contrôle contient un horodatage.

Exemple :

```text
2026-10-23 21:25:14
```

Cela permet de savoir précisément quand le contrôle d'intégrité a été effectué.

L'horodatage est généré avec le module Python :

```python
datetime
```

---

## Modules Python utilisés

Le script utilise principalement :

### `hashlib`

Permet de calculer les empreintes SHA-256.

### `json`

Permet de lire et écrire :

```text
baseline.json
fim-report.json
```

### `pathlib`

Permet de manipuler les chemins de fichiers.

### `argparse`

Permet de gérer les options :

```text
--init
--check
```

### `datetime`

Permet d'horodater les contrôles.

### `sys`

Permet notamment de retourner les codes de sortie.

---

## Prérequis

Le script nécessite :

- Python 3 ;
- un système Linux ;
- les permissions nécessaires pour lire les fichiers surveillés.

Vérification :

```bash
python3 --version
```

---

## Utilisation

### Créer la baseline

```bash
python3 fim.py --init
```

### Vérifier l'intégrité

```bash
python3 fim.py --check
```

### Vérifier le code retour

```bash
echo $?
```

Exemple :

```text
0
```

ou :

```text
2
```

---

## Exemple de test

Créer la baseline :

```bash
python3 fim.py --init
```

Effectuer un premier contrôle :

```bash
python3 fim.py --check
```

Modifier ensuite un fichier surveillé.

Exemple :

```bash
echo "# test modification" >> /etc/ssh/sshd_config
```

Relancer le contrôle :

```bash
python3 fim.py --check
```

Le script doit alors signaler que le fichier a été modifié.

> Les modifications de fichiers système doivent être effectuées uniquement dans un environnement de test.

---

## Intérêt sécurité

Le File Integrity Monitoring est utilisé pour détecter des changements inattendus sur des fichiers sensibles.

Il peut notamment être utilisé pour surveiller :

```text
/etc/passwd
/etc/group
/etc/ssh/sshd_config
```

ou encore :

- des fichiers de configuration ;
- des scripts système ;
- des fichiers applicatifs ;
- des fichiers de sécurité ;
- des fichiers critiques pour un service.

Un changement détecté ne signifie pas forcément qu'une attaque a eu lieu.

Il indique qu'une investigation peut être nécessaire.

---

## Limites

Ce script constitue une implémentation pédagogique du File Integrity Monitoring.

Il présente plusieurs limites :

- il surveille uniquement les fichiers explicitement définis ;
- il ne fonctionne pas en temps réel ;
- il ne détecte pas automatiquement les nouveaux fichiers ;
- il ne vérifie pas les changements de permissions ou de propriétaire ;
- il ne protège pas lui-même la baseline contre une modification ;
- il ne remplace pas une solution FIM complète.

Pour un environnement de production, des outils spécialisés comme Wazuh, AIDE ou Tripwire sont plus adaptés.

---

## Ce que ce projet met en pratique

Ce projet permet de travailler sur :

- Python ;
- SHA-256 ;
- File Integrity Monitoring ;
- manipulation de fichiers ;
- JSON ;
- dictionnaires Python ;
- gestion d'arguments ;
- codes de retour ;
- horodatage ;
- génération de rapports ;
- principes de détection en sécurité.

---

## Évolutions possibles

Plusieurs améliorations peuvent être envisagées :

- protéger la baseline contre les modifications ;
- vérifier les permissions des fichiers ;
- vérifier les propriétaires et groupes ;
- envoyer une alerte en cas de modification ;
- conserver un historique des rapports ;
- envoyer les résultats vers un SIEM ;
- intégrer le script à une solution de supervision ;
- améliorer la gestion des erreurs.

---

## Conclusion

Ce projet met en œuvre un mécanisme simple de File Integrity Monitoring basé sur SHA-256.

Il permet de comprendre les principes fondamentaux d'une solution FIM :

```text
Baseline
   ↓
Calcul d'intégrité
   ↓
Comparaison
   ↓
Détection
   ↓
Alerte / rapport
```

Il constitue également une première approche avant l'utilisation de solutions plus complètes comme Wazuh.
