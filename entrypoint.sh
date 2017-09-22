#!/bin/bash

# WORKDIR $CATALINA_HOME

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

rm -f $P12_FILE
rm -f $JKS_FILE

# convert PEM to PKCS12

openssl pkcs12 -export \
  -in $LETSENCRYPT_CERT_DIR/fullchain.pem \
  -inkey $LETSENCRYPT_CERT_DIR/privkey.pem \
  -name $KEY_ALIAS \
  -out $P12_FILE \
  -password pass:$PKCS12_PASSWORD

# import PKCS12 into JKS

keytool -importkeystore \
  -alias $KEY_ALIAS \
  -destkeypass $JKS_KEY_PASSWORD \
  -destkeystore $JKS_FILE \
  -deststorepass $JKS_STORE_PASSWORD \
  -srckeystore $P12_FILE \
  -srcstorepass $PKCS12_PASSWORD \
  -srcstoretype PKCS12

# change server configuration

xsltproc \
  --output conf/server.xml \
  --stringparam http.proxyName $HTTP_PROXY_NAME \
  --stringparam http.proxyPort $HTTP_PROXY_PORT \
  --stringparam http.redirectPort $HTTP_REDIRECT_PORT \
  --stringparam https.port $HTTPS_PORT \
  --stringparam https.maxThreads $HTTPS_MAX_THREADS \
  --stringparam https.clientAuth $HTTPS_CLIENT_AUTH \
  --stringparam https.proxyName $HTTPS_PROXY_NAME \
  --stringparam https.proxyPort $HTTPS_PROXY_PORT \
  --stringparam https.keystoreFile $JKS_FILE \
  --stringparam https.keystorePass $JKS_KEY_PASSWORD \
  --stringparam https.keyAlias $KEY_ALIAS \
  --stringparam https.keyPass $JKS_STORE_PASSWORD \
  conf/letsencrypt-tomcat.xsl \
  conf/server.xml

# run Tomcat

catalina.sh run