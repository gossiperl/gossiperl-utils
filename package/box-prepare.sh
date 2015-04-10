#!/bin/bash

SCRIPT_DIRECTORY=$(dirname "${BASH_SOURCE[0]}")
. $SCRIPT_DIRECTORY/vars.sh

mkdir -p $PACKAGING_ROOT
mkdir -p $STATE_ROOT

echo ""
echo " === APT"

if [ ! -f $STATE_ROOT/apt ]; then
  echo "Changing APT settings..."
  sudo rm -Rf /etc/apt/sources.list
  echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse" >> /etc/apt/sources.list
  echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse" >> /etc/apt/sources.list
  echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse" >> /etc/apt/sources.list
  echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse" >> /etc/apt/sources.list
  echo "APT settings changed."
  apt-get -y update
  apt-get install -y libncurses5-dev libssl-dev curl git-core build-essential
  echo -e `date` > $STATE_ROOT/apt
else
  echo "Apt already done."
fi

echo " === OpenSSL"

if [ ! -f $STATE_ROOT/openssl ]; then
  echo "Installing OpenSSL..."
  curl https://www.openssl.org/source/openssl-$OPENSSL_V.tar.gz | tar xz
  cd openssl-$OPENSSL_V
  ./config
  make
  make install
  ln -sf /usr/local/ssl/bin/openssl `which openssl`
  cd ..
  echo -e `date` > $STATE_ROOT/openssl
else
  echo "OpenSSL already done."
fi

echo ""
echo " === Kerl"

if [ ! -f $PACKAGING_ROOT/kerl ]; then
  echo "Installing Kerl..."
  cd $PACKAGING_ROOT
  curl -O https://raw.githubusercontent.com/yrashk/kerl/master/kerl
  chmod a+x kerl
else
  echo "Kerl already done"
fi

echo ""
echo " === Erlang/OTP"

if [ ! -d $PACKAGING_ROOT/erlang-$ERL_V ]; then
  echo "Installing Erlang/OTP $ERL_V..."
  mkdir -p $PACKAGING_ROOT/erlang-$ERL_V
  $PACKAGING_ROOT/kerl build  $ERL_V $ERL_V
  $PACKAGING_ROOT/kerl install $ERL_V $PACKAGING_ROOT/erlang-$ERL_V
  if [ -z "$( cat /etc/bash.bashrc | grep erlang-current )" ]; then
    echo ". $PACKAGING_ROOT/erlang-$ERL_V/activate" >> /etc/bash.bashrc
  fi
  /bin/sleep 5
else
  echo "Erlang/OTP ${ERL_V} already installed"
fi

echo ""
echo " === Activating Erlang"

chmod -R 0777 $PACKAGING_ROOT/erlang-$ERL_V # let it be executed by anybody
. $PACKAGING_ROOT/erlang-$ERL_V/activate

echo ""
echo " === Installing Rebar"

mkdir -p $PACKAGING_ROOT/rebar

if [ ! -f $PACKAGING_ROOT/rebar/rebar-$REBAR_V ]; then
  echo "Installing rebar"
  cd $PACKAGING_ROOT/rebar
  mkdir -p rebar-$REBAR_V-src
  cd rebar-$REBAR_V-src
  git clone https://github.com/basho/rebar.git .
  git fetch origin
  git checkout -b $REBAR_V origin/$REBAR_V
  /bin/sleep 5
  # bootstrap - make sure Erlang is available:
  ./bootstrap || exit 100
  echo -e "Rebar bootstrapped."
  while [ -z "$(ls -la . | grep ' rebar$')" ]; do
    echo " -> rebar build not found yet"
    /bin/sleep 1
  done
  echo -e "Rebar build found"
  cp rebar ../rebar-$REBAR_V
  cd ..
  rm -Rf rebar-$REBAR_V-src
  ln -sf $PACKAGING_ROOT/rebar/rebar-$REBAR_V $PACKAGING_ROOT/rebar/rebar-current
  ln -sf $PACKAGING_ROOT/rebar/rebar-current /usr/bin/rebar
else
  echo "Rebar already done."
fi
