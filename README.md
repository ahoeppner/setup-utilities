# setup-utilities
Some common actions needed when setting up a server for the first time.

keys-setup
==========
This script will populate the 'authorized_keys' file on a server with the entries in this repository. To run this script, use the following command (must be root):
```
sudo curl -s https://raw.githubusercontent.com/ahoeppner/setup-utilities/main/keys-setup.sh | bash
```
