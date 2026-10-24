# Linux Security Audit

## Présentation

Ce projet contient un script Bash permettant d'effectuer plusieurs contrôles de sécurité sur un système Linux.

L'objectif est de vérifier rapidement différents éléments liés au durcissement du système :

- configuration SSH ;
- comptes privilégiés ;
- mots de passe ;
- permissions de fichiers sensibles ;
- ports en écoute ;
- pare-feu ;
- mises à jour ;
- configuration sudo ;
- comptes utilisateurs interactifs.

Le script affiche les résultats sous forme de statuts :

```text
[PASS]
[WARNING]
[FAIL]
[INFO]
```

---

## Objectif

Ce projet permet de mettre en pratique plusieurs principes de sécurité Linux et de centraliser différents contrôles dans un même script.

L'objectif n'est pas de remplacer un outil d'audit complet, mais de construire un script simple permettant de comprendre les principaux points de contrôle d'un serveur Linux.

---

## Exemple de sortie

```text
========================================
         Linux Security Audit
========================================

=== SSH ===
[WARNING] SSH root login allowed with key authentication
[WARNING] SSH password authentication enabled
[PASS] SSH pubkey authentication enabled

=== Accounts ===
[PASS] Only root account found
[PASS] No account has an empty password

=== Sensitive files ===
[PASS] /etc/passwd permissions are 644
[PASS] /etc/shadow permissions and ownership are correct

=== Network ===
[INFO] Listening TCP/UDP ports:
22
53
68

=== Firewall ===
[WARNING] UFW firewall is not active
[PASS] nftables rules detected

=== Updates ===
[WARNING] 1 package(s) can be upgraded

=== Sudo ===
[PASS] /etc/sudoers permissions and ownership are correct

=== Interactive users ===
[INFO] Accounts with an interactive shell:
local
```

---

## Statuts utilisés

| Statut | Signification |
|---|---|
| `PASS` | Le contrôle correspond à la configuration attendue |
| `WARNING` | Le paramètre mérite une vérification ou peut augmenter le risque |
| `FAIL` | Une configuration considérée comme dangereuse a été détectée |
| `INFO` | Information utile pour l'analyse, sans conclusion automatique |

---

## Contrôles réalisés

### SSH

Le script vérifie plusieurs paramètres de la configuration effective de `sshd`.

La commande utilisée est :

```bash
sshd -T
```

Cette commande permet d'obtenir la configuration réellement appliquée par le serveur SSH.

---

### Connexion SSH directe de root

Le script analyse :

```text
PermitRootLogin
```

Interprétation :

```text
no                 → PASS
prohibit-password  → WARNING
yes                → FAIL
```

`PermitRootLogin no` empêche toute connexion SSH directe avec le compte root.

`prohibit-password` interdit l'authentification root par mot de passe mais peut encore autoriser l'utilisation d'une clé SSH.

---

### Authentification SSH par mot de passe

Le script vérifie :

```text
PasswordAuthentication
```

Interprétation :

```text
no  → PASS
yes → WARNING
```

L'authentification par mot de passe peut augmenter l'exposition aux attaques par brute force ou password spraying.

L'utilisation de clés SSH permet de réduire ce risque lorsqu'elle est correctement mise en place.

---

### Authentification par clé publique

Le script vérifie :

```text
PubkeyAuthentication
```

Interprétation :

```text
yes → PASS
no  → WARNING
```

L'authentification par clé publique est généralement privilégiée pour les accès administratifs SSH.

---

## Comptes avec UID 0

Sous Linux, l'UID `0` correspond aux privilèges root.

Le script recherche les comptes possédant cet UID avec :

```bash
awk -F: '$3 == 0 {print $1}' /etc/passwd
```

Le résultat attendu est uniquement :

```text
root
```

La présence d'un autre compte avec UID 0 génère un état `FAIL`.

---

## Comptes sans mot de passe

Le script analyse `/etc/shadow` afin de détecter les comptes dont le champ mot de passe est vide.

Commande utilisée :

```bash
awk -F: '($2 == "") {print $1}' /etc/shadow
```

Si aucun compte n'est trouvé :

```text
PASS
```

Sinon :

```text
FAIL
```

---

## Permissions de /etc/passwd

Le script vérifie les permissions du fichier :

```text
/etc/passwd
```

La valeur attendue est :

```text
644
```

Cela signifie :

```text
root    → lecture + écriture
groupe  → lecture
autres  → lecture
```

Le fichier peut être lu par les utilisateurs, mais seul root doit pouvoir le modifier.

---

## Permissions de /etc/shadow

Le fichier :

```text
/etc/shadow
```

contient notamment les hashes des mots de passe.

Le script vérifie :

- permissions ;
- propriétaire ;
- groupe.

Exemple attendu sur Ubuntu :

```text
640 root shadow
```

Cela permet de limiter fortement l'accès au fichier.

---

## Ports en écoute

Le script utilise :

```bash
ss -tuln
```

afin d'identifier les ports TCP et UDP en écoute.

Les ports sont affichés en état `INFO`, car un port ouvert n'est pas forcément une vulnérabilité.

Il doit être analysé en fonction du rôle du serveur.

Exemple :

```text
22
53
68
```

---

## Pare-feu

Le script vérifie la présence de règles de filtrage avec :

```bash
ufw status
```

et :

```bash
nft list ruleset
```

UFW peut être inactif alors que des règles nftables sont présentes.

Le script ne considère donc pas automatiquement l'absence d'UFW comme un échec.

---

## Mises à jour disponibles

Le script vérifie les paquets pouvant être mis à jour avec :

```bash
apt list --upgradable
```

Si aucun paquet n'est disponible :

```text
PASS
```

Si des mises à jour sont disponibles :

```text
WARNING
```

Maintenir le système à jour permet de réduire l'exposition à des vulnérabilités connues.

---

## Permissions de /etc/sudoers

Le script vérifie :

```text
/etc/sudoers
```

Les valeurs attendues sont :

```text
permissions : 440
owner       : root
group       : root
```

Ce fichier contrôle les privilèges accordés via `sudo` et doit donc être fortement protégé.

---

## Comptes avec shell interactif

Le script identifie les comptes utilisateurs disposant d'un shell interactif.

Il filtre notamment les comptes avec un UID utilisateur et exclut les shells comme :

```text
nologin
false
```

Le résultat est affiché en `INFO`.

Cela permet de vérifier quels comptes peuvent potentiellement ouvrir une session interactive.

---

## Prérequis

Le script est conçu pour une distribution Linux de type Debian ou Ubuntu.

Il utilise notamment :

```text
bash
sshd
awk
stat
ss
ufw
nft
apt
```

Certaines commandes peuvent être absentes selon la distribution ou les paquets installés.

---

## Utilisation

Rendre le script exécutable :

```bash
chmod +x audit.sh
```

Puis lancer :

```bash
./audit.sh
```

ou :

```bash
bash audit.sh
```

Certains contrôles nécessitent des privilèges suffisants pour lire des fichiers comme :

```text
/etc/shadow
/etc/sudoers
```

---

## Limites

Ce script constitue une approche pédagogique de l'audit de sécurité Linux.

Il ne prend pas en compte :

- l'ensemble des paramètres de durcissement du système ;
- les distributions Linux autres que Debian/Ubuntu ;
- les exceptions liées au contexte métier ;
- la configuration complète de PAM ;
- les paramètres kernel ;
- les règles détaillées du pare-feu ;
- les politiques de mot de passe avancées ;
- les contrôles CIS complets ;
- les vulnérabilités logicielles.

Un résultat `WARNING` ou `FAIL` doit toujours être interprété dans son contexte.

---

## Améliorations possibles

Plusieurs évolutions peuvent être ajoutées :

- génération d'un résumé avec le nombre de `PASS`, `WARNING` et `FAIL` ;
- rapport JSON ou CSV ;
- vérification des paramètres `sysctl` ;
- audit des permissions des répertoires utilisateurs ;
- vérification de l'expiration des mots de passe ;
- détection des comptes inactifs ;
- analyse plus détaillée des services ;
- contrôle des règles nftables ;
- comparaison avec des recommandations CIS ;
- prise en charge de plusieurs distributions Linux.

---

## Ce que ce projet met en pratique

Ce projet permet de travailler sur :

- Bash ;
- sécurité Linux ;
- durcissement SSH ;
- gestion des comptes et privilèges ;
- permissions Unix ;
- fichiers sensibles ;
- réseau ;
- pare-feu ;
- mises à jour système ;
- sudo ;
- interprétation de résultats d'audit.

---

## Conclusion

Ce script regroupe plusieurs contrôles simples permettant d'évaluer rapidement certains éléments importants de la configuration de sécurité d'un système Linux.

Il permet surtout de comprendre les mécanismes vérifiés plutôt que d'utiliser directement un outil d'audit automatisé.

Il peut servir de base avant de travailler avec des outils ou référentiels plus complets comme Lynis ou les CIS Benchmarks.
