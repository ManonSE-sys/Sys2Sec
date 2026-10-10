# Tests de stress d'un serveur Linux avec stress-ng

## 📌 Présentation

Les tests de stress permettent de soumettre un serveur à une charge importante afin d'observer son comportement dans différentes conditions.

Ils peuvent notamment servir à :

- vérifier le comportement d'un serveur avant sa mise en production ;
- identifier d'éventuels goulots d'étranglement ;
- observer la stabilité du système sous charge ;
- tenter de reproduire des erreurs présentes dans les journaux système ;
- compléter une démarche de diagnostic matériel ou logiciel.

Dans ce projet, `stress-ng` a notamment été utilisé pour tester des serveurs destinés à une infrastructure Proxmox et pour tenter de reproduire des erreurs kernel suspectées d'être liées au stockage.

> ⚠️ Un stress test ne permet pas, à lui seul, de garantir l'absence de panne matérielle. Il permet surtout d'observer le comportement du système pendant une campagne de tests donnée.

---

## 🎯 Objectifs

- générer une charge CPU ;
- solliciter la mémoire ;
- générer des écritures disque ;
- combiner plusieurs types de charge ;
- surveiller les journaux système pendant les tests ;
- comparer le comportement observé avec les symptômes rencontrés.

---

## 🛠️ Outil utilisé

### stress-ng

Installation :

```bash
sudo apt update
sudo apt install stress-ng -y
```

---

## 1. Tester le CPU

```bash
stress-ng --cpu 4 --timeout 60s
```

Cette commande lance une charge CPU avec 4 workers pendant 60 secondes.

Pour une charge plus importante :

```bash
stress-ng --cpu 8 --timeout 120s
```

Surveillance :

```bash
top
```

ou :

```bash
htop
```

---

## 2. Tester la mémoire

```bash
stress-ng --vm 2 --vm-bytes 75% --timeout 60s
```

Cette commande lance deux workers mémoire et utilise jusqu'à 75 % de la mémoire disponible pendant 60 secondes.

Surveillance :

```bash
free -h
```

```bash
vmstat 1
```

---

## 3. Tester les écritures disque

```bash
stress-ng --hdd 2 --hdd-bytes 1G --timeout 60s
```

Cette commande lance deux workers effectuant des opérations disque.

> ⚠️ Les tests disque génèrent des écritures. Ils doivent être exécutés dans un contexte maîtrisé.

---

## 4. Combiner plusieurs charges

```bash
stress-ng --cpu 2 --vm 1 --vm-bytes 50% --hdd 1 --hdd-bytes 500M --timeout 120s
```

Cette commande sollicite simultanément le CPU, la mémoire et le stockage.

---

## 🔎 Surveillance pendant les tests

### Journaux kernel

```bash
journalctl -k -f
```

ou :

```bash
dmesg -w
```

### Charge système

```bash
uptime
```

### Mémoire

```bash
free -h
```

### Entrées/sorties

```bash
vmstat 1
```

Si `iostat` est disponible :

```bash
iostat
```

---

## 🧪 Cas pratique : serveurs destinés à Proxmox

### Contexte

Plusieurs serveurs destinés à héberger une infrastructure Proxmox devaient être testés avant leur utilisation.

### Méthode

Des charges CPU, mémoire et disque ont été générées avec `stress-ng` pendant que les ressources et les journaux système étaient surveillés.

### Résultat

Les serveurs ont supporté les charges simulées sans anomalie critique observée pendant la campagne de tests.

> Ce résultat valide le comportement observé pendant les tests, mais ne constitue pas une garantie absolue sur l'état matériel du serveur.

---

## 🧪 Cas pratique : investigation d'erreurs kernel

### Contexte

Un autre serveur présentait des messages d'erreur kernel. Les symptômes faisaient notamment suspecter un problème lié au stockage.

### Méthode

Plusieurs tests ont été exécutés, notamment des charges disque, afin de tenter de reproduire l'erreur dans des conditions contrôlées.

### Résultat

Aucune anomalie critique n'a été reproduite pendant les tests.

Cela n'exclut pas définitivement un problème matériel : cela indique seulement que les charges générées n'ont pas permis de reproduire le défaut observé.

---

## 🔐 Points d'attention

Avant de lancer un stress test :

- vérifier que le serveur peut supporter une charge importante ;
- éviter de tester sans précaution un système de production ;
- vérifier l'espace disque disponible ;
- surveiller les journaux et, si possible, la température du matériel ;
- définir une durée de test ;
- arrêter le test si le serveur présente un comportement anormal.

---

## 📌 Points clés

- **Diagnostic :** `stress-ng` permet de reproduire différentes conditions de charge.
- **Observation :** les résultats doivent être croisés avec les métriques et les journaux système.
- **Prudence :** un test réussi ne prouve pas qu'un matériel est exempt de défaut.
- **Méthodologie :** les tests doivent être adaptés au symptôme ou à l'objectif recherché.
