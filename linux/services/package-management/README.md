# Gestion des paquets Linux

Cette section regroupe plusieurs projets liés à la gestion et à la distribution de paquets sous Linux.

L'objectif est de documenter différentes approches utilisées pour centraliser, contrôler ou optimiser l'accès aux paquets dans une infrastructure.

## Projets

### Dépôt APT local avec Reprepro

Mise en place d'un dépôt APT local signé permettant de :

- centraliser certains paquets `.deb` ;
- contrôler les versions disponibles ;
- signer le dépôt avec GPG ;
- publier le dépôt via Apache ;
- configurer des clients Ubuntu pour utiliser ce dépôt.

👉 [Voir le projet Reprepro](./reprepro/README.md)

---

### Cache APT avec apt-cacher-ng

Mise en place d'un serveur de cache APT permettant de :

- réduire la consommation de bande passante ;
- éviter de télécharger plusieurs fois les mêmes paquets ;
- accélérer les installations et mises à jour ;
- mutualiser les téléchargements entre plusieurs machines Linux.

👉 [Voir le projet apt-cacher-ng](./apt-cacher-ng/README.md)

---

## Différence entre les deux approches

| Solution | Objectif principal |
|---|---|
| **Reprepro** | Contrôler les paquets et versions publiés dans un dépôt local |
| **apt-cacher-ng** | Mettre en cache les paquets téléchargés depuis des dépôts externes |

Ces deux solutions répondent donc à des besoins différents mais complémentaires dans la gestion des paquets Linux.
