# Ansible

## Présentation

Cette section regroupe des projets d'automatisation et de gestion de configuration réalisés avec Ansible.

L'objectif est d'utiliser Ansible pour appliquer de manière reproductible des configurations sur des systèmes Linux.

Les projets présents dans cette section peuvent couvrir :

- durcissement de systèmes ;
- gestion de paquets ;
- configuration de services ;
- gestion de comptes ;
- déploiement de fichiers de configuration ;
- automatisation de tâches d'administration.

---

## Pourquoi Ansible ?

Ansible permet de décrire l'état attendu d'une machine à l'aide de playbooks YAML.

Il repose notamment sur :

- un **control node** sur lequel Ansible est installé ;
- un **inventory** contenant les machines à administrer ;
- des **playbooks** décrivant les tâches à appliquer ;
- une connexion SSH vers les machines distantes.

L'un de ses principaux intérêts est l'idempotence :

```text
Configuration déjà conforme
        ↓
Aucune modification nécessaire

Configuration non conforme
        ↓
Ansible applique uniquement les changements nécessaires
```

---

## Projets disponibles

### Linux Hardening

Automatisation d'une configuration de sécurité Linux de base.

Le playbook permet notamment de :

- durcir la configuration SSH ;
- appliquer les permissions attendues sur des fichiers sensibles ;
- installer et configurer UFW ;
- gérer les règles firewall ;
- mettre à jour les paquets système.

Le projet est associé à un script d'audit permettant de vérifier l'état de la machine avant et après remédiation.

👉 [Voir le projet Linux Hardening](./linux-hardening/)

---

## Exemple d'architecture

```text
Control node
    │
    │ SSH
    ▼
Managed node 1
Managed node 2
Managed node 3
```

Le control node exécute les playbooks sur les machines définies dans l'inventory.

---

## Concepts Ansible utilisés

Les projets de cette section permettent de travailler sur :

- inventories ;
- playbooks YAML ;
- modules Ansible ;
- handlers ;
- variables ;
- privilèges avec `become` ;
- gestion de fichiers ;
- gestion de paquets ;
- gestion de services ;
- idempotence ;
- administration distante via SSH.

---

## Structure

```text
ansible/
├── README.md
└── linux-hardening/
    ├── README.md
    ├── inventory.ini
    └── hardening.yaml
```

Cette structure pourra évoluer avec de nouveaux projets.

Exemples :

```text
ansible/
├── linux-hardening/
├── user-management/
├── package-management/
└── service-deployment/
```

---

## Utilisation générale

Vérifier la syntaxe d'un playbook :

```bash
ansible-playbook -i inventory.ini playbook.yaml --syntax-check
```

Tester la communication avec les machines :

```bash
ansible all -i inventory.ini -m ping
```

Exécuter un playbook :

```bash
ansible-playbook -i inventory.ini playbook.yaml
```

---

## Sécurité

L'utilisation d'Ansible pour administrer des machines distantes nécessite de porter une attention particulière à :

- la gestion des clés SSH ;
- les privilèges `sudo` ;
- la protection des fichiers d'inventory ;
- la gestion des secrets ;
- la validation des configurations avant application ;
- les risques de perte d'accès lors de modifications SSH ou firewall.

Les mots de passe et autres secrets ne doivent pas être stockés en clair dans le dépôt Git.

---

## Ce que cette section met en pratique

Cette section permet de travailler sur :

- administration Linux ;
- Infrastructure as Code ;
- automatisation ;
- configuration management ;
- sécurité système ;
- déploiement reproductible ;
- gestion de plusieurs machines ;
- validation de configuration.

---

## Notes

Les projets présents ici sont conçus comme des exercices pratiques et des démonstrations de compétences.

Ils doivent être adaptés avant toute utilisation sur un environnement de production.
