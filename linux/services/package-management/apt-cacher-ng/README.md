# Cache APT avec apt-cacher-ng

## 📌 Présentation

**apt-cacher-ng** est un proxy de cache destiné notamment aux téléchargements de paquets.

Lorsqu'un paquet est demandé pour la première fois, le serveur le récupère depuis le dépôt distant et le conserve localement.

Une demande ultérieure du même contenu peut alors être servie depuis le cache.

Cette solution est particulièrement intéressante sur un réseau contenant plusieurs machines Debian ou Ubuntu.

---

## 🎯 Objectifs

Ce projet permet de travailler sur :

* la mise en cache de paquets APT ;
* l'utilisation d'un proxy ;
* la réduction des téléchargements redondants ;
* la centralisation des flux APT ;
* la configuration client/serveur ;
* la journalisation ;
* le diagnostic d'un service réseau.

---

## 🏗️ Architecture

```text
Clients Ubuntu / Debian
          │
          │ HTTP
          ▼
    apt-cacher-ng
       TCP 3142
          │
          ├── Cache HIT
          │      └── réponse locale
          │
          └── Cache MISS
                 │
                 ▼
           Dépôt distant
                 │
                 ▼
            Mise en cache
```

---

## 🔄 Principe du cache

### Première demande

```text
Client
   │
   ▼
apt-cacher-ng
   │
   ├── absent du cache
   │
   ▼
Dépôt distant
   │
   ▼
Téléchargement
   │
   ├── réponse au client
   └── stockage local
```

### Demande suivante

```text
Client
   │
   ▼
apt-cacher-ng
   │
   ├── présent dans le cache
   │
   ▼
Réponse locale
```

Cela permet de réduire les téléchargements répétés depuis Internet.

---

## 📂 Cache

Le cache est généralement stocké dans :

```text
/var/cache/apt-cacher-ng
```

Le paramètre associé est :

```text
CacheDir: /var/cache/apt-cacher-ng
```

---

## 📄 Journaux

Les journaux sont stockés dans :

```text
/var/log/apt-cacher-ng
```

Le paramètre correspondant est :

```text
LogDir: /var/log/apt-cacher-ng
```

Ils permettent notamment d'analyser :

* les requêtes ;
* l'utilisation du cache ;
* les erreurs de téléchargement ;
* les clients utilisant le service.

---

## 🌐 Port réseau

Le port utilisé par défaut est :

```text
3142/TCP
```

Un client utilise donc une adresse de type :

```text
http://192.168.1.10:3142
```

---

## ⚙️ Configuration

Le fichier principal est :

```text
/etc/apt-cacher-ng/acng.conf
```

---

### CacheDir

```text
CacheDir: /var/cache/apt-cacher-ng
```

Définit l'emplacement du cache.

---

### LogDir

```text
LogDir: /var/log/apt-cacher-ng
```

Définit l'emplacement des journaux.

---

### Port

Le service utilise normalement :

```text
3142
```

---

### BindAddress

`BindAddress` permet de contrôler les interfaces réseau sur lesquelles le service écoute.

Cela peut notamment permettre d'éviter d'exposer le proxy sur une interface non nécessaire.

---

### Proxy

Si le serveur doit lui-même utiliser un proxy pour accéder à Internet :

```text
Proxy: http://proxy.example.net:3128
```

---

### Backends et remapping

apt-cacher-ng permet également d'utiliser des définitions de dépôts et de miroirs.

Exemple :

```text
Remap-uburep: file:ubuntu_mirrors /ubuntu ; file:backends_ubuntu
```

Ces mécanismes permettent de contrôler la manière dont les requêtes sont associées aux dépôts distants.

---

## 💻 Configuration des clients

Les clients APT peuvent être configurés pour utiliser le proxy.

Principe :

```text
APT
 │
 ▼
Proxy :3142
 │
 ▼
Dépôt distant / cache
```

La procédure complète est disponible dans :

👉 [Installation et configuration](./installation.md)

---

## 🔐 Sécurité

### Limiter l'accès réseau

Le port :

```text
3142/TCP
```

ne doit pas être inutilement exposé à Internet.

L'accès peut être limité :

* au réseau interne ;
* aux VLAN nécessaires ;
* aux machines autorisées.

---

### Limiter les interfaces

Lorsque cela est pertinent, `BindAddress` permet d'éviter une écoute sur toutes les interfaces du serveur.

---

### Protéger le cache et les journaux

Les répertoires de cache et de logs ne doivent être modifiables que par les comptes réellement nécessaires.

---

### Maîtriser les dépôts utilisés

Le cache ne remplace pas les mécanismes de confiance d'APT.

Les clients continuent à utiliser les mécanismes de validation des dépôts et des métadonnées APT.

---

## ✅ Validation

Vérifier le service :

```bash
systemctl status apt-cacher-ng
```

Vérifier l'écoute :

```bash
ss -lntp | grep ':3142'
```

Observer le cache :

```bash
du -sh /var/cache/apt-cacher-ng
```

Consulter les journaux :

```bash
ls -l /var/log/apt-cacher-ng
```

Puis effectuer des opérations APT depuis plusieurs clients afin d'observer la réutilisation du contenu mis en cache.

---

## 📌 Points clés

* apt-cacher-ng agit comme un proxy de cache.
* Les paquets déjà récupérés peuvent être réutilisés par plusieurs machines.
* Le cache réduit les téléchargements redondants.
* Le port par défaut est `3142/TCP`.
* Les clients utilisent le proxy de manière transparente pour leurs opérations APT.
* L'accès au cache doit être limité aux réseaux nécessaires.
* Les mécanismes de vérification APT restent importants.

---

## 🧠 Compétences mises en pratique

* administration Linux ;
* APT ;
* proxy ;
* cache ;
* services réseau ;
* gestion de paquets ;
* optimisation de bande passante ;
* journalisation ;
* sécurité réseau ;
* troubleshooting.
