#!/bin/bash

echo ""
echo " === APT"

sudo rm -Rf /etc/apt/sources.list
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse" >> /etc/apt/sources.list

apt-get -y update
apt-get -y install git-core wget curl jq

VERSION=$(git ls-remote -t https://github.com/gossiperl/gossiperl.git | awk '{ print $2 }' | cut -d '/' -f 3 | sort -r | head -n 1)
URL=https://github.com/gossiperl/gossiperl/releases/download/${VERSION}/gossiperl-${VERSION}_all.deb

echo ""
echo " === Installing gossiperl $VERSION from $URL..."

wget $URL
dpkg -i gossiperl-${VERSION}_all.deb

echo ""
echo " === Installed. Verify..."

echo ""
echo " === Settings:"
cat /etc/gossiperl/settings.sh

echo ""
echo " === Start script:"
cat /etc/gossiperl/start.sh

echo ""
echo " === Start and wait script:"
cat /etc/gossiperl/start-and-wait.sh

echo ""
echo " === Stop script:"
cat /etc/gossiperl/stop.sh

echo ""
echo " === Test overlay:"
cat /etc/gossiperl/test-overlay.sh