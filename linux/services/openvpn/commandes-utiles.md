# Commandes utiles — OpenVPN

Cette fiche regroupe quelques commandes utiles pour administrer et superviser un serveur OpenVPN.

---

## 🔎 Vérifier les connexions

Dans la configuration documentée, l'association entre les clients et les adresses VPN est enregistrée dans :

```bash
cat /var/log/openvpn/ipp.txt
```

Selon la configuration, les clients actifs peuvent également être suivis dans le fichier de statut :

```bash
cat /var/log/openvpn/openvpn-status.log
```

Pour suivre ce fichier en temps réel :

```bash
tail -f /var/log/openvpn/openvpn-status.log
```

---

## 🖥️ Vérifier le service

Exemple pour une instance nommée `server` :

```bash
systemctl status openvpn@server
```

Le nom exact de l'unité peut varier selon la version du paquet et l'emplacement du fichier de configuration.

---

## 📄 Consulter les journaux

```bash
journalctl -u openvpn@server
```

Pour suivre les événements en temps réel :

```bash
journalctl -u openvpn@server -f
```

---

## 📦 Vérifier la version

```bash
openvpn --version
```

Cette information est importante pour vérifier la compatibilité des paramètres de configuration et des algorithmes cryptographiques utilisés.

---

## 📜 Vérifier l'expiration d'un certificat

Exemple pour le certificat serveur :

```bash
openssl x509 -enddate -noout \
  -in /etc/openvpn/easy-rsa/pki/issued/server.crt
```

Pour afficher davantage d'informations :

```bash
openssl x509 -in /etc/openvpn/easy-rsa/pki/issued/server.crt \
  -noout -subject -issuer -dates
```

Adapter le chemin au certificat réellement utilisé.

---

## 🔄 Renouveler un certificat

Depuis l'environnement Easy-RSA :

```bash
./easyrsa renew server
```

La commande exacte dépend du nom du certificat et de la version d'Easy-RSA utilisée.

Après renouvellement, vérifier que le nouveau certificat est correctement déployé puis redémarrer ou recharger le service si nécessaire.

---

## 🚫 Révoquer un certificat

Pour un client compromis ou qui ne doit plus avoir accès au VPN, utiliser la procédure de révocation Easy-RSA correspondant à l'environnement.

Exemple de principe :

```bash
./easyrsa revoke client1
```

Puis régénérer la liste de révocation :

```bash
./easyrsa gen-crl
```

Le serveur doit être configuré pour consulter la CRL afin que les certificats révoqués soient effectivement refusés.

---

## 🌐 Vérifier l'interface et les routes

Afficher les interfaces :

```bash
ip a
```

Afficher les routes :

```bash
ip route
```

Ces commandes permettent notamment de vérifier :

- la présence de l'interface VPN ;
- le réseau attribué au tunnel ;
- les routes vers les réseaux distants.

---

## 🧭 Diagnostic rapide

En cas de problème :

```text
1. Le service OpenVPN fonctionne-t-il ?
2. Le port VPN est-il accessible ?
3. Le certificat client est-il valide ?
4. Le certificat a-t-il été révoqué ?
5. Les routes attendues sont-elles présentes ?
6. L'IP forwarding est-il actif ?
7. Le pare-feu autorise-t-il les flux nécessaires ?
8. Les journaux indiquent-ils une erreur ?
```

Commandes utiles :

```bash
openvpn --version
systemctl status openvpn@server
journalctl -u openvpn@server
ip a
ip route
```
