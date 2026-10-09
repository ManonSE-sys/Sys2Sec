# Déploiement automatisé d'Ubuntu avec PXE

## 🏗️ Architecture

Le déploiement repose sur plusieurs composants :

- **DHCP** : permet au client d'obtenir sa configuration réseau et les informations nécessaires au démarrage PXE ;
- **TFTP** : fournit le bootloader, le kernel et l'initrd ;
- **PXELINUX / Syslinux** : fournit le menu de démarrage ;
- **Apache** : distribue les ISO et les fichiers nécessaires à l'autoinstall ;
- **Cloud-init / Autoinstall** : automatise l'installation et la configuration d'Ubuntu.

```text
Client
  │
  │ PXE
  ▼
DHCP
  │
  ▼
TFTP
  │
  ├── PXELINUX
  ├── vmlinuz
  └── initrd
  │
  ▼
Apache
  │
  ├── ISO Ubuntu
  └── user-data / meta-data
  │
  ▼
Installation Ubuntu
```

## Pourquoi utiliser un serveur PXE ?

Un serveur PXE (**Preboot Execution Environment**) permet de :

- **automatiser l'installation d'un système d'exploitation** sur des machines sans OS ;
- **simplifier le déploiement en masse** dans des environnements de type datacenter ;
- **réduire le temps de configuration manuelle** des systèmes.

## Étapes pour installer un serveur PXE sur Ubuntu

### 1. Mettre à jour le système

Avant d'installer PXE, assurez-vous que le système est à jour :

```bash
apt update && sudo apt upgrade -y
```

### 2. Installer les paquets nécessaires

Installez les paquets nécessaires au serveur PXE :

```bash
apt install tftpd-hpa syslinux syslinux-efi pxelinux apache2 -y
```

### 3. Configurer `/etc/default/tftpd-hpa`

Le fichier principal de configuration est situé dans :

```text
/etc/default/tftpd-hpa
```

Pour le modifier :

```bash
vi /etc/default/tftpd-hpa
```

La configuration complète du service TFTP est disponible ici :
[`configs/tftpd-hpa.conf`](configs/tftpd-hpa.conf)

### 4. Créer les répertoires TFTP

Il faut ensuite créer les répertoires nécessaires au démarrage réseau et copier les fichiers requis :

```bash
mkdir -p /var/lib/tftpboot/efi64/pxelinux.cfg
mkdir -p /var/lib/tftpboot/bios/pxelinux.cfg

cp /usr/lib/syslinux/modules/efi64/ldlinux.e64  /var/lib/tftpboot/efi64/
cp /usr/lib/syslinux/modules/efi64/libcom32.c32 /var/lib/tftpboot/efi64/
cp /usr/lib/syslinux/modules/efi64/vesamenu.c32 /var/lib/tftpboot/efi64/
cp /usr/lib/syslinux/modules/efi64/libutil.c32  /var/lib/tftpboot/efi64/
cp /usr/lib/syslinux/modules/efi64/chain.c32    /var/lib/tftpboot/efi64/
cp /usr/lib/syslinux/modules/efi64/reboot.c32   /var/lib/tftpboot/efi64/

cp /usr/lib/syslinux/modules/bios/ldlinux.c32  /var/lib/tftpboot/bios/
cp /usr/lib/syslinux/modules/bios/libcom32.c32 /var/lib/tftpboot/bios/
cp /usr/lib/syslinux/modules/bios/vesamenu.c32 /var/lib/tftpboot/bios/
cp /usr/lib/syslinux/modules/bios/libutil.c32  /var/lib/tftpboot/bios/
cp /usr/lib/syslinux/modules/bios/chain.c32    /var/lib/tftpboot/bios/
cp /usr/lib/syslinux/modules/bios/reboot.c32   /var/lib/tftpboot/bios/

cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /var/lib/tftpboot/efi64/
cp /usr/lib/PXELINUX/pxelinux.0              /var/lib/tftpboot/bios/
```

### 5. Configurer le menu principal PXELINUX

La configuration du menu principal PXELINUX est disponible ici :
[`configs/pxelinux-default`](configs/pxelinux-default)

### 6. Configurer Apache

Dans le répertoire `/etc/apache2/sites-available/`, créez le fichier `pxe.conf` à partir de l'exemple suivant :
[`configs/pxe.conf`](configs/pxe.conf)

Désactivez ensuite le site par défaut, activez le nouveau site et rechargez Apache :

```bash
a2dissite 000-default.conf
a2ensite pxe
systemctl reload apache2
```

### 7. Créer les menus Ubuntu

Dans cet exemple, le déploiement concerne Ubuntu 22.04.

Dans le répertoire `/var/lib/tftpboot/ubuntu22/`, créez le fichier `ubuntu22.menu` en vous basant sur :
[`configs/ubuntu22.menu`](configs/ubuntu22.menu)

Des exemples de menus pour les installations automatique et manuelle sont également disponibles :

- [`configs/ubuntu22_auto.menu`](configs/ubuntu22_auto.menu)
- [`configs/ubuntu22_manual.menu`](configs/ubuntu22_manual.menu)

### 8. Configurer l'installation automatique

Dans le répertoire `/var/www/NOM_VERSION/server/`, créez le fichier `user-data` utilisé par Cloud-init / Autoinstall.

Un exemple de configuration est disponible ici :
[`configs/user-data.yaml`](configs/user-data.yaml)

Pour générer le hash du mot de passe à renseigner dans la section `identity`, utilisez :

```bash
mkpasswd --method=SHA-512
```

Renseignez le mot de passe demandé, puis copiez le résultat dans le fichier `user-data`.

Créez ensuite le fichier `meta-data` dans le même répertoire. Il peut être vide, mais reste nécessaire :

```bash
touch meta-data
```

### 9. Préparer le kernel et l'initrd

Créez les répertoires nécessaires dans `/var/lib/tftpboot/DOSSIER_VERSION/`.

Exemple pour Ubuntu 22.04 :

```bash
mkdir -p /var/lib/tftpboot/ubuntu22/{desktop,server}
```

Récupérez ensuite l'image ISO Ubuntu et extrayez les fichiers `vmlinuz` et `initrd` nécessaires au démarrage PXE.

Exemple pour Ubuntu Server 22.04 :

```bash
wget https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso
mkdir -p /mnt/iso
mount -o loop /var/www/iso/ubuntu-22.04.5-live-server-amd64.iso /mnt/iso/
cp /mnt/iso/casper/vmlinuz server/
cp /mnt/iso/casper/initrd server/
```

### 10. Configurer le DHCP

Enfin, un serveur DHCP doit être configuré afin que les clients puissent obtenir leur configuration réseau et les informations nécessaires au démarrage sur le serveur PXE.

## 📌 Points clés

- **Simplicité :** PXE permet d'automatiser le déploiement d'un système d'exploitation.
- **Flexibilité :** plusieurs versions ou profils d'installation peuvent être proposés dans le menu de démarrage.
- **Centralisation :** les fichiers nécessaires au démarrage et à l'installation sont distribués depuis l'infrastructure PXE.
- **Automatisation :** l'utilisation de Cloud-init / Autoinstall permet de réduire les interventions manuelles pendant l'installation.
