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
    
    if [ -z "$(grep "^$keyword" "$file")" ]; then
        echo "$comment" >> "$file"
        echo "$line" >> "$file"
        log "INFO" "Added '$line' to $file"
    else
        log "INFO" "'$keyword:' already exists in $file. Skipping addition."
    fi
}

# Exécution en fonction du type de serveur Salt
if [ "$SALT_NODE_TYPE" = "MASTER" ]; then
    echo "Salt Master configuration preprocessing..."
elif [ "$SALT_NODE_TYPE" = "SYNDIC" ]; then
    echo "Salt Syndic configuration preprocessing..."
    comment="# Sets the unique identifier for the master, which is typically derived from the hostname of the machine."
    add_if_not_exists /etc/salt/master.d/master.conf "id:" "id: $SALT_HOSTNAME" "$comment"
    comment="# Sets the unique identifier for the minion, which is typically derived from the hostname of the machine."
    add_if_not_exists /etc/salt/minion.d/minion.conf "id:" "id: ${SALT_HOSTNAME}_minion" "$comment"
elif [ "$SALT_NODE_TYPE" = "MINION" ]; then
    echo "Salt Minion configuration preprocessing..."
    comment="# Sets the unique identifier for the minion, which is typically derived from the hostname of the machine."
    add_if_not_exists /etc/salt/minion.d/minion.conf "id:" "id: $SALT_HOSTNAME" "$comment"
    comment="# Sets the timeout duration (in seconds) for authentication requests between the Salt master and its minions."
    add_if_not_exists /etc/salt/minion.d/minion.conf "auth_timeout:" "auth_timeout: 5" "$comment" # to fix : salt.exceptions.SaltClientError: Unable to sign_in to master: Attempt to authenticate with the salt master failed with timeout error
else
    echo "Runtime Error: Invalid SALT_NODE_TYPE. Must be either MASTER, SYNDIC or MINION."
    exit 1
fi

supervisord -n -c /etc/supervisor/supervisord.conf
sleep 5
supervisorctl start all
supervisorctl status
exec tail -f /dev/null