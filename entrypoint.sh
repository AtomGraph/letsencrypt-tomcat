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

export KEY_ALIAS="letsencrypt"

# remove existing keystores

rm -f $CATALINA_HOME/letsencrypt.p12
rm -f $CATALINA_HOME/letsencrypt.jks

# convert PEM to PKCS12

openssl pkcs12 -export \
  -in $LETSENCRYPT_CERT_DIR/fullchain.pem \
  -inkey $LETSENCRYPT_CERT_DIR/privkey.pem \
  -name $KEY_ALIAS \
  -out $CATALINA_HOME/letsencrypt.p12 \
  -password pass:$PKCS12_PASSWORD

# import PKCS12 into JKS

keytool -importkeystore \
  -alias $KEY_ALIAS \
  -destkeypass $JKS_KEY_PASSWORD \
  -destkeystore $CATALINA_HOME/letsencrypt.jks \
  -deststorepass $JKS_STORE_PASSWORD \
  -srckeystore $CATALINA_HOME/letsencrypt.p12 \
  -srcstorepass $PKCS12_PASSWORD \
  -srcstoretype PKCS12 \

# change server configuration

xsltproc \
  --output $CATALINA_HOME/conf/server.xml \
  --stringparam letsencrypt.keystoreFile letsencrypt.jks \
  --stringparam letsencrypt.keystorePass $JKS_KEY_PASSWORD \
  --stringparam letsencrypt.keyAlias $KEY_ALIAS \
  --stringparam letsencrypt.keyPass $JKS_STORE_PASSWORD \
  $CATALINA_HOME/conf/letsencrypt-tomcat.xsl \
  $CATALINA_HOME/conf/server.xml

# run Tomcat

catalina.sh run