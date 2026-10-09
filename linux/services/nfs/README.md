# Partage de fichiers avec NFS

## 📌 Présentation

**NFS (Network File System)** permet de partager des fichiers et des répertoires entre plusieurs machines sur un réseau.

Ce projet documente la mise en place d'un serveur NFS sous Ubuntu, la configuration d'un répertoire partagé, ainsi que le montage du partage depuis un client Linux.

---

## 🎯 Objectifs

Cette mise en place permet de :

- partager un répertoire entre plusieurs machines ;
- centraliser l'accès à certains fichiers ;
- contrôler les clients autorisés à monter le partage ;
- monter le partage manuellement ou automatiquement ;
- diagnostiquer les principaux problèmes côté serveur et côté client.

---

## 🏗️ Architecture

```text
Client Linux
    │
    │ Montage NFS
    ▼
Serveur NFS
    │
    └── /srv/nfs/share
```

Dans cet exemple, le serveur exporte le répertoire :

```text
/srv/nfs/share
```

vers les clients autorisés sur le réseau.

---

## 1. Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Installer le serveur NFS

Installer le paquet nécessaire :

```bash
sudo apt install nfs-kernel-server -y
```

---

## 3. Créer le répertoire à partager

Créer le répertoire qui sera exporté :

```bash
sudo mkdir -p /srv/nfs/share
```

Les permissions et le propriétaire du répertoire doivent ensuite être adaptés à l'usage prévu.

> ⚠️ Les droits Unix appliqués au répertoire restent importants : le fait d'exporter un répertoire via NFS ne remplace pas la gestion des permissions locales.

---

## 4. Configurer les exports NFS

Le fichier principal de configuration des exports est :

```text
/etc/exports
```

L'éditer avec :

```bash
sudo nano /etc/exports
```

Exemple pour autoriser les machines du réseau `192.168.1.0/24` :

```text
/srv/nfs/share 192.168.1.0/24(rw,sync,no_subtree_check)
```

### Explication des options

- `rw` : autorise la lecture et l'écriture ;
- `sync` : demande au serveur de valider les écritures de manière synchrone ;
- `no_subtree_check` : désactive la vérification des sous-répertoires exportés.

> ⚠️ L'autorisation `192.168.1.0/24` ouvre le partage à l'ensemble de ce sous-réseau. Dans un environnement réel, il est préférable de limiter l'accès aux clients réellement nécessaires.

---

## 5. Appliquer la configuration

Recharger les exports :

```bash
sudo exportfs -ra
```

Afficher les exports actifs :

```bash
sudo exportfs -v
```

---

## 6. Démarrer et activer le service NFS

```bash
sudo systemctl start nfs-kernel-server
sudo systemctl enable nfs-kernel-server
```

Vérifier son état :

```bash
systemctl status nfs-kernel-server
```

---

## 7. Configurer un client NFS

Sur la machine cliente, installer les outils NFS :

```bash
sudo apt install nfs-common -y
```

Créer un point de montage :

```bash
sudo mkdir -p /mnt/nfs_share
```

---

## 8. Monter le partage manuellement

Monter le partage :

```bash
sudo mount -t nfs <IP_DU_SERVEUR>:/srv/nfs/share /mnt/nfs_share
```

Vérifier ensuite le montage :

```bash
df -h
```

Il est également possible de vérifier les montages NFS avec :

```bash
mount | grep nfs
```

---

## 9. Tester les accès

Créer ou modifier un fichier dans le partage afin de vérifier le fonctionnement en lecture et en écriture.

Exemple :

```bash
touch /mnt/nfs_share/test.txt
```

Si l'opération échoue, vérifier notamment :

- les permissions du répertoire sur le serveur ;
- les options définies dans `/etc/exports` ;
- l'adresse ou le réseau autorisé ;
- l'état du service NFS ;
- les journaux système.

---

## 10. Monter automatiquement le partage au démarrage

Sur le client, éditer :

```text
/etc/fstab
```

Exemple :

```text
<IP_DU_SERVEUR>:/srv/nfs/share /mnt/nfs_share nfs defaults,_netdev 0 0
```

L'option `_netdev` indique que le montage dépend du réseau.

Tester la configuration avant de redémarrer :

```bash
sudo mount -a
```

> ⚠️ Une erreur dans `/etc/fstab` peut perturber le démarrage ou le montage automatique. Il est donc important de toujours tester la configuration avec `mount -a`.

---

## 🔐 Points d'attention

Lors de la mise en place d'un partage NFS :

- limiter les clients autorisés à accéder au partage ;
- vérifier les permissions Unix du répertoire exporté ;
- éviter d'exposer inutilement le service à des réseaux non maîtrisés ;
- tester les droits en lecture et en écriture ;
- surveiller les journaux en cas d'erreur ;
- documenter les montages automatiques configurés dans `/etc/fstab`.

---

## 🔎 Diagnostic

Les principales commandes de diagnostic et d'administration sont regroupées dans une fiche dédiée :

👉 [Voir les commandes utiles NFS](./commandes-utiles.md)

---

## 📌 Points clés

- **Partage réseau :** NFS permet de mettre à disposition des fichiers sur plusieurs machines Linux.
- **Centralisation :** les données peuvent être regroupées sur un serveur dédié.
- **Contrôle d'accès :** les exports peuvent être limités à certains clients ou réseaux.
- **Persistance :** les montages peuvent être automatisés via `/etc/fstab`.
- **Diagnostic :** `exportfs`, `showmount`, `nfsstat` et les journaux permettent d'identifier les principaux problèmes.
