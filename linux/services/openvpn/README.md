# Serveur OpenVPN — Accès distant sécurisé

## 📌 Présentation

**OpenVPN** permet de créer un tunnel chiffré entre un client distant et un réseau privé.

Ce projet documente la mise en place d'un serveur OpenVPN sous Ubuntu avec **Easy-RSA** pour la gestion des certificats, ainsi que les principaux points de sécurité associés.

L'objectif n'est pas seulement de mettre en place le tunnel VPN, mais également de comprendre les mécanismes de sécurité qui permettent de contrôler et protéger les accès distants.

---

## 🎯 Objectifs

Cette mise en place permet de :

- installer un serveur OpenVPN ;
- créer une autorité de certification avec Easy-RSA ;
- générer et signer le certificat du serveur ;
- attribuer un certificat distinct aux clients ;
- créer un réseau VPN dédié ;
- pousser une route vers un réseau interne ;
- activer le transfert IPv4 ;
- superviser les connexions et certificats ;
- appliquer plusieurs principes de durcissement.

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

---

## 1. Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Installer OpenVPN et Easy-RSA

```bash
sudo apt install openvpn easy-rsa -y
```

Easy-RSA est utilisé pour créer l'autorité de certification et gérer les certificats du serveur et des clients.

---

## 3. Créer l'autorité de certification

Depuis l'environnement Easy-RSA :

```bash
./easyrsa build-ca
```

Lors de cette étape, définir notamment :

- un mot de passe pour protéger la CA ;
- un nom commun adapté à l'environnement.

> 🔐 La clé privée de l'autorité de certification est particulièrement sensible. Elle doit être protégée et ne doit pas être distribuée aux clients.

---

## 4. Générer le certificat du serveur

Créer la paire de clés et la demande de certificat :

```bash
./easyrsa gen-req nom_serveur nopass
```

Puis signer la demande avec la CA :

```bash
./easyrsa sign-req server nom_serveur
```

> ⚠️ L'option `nopass` simplifie le démarrage automatique du service, mais supprime la protection par mot de passe de la clé privée. Ce choix doit être évalué selon le contexte et les mesures de protection du serveur.

---

## 5. Générer les paramètres nécessaires

Dans la configuration documentée initialement, les paramètres Diffie-Hellman sont générés avec :

```bash
./easyrsa gen-dh
```

---

## 6. Configurer le serveur OpenVPN

Le fichier de configuration utilisé comme base est disponible ici :

👉 [`configs/server.conf`](configs/server.conf)

Il configure notamment :

- le port UDP `1194` ;
- une interface virtuelle `tun` ;
- les certificats du serveur ;
- le réseau VPN `10.8.0.0/24` ;
- une route vers `192.168.1.0/24` ;
- la journalisation de l'état des connexions ;
- la conservation de l'interface et des clés lors d'un redémarrage du service.

> Les chemins de certificats, adresses IP, routes et paramètres cryptographiques doivent être adaptés à l'environnement réellement utilisé.

---

## 7. Activer le transfert IPv4

Pour permettre au serveur VPN de router le trafic entre le tunnel et d'autres réseaux, activer l'IP forwarding.

Dans `/etc/sysctl.conf` :

```text
net.ipv4.ip_forward=1
```

Puis appliquer la configuration :

```bash
sudo sysctl -p
```

---

## 8. Démarrer le service

Le nom exact de l'unité systemd dépend du paquet OpenVPN et de la disposition des fichiers de configuration.

Dans l'environnement documenté initialement, le service était démarré avec :

```bash
sudo systemctl enable openvpn@server
sudo systemctl start openvpn@server
```

Vérifier ensuite son état :

```bash
systemctl status openvpn@server
```

---

## 9. Configurer les clients

Chaque client doit disposer de son propre certificat et de sa propre clé privée.

La procédure de génération, de configuration et de connexion est détaillée ici :

👉 [Voir la configuration client](./client.md)

---

## 🔐 Sécurité et durcissement

### Utiliser un certificat distinct par client

Chaque utilisateur ou machine doit disposer de son propre certificat.

Cela permet :

- d'identifier précisément les clients ;
- de révoquer un seul certificat en cas de compromission ;
- d'éviter le partage d'identités entre plusieurs utilisateurs.

---

### Protéger les clés privées

Les clés privées de la CA, du serveur et des clients ne doivent jamais être exposées publiquement.

Les fichiers sensibles doivent être protégés par des permissions adaptées.

Exemple :

```bash
chmod 600 /etc/openvpn/easy-rsa/pki/private/srv-vpn.key
```

---

### Valider l'identité du serveur côté client

Le profil client utilise :

```text
remote-cert-tls server
```

Cette directive permet au client de vérifier que le certificat présenté correspond bien à un certificat destiné à un serveur.

---

### Utiliser des algorithmes modernes

La configuration d'origine mentionnait notamment `AES-256-CBC`.

Pour une nouvelle configuration, il est préférable d'utiliser les mécanismes de négociation modernes d'OpenVPN et des chiffrements AEAD lorsque les versions serveur/client le permettent, par exemple :

```text
AES-256-GCM
AES-128-GCM
CHACHA20-POLY1305
```

La configuration retenue doit rester compatible avec les versions déployées.

---

### Restreindre les routes

Un VPN ne doit donner accès qu'aux réseaux nécessaires.

Exemple :

```text
push "route 192.168.1.0 255.255.255.0"
```

Il est préférable d'éviter d'exposer inutilement d'autres réseaux internes aux clients VPN.

---

### Filtrer l'accès réseau

Le port OpenVPN ne doit être exposé que lorsque nécessaire.

Dans cet exemple :

```text
UDP 1194
```

Le pare-feu doit également contrôler les flux autorisés entre :

```text
Clients VPN
    │
    ▼
Serveur OpenVPN
    │
    ▼
Réseaux internes autorisés
```

---

### Révoquer les certificats compromis

En cas de perte ou de compromission d'un certificat client, celui-ci doit pouvoir être révoqué.

La gestion de la révocation via Easy-RSA et l'utilisation d'une CRL permettent d'empêcher un ancien certificat de continuer à se connecter.

---

### Renforcer la protection du canal TLS

OpenVPN peut également utiliser des mécanismes comme `tls-auth` ou `tls-crypt` pour ajouter une protection supplémentaire au canal de contrôle.

Le choix dépend de la version d'OpenVPN et de l'architecture retenue.

---

### Surveiller les connexions

Les journaux et fichiers de statut permettent de suivre :

- les clients connectés ;
- les adresses attribuées ;
- les erreurs d'authentification ;
- les certificats utilisés ;
- les anomalies de fonctionnement.

Les principales commandes sont regroupées ici :

👉 [Voir les commandes utiles OpenVPN](./commandes-utiles.md)

---

## 📌 Points clés

- **Chiffrement :** le tunnel protège les échanges entre les clients et le serveur VPN.
- **Authentification :** les certificats permettent d'identifier les différents clients.
- **Segmentation :** les routes doivent être limitées aux ressources réellement nécessaires.
- **Révocation :** un certificat compromis doit pouvoir être désactivé.
- **Supervision :** les connexions et certificats doivent être surveillés dans le temps.
