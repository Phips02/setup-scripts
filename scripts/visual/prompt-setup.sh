#!/bin/bash

# Script de déploiement du prompt personnalisé
# Auteur: Phips
# Version: 1.0

echo "============================================"
echo "🎯 Configuration du prompt personnalisé"
echo "============================================"

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration du prompt personnalisé
CUSTOM_PS1='export PS1="\[\e[1;32m\]┌──(\[\e[m\]\[\e[1;34m\]\u\[\e[m\]\[\e[1;32m\] ► \[\e[m\]\[\e[1;34m\]\h\[\e[m\]\[\e[1;32m\])-[\[\e[m\]\[\e[38;5;214m\]\w\[\e[m\]\[\e[1;32m\]]\n└─\[\e[m\]\[\e[1;37m\]\$ \[\e[0m\]"'

# Fonction de sauvegarde
backup_bashrc() {
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}✓${NC} Sauvegarde de .bashrc créée"
    fi
}

# Fonction pour vérifier si le prompt existe déjà
check_existing_prompt() {
    if grep -q "┌──(" ~/.bashrc 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC} Un prompt personnalisé existe déjà dans .bashrc"
        read -p "Voulez-vous le remplacer ? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}ℹ${NC} Installation annulée"
            exit 0
        fi
        # Supprimer l'ancien prompt personnalisé
        sed -i '/┌──(/d' ~/.bashrc
        echo -e "${GREEN}✓${NC} Ancien prompt supprimé"
    fi
}

# Fonction principale d'installation
install_prompt() {
    echo -e "${BLUE}📝${NC} Configuration du prompt..."
    
    # Créer le fichier .bashrc s'il n'existe pas
    touch ~/.bashrc
    
    # Ajouter une ligne vide et un commentaire
    echo "" >> ~/.bashrc
    echo "# ============================================" >> ~/.bashrc
    echo "# Prompt personnalisé moderne" >> ~/.bashrc
    echo "# Couleurs: Vert (bordures) | Bleu (user/host) | Orange (répertoire)" >> ~/.bashrc
    echo "# ============================================" >> ~/.bashrc
    echo "$CUSTOM_PS1" >> ~/.bashrc
    
    echo -e "${GREEN}✓${NC} Prompt ajouté à ~/.bashrc"
}

# Fonction de test
test_prompt() {
    echo -e "${BLUE}🧪${NC} Test du nouveau prompt..."
    
    # Charger le nouveau prompt dans la session actuelle
    source ~/.bashrc
    
    echo -e "${GREEN}✓${NC} Prompt chargé avec succès!"
    echo ""
    echo -e "${YELLOW}Aperçu de votre nouveau prompt:${NC}"
    echo -e "┌──(\033[1;34m$(whoami)\033[0m \033[1;32m►\033[0m \033[1;34m$(hostname)\033[0m\033[1;32m)-[\033[38;5;214m~\033[1;32m]\033[0m"
    echo -e "\033[1;32m└─\033[1;37m\$\033[0m"
}

# Fonction d'information
show_info() {
    echo ""
    echo -e "${BLUE}ℹ${NC}  Informations sur votre prompt:"
    echo -e "   • ${GREEN}Bordures vertes${NC} : style moderne et professionnel"
    echo -e "   • ${BLUE}Nom d'utilisateur/hostname en bleu${NC} : optimisé daltoniens"
    echo -e "   • Répertoire en ${YELLOW}orange${NC} : excellent contraste"
    echo -e "   • Symbole ${GREEN}►${NC} : design moderne et dynamique"
    echo ""
    echo -e "${YELLOW}💡 Conseils:${NC}"
    echo -e "   • Redémarrez votre terminal pour voir les changements"
    echo -e "   • Le prompt sera conservé après redémarrage"
    echo -e "   • Pour restaurer l'ancien prompt: ${GREEN}cp ~/.bashrc.backup.* ~/.bashrc${NC}"
}

# Vérification des prérequis
check_requirements() {
    if [ ! -d "$HOME" ]; then
        echo -e "${RED}✗${NC} Erreur: répertoire HOME non trouvé"
        exit 1
    fi
    
    # Vérifier si on est dans un terminal compatible
    if [ -z "$TERM" ]; then
        echo -e "${YELLOW}⚠${NC} Terminal non détecté, installation possible mais non testée"
    fi
}

# Script principal
main() {
    echo -e "${BLUE}🔍${NC} Vérification des prérequis..."
    check_requirements
    
    echo -e "${BLUE}💾${NC} Création de la sauvegarde..."
    backup_bashrc
    
    echo -e "${BLUE}🔍${NC} Vérification des configurations existantes..."
    check_existing_prompt
    
    install_prompt
    test_prompt
    show_info
    
    echo ""
    echo -e "${GREEN}🎉 Installation terminée avec succès!${NC}"
    echo -e "${BLUE}👉${NC} Redémarrez votre terminal ou tapez: ${GREEN}source ~/.bashrc${NC}"
}

# Exécution du script principal
main "$@"