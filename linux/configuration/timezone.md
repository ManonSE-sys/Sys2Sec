# Configurer le fuseau horaire

## Vérifier la configuration actuelle

```bash
timedatectl
```

## Lister les fuseaux horaires

```bash
timedatectl list-timezones
```

Exemple :

```bash
timedatectl list-timezones | grep Europe
```

## Modifier le fuseau horaire

```bash
sudo timedatectl set-timezone Europe/Paris
```

## Vérifier

```bash
timedatectl
```

## Pourquoi c'est important

Un fuseau horaire cohérent facilite l'analyse des journaux, la supervision, la corrélation d'événements, les tâches planifiées et les investigations de sécurité.
