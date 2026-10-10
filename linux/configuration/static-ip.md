# Configurer une adresse IP statique avec Netplan

## Présentation

Une adresse IP statique est couramment utilisée sur les serveurs afin de garantir une adresse stable pour les services, la supervision et l'administration.

## Identifier l'interface réseau

```bash
ip a
```

Exemple :

```text
enp0s3
```

## Identifier les fichiers Netplan

```bash
ls /etc/netplan/
```

## Exemple de configuration statique

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.1.50/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 192.168.1.10
          - 1.1.1.1
```

Adapter le nom de l'interface, l'adresse IP, la passerelle et les serveurs DNS.

## Tester la configuration

```bash
sudo netplan generate
```

Puis :

```bash
sudo netplan apply
```

## Vérifier

```bash
ip a
ip route
```

## Points d'attention

- une erreur Netplan peut couper l'accès distant ;
- vérifier qu'aucune autre machine n'utilise déjà l'adresse ;
- conserver une console ou un accès de secours si possible.
