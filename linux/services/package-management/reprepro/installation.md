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
