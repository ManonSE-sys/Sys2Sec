# Serveur FTP avec vsftpd

## 📌 Présentation

**vsftpd (Very Secure FTP Daemon)** est un serveur FTP léger permettant de transférer des fichiers entre plusieurs machines sur un réseau.

Ce projet documente la mise en place d'un serveur `vsftpd` sous Ubuntu, avec une attention particulière portée à l'isolation des utilisateurs, aux permissions, à la journalisation et aux risques liés au protocole FTP.

> ⚠️ FTP classique ne chiffre ni les identifiants ni les données échangées. La configuration présentée ici est donc destinée à un environnement de lab ou à un réseau maîtrisé. Pour un usage réel, FTPS ou SFTP sont préférables.

---

## 🎯 Objectifs

Ce projet permet de travailler sur :

* la mise en place d'un serveur FTP ;
* la gestion des utilisateurs locaux ;
* l'isolation des utilisateurs avec `chroot` ;
* les permissions Unix ;
* les transferts de fichiers ;
* la journalisation ;
* la sécurité d'un service réseau ;
* le diagnostic d'un service FTP.

---

## 🏗️ Architecture

```text
Client FTP
    │
    │ FTP
    │ TCP 21
    ▼
Serveur vsftpd
    │
    └── /home/ftpuser/ftp/
            │
            └── upload/
```

La racine FTP :

```text
/home/ftpuser/ftp
```

est contrôlée par `root`.

Le sous-répertoire :

```text
/home/ftpuser/ftp/upload
```

est accessible en écriture à l'utilisateur FTP.

---

## ⚙️ Fonctionnement

Le service `vsftpd` écoute les connexions FTP et authentifie les utilisateurs locaux autorisés.

Dans ce projet :

```text
Client
   │
   │ Authentification
   ▼
vsftpd
   │
   ├── utilisateur local : ftpuser
   │
   ├── chroot
   │
   └── /home/ftpuser/ftp
                    │
                    └── upload/
```

La configuration principale se trouve dans :

```text
/etc/vsftpd.conf
```

La configuration utilisée pour ce lab est disponible dans :

👉 [`configs/vsftpd.conf`](./configs/vsftpd.conf)

---

## 👤 Gestion de l'utilisateur FTP

Un compte dédié est utilisé pour accéder au service :

```text
ftpuser
```

L'arborescence est organisée de manière à séparer la racine FTP du répertoire accessible en écriture :

```text
/home/ftpuser/
└── ftp/
    └── upload/
```

Principe :

```text
/home/ftpuser/ftp
        │
        └── contrôlé par root
                │
                └── upload/
                     contrôlé par ftpuser
```

Cette organisation évite de rendre toute la racine FTP modifiable par l'utilisateur.

---

## 🔒 Isolation avec chroot

La configuration utilise :

```ini
chroot_local_user=YES
```

Cette option permet de limiter les utilisateurs locaux à leur environnement FTP.

L'utilisateur ne peut donc pas parcourir librement le reste de l'arborescence du serveur depuis sa session FTP.

Le répertoire utilisé comme racine est défini avec :

```ini
local_root=/home/ftpuser/ftp
```

---

## ✍️ Gestion des écritures

L'écriture est autorisée avec :

```ini
write_enable=YES
```

Cependant, les permissions Unix déterminent toujours les répertoires réellement modifiables.

Dans ce projet :

```text
/home/ftpuser/ftp
        → root:root
        → non modifiable par ftpuser

/home/ftpuser/ftp/upload
        → ftpuser:ftpuser
        → accessible en écriture
```

Cette séparation applique le principe du moindre privilège.

---

## 📄 Journalisation

La journalisation des transferts est activée dans la configuration :

```ini
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
```

Les journaux peuvent être consultés avec :

```bash
tail -f /var/log/vsftpd.log
```

Les événements liés au service peuvent également être consultés avec :

```bash
journalctl -u vsftpd
```

La journalisation permet notamment d'identifier :

* les erreurs du service ;
* certains problèmes de connexion ;
* les transferts effectués ;
* des comportements inhabituels.

---

# 🔐 Sécurité et durcissement

## Désactiver les connexions anonymes

La configuration utilise :

```ini
anonymous_enable=NO
```

Les utilisateurs non authentifiés ne peuvent donc pas accéder au serveur FTP.

---

## Limiter les utilisateurs à leur répertoire

```ini
chroot_local_user=YES
```

Cette option réduit la visibilité des utilisateurs sur le système.

Elle ne remplace cependant pas les permissions Unix.

---

## Limiter les droits d'écriture

Un utilisateur FTP ne doit disposer de droits d'écriture que sur les répertoires nécessaires.

Dans ce projet :

```text
/home/ftpuser/ftp
        │
        └── lecture / navigation
                │
                └── upload/
                     écriture autorisée
```

Cette séparation limite l'impact d'une erreur ou d'un compte compromis.

---

## Éviter FTP classique sur un réseau non maîtrisé

FTP classique ne chiffre pas :

* les identifiants ;
* les commandes ;
* les fichiers transférés.

Une interception du trafic peut donc exposer les informations échangées.

Pour un environnement réel, il est préférable d'utiliser :

* **FTPS**, qui ajoute TLS au protocole FTP ;
* **SFTP**, qui repose sur SSH.

---

## FTPS avec vsftpd

`vsftpd` peut utiliser TLS afin de protéger l'authentification et les transferts.

Exemple de paramètres :

```ini
ssl_enable=YES
force_local_logins_ssl=YES
force_local_data_ssl=YES

rsa_cert_file=/etc/ssl/certs/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key
```

Le certificat et sa clé privée doivent être adaptés à l'environnement et correctement protégés.

> ⚠️ Le lab présenté dans ce projet utilise FTP classique afin d'étudier le fonctionnement du service. TLS n'est pas activé dans la configuration fournie.

---

## Mode passif

Lors de l'utilisation du mode passif, il est possible de définir une plage de ports précise :

```ini
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
```

Cela permet de limiter les ports supplémentaires à autoriser dans le pare-feu.

---

## Restreindre l'accès réseau

Le serveur FTP ne devrait être accessible que depuis les réseaux ou machines qui en ont besoin.

Le filtrage peut être réalisé avec :

* le pare-feu du serveur ;
* un pare-feu réseau ;
* des ACL réseau.

Principe :

```text
Clients autorisés
       │
       ▼
Pare-feu
       │
       ▼
Serveur vsftpd
```

---

## Principe du moindre privilège

Les comptes FTP doivent :

* disposer uniquement des droits nécessaires ;
* être limités aux répertoires utiles ;
* ne pas disposer de privilèges administrateur ;
* utiliser des mécanismes d'authentification adaptés ;
* être désactivés lorsqu'ils ne sont plus nécessaires.

---

## 🚀 Installation et configuration

La procédure complète de mise en place du serveur, de l'utilisateur FTP et des permissions est disponible dans une fiche dédiée :

👉 [Installation et configuration de vsftpd](./installation.md)

---

## 📚 Commandes utiles

Les principales commandes d'administration et de diagnostic sont regroupées dans :

👉 [Commandes utiles vsftpd](./commandes-utiles.md)

---

## ✅ Validation

Après configuration, plusieurs contrôles permettent de vérifier le fonctionnement du service.

Vérifier son état :

```bash
systemctl status vsftpd
```

Vérifier que le port FTP est en écoute :

```bash
ss -lntp | grep ':21'
```

Vérifier l'utilisateur :

```bash
id ftpuser
```

Vérifier les permissions :

```bash
ls -ld /home/ftpuser/ftp
ls -ld /home/ftpuser/ftp/upload
```

Puis tester une connexion depuis un client :

```bash
ftp <IP_DU_SERVEUR>
```

---

## 📌 Points clés

* `vsftpd` permet de mettre en place un service FTP sous Linux.
* Les accès anonymes peuvent être désactivés.
* `chroot` permet de limiter la visibilité des utilisateurs.
* Les permissions Unix restent essentielles.
* La racine FTP et le répertoire d'upload peuvent disposer de droits différents.
* La journalisation facilite le diagnostic et la surveillance.
* FTP classique ne chiffre pas les communications.
* FTPS ou SFTP sont préférables sur un réseau non maîtrisé.

---

## 🧠 Compétences mises en pratique

Ce projet permet de travailler sur :

* administration Linux ;
* services réseau ;
* FTP ;
* gestion des utilisateurs ;
* permissions Unix ;
* chroot ;
* journalisation ;
* sécurité des services ;
* analyse des flux réseau ;
* troubleshooting Linux.
