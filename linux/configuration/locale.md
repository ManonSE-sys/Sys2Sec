# Configurer la locale d'un serveur Linux

## Vérifier la locale actuelle

```bash
locale
```

## Lister les locales disponibles

```bash
locale -a
```

## Définir la locale par défaut

```bash
sudo update-locale LANG=fr_FR.UTF-8
```

## Vérifier

Ouvrir une nouvelle session puis :

```bash
locale
```

## Points d'attention

La locale influence notamment l'affichage des dates, les formats numériques, certains messages système, le tri et l'encodage des caractères.
