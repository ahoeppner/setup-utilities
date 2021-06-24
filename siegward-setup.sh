#!/usr/bin/env bash

# Variables
USER="siegward"
USERHOME="/home/$USER"

# Require script to be run via sudo, but not as root
if [[ $EUID -ne 0 ]]; then
  echo "Script must be run with root privilages!"
  exit 1
fi

# Add and configure siegward user access
if getent passwd $USER > /dev/null; then
  echo "$USER already exists...Skipping"
else
  echo "Adding $USER..."
  useradd -m -d $USERHOME $USER
  usermod -aG sudo $USER
  passwd $USER # manually set password for user account as final step
  echo
  echo "Done"
fi
