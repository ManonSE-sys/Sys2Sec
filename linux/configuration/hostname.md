# Configurer le nom d'un serveur Linux

## Présentation

Le nom d'hôte permet d'identifier facilement une machine sur le réseau et dans les outils d'administration.

## Vérifier le nom actuel

```bash
hostname
```

ou :

```bash
hostnamectl
```

## Modifier le nom du serveur

```bash
sudo hostnamectl set-hostname srv-linux-01
```

Vérifier ensuite :

```bash
hostnamectl
```

## Vérifier `/etc/hosts`

Selon l'environnement, il peut être nécessaire d'adapter :

```text
/etc/hosts
```

Exemple :

```text
127.0.0.1       localhost
127.0.1.1       srv-linux-01
```

## Points d'attention

- utiliser une convention de nommage cohérente ;
- éviter les noms ambigus ;
- vérifier la résolution DNS si le serveur est enregistré dans un domaine ;
- adapter les outils de supervision ou d'inventaire si le serveur change de nom.
