#!/usr/bin/env bash

# Variables
USER="siegward"
HOMEDIR="/home/$USER"
SSHDIR="$HOMEDIR/.ssh"
REPO="https://raw.githubusercontent.com/ahoeppner/setup-utilities/main"
KEYS="$REPO/authorized_keys"


# Check script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "Script must be run with root privilages!"
    exit 1
fi

# Check for and/or create .ssh folder in home directory
echo -n "Creating .ssh directory if necessary..."
if [ ! -d "$SSHDIR" ]; then
  mkdir $SSHDIR
fi
echo "done."

# Download authorized_users file from repo
curl -s -o $SSHDIR/authorized_keys $KEYS

# Change permissions to be owned by the user
echo -n "Correcting SSH configuration permissions..."
chmod 700 $SSHDIR
chmod 600 $SSHDIR/authorized_keys
chown -R $USER: $SSHDIR
echo "done."

echo "Key setup complete."

printf "\nDon't forget to setup dotfiles (one-liner):\n"
echo "git clone https://github.com/ahoeppner/dotfiles.git && cd dotfiles && ./install.sh"
echo ""
