# Désactivation d'IPv6 sur un serveur Linux

## 📌 Présentation

Dans certains environnements, IPv6 n'est pas utilisé.

Lorsqu'il n'est pas nécessaire, sa désactivation peut permettre de simplifier la configuration réseau et d'éviter de conserver actif un protocole qui n'est pas exploité.

> ⚠️ Désactiver IPv6 n'est pas une mesure de sécurité universelle. Cette décision doit être prise en fonction de l'architecture, des dépendances applicatives et des besoins du réseau.

---

## 🎯 Objectifs

- désactiver IPv6 au niveau du noyau avec `sysctl` ;
- désactiver la configuration IPv6 via Netplan ;
- vérifier que les interfaces ne disposent plus d'adresses IPv6 ;
- documenter les précautions à prendre avant la désactivation.

---

## 1. Vérifier l'utilisation actuelle d'IPv6

```bash
ip -6 addr
```

Afficher les routes IPv6 :

```bash
ip -6 route
```

---

## 2. Désactiver IPv6 avec sysctl

Éditer :

```text
/etc/sysctl.conf
```

Ajouter :

```text
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

Appliquer :

```bash
sudo sysctl -p
```

Vérifier :

```bash
sysctl net.ipv6.conf.all.disable_ipv6
sysctl net.ipv6.conf.default.disable_ipv6
```

Une valeur `1` indique que le paramètre de désactivation est actif.

---

## 3. Adapter Netplan

Si le serveur utilise Netplan, éditer le fichier concerné, par exemple :

```text
/etc/netplan/01-netcfg.yaml
```

Ajouter ou adapter dans la bonne interface :

```yaml
dhcp6: false
link-local: []
```

> ⚠️ Le nom du fichier et la structure YAML dépendent de la configuration du serveur. Il ne faut pas remplacer le reste de la configuration réseau.

Tester de préférence avec :

```bash
sudo netplan try
```

Puis appliquer si nécessaire :

```bash
sudo netplan apply
```

> Sur un serveur distant, une erreur Netplan peut provoquer une perte de connectivité.

---

## 4. Vérifier la désactivation

```bash
ip a
```

Puis :

```bash
ip -6 addr
```

Selon la configuration appliquée, les interfaces concernées ne doivent plus disposer d'adresses IPv6 actives.

---

## 🔐 Sécurité et points d'attention

Désactiver IPv6 peut être pertinent lorsque :

- IPv6 n'est pas utilisé dans l'infrastructure ;
- aucun service ne dépend d'IPv6 ;
- l'objectif est de réduire la complexité opérationnelle ;
- le protocole ne fait pas partie de l'architecture réseau prévue.

Il ne faut cependant pas le désactiver automatiquement uniquement au motif de « renforcer la sécurité ».

Avant toute modification, vérifier :

- les dépendances applicatives ;
- les outils de supervision ;
- la résolution DNS ;
- les services écoutant en IPv6 ;
- les besoins futurs de l'infrastructure.

Une autre approche consiste à conserver IPv6 actif tout en appliquant des règles de filtrage adaptées.

---

## 🔄 Retour arrière

Pour réactiver IPv6 via `sysctl` :

```text
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
```

Puis :

```bash
sudo sysctl -p
```

Adapter également Netplan si `dhcp6` ou les adresses link-local avaient été désactivés.

---

## 📌 Points clés

- **Contexte :** la désactivation d'IPv6 doit répondre à un besoin réel.
- **Sysctl :** permet d'agir au niveau du noyau.
- **Netplan :** permet d'éviter une configuration IPv6 sur les interfaces concernées.
- **Validation :** vérifier avec `ip -6 addr`.
- **Sécurité :** désactiver IPv6 ne remplace pas une politique de filtrage réseau.
