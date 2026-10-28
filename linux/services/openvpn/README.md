# Serveur OpenVPN — Accès distant sécurisé

## 📌 Présentation

**OpenVPN** permet de créer un tunnel chiffré entre un client distant et un réseau privé.

Ce projet documente la mise en place d'un serveur OpenVPN sous Ubuntu avec **Easy-RSA** pour la gestion des certificats.

L'objectif est de comprendre à la fois :

* le fonctionnement d'un tunnel VPN ;
* l'authentification par certificats ;
* le routage vers un réseau interne ;
* la gestion des clients ;
* la révocation des accès ;
* les principaux mécanismes de durcissement.

---

## 🎯 Objectifs

Ce projet permet de travailler sur :

* OpenVPN ;
* Easy-RSA ;
* PKI et certificats X.509 ;
* création d'une autorité de certification ;
* authentification serveur/client ;
* création d'un réseau VPN dédié ;
* routage entre réseaux ;
* IP forwarding ;
* sécurité des accès distants ;
* gestion des certificats ;
* supervision et diagnostic.

---

## 🏗️ Architecture

```text
Client OpenVPN
      │
      │ Tunnel chiffré
      ▼
Serveur OpenVPN
      │
      ├── Réseau VPN : 10.8.0.0/24
      │
      └── Route vers le réseau interne
                  │
                  ▼
          192.168.1.0/24
```

Le client établit un tunnel chiffré avec le serveur.

Une adresse appartenant au réseau VPN lui est attribuée :

```text
10.8.0.0/24
```

Le serveur peut ensuite router les flux autorisés vers le réseau interne :

```text
192.168.1.0/24
```

---

## ⚙️ Fonctionnement

L'architecture repose sur une infrastructure à clés publiques.

```text
Autorité de certification
          │
          ├── Certificat serveur
          │
          ├── Certificat client 1
          │
          ├── Certificat client 2
          │
          └── Certificat client ...
```

L'autorité de certification permet de signer les certificats utilisés par les différentes machines.

Lorsqu'un client se connecte :

```text
Client
  │
  │ Certificat + clé privée
  ▼
Serveur OpenVPN
  │
  │ Vérification du certificat
  ▼
Tunnel VPN
```

Chaque client doit idéalement posséder sa propre identité cryptographique.

---

## 🔑 Gestion des certificats

**Easy-RSA** est utilisé pour gérer la PKI du lab.

Elle permet notamment de :

* créer l'autorité de certification ;
* générer les clés privées ;
* créer les demandes de certificat ;
* signer les certificats serveur et clients ;
* renouveler les certificats ;
* révoquer les certificats compromis ;
* générer une liste de révocation.

La clé privée de l'autorité de certification constitue un élément particulièrement sensible et doit être protégée.

---

## 🌐 Réseau VPN

La configuration serveur utilise :

```text
10.8.0.0/24
```

comme réseau dédié au tunnel.

Le serveur peut également annoncer une route vers le réseau interne :

```text
192.168.1.0/24
```

Exemple :

```text
Client VPN
10.8.0.x
    │
    ▼
Serveur VPN
10.8.0.1
    │
    ▼
192.168.1.0/24
```

Le routage doit être limité aux ressources réellement nécessaires.

---

## 🔀 IP forwarding

Pour permettre au serveur de transférer du trafic entre le tunnel VPN et un autre réseau, le transfert IPv4 doit être activé.

Le paramètre correspondant est :

```text
net.ipv4.ip_forward=1
```

Cela transforme le serveur VPN en point de routage entre les différents réseaux autorisés.

---

## ⚙️ Configuration serveur

Un exemple de configuration est disponible dans :

👉 [`configs/server.conf`](./configs/server.conf)

Elle définit notamment :

* le port UDP `1194` ;
* l'interface virtuelle `tun` ;
* les certificats utilisés ;
* le réseau VPN `10.8.0.0/24` ;
* la route vers `192.168.1.0/24` ;
* le fichier de statut des connexions ;
* la persistance de l'interface et des clés.

Les chemins, réseaux et paramètres cryptographiques doivent être adaptés à l'environnement utilisé.

---

# 🔐 Sécurité et durcissement

## Utiliser un certificat distinct par client

Chaque utilisateur ou machine doit disposer de son propre certificat.

Cela permet :

* d'identifier individuellement les clients ;
* de révoquer un seul accès ;
* de tracer plus facilement les connexions ;
* d'éviter le partage d'une identité commune.

---

## Protéger les clés privées

Les clés privées :

* de la CA ;
* du serveur ;
* des clients ;

doivent être considérées comme des secrets.

Exemple de permissions :

```bash
chmod 600 /etc/openvpn/easy-rsa/pki/private/srv-vpn.key
```

Une clé privée exposée peut permettre à un attaquant d'usurper une identité.

---

## Valider l'identité du serveur

Le profil client utilise notamment :

```text
remote-cert-tls server
```

Cette directive permet de vérifier que le certificat présenté est prévu pour être utilisé par un serveur.

---

## Utiliser des algorithmes modernes

Pour une nouvelle configuration, il est préférable d'utiliser les mécanismes de négociation modernes d'OpenVPN ainsi que des chiffrements AEAD lorsque les versions utilisées le permettent.

Exemples :

```text
AES-256-GCM
AES-128-GCM
CHACHA20-POLY1305
```

La configuration doit rester compatible avec les versions serveur et client réellement déployées.

---

## Restreindre les routes

Un VPN ne doit pas automatiquement fournir un accès à l'ensemble du réseau interne.

Exemple :

```text
push "route 192.168.1.0 255.255.255.0"
```

Seuls les réseaux réellement nécessaires doivent être accessibles.

---

## Filtrer les flux

Dans ce projet, OpenVPN utilise :

```text
UDP 1194
```

Le pare-feu doit contrôler :

```text
Internet / Clients
        │
        ▼
UDP 1194
        │
        ▼
Serveur OpenVPN
        │
        ▼
Réseaux internes autorisés
```

Les flux provenant du tunnel VPN vers les réseaux internes doivent également être filtrés selon les besoins.

---

## Révoquer les certificats compromis

Lorsqu'un client :

* perd son appareil ;
* quitte l'organisation ;
* expose sa clé privée ;
* ne doit plus disposer d'un accès ;

son certificat doit pouvoir être révoqué.

Easy-RSA permet de gérer cette révocation et de générer une **CRL (Certificate Revocation List)**.

Le serveur doit ensuite consulter cette liste afin de refuser les certificats révoqués.

---

## Renforcer le canal TLS

OpenVPN peut utiliser des mécanismes complémentaires tels que :

```text
tls-auth
```

ou :

```text
tls-crypt
```

Ils permettent d'ajouter une couche de protection au canal de contrôle OpenVPN.

---

## 📊 Supervision

Les connexions peuvent être suivies grâce aux journaux et fichiers de statut.

Ils permettent notamment de contrôler :

* les clients connectés ;
* les adresses VPN attribuées ;
* les erreurs d'authentification ;
* les certificats utilisés ;
* les erreurs de routage ou de connexion.

Les principales commandes sont regroupées dans :

👉 [Commandes utiles OpenVPN](./commandes-utiles.md)

---

## 🚀 Installation du serveur

La procédure complète de mise en place du serveur, de la PKI et du routage est disponible ici :

👉 [Installation et configuration du serveur OpenVPN](./installation.md)

---

## 👤 Configuration des clients

Chaque client doit disposer de son propre certificat et de sa propre clé privée.

La procédure est documentée séparément :

👉 [Configuration d'un client OpenVPN](./client.md)

---

## ✅ Validation

Après configuration, plusieurs éléments doivent être vérifiés.

### Service OpenVPN

```bash
systemctl status openvpn@server
```

### Interface VPN

```bash
ip a
```

### Routes

```bash
ip route
```

### IP forwarding

```bash
sysctl net.ipv4.ip_forward
```

### Connexions actives

Selon la configuration :

```bash
cat /var/log/openvpn/openvpn-status.log
```

---

## 📌 Points clés

* OpenVPN permet de créer un tunnel chiffré entre un client et un réseau distant.
* Une PKI permet d'identifier le serveur et les clients.
* Chaque client doit disposer d'un certificat distinct.
* Les clés privées doivent être protégées.
* Les routes VPN doivent être limitées aux ressources nécessaires.
* Le pare-feu doit contrôler les flux entrant dans le VPN et sortant du tunnel.
* Les certificats compromis doivent pouvoir être révoqués.
* Les connexions et dates d'expiration des certificats doivent être surveillées.

---

## 🧠 Compétences mises en pratique

Ce projet permet de travailler sur :

* administration Linux ;
* OpenVPN ;
* Easy-RSA ;
* PKI ;
* certificats X.509 ;
* cryptographie appliquée ;
* routage ;
* IP forwarding ;
* services réseau ;
* pare-feu ;
* contrôle d'accès ;
* supervision ;
* sécurité des accès distants ;
* troubleshooting réseau.
