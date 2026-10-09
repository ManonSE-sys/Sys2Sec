# Dépôt APT local signé avec Reprepro et Apache

## 📌 Présentation

Ce projet documente la mise en place d'un **dépôt APT local** sous Ubuntu à l'aide de **Reprepro**, **GnuPG** et **Apache**.

L'objectif est de centraliser certains paquets `.deb`, de contrôler les versions mises à disposition et de permettre à des clients Ubuntu d'installer ces paquets depuis un dépôt interne signé.

---

## 🎯 Objectifs

Cette mise en place permet de :

- réduire la dépendance aux dépôts externes pour certains paquets ;
- centraliser les paquets utilisés dans l'infrastructure ;
- contrôler les versions disponibles ;
- signer le dépôt avec une clé GPG ;
- publier le dépôt via Apache ;
- configurer les clients APT pour utiliser le dépôt local.

---

## 🏗️ Architecture

```text
Paquet .deb
    │
    ▼
Reprepro
    │
    ├── indexation du paquet
    ├── génération des métadonnées
    └── signature du dépôt
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
    ├── clé publique du dépôt
    └── source APT locale
```

---

## 1. Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Installer les paquets nécessaires

```bash
sudo apt install reprepro gnupg apache2 -y
```

Les composants utilisés sont :

- **Reprepro** pour gérer le dépôt APT ;
- **GnuPG** pour signer le dépôt ;
- **Apache** pour publier le contenu via HTTP.

---

## 3. Générer une clé GPG

Créer une clé qui sera utilisée pour signer le dépôt :

```bash
gpg --full-generate-key
```

Afficher ensuite les clés disponibles :

```bash
gpg --list-keys
```

Repérer l'identifiant ou l'empreinte de la clé qui sera utilisée pour la signature.

> ⚠️ La clé privée doit rester protégée. Seule la clé publique doit être distribuée aux clients.

---

## 4. Créer l'arborescence du dépôt

Créer les répertoires nécessaires :

```bash
sudo mkdir -p /var/www/repos/ubuntu/{conf,incoming}
```

L'arborescence de départ est la suivante :

```text
/var/www/repos/ubuntu/
├── conf/
└── incoming/
```

---

## 5. Configurer Reprepro

Le fichier de distribution doit être créé ici :

```text
/var/www/repos/ubuntu/conf/distributions
```

La configuration utilisée pour ce projet est disponible ici :

👉 [`configs/distributions`](configs/distributions)

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

> Adaptez le `Codename` à la version Ubuntu ciblée.  
> N'ajoutez que les architectures réellement nécessaires.

---

## 6. Ajouter un paquet au dépôt

Copier ou télécharger un paquet `.deb` dans le répertoire `incoming`.

Exemple :

```bash
cd /var/www/repos/ubuntu/incoming
wget https://apt.puppet.com/puppet7-release-noble.deb
```

Ajouter ensuite le paquet au dépôt :

```bash
cd /var/www/repos/ubuntu
sudo reprepro -Vb . includedeb noble incoming/puppet7-release-noble.deb
```

Le nom de distribution (`noble`) et le nom du paquet doivent être adaptés au contexte.

---

## 7. Exporter la clé publique

Afficher les clés :

```bash
gpg --list-keys
```

Exporter ensuite la clé publique en ASCII :

```bash
gpg --armor --export ID_CLE > /var/www/repos/ubuntu/repo-signing-key.asc
```

Cette clé sera récupérée par les clients afin de vérifier les signatures du dépôt.

> Le fichier exporté ne contient que la clé publique.

---

## 8. Configurer Apache

Créer le virtual host :

```text
/etc/apache2/sites-available/25-apt-local.conf
```

La configuration utilisée pour ce projet est disponible ici :

👉 [`configs/25-apt-local.conf`](configs/25-apt-local.conf)

Activer ensuite le site :

```bash
sudo a2dissite 000-default.conf
sudo a2ensite 25-apt-local.conf
sudo systemctl reload apache2
```

Vérifier la configuration Apache avant le rechargement peut également être utile :

```bash
sudo apache2ctl configtest
```

---

## 9. Configurer un client Ubuntu

### Importer la clé publique

Sur le client :

```bash
wget -O- http://adresse_ip_ou_nom_dns/ubuntu/repo-signing-key.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/srv-apt.gpg
```

---

### Ajouter le dépôt APT

Créer un fichier, par exemple :

```text
/etc/apt/sources.list.d/srv-apt.list
```

avec le contenu suivant :

```text
deb [signed-by=/usr/share/keyrings/srv-apt.gpg] http://adresse_ip_ou_nom_dns/ubuntu noble main
```

Puis mettre à jour la liste des paquets :

```bash
sudo apt update
```

---

## 10. Tester le dépôt

Installer un paquet présent dans le dépôt :

```bash
sudo apt install puppet7-release
```

Si le paquet est trouvé et installé depuis le dépôt local, la publication et la configuration APT fonctionnent correctement.

---

## 🔎 Diagnostic

### Vérifier Apache

```bash
systemctl status apache2
```

### Vérifier la configuration Apache

```bash
apache2ctl configtest
```

### Consulter les journaux

```bash
tail -f /var/log/apache2/srv-apt_error.log
```

```bash
tail -f /var/log/apache2/srv-apt_access.log
```

### Vérifier le contenu du dépôt

```bash
reprepro -b /var/www/repos/ubuntu list noble
```

---

## 🔐 Points d'attention

Quelques précautions sont importantes :

- protéger la clé privée utilisée pour signer le dépôt ;
- distribuer uniquement la clé publique aux clients ;
- limiter les paquets ajoutés au dépôt ;
- contrôler les versions publiées ;
- adapter le codename Ubuntu au système client ;
- tester les mises à jour avant leur déploiement à grande échelle ;
- utiliser HTTPS lorsque le contexte l'exige, même si APT vérifie également les signatures du dépôt.

---

## 📌 Points clés

- **Centralisation :** les paquets sont regroupés dans un dépôt interne.
- **Contrôle :** les versions mises à disposition sont maîtrisées.
- **Signature :** les métadonnées du dépôt sont signées avec GPG.
- **Distribution :** Apache permet aux clients d'accéder au dépôt.
- **Intégration :** les clients utilisent le dépôt via une source APT dédiée.
