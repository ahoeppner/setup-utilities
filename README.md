# setup-utilities
Some common actions and files needed when setting up a server for the first time.

## Certificate Authority setup
Add the CA public cert, update sshd_config, and help get a signed certificate.

```
curl https://raw.githubusercontent.com/ahoeppner/setup-utilities/main/ca_setup | sudo bash
```
