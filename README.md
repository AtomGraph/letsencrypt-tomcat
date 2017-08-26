# letsencrypt-tomcat
Docker image combining Tomcat 8 and LetsEncrypt HTTPS certificates

https://tomcat.apache.org/tomcat-8.0-doc/ssl-howto.html

https://certbot.eff.org/docs/

Supported environment variables:
* `LETSENCRYPT_CERT_DIR`
* `PKCS12_PASSWORD`
* `JKS_KEY_PASSWORD`
* `JKS_STORE_PASSWORD`

**Not tested in production yet!**