# Services Linux

## 📌 Présentation

Cette section regroupe différents projets autour de la mise en place, de la configuration et de l'administration de services sous Linux.

Les projets couvrent plusieurs domaines :

* services réseau ;
* partage de fichiers ;
* synchronisation temporelle ;
* accès distant ;
* déploiement ;
* gestion de paquets ;
* supervision ;
* automatisation.

---

## 📂 Services disponibles

### 🤖 Ansible

Automatisation et gestion de configuration de systèmes Linux.

Le premier projet utilise Ansible pour appliquer automatiquement une configuration de durcissement et illustrer l'idempotence.

👉 [Voir les projets Ansible](./ansible/)

---

### 🌐 DHCP

Configuration d'un service DHCP permettant d'attribuer automatiquement des paramètres réseau aux clients.

👉 [Voir le projet DHCP](./dhcp/)

---

### 📊 Monitoring

Scripts Bash destinés à la supervision de services et de composants Linux.

Les checks utilisent notamment des codes de retour compatibles avec une logique de supervision de type Nagios/Centreon.

👉 [Voir les projets de monitoring](./monitoring/)

---

### 📁 NFS

Mise en place d'un serveur NFS pour partager des fichiers entre plusieurs machines Linux.

Le projet couvre notamment :

* les exports ;
* les permissions ;
* les montages clients ;
* `/etc/fstab` ;
* la sécurité ;
* le troubleshooting.

👉 [Voir le projet NFS](./nfs/)

---

### 🕒 NTP

Installation, configuration et vérification d'un service de synchronisation temporelle.

Le projet inclut également :

* une fiche de référence sur `ntpq` ;
* un script de monitoring de la synchronisation.

👉 [Voir le projet NTP](./ntp/)

---

### 🔐 OpenVPN

Mise en place d'un serveur VPN avec authentification par certificats.

Le projet aborde notamment :

* OpenVPN ;
* Easy-RSA ;
* PKI ;
* certificats X.509 ;
* routage ;
* IP forwarding ;
* gestion des clients ;
* sécurité des accès distants.

👉 [Voir le projet OpenVPN](./openvpn/)

---

### 📦 Gestion des paquets

Projets consacrés à l'administration et à l'optimisation des paquets APT.

Deux approches sont documentées :

* **Reprepro** : création d'un dépôt APT local signé ;
* **apt-cacher-ng** : mise en cache des téléchargements APT.

👉 [Voir les projets de gestion des paquets](./package-management/)

---

### 🚀 PXE

Mise en place d'un environnement de démarrage et de déploiement réseau PXE.

Le projet permet de travailler sur plusieurs composants réseau nécessaires au démarrage d'une machine via le réseau.

👉 [Voir le projet PXE](./pxe/)

---

### 📤 vsftpd

Mise en place d'un serveur FTP avec `vsftpd`.

Le projet aborde notamment :

* utilisateurs locaux ;
* permissions Unix ;
* `chroot` ;
* répertoires d'upload ;
* journalisation ;
* différences entre FTP, FTPS et SFTP ;
* sécurité du service.

👉 [Voir le projet vsftpd](./vsftpd/)

---

## 🧩 Compétences mises en pratique

Ces projets permettent de travailler sur :

* administration de services Linux ;
* réseau TCP/IP ;
* configuration système ;
* gestion des utilisateurs et permissions ;
* systemd ;
* journalisation ;
* gestion de paquets ;
* automatisation ;
* supervision ;
* sécurité des services ;
* diagnostic et troubleshooting.

---

## 📂 Organisation

```text
services/
├── ansible/
├── dhcp/
├── monitoring/
├── nfs/
├── ntp/
├── openvpn/
├── package-management/
├── pxe/
└── vsftpd/
```

Chaque service possède sa propre documentation et peut contenir selon les besoins :

```text
README.md
installation.md
commandes-utiles.md
configs/
troubleshooting/
```

La structure est adaptée à la complexité de chaque projet : tous les dossiers n'ont donc pas nécessairement besoin de l'ensemble de ces fichiers.
