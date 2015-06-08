#!/bin/bash

SCRIPT_DIRECTORY=$(dirname "${BASH_SOURCE[0]}")
. $SCRIPT_DIRECTORY/vars.sh

cd $SOURCE_ROOT
VERSION=$(git tag -l | sort -r | head -n 1)

echo ""
echo " === Gossiperl version is $VERSION."
echo " === Creating a temporary deb package structure in $TEMP_DIR..."

rm -Rf $TEMP_DIR
rm -Rf $TARGET_DIR

mkdir -p $TEMP_DIR/DEBIAN
mkdir -p $TARGET_DIR

echo " === -> control file"

cat > $TEMP_DIR/DEBIAN/control <<EOF
Package: $PACKAGE
Version: $VERSION~$BUILD_TIMESTAMP
Description: $DESCRIPTION
Homepage: $HOMEPAGE
Maintainer: $MAINTAINER
Architecture: $ARCHITECTURE
Depends: curl, jq
EOF

echo " === -> preinst file"

cat > $TEMP_DIR/DEBIAN/preinst <<EOF
#!/bin/sh

mkdir -p /etc/gossiperl
mkdir -p /var/log/gossiperl

cat > /etc/gossiperl/start.sh <<'EOP'
#!/bin/bash
export HOME=$INSTALL_PATH
$INSTALL_PATH/bin/gossiperl start
EOP

cat > /etc/gossiperl/settings.sh <<'EOP'
#!/bin/bash
HOST=127.0.0.1
PORT=8080
REST_USER=\$(cat $INSTALL_PATH/lib/gossiperl-$VERSION/priv/settings.json | jq '.rest_user.username' -r)
REST_PASS=\$(cat $INSTALL_PATH/lib/gossiperl-$VERSION/priv/settings.json | jq '.rest_user.password' -r)
EOP

cat > /etc/gossiperl/start-and-wait.sh <<'EOP'
#!/bin/bash
export HOME=$INSTALL_PATH
# start gossiperl
$INSTALL_PATH/bin/gossiperl start
. /etc/gossiperl/settings.sh
# wait for the service to come up
STATUS=nil
while true; do
  STATUS=\$(curl -i -k -u \$REST_USER:\$REST_PASS https://\$HOST:\$PORT/overlays | head -n 1)
  sleep 2
  if [[ \$STATUS =~ .*200\\ OK*. ]]; then
    break
  fi
done
/bin/sleep 1
curl -k -u \$REST_USER:\$REST_PASS https://\$HOST:\$PORT/overlays | jq '.'
EOP

cat > /etc/gossiperl/test-overlay.sh <<'EOP'
#!/bin/bash
. /etc/gossiperl/settings.sh
curl -i -k -u \$REST_USER:\$REST_PASS \\
     -X POST \\
     -H 'Contetnt-Type: application/json; charset=utf-8' \\
     -d "{ \\"ip\\": \\"0.0.0.0\\",
           \\"port\\": 6666,
           \\"rack_name\\": \\"dev_rack1\\",
           \\"racks\\": { \\"dev_rack1\\": [\\"127.0.0.1\\"] },
           \\"symmetric_key\\": \\"v3JElaRswYgxOt4b\\" }" \\
     https://\$HOST:\$PORT/overlays/gossiper_overlay_remote
/bin/sleep 1
curl -k -u \$REST_USER:\$REST_PASS https://\$HOST:\$PORT/overlays | jq '.'
EOP

cat > /etc/gossiperl/stop.sh <<'EOP'
#!/bin/bash
export HOME=$INSTALL_PATH
$INSTALL_PATH/bin/gossiperl stop
EOP

chmod +x /etc/gossiperl/settings.sh
chmod +x /etc/gossiperl/test-overlay.sh
chmod +x /etc/gossiperl/start.sh
chmod +x /etc/gossiperl/start-and-wait.sh
chmod +x /etc/gossiperl/stop.sh

EOF
chmod 0775 $TEMP_DIR/DEBIAN/preinst

echo " === -> postrm file"

cat > $TEMP_DIR/DEBIAN/postrm <<EOF
#!/bin/sh
rm -Rf /etc/gossiperl
EOF
chmod 0775 $TEMP_DIR/DEBIAN/postrm

mkdir -p $TEMP_DIR/$INSTALL_PATH

echo ""
echo " === Copying all files to $TEMP_DIR/$INSTALL_PATH/$PACKAGE..."

cd $SOURCE_ROOT/rel/gossiperl
rsync -ar . $TEMP_DIR/$INSTALL_PATH

""
echo " === `find $TEMP_DIR/$INSTALL_PATH | wc -l` files and folders"

echo ""
echo " === Building a deb package..."
#DEB_FILE=$TARGET_DIR/$PACKAGE-$VERSION~${BUILD_TIMESTAMP}_$ARCHITECTURE.deb
DEB_FILE=$TARGET_DIR/${PACKAGE}-${VERSION}_${ARCHITECTURE}.deb
dpkg-deb --build -Zbzip2 $TEMP_DIR $DEB_FILE

echo " === deb package ready: $(du -h $DEB_FILE)"
