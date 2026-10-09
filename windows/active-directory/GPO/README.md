# 🏢 Group Policy Objects (GPO) — Concepts essentiels

## 📌 Qu'est-ce qu'une GPO ?

Une **GPO (Group Policy Object)** permet d'appliquer de manière centralisée des paramètres de configuration à des utilisateurs ou à des ordinateurs dans un environnement Active Directory.

Une GPO peut contenir :

- des paramètres de sécurité ;
- des configurations système ;
- des paramètres utilisateurs ;
- des restrictions ;
- des configurations réseau ;
- des paramètres Windows.

Elle peut être liée à :

- un **site** ;
- un **domaine** ;
- une **OU (Organizational Unit)**.

Les paramètres configurés dans une GPO peuvent cibler :

- les ordinateurs via **Computer Configuration** ;
- les utilisateurs via **User Configuration**.

---

## 🔄 Ordre d'application des GPO

Lorsque plusieurs stratégies s'appliquent à un même objet, elles sont traitées selon l'ordre **LSDOU** :

```text
Local
  ↓
Site
  ↓
Domain
  ↓
Organizational Unit
```

### Local

La stratégie locale de la machine est appliquée en premier.

### Site

Les GPO liées au site Active Directory sont ensuite appliquées.

### Domain

Les GPO liées au domaine sont appliquées après celles du site.

### Organizational Unit

Les GPO liées aux OU sont ensuite appliquées en descendant dans l'arborescence.

Une GPO liée à une OU située plus près de l'objet peut généralement écraser un paramètre provenant d'une GPO appliquée plus haut dans l'arborescence.

> ⚠️ La règle du **« dernier appliqué gagne »** est une simplification utile, mais certains mécanismes comme **Enforced**, **Block Inheritance** ou certains paramètres spécifiques peuvent modifier le comportement attendu.

---

## 🔒 Enforced

Une GPO marquée **Enforced** bénéficie d'un comportement particulier dans l'ordre d'héritage.

Ses paramètres ne peuvent pas être écrasés par une GPO liée plus bas dans l'arborescence.

Elle reste également applicable même lorsqu'une OU utilise **Block Inheritance**.

---

## 🚧 Block Inheritance

Une OU peut être configurée avec l'option :

```text
Block Inheritance
```

Cette option permet d'empêcher l'héritage des GPO provenant des niveaux supérieurs.

Cependant, une GPO marquée **Enforced** continue de s'appliquer.

---

## 🎯 Security Filtering

Par défaut, une GPO liée à une OU peut potentiellement concerner l'ensemble des objets présents dans son périmètre.

Le **Security Filtering** permet de contrôler plus précisément les utilisateurs ou ordinateurs auxquels la GPO doit réellement s'appliquer.

Il est donc possible de cibler uniquement certains :

- utilisateurs ;
- groupes ;
- ordinateurs.

Cela permet d'éviter de créer une OU uniquement pour appliquer une stratégie spécifique à quelques objets.

---

## 🔑 Fine-Grained Password Policies

Active Directory permet d'appliquer plusieurs politiques de mot de passe dans un même domaine grâce aux **Fine-Grained Password Policies (FGPP)**.

Une FGPP repose sur un objet appelé :

**Password Settings Object (PSO)**

Un PSO peut notamment définir :

- la longueur minimale du mot de passe ;
- la complexité ;
- l'historique ;
- l'âge minimal du mot de passe ;
- l'âge maximal ;
- les paramètres de verrouillage de compte.

Le PSO est ensuite associé aux utilisateurs ou groupes concernés.

### Priorité

Lorsqu'un utilisateur correspond à plusieurs PSO, Active Directory doit déterminer laquelle appliquer.

Chaque PSO possède une valeur de priorité.

> ⚠️ Plus la valeur de priorité est faible, plus la priorité est élevée.

Exemple :

```text
PSO-Admins     → priorité 10
PSO-Standard   → priorité 20
```

Si un utilisateur correspond aux deux politiques, `PSO-Admins` sera prioritaire.

---

## 🛠️ Commandes utiles

### Forcer l'actualisation des stratégies

```cmd
gpupdate /force
```

Permet de demander une actualisation immédiate des stratégies de groupe sur la machine.

---

### Vérifier les GPO appliquées

```cmd
gpresult /r
```

Permet d'obtenir un résumé des stratégies appliquées à l'utilisateur et à l'ordinateur.

---

### Resultant Set of Policy

```cmd
rsop.msc
```

**Resultant Set of Policy** fournit une vue graphique permettant d'analyser le résultat des différentes stratégies appliquées.

C'est particulièrement utile pour comprendre :

- quelle GPO configure un paramètre ;
- quelles stratégies ont effectivement été appliquées ;
- les éventuels conflits de configuration.

---

## 🧠 Ce que je retiens

Les GPO permettent de centraliser la configuration d'un environnement Active Directory.

Pour comprendre pourquoi une stratégie est ou non appliquée, plusieurs éléments doivent être pris en compte :

- l'endroit où la GPO est liée ;
- l'ordre LSDOU ;
- l'héritage ;
- les options **Enforced** et **Block Inheritance** ;
- le **Security Filtering** ;
- le type de configuration : **User** ou **Computer**.

Les commandes `gpresult`, `gpupdate` et `rsop.msc` sont également importantes pour diagnostiquer les problèmes liés à l'application des stratégies.

---

## 🔗 Mise en pratique

J'ai également travaillé ces notions dans un lab TryHackMe consacré au durcissement d'Active Directory et aux stratégies de groupe.

👉 [Voir le lab Active Directory Hardening](../../labs/tryhackme/active-directory-hardening/README.md)
