# letsencrypt-tomcat
Docker image combining Tomcat and LetsEncrypt HTTPS certificates

## Usage

     docker run \
        -v /etc/letsencrypt:/etc/letsencrypt \
        -e LETSENCRYPT_CERT_DIR=/etc/letsencrypt \
        -e PKCS12_PASSWORD=whateverest \
        -e JKS_KEY_PASSWORD=whateverest \
        -e JKS_STORE_PASSWORD=whateverest \
        atomgraph/letsencrypt-tomcat

## Configuration

Supported environment variables:
* `HTTP` - enable HTTP connector? (default: `true`)
* `HTTP_PORT`
* `HTTP_PROXY_NAME`
* `HTTP_PROXY_PORT`
* `HTTP_REDIRECT_PORT`
* `HTTP_CONNECTION_TIMEOUT`
* `HTTP_COMPRESSION`
* `HTTP` - enable HTTPS connector? (default: `false`)
* `HTTPS_PORT`
* `HTTPS_MAX_THREADS`
* `HTTPS_CLIENT_AUTH`
* `HTTPS_PROXY_NAME`
* `HTTPS_PROXY_PORT`
* `HTTPS_COMPRESSION`
* `JKS_FILE`
* `JKS_KEY_PASSWORD`
* `KEY_ALIAS`
* `JKS_STORE_PASSWORD`
* `P12_FILE`

## More info

https://tomcat.apache.org/tomcat-9.0-doc/ssl-howto.html

https://certbot.eff.org/docs/
