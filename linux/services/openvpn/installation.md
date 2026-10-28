# Installation et configuration d'un serveur OpenVPN

## 📌 Objectif

Cette fiche décrit la mise en place d'un serveur OpenVPN sous Ubuntu avec **Easy-RSA** pour la gestion des certificats.

Architecture du lab :

```text
Client OpenVPN
      │
      │ Tunnel chiffré
      ▼
Serveur OpenVPN
      │
      ├── 10.8.0.0/24
      │
      └── Route
            │
            ▼
      192.168.1.0/24
```

---

# Installation

## 1. Mettre à jour l'index des paquets

```bash
sudo apt update
```

---

## 2. Installer OpenVPN et Easy-RSA

```bash
sudo apt install openvpn easy-rsa -y
```

OpenVPN fournit le service VPN.

Easy-RSA permet de gérer :

* l'autorité de certification ;
* les clés privées ;
* les demandes de certificat ;
* les certificats serveur et clients ;
* la révocation.

---

# PKI

## 3. Initialiser l'environnement Easy-RSA

La localisation exacte de l'environnement Easy-RSA dépend de l'installation utilisée.

Une fois dans l'environnement de travail Easy-RSA, initialiser la PKI si nécessaire :

```bash
./easyrsa init-pki
```

---

## 4. Créer l'autorité de certification

```bash
./easyrsa build-ca
```

Lors de cette étape, définir notamment :

* un nom commun adapté ;
* une protection de la clé privée de la CA selon le niveau de sécurité recherché.

> 🔐 La clé privée de la CA doit être particulièrement protégée. Elle permet de signer les certificats de l'infrastructure.

---

# Certificat serveur

## 5. Générer la clé et la demande de certificat

Exemple :

```bash
./easyrsa gen-req srv-vpn nopass
```

Cette commande génère notamment :

```text
pki/private/srv-vpn.key
pki/reqs/srv-vpn.req
```

> ⚠️ `nopass` permet au service de démarrer sans demander de mot de passe pour déverrouiller la clé privée. Cela signifie également que la clé n'est pas protégée par une passphrase.

---

## 6. Signer le certificat serveur

```bash
./easyrsa sign-req server srv-vpn
```

Le certificat signé est généré dans l'arborescence PKI.

---

## 7. Générer les paramètres Diffie-Hellman

Dans la configuration utilisée pour ce lab :

```bash
./easyrsa gen-dh
```

Le fichier généré peut ensuite être référencé par la configuration serveur.

> La nécessité de paramètres DH dépend de la configuration et des mécanismes cryptographiques réellement utilisés.

---

# Configuration OpenVPN

## 8. Préparer la configuration serveur

Un exemple est fourni ici :

👉 [`configs/server.conf`](./configs/server.conf)

La configuration utilise notamment :

```text
port 1194
proto udp
dev tun
```

ainsi que :

```text
server 10.8.0.0 255.255.255.0
```

et une route vers :

```text
192.168.1.0/24
```

---

## 9. Vérifier les chemins des certificats

La configuration du lab référence notamment :

```text
ca   /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/srv-vpn.crt
key  /etc/openvpn/easy-rsa/pki/private/srv-vpn.key
dh   /etc/openvpn/easy-rsa/pki/dh.pem
```

Ces chemins doivent correspondre à l'emplacement réel des fichiers.

---

## 10. Protéger la clé privée du serveur

Exemple :

```bash
sudo chmod 600 /etc/openvpn/easy-rsa/pki/private/srv-vpn.key
```

Vérifier :

```bash
ls -l /etc/openvpn/easy-rsa/pki/private/srv-vpn.key
```

---

# Routage

## 11. Activer l'IP forwarding

Le serveur doit pouvoir transférer les paquets entre le tunnel VPN et les réseaux autorisés.

Dans :

```text
/etc/sysctl.conf
```

ajouter ou activer :

```text
net.ipv4.ip_forward=1
```

Appliquer :

```bash
sudo sysctl -p
```

Vérifier :

```bash
sysctl net.ipv4.ip_forward
```

Résultat attendu :

```text
net.ipv4.ip_forward = 1
```

---

## 12. Configurer le pare-feu

Le serveur doit autoriser le port utilisé par OpenVPN.

Dans ce lab :

```text
UDP 1194
```

Le pare-feu doit également autoriser les flux nécessaires entre :

```text
10.8.0.0/24
```

et les réseaux internes auxquels les clients doivent accéder.

La politique exacte dépend de l'architecture réseau utilisée.

---

# Démarrage du service

## 13. Activer OpenVPN

Dans l'environnement initialement documenté, l'instance serveur était démarrée avec :

```bash
sudo systemctl enable openvpn@server
sudo systemctl start openvpn@server
```

Le nom exact de l'unité systemd peut dépendre :

* de la version d'OpenVPN ;
* du paquet utilisé ;
* de l'emplacement du fichier de configuration.

---

## 14. Vérifier le service

```bash
systemctl status openvpn@server
```

Consulter les journaux si nécessaire :

```bash
journalctl -u openvpn@server
```

---

# Validation

## 15. Vérifier l'interface VPN

```bash
ip a
```

Une interface virtuelle de type `tun` doit apparaître lorsque le service fonctionne correctement.

---

## 16. Vérifier les routes

```bash
ip route
```

Contrôler notamment :

* le réseau VPN ;
* les routes vers les réseaux internes ;
* la route utilisée pour joindre les clients.

---

## 17. Vérifier le port

```bash
ss -lunp | grep 1194
```

Le service doit apparaître en écoute sur le port UDP configuré.

---

# Configuration des clients

Chaque client doit disposer :

```text
Certificat CA
+
Certificat client
+
Clé privée client
+
Configuration OpenVPN
```

La création et l'utilisation du profil client sont documentées séparément :

👉 [Configuration d'un client OpenVPN](./client.md)

---

# Test de connexion

Après avoir configuré un client, vérifier :

```bash
ip a
ip route
```

Puis tester l'accès aux seules ressources internes qui doivent être accessibles via le VPN.

Selon l'environnement :

```bash
ping <IP_INTERNE>
```

ou tester directement le service cible.

---

# Supervision

Le fichier de statut défini dans la configuration peut être consulté avec :

```bash
cat /var/log/openvpn/openvpn-status.log
```

Les associations entre clients et adresses peuvent également être enregistrées dans :

```bash
cat /var/log/openvpn/ipp.txt
```

---

# Résultat attendu

```text
OpenVPN
   │
   ├── service actif
   ├── UDP 1194 en écoute
   ├── interface tun disponible
   ├── réseau VPN 10.8.0.0/24
   ├── IP forwarding actif
   │
   └── PKI
       ├── CA
       ├── certificat serveur
       └── certificats clients
```

Un client correctement configuré doit pouvoir :

```text
S'authentifier
      ↓
Créer le tunnel
      ↓
Recevoir une adresse VPN
      ↓
Accéder uniquement aux réseaux autorisés
```

---

## 🔐 Points d'attention

* protéger la clé privée de la CA ;
* protéger la clé privée du serveur ;
* utiliser un certificat distinct par client ;
* protéger les fichiers `.ovpn` contenant une clé privée ;
* limiter les routes annoncées ;
* limiter les flux au niveau du pare-feu ;
* prévoir la révocation des certificats ;
* surveiller leur expiration ;
* adapter les algorithmes cryptographiques aux versions OpenVPN utilisées.

---

## Voir aussi

* [README principal](./README.md)
* [Configuration client](./client.md)
* [Commandes utiles OpenVPN](./commandes-utiles.md)
* [Configuration serveur](./configs/server.conf)
