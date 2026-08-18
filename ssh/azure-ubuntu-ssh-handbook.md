# Azure Ubuntu VM --- SSH Login Handbook

A practical handbook for connecting to an Azure Ubuntu VM from macOS
using SSH keys.

------------------------------------------------------------------------

## 1. SSH Concepts

SSH uses a **key pair**:

``` text
Mac
├── Private key   ~/.ssh/id_ed25519
└── Public key    ~/.ssh/id_ed25519.pub
                         │
                         ▼
Azure Ubuntu VM
└── ~/.ssh/authorized_keys
```

The **public key** is installed on the VM.

The **private key stays on your Mac** and must never be shared.

------------------------------------------------------------------------

## 2. Recommended SSH Key Location on Mac

Use the standard SSH directory:

``` bash
~/.ssh/
```

On macOS this is normally:

``` text
/Users/<your-username>/.ssh/
```

Create it if it does not exist:

``` bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Check it:

``` bash
ls -la ~/.ssh
```

> `.ssh` is a hidden directory, so use `ls -la`, not just `ls`.

------------------------------------------------------------------------

## 3. Generate a New SSH Key

Recommended for new keys:

``` bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "your-email@example.com"
```

When asked for a passphrase, using one is recommended for better
security.

This creates:

``` text
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

Check:

``` bash
ls -la ~/.ssh
```

------------------------------------------------------------------------

## 4. Understand the Two Files

### Private key

``` text
~/.ssh/id_ed25519
```

Never share this file.

Recommended permission:

``` bash
chmod 600 ~/.ssh/id_ed25519
```

### Public key

``` text
~/.ssh/id_ed25519.pub
```

This can be copied to Azure/Ubuntu.

View it:

``` bash
cat ~/.ssh/id_ed25519.pub
```

It normally looks like:

``` text
ssh-ed25519 AAAAC3... your-email@example.com
```

Copy the **entire single line**.

------------------------------------------------------------------------

## 5. Add the Public Key to an Azure Ubuntu VM

There are several methods.

### Method A --- Azure Portal

Use this when you cannot currently SSH into the VM.

1.  Open Azure Portal.
2.  Go to **Virtual Machines**.
3.  Select the Ubuntu VM.
4.  Open **Reset password** under the VM's Help/Support section.
5.  Choose the option to reset/update the SSH public key.
6.  Select the correct username.
7.  Paste the complete contents of:

``` bash
cat ~/.ssh/id_ed25519.pub
```

8.  Apply/update the change.

This updates the user's SSH authorization without requiring you to
already have SSH access.

------------------------------------------------------------------------

### Method B --- If You Already Have VM Access

Log into the VM using your existing authentication:

``` bash
ssh azureuser@<PUBLIC_IP>
```

Create the SSH directory:

``` bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Edit authorized keys:

``` bash
nano ~/.ssh/authorized_keys
```

Paste the public key as one complete line.

Save:

``` text
Ctrl + O
Enter
```

Exit:

``` text
Ctrl + X
```

Fix permissions:

``` bash
chmod 600 ~/.ssh/authorized_keys
```

Verify:

``` bash
cat ~/.ssh/authorized_keys
```

------------------------------------------------------------------------

### Method C --- Azure CLI

If Azure CLI is installed and you are authenticated:

``` bash
az login
```

Then:

``` bash
az vm user update \
  --resource-group <RESOURCE_GROUP> \
  --name <VM_NAME> \
  --username azureuser \
  --ssh-key-value ~/.ssh/id_ed25519.pub
```

Replace:

``` text
<RESOURCE_GROUP>
<VM_NAME>
azureuser
```

with your actual values.

------------------------------------------------------------------------

## 6. Connect from Mac

Basic command:

``` bash
ssh azureuser@<PUBLIC_IP>
```

Explicitly specify the private key:

``` bash
ssh -i ~/.ssh/id_ed25519 azureuser@<PUBLIC_IP>
```

Example:

``` bash
ssh -i ~/.ssh/id_ed25519 azureuser@20.120.50.100
```

If the private key has a custom name:

``` bash
ssh -i ~/.ssh/azure-prod azureuser@20.120.50.100
```

------------------------------------------------------------------------

## 7. First SSH Connection

The first time you connect, SSH may display:

``` text
The authenticity of host '20.120.50.100' can't be established.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Verify the server/fingerprint if appropriate, then type:

``` text
yes
```

SSH stores the host information in:

``` text
~/.ssh/known_hosts
```

------------------------------------------------------------------------

## 8. Recommended SSH Config

If you frequently connect to Azure VMs, create:

``` bash
nano ~/.ssh/config
```

Example:

``` sshconfig
Host azure-dev
    HostName 20.120.50.100
    User azureuser
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Set permissions:

``` bash
chmod 600 ~/.ssh/config
```

Now connect with:

``` bash
ssh azure-dev
```

This is preferable to repeatedly typing:

``` bash
ssh -i ~/.ssh/id_ed25519 azureuser@20.120.50.100
```

------------------------------------------------------------------------

## 9. Multiple Azure VMs

For multiple environments, use meaningful names:

``` sshconfig
Host azure-dev
    HostName <DEV_PUBLIC_IP>
    User azureuser
    IdentityFile ~/.ssh/azure-dev
    IdentitiesOnly yes

Host azure-staging
    HostName <STAGING_PUBLIC_IP>
    User azureuser
    IdentityFile ~/.ssh/azure-staging
    IdentitiesOnly yes

Host azure-prod
    HostName <PROD_PUBLIC_IP>
    User azureuser
    IdentityFile ~/.ssh/azure-prod
    IdentitiesOnly yes
```

Then:

``` bash
ssh azure-dev
ssh azure-staging
ssh azure-prod
```

------------------------------------------------------------------------

## 10. SSH Key Permissions

On Mac:

``` bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/config
```

On Ubuntu:

``` bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

If necessary:

``` bash
chown -R azureuser:azureuser ~/.ssh
```

For another user's home directory, use `sudo` and the correct username.

------------------------------------------------------------------------

## 11. Using sudo nano

For system files:

``` bash
sudo nano /path/to/file
```

Example:

``` bash
sudo nano /etc/ssh/sshd_config
```

For your own user's SSH keys, normally:

``` bash
nano ~/.ssh/authorized_keys
```

not:

``` bash
sudo nano ~/.ssh/authorized_keys
```

### Nano shortcuts

  Action                      Shortcut
  --------------------------- ------------
  Delete/cut current line     `Ctrl + K`
  Paste previously cut line   `Ctrl + U`
  Save                        `Ctrl + O`
  Confirm filename            `Enter`
  Exit                        `Ctrl + X`
  Search                      `Ctrl + W`
  Go to line                  `Ctrl + _`

### Replace entire file in nano

Open:

``` bash
sudo nano /path/to/file
```

Delete lines using:

``` text
Ctrl + K
```

Repeat until the file is empty.

Paste the new content.

Save:

``` text
Ctrl + O
Enter
```

Exit:

``` text
Ctrl + X
```

------------------------------------------------------------------------

## 12. Verify SSH Service on Ubuntu

Check:

``` bash
sudo systemctl status ssh
```

If required:

``` bash
sudo systemctl restart ssh
```

Enable SSH at boot:

``` bash
sudo systemctl enable ssh
```

Check whether SSH is listening:

``` bash
sudo ss -tlnp | grep :22
```

------------------------------------------------------------------------

## 13. Azure Network Security Group

SSH normally uses:

``` text
TCP 22
```

The Azure VM's Network Security Group must allow inbound TCP 22 from
your source IP.

In Azure Portal:

``` text
VM
→ Networking
→ Inbound port rules
→ TCP 22
```

For better security, avoid allowing:

``` text
0.0.0.0/0
```

when possible.

Prefer your own public IP or a controlled network.

------------------------------------------------------------------------

## 14. Troubleshooting

### Permission denied (publickey)

``` text
Permission denied (publickey).
```

Check:

``` bash
ssh -v -i ~/.ssh/id_ed25519 azureuser@<PUBLIC_IP>
```

More detailed:

``` bash
ssh -vvv -i ~/.ssh/id_ed25519 azureuser@<PUBLIC_IP>
```

Common causes:

-   Wrong username
-   Wrong private key
-   Public key not present in `authorized_keys`
-   Incorrect permissions
-   SSH agent selecting the wrong key
-   Azure VM was configured with a different key

------------------------------------------------------------------------

### Check which key SSH is using

``` bash
ssh -v azureuser@<PUBLIC_IP>
```

Look for lines such as:

``` text
Offering public key: /Users/<user>/.ssh/id_ed25519
```

------------------------------------------------------------------------

### Check SSH agent

List loaded keys:

``` bash
ssh-add -l
```

Add your key:

``` bash
ssh-add ~/.ssh/id_ed25519
```

If macOS Keychain integration is desired:

``` bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

------------------------------------------------------------------------

### Connection timed out

Usually check:

1.  Azure VM is running.
2.  Public IP is correct.
3.  NSG allows TCP 22.
4.  VM has network connectivity.
5.  Local/corporate network is not blocking outbound SSH.

Test port 22:

``` bash
nc -vz <PUBLIC_IP> 22
```

------------------------------------------------------------------------

### Connection refused

The VM may be reachable but SSH may not be running.

On Ubuntu:

``` bash
sudo systemctl status ssh
```

Restart:

``` bash
sudo systemctl restart ssh
```

------------------------------------------------------------------------

### Wrong public key

On Ubuntu:

``` bash
cat ~/.ssh/authorized_keys
```

Make sure the key exactly matches:

``` bash
cat ~/.ssh/id_ed25519.pub
```

from your Mac.

------------------------------------------------------------------------

## 15. Fix authorized_keys Permissions

For user `azureuser`:

``` bash
sudo chmod 700 /home/azureuser/.ssh
sudo chmod 600 /home/azureuser/.ssh/authorized_keys
sudo chown -R azureuser:azureuser /home/azureuser/.ssh
```

Then retry SSH.

------------------------------------------------------------------------

## 16. Remove a Host Key

If the VM was rebuilt and has a different SSH host fingerprint:

``` bash
ssh-keygen -R <PUBLIC_IP>
```

Example:

``` bash
ssh-keygen -R 20.120.50.100
```

Then reconnect:

``` bash
ssh azureuser@20.120.50.100
```

------------------------------------------------------------------------

## 17. Copy Files with SCP

Copy a local file to the VM:

``` bash
scp -i ~/.ssh/id_ed25519 ./file.txt azureuser@<PUBLIC_IP>:/home/azureuser/
```

Copy a file from the VM:

``` bash
scp -i ~/.ssh/id_ed25519 \
  azureuser@<PUBLIC_IP>:/home/azureuser/file.txt \
  .
```

Copy a directory:

``` bash
scp -r -i ~/.ssh/id_ed25519 ./my-folder azureuser@<PUBLIC_IP>:/home/azureuser/
```

------------------------------------------------------------------------

## 18. SSH Port Other Than 22

If SSH is configured on another port:

``` bash
ssh -p <PORT> -i ~/.ssh/id_ed25519 azureuser@<PUBLIC_IP>
```

Example:

``` bash
ssh -p 2222 -i ~/.ssh/id_ed25519 azureuser@20.120.50.100
```

The Azure NSG must also allow that port.

------------------------------------------------------------------------

## 19. Useful Ubuntu Commands After Login

Check current user:

``` bash
whoami
```

Check hostname:

``` bash
hostname
```

Check OS:

``` bash
cat /etc/os-release
```

Check IP addresses:

``` bash
ip addr
```

Check disk:

``` bash
df -h
```

Check memory:

``` bash
free -h
```

Check CPU/load:

``` bash
uptime
```

Check running services:

``` bash
systemctl --type=service --state=running
```

------------------------------------------------------------------------

## 20. Quick Daily Workflow

### On Mac

``` bash
cd ~/.ssh
ls -la
```

Check key:

``` bash
cat ~/.ssh/id_ed25519.pub
```

Test connection:

``` bash
ssh -i ~/.ssh/id_ed25519 azureuser@<PUBLIC_IP>
```

If using SSH config:

``` bash
ssh azure-dev
```

### On Ubuntu

``` bash
whoami
hostname
pwd
```

Check SSH:

``` bash
sudo systemctl status ssh
```

Check authorized key:

``` bash
cat ~/.ssh/authorized_keys
```

------------------------------------------------------------------------

## 21. Recommended File Structure

A practical setup for multiple environments:

``` text
~/.ssh/
├── config
├── known_hosts
├── id_ed25519
├── id_ed25519.pub
├── azure-dev
├── azure-dev.pub
├── azure-staging
├── azure-staging.pub
├── azure-prod
└── azure-prod.pub
```

For a small number of VMs, a single Ed25519 key is also perfectly
reasonable.

------------------------------------------------------------------------

## 22. Security Guidelines

-   Never share private keys.
-   Never commit private keys to Git.
-   Never put private keys in application repositories.
-   Prefer Ed25519 for new SSH keys.
-   Use a passphrase for important keys.
-   Keep private-key permissions restrictive.
-   Prefer SSH access from known IP addresses instead of the whole
    internet.
-   Use separate keys for important environments when practical.
-   Remove old/unneeded public keys from `authorized_keys`.
-   Use Azure Bastion, VPN, or private networking for higher-security
    environments.
-   Do not disable SSH host-key verification blindly.
-   Back up important SSH keys securely, but never put private keys in
    public cloud storage.

------------------------------------------------------------------------

## 23. Most Important Commands --- Cheat Sheet

### Create SSH directory

``` bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

### Generate key

``` bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
```

### Show public key

``` bash
cat ~/.ssh/id_ed25519.pub
```

### Connect

``` bash
ssh -i ~/.ssh/id_ed25519 azureuser@<PUBLIC_IP>
```

### Debug

``` bash
ssh -vvv -i ~/.ssh/id_ed25519 azureuser@<PUBLIC_IP>
```

### Copy file

``` bash
scp -i ~/.ssh/id_ed25519 ./file.txt azureuser@<PUBLIC_IP>:/home/azureuser/
```

### SSH config

``` bash
nano ~/.ssh/config
```

### Remove stale host key

``` bash
ssh-keygen -R <PUBLIC_IP>
```

### Ubuntu SSH status

``` bash
sudo systemctl status ssh
```

### Ubuntu authorized keys

``` bash
cat ~/.ssh/authorized_keys
```

------------------------------------------------------------------------

## 24. Recommended Standard Setup

For a new Azure Ubuntu VM from a Mac:

``` bash
# Mac
mkdir -p ~/.ssh
chmod 700 ~/.ssh

ssh-keygen -t ed25519 -f ~/.ssh/azure-dev

cat ~/.ssh/azure-dev.pub
```

Add the displayed public key to the Azure VM.

Then:

``` bash
chmod 600 ~/.ssh/azure-dev

ssh -i ~/.ssh/azure-dev azureuser@<PUBLIC_IP>
```

For convenience, add this to `~/.ssh/config`:

``` sshconfig
Host azure-dev
    HostName <PUBLIC_IP>
    User azureuser
    IdentityFile ~/.ssh/azure-dev
    IdentitiesOnly yes
```

Then:

``` bash
ssh azure-dev
```

This is the recommended workflow for regular Azure VM administration
from macOS.
