#!/bin/bash

if [ -z "$LETSENCRYPT_CERT_DIR" ] ; then
    echo '$LETSENCRYPT_CERT_DIR not set'
    exit 1
fi

if [ -z "$PKCS12_PASSWORD" ] ; then
    echo '$PKCS12_PASSWORD not set'
    exit 1
fi

if [ -z "$JKS_KEY_PASSWORD" ] ; then
    echo '$JKS_KEY_PASSWORD not set'
    exit 1
fi

if [ -z "$JKS_STORE_PASSWORD" ] ; then
    echo '$JKS_STORE_PASSWORD not set'
    exit 1
fi

# convert LetsEncrypt certificates
# https://community.letsencrypt.org/t/cry-for-help-windows-tomcat-ssl-lets-encrypt/22902/4

# remove existing keystores

rm -f $CATALINA_HOME/letsencrypt.p12
rm -f $CATALINA_HOME/letsencrypt.jks

# convert PEM to PKCS12

openssl pkcs12 -export -in $LETSENCRYPT_CERT_DIR/fullchain.pem -inkey $LETSENCRYPT_CERT_DIR/privkey.pem -out $CATALINA_HOME/letsencrypt.p12 -name tomcat -password pass:$PKCS12_PASSWORD

# import PKCS12 into JKS

keytool -importkeystore -alias tomcat -srckeystore $CATALINA_HOME/letsencrypt.p12 -srcstoretype PKCS12 -srcstorepass $PKCS12_PASSWORD -deststorepass $JKS_STORE_PASSWORD -destkeypass $JKS_KEY_PASSWORD -destkeystore $CATALINA_HOME/letsencrypt.jks 

# set Tomcat properties

export CATALINA_OPTS="-Dletsencrypt.keystorePass=$JKS_KEY_PASSWORD -Dletsencrypt.keyPass=$JKS_STORE_PASSWORD"

# run Tomcat

catalina.sh run