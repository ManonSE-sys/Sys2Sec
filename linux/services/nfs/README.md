# Partage de fichiers avec NFS

## 📌 Présentation

**NFS (Network File System)** permet de partager des fichiers et des répertoires entre plusieurs machines Linux sur un réseau.

Ce projet documente la mise en place et l'administration d'un partage NFS sous Ubuntu, avec une attention portée à la configuration, aux permissions, à la sécurité et au diagnostic.

---

## 🎯 Objectifs

Ce projet permet de travailler sur :

* le partage de fichiers entre plusieurs machines Linux ;
* la centralisation de données sur un serveur ;
* la configuration des exports NFS ;
* le contrôle des clients autorisés ;
* les montages manuels et persistants ;
* les permissions Unix ;
* la sécurité des partages ;
* le troubleshooting côté serveur et côté client.

---

## 🏗️ Architecture

```text
Client Linux
    │
    │ NFS
    ▼
Serveur NFS
    │
    └── /srv/nfs/share
```

Dans cet exemple, le serveur exporte le répertoire :

```text
/srv/nfs/share
```

vers les clients autorisés.

---

## ⚙️ Fonctionnement

Le serveur NFS publie un ou plusieurs répertoires configurés dans :

```text
/etc/exports
```

Exemple :

```text
/srv/nfs/share 192.168.1.0/24(rw,sync,no_subtree_check)
```

Un client autorisé peut ensuite monter ce partage sur son système de fichiers local.

Exemple :

```bash
sudo mount -t nfs <IP_DU_SERVEUR>:/srv/nfs/share /mnt/nfs_share
```

Le partage apparaît alors comme un répertoire local, tout en utilisant les données stockées sur le serveur NFS.

---

## 📂 Gestion des exports

Les exports sont définis dans :

```text
/etc/exports
```

Les principales options utilisées dans ce projet sont :

| Option             | Description                                    |
| ------------------ | ---------------------------------------------- |
| `rw`               | Autorise la lecture et l'écriture              |
| `sync`             | Valide les écritures de manière synchrone      |
| `no_subtree_check` | Désactive la vérification des sous-répertoires |

Après une modification de `/etc/exports`, les exports peuvent être rechargés avec :

```bash
sudo exportfs -ra
```

et vérifiés avec :

```bash
sudo exportfs -v
```

---

## 🔐 Sécurité

La configuration d'un partage NFS doit prendre en compte plusieurs éléments.

### Limiter les clients autorisés

Il est préférable de limiter l'accès aux machines ou réseaux réellement nécessaires.

Par exemple :

```text
/srv/nfs/share 192.168.1.0/24(rw,sync,no_subtree_check)
```

est préférable à un export accessible à tous les clients.

---

### Permissions Unix

NFS s'appuie sur les permissions du système de fichiers.

Il est donc important de vérifier :

* le propriétaire ;
* le groupe ;
* les permissions ;
* les UID et GID.

Exemple :

```bash
ls -ld /srv/nfs/share
```

---

### Root squashing

NFS utilise généralement :

```text
root_squash
```

Ce mécanisme empêche un utilisateur `root` provenant d'un client d'obtenir automatiquement les privilèges root sur le serveur.

L'option :

```text
no_root_squash
```

doit être utilisée avec prudence, car elle réduit fortement l'isolation entre le client et le serveur.

---

### Réseau et pare-feu

Le service NFS ne doit être accessible que depuis les réseaux nécessaires.

Les règles de pare-feu doivent être adaptées à l'architecture utilisée.

---

## 💾 Montage persistant

Un partage NFS peut être monté automatiquement au démarrage grâce à :

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

La configuration doit être testée avant redémarrage avec :

```bash
sudo mount -a
```

---

## 🚀 Installation et configuration

La procédure complète de mise en place du serveur et du client est disponible dans une fiche dédiée :

👉 [Installation et configuration NFS](./installation.md)

---

## 🛠️ Troubleshooting

Les incidents courants sont documentés dans le dossier :

```text
troubleshooting/
```

Cas documentés :

* accès refusé lors de l'utilisation du partage ;
* échec du montage ;
* export NFS non visible depuis le client.

👉 [Voir la documentation de troubleshooting](./troubleshooting/)

---

## 📚 Commandes utiles

Une fiche regroupe les principales commandes utilisées pour administrer et diagnostiquer NFS.

👉 [Voir les commandes utiles NFS](./commandes-utiles.md)

---

## ✅ Validation

Plusieurs commandes permettent de vérifier le fonctionnement du service.

Sur le serveur :

```bash
sudo exportfs -v
```

Depuis le client :

```bash
showmount -e <IP_DU_SERVEUR>
```

Vérifier le montage :

```bash
findmnt -t nfs,nfs4
```

Puis effectuer un test de lecture ou d'écriture sur le partage.

---

## 📌 Points clés

* NFS permet de partager des fichiers entre plusieurs systèmes Linux.
* `/etc/exports` définit les répertoires exportés et les clients autorisés.
* `exportfs` permet de gérer et vérifier les exports.
* Les permissions Unix restent applicables.
* Les UID et GID influencent les droits d'accès.
* `/etc/fstab` permet de rendre les montages persistants.
* `_netdev` indique qu'un montage dépend du réseau.
* `root_squash` permet de limiter les privilèges root provenant d'un client.
* Les problèmes NFS peuvent provenir du réseau, des exports, des permissions ou du système de fichiers.

---

## 🧠 Compétences mises en pratique

Ce projet permet de travailler sur :

* administration Linux ;
* services réseau ;
* NFS ;
* permissions Unix ;
* gestion des systèmes de fichiers ;
* configuration réseau ;
* montages persistants ;
* sécurité des services ;
* troubleshooting Linux.
