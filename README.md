# 🛠️ Setup Scripts - Stack de déploiement VM

Collection de scripts pour automatiser la configuration et personnalisation de machines virtuelles Linux.

## 🎯 Objectif

Déployer rapidement et de manière cohérente un environnement personnalisé sur des VMs fraîches avec une approche modulaire et configurable.

## 🚀 Installation rapide

### Déploiement complet (recommandé)
```bash
curl -sSL https://raw.githubusercontent.com/Phips02/setup-scripts/main/deploy.sh | bash
```

### Installation sélective
```bash
# Cloner le repository
git clone https://github.com/Phips02/setup-scripts.git
cd setup-scripts

# Rendre les scripts exécutables
chmod +x deploy.sh scripts/**/*.sh

# Déploiement interactif
./deploy.sh --interactive

# Ou déploiement avec profil prédéfini
./deploy.sh --profile dev
```

## 📦 Modules disponibles

### 🎨 Visual - Personnalisation visuelle
- **prompt-setup.sh** : Prompt bash moderne et coloré
- **terminal-themes.sh** : Thèmes de terminal
- **fonts-install.sh** : Installation de polices développeur

### 🔒 Security - Sécurisation système
- **firewall-setup.sh** : Configuration du firewall
- **ssh-hardening.sh** : Durcissement de la configuration SSH
- **fail2ban-setup.sh** : Protection contre les attaques brute-force

### 🛠️ Tools - Outils essentiels
- **dev-tools.sh** : Git, curl, wget, vim, htop, etc.
- **monitoring.sh** : Outils de surveillance système
- **network-tools.sh** : Outils réseau et diagnostic

### ⚙️ System - Configuration système
- **timezone-setup.sh** : Configuration du fuseau horaire
- **locale-setup.sh** : Configuration des locales
- **updates-setup.sh** : Gestion des mises à jour

### 🐳 Services - Services et applications
- **docker-setup.sh** : Installation et configuration Docker
- **nginx-setup.sh** : Installation Nginx
- **database-setup.sh** : Installation MySQL/PostgreSQL

## 🔧 Utilisation avancée

### Profils prédéfinis

```bash
# Profil développement
./deploy.sh --profile dev

# Profil serveur
./deploy.sh --profile server

# Profil desktop
./deploy.sh --profile desktop
```

### Exécution sélective

```bash
# Modules spécifiques
./deploy.sh --modules "visual,tools,security"

# Script individuel
./scripts/visual/prompt-setup.sh

# Avec configuration personnalisée
./deploy.sh --config config/custom.conf
```

### Options du déployeur

```bash
./deploy.sh [OPTIONS]

Options:
  -i, --interactive     Mode interactif (sélection manuelle)
  -p, --profile PROF    Utiliser un profil prédéfini
  -m, --modules LIST    Liste des modules à installer
  -c, --config FILE     Fichier de configuration personnalisé
  -v, --verbose         Mode verbeux
  -d, --dry-run         Simulation sans exécution
  -h, --help           Afficher l'aide
```

## 📋 Profils disponibles

| Profil | Description | Modules inclus |
|--------|-------------|----------------|
| **dev** | Environnement de développement | visual, tools, system, docker |
| **server** | Serveur de production | security, system, monitoring, nginx |
| **desktop** | Poste de travail | visual, tools, system |

## 🔄 Workflow recommandé

1. **VM fraîche** : Démarrer avec une installation Linux minimale
2. **Déploiement** : Lancer le script de déploiement
3. **Personnalisation** : Modifier les configs selon vos besoins
4. **Sauvegarde** : Créer un snapshot de la VM configurée

## 📝 Logs et debugging

```bash
# Logs de déploiement
tail -f logs/deploy-$(date +%Y%m%d).log

# Test des modules
./tests/test-runner.sh

# Vérification post-installation
./deploy.sh --verify
```

## 🤝 Contribution

Pour ajouter un nouveau script :

1. Créer le script dans le dossier approprié (`scripts/categorie/`)
2. Ajouter les tests correspondants (`tests/unit-tests/`)
3. Mettre à jour la configuration (`config/default.conf`)
4. Documenter dans ce README

## 📊 Compatibilité

- **Ubuntu** 20.04, 22.04, 24.04
- **Debian** 11, 12
- **CentOS** 8, 9
- **Rocky Linux** 8, 9

## 🔗 Scripts individuels

| Script | Description | Usage |
|--------|-------------|-------|
| [prompt-setup.sh](scripts/visual/prompt-setup.sh) | Prompt bash personnalisé | `./scripts/visual/prompt-setup.sh` |
| *Autres scripts à venir...* | | |

---

**Auteur** : Phips  
**Version** : 1.0  
**Licence** : MIT