#!/bin/bash

# Clone or update the repository
if [ -d Mobile-Security-Framework-MobSF ]; then
    echo ">>> Updating Mobile-Security-Framework-MobSF"
    cd Mobile-Security-Framework-MobSF
    git pull
    cd ..
else
    echo ">>> Cloning Mobile-Security-Framework-MobSF"
    git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
fi

# Change docker-compose.yml
echo ">>> Changing docker-compose.yml"
rm -f Mobile-Security-Framework-MobSF/docker-compose.yml
cp docker-compose.yml Mobile-Security-Framework-MobSF/docker-compose.yml

# Make Directory
echo ">>> Make Directory"
mkdir -p /opt/mobsf/.Mobsf
chown 9901:9901 /opt/mobsf/.Mobsf

# Install
echo ">>> Installing MobSF"
cd Mobile-Security-Framework-MobSF
docker compose up

# Run
