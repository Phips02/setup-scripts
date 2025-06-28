#!/bin/bash

# =================================================================
# Setup Scripts - Déployeur principal
# Auteur: Phips
# Version: 1.1
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

# Variables par défaut
INTERACTIVE=false
MODULES=""

# Modules disponibles
AVAILABLE_MODULES=(
    "visual:Personnalisation visuelle"
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
    
    # Corriger les permissions du script principal
    chmod +x "$0" 2>/dev/null || true
    
    # Corriger les permissions des scripts dans le dossier scripts/
    if [[ -d "$SCRIPTS_DIR" ]]; then
        find "$SCRIPTS_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        log "SUCCESS" "Permissions des scripts corrigées"
    fi
}

install_prerequisites() {
    log "INFO" "Installation des prérequis..."
    
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y curl wget git
    elif command -v yum &> /dev/null; then
        yum install -y curl wget git
    elif command -v dnf &> /dev/null; then
        dnf install -y curl wget git
    else
        log "ERROR" "Gestionnaire de paquets non supporté"
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
    
    # Afficher les modules à venir
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
    
    local selection=""
    while [[ -z "$selection" ]]; do
        echo -n "Sélectionnez les modules (ex: 1 ou 'a' pour tous disponibles): "
        read -r selection < /dev/tty
        
        # Validation de l'entrée
        if [[ -z "$selection" ]]; then
            log "WARNING" "Veuillez faire une sélection"
            continue
        fi
    done
    
    case "$selection" in
        "q"|"Q")
            log "INFO" "Déploiement annulé par l'utilisateur"
            exit 0
            ;;
        "1")
            MODULES="visual"
            ;;
        "a"|"A")
            MODULES="visual"  # Pour l'instant, seul visual est disponible
            ;;
        "2"|"3"|"4"|"5")
            log "WARNING" "Module non disponible (en développement)"
            log "INFO" "Seul le module 'visual' est actuellement disponible"
            echo -n "Voulez-vous installer le module visual ? (y/N): "
            read -r confirm < /dev/tty
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                MODULES="visual"
            else
                log "INFO" "Déploiement annulé"
                exit 0
            fi
            ;;
        *)
            # Essayer de parser les numéros
            if [[ "$selection" =~ ^[1]$ ]]; then
                MODULES="visual"
            else
                log "WARNING" "Sélection invalide: $selection"
                log "INFO" "Installation du module visual par défaut"
                MODULES="visual"
            fi
            ;;
    esac
    
    if [[ -z "$MODULES" ]]; then
        log "ERROR" "Aucun module sélectionné"
        exit 1
    fi
    
    log "INFO" "Modules sélectionnés: $MODULES"
    
    # Confirmation avant déploiement
    echo -e "${YELLOW}Modules à installer: ${WHITE}$MODULES${NC}"
    echo -n "Continuer ? (Y/n): "
    read -r confirm < /dev/tty
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        log "INFO" "Déploiement annulé par l'utilisateur"
        exit 0
    fi
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
    
    # Détecter si on est en mode curl (pas de scripts locaux disponibles)
    if [[ ! -f "$SCRIPTS_DIR/visual/prompt-setup.sh" ]] && [[ ! -d "$SCRIPTS_DIR/visual" ]]; then
        log "INFO" "Scripts non trouvés localement - Clonage du repository..."
        clone_and_rerun
        return
    fi
    
    # Mode interactif si aucun module spécifié
    if [[ $INTERACTIVE == true ]] || [[ -z "$MODULES" ]]; then
        interactive_mode
    fi
    
    # Déployer les modules
    if deploy_modules; then
        show_final_summary "SUCCESS"
    else
        show_final_summary "ERROR"
        exit 1
    fi
}

clone_and_rerun() {
    log "INFO" "Scripts non disponibles localement - Clonage du repository..."
    
    local temp_dir="/tmp/setup-scripts-$$"
    
    # Nettoyer le dossier temporaire s'il existe
    [[ -d "$temp_dir" ]] && rm -rf "$temp_dir"
    
    # Cloner le repository
    if git clone https://github.com/Phips02/setup-scripts.git "$temp_dir"; then
        log "SUCCESS" "Repository cloné dans $temp_dir"
        
        # Se déplacer dans le dossier et relancer le script
        cd "$temp_dir"
        chmod +x deploy.sh
        
        log "INFO" "Relancement du script en mode local..."
        echo
        
        # Relancer le script localement en mode interactif
        if [[ -n "$MODULES" ]]; then
            # Si des modules sont déjà spécifiés, les utiliser
            exec ./deploy.sh --modules "$MODULES"
        else
            # Sinon, mode interactif
            exec ./deploy.sh --interactive
        fi
    else
        log "ERROR" "Échec du clonage du repository"
        log "ERROR" "Impossible de continuer sans les scripts"
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
# FONCTIONS D'AIDE
# =================================================================

show_help() {
    echo -e "${WHITE}Setup Scripts - Déployeur principal${NC}"
    echo
    echo "Usage:"
    echo "  $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -i, --interactive    Mode interactif (par défaut si aucun module spécifié)"
    echo "  -m, --modules LIST   Modules à installer (séparés par des virgules)"
    echo "  -h, --help          Afficher cette aide"
    echo
    echo "Modules disponibles:"
    echo "  visual              Personnalisation visuelle"
    echo
    echo "Exemples:"
    echo "  $0                          # Mode interactif"
    echo "  $0 -m visual               # Installer uniquement le module visual"
    echo "  $0 --modules visual         # Même chose avec option longue"
    echo
    echo "Pour utilisation avec curl:"
    echo "  curl -sSL https://raw.githubusercontent.com/Phips02/setup-scripts/main/deploy.sh | bash -s -- -m visual"
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
        *)
            log "ERROR" "Option inconnue: $1"
            echo "Utilisez --help pour voir les options disponibles"
            exit 1
            ;;
    esac
done

# Si aucun module spécifié, activer le mode interactif
if [[ -z "$MODULES" ]]; then
    INTERACTIVE=true
fi

# Lancer le déploiement
main "$@"