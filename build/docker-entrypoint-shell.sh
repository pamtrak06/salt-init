#!/bin/bash
set -e

# Function to display colored logs and write to the log file
log() {
    local level="$1"
    shift
    local message="$@"
    local log_message

    case "$level" in
        "INFO") log_message="${GREEN}[INFO] ${message}${RESET}" ;;
        "WARNING") log_message="${YELLOW}[WARNING] ${message}${RESET}" ;;
        "ERROR") log_message="${RED}[ERROR] ${message}${RESET}" ;;
        "DEBUG") log_message="${BLUE}[DEBUG] ${message}${RESET}" ;;
        *) log_message="[UNKNOWN] $message" ;;
    esac

    # Output to console and log file
    echo -e "$log_message"
    #echo "[$(date '+%Y-%m-%d %H:%M:%S')] $level: $message" >> "$LOG_FILE"
}

add_if_not_exists() {
    local file="$1"
    local keyword="$2"
    local line="$3"
    local comment="$4"
    
    if [ -z "$(grep "^$keyword:" "$file")" ]; then
        echo "$line" >> "$file"
        echo "$comment" >> "$file"
        log "INFO" "Added '$line' to $file"
    else
        log "INFO" "'$keyword:' already exists in $file. Skipping addition."
    fi
}

# Exécution en fonction du type de composant Salt
if [ "$SALT_NODE_TYPE" = "MASTER" ]; then
    echo "Starting Salt Master..."
    exec salt-master -l debug
elif [ "$SALT_NODE_TYPE" = "SYNDIC" ]; then
    comment="# Sets the unique identifier for the minion, which is typically derived from the hostname of the machine."
    add_if_not_exists /etc/salt/minion.d/minion.conf "id:" "id: $SALT_HOSTNAME" "$comment"
    echo "Starting Salt Syndic..."
    exec salt-master -l debug
    exec salt-syndic -l debug
    exec salt-minion -l debug
elif [ "$SALT_NODE_TYPE" = "MINION" ]; then
    add_if_not_exists /etc/salt/minion.d/minion.conf "id:" "id: $(hostname)"
    echo "Starting Salt Minion..."
    exec salt-minion -l debug
else
    echo "Runtime Error: Invalid SALT_NODE_TYPE. Must be either MASTER, SYNDIC or MINION."
    exit 1
fi