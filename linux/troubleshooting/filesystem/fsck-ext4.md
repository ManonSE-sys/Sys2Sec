# Vérifier un système de fichiers ext4 avec fsck

## 📌 Présentation

Lorsqu'un serveur Linux présente des erreurs liées à un système de fichiers `ext4`, l'outil `fsck` peut être utilisé pour vérifier et, selon les options choisies, corriger certaines incohérences.

> ⚠️ `fsck` ne doit pas être lancé sur un système de fichiers monté en écriture.

---

## 🎯 Objectifs

- identifier la partition concernée ;
- vérifier un système de fichiers non monté ;
- corriger certaines erreurs ;
- traiter le cas particulier d'une partition racine ;
- éviter les manipulations risquées sur un système de fichiers actif.

---

## 1. Identifier les disques et partitions

```bash
lsblk
```

Pour afficher également les systèmes de fichiers :

```bash
lsblk -f
```

Toujours vérifier précisément la partition concernée avant de continuer.

---

## 2. Vérifier que la partition n'est pas montée

```bash
findmnt
```

ou :

```bash
mount
```

Si la partition est montée, la démonter avant l'analyse :

```bash
sudo umount /dev/sdX1
```

Remplacer `/dev/sdX1` par la partition réellement concernée.

---

## 3. Lancer fsck

Vérification interactive :

```bash
sudo fsck /dev/sdX1
```

Dans la procédure initialement utilisée :

```bash
sudo fsck -fy -C /dev/sdX1
```

### Options

- `-f` : force la vérification ;
- `-y` : accepte automatiquement les corrections proposées ;
- `-C` : affiche une barre de progression lorsque cela est pris en charge.

> ⚠️ L'option `-y` applique automatiquement les corrections. Pour des données importantes, il peut être préférable d'éviter la validation automatique.

---

## 4. Cas de la partition racine

La partition racine `/` est généralement montée pendant le fonctionnement normal du serveur.

Il ne faut donc pas lancer `fsck` directement dessus lorsqu'elle est montée en écriture.

Une solution consiste à démarrer depuis :

- un Live USB Ubuntu ;
- un environnement de secours ;
- un mode de maintenance permettant de travailler sur la partition hors ligne.

Depuis un Live USB :

```bash
lsblk -f
```

Puis, une fois la bonne partition identifiée et non montée :

```bash
sudo fsck /dev/sdX1
```

---

## 5. Vérifier après l'intervention

Redémarrer si nécessaire :

```bash
sudo reboot
```

Puis vérifier les journaux kernel :

```bash
journalctl -k
```

Recherche ciblée sur ext4 :

```bash
journalctl -k | grep -i ext4
```

---

## 🔐 Points d'attention

Avant d'utiliser `fsck` :

- identifier précisément la bonne partition ;
- ne pas lancer `fsck` sur un système de fichiers monté en écriture ;
- disposer d'une sauvegarde lorsque les données sont importantes ;
- utiliser avec prudence les options automatiques comme `-y` ;
- vérifier les journaux après l'intervention ;
- si les erreurs se répètent, investiguer également le stockage sous-jacent.

Des erreurs répétées peuvent être liées à un problème plus large : arrêt brutal, disque défaillant, contrôleur, corruption ou autre anomalie de stockage.

---

## 📌 Points clés

- **Identification :** utiliser `lsblk` ou `lsblk -f`.
- **Sécurité :** vérifier le système de fichiers hors ligne.
- **Correction :** `fsck` peut réparer certaines incohérences ext4.
- **Prudence :** `-y` applique automatiquement les corrections.
- **Diagnostic :** des erreurs récurrentes nécessitent aussi une investigation du stockage.
