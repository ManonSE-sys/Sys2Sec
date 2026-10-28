# `reprepro/README.md`

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

---

# `reprepro/installation.md`

# Installation d'un dépôt APT avec Reprepro

## 📌 Objectif

Cette fiche décrit la création d'un dépôt APT interne signé avec GPG et publié avec Apache.

---

## 1. Mettre à jour l'index APT

```bash
sudo apt update
```

---

## 2. Installer les composants

```bash
sudo apt install reprepro gnupg apache2 -y
```

Les composants utilisés sont :

* Reprepro pour gérer le dépôt ;
* GnuPG pour la signature ;
* Apache pour sa publication.

---

## 3. Générer la clé GPG

```bash
gpg --full-generate-key
```

Afficher les clés :

```bash
gpg --list-keys
```

Repérer l'identifiant ou l'empreinte de la clé utilisée pour la signature.

> 🔐 La clé privée doit rester protégée.

---

## 4. Créer l'arborescence

```bash
sudo mkdir -p /var/www/repos/ubuntu/{conf,incoming}
```

Structure initiale :

```text
/var/www/repos/ubuntu/
├── conf/
└── incoming/
```

---

## 5. Configurer Reprepro

Créer :

```text
/var/www/repos/ubuntu/conf/distributions
```

La configuration de ce projet est disponible dans :

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

---

## 6. Ajouter un paquet

Placer le paquet dans :

```text
/var/www/repos/ubuntu/incoming/
```

Puis :

```bash
cd /var/www/repos/ubuntu
sudo reprepro -Vb . includedeb noble incoming/<paquet>.deb
```

Vérifier :

```bash
reprepro -b /var/www/repos/ubuntu list noble
```

---

## 7. Exporter la clé publique

```bash
gpg --armor --export ID_CLE \
  > /var/www/repos/ubuntu/repo-signing-key.asc
```

Le fichier exporté contient uniquement la clé publique.

---

## 8. Configurer Apache

La configuration utilisée est disponible dans :

👉 [`configs/25-apt-local.conf`](./configs/25-apt-local.conf)

Vérifier la syntaxe :

```bash
sudo apache2ctl configtest
```

Activer le site :

```bash
sudo a2dissite 000-default.conf
sudo a2ensite 25-apt-local.conf
sudo systemctl reload apache2
```

---

# Configuration cliente

## 9. Importer la clé publique

```bash
wget -O- http://ADRESSE_SERVEUR/ubuntu/repo-signing-key.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/srv-apt.gpg
```

---

## 10. Ajouter la source APT

Créer :

```text
/etc/apt/sources.list.d/srv-apt.list
```

avec :

```text
deb [signed-by=/usr/share/keyrings/srv-apt.gpg] http://ADRESSE_SERVEUR/ubuntu noble main
```

---

## 11. Actualiser les sources

```bash
sudo apt update
```

---

## 12. Tester le dépôt

Installer un paquet publié :

```bash
sudo apt install <paquet>
```

Vérifier sa provenance :

```bash
apt-cache policy <paquet>
```

---

## ✅ Résultat attendu

```text
Administrateur
      │
      ▼
Paquet .deb
      │
      ▼
Reprepro + signature
      │
      ▼
Apache
      │
      ▼
Client APT
      │
      ▼
Vérification + installation
```

---

## Voir aussi

* [Configuration Reprepro](./configs/distributions)
* [Configuration Apache](./configs/25-apt-local.conf)
