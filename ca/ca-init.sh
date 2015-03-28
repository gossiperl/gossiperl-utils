#!/bin/bash
CA_NAME=gossiperl_ca
INSTALL_DIR=/opt/$CA_NAME
DAYS=3650
ROOT_CERITIFICATE_DAYS=3650
ROOT_CERT_PASS=some_password_for_root_certificate_do_not_change_after_bootstrapping
DEFAULT_CRL_DAYS=7
DEFAULT_DAYS=365
DEFAULT_MD=sha256
DEFAULT_BITS=4096

AUTHORITY_KEY_IDENTIFIER=keyid:issuer
KEY_USAGE=digitalSignature,keyEncipherment
EXTENDED_KEY_USAGE=serverAuth
CRL_DISTRIBUTION_POINTS=URI:http://ca.gossiperl.com/root.crl,
ALT_NAME=gossiperl.com

DN_COMMON_NAME=localhost
DN_STATE_OR_PROVINCE_NAME=Rheinland-Pfalz
DN_COUNTRY_NAME=DE
DN_EMAIL_ADDRESS=dev@gossiperl.com
DN_ORGANIZATION_NAME=Gossiperl

echo "Update and ensure packages..."

apt-get -y update
apt-get install -y openssl

echo "Create directories..."

mkdir -p $INSTALL_DIR/private
mkdir -p $INSTALL_DIR/certs
mkdir -p $INSTALL_DIR/public

chmod 0600 $INSTALL_DIR/private
chmod 0600 $INSTALL_DIR/certs
chmod 0600 $INSTALL_DIR/public

echo "Initialise configuration files..."

if [ ! -f $INSTALL_DIR/serial ]; then
cat > $INSTALL_DIR/serial <<EOP
01
EOP
fi

if [ ! -f $INSTALL_DIR/crl_number ]; then
cat > $INSTALL_DIR/crl_number <<EOP
01
EOP
fi

touch $INSTALL_DIR/index.txt

if [ ! -f $INSTALL_DIR/openssl.cnf ]; then
cat > $INSTALL_DIR/openssl.cnf <<EOP
[ ca ]
default_ca = $CA_NAME

# ---- TO ENABLE CRL
[ crl_ext ]
# issuerAltName=issuer:copy  #this would copy the issuer name to altname
authorityKeyIdentifier = $AUTHORITY_KEY_IDENTIFIER
# ---- TO ENABLE CRL

[ $CA_NAME ]
dir = $INSTALL_DIR
unique_subject = no
certificate = \$dir/public/$CA_NAME.crt
database = \$dir/index.txt
new_certs_dir = \$dir/certs
private_key = \$dir/private/$CA_NAME.key
serial = \$dir/serial
default_crl_days = $DEFAULT_CRL_DAYS
default_days = $DEFAULT_DAYS
default_md = $DEFAULT_MD
policy = ${CA_NAME}_policy
x509_extensions = ${CA_NAME}_extensions
# ---- TO ENABLE CRL
crlnumber = \$dir/crl_number
default_crl_days = 730
# ---- TO ENABLE CRL

[ ${CA_NAME}_policy ]
commonName = supplied
stateOrProvinceName = supplied
countryName = supplied
emailAddress = supplied
organizationName = supplied
organizationalUnitName = optional

[ ${CA_NAME}_extensions ]
basicConstraints = CA:false

# ---- TO ENABLE CRL
subjectKeyIdentifier = hash
authorityKeyIdentifier = $AUTHORITY_KEY_IDENTIFIER
keyUsage = $KEY_USAGE
extendedKeyUsage = $EXTENDED_KEY_USAGE
crlDistributionPoints = $CRL_DISTRIBUTION_POINTS
subjectAltName = @alt_names
# ---- TO ENABLE CRL

[ req ]
default_bits = $DEFAULT_BITS
default_keyfile = $INSTALL_DIR/private/$CA_NAME.key
default_md = $DEFAULT_MD
prompt = no
distinguished_name = root_ca_distinguished_name
x509_extensions = root_ca_extensions

[ root_ca_distinguished_name ]
commonName = $DN_COMMON_NAME
stateOrProvinceName = $DN_STATE_OR_PROVINCE_NAME
countryName = $DN_COUNTRY_NAME
emailAddress = $DN_EMAIL_ADDRESS
organizationName = $DN_EMAIL_ADDRESS

[ root_ca_extensions ]
basicConstraints = CA:true

# ---- TO ENABLE CRL
[alt_names]
DNS.1 = $ALT_NAME
DNS.2 = *.$ALT_NAME
# ---- TO ENABLE CRL
EOP
fi

echo "Setup environment..."

if [ -z "$(cat /etc/bash.bashrc | grep OPENSSL_CONF)" ]; then
  echo OPENSSL_CONF=$INSTALL_DIR/openssl.cnf >> /etc/bash.bashrc
  . /etc/bash.bashrc
  OPENSSL_CONF=$INSTALL_DIR/openssl.cnf
  export OPENSSL_CONF
fi

echo "Root certificate..."

if [ ! -f $INSTALL_DIR/public/$CA_NAME.crt ]; then
  CURRENT=$(pwd)
  cd $INSTALL_DIR
  openssl req -x509 -newkey rsa:$DEFAULT_BITS \
              -out public/$CA_NAME.crt \
              -outform PEM \
              -days $ROOT_CERITIFICATE_DAYS \
              -passin pass:$ROOT_CERT_PASS \
              -passout pass:$ROOT_CERT_PASS \
              -config $INSTALL_DIR/openssl.cnf
  echo "CACERT: Generated self-signed root certificate."
  cd $CURRENT
else
  echo "CACERT: Skipped, Self-signed root certificate already exists."
fi

echo "Root CRL..."

if [ ! -f $INSTALL_DIR/public/root.crl ]; then
  CURRENT=$(pwd)
  cd $INSTALL_DIR
  openssl ca -config $INSTALL_DIR/openssl.cnf \
             -gencrl -out root.crl.pem \
             -passin pass:$ROOT_CERT_PASS
  openssl crl -inform PEM \
              -in root.crl.pem \
              -outform DER \
              -out public/root.crl
  rm root.crl.pem
  echo "CACERT: Generated empty CRL."
  cd $CURRENT
else
  echo "CACERT: Skipped, CRL already exists."
fi

CERT_COUNTRY=DE
CERT_STATE=Rheinland-Pfalz
CERT_LOCATION=Cologne
CERT_ORGANISATION=Gossiperl
CERT_ORGANIZATIONAL_UNIT=Gossiperl
CERT_DIRECTORY=/opt/generated
CERT_FILENAME=gossiperl
CERT_COMMON_NAME=$DN_COMMON_NAME
CERT_EMAIL=dev@gossiperl.com
CERT_PASSWORD=choose_some_strong_password_here

mkdir -p $CERT_DIRECTORY

openssl req -nodes -x509 -newkey rsa:$DEFAULT_BITS \
            -keyout $CERT_DIRECTORY/$CERT_FILENAME.key.pem \
            -out $CERT_DIRECTORY/$CERT_FILENAME.cert.pem \
            -days $DEFAULT_DAYS \
            -subj "/C=$CERT_COUNTRY/ST=$CERT_STATE/L=$CERT_LOCATION/O=$CERT_ORGANISATION/OU=$CERT_ORGANISATIONAL_UNIT/CN=$CERT_COMMON_NAME/emailAddress=$EMAIL" \
            -passin pass:$CERT_PASSWORD \
            -passout pass:$CERT_PASSWORD \
            -config $INSTALL_DIR/openssl.cnf
