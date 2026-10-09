# Cache APT avec apt-cacher-ng

## 📌 Présentation

**apt-cacher-ng** permet de mettre en cache les paquets téléchargés par les clients APT.

Lorsqu'un paquet est demandé pour la première fois, le serveur le récupère depuis le dépôt distant et le conserve localement. Les clients suivants peuvent ensuite récupérer ce même paquet depuis le cache plutôt que de le télécharger à nouveau depuis Internet.

Cette solution est particulièrement intéressante lorsqu'un réseau contient plusieurs machines Ubuntu ou Debian utilisant les mêmes dépôts.

---

## 🎯 Objectifs

La mise en place d'un cache APT permet notamment de :

- réduire la consommation de bande passante ;
- accélérer les installations et les mises à jour ;
- éviter le téléchargement répété des mêmes paquets ;
- centraliser les téléchargements APT de plusieurs machines.

---

## 🏗️ Fonctionnement général

```text
Client Ubuntu
      │
      │ Requête APT
      ▼
apt-cacher-ng
      │
      ├── Paquet déjà présent
      │       │
      │       └──► réponse depuis le cache
      │
      └── Paquet absent
              │
              ▼
        Dépôt distant
              │
              ▼
        Mise en cache
              │
              ▼
           Client
```

Le répertoire utilisé par défaut pour stocker les paquets en cache est :

```text
/var/cache/apt-cacher-ng
```

---

## 1. Mettre à jour le système

Avant l'installation :

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Installer apt-cacher-ng

Installer le paquet :

```bash
sudo apt install apt-cacher-ng -y
```

---

## 3. Configurer apt-cacher-ng

Le fichier principal de configuration est situé ici :

```text
/etc/apt-cacher-ng/acng.conf
```

Il peut être édité avec :

```bash
sudo vi /etc/apt-cacher-ng/acng.conf
```

---

## ⚙️ Principaux paramètres

Le fichier `acng.conf` permet de définir différents paramètres de fonctionnement.

### CacheDir

```text
CacheDir: /var/cache/apt-cacher-ng
```

Définit le répertoire dans lequel les paquets téléchargés sont mis en cache.

---

### LogDir

```text
LogDir: /var/log/apt-cacher-ng
```

Définit le répertoire contenant les journaux du service.

---

### Port

Le port utilisé par défaut est :

```text
3142
```

Les clients APT doivent donc utiliser l'adresse du serveur accompagnée de ce port.

Exemple :

```text
http://192.168.1.10:3142
```

---

### BindAddress

Le paramètre `BindAddress` permet de déterminer les interfaces réseau sur lesquelles le service écoute.

Il peut être adapté lorsque l'on souhaite limiter l'accès au cache à certaines interfaces.

---

### Proxy

Lorsque le serveur doit lui-même passer par un proxy pour accéder à Internet, celui-ci peut être renseigné dans la configuration.

Exemple :

```text
Proxy: http://www-proxy.example.net:3128
```

---

### Backends

Les backends permettent de définir les différentes sources ou miroirs utilisés pour récupérer les paquets.

Ils peuvent notamment être utilisés avec des règles de type :

```text
Remap-uburep: file:ubuntu_mirrors /ubuntu ; file:backends_ubuntu
```

---

### ReportPage

Le paramètre `ReportPage` permet de définir l'accès à la page de rapport fournie par apt-cacher-ng.

Cette interface permet d'obtenir des informations sur le fonctionnement et l'utilisation du cache.

---

## 4. Redémarrer le service

Après modification de la configuration :

```bash
sudo systemctl restart apt-cacher-ng
```

---

## 5. Configurer un client Ubuntu

Sur chaque client utilisant le cache, créer le fichier :

```text
/etc/apt/apt.conf.d/02-aptcacher
```

Ajouter ensuite :

```text
Acquire::http::Proxy "http://ADRESSE_IP_SERVEUR:3142";
```

Par exemple :

```text
Acquire::http::Proxy "http://192.168.1.10:3142";
```

L'adresse doit correspondre à celle du serveur hébergeant `apt-cacher-ng`.

---

## 6. Tester le cache

Sur le client, mettre à jour la liste des paquets :

```bash
sudo apt update
```

Puis installer ou mettre à jour des paquets.

Exemple :

```bash
sudo apt upgrade
```

Sur le serveur, vérifier ensuite que de nouveaux fichiers apparaissent dans :

```text
/var/cache/apt-cacher-ng
```

La présence des paquets téléchargés dans ce répertoire permet de confirmer qu'ils sont bien mis en cache.

---

## 🔄 Principe du cache

Lors du premier téléchargement :

```text
Client
   │
   ▼
apt-cacher-ng
   │
   ▼
Internet
   │
   ▼
Paquet téléchargé et stocké dans le cache
```

Lors d'une demande ultérieure du même paquet :

```text
Client
   │
   ▼
apt-cacher-ng
   │
   ▼
Paquet déjà présent dans le cache
```

Le paquet peut alors être fourni localement sans devoir être téléchargé une nouvelle fois depuis le dépôt distant.

---

## 📌 Points clés

- **Économie de bande passante :** les paquets déjà téléchargés peuvent être réutilisés par plusieurs clients.
- **Performance :** les paquets présents dans le cache peuvent être récupérés depuis le réseau local.
- **Centralisation :** plusieurs machines utilisent le même serveur de cache APT.
- **Simplicité :** une fois les clients configurés, l'utilisation du cache est transparente lors des opérations APT.
