# Commandes utiles — Kea DHCP

## Consulter les journaux du service

Pour suivre les événements du service DHCP en temps réel :

```bash
journalctl -u kea-dhcp4-server -f
```

Cette commande permet d'identifier rapidement les erreurs, avertissements ou événements liés au service.

---

## Vérifier le statut du service

```bash
systemctl status kea-dhcp4-server
```

Permet de vérifier notamment :

- si le service est actif ;
- s'il a démarré correctement ;
- les derniers événements remontés par systemd.

---

## Vérifier les ports DHCP

Le serveur DHCP utilise principalement le port UDP `67`.

```bash
ss -lunp
```

Cette commande permet de vérifier les ports UDP en écoute et les processus associés.

---

## Vérifier les baux DHCP

Selon la configuration utilisée avec le backend `memfile`, les baux IPv4 peuvent être stockés dans un fichier CSV.

Par exemple :

```bash
ls -l /var/lib/kea/
```

Il est ensuite possible de consulter le fichier de baux :

```bash
cat /var/lib/kea/kea-leases4.csv
```

---

## Réinitialiser les baux dans un environnement de lab

> ⚠️ À utiliser avec précaution.

Dans un environnement de test, il peut être utile de repartir avec une base de baux vide.

Avant toute suppression, arrêter le service :

```bash
sudo systemctl stop kea-dhcp4-server
```

Sauvegarder le fichier existant :

```bash
sudo cp /var/lib/kea/kea-leases4.csv \
        /var/lib/kea/kea-leases4.csv.bak
```

Puis supprimer le fichier de baux :

```bash
sudo rm /var/lib/kea/kea-leases4.csv
```

Relancer ensuite le service :

```bash
sudo systemctl start kea-dhcp4-server
```

> Cette opération supprime l'état des baux enregistré localement.  
> Elle ne doit pas être utilisée comme méthode normale de nettoyage dans un environnement de production.
