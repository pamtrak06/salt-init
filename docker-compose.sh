#!/bin/bash

# Source the configuration file
source docker-compose-env.sh

docker-compose -p $CONFIG_COMPOSE_PREFIX $@
