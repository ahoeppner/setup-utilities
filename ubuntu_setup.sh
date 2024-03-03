#!/bin/bash

# TODO add a section at the beginning of the script for documentation, including a brief description, usage instructions, and any prerequisites.

# Logging function
log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $1"
}

log "Starting setup script."

# Confirm the script is being run as root privileges.
if [ "$(id -u)" != "0" ]; then
    log "This script must be run as root."
    exit 1
fi

# Validate internet connectivity before proceeding with the script.
if ! ping -c 1 google.com &> /dev/null; then
    log "Internet connection is required. Please check your connectivity."
    exit 1
fi

log "Internet connectivity confirmed."

# Install utilities
log "Installing necessary utilities."
apt-get install -y git vim htop ufw unattended-upgrades || { log "Failed to install necessary utilities."; exit 1; }

##########################
# Setup user
##########################
log "Setting up user."

# Instead of statically creating the user 'siegward', ask the user what username they would like to setup, with a suggested default of 'siegward'.
read -p "Enter the username to setup [siegward]: " USERNAME
USERNAME=${USERNAME:-siegward}

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    log "User $USERNAME already exists."
else
    # Create user and add to sudo group
    useradd -m -s /bin/bash "$USERNAME" && usermod -aG sudo "$USERNAME" || { log "Failed to create user $USERNAME."; exit 1; }
    passwd "$USERNAME"
    log "User $USERNAME created and added to sudo group. Please change the default password immediately."
fi

##########################
# Setup ssh for user
##########################
log "Setting up SSH for $USERNAME."

# Variables
USER_HOME=$(getent passwd $USERNAME | cut -d: -f6)
SSH_DIR="$USER_HOME/.ssh"

# Create .ssh directory
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chown $USERNAME:$USERNAME "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    log ".ssh directory created."
else
    log ".ssh directory already exists."
fi

# Download ssh keys
curl https://github.com/ahoeppner.keys -o "$SSH_DIR/authorized_keys" || { log "Failed to download SSH keys."; exit 1; }
chown $USERNAME:$USERNAME "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"
log "SSH keys downloaded and saved."

# Modify SSH config to disable password login
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd
log "SSH service configured and restarted."


##########################
# Local firewall and additional system settings
##########################

# Function to display current UFW rules
show_firewall_rules() {
    echo "Current UFW firewall rules:"
    ufw status numbered
}

# Introduce a UFW firewall setup with sensible defaults. Allow ssh by default.
ufw allow ssh
log "Setting up UFW - port 22 (ssh) enabled."

# Prompt for additional ports
while true; do
    show_firewall_rules
    read -p "Would you like to allow another port? (Y/N): " yn
    case $yn in
        [Yy]* ) read -p "Enter port number to allow: " portnum;
                ufw allow $portnum;
                log "Port $portnum allowed.";
                ;;
        [Nn]* ) break;;
        * ) log "Please answer yes or no.";;
    esac
done

ufw enable

# Prompt for setting up time zone and locale settings
dpkg-reconfigure tzdata
dpkg-reconfigure locales

log "Configuring automatic security updates to automatically install security patches."
# Configure automatic security updates
dpkg-reconfigure -plow unattended-upgrades

##########################
# Install bash dotfiles for user
##########################
log "Installing bash dotfiles for $USERNAME."

# Create repos directory
REPOS_DIR="$USER_HOME/repos"
if [ ! -d "$REPOS_DIR" ]; then
    mkdir -p "$REPOS_DIR"
    chown $USERNAME:$USERNAME "$REPOS_DIR"
    log "Directory ~/repos created."
else
    log "Directory ~/repos already exists."
fi

# Clone git repo
git clone https://github.com/ahoeppner/dotfiles_bash.git "$REPOS_DIR/dotfiles_bash" || { log "Failed to clone dotfiles_bash repository."; exit 1; }
chown -R $USERNAME:$USERNAME "$REPOS_DIR/dotfiles_bash"
log "dotfiles_bash repository cloned."

# Run install.sh
sudo -u $USERNAME bash "$REPOS_DIR/dotfiles_bash/install.sh" || { log "Failed to run install.sh from dotfiles_bash."; exit 1; }
log "dotfiles_bash installation script executed."

log "Setup script completed."