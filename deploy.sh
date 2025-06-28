#!/bin/bash

# =================================================================
# Setup Scripts - Déployeur principal
# Auteur: Phips
# Version: 1.0
# Description: Script de déploiement modulaire pour VMs
# =================================================================

set -euo pipefail  # Mode strict

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variables par défaut
INTERACTIVE=false
VERBOSE=false
DRY_RUN=false
PROFILE=""
MODULES=""
CONFIG_FILE="$CONFIG_DIR/default.conf"

# Modules disponibles
AVAILABLE_MODULES=(
    "visual:Personnalisation visuelle"
    "security:Sécurisation système" 
    "tools:Outils essentiels"
    "system:Configuration système"
    "services:Services et applications"
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
        "DEBUG")   [[ $VERBOSE == true ]] && echo -e "${PURPLE}🔍 $message${NC}" ;;
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
  -i, --interactive     Mode interactif (sélection manuelle)
  -p, --profile PROF    Utiliser un profil prédéfini (dev|server|desktop)
  -m, --modules LIST    Liste des modules (ex: visual,tools,security)
  -c, --config FILE     Fichier de configuration personnalisé
  -v, --verbose         Mode verbeux
  -d, --dry-run         Simulation sans exécution
  -h, --help           Afficher cette aide

Exemples:
  $0 --interactive                    # Mode interactif
  $0 --profile dev                    # Profil développement
  $0 --modules "visual,tools"         # Modules spécifiques
  $0 --config config/custom.conf     # Configuration personnalisée

Profils disponibles:
  dev       Environnement de développement
  server    Serveur de production  
  desktop   Poste de travail

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
    
    log "SUCCESS" "Prérequis validés"
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

load_profile() {
    local profile="$1"
    local profile_file="$CONFIG_DIR/profiles/$profile.conf"
    
    if [[ -f "$profile_file" ]]; then
        log "INFO" "Chargement du profil: $profile"
        source "$profile_file"
        MODULES="$PROFILE_MODULES"
    else
        log "ERROR" "Profil '$profile' non trouvé dans $profile_file"
        exit 1
    fi
}

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
    
    echo
    echo -e "${WHITE}Options:${NC}"
    echo -e "${CYAN}[a]${NC} Tous les modules"
    echo -e "${CYAN}[q]${NC} Quitter"
    echo
}

interactive_mode() {
    log "INFO" "Mode interactif activé"
    
    show_module_menu
    
    echo -n "Sélectionnez les modules (ex: 1,3,5 ou 'a' pour tous): "
    read -r selection
    
    case "$selection" in
        "q"|"Q")
            log "INFO" "Déploiement annulé par l'utilisateur"
            exit 0
            ;;
        "a"|"A")
            MODULES=$(printf "%s," "${AVAILABLE_MODULES[@]}" | sed 's/:.*,/,/g' | sed 's/:.*$//' | sed 's/,$//')
            ;;
        *)
            local selected_modules=()
            IFS=',' read -ra NUMBERS <<< "$selection"
            for num in "${NUMBERS[@]}"; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#AVAILABLE_MODULES[@]}" ]; then
                    local module_name="${AVAILABLE_MODULES[$((num-1))]%%:*}"
                    selected_modules+=("$module_name")
                fi
            done
            MODULES=$(IFS=','; echo "${selected_modules[*]}")
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
    
    # Exécuter tous les scripts du module
    for script in "$module_dir"/*.sh; do
        if [[ -f "$script" ]]; then
            local script_name=$(basename "$script")
            log "INFO" "Exécution de: $script_name"
            
            if [[ $DRY_RUN == true ]]; then
                log "DEBUG" "[DRY-RUN] $script"
            else
                if bash "$script"; then
                    log "SUCCESS" "$script_name terminé avec succès"
                else
                    log "ERROR" "Échec de $script_name"
                    return 1
                fi
            fi
        fi
    done
}

deploy_modules() {
    if [[ -z "$MODULES" ]]; then
        log "ERROR" "Aucun module spécifié"
        exit 1
    fi
    
    IFS=',' read -ra MODULE_LIST <<< "$MODULES"
    local total_modules=${#MODULE_LIST[@]}
    local current=0
    
    log "INFO" "Déploiement de $total_modules module(s)"
    
    for module in "${MODULE_LIST[@]}"; do
        ((current++))
        echo -e "${WHITE}[${current}/${total_modules}] Module: ${YELLOW}$module${NC}"
        
        if execute_module "$module"; then
            log "SUCCESS" "Module '$module' déployé avec succès"
        else
            log "ERROR" "Échec du déploiement du module '$module'"
            exit 1
        fi
        echo
    done
}

main() {
    banner
    
    # Vérifications préliminaires
    check_requirements
    
    # Mode interactif si aucun module spécifié
    if [[ $INTERACTIVE == true ]] || [[ -z "$MODULES" && -z "$PROFILE" ]]; then
        interactive_mode
    fi
    
    # Charger le profil si spécifié
    if [[ -n "$PROFILE" ]]; then
        load_profile "$PROFILE"
    fi
    
    # Déployer les modules
    deploy_modules
    
    # Résumé final
    echo -e "${GREEN}"
    echo "================================================================="
    echo "🎉 DÉPLOIEMENT TERMINÉ AVEC SUCCÈS!"
    echo "================================================================="
    echo -e "${NC}"
    log "SUCCESS" "Déploiement terminé - Log: $LOG_FILE"
    
    echo -e "${BLUE}📝 Log détaillé:${NC} $LOG_FILE"
    echo -e "${BLUE}🔄 Pour redémarrer:${NC} sudo reboot"
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
        -p|--profile)
            PROFILE="$2"
            shift 2
            ;;
        -m|--modules)
            MODULES="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log "ERROR" "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Charger la configuration
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Lancer le déploiement
main "$@"