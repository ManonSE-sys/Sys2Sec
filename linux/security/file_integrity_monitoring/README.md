# File Integrity Monitoring

## Présentation

Ce projet présente deux implémentations d'un mécanisme simple de File Integrity Monitoring :

- une version Bash ;
- une version Python.

L'objectif est de comprendre le fonctionnement d'un contrôle d'intégrité basé sur des empreintes SHA-256 et de comparer deux approches différentes pour répondre au même besoin de sécurité.

---

## Objectif

Le File Integrity Monitoring consiste à surveiller des fichiers afin de détecter des changements inattendus.

Le principe repose sur une baseline :

```text
État de référence
      │
      ▼
Calcul des empreintes
      │
      ▼
Vérification ultérieure
      │
      ▼
Comparaison
      │
      ▼
Détection d'un changement
```

Les scripts de ce projet permettent notamment de détecter :

- un fichier modifié ;
- un fichier supprimé ;
- une différence entre l'état actuel et l'état de référence.

---

## Structure du projet

```text
file-integrity-monitoring/
├── README.md
├── bash/
│   ├── README.md
│   ├── fim.sh
│   └── files.conf
├── python/
│   ├── README.md
│   ├── fim.py
│   └── files.conf
└── examples/
    ├── baseline.example.json
    └── fim-report.example.json
```

Les fichiers de baseline et de rapport réellement générés ne sont pas destinés à être versionnés directement.

Des exemples anonymisés peuvent être placés dans :

```text
examples/
```

---

## Version Bash

La version Bash constitue l'implémentation la plus simple.

Elle utilise notamment :

```bash
sha256sum
```

pour calculer les empreintes des fichiers surveillés.

Elle permet de :

- créer une baseline ;
- vérifier les fichiers ;
- détecter les modifications ;
- détecter les fichiers absents ;
- retourner des codes de sortie compatibles avec une logique de supervision.

👉 [Voir la version Bash](./bash/)

---

## Version Python

La version Python reprend le même principe mais ajoute une structure plus riche.

Elle utilise notamment :

- `hashlib` pour SHA-256 ;
- `json` pour les données structurées ;
- `pathlib` pour les chemins ;
- `argparse` pour les arguments ;
- `datetime` pour l'horodatage.

Elle permet de :

- créer une baseline JSON ;
- vérifier l'intégrité des fichiers ;
- détecter les fichiers modifiés ;
- détecter les fichiers absents ;
- horodater les contrôles ;
- générer un rapport JSON ;
- retourner des codes de sortie.

👉 [Voir la version Python](./python/)

---

## Comparaison des deux versions

| Fonctionnalité | Bash | Python |
|---|---:|---:|
| Calcul SHA-256 | ✅ | ✅ |
| Baseline | Texte | JSON |
| Fichier modifié | ✅ | ✅ |
| Fichier absent | ✅ | ✅ |
| Codes de retour | ✅ | ✅ |
| Horodatage | ❌ | ✅ |
| Rapport structuré | ❌ | ✅ |
| JSON | ❌ | ✅ |
| Évolution future | Limitée | Plus facile |

La version Bash met principalement l'accent sur la simplicité et l'intégration Linux.

La version Python permet une gestion plus structurée des données et offre davantage de possibilités d'évolution.

---

## Exemple de fichiers surveillés

Les fichiers peuvent être définis dans :

```text
files.conf
```

Exemple :

```text
/etc/passwd
/etc/group
/etc/ssh/sshd_config
```

Dans un environnement de test, il est également possible d'utiliser des copies ou des fichiers dédiés à un laboratoire.

---

## Principe de la baseline

Lors de l'initialisation, le script calcule une empreinte SHA-256 pour chaque fichier.

Exemple simplifié :

```text
/etc/passwd
      │
      ▼
   SHA-256
      │
      ▼
abc123...
```

Lors d'un contrôle ultérieur :

```text
Hash de référence
       │
       ├─────────────┐
       │             │
       ▼             ▼
Hash identique   Hash différent
       │             │
       ▼             ▼
      OK          CRITICAL
```

---

## Pourquoi SHA-256 ?

SHA-256 permet de produire une empreinte à partir du contenu d'un fichier.

Une modification du contenu entraîne normalement une empreinte différente.

Cela permet de détecter qu'un changement a eu lieu entre deux contrôles.

Le hash ne permet cependant pas de déterminer :

- qui a effectué la modification ;
- pourquoi elle a été effectuée ;
- si elle est légitime ou malveillante.

Il constitue donc un mécanisme de détection, pas une preuve de compromission.

---

## Intérêt en cybersécurité

Le File Integrity Monitoring peut être utilisé pour surveiller des fichiers sensibles :

- comptes utilisateurs ;
- configuration SSH ;
- fichiers applicatifs ;
- scripts système ;
- fichiers de sécurité ;
- configurations critiques.

Il permet d'identifier rapidement qu'un changement a eu lieu sur un fichier surveillé.

Ce type de mécanisme peut participer à une stratégie de détection et de supervision.

---

## Du script pédagogique aux outils spécialisés

Les scripts présents dans ce projet permettent de comprendre la logique fondamentale du FIM.

Pour des besoins plus avancés, des outils spécialisés peuvent gérer :

- la surveillance en temps réel ;
- les répertoires complets ;
- les nouveaux fichiers ;
- les permissions ;
- les propriétaires ;
- les suppressions ;
- la centralisation des alertes ;
- la corrélation avec d'autres événements.

Des solutions comme Wazuh, AIDE ou Tripwire sont conçues pour répondre à ce type de besoins à plus grande échelle.

---

## Limites du projet

Ce projet reste volontairement pédagogique.

Il ne constitue pas une solution de sécurité complète.

Les principales limites sont :

- surveillance de fichiers explicitement définis ;
- absence de surveillance temps réel ;
- baseline locale ;
- absence de protection forte de la baseline ;
- absence de corrélation avec d'autres événements ;
- absence de gestion centralisée.

---

## Compétences mises en pratique

Ce projet permet de travailler sur :

### Linux

- manipulation de fichiers ;
- scripts Bash ;
- commandes système ;
- codes de retour.

### Python

- fonctions ;
- dictionnaires ;
- lecture et écriture de fichiers ;
- JSON ;
- gestion des arguments ;
- gestion des chemins ;
- horodatage.

### Cybersécurité

- File Integrity Monitoring ;
- empreintes SHA-256 ;
- baseline ;
- détection de modifications ;
- contrôle d'intégrité ;
- génération d'alertes et de rapports.

---

## Approche du projet

Le projet a été construit progressivement :

```text
Version Bash
     │
     ▼
Compréhension du principe
     │
     ▼
Version Python
     │
     ▼
Baseline JSON
     │
     ▼
Horodatage
     │
     ▼
Rapport structuré
```

Cette progression permet de partir d'une implémentation simple avant d'introduire une gestion plus structurée des données.

---

## Évolutions possibles

Plusieurs pistes peuvent être envisagées :

- protéger la baseline ;
- vérifier les permissions et propriétaires ;
- conserver un historique des rapports ;
- envoyer les résultats vers un SIEM ;
- déclencher des notifications ;
- intégrer les scripts à une solution de supervision ;
- comparer le fonctionnement avec une solution FIM spécialisée.

---

## Conclusion

Ce projet permet de comprendre concrètement le fonctionnement d'un mécanisme de File Integrity Monitoring.

Les deux implémentations montrent deux approches différentes :

```text
Bash
→ simple
→ proche du système
→ adapté aux checks Linux

Python
→ données structurées
→ JSON
→ rapports
→ plus facile à faire évoluer
```

L'objectif n'est pas de remplacer une solution FIM existante, mais de comprendre les mécanismes fondamentaux qui se trouvent derrière ce type d'outil.
