# Commandes utiles — vsftpd

Cette fiche regroupe quelques commandes utiles pour administrer et diagnostiquer un serveur `vsftpd`.

---

## 🖥️ Vérifier le service

Afficher l'état du service :

```bash
systemctl status vsftpd
```

Redémarrer le service après une modification de configuration :

```bash
sudo systemctl restart vsftpd
```

Arrêter le service :

```bash
sudo systemctl stop vsftpd
```

Démarrer le service :

```bash
sudo systemctl start vsftpd
```

---

## 📄 Consulter les journaux

Suivre le journal de transfert configuré dans `vsftpd.conf` :

```bash
tail -f /var/log/vsftpd.log
```

Consulter les événements liés au service avec systemd :

```bash
journalctl -u vsftpd
```

Suivre les événements en temps réel :

```bash
journalctl -u vsftpd -f
```

---

## 🌐 Vérifier le port en écoute

Afficher les ports TCP en écoute :

```bash
ss -lntp
```

FTP utilise notamment le port TCP `21` pour la connexion de contrôle.

Pour filtrer uniquement ce port :

```bash
ss -lntp | grep ':21'
```

---

## 👤 Vérifier l'utilisateur FTP

Afficher les informations du compte :

```bash
id ftpuser
```

Vérifier son répertoire personnel :

```bash
getent passwd ftpuser
```

---

## 📁 Vérifier les permissions

Afficher les droits sur l'arborescence FTP :

```bash
ls -ld /home/ftpuser/ftp
ls -ld /home/ftpuser/ftp/upload
```

Exemple attendu :

```text
/home/ftpuser/ftp        → contrôlé par root
/home/ftpuser/ftp/upload → accessible à ftpuser
```

---

## 🔎 Tester depuis un client

Se connecter au serveur :

```bash
ftp <IP_DU_SERVEUR>
```

Une fois connecté :

```text
ls
cd upload
put fichier.txt
get fichier.txt
```

---

## 🧭 Diagnostic rapide

En cas de problème, vérifier dans cet ordre :

```text
1. Le service vsftpd fonctionne-t-il ?
2. Le port 21 est-il en écoute ?
3. Le compte utilisateur existe-t-il ?
4. Les permissions du répertoire sont-elles correctes ?
5. Le chroot est-il correctement configuré ?
6. Les journaux indiquent-ils une erreur ?
```

Commandes principales :

```bash
systemctl status vsftpd
ss -lntp | grep ':21'
id ftpuser
ls -ld /home/ftpuser/ftp /home/ftpuser/ftp/upload
journalctl -u vsftpd
```
