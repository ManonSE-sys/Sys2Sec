# Installation d'un Serveur NTP

## Pourquoi un Serveur NTP est Essentiel

Un serveur NTP (Network Time Protocol) est indispensable pour :

- **Synchroniser l'heure entre plusieurs machines** dans un réseau.
- **Garantir l'exactitude des journaux système** pour le dépannage et la conformité.
- **Assurer la cohérence temporelle** dans les environnements critiques (bases de données, transactions financières, etc.).

## Étapes pour Installer un Serveur NTP sur Ubuntu

### 1. Mettre à jour le système
Avant d'installer NTP, assurez-vous que le système est à jour :
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Installer le paquet NTP
Installez le logiciel NTP à l'aide de la commande suivante :
```bash
apt install ntp -y
```

### 3. Configurer le fichier `ntp.conf`
Le fichier principal de configuration est situé à : `/etc/ntpsec/ntp.conf`.

- Ouvrez le fichier pour le modifier :
  ```bash
  vi /etc/ntpsec/ntp.conf
  ```

- Configurez les serveurs NTP publics ou locaux :
  ```
  server ntp.obspm.fr iburst
  server ntp2.jussieu.fr iburst
  server ntp.uvsq.fr iburst
  server ntp.u-psud.fr iburst
  ```

- (Optionnel) Limitez l'accès au serveur :
  ```
  restrict default nomodify nopeer noquery
  restrict 127.0.0.1
  restrict ::1
  ```

### 4. Redémarrer le service NTP
Pour appliquer les modifications, redémarrez le service :
```bash
systemctl restart ntp
```

### 5. Vérifier le statut du serveur NTP
Assurez-vous que le serveur NTP fonctionne correctement :
```bash
systemctl status ntp
```

### 6. Tester la synchronisation
Utilisez la commande suivante pour vérifier les pairs synchronisés :
```bash
ntpq -p
```

Vous devriez voir une liste des serveurs avec lesquels votre serveur NTP est synchronisé.

## Points Clés

- **Fiabilité :** Un serveur NTP correctement configuré garantit une synchronisation temporelle précise.
- **Sécurité :** Limiter l'accès au serveur empêche des modifications non autorisées.
- **Simplicité :** Avec quelques commandes, vous pouvez mettre en place une infrastructure temporelle robuste.

## 🔎 Aller plus loin

Pour comprendre la sortie de `ntpq -p` :

👉 [Voir la fiche de référence ntpq](ntpq-reference.md)

Pour automatiser la vérification de la synchronisation :

👉 [Voir le script de monitoring NTP](../monitoring/scripts/ntp-check/check_ntp_sync.sh)
