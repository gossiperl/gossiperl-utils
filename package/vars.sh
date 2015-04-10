#!/bin/bash

ERL_V=17.4
OPENSSL_V=1.0.1m
REBAR_V=2.0
PACKAGING_ROOT=/opt/gossiperl/packaging
STATE_ROOT=/opt/gossiperl/state
SOURCE_ROOT=/opt/gossiperl/source
RELEASE_CREATE=false

# DEB packaging
BUILD_TIMESTAMP=`TZ=UTC date +%Y%m%d%H%M`
TARGET_DIR=/vagrant/package/build
TEMP_DIR=/tmp/deb-src
INSTALL_PATH=/opt/gossiperl
ARCHITECTURE=all

PACKAGE='gossiperl'
DESCRIPTION='Gossip middleware'
HOMEPAGE='http://gossiperl.com'
MAINTAINER='Gossiperl'