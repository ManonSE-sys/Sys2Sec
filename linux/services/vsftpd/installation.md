# Installation et configuration de vsftpd

## 📌 Objectif

Cette fiche décrit la mise en place d'un serveur FTP `vsftpd` sous Ubuntu.

Le lab utilise l'architecture suivante :

```text
Client FTP
    │
    │ FTP
    ▼
Serveur vsftpd
    │
    └── /home/ftpuser/ftp/
            └── upload/
```

> ⚠️ Cette configuration utilise FTP classique et est destinée à un environnement de test. Les communications ne sont pas chiffrées.

---

# Installation

## 1. Mettre à jour l'index des paquets

```bash
sudo apt update
```

---

## 2. Installer vsftpd

```bash
sudo apt install vsftpd -y
```

Vérifier que le service est disponible :

```bash
systemctl status vsftpd
```

---

## 3. Sauvegarder la configuration d'origine

Avant toute modification :

```bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
```

Le fichier principal de configuration est :

```text
/etc/vsftpd.conf
```

Cette sauvegarde permet de restaurer facilement la configuration initiale en cas de problème.

---

# Configuration

## 4. Configurer vsftpd

Éditer :

```bash
sudo vi /etc/vsftpd.conf
```

La configuration utilisée pour ce projet est disponible ici :

👉 [`configs/vsftpd.conf`](./configs/vsftpd.conf)

Les principaux paramètres utilisés sont :

```ini
listen=YES
listen_ipv6=NO

anonymous_enable=NO
local_enable=YES
write_enable=YES

dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log

chroot_local_user=YES
local_root=/home/ftpuser/ftp

pam_service_name=vsftpd

ssl_enable=NO
```

Cette configuration permet notamment :

* d'écouter en IPv4 ;
* de désactiver les connexions anonymes ;
* d'autoriser les utilisateurs locaux ;
* d'autoriser les opérations d'écriture ;
* de journaliser les transferts ;
* de limiter les utilisateurs à leur environnement FTP ;
* de définir une racine FTP dédiée.

---

# Utilisateur FTP

## 5. Créer un utilisateur dédié

Créer le compte :

```bash
sudo adduser ftpuser
```

Le compte sera utilisé pour les tests de connexion FTP.

---

## 6. Créer l'arborescence

Créer le répertoire d'upload :

```bash
sudo mkdir -p /home/ftpuser/ftp/upload
```

L'arborescence obtenue est :

```text
/home/ftpuser/
└── ftp/
    └── upload/
```

---

## 7. Configurer la racine FTP

La racine FTP est contrôlée par `root` :

```bash
sudo chown root:root /home/ftpuser/ftp
sudo chmod 755 /home/ftpuser/ftp
```

Cette configuration permet notamment d'éviter que l'utilisateur FTP puisse modifier directement sa racine chrootée.

---

## 8. Configurer le répertoire d'upload

Donner la propriété du répertoire à l'utilisateur :

```bash
sudo chown ftpuser:ftpuser /home/ftpuser/ftp/upload
sudo chmod 750 /home/ftpuser/ftp/upload
```

Principe :

```text
/home/ftpuser/ftp
        │
        ├── root:root
        └── permissions 755
                │
                └── upload/
                     ├── ftpuser:ftpuser
                     └── permissions 750
```

L'utilisateur peut ainsi déposer des fichiers dans `upload/` sans disposer de droits d'écriture sur toute la racine FTP.

---

# Activation du service

## 9. Redémarrer vsftpd

Après modification de la configuration :

```bash
sudo systemctl restart vsftpd
```

Vérifier son état :

```bash
systemctl status vsftpd
```

---

## 10. Activer le service au démarrage

```bash
sudo systemctl enable vsftpd
```

---

# Validation

## 11. Vérifier le port en écoute

FTP utilise principalement le port TCP `21` pour la connexion de contrôle.

Vérifier :

```bash
ss -lntp | grep ':21'
```

---

## 12. Vérifier les permissions

```bash
ls -ld /home/ftpuser/ftp
ls -ld /home/ftpuser/ftp/upload
```

Vérifier également le compte :

```bash
id ftpuser
```

---

# Test depuis un client

## 13. Se connecter au serveur

Depuis une machine cliente :

```bash
ftp <IP_DU_SERVEUR>
```

S'authentifier avec le compte créé :

```text
Utilisateur : ftpuser
Mot de passe : ********
```

---

## 14. Tester la navigation

Une fois connecté :

```text
ls
cd upload
```

---

## 15. Tester un envoi de fichier

```text
put fichier.txt
```

Vérifier ensuite côté serveur :

```bash
ls -l /home/ftpuser/ftp/upload
```

---

## 16. Tester un téléchargement

Depuis le client :

```text
get fichier.txt
```

---

# Vérification des journaux

Consulter le journal de transfert :

```bash
tail -f /var/log/vsftpd.log
```

Consulter les événements systemd :

```bash
journalctl -u vsftpd
```

---

# Résultat attendu

À la fin de la configuration :

```text
Serveur vsftpd
    │
    ├── service actif
    ├── port TCP 21 en écoute
    │
    ├── accès anonyme désactivé
    │
    ├── utilisateur local autorisé
    │
    ├── utilisateur chrooté
    │
    └── /home/ftpuser/ftp/
            │
            └── upload/
                 accessible à ftpuser
```

Depuis le client :

```text
Connexion
   ↓
Authentification
   ↓
Accès au répertoire FTP
   ↓
Upload / Download
```

---

## 🔐 Limite du lab

Le fichier de configuration fourni contient :

```ini
ssl_enable=NO
```

Les identifiants et fichiers transitent donc sans chiffrement.

Cette configuration permet d'étudier le fonctionnement de FTP et de `vsftpd`, mais ne doit pas être considérée comme une configuration adaptée à un réseau non maîtrisé.

Pour protéger les communications, utiliser :

* FTPS avec TLS ;
* ou SFTP via SSH.

---

## Voir aussi

* [README principal](./README.md)
* [Configuration vsftpd](./configs/vsftpd.conf)
* [Commandes utiles](./commandes-utiles.md)
