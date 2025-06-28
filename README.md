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

```bash
# Installation des prérequis + clonage + déploiement
curl -sSL https://raw.githubusercontent.com/Phips02/setup-scripts/main/deploy.sh | bash -s -- --interactive
```

## 🔧 Installation manuelle (recommandée)

```bash
# 1. Installer git si nécessaire
apt update && apt install -y git      # Debian/Ubuntu
# yum install -y git                  # CentOS/RHEL
# dnf install -y git                  # Fedora

# 2. Cloner le repository
git clone https://github.com/Phips02/setup-scripts.git
cd setup-scripts

# 3. Lancer le déployeur
./deploy.sh --interactive
```

## 📦 Modules disponibles

- **visual** : Personnalisation de l'apparence (prompt, thèmes)
- **security** : Sécurisation du système *(à venir)*
- **tools** : Outils essentiels *(à venir)*
- **system** : Configuration système *(à venir)*
- **services** : Services et applications *(à venir)*

## 🎛️ Options du déployeur

```bash
./deploy.sh --interactive           # Mode interactif
./deploy.sh --modules "visual"      # Module spécifique
./deploy.sh --help                  # Aide complète
```

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