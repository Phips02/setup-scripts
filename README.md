# 🛠️ Setup Scripts

Scripts pour automatiser la configuration de machines virtuelles Linux.

## 🎯 Actuellement disponible

### **Prompt personnalisé**
Script de personnalisation du prompt bash avec un design moderne et coloré.

```
┌──(utilisateur ► hostname)-[~/dossier]
└─$ 
```

## 🚀 Installation

### Installation rapide (prompt seul)
```bash
curl -sSL https://raw.githubusercontent.com/Phips02/setup-scripts/main/scripts/visual/prompt-setup.sh | bash
```

### Installation via le déployeur
```bash
# Cloner le repository
git clone https://github.com/Phips02/setup-scripts.git
cd setup-scripts

# Lancer le déployeur interactif
./deploy.sh --interactive
```

## 🔧 Utilisation du déployeur

Le script `deploy.sh` permet de gérer les modules de façon organisée :

```bash
# Mode interactif (recommandé)
./deploy.sh --interactive

# Installation directe du module visual
./deploy.sh --modules "visual"

# Aide
./deploy.sh --help
```

## 📁 Structure

```
setup-scripts/
├── deploy.sh                    # Script principal
├── scripts/
│   └── visual/
│       └── prompt-setup.sh      # Personnalisation du prompt
└── logs/                        # Logs de déploiement
```

## 🛠️ Ajouter un nouveau script

1. **Créer le script** dans `scripts/categorie/nouveau-script.sh`
2. **Le rendre exécutable** : `chmod +x scripts/categorie/nouveau-script.sh`
3. **Tester** : `./scripts/categorie/nouveau-script.sh`

## 📋 Prochains ajouts prévus

- **Sécurité** : Configuration firewall, SSH
- **Outils** : Installation d'outils de développement
- **Système** : Configuration timezone, locales
- **Services** : Docker, Nginx

---

**Auteur** : Phips  
**Version** : 1.0