# Installation et configuration NFS

## 📌 Objectif

Cette fiche décrit la mise en place d'un serveur NFS sous Ubuntu ainsi que la configuration d'un client Linux.

Architecture utilisée :

```text
Client Linux
    │
    │ NFS
    ▼
Serveur NFS
    │
    └── /srv/nfs/share
```

---

# Serveur NFS

## 1. Mettre à jour l'index des paquets

```bash
sudo apt update
```

---

## 2. Installer le serveur NFS

```bash
sudo apt install nfs-kernel-server -y
```

---

## 3. Créer le répertoire à partager

```bash
sudo mkdir -p /srv/nfs/share
```

Vérifier les permissions :

```bash
ls -ld /srv/nfs/share
```

Les permissions et le propriétaire doivent être adaptés à l'usage prévu.

> ⚠️ NFS ne remplace pas les permissions Unix du système de fichiers.

---

## 4. Configurer les exports

Le fichier principal de configuration est :

```text
/etc/exports
```

L'éditer avec :

```bash
sudo nano /etc/exports
```

Exemple :

```text
/srv/nfs/share 192.168.1.0/24(rw,sync,no_subtree_check)
```

### Options utilisées

`rw`

Autorise la lecture et l'écriture.

`sync`

Demande au serveur de valider les écritures de manière synchrone.

`no_subtree_check`

Désactive la vérification des sous-répertoires.

---

## 5. Recharger les exports

Après modification de `/etc/exports` :

```bash
sudo exportfs -ra
```

Vérifier les exports actifs :

```bash
sudo exportfs -v
```

---

## 6. Démarrer et activer le service

```bash
sudo systemctl enable --now nfs-kernel-server
```

Vérifier son état :

```bash
systemctl status nfs-kernel-server
```

---

# Client NFS

## 7. Installer les outils NFS

Sur le client :

```bash
sudo apt update
sudo apt install nfs-common -y
```

---

## 8. Vérifier les exports disponibles

```bash
showmount -e <IP_DU_SERVEUR>
```

Exemple :

```bash
showmount -e 192.168.1.10
```

Le partage :

```text
/srv/nfs/share
```

doit apparaître.

---

## 9. Créer le point de montage

```bash
sudo mkdir -p /mnt/nfs_share
```

---

## 10. Monter le partage

```bash
sudo mount -t nfs <IP_DU_SERVEUR>:/srv/nfs/share /mnt/nfs_share
```

Vérifier le montage :

```bash
findmnt -t nfs,nfs4
```

ou :

```bash
mount | grep nfs
```

---

# Validation

## 11. Tester la lecture et l'écriture

Créer un fichier depuis le client :

```bash
touch /mnt/nfs_share/test.txt
```

Puis vérifier sa présence :

```bash
ls -l /mnt/nfs_share
```

Le fichier doit également être visible sur le serveur :

```bash
ls -l /srv/nfs/share
```

---

## 12. Vérifier les permissions

Sur le serveur :

```bash
ls -ld /srv/nfs/share
```

Sur le client :

```bash
ls -ld /mnt/nfs_share
```

Si nécessaire, vérifier également les UID et GID :

```bash
id utilisateur
```

---

# Montage automatique

## 13. Configurer `/etc/fstab`

Sur le client, éditer :

```text
/etc/fstab
```

Exemple :

```text
<IP_DU_SERVEUR>:/srv/nfs/share /mnt/nfs_share nfs defaults,_netdev 0 0
```

L'option :

```text
_netdev
```

indique que le montage dépend de la disponibilité du réseau.

---

## 14. Tester la configuration

Avant tout redémarrage :

```bash
sudo mount -a
```

Puis vérifier :

```bash
findmnt -t nfs,nfs4
```

> ⚠️ Une erreur dans `/etc/fstab` peut provoquer des problèmes de montage au démarrage. Il est donc important de tester la configuration avant de redémarrer.

---

# Vérifications finales

Sur le serveur :

```bash
systemctl status nfs-kernel-server
sudo exportfs -v
```

Sur le client :

```bash
showmount -e <IP_DU_SERVEUR>
findmnt -t nfs,nfs4
```

Tester ensuite les accès :

```bash
touch /mnt/nfs_share/test.txt
```

---

# Résultat attendu

À la fin de la configuration :

```text
Serveur NFS
    │
    ├── service actif
    ├── /srv/nfs/share exporté
    └── client autorisé

Client NFS
    │
    ├── partage visible
    ├── partage monté
    └── accès lecture/écriture fonctionnel
```

---

## Voir aussi

* [Commandes utiles NFS](./commandes-utiles.md)
