# Health Check Script for SaltStack Architecture

This script performs a comprehensive health check on a SaltStack architecture deployed using Docker. It checks the status of the master, syndics, and minions, and generates a report in Markdown format.

## Overview

The script executes various checks to ensure that all components of the SaltStack infrastructure are running correctly and can communicate with each other. It logs the results of these checks and generates a detailed report.

## Features

- **Container Status Check**: Verifies if each Docker container is running.
- **Connectivity Checks**: Tests connectivity between syndics and the master using ping and Salt commands.
- **Key Management**: Checks if keys are accepted by the master.
- **Service Status**: Confirms that Salt services (master, minion, syndic) are active.
- **Log Analysis**: Reviews logs for errors or warnings.
- **Firewall Checks**: Ensures that necessary ports (4505 and 4506) are open.
- **Configuration Verification**: Checks if the minion configuration file has the correct master address.

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/pamtrak06/salt-init.git
   cd salt-init
  ```
2. Set up your environment variables in docker-compose-env.sh.
3. Check usage of init script:
   ```bash
   ./docker-compose-init.sh -h
  ```
3. Run the init script with options:
   ```bash
   ./docker-compose-init.sh -c -x
  ```
4. Check the generated report:
After execution :
- log will be generated in the _logs directory with a timestamped lines.
- salt configuration files export will be present in the _exports directory.
- report will be generated in the _reports directory with a timestamped filename.

## Functions of ./health_check.sh

### `usage()`
Displays usage information for the script, including how to run it and what optional arguments it accepts.

### `cleanup()`
Handles cleanup operations when the script is terminated, including finalizing the report.

### `log(level, message)`
Outputs colored log messages to both the console and a log file. Levels include INFO, WARNING, ERROR, and DEBUG.

### `escape_pipes(string)`
Escapes pipe characters in strings to ensure proper Markdown formatting in the report.

### `log_report(test, command, output, result)`
Adds a new entry to the report, including the test name, command executed, output, and result.

### `check_container(container)`
Verifies if a specified Docker container is running. If not, it attempts to start the container.

### `check_connectivity(node, node_type)`
Checks connectivity between Salt components. If connection fails, it performs additional diagnostics including key checks, configuration verification, and service restarts.

## Health Checks

The script performs the following health checks:

1. **Communication between syndics and master**
   - Ping test
   - Salt command test

2. **Salt key management**
   - Checking if syndic keys are accepted by the master
   - Accepting syndic keys if necessary

3. **Salt service status**
   - Verifying Salt Minion service
   - Verifying Salt Master service
   - Verifying Salt Syndic service

4. **Log analysis**
   - Checking for errors or warnings in Salt logs

5. **Firewall checks**
   - Verifying if ports 4505 and 4506 are open

6. **Minion configuration**
   - Ensuring the correct master address is set in the minion configuration file

## Report Generation

The script generates a comprehensive Markdown report containing the results of all health checks. Each check is logged with the following information:
- Test name
- Command executed
- Output of the command
- Result (Passed/Failed/Warning)

The report is saved in the `_reports` directory with a timestamp in the filename.

## Usage

Run the script with optional arguments:

```bash
./health_check.sh [<compose_prefix>] [<number_of_minions>]
```

- `<compose_prefix>`: This optional argument specifies the prefix used for naming minions. The default value is 'test'.
- `<number_of_minions>`: This optional argument defines the total number of minions to check. The default value is 3.

## Script Overview

This script performs a comprehensive health check on a SaltStack architecture deployed using Docker. It checks the status of the master, syndics, and minions, and generates a detailed report.

### Key Features

1. **Container Status Check**: Verifies if each Docker container is running.
2. **Connectivity Tests**: Checks communication between syndics and the master.
3. **Salt Key Management**: Ensures proper key acceptance.
4. **Service Status Verification**: Checks if Salt services are running correctly.
5. **Log Analysis**: Reviews Salt logs for errors or warnings.
6. **Firewall Checks**: Verifies if necessary ports are open.
7. **Configuration Validation**: Checks minion configuration files.

### Report Generation

The script generates a Markdown report containing:
- Test name
- Command executed
- Output of the command
- Result (Passed/Failed/Warning)

Reports are saved in the `_reports` directory with a timestamp in the filename.

### Logging

Detailed logs are written to a file in the `_logs` directory, named after the script with a `.log` extension.

## Main Functions

- `usage()`: Displays usage information.
- `cleanup()`: Handles cleanup operations and report generation.
- `log()`: Outputs colored log messages to console and log file.
- `log_report()`: Adds entries to the report.
- `check_container()`: Verifies and attempts to start Docker containers.
- `check_connectivity()`: Tests connectivity between Salt components.

## Dependencies

- Docker
- Docker Compose

## Contributing

Contributions to improve the script are welcome. Please submit issues or pull requests on the project repository.

## License

[Specify the license here, if applicable]