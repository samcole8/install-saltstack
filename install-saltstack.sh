#!/bin/bash
set -e


# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Ensure keyrings directory exists
if [ ! -d "/etc/apt/keyrings" ]; then
  echo "Creating /etc/apt/keyrings directory..."
  mkdir -p /etc/apt/keyrings
else
  echo "/etc/apt/keyrings directory already exists."
fi

# Ensure salt public key is added
if [ ! -f "/etc/apt/keyrings/salt-archive-keyring.pgp" ]; then
  echo "Downloading Salt public key..."
  curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp > /dev/null
else
  echo "Salt public key already exists."
fi

# Ensure Salt repository is added to apt sources
if [ ! -f "/etc/apt/sources.list.d/salt.sources" ]; then
  echo "Adding Salt repository..."
  curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources > /dev/null
else
  echo "Salt repo configuration already exists."
fi

# Show menu
echo "Please select the components you want to install (comma separated list):"
echo "1) salt-master"
echo "2) salt-minion"
echo "3) salt-ssh"
echo "4) salt-syndic"
echo "5) salt-cloud"
echo "6) salt-api"

read -p "Enter your selection: " selection
IFS=',' read -ra choices <<< "$selection"

declare -A options
options=( 
  [1]="salt-master"
  [2]="salt-minion"
  [3]="salt-ssh"
  [4]="salt-syndic"
  [5]="salt-cloud"
  [6]="salt-api"
)

# Loop through selection items
for choice in "${choices[@]}"; do
  # Remove whitespace
  choice=$(echo "$choice" | xargs)

  if [[ -z "${options[$choice]}" ]]; then
    echo "Invalid option: $choice"
  else
    # Install corresponding package
    echo "Installing ${options[$choice]}..."
    apt-get install -y "${options[$choice]}"
  fi
done