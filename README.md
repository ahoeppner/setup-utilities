# setup-utilities
Some common actions and files needed when setting up a server for the first time.

## Certificate Authority setup
Add the CA public cert, update sshd_config, and help get a signed certificate.

```bash
sudo curl https://raw.githubusercontent.com/ahoeppner/setup-utilities/main/ca_setup | sudo bash
```

## Ubuntu Setup Script

Automate the setup of a new Ubuntu system. The script performs a series of tasks including updating and upgrading packages, installing essential utilities, setting up a user account with sudo privileges, configuring SSH, and installing bash dotfiles.

### Overview

The `ubuntu_setup.sh` script carries out the following main tasks:

1. **Updates and Upgrades Packages:** Ensures your system's package list and installed packages are updated.
2. **Installs Utilities:** Installs necessary utilities such as `curl` and `git`.
3. **User Setup:** Creates a new user named `siegward`, adds the user to the `sudo` group, and prompts for a password change.
4. **SSH Configuration:** Sets up SSH for the user `siegward`, including creating an `.ssh` directory, downloading SSH keys, and modifying the SSH config to enhance security.
5. **Bash Dotfiles Installation:** Clones a git repository containing bash dotfiles and runs an installation script to apply these configurations.

### Prerequisites

- A running Ubuntu system.
- Root access to the system.
- Internet access (obviously)

### How to Run the Script

To run the script, download it and run with bash.

```bash
wget https://raw.githubusercontent.com/ahoeppner/setup-utilities/main/ubuntu_setup.sh
chmod +x ubuntu_setup.sh
./ubuntu_setup.sh
```

