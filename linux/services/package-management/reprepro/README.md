# Dépôt APT local signé avec Reprepro

## 📌 Présentation

Ce projet documente la mise en place d'un **dépôt APT local** sous Ubuntu à l'aide de :

* **Reprepro** pour gérer les paquets et métadonnées ;
* **GnuPG** pour signer le dépôt ;
* **Apache** pour publier son contenu aux clients.

L'objectif est de centraliser certains paquets `.deb`, de contrôler les versions mises à disposition et de permettre à des clients Ubuntu de les installer depuis un dépôt interne signé.

---

## 🎯 Objectifs

Ce projet permet de travailler sur :

* la gestion d'un dépôt APT local ;
* la centralisation de paquets Debian ;
* la gestion des versions ;
* la signature GPG ;
* la publication HTTP avec Apache ;
* la configuration des sources APT ;
* la vérification de l'origine des paquets ;
* la sécurité d'une chaîne de distribution logicielle.

---

## 🏗️ Architecture

```text
Paquet .deb
    │
    ▼
Reprepro
    │
    ├── indexation
    ├── métadonnées
    └── signature GPG
    │
    ▼
/var/www/repos/ubuntu/
    │
    ▼
Apache
    │
    ▼
Client Ubuntu
    │
    ├── clé publique
    └── source APT locale
```

---

## ⚙️ Fonctionnement

Reprepro organise les paquets dans une structure compatible avec APT.

Lorsqu'un paquet est ajouté :

```text
Paquet .deb
    ↓
Reprepro
    ↓
Indexation
    ↓
Génération des métadonnées
    ↓
Signature
    ↓
Publication
```

Le client peut ensuite utiliser ce dépôt comme une source APT classique.

---

## 📂 Configuration du dépôt

La définition de la distribution se trouve dans :

```text
/var/www/repos/ubuntu/conf/distributions
```

Un exemple est disponible dans :

👉 [`configs/distributions`](./configs/distributions)

Exemple :

```text
Origin: srv-apt
Label: Local
Codename: noble
Architectures: source amd64
Components: main
Description: Dépôt APT local
SignWith: default
```

Le `Codename` et les architectures doivent être adaptés aux systèmes réellement ciblés.

---

## 🔑 Signature GPG

Le dépôt est signé avec une clé GPG.

Principe :

```text
Clé privée
    │
    └── signature du dépôt
            │
            ▼
       Métadonnées signées
            │
            ▼
       Client APT
            │
            └── vérification avec la clé publique
```

La **clé privée ne doit jamais être distribuée** aux clients.

Seule la clé publique est nécessaire pour vérifier les signatures.

---

## 🌐 Publication avec Apache

Le dépôt est publié depuis :

```text
/var/www/repos/ubuntu/
```

via un VirtualHost Apache.

La configuration utilisée est disponible dans :

👉 [`configs/25-apt-local.conf`](./configs/25-apt-local.conf)

Le client peut ensuite accéder au dépôt via une URL de type :

```text
http://serveur/ubuntu
```

---

## 💻 Configuration des clients

Le client dispose :

```text
Clé publique du dépôt
        +
Source APT
        ↓
apt update
        ↓
Vérification des métadonnées
        ↓
Installation des paquets
```

Une source peut par exemple être définie avec :

```text
deb [signed-by=/usr/share/keyrings/srv-apt.gpg] http://serveur/ubuntu noble main
```

L'utilisation de `signed-by` permet d'associer explicitement une clé au dépôt concerné.

---

## 🔐 Sécurité

### Protéger la clé privée

La clé utilisée pour signer le dépôt doit rester protégée.

Une compromission de cette clé pourrait permettre de signer du contenu malveillant comme s'il provenait du dépôt légitime.

---

### Distribuer uniquement la clé publique

Les clients ont uniquement besoin de la clé publique pour vérifier les signatures.

---

### Contrôler les paquets publiés

Avant d'ajouter un paquet au dépôt, il est important de contrôler :

* son origine ;
* sa version ;
* son architecture ;
* son intégrité ;
* sa nécessité.

---

### Maîtriser les versions

L'un des intérêts d'un dépôt interne est de contrôler les versions disponibles pour les systèmes de l'infrastructure.

Cela permet notamment d'éviter qu'une version non validée soit déployée automatiquement.

---

### Tester avant déploiement

Un paquet ou une nouvelle version doit idéalement être validé dans un environnement de test avant publication à grande échelle.

---

## 🚀 Installation et configuration

La procédure complète est disponible ici :

👉 [Installation et configuration du dépôt](./installation.md)

---

## ✅ Validation

Vérifier les paquets disponibles :

```bash
reprepro -b /var/www/repos/ubuntu list noble
```

Vérifier Apache :

```bash
systemctl status apache2
```

Tester sa configuration :

```bash
sudo apache2ctl configtest
```

Depuis un client :

```bash
sudo apt update
```

Puis vérifier l'origine d'un paquet :

```bash
apt-cache policy <paquet>
```

---

## 🔎 Diagnostic

### Apache

```bash
systemctl status apache2
```

```bash
sudo apache2ctl configtest
```

### Journaux

```bash
tail -f /var/log/apache2/srv-apt_error.log
```

```bash
tail -f /var/log/apache2/srv-apt_access.log
```

### Reprepro

```bash
reprepro -b /var/www/repos/ubuntu list noble
```

---

## 📌 Points clés

* Reprepro permet de gérer un dépôt APT interne.
* Les versions des paquets publiés peuvent être maîtrisées.
* GPG permet de signer le dépôt.
* Les clients utilisent la clé publique pour vérifier son authenticité.
* Apache permet de publier le dépôt sur le réseau.
* `signed-by` permet d'associer une clé précise à une source APT.
* La clé privée de signature constitue un élément critique.

---

## 🧠 Compétences mises en pratique

* administration Linux ;
* gestion de paquets Debian ;
* APT ;
* Reprepro ;
* GnuPG ;
* Apache ;
* gestion de clés ;
* sécurité de la chaîne logicielle ;
* gestion de versions ;
* troubleshooting.
