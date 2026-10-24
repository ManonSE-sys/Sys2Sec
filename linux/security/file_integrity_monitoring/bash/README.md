# File Integrity Monitoring en Bash

## Présentation

Ce projet contient un script Bash permettant de vérifier l'intégrité de fichiers à l'aide de sommes de contrôle SHA-256.

Le script repose sur une baseline contenant le hash de référence de chaque fichier surveillé.

Il permet de :

- créer une baseline ;
- recalculer les empreintes SHA-256 ;
- détecter les fichiers modifiés ;
- détecter les fichiers absents ;
- retourner un code de sortie exploitable par un outil de supervision.

Cette version constitue une implémentation simple et pédagogique du File Integrity Monitoring sous Linux.

---

## Objectif

Le File Integrity Monitoring permet de détecter des changements inattendus sur des fichiers importants.

Une modification peut par exemple être liée à :

- une modification de configuration ;
- une erreur d'administration ;
- une suppression accidentelle ;
- une modification non autorisée ;
- une compromission.

Le script compare l'état actuel des fichiers à un état de référence créé précédemment.

---

## Fonctionnement

Le script utilise deux modes :

```bash
./fim.sh --init
```

et :

```bash
./fim.sh --check
```

Le fonctionnement général est le suivant :

```text
files.conf
    │
    ▼
Calcul SHA-256
    │
    ▼
baseline.txt
    │
    ▼
  --check
    │
    ▼
Nouveau calcul SHA-256
    │
    ▼
Comparaison
    │
 ┌──┴──────────┐
 │             │
Identique    Différent
 │             │
 ▼             ▼
OK          CRITICAL
```

---

## Structure

Exemple :

```text
bash/
├── README.md
├── fim.sh
├── files.conf
└── baseline.txt
```

### `fim.sh`

Script principal de contrôle d'intégrité.

### `files.conf`

Contient la liste des fichiers à surveiller.

Exemple :

```text
/etc/passwd
/etc/ssh/sshd_config
```

### `baseline.txt`

Contient les empreintes SHA-256 de référence.

Ce fichier est généré automatiquement avec l'option :

```bash
./fim.sh --init
```

---

## Création de la baseline

La baseline est créée avec :

```bash
./fim.sh --init
```

Le script lit chaque fichier défini dans :

```text
files.conf
```

puis calcule son hash avec :

```bash
sha256sum
```

Exemple :

```bash
sha256sum /etc/passwd
```

Le résultat est enregistré dans :

```text
baseline.txt
```

Exemple :

```text
abc123...  /etc/passwd
def456...  /etc/ssh/sshd_config
```

Cette baseline représente l'état de référence des fichiers surveillés.

---

## Vérification de l'intégrité

Le contrôle est lancé avec :

```bash
./fim.sh --check
```

Le script :

1. lit la baseline ;
2. vérifie que chaque fichier existe ;
3. recalcule son hash SHA-256 ;
4. compare le hash actuel au hash de référence ;
5. affiche le résultat ;
6. retourne un code de sortie.

---

## Exemple : fichier inchangé

```text
OK - /etc/passwd inchangé
```

Le hash actuel correspond au hash enregistré dans la baseline.

---

## Exemple : fichier modifié

```text
CRITICAL - /etc/ssh/sshd_config modifié
```

Le contenu du fichier a changé depuis la création de la baseline.

---

## Exemple : fichier absent

```text
CRITICAL - Fichier absent : /etc/ssh/sshd_config
```

Le fichier surveillé n'existe plus.

---

## Codes de retour

| Code | État | Description |
|---|---|---|
| `0` | OK | Tous les fichiers correspondent à la baseline |
| `2` | CRITICAL | Au moins un fichier est modifié ou absent |
| `3` | UNKNOWN | Le script ne peut pas effectuer correctement le contrôle |

Ces codes permettent d'intégrer le script à une solution de supervision.

---

## Prérequis

Le script nécessite :

- Bash ;
- `sha256sum` ;
- `awk` ;
- les permissions nécessaires pour lire les fichiers surveillés.

---

## Utilisation

Rendre le script exécutable :

```bash
chmod +x fim.sh
```

Créer la baseline :

```bash
./fim.sh --init
```

Vérifier l'intégrité :

```bash
./fim.sh --check
```

Vérifier le code retour :

```bash
echo $?
```

---

## Exemple de test

Créer la baseline :

```bash
./fim.sh --init
```

Effectuer un premier contrôle :

```bash
./fim.sh --check
```

Modifier ensuite un fichier dans un environnement de test.

Puis relancer :

```bash
./fim.sh --check
```

Le script doit détecter la modification.

> Il est préférable d'effectuer les tests sur des fichiers de laboratoire ou des copies de fichiers système.

---

## Intérêt sécurité

Le script permet de surveiller des fichiers sensibles comme :

```text
/etc/passwd
/etc/group
/etc/ssh/sshd_config
```

Il peut également être utilisé pour surveiller :

- des fichiers de configuration ;
- des scripts système ;
- des fichiers applicatifs ;
- des fichiers liés à la sécurité.

Une modification détectée ne signifie pas nécessairement qu'une attaque a eu lieu.

Elle indique qu'un changement a eu lieu et qu'une vérification peut être nécessaire.

---

## Limites

Cette implémentation reste volontairement simple.

Elle ne permet pas notamment de :

- surveiller les fichiers en temps réel ;
- détecter automatiquement les nouveaux fichiers ;
- vérifier les permissions ou les propriétaires ;
- protéger la baseline contre les modifications ;
- conserver un historique des contrôles.

Pour un environnement de production, des solutions spécialisées sont plus adaptées.

---

## Ce que ce projet met en pratique

Ce projet permet de travailler sur :

- Bash ;
- SHA-256 ;
- File Integrity Monitoring ;
- lecture de fichiers ;
- boucles ;
- conditions ;
- codes de retour ;
- logique de supervision ;
- détection de modifications de fichiers.

---

## Améliorations possibles

Plusieurs évolutions peuvent être envisagées :

- rendre le fichier de configuration paramétrable ;
- ajouter un état `WARNING` ;
- vérifier l'existence de la baseline ;
- protéger la baseline ;
- surveiller les permissions ;
- ajouter un historique ;
- envoyer des alertes ;
- intégrer le script à Nagios ou Centreon.

---

## Notes

Ce script a pour objectif de comprendre les principes de base du File Integrity Monitoring avec des outils Linux simples.

Une version Python plus structurée est également disponible dans le projet principal.
