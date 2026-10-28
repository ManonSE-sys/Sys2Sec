# Sécurité Linux

## 📌 Présentation

Cette section regroupe des projets consacrés à la sécurité, au contrôle d'intégrité et au durcissement de systèmes Linux.

L'objectif est de mettre en pratique des mécanismes de sécurité à travers des scripts et des laboratoires simples, tout en comprenant leurs limites par rapport à des solutions spécialisées.

---

## 🔎 Projets disponibles

### File Integrity Monitoring

Implémentation d'un mécanisme simple de **File Integrity Monitoring (FIM)**.

Deux versions sont proposées :

* Bash ;
* Python.

Le principe repose sur la création d'une baseline contenant des empreintes SHA-256, puis sur leur comparaison avec l'état actuel des fichiers.

```text
État de référence
       ↓
Baseline
       ↓
Modification
       ↓
Nouvelle vérification
       ↓
Comparaison
       ↓
Détection
```

Le projet permet notamment de travailler sur :

* SHA-256 ;
* baselines ;
* détection de fichiers modifiés ou absents ;
* Bash ;
* Python ;
* JSON ;
* rapports de contrôle.

👉 [Voir le projet File Integrity Monitoring](./file_integrity_monitoring/)

---

### Linux Security Audit

Script Bash permettant d'effectuer plusieurs contrôles de sécurité sur un système Linux.

Les vérifications portent notamment sur :

* configuration SSH ;
* UID 0 ;
* comptes sans mot de passe ;
* permissions de `/etc/passwd` ;
* permissions de `/etc/shadow` ;
* permissions de `/etc/sudoers` ;
* ports en écoute ;
* UFW ;
* nftables ;
* mises à jour ;
* comptes disposant d'un shell interactif.

Les résultats utilisent plusieurs statuts :

```text
[PASS]
[WARNING]
[FAIL]
[INFO]
```

👉 [Voir le projet Linux Security Audit](./linux_security_audit/)

---

## 🧠 Approche

Les projets de cette section sont volontairement pédagogiques.

Ils permettent de comprendre les mécanismes fondamentaux avant d'utiliser des solutions ou référentiels plus complets.

Exemples :

```text
Scripts FIM
    → compréhension du contrôle d'intégrité

Linux Security Audit
    → compréhension de contrôles de durcissement

```

---

## 🧩 Compétences mises en pratique

Cette section permet de travailler sur :

* sécurité Linux ;
* Bash ;
* Python ;
* contrôle d'intégrité ;
* SHA-256 ;
* audit système ;
* durcissement SSH ;
* permissions Unix ;
* comptes et privilèges ;
* pare-feu ;
* gestion des mises à jour ;
* automatisation des remédiations ;
* interprétation des résultats de sécurité.

---

## ⚠️ Limites

Les scripts présents dans cette section sont conçus comme des exercices pratiques et des démonstrations de compétences.

Ils ne remplacent pas :

* un audit de sécurité complet ;
* un référentiel de durcissement ;
* une solution EDR ;
* un SIEM ;
* un outil FIM spécialisé ;
* une analyse de vulnérabilités.

Les résultats doivent toujours être interprétés en fonction du rôle et du contexte de la machine.
