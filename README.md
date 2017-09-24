# letsencrypt-tomcat
Docker image combining Tomcat 8 and LetsEncrypt HTTPS certificates

https://tomcat.apache.org/tomcat-8.0-doc/ssl-howto.html

https://certbot.eff.org/docs/

Supported environment variables:
* `HTTP_PORT`
* `HTTP_PROXY_NAME`
* `HTTP_PROXY_PORT`
* `HTTP_REDIRECT_PORT`
* `HTTP_CONNECTION_TIMEOUT`
* `HTTPS_PORT`
* `HTTPS_MAX_THREADS`
* `HTTPS_CLIENT_AUTH`
* `HTTPS_PROXY_NAME`
* `HTTPS_PROXY_PORT`
* `JKS_FILE`
* `JKS_KEY_PASSWORD`
* `KEY_ALIAS`
* `JKS_STORE_PASSWORD`
* `P12_FILE`