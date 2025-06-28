#!/bin/bash

# =================================================================
# Setup Scripts - Déployeur principal
# Auteur: Phips
# Version: 1.0
# Description: Script de déploiement modulaire pour VMs
# =================================================================

set -euo pipefail  # Mode strict

# Variables globales
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi
LOG_DIR="$SCRIPT_DIR/logs"
CONFIG_DIR="$SCRIPT_DIR/config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/deploy-$TIMESTAMP.log"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
# Couleurs pour fonctionnalités futures (commentées)
# PURPLE='\033[0;35m'

# Variables par défaut
INTERACTIVE=false
MODULES=""
# Variables pour fonctionnalités futures (commentées)
# VERBOSE=false
# DRY_RUN=false
# PROFILE=""
# CONFIG_FILE="$CONFIG_DIR/default.conf"

# Modules disponibles
AVAILABLE_MODULES=(
    "visual:Personnalisation visuelle"
    # "security:Sécurisation système"      # À venir
    # "tools:Outils essentiels"            # À venir  
    # "system:Configuration système"       # À venir
    # "services:Services et applications"  # À venir
)

# =================================================================
# FONCTIONS UTILITAIRES
# =================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Créer le dossier de logs s'il n'existe pas
    mkdir -p "$LOG_DIR"
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "ERROR")   echo -e "${RED}✗ $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✓ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠ $message${NC}" ;;
        "INFO")    echo -e "${BLUE}ℹ $message${NC}" ;;
        *)         echo "$message" ;;
    esac
}

banner() {
    echo -e "${CYAN}"
    echo "================================================================="
    echo "🛠️  SETUP SCRIPTS - DÉPLOYEUR PRINCIPAL"
    echo "================================================================="
    echo -e "${NC}"
    log "INFO" "Démarrage du déploiement - Session: $TIMESTAMP"
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -i, --interactive     Mode interactif (recommandé)
  -m, --modules LIST    Liste des modules (ex: visual)
  -h, --help           Afficher cette aide

Exemples:
  $0 --interactive                    # Mode interactif
  $0 --modules "visual"               # Module visual uniquement

Modules disponibles:
  visual    Personnalisation visuelle (prompt, thèmes)

Modules en développement:
  security  Sécurisation système
  tools     Outils essentiels
  system    Configuration système
  services  Services et applications

EOF
}

check_requirements() {
    log "INFO" "Vérification des prérequis..."
    
    # Vérifier que nous sommes sur un système Linux
    if [[ "$(uname)" != "Linux" ]]; then
        log "ERROR" "Ce script est conçu pour Linux uniquement"
        exit 1
    fi
    
    # Vérifier les commandes essentielles
    local required_commands=("curl" "wget" "git")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log "WARNING" "$cmd non trouvé, installation des prérequis..."
            install_prerequisites
            break
        fi
    done
    
    # Créer les dossiers nécessaires
    mkdir -p "$LOG_DIR"
    
    # Donner les permissions d'exécution aux scripts
    fix_permissions
    
    log "SUCCESS" "Prérequis validés"
}

fix_permissions() {
    log "INFO" "Vérification des permissions des scripts..."
    
    if [[ -d "$SCRIPTS_DIR" ]]; then
        find "$SCRIPTS_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null
        log "SUCCESS" "Permissions des scripts corrigées"
    fi
}

install_prerequisites() {
    log "INFO" "Installation des prérequis..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y curl wget git
    elif command -v yum &> /dev/null; then
        sudo yum install -y curl wget git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y curl wget git
    else
        log "ERROR" "Gestionnaire de paquets non supporté"
        exit 1
    fi
}

# Fonction pour charger les profils (commentée pour l'instant)
# load_profile() {
#     local profile="$1"
#     local profile_file="$CONFIG_DIR/profiles/$profile.conf"
#     
#     if [[ -f "$profile_file" ]]; then
#         log "INFO" "Chargement du profil: $profile"
#         source "$profile_file"
#         MODULES="$PROFILE_MODULES"
#     else
#         log "ERROR" "Profil '$profile' non trouvé dans $profile_file"
#         exit 1
#     fi
# }

show_module_menu() {
    echo -e "${WHITE}Modules disponibles:${NC}"
    echo
    
    local i=1
    for module_info in "${AVAILABLE_MODULES[@]}"; do
        local module_name="${module_info%%:*}"
        local module_desc="${module_info##*:}"
        echo -e "${CYAN}[$i]${NC} ${YELLOW}$module_name${NC} - $module_desc"
        ((i++))
    done
    
    # Afficher les modules à venir (commentés)
    echo
    echo -e "${WHITE}À venir:${NC}"
    echo -e "${CYAN}[2]${NC} ${YELLOW}security${NC} - Sécurisation système"
    echo -e "${CYAN}[3]${NC} ${YELLOW}tools${NC} - Outils essentiels"
    echo -e "${CYAN}[4]${NC} ${YELLOW}system${NC} - Configuration système"
    echo -e "${CYAN}[5]${NC} ${YELLOW}services${NC} - Services et applications"
    
    echo
    echo -e "${WHITE}Options:${NC}"
    echo -e "${CYAN}[a]${NC} Tous les modules disponibles"
    echo -e "${CYAN}[q]${NC} Quitter"
    echo
}

interactive_mode() {
    log "INFO" "Mode interactif activé"
    
    show_module_menu
    
    echo -n "Sélectionnez les modules (ex: 1 ou 'a' pour tous disponibles): "
    read -r selection
    
    case "$selection" in
        "q"|"Q")
            log "INFO" "Déploiement annulé par l'utilisateur"
            exit 0
            ;;
        "1")
            MODULES="visual"
            ;;
        "a"|"A")
            MODULES=$(printf "%s," "${AVAILABLE_MODULES[@]}" | sed 's/:.*,/,/g' | sed 's/:.*$//' | sed 's/,$//')
            ;;
        "2"|"3"|"4"|"5")
            log "WARNING" "Module non disponible (en développement)"
            log "INFO" "Seul le module 'visual' est actuellement disponible"
            echo -n "Voulez-vous installer le module visual ? (y/N): "
            read -r confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                MODULES="visual"
            else
                log "INFO" "Déploiement annulé"
                exit 0
            fi
            ;;
        *)
            local selected_modules=()
            IFS=',' read -ra NUMBERS <<< "$selection"
            for num in "${NUMBERS[@]}"; do
                if [[ "$num" == "1" ]]; then
                    selected_modules+=("visual")
                elif [[ "$num" =~ ^[2-5]$ ]]; then
                    log "WARNING" "Module $num non disponible (en développement)"
                fi
            done
            
            if [[ ${#selected_modules[@]} -eq 0 ]]; then
                log "WARNING" "Aucun module disponible sélectionné"
                log "INFO" "Installation du module visual par défaut"
                MODULES="visual"
            else
                MODULES=$(IFS=','; echo "${selected_modules[*]}")
            fi
            ;;
    esac
    
    if [[ -z "$MODULES" ]]; then
        log "ERROR" "Aucun module sélectionné"
        exit 1
    fi
    
    log "INFO" "Modules sélectionnés: $MODULES"
}

execute_module() {
    local module="$1"
    local module_dir="$SCRIPTS_DIR/$module"
    
    if [[ ! -d "$module_dir" ]]; then
        log "WARNING" "Module '$module' non trouvé dans $module_dir"
        return 1
    fi
    
    log "INFO" "Exécution du module: $module"
    
    # Compter les scripts disponibles
    local script_count=0
    for script in "$module_dir"/*.sh; do
        [[ -f "$script" ]] && ((script_count++))
    done
    
    if [[ $script_count -eq 0 ]]; then
        log "WARNING" "Aucun script trouvé dans le module '$module'"
        return 1
    fi
    
    # Exécuter tous les scripts du module
    local script_num=0
    for script in "$module_dir"/*.sh; do
        if [[ -f "$script" ]]; then
            ((script_num++))
            local script_name=$(basename "$script")
            log "INFO" "[$script_num/$script_count] Exécution de: $script_name"
            
            # Donner les permissions si nécessaire
            chmod +x "$script" 2>/dev/null || true
            
            if bash "$script"; then
                log "SUCCESS" "$script_name terminé avec succès"
            else
                log "ERROR" "Échec de $script_name"
                return 1
            fi
        fi
    done
    
    return 0
}

deploy_modules() {
    if [[ -z "$MODULES" ]]; then
        log "ERROR" "Aucun module spécifié"
        return 1
    fi
    
    IFS=',' read -ra MODULE_LIST <<< "$MODULES"
    local total_modules=${#MODULE_LIST[@]}
    local current=0
    local failed_modules=()
    
    log "INFO" "Déploiement de $total_modules module(s)"
    
    for module in "${MODULE_LIST[@]}"; do
        ((current++))
        echo -e "${WHITE}[${current}/${total_modules}] Module: ${YELLOW}$module${NC}"
        
        if execute_module "$module"; then
            log "SUCCESS" "Module '$module' déployé avec succès"
        else
            log "ERROR" "Échec du déploiement du module '$module'"
            failed_modules+=("$module")
        fi
        echo
    done
    
    # Vérifier s'il y a eu des échecs
    if [[ ${#failed_modules[@]} -gt 0 ]]; then
        log "ERROR" "Modules en échec: ${failed_modules[*]}"
        return 1
    fi
    
    return 0
}

main() {
    # Gérer les signaux pour afficher le résumé même en cas d'interruption
    trap 'show_final_summary "INTERRUPTED"' INT TERM
    
    banner
    
    # Vérifications préliminaires
    check_requirements
    
    # Mode interactif si aucun module spécifié
    if [[ $INTERACTIVE == true ]] || [[ -z "$MODULES" ]]; then
        interactive_mode
    fi
    
    # Charger le profil si spécifié (commenté pour l'instant)
    # if [[ -n "$PROFILE" ]]; then
    #     load_profile "$PROFILE"
    # fi
    
    # Déployer les modules
    if deploy_modules; then
        show_final_summary "SUCCESS"
    else
        show_final_summary "ERROR"
        exit 1
    fi
}

show_final_summary() {
    local status="$1"
    
    case "$status" in
        "SUCCESS")
            echo -e "${GREEN}"
            echo "================================================================="
            echo "🎉 DÉPLOIEMENT TERMINÉ AVEC SUCCÈS!"
            echo "================================================================="
            echo -e "${NC}"
            log "SUCCESS" "Déploiement terminé - Log: $LOG_FILE"
            
            echo -e "${BLUE}📝 Log détaillé:${NC} $LOG_FILE"
            echo -e "${BLUE}🔄 Pour appliquer les changements:${NC} source ~/.bashrc"
            echo -e "${BLUE}💡 Ou redémarrez votre terminal${NC}"
            ;;
        "ERROR")
            echo -e "${RED}"
            echo "================================================================="
            echo "❌ DÉPLOIEMENT ÉCHOUÉ"
            echo "================================================================="
            echo -e "${NC}"
            log "ERROR" "Déploiement échoué - Log: $LOG_FILE"
            echo -e "${BLUE}📝 Consultez les logs:${NC} $LOG_FILE"
            ;;
        "INTERRUPTED")
            echo -e "${YELLOW}"
            echo "================================================================="
            echo "⚠️  DÉPLOIEMENT INTERROMPU"
            echo "================================================================="
            echo -e "${NC}"
            log "WARNING" "Déploiement interrompu - Log: $LOG_FILE"
            ;;
    esac
}

# =================================================================
# GESTION DES ARGUMENTS
# =================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -m|--modules)
            MODULES="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        # Options avancées (commentées pour l'instant)
        # -p|--profile)
        #     PROFILE="$2"
        #     shift 2
        #     ;;
        # -c|--config)
        #     CONFIG_FILE="$2"
        #     shift 2
        #     ;;
        # -v|--verbose)
        #     VERBOSE=true
        #     shift
        #     ;;
        # -d|--dry-run)
        #     DRY_RUN=true
        #     shift
        #     ;;
        *)
            log "ERROR" "Option inconnue: $1"
            echo "Utilisez --help pour voir les options disponibles"
            exit 1
            ;;
    esac
done

# Charger la configuration (commenté pour l'instant)
# if [[ -f "$CONFIG_FILE" ]]; then
#     source "$CONFIG_FILE"
# fi

# Lancer le déploiement
main "$@"