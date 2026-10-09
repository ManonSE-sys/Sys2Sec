# Serveur DHCP avec Kea — Attribution d'adresses et support PXE

## 📌 Présentation

Ce projet documente l'installation et la configuration d'un serveur **DHCP Kea** sous Ubuntu.

Le serveur DHCP permet d'automatiser l'attribution des paramètres réseau aux clients. Dans cet exemple, la configuration est également adaptée à un environnement **PXE** afin de fournir un fichier de démarrage différent selon que le client utilise un firmware **UEFI** ou **BIOS**.

---

## 🎯 Objectifs

Cette mise en place permet de :

- automatiser l'attribution des adresses IPv4 ;
- centraliser la configuration réseau des clients ;
- définir une plage d'adresses distribuées automatiquement ;
- fournir aux clients PXE l'adresse du serveur de démarrage ;
- distinguer les clients UEFI et BIOS afin de leur fournir le bootloader adapté.

---

## 🏗️ Architecture

```text
Client
  │
  │ Requête DHCP
  ▼
Serveur Kea DHCP
  │
  ├── Adresse IPv4
  ├── Durée du bail
  ├── next-server
  └── boot-file-name
        │
        ├── UEFI → efi64/syslinux.efi
        └── BIOS → bios/pxelinux.0
  │
  ▼
Serveur PXE / TFTP
```

---

## 1. Mettre à jour le système

Avant d'installer Kea, mettre à jour les paquets du système :

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Installer le serveur DHCP Kea

Installer le paquet `kea-dhcp4-server` :

```bash
sudo apt install kea-dhcp4-server -y
```

---

## 3. Configurer Kea DHCP

Le fichier principal de configuration IPv4 est situé ici :

```text
/etc/kea/kea-dhcp4.conf
```

Il peut être édité avec :

```bash
sudo vi /etc/kea/kea-dhcp4.conf
```

La configuration utilisée pour ce projet est disponible ici :

👉 [`configs/kea-dhcp4.conf`](configs/kea-dhcp4.conf)

### Éléments principaux de la configuration

La configuration définit notamment :

- l'interface réseau écoutée par Kea ;
- le stockage des baux ;
- les durées de renouvellement et de validité des baux ;
- le sous-réseau IPv4 ;
- la plage d'adresses distribuées ;
- le serveur PXE via `next-server` ;
- des classes de clients UEFI et BIOS ;
- le fichier de démarrage fourni à chaque type de client.

### Exemple de plage DHCP

```text
Sous-réseau : 192.168.1.0/24
Pool DHCP   : 192.168.1.200 - 192.168.1.205
Serveur PXE : 192.168.1.181
```

> ⚠️ Les adresses utilisées ici correspondent à un environnement de lab et doivent être adaptées au réseau utilisé.

---

## 4. Support du démarrage PXE

La configuration Kea distingue deux catégories de clients.

### Clients UEFI

Les clients correspondant aux architectures UEFI reçoivent :

```text
efi64/syslinux.efi
```

### Clients BIOS

Les autres clients reçoivent :

```text
bios/pxelinux.0
```

Le paramètre :

```text
next-server
```

indique l'adresse du serveur PXE/TFTP qui fournit ensuite les fichiers nécessaires au démarrage.

---

## 5. Redémarrer le service

Après modification de la configuration :

```bash
sudo systemctl restart kea-dhcp4-server
```

---

## 6. Vérifier le statut du serveur DHCP

Vérifier que le service fonctionne correctement :

```bash
systemctl status kea-dhcp4-server
```

---

## 7. Tester le serveur DHCP

Démarrer un client configuré pour obtenir automatiquement sa configuration réseau.

Sur le client Linux, vérifier l'adresse reçue :

```bash
ip a
```

Le client doit recevoir une adresse appartenant à la plage configurée.

Dans cet exemple :

```text
192.168.1.200 - 192.168.1.205
```

Pour un client PXE, vérifier également qu'il reçoit les informations nécessaires au démarrage réseau.

---

## 🔎 Diagnostic

### Vérifier le service Kea

```bash
systemctl status kea-dhcp4-server
```

### Consulter les journaux

```bash
journalctl -u kea-dhcp4-server
```

### Vérifier les ports DHCP

DHCP utilise principalement :

```text
UDP 67 → serveur DHCP
UDP 68 → client DHCP
```

Les ports en écoute peuvent être inspectés avec :

```bash
ss -lunp
```

---

## 🔐 Points d'attention

Quelques précautions sont importantes lors de la mise en place d'un serveur DHCP :

- éviter la présence de plusieurs serveurs DHCP non maîtrisés sur le même segment réseau ;
- vérifier l'interface réseau sur laquelle Kea écoute ;
- adapter les plages d'adresses au réseau utilisé ;
- éviter les conflits avec des adresses configurées statiquement ;
- contrôler l'accès au réseau de déploiement PXE ;
- tester les changements de configuration avant leur mise en production.

---

## 📌 Points clés

- **Automatisation :** DHCP simplifie l'attribution des paramètres réseau aux clients.
- **Centralisation :** les paramètres réseau sont administrés depuis un point unique.
- **Flexibilité :** Kea permet d'adapter les pools, les durées de bail et les classes de clients.
- **PXE :** la configuration peut fournir automatiquement le serveur et le bootloader adaptés au type de client.

---

## 🔗 Projet associé

Cette configuration DHCP est utilisée pour permettre aux clients de démarrer sur une infrastructure PXE.

👉 [Voir le projet PXE](/linux/services/pxe/README.md)
