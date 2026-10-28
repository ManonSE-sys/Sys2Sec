# Installation et configuration d'apt-cacher-ng

## 📌 Objectif

Cette fiche décrit la mise en place d'un serveur `apt-cacher-ng` et la configuration d'un client Ubuntu ou Debian.

---

## 1. Mettre à jour l'index APT

```bash
sudo apt update
```

---

## 2. Installer apt-cacher-ng

```bash
sudo apt install apt-cacher-ng -y
```

---

## 3. Vérifier le service

```bash
systemctl status apt-cacher-ng
```

---

## 4. Vérifier le port

```bash
ss -lntp | grep ':3142'
```

---

## 5. Configurer le serveur

Le fichier principal est :

```text
/etc/apt-cacher-ng/acng.conf
```

L'éditer avec :

```bash
sudo vi /etc/apt-cacher-ng/acng.conf
```

Les paramètres peuvent être adaptés selon le lab :

```text
CacheDir
LogDir
Port
BindAddress
Proxy
Remap-*
```

---

## 6. Redémarrer le service

```bash
sudo systemctl restart apt-cacher-ng
```

Puis :

```bash
systemctl status apt-cacher-ng
```

---

# Configuration cliente

## 7. Créer la configuration APT

Sur le client :

```text
/etc/apt/apt.conf.d/02-aptcacher
```

Ajouter :

```text
Acquire::http::Proxy "http://ADRESSE_SERVEUR:3142";
```

Exemple :

```text
Acquire::http::Proxy "http://192.168.1.10:3142";
```

---

## 8. Tester la connexion

Sur le client :

```bash
sudo apt update
```

Puis télécharger ou installer un paquet.

Par exemple :

```bash
sudo apt install <paquet>
```

---

## 9. Vérifier le cache

Sur le serveur :

```bash
du -sh /var/cache/apt-cacher-ng
```

Il est également possible d'observer son contenu :

```bash
find /var/cache/apt-cacher-ng -type f | head
```

---

## 10. Tester avec plusieurs clients

Le test le plus intéressant consiste à :

```text
Client 1
   │
   └── télécharge un paquet
             ↓
       mise en cache

Client 2
   │
   └── demande le même paquet
             ↓
       réutilisation du cache
```

Cela permet de montrer concrètement l'intérêt du service.

---

## 11. Consulter les journaux

```bash
ls -l /var/log/apt-cacher-ng
```

Puis examiner les fichiers adaptés à l'installation.

---

## ✅ Résultat attendu

```text
Clients APT
    │
    ▼
apt-cacher-ng :3142
    │
    ├── Cache HIT → réponse locale
    │
    └── Cache MISS
             │
             ▼
         Internet
             │
             ▼
          Cache
```
