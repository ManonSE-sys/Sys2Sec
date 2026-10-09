# Serveur FTP avec vsftpd

## 📌 Présentation

**vsftpd (Very Secure FTP Daemon)** est un serveur FTP léger permettant de transférer des fichiers entre plusieurs machines sur un réseau.

Ce projet documente l'installation et la configuration d'un serveur `vsftpd` sous Ubuntu, la création d'un utilisateur dédié ainsi que le test de la connexion depuis un client.

> ⚠️ Le protocole FTP classique ne chiffre pas les identifiants ni les données échangées. Cette configuration est donc adaptée à un environnement de test ou à un réseau maîtrisé. Pour un usage réel, FTPS ou SFTP sont préférables.

---

## 🎯 Objectifs

Cette mise en place permet de :

- installer un serveur FTP ;
- désactiver les connexions anonymes ;
- autoriser les utilisateurs locaux ;
- créer un utilisateur dédié ;
- limiter l'utilisateur à son répertoire FTP ;
- autoriser les dépôts de fichiers dans un sous-répertoire dédié ;
- tester le fonctionnement depuis un client.

---

## 🏗️ Architecture

```text
Client FTP
    │
    │ Connexion FTP
    ▼
Serveur vsftpd
    │
    └── /home/ftpuser/ftp/
            └── upload/
```

---

## 1. Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Installer vsftpd

```bash
sudo apt install vsftpd -y
```

Vérifier que le service est présent :

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

---

## 4. Configurer vsftpd

Éditer le fichier :

```bash
sudo vi /etc/vsftpd.conf
```

La configuration utilisée pour ce projet est disponible ici :

👉 [`configs/vsftpd.conf`](configs/vsftpd.conf)

Les principaux paramètres configurés sont :

- désactivation de l'accès anonyme ;
- activation des comptes locaux ;
- autorisation de l'écriture ;
- activation des journaux ;
- confinement des utilisateurs locaux avec `chroot_local_user=YES` ;
- définition d'un répertoire FTP dédié.

---

## 5. Créer l'utilisateur FTP

Créer un utilisateur dédié :

```bash
sudo adduser ftpuser
```

Créer ensuite l'arborescence FTP :

```bash
sudo mkdir -p /home/ftpuser/ftp/upload
```

Configurer les droits sur la racine FTP :

```bash
sudo chown root:root /home/ftpuser/ftp
sudo chmod 755 /home/ftpuser/ftp
```

Donner ensuite à l'utilisateur les droits sur le répertoire d'upload :

```bash
sudo chown ftpuser:ftpuser /home/ftpuser/ftp/upload
sudo chmod 750 /home/ftpuser/ftp/upload
```

Cette organisation permet de conserver une racine FTP contrôlée tout en laissant à l'utilisateur un répertoire dédié pour déposer des fichiers.

---

## 6. Redémarrer le service

Après modification de la configuration :

```bash
sudo systemctl restart vsftpd
```

Vérifier ensuite son état :

```bash
systemctl status vsftpd
```

---

## 7. Tester la connexion

Depuis une machine cliente :

```bash
ftp <IP_DU_SERVEUR>
```

S'authentifier avec le compte créé :

```text
Utilisateur : ftpuser
Mot de passe : ********
```

Quelques commandes FTP peuvent ensuite être utilisées :

```text
ls
cd upload
put fichier.txt
get fichier.txt
```

---

## 🔐 Points d'attention

Quelques précautions sont importantes :

- désactiver les connexions anonymes lorsqu'elles ne sont pas nécessaires ;
- limiter les utilisateurs autorisés ;
- isoler les utilisateurs dans leur répertoire ;
- appliquer des permissions adaptées sur les répertoires ;
- surveiller les journaux de connexion et de transfert ;
- éviter FTP classique sur un réseau non maîtrisé.

Pour un usage réel, **FTPS** ou **SFTP** permettent de protéger les échanges avec du chiffrement.

---

## 🔐 Sécurité et durcissement

### Désactiver les connexions anonymes

```ini
anonymous_enable=NO
```

Cela évite qu'un utilisateur non authentifié puisse accéder au serveur.

---

### Restreindre les utilisateurs à leur répertoire

```ini
chroot_local_user=YES
```

Cette option permet de limiter les utilisateurs locaux à leur environnement FTP et de réduire leur visibilité sur le système.

---

### Limiter les droits d'écriture

Les utilisateurs ne doivent disposer de droits d'écriture que sur les répertoires nécessaires.

Exemple :

```text
/home/ftpuser/ftp        → contrôlé par root
/home/ftpuser/ftp/upload → accessible en écriture à ftpuser
```

Cette séparation évite de rendre toute la racine FTP modifiable.

---

### Éviter FTP classique sur un réseau non maîtrisé

FTP classique ne chiffre ni :

- les identifiants ;
- les commandes ;
- les fichiers transférés.

Une interception du trafic réseau peut donc exposer les données échangées.

Pour un usage réel, il est préférable d'utiliser :

- **FTPS** pour conserver le protocole FTP avec TLS ;
- **SFTP** lorsque SSH est disponible.

---

### Activer TLS avec vsftpd

Pour utiliser FTPS, vsftpd peut être configuré avec un certificat TLS.

Exemple :

```ini
ssl_enable=YES
force_local_logins_ssl=YES
force_local_data_ssl=YES

rsa_cert_file=/etc/ssl/certs/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key
```

> ⚠️ Un certificat adapté à l'environnement doit être utilisé.  
> Les certificats de test ne doivent pas être utilisés en production.

---

### Limiter le mode passif

Si le mode passif est utilisé, il est préférable de définir une plage de ports précise :

```ini
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
```

Cela permet de n'ouvrir dans le pare-feu que les ports réellement nécessaires.

---

### Restreindre l'accès réseau

Le serveur FTP ne devrait être accessible que depuis les réseaux ou machines qui en ont besoin.

Le filtrage peut être effectué via :

- le pare-feu du serveur ;
- un pare-feu réseau ;
- des ACL réseau.

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

### Surveiller les connexions

Les journaux permettent de détecter :

- les échecs d'authentification ;
- les connexions inhabituelles ;
- les transferts de fichiers ;
- les erreurs du service.

```bash
journalctl -u vsftpd
```

```bash
tail -f /var/log/vsftpd.log
```

---

### Appliquer le principe du moindre privilège

Les comptes FTP doivent :

- avoir uniquement les droits nécessaires ;
- être limités aux répertoires utiles ;
- ne pas disposer de privilèges administrateur ;
- utiliser des mots de passe robustes ;
- être désactivés lorsqu'ils ne sont plus nécessaires.

---

## 🔎 Diagnostic

Les principales commandes de diagnostic et d'exploitation sont regroupées dans une fiche dédiée :

👉 [Voir les commandes utiles vsftpd](./commandes-utiles.md)

---

## 📌 Points clés

- **Transfert de fichiers :** vsftpd permet de mettre en place rapidement un service FTP.
- **Isolation :** le chroot limite les utilisateurs à leur espace.
- **Permissions :** la racine FTP et le répertoire d'upload disposent de droits distincts.
- **Journalisation :** les connexions et transferts peuvent être suivis dans les logs.
- **Sécurité :** FTP classique ne chiffre pas les échanges.
