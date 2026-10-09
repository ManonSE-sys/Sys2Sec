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
