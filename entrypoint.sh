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

rm -f "$P12_FILE"
rm -f "$JKS_FILE"

# convert PEM to PKCS12

openssl pkcs12 -export \
  -in "$LETSENCRYPT_CERT_DIR"/fullchain.pem \
  -inkey "$LETSENCRYPT_CERT_DIR"/privkey.pem \
  -name "$KEY_ALIAS" \
  -out "$P12_FILE" \
  -password pass:"$PKCS12_PASSWORD"

# import PKCS12 into JKS

keytool -importkeystore \
  -alias "$KEY_ALIAS" \
  -destkeypass "$JKS_KEY_PASSWORD" \
  -destkeystore "$JKS_FILE" \
  -deststorepass "$JKS_STORE_PASSWORD" \
  -srckeystore "$P12_FILE" \
  -srcstorepass "$PKCS12_PASSWORD" \
  -srcstoretype PKCS12

# change server configuration

if [ -n "$HTTP_PORT" ] ; then
    HTTP_PORT_PARAM="--stringparam http.port $HTTP_PORT "
fi

if [ -n "$HTTP_PROXY_NAME" ] ; then
    HTTP_PROXY_NAME_PARAM="--stringparam http.proxyName $HTTP_PROXY_NAME "
fi

if [ -n "$HTTP_PROXY_PORT" ] ; then
    HTTP_PROXY_PORT_PARAM="--stringparam http.proxyPort $HTTP_PROXY_PORT "
fi

if [ -n "$HTTP_REDIRECT_PORT" ] ; then
    HTTP_REDIRECT_PORT_PARAM="--stringparam http.redirectPort $HTTP_REDIRECT_PORT "
fi

if [ -n "$HTTP_CONNECTION_TIMEOUT" ] ; then
    HTTP_CONNECTION_TIMEOUT_PARAM="--stringparam http.connectionTimeout $HTTP_CONNECTION_TIMEOUT "
fi

if [ -n "$HTTP_COMPRESSION" ] ; then
    HTTP_COMPRESSION_PARAM="--stringparam http.compression $HTTP_COMPRESSION "
fi

if [ -n "$HTTPS_PORT" ] ; then
    HTTPS_PORT_PARAM="--stringparam https.port $HTTPS_PORT "
fi

if [ -n "$HTTPS_MAX_THREADS" ] ; then
    HTTPS_MAX_THREADS_PARAM="--stringparam https.maxThreads $HTTPS_MAX_THREADS "
fi

if [ -n "$HTTPS_CLIENT_AUTH" ] ; then
    HTTPS_CLIENT_AUTH_PARAM="--stringparam https.clientAuth $HTTPS_CLIENT_AUTH "
fi

if [ -n "$HTTPS_PROXY_NAME" ] ; then
    HTTPS_PROXY_NAME_PARAM="--stringparam https.proxyName $HTTPS_PROXY_NAME "
fi

if [ -n "$HTTPS_PROXY_PORT" ] ; then
    HTTPS_PROXY_PORT_PARAM="--stringparam https.proxyPort $HTTPS_PROXY_PORT "
fi

if [ -n "$HTTPS_COMPRESSION" ] ; then
    HTTPS_COMPRESSION_PARAM="--stringparam https.compression $HTTPS_COMPRESSION "
fi

if [ -n "$JKS_FILE" ] ; then
    JKS_FILE_PARAM="--stringparam https.keystoreFile $JKS_FILE "
fi
if [ -n "$JKS_KEY_PASSWORD" ] ; then
    JKS_KEY_PASSWORD_PARAM="--stringparam https.keystorePass $JKS_KEY_PASSWORD "
fi

if [ -n "$KEY_ALIAS" ] ; then
    KEY_ALIAS_PARAM="--stringparam https.keyAlias $KEY_ALIAS "
fi

if [ -n "$JKS_STORE_PASSWORD" ] ; then
    JKS_STORE_PASSWORD_PARAM="--stringparam https.keyPass $JKS_STORE_PASSWORD "
fi

transform="xsltproc \
  --output conf/server.xml \
  $HTTP_PORT_PARAM \
  $HTTP_PROXY_NAME_PARAM \
  $HTTP_PROXY_PORT_PARAM \
  $HTTP_REDIRECT_PORT_PARAM \
  $HTTP_CONNECTION_TIMEOUT_PARAM \
  $HTTP_COMPRESSION_PARAM \
  $HTTPS_PORT_PARAM \
  $HTTPS_MAX_THREADS_PARAM \
  $HTTPS_CLIENT_AUTH_PARAM \
  $HTTPS_PROXY_NAME_PARAM \
  $HTTPS_PROXY_PORT_PARAM \
  $HTTPS_COMPRESSION_PARAM \
  $JKS_FILE_PARAM \
  $JKS_KEY_PASSWORD_PARAM \
  $KEY_ALIAS_PARAM \
  $JKS_STORE_PASSWORD_PARAM \
  conf/letsencrypt-tomcat.xsl \
  conf/server.xml"

eval "$transform"

# run Tomcat

catalina.sh run