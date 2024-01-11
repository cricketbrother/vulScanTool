#!/bin/bash

# Clone or update the repository
if [ -d "Mobile-Security-Framework-MobSF" ]; then
    echo ">>> Updating Mobile-Security-Framework-MobSF"
    cd "Mobile-Security-Framework-MobSF"
    git pull
else
    echo ">>> Cloning Mobile-Security-Framework-MobSF"
    git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
fi

# Install
echo ">>> Installing MobSF"
docker compose up

# Run
