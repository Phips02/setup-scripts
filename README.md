# 🛠️ Setup Scripts

Infrastructure modulaire pour automatiser la configuration de machines virtuelles Linux **depuis zéro**.

## 📋 Prérequis

**VM fraîche avec :**
- **Linux** (Debian, Ubuntu, CentOS, Rocky, etc.)
- **Accès root** ou sudo
- **Connexion internet**
- **curl** (généralement préinstallé)

**C'est tout !** Le script installe automatiquement les autres dépendances (git, wget, etc.)

## 🎯 Objectif

Déployer rapidement et de manière cohérente un environnement personnalisé sur des VMs fraîches avec une approche modulaire.

## 🚀 Installation rapide

### Installation automatique (module visual)
```bash
curl -sSL https://raw.githubusercontent.com/Phips02/setup-scripts/main/deploy.sh | bash
```

### Installation avec choix (recommandée)
```bash
# 1. Installer git si nécessaire
apt update && apt install -y git      # Debian/Ubuntu

# 2. Cloner et déployer
git clone https://github.com/Phips02/setup-scripts.git
cd setup-scripts
chmod +x deploy.sh
./deploy.sh --interactive
```

### Installation rapide d'un module spécifique
```bash
# Module visual uniquement (prompt personnalisé)
curl -sSL https://raw.githubusercontent.com/Phips02/setup-scripts/main/deploy.sh | bash -s -- --modules "visual"
```

## 📦 Modules disponibles

- **visual** : Personnalisation de l'apparence (prompt, thèmes)
- **security** : Sécurisation du système *(à venir)*
- **tools** : Outils essentiels *(à venir)*
- **system** : Configuration système *(à venir)*
- **services** : Services et applications *(à venir)*

## 🎛️ Options du déployeur

```bash
# Mode automatique - installe le module visual
curl -sSL [...]/deploy.sh | bash

# Module spécifique via curl
curl -sSL [...]/deploy.sh | bash -s -- --modules "visual"

# Mode interactif (nécessite git clone)
git clone https://github.com/Phips02/setup-scripts.git
cd setup-scripts
./deploy.sh --interactive

# Aide
./deploy.sh --help
```

**Note** : Le mode interactif nécessite de cloner le repository pour fonctionner correctement.

## 🎯 Modes d'utilisation

| Commande | Description | Usage |
|----------|-------------|-------|
| `curl [...]/deploy.sh \| bash` | Installation automatique du module visual | VM rapide |
| `curl [...]/deploy.sh \| bash -s -- --modules "visual"` | Installation spécifique | Sélection précise |
| `git clone && ./deploy.sh --interactive` | Mode interactif complet | Configuration personnalisée |

## 📁 Structure

```
setup-scripts/
├── deploy.sh              # Déployeur principal
├── scripts/               # Scripts par catégorie
│   ├── visual/           # Personnalisation visuelle
│   ├── security/         # Sécurisation
│   ├── tools/            # Outils
│   ├── system/           # Configuration système
│   └── services/         # Services
└── logs/                 # Logs de déploiement
```

## ➕ Ajouter un script

1. **Créer** : `scripts/categorie/mon-script.sh`
2. **Tester** : `./scripts/categorie/mon-script.sh`
3. **Déployer** : `./deploy.sh --modules "categorie"`

---

**Auteur** : Phips | **Version** : 1.0