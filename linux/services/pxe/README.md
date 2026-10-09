# PXE — Déploiement automatisé d'Ubuntu

Ce dossier regroupe les ressources utilisées pour mettre en place une infrastructure de déploiement réseau basée sur **PXE**.

L'objectif est de permettre le démarrage et l'installation d'Ubuntu via le réseau, avec la possibilité de proposer une installation manuelle ou automatisée.

---

## 🏗️ Architecture

Le déploiement repose sur plusieurs composants :

- **DHCP** : fournit au client sa configuration réseau et les informations nécessaires au démarrage PXE ;
- **TFTP** : fournit le bootloader, le kernel et l'initrd ;
- **PXELINUX / Syslinux** : fournit les menus de démarrage ;
- **Apache** : distribue les images ISO et les fichiers nécessaires à l'installation ;
- **Cloud-init / Autoinstall** : automatise l'installation et la configuration d'Ubuntu.

```text
Client PXE
    │
    │ DHCP
    ▼
Serveur DHCP
    │
    ▼
Serveur TFTP
    │
    ├── PXELINUX
    ├── vmlinuz
    └── initrd
    │
    ▼
Serveur Apache
    │
    ├── ISO Ubuntu
    ├── user-data
    └── meta-data
    │
    ▼
Installation Ubuntu
```

---

## 📂 Contenu

### [`installation.md`](installation.md)

Documentation complète de la mise en place du serveur PXE :

- installation des paquets ;
- configuration TFTP ;
- préparation des bootloaders BIOS et UEFI ;
- configuration de PXELINUX ;
- configuration Apache ;
- création des menus de démarrage ;
- installation manuelle ;
- installation automatisée avec Autoinstall ;
- préparation de `vmlinuz` et `initrd`.

### [`configs/`](configs/)

Contient les différents exemples de configuration utilisés par le projet.

| Fichier | Utilisation |
|---|---|
| [`tftpd-hpa.conf`](configs/tftpd-hpa.conf) | Configuration du service TFTP |
| [`pxelinux-default`](configs/pxelinux-default) | Menu principal PXELINUX |
| [`pxe.conf`](configs/pxe.conf) | Configuration Apache |
| [`ubuntu22.menu`](configs/ubuntu22.menu) | Menu Ubuntu 22.04 |
| [`ubuntu22_auto.menu`](configs/ubuntu22_auto.menu) | Installation automatisée |
| [`ubuntu22_manual.menu`](configs/ubuntu22_manual.menu) | Installation manuelle |
| [`user-data.yaml`](configs/user-data.yaml) | Configuration Cloud-init / Autoinstall |

---

## 🎯 Objectifs du projet

Ce projet permet de travailler plusieurs notions liées à l'administration système et au déploiement :

- démarrage réseau PXE ;
- administration Linux ;
- TFTP ;
- DHCP ;
- HTTP / Apache ;
- Syslinux / PXELINUX ;
- automatisation d'installation ;
- Cloud-init ;
- Ubuntu Autoinstall ;
- gestion centralisée des images d'installation.

---

## 🚀 Parcours conseillé

Pour comprendre progressivement le projet :

1. consulter l'architecture PXE ;
2. suivre la procédure d'installation du serveur ;
3. configurer TFTP et PXELINUX ;
4. configurer Apache ;
5. créer les menus de démarrage ;
6. tester une installation manuelle ;
7. configurer Autoinstall ;
8. tester le déploiement automatisé d'Ubuntu.

👉 [Commencer l'installation](installation.md)

---

## ⚙️ Modes de déploiement

Deux modes sont documentés dans ce projet.

### Installation manuelle

Le client démarre via PXE puis lance l'installateur Ubuntu.

L'installation reste ensuite réalisée manuellement.

Configuration associée :

👉 [`configs/ubuntu22_manual.menu`](configs/ubuntu22_manual.menu)

### Installation automatisée

Le client démarre via PXE puis utilise **Ubuntu Autoinstall** et **Cloud-init** afin de réaliser l'installation avec un minimum d'intervention.

Configurations associées :

👉 [`configs/ubuntu22_auto.menu`](configs/ubuntu22_auto.menu)

👉 [`configs/user-data.yaml`](configs/user-data.yaml)

---

## 🧠 Ce que ce projet met en pratique

La mise en place de cette infrastructure m'a permis de travailler sur plusieurs couches d'un système de déploiement.

Le démarrage d'un client ne dépend pas d'un seul service mais d'une chaîne de composants :

```text
DHCP
  ↓
TFTP
  ↓
Bootloader
  ↓
Kernel / initrd
  ↓
HTTP
  ↓
Autoinstall
  ↓
Système installé
```

Comprendre cette chaîne permet également de diagnostiquer plus facilement un problème de déploiement en identifiant l'étape à laquelle le démarrage échoue.

---

## 🔎 Diagnostic

Quelques commandes utiles lors du dépannage :

### Vérifier le service TFTP

```bash
systemctl status tftpd-hpa
```

### Vérifier Apache

```bash
systemctl status apache2
```

### Vérifier les ports en écoute

```bash
ss -tulpn
```

### Consulter les logs Apache

```bash
journalctl -u apache2
```

ou :

```bash
tail -f /var/log/apache2/access.log
```

---

## 🔐 Points d'attention

Une infrastructure PXE doit être utilisée sur un réseau maîtrisé.

Quelques points à prendre en compte :

- contrôler les machines pouvant accéder au réseau de déploiement ;
- protéger les fichiers `user-data` ;
- éviter de stocker des secrets en clair ;
- contrôler les images ISO mises à disposition ;
- limiter l'accès au serveur HTTP ;
- vérifier la configuration DHCP avant le déploiement ;
- tester les modifications avant une utilisation à grande échelle.

---

## 📁 Arborescence

```text
pxe/
├── README.md
├── installation.md
└── configs/
    ├── tftpd-hpa.conf
    ├── pxelinux-default
    ├── pxe.conf
    ├── ubuntu22.menu
    ├── ubuntu22_auto.menu
    ├── ubuntu22_manual.menu
    └── user-data.yaml
```
