#!/bin/bash
set -e

# Configure file /etc/salt/master for master node
configure_master() {
    mv /etc/salt/master /etc/salt/master.template
    cp salt_master_master /etc/salt/master.d/master.conf
}

# Configure file /etc/salt/minion for minion node
configure_minion() {
    mv /etc/salt/minion /etc/salt/minion.template

    # Specify multiple syndics as masters in the /etc/salt/minion file
    # Load balancing between the two syndics (options random_master, master_type)
    echo "# Specifies the hostname or IP address of the Salt master that the minion will connect to for commands and configurations." > /etc/salt/minion.d/minion.conf
    echo "master:" >> /etc/salt/minion.d/minion.conf
    echo "  - salt_syndic1" >> /etc/salt/minion.d/minion.conf
    echo "  - salt_syndic2" >> /etc/salt/minion.d/minion.conf
    
    echo "# Enables load balancing by allowing the minion to randomly select a master from a list of configured masters." >> /etc/salt/minion.d/minion.conf
    echo "random_master: True" >> /etc/salt/minion.d/minion.conf

    echo "# Defines the type of master connection, which can be 'str' for a string-based connection or other types as specified in the configuration." >> /etc/salt/minion.d/minion.conf
    echo "master_type: failover" >> /etc/salt/minion.d/minion.conf

    # echo "master_port: 4506" >> /etc/salt/minion.d/minion.conf
    # echo "user: root" >> /etc/salt/minion.d/minion.conf
    # echo "pki_dir: /etc/salt/pki/minion" >> /etc/salt/.d/minion.conf
    # echo "cachedir: /var/cache/salt/minion" >> /etc/salt/minion.d/minion.conf
    # echo "log_level: error" >> /etc/salt/minion.d/minion.conf
    # echo "verify_env: True" >> /etc/salt/minion.d/minion.conf
    # echo "sudo_user: root" >> /etc/salt/minion.d/minion.conf
}

# Configure file /etc/salt/master for syndic node
configure_syndic() {
    mv /etc/salt/master /etc/salt/master.template
    
    echo "# Defines the name of the Salt master that the syndics will communicate with."
    echo "syndic_master: $SALT_MASTER_NAME" >> /etc/salt/master.d/master.conf
    
    echo "# Specifies the port number used by the Salt syndic to connect to the Salt master."
    echo "syndic_master_port: 4506" >> /etc/salt/master.d/master.conf
    
    # echo "syndic_log_file: /var/log/salt/syndic" >> /etc/salt/master.d/master.conf
    # echo "syndic_pidfile: /var/run/salt-syndic.pid" >> /etc/salt/master.d/master.conf
    
    echo "# Enable auto-acceptance of minion keys" >> /etc/salt/master.d/master.conf
    echo "auto_accept: True" >> /etc/salt/master.d/master.conf

    echo "# Enables ordered communication between multiple Salt masters like (syndics)" >> /etc/salt/master.d/master.conf
    echo "order_masters: True" >> /etc/salt/master.d/master.conf

    echo "# This defines how long the master should wait for syndics to respond." >> /etc/salt/master.d/master.conf
    echo "syndic_wait: 30" >> /etc/salt/master.d/master.conf
    
    echo "# This defines the location of Salt states files." >> /etc/salt/master.d/master.conf
    echo "file_roots:" >> /etc/salt/master.d/master.conf
    echo "  base:" >> /etc/salt/master.d/master.conf
    echo "    - /srv/salt" >> /etc/salt/master.d/master.conf
    
    mv /etc/salt/minion /etc/salt/minion.template
    echo "# Specifies the hostname or IP address of the Salt master that the minion will connect to for commands and configurations." >> /etc/salt/minion.d/minion.conf
    echo "master: $SALT_MASTER_NAME" >> /etc/salt/minion.d/minion.conf
    
    echo "# Determines how the minion/syndic retrieves files from the Salt master, with options like 'local' for local file retrieval or 'remote' for fetching files over the network." >> /etc/salt/minion.d/minion.conf
    echo "file_client: remote" >> /etc/salt/minion.d/minion.conf
    
    echo "# Sets the directory path where the minion/syndic's public and private keys are stored for secure communication with the Salt master." >> /etc/salt/minion.d/minion.conf
    echo "pki_dir: /etc/salt/pki/minion" >> /etc/salt/minion.d/minion.conf
}

# Configure depending Salt node type (master, syndic, minion)
if [ "$SALT_NODE_TYPE" = "MASTER" ]; then
    echo "Configuring Salt Master..."
    cp docker-entrypoint-shell.sh ./docker-entrypoint.sh
    rm -f supervisord-syndic.conf
    rm -f docker-entrypoint-supervisor.sh
    configure_master
elif [ "$SALT_NODE_TYPE" = "SYNDIC" ]; then
    if [ -z "$SALT_MASTER_NAME" ]; then
        echo "Build Error: SALT_MASTER_NAME environment variable is required for SYNDIC configuration."
        exit 1
    fi
    echo "Configuring Salt Syndic..."
    cp docker-entrypoint-supervisor.sh ./docker-entrypoint.sh
    rm -f docker-entrypoint-shell.sh
    cp supervisord-syndic.conf /etc/supervisor/conf.d/supervisord.conf
    configure_syndic
elif [ "$SALT_NODE_TYPE" = "MINION" ]; then
    if [ -z "$SALT_MASTER_NAME" ]; then
        echo "Build Error: SALT_MASTER_NAME environment variable is required for MINION configuration."
        exit 1
    fi
    echo "Configuring Salt Minion..."
    cp docker-entrypoint-shell.sh ./docker-entrypoint.sh
    rm -f supervisord-syndic.conf
    configure_minion
else
    echo "Build Error: Invalid SALT_NODE_TYPE. Must be either MASTER, SYNDIC or MINION."
    exit 1
fi