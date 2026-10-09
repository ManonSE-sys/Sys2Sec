# Configuration d'un client OpenVPN

## 📌 Présentation

Cette fiche documente la création d'un profil client OpenVPN permettant de se connecter au serveur VPN.

Chaque client utilise idéalement :

- un certificat propre ;
- une clé privée propre ;
- le certificat de l'autorité de certification ;
- un fichier de configuration `.ovpn`.

---

## 1. Générer le certificat du client

Sur le serveur hébergeant Easy-RSA, générer une demande de certificat :

```bash
./easyrsa gen-req client1 nopass
```

Puis signer cette demande :

```bash
./easyrsa sign-req client client1
```

> ⚠️ Un certificat distinct doit être utilisé pour chaque client afin de faciliter l'identification et la révocation.

> L'utilisation de `nopass` simplifie la connexion mais laisse la clé privée sans mot de passe. Ce choix doit être adapté au niveau de sécurité recherché.

---

## 2. Créer le fichier client.ovpn

Un exemple de profil est disponible ici :

👉 [`configs/client.ovpn.example`](configs/client.ovpn.example)

Le profil contient notamment :

```text
client
dev tun
proto udp
remote ADRESSE_DU_SERVEUR 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
verb 3
```

Les éléments cryptographiques peuvent être intégrés directement au fichier `.ovpn` :

```text
<ca>
...
</ca>

<cert>
...
</cert>

<key>
...
</key>
```

> 🔐 Le bloc `<key>` contient la clé privée du client. Le fichier `.ovpn` doit donc être protégé comme un secret.

---

## 3. Installer OpenVPN sur Ubuntu

Mettre à jour le système :

```bash
sudo apt update && sudo apt upgrade -y
```

Installer le client OpenVPN :

```bash
sudo apt install openvpn -y
```

Easy-RSA n'est nécessaire sur le client que si la gestion des certificats y est réellement effectuée.

---

## 4. Transférer le profil client

Le profil doit être transmis au client par un canal sécurisé.

Dans l'environnement initialement documenté, un transfert SCP était utilisé :

```bash
scp /etc/openvpn/client/client.ovpn client:/tmp/
```

Puis le fichier était déplacé sur le client.

Exemple :

```bash
sudo cp /tmp/client.ovpn /etc/openvpn/client.ovpn
```

---

## 5. Se connecter depuis Ubuntu

Lancer le client :

```bash
sudo openvpn --config /etc/openvpn/client.ovpn
```

Vérifier ensuite :

- l'apparition de l'interface VPN ;
- l'adresse attribuée ;
- l'accès au réseau distant ;
- les routes ajoutées.

Exemples :

```bash
ip a
ip route
```

---

## 6. Client Windows

Sous Windows :

1. installer le client OpenVPN adapté ;
2. importer le fichier `.ovpn` ;
3. lancer la connexion ;
4. vérifier l'accès aux ressources autorisées.

Le même principe de sécurité s'applique : la clé privée intégrée dans le fichier `.ovpn` doit être protégée.

---

## 🔐 Points d'attention

- utiliser un certificat différent pour chaque client ;
- protéger le fichier `.ovpn` ;
- ne jamais partager une clé privée entre plusieurs utilisateurs ;
- vérifier l'identité du serveur avec `remote-cert-tls server` ;
- révoquer rapidement un certificat perdu ou compromis ;
- limiter les routes et ressources accessibles au strict nécessaire.
