# Les commandes utiles pour un serveur NFS et un client

## Serveur NFS

Vérifier les exports du serveurs NFS
```bash
showmount -e
```

Surveiller les performances côté serveur
```bash
nfsstat -s
```

Surveiller les performances côté client
```bash
nfsstat -c
```

Réinitialiser et afficher les statistiques actuelles (depuis la dernière réinitialisation) :
```bash
nfsstat -z
```

Vérifier les logs 
```bash
journalctl -u nfs-server
dmesg | grep nfs
```

## Client NFS

Si un partage ne fonctionne pas, vérifier la disponibilité et remonter manuellement :
```bash
sudo mount -a
```
