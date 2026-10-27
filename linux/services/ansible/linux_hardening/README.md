# Linux Hardening avec Ansible

## Présentation

Ce projet utilise **Ansible** pour appliquer automatiquement une configuration de sécurité de base sur un serveur Linux Ubuntu.

Le playbook permet de mettre une machine dans un état de configuration attendu concernant notamment :

* SSH ;
* les permissions de fichiers sensibles ;
* le pare-feu ;
* les mises à jour système.

Le projet complète le script [`linux_security_audit`](../../../security/linux_security_audit/), qui permet de vérifier l'état de sécurité de la machine avant et après l'application du playbook.

---

## Objectif

L'objectif est d'automatiser une partie du durcissement d'un serveur Linux en utilisant une approche déclarative et idempotente.

La logique utilisée est :

```text
Audit de la machine
        │
        ▼
Détection des écarts
        │
        ▼
Application du playbook Ansible
        │
        ▼
Remédiation
        │
        ▼
Nouvel audit
        │
        ▼
Validation
```

---

## Structure du projet

```text
linux-hardening/
├── README.md
├── inventory.ini
└── hardening.yaml
```

### `inventory.ini`

Contient les machines sur lesquelles le playbook doit être exécuté.

### `hardening.yaml`

Contient les différentes tâches de durcissement.

---

## Fonctionnalités

Le playbook applique actuellement les configurations suivantes.

### Durcissement SSH

Une configuration dédiée est déployée dans :

```text
/etc/ssh/sshd_config.d/00-hardening.conf
```

Elle applique :

```text
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Cela permet de :

* interdire la connexion SSH directe avec `root` ;
* désactiver l'authentification SSH par mot de passe ;
* conserver l'authentification par clé publique.

La configuration effective peut être vérifiée avec :

```bash
sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'
```

Résultat attendu :

```text
permitrootlogin no
passwordauthentication no
pubkeyauthentication yes
```

Un handler redémarre le service SSH uniquement lorsque la configuration a été modifiée.

---

## Permissions des fichiers sensibles

Le playbook vérifie et applique les permissions suivantes :

### `/etc/passwd`

```text
owner : root
group : root
mode  : 0644
```

### `/etc/shadow`

```text
owner : root
group : shadow
mode  : 0640
```

### `/etc/sudoers`

```text
owner : root
group : root
mode  : 0440
```

Ces fichiers contiennent des informations sensibles liées aux comptes, mots de passe et privilèges administratifs.

---

## Pare-feu UFW

Le playbook installe et configure UFW.

La politique appliquée est :

```text
Incoming → deny
Outgoing → allow
```

Le trafic SSH est explicitement autorisé :

```text
22/tcp → ALLOW
```

Puis UFW est activé.

La configuration peut être contrôlée avec :

```bash
ufw status verbose
```

Exemple :

```text
Status: active

Default: deny (incoming), allow (outgoing)

22/tcp      ALLOW IN    Anywhere
22/tcp (v6) ALLOW IN    Anywhere (v6)
```

> Lors d'une administration distante, l'accès SSH doit être autorisé avant l'activation du pare-feu afin d'éviter de perdre l'accès au serveur.

---

## Mises à jour système

Le playbook met à jour le cache APT :

```text
apt update
```

puis applique les mises à jour disponibles sur les paquets installés.

Cela permet de limiter l'exposition à des vulnérabilités déjà corrigées dans les versions disponibles dans les dépôts configurés.

---

## Idempotence

Ansible est conçu pour maintenir un **état attendu**.

Si la configuration est déjà correcte, une nouvelle exécution ne doit pas provoquer inutilement de modifications.

Exemple :

```text
TASK [Set permissions on /etc/passwd]
ok: [server]

TASK [Set permissions on /etc/shadow]
ok: [server]
```

`ok` indique que l'état était déjà conforme.

À l'inverse :

```text
changed: [server]
```

indique qu'Ansible a dû modifier la machine afin d'atteindre l'état demandé.

---

## Handler SSH

Le redémarrage de SSH est géré par un handler.

Le handler n'est déclenché que lorsque la configuration SSH est réellement modifiée.

Cela évite de redémarrer inutilement le service lors de chaque exécution du playbook.

---

## Prérequis

Sur la machine de contrôle :

* Ansible ;
* accès SSH vers la machine cible ;
* collection `community.general` pour la gestion d'UFW.

Vérifier Ansible :

```bash
ansible --version
```

Vérifier la collection :

```bash
ansible-doc community.general.ufw
```

Si nécessaire :

```bash
ansible-galaxy collection install community.general
```

Sur la machine cible :

* Linux Ubuntu/Debian ;
* serveur SSH ;
* Python 3 ;
* un compte permettant l'élévation de privilèges avec `sudo`.

Ansible utilise SSH par défaut pour communiquer avec les hôtes distants.

---

## Inventory local

Pour tester le playbook directement sur la machine Ansible :

```ini
[linux]
localhost ansible_connection=local
```

Tester :

```bash
ansible all -i inventory.ini -m ping
```

Résultat attendu :

```text
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## Inventory distant

Pour administrer une autre machine :

```ini
[linux]
server01 ansible_host=192.168.1.50 ansible_user=admin
```

Ansible utilisera SSH pour contacter :

```text
192.168.1.50
```

avec l'utilisateur :

```text
admin
```

Tester la connexion :

```bash
ansible linux -i inventory.ini -m ping
```

---

## Vérification du playbook

Avant chaque exécution :

```bash
ansible-playbook -i inventory.ini hardening.yaml --syntax-check
```

Puis exécuter :

```bash
ansible-playbook -i inventory.ini hardening.yaml
```

---

## Validation avec le script d'audit

Après l'application du playbook, le script `linux-security-audit` peut être utilisé pour vérifier la configuration.

Exemple :

```text
[PASS] SSH root login disabled
[PASS] SSH password authentication disabled
[PASS] SSH pubkey authentication enabled
[PASS] Only root account found
[PASS] /etc/shadow permissions and ownership are correct
[PASS] No account has an empty password
[PASS] UFW firewall is active
[PASS] nftables rules detected
[PASS] System packages are up to date
[PASS] /etc/sudoers permissions and ownership are correct
```

Cela permet de mettre en place une logique :

```text
Détection
    ↓
Remédiation
    ↓
Validation
```

---

## Sécurité lors de l'utilisation à distance

Avant de désactiver :

```text
PasswordAuthentication
```

il est impératif de vérifier que l'authentification SSH par clé publique fonctionne.

Dans le cas contraire, l'application du playbook pourrait rendre le serveur inaccessible à distance.

Il est recommandé de tester au préalable :

```bash
ssh utilisateur@serveur
```

et de confirmer que la connexion fonctionne sans authentification par mot de passe.

---

## Limites

Ce projet constitue une configuration de durcissement de base.

Il ne couvre pas notamment :

* la configuration complète de PAM ;
* les politiques avancées de mot de passe ;
* les paramètres de sécurité `sysctl` ;
* l'audit des services inutiles ;
* AppArmor ;
* les paramètres de montage ;
* la journalisation avancée ;
* `auditd` ;
* les CIS Benchmarks complets ;
* les besoins spécifiques liés au rôle du serveur.

Les paramètres doivent toujours être adaptés au contexte d'utilisation de la machine.

---

## Améliorations possibles

Le projet pourra évoluer avec :

* utilisation de variables Ansible ;
* création de rôles ;
* templates Jinja2 ;
* gestion de plusieurs distributions ;
* paramètres `sysctl` ;
* installation et configuration d'`auditd` ;
* gestion d'AppArmor ;
* politiques de mots de passe ;
* génération de rapports ;
* intégration dans un pipeline de validation.

---

## Compétences mises en pratique

Ce projet permet de travailler sur :

* Ansible ;
* YAML ;
* inventories ;
* playbooks ;
* modules Ansible ;
* handlers ;
* idempotence ;
* administration Linux ;
* SSH ;
* permissions Unix ;
* UFW / nftables ;
* APT ;
* automatisation du durcissement ;
* remédiation de configurations de sécurité.

---

## Conclusion

Ce projet montre comment automatiser une configuration de sécurité Linux de base avec Ansible.

Il est volontairement associé au projet `linux-security-audit` afin de couvrir deux approches complémentaires :

```text
linux-security-audit
→ détecter

linux-hardening-ansible
→ corriger

linux-security-audit
→ vérifier
```

L'objectif est ainsi de ne pas uniquement automatiser la configuration, mais également de pouvoir contrôler que l'état obtenu correspond bien à celui attendu.
