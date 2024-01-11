!#/bin/bash

# Clone or update the repository
if [ -d "Mobile-Security-Framework-MobSF" ]; then
    cd "Mobile-Security-Framework-MobSF"
    git pull
else
    git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
fi

# Install
docker compose up

# Run
