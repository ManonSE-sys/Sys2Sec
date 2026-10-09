# Active Directory Hardening — Authentification et politiques de sécurité

Ce repository documente mon travail autour de la room
**Active Directory Hardening** de TryHackMe.

L'objectif n'est pas de reproduire le contenu de la room, mais de synthétiser
les mécanismes de durcissement étudiés, de documenter les configurations
que j'ai manipulées et d'expliquer ce que j'en retiens.

Aucune réponse aux questions, flag ou solution complète de la room
n'est publiée ici.

## Compétences travaillées

Au cours de ce lab, j'ai travaillé sur plusieurs aspects du durcissement
d'Active Directory :

- stratégies de groupe (GPO) ;
- sécurité de l'authentification ;
- sécurisation des communications SMB ;
- sécurisation des communications LDAP ;
- politiques de mot de passe ;
- gestion des comptes de service ;
- principe du moindre privilège.

---

## 1. Désactiver le stockage des hash LM

### Contexte

Windows ne stocke pas directement les mots de passe utilisateurs en clair.
Différentes représentations de hash peuvent être utilisées.

Dans la room, j'ai notamment étudié le **LM Hash (LAN Manager Hash)**,
un ancien mécanisme considéré comme plus faible que le hash NT.

### Risque identifié

La faiblesse du LM Hash le rend davantage exposé aux attaques par brute force.

Une mesure de durcissement consiste donc à empêcher Windows de conserver
ce type de hash lors des futurs changements de mot de passe.

### Mise en pratique

Dans l'éditeur de stratégie de groupe :

`Computer Configuration`
→ `Policies`
→ `Windows Settings`
→ `Security Settings`
→ `Local Policies`
→ `Security Options`

J'ai configuré la stratégie :

`Network security: Do not store LAN Manager hash value on next password change`

### Capture

![Désactivation du stockage LM](images/01-disable-lm-hash.png)

### Ce que j'ai compris

Cette stratégie permet de supprimer progressivement l'utilisation d'un
mécanisme historique de stockage des mots de passe.

Un point important est que la stratégie prend effet lors du prochain
changement de mot de passe : son activation ne remplace donc pas
instantanément les valeurs déjà présentes.

---

## 2. Activer la signature SMB

### Contexte

SMB (*Server Message Block*) est notamment utilisé dans les environnements
Windows pour les communications liées aux fichiers et aux imprimantes.

### Risque identifié

Sans mécanisme permettant de vérifier l'intégrité des communications,
un attaquant capable d'intercepter le trafic pourrait tenter de modifier
les échanges entre deux systèmes.

La signature SMB permet d'ajouter un mécanisme de vérification de
l'intégrité des échanges.

### Mise en pratique

Dans l'éditeur de stratégie de groupe :

`Computer Configuration`
→ `Policies`
→ `Windows Settings`
→ `Security Settings`
→ `Local Policies`
→ `Security Options`

J'ai activé :

`Microsoft network server: Digitally sign communications (always)`

### Capture

![Activation de la signature SMB](images/02-smb-signing.png)

### Ce que j'ai compris

La signature SMB permet de vérifier que les échanges n'ont pas été modifiés
pendant leur transmission.

Cette configuration participe donc au durcissement des communications SMB
dans un environnement Active Directory.

---

## 3. Exiger la signature LDAP

### Contexte

LDAP (*Lightweight Directory Access Protocol*) est utilisé pour rechercher
et authentifier des ressources dans un environnement Active Directory.

### Risque identifié

La room présente notamment le risque de requêtes LDAP non protégées
pouvant être exploitées dans certaines attaques.

L'utilisation de LDAP Signing permet d'imposer l'utilisation de requêtes
signées.

### Mise en pratique

Dans l'éditeur de stratégie de groupe :

`Computer Configuration`
→ `Policies`
→ `Windows Settings`
→ `Security Settings`
→ `Local Policies`
→ `Security Options`

J'ai configuré :

`Domain controller: LDAP server signing requirements`

avec la valeur :

`Require signing`

### Capture

![Configuration de LDAP Signing](images/03-ldap-signing.png)

### Ce que j'ai compris

Le but n'est pas simplement « d'activer une option LDAP ».

La stratégie définit quelles communications le contrôleur de domaine
accepte et permet d'écarter les requêtes qui ne respectent pas
l'exigence de signature.

Cela m'a permis de mieux comprendre que le durcissement Active Directory
repose également sur la sécurisation des protocoles utilisés autour du domaine.

---

## 4. Gestion et rotation des mots de passe

### Problématique

La rotation des mots de passe peut devenir complexe dans un environnement
Active Directory, notamment pour les comptes utilisés par des services
ou des processus automatisés.

La room présente plusieurs approches permettant de répondre à cette problématique.

### Approches étudiées

| Approche | Principe | Point d'attention |
|---|---|---|
| PowerShell | Automatiser le changement de mot de passe via un script et une tâche planifiée | Le script doit être développé et maintenu |
| MFA | Ajouter un facteur d'authentification supplémentaire | Ajoute une couche de sécurité mais ne répond pas à tous les cas d'usage |
| gMSA | Confier à Active Directory la gestion du mot de passe d'un compte de service | Nécessite d'utiliser un type de compte adapté |

### Focus : gMSA

Les **Group Managed Service Accounts (gMSA)** permettent à Active Directory
de gérer automatiquement le mot de passe de certains comptes de service.

La rotation du mot de passe est alors prise en charge automatiquement.

### Ce que j'ai compris

Les comptes de service peuvent poser un problème particulier : modifier
manuellement leur mot de passe peut avoir un impact sur les applications
ou services qui les utilisent.

Les gMSA permettent de réduire cette gestion manuelle en automatisant
la gestion du mot de passe.

### À approfondir

Je souhaite compléter cette partie par un mini-lab consacré aux gMSA :

- création d'un gMSA ;
- association à un serveur ;
- utilisation par un service ;
- vérification de son fonctionnement.

---

## 5. Politique de mot de passe

### Contexte

Les mots de passe constituent une cible importante dans un environnement
Active Directory.

La room présente notamment plusieurs types d'attaques :

- brute force ;
- attaques par dictionnaire ;
- password spraying ;
- attaques visant les identifiants.

Une politique de mot de passe permet de définir des règles communes
pour les comptes du domaine.

### Mise en pratique

Dans l'éditeur de stratégie de groupe :

`Computer Configuration`
→ `Policies`
→ `Windows Settings`
→ `Security Settings`
→ `Account Policies`
→ `Password Policy`

### Paramètres étudiés

#### Enforce password history

Ce paramètre empêche la réutilisation immédiate d'anciens mots de passe.

La room recommande de conserver un historique de **10 à 15 mots de passe**.

#### Minimum password length

Ce paramètre définit le nombre minimal de caractères autorisés.

La room recommande ici une valeur comprise entre **10 et 14 caractères**.

#### Password must meet complexity requirements

Cette stratégie impose différentes règles de complexité, notamment
l'utilisation de plusieurs catégories de caractères.

### Capture

![Configuration de la politique de mot de passe](images/04-password-policy.png)

### Ce que j'ai compris

Une politique de mot de passe ne se limite pas à imposer des caractères
spéciaux.

Plusieurs paramètres doivent être considérés ensemble :

- longueur ;
- historique ;
- complexité ;
- gestion du changement de mot de passe ;
- mécanismes d'authentification complémentaires.

Les valeurs indiquées ci-dessus correspondent aux recommandations étudiées
dans cette room et ne sont pas présentées ici comme des valeurs universelles
pour tous les environnements.

## Ce que ce lab m'a apporté

Cette room m'a permis de relier plusieurs concepts Active Directory
à des mesures de durcissement concrètes.

Au-delà de l'activation de stratégies de groupe, j'en retiens surtout
qu'une mesure de sécurité doit répondre à un risque identifié :

| Risque | Mesure étudiée |
|---|---|
| Stockage d'un hash historique faible | Désactivation du stockage LM |
| Modification des échanges SMB | SMB Signing |
| Requêtes LDAP non signées | LDAP Signing |
| Gestion complexe des comptes de service | gMSA |
| Attaques visant les mots de passe | Password Policy |

Cette approche me permet progressivement de passer d'une logique
d'administration Active Directory à une logique davantage orientée
sécurisation et durcissement de l'infrastructure.
