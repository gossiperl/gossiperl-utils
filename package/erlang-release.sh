#!/bin/bash

SCRIPT_DIRECTORY=$(dirname "${BASH_SOURCE[0]}")
. $SCRIPT_DIRECTORY/vars.sh

rm -Rf $SOURCE_ROOT
mkdir -p $SOURCE_ROOT

cd $SOURCE_ROOT

echo ""
echo " === Cloning gossiperl sources"

git clone https://github.com/gossiperl/gossiperl.git .
VERSION=$(git tag -l | sort -r | head -n 1)

echo ""
echo " === gossiperl version is ${VERSION}. Checking out the tag."

git checkout tags/$VERSION

echo ""
echo " === gossiperl at the right version"

if $RELEASE_CREATE ; then
  kill -9 $(ps aux | grep 'gossiperl.*-daemon' | grep -v grep | awk '{print $2}')
  cd rel
  rm -Rf gossiperl
  rebar create-node nodeid=gossiperl
  cd $SOURCE_ROOT
fi

echo ""
echo " === Ensuring reltool.config file"

cp $SOURCE_ROOT/rel/reltool.config.template $SOURCE_ROOT/rel/reltool.config
sed -i "s/git-semver/\"$VERSION\"/g" $SOURCE_ROOT/rel/reltool.config

echo ""
echo " === reltool.config should be complete: -> $(cat $SOURCE_ROOT/rel/reltool.config | grep $VERSION) <-"
echo " === Generating release"

. $PACKAGING_ROOT/erlang-$ERL_V/activate
rebar clean delete-deps get-deps compile generate

echo ""
echo " === Release generated"
