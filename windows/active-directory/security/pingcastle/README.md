# Audit Active Directory avec PingCastle

## Présentation

PingCastle est un outil d’audit de sécurité dédié aux environnements Active Directory.

Il permet d’analyser rapidement la configuration d’un domaine afin d’identifier des faiblesses de sécurité, de mauvaises pratiques ou des éléments susceptibles d’augmenter la surface d’attaque.

L’outil génère notamment un rapport détaillé permettant de prioriser les risques et d’orienter les actions de remédiation.

## Contexte 

J’ai eu l’occasion d’utiliser PingCastle il y a plusieurs années dans le cadre d’environnements Active Directory.

Les rapports et captures issus de ces audits ne sont plus disponibles. Cette fiche n’a donc pas pour objectif de reproduire un audit précis effectué à l’époque.

Elle présente plutôt la méthodologie générale d’utilisation de PingCastle, les principaux éléments analysés par l’outil ainsi que les notions de sécurité associées, à partir de mon expérience passée et d’une remise à jour de mes connaissances.

## Objectifs d'un audit PingCastle

L’utilisation de PingCastle permet notamment de :
- obtenir une vue globale du niveau de sécurité d’un domaine Active Directory ;
- identifier les mauvaises pratiques de configuration ;
- détecter certains comptes ou objets obsolètes ;
- analyser les comptes disposant de privilèges importants ;
- identifier certains risques liés aux relations d’approbation ;
- repérer des configurations ou comportements anormaux ;
- prioriser les actions de remédiation ;
- suivre l’évolution du niveau de sécurité après correction.

## Fonctionnement général

L’un des audits les plus couramment réalisés avec PingCastle est le **Health Check**.

Celui-ci analyse différents éléments de l’environnement Active Directory puis génère un rapport, notamment au format HTML.

Workflow simplifié :

```text
PingCastle
    │
    ▼
Analyse du domaine Active Directory
    │
    ├── Comptes et groupes
    ├── Objets obsolètes
    ├── Comptes privilégiés
    ├── Relations d'approbation
    ├── Politiques et configurations
    └── Anomalies de sécurité
    │
    ▼
Évaluation des risques
    │
    ▼
Rapport HTML
    │
    ▼
Analyse et remédiation
```

## Les principales catégories de risques

PingCastle regroupe une partie de ses contrôles autour de quatre grandes catégories.

### Stale Objects

Cette catégorie concerne principalement les objets Active Directory devenus anciens ou inutilisés.

Quelques exemples :
- anciens comptes utilisateurs ;
- comptes ordinateurs n’étant plus utilisés ;
- mots de passe de comptes n’ayant pas été modifiés depuis longtemps ;
- objets qui auraient dû être supprimés ou désactivés.

Ces éléments peuvent représenter un risque, notamment lorsqu’un ancien compte reste actif alors qu’il n’est plus nécessaire.

### Privileged Accounts

Cette catégorie concerne les comptes bénéficiant de privilèges élevés dans Active Directory.

L’objectif est notamment d’identifier :
- les comptes membres de groupes administratifs sensibles ;
- une quantité trop importante de comptes privilégiés ;
- de mauvaises pratiques autour des comptes administrateurs ;
- des comptes privilégiés inutilisés ou insuffisamment protégés.

Les comptes disposant de privilèges élevés constituent des cibles particulièrement sensibles.

> ⚠️ La compromission d’un compte privilégié peut avoir un impact majeur sur l’ensemble du domaine.

### Trusts

Les relations d’approbation permettent à plusieurs domaines ou forêts Active Directory de communiquer et de partager certaines ressources.

Une mauvaise configuration de ces relations peut introduire des chemins d’attaque supplémentaires.

L’audit permet donc d’obtenir davantage de visibilité sur les relations existantes et sur les risques potentiels associés.

### Anomalies

Cette catégorie regroupe différents problèmes de configuration ou comportements pouvant présenter un risque pour Active Directory.

Il peut par exemple s’agir :
- de paramètres de sécurité insuffisants ;
- de protocoles ou mécanismes anciens ;
- de mauvaises pratiques de configuration ;
- de paramètres Active Directory trop permissifs.

## Analyse du rapport 

Le rapport PingCastle ne doit pas être considéré uniquement comme un score à faire diminuer.

### Lecture d'une alerte

| Question | Objectif |
|---|---|
| Quel objet est concerné ? | Identifier précisément la ressource |
| Pourquoi est-ce un risque ? | Comprendre le mécanisme de sécurité |
| Est-ce nécessaire ? | Vérifier le besoin métier ou technique |
| Quel est l’impact d’une correction ? | Éviter une régression |
| Quelle remédiation appliquer ? | Corriger de manière adaptée |

Chaque alerte doit être replacée dans le contexte de l’environnement.

Pour chaque risque identifié, il est important de déterminer :
1. quel élément Active Directory est concerné ;
2. pourquoi la configuration représente un risque ;
3. si cette configuration est réellement nécessaire ;
4. quel serait l’impact d’une modification ;
5. quelle action corrective peut être appliquée.

Certaines alertes peuvent être pertinentes dans un environnement et acceptables dans un autre.

L’objectif est donc d’utiliser PingCastle comme un outil d’aide à l’analyse et non comme un simple scanner automatique.

## Cycle d'audit et de remédiation

Une démarche d’audit peut suivre le cycle suivant :
```text
Audit initial
    ↓
Analyse des résultats
    ↓
Priorisation des risques
    ↓
Correction des configurations
    ↓
Nouvel audit
    ↓
Comparaison des résultats
    ↓
Suivi dans le temps
```

Cette approche permet de vérifier que les actions appliquées ont réellement amélioré la sécurité de l’environnement.

Elle permet également de suivre l’évolution du domaine dans le temps.

## Points importants à retenir

PingCastle permet d’obtenir rapidement une vue d’ensemble de la posture de sécurité d’un environnement Active Directory.

Cependant, l’intérêt principal de l’outil ne réside pas uniquement dans la génération du rapport.

Il permet surtout de faciliter une démarche composée de plusieurs étapes :
```text
détection → analyse → compréhension du risque → remédiation → validation
```

L’analyse des résultats nécessite donc de connaître les mécanismes Active Directory associés afin de déterminer les corrections adaptées sans perturber le fonctionnement de l’infrastructure.

## Compétences associées

Cette utilisation de PingCastle mobilise notamment des connaissances autour de :
- Active Directory ;
- sécurité des comptes et groupes ;
- comptes privilégiés ;
- principe du moindre privilège ;
- relations d’approbation ;
- politiques de sécurité ;
- analyse de risques ;
- durcissement Active Directory ;
- remédiation de configurations ;
- administration Windows Server.

## Limites de cette fiche

Cette documentation repose sur une expérience antérieure avec PingCastle ainsi que sur une remise à jour des connaissances autour de l’outil.

Les captures d’écran et rapports issus de l’environnement utilisé à l’époque n’étant plus disponibles, aucun résultat réel provenant de cet environnement n’est présenté ici.

L’objectif est de documenter la démarche d’audit et les concepts de sécurité associés sans exposer d’informations provenant d’une infrastructure professionnelle.
