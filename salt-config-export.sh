#!/bin/bash
source docker-compose-env.sh
export_path=_exports

# Creating the log file name
SCRIPT_NAME=$(basename "$0")
LOG_FILE="_logs/${SCRIPT_NAME%.sh}.log"

# Definition of color codes
RESET="\033[0m"
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
BLUE="\033[34m"

# Function to display usage information
usage() {
    echo "Usage: $0 [<compose_prefix>] [<number_of_minions>]"
    echo ""
    echo "This script exports Salt configuration files for a specified number of minions."
    echo "It takes two optional arguments:"
    echo "  <compose_prefix>      The prefix to use for naming containers (default: 'test')."
    echo "  <number_of_minions>  The total number of minions to export configurations for (default: 3)."
    echo ""
    echo "The exported configuration files will be saved in the directory: $export_path"
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi

# Setting default values
COMPOSE_PREFIX=${1:-$CONFIG_COMPOSE_PREFIX}
NUM_MINIONS=${2:-$CONFIG_NUM_MINIONS}

# Function to display colored logs and write to the log file
log() {
    local level="$1"
    shift
    local message="$@"
    local log_message

    case "$level" in
        "INFO")
            log_message="${GREEN}[INFO] ${message}${RESET}"
            ;;
        "WARNING")
            log_message="${YELLOW}[WARNING] ${message}${RESET}"
            ;;
        "ERROR")
            log_message="${RED}[ERROR] ${message}${RESET}"
            ;;
        "DEBUG")
            log_message="${BLUE}[DEBUG] ${message}${RESET}"
            ;;
        *)
            log_message="[UNKNOWN] $message"
            ;;
    esac

    echo -e "$log_message"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $level: $message" >> "$LOG_FILE"
}

# Function to export Salt configuration files
export_salt_conf() {
    local node=$1
    local node_type=$2
    log "INFO" "[$node] Exporting ${node_type} configuration..."
    mkdir -p ${export_path}/${node}_${node_type}.d/
    for file in $(docker exec ${node} ls /etc/salt/${node_type}.d/); do
        docker cp ${node}:/etc/salt/${node_type}.d/$file ${export_path}/${node}_${node_type}.d/
    done
}
rm -rf ${export_path}/*
# Export configurations for predefined components
export_salt_conf salt_master master
export_salt_conf salt_syndic1 master
export_salt_conf salt_syndic1 minion
export_salt_conf salt_syndic2 master
export_salt_conf salt_syndic2 minion

# Export configurations for dynamically generated minions
for i in $(seq 1 $NUM_MINIONS); do
    export_salt_conf "${COMPOSE_PREFIX}_salt_minion_$i" minion
done