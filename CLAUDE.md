# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository provides a Docker image that combines Apache Tomcat with Let's Encrypt HTTPS certificates. It automates the conversion of Let's Encrypt PEM certificates to Java keystores (JKS) and dynamically configures Tomcat's `server.xml` using XSLT transformations.

## Architecture

### Certificate Conversion Flow

The entrypoint script (`entrypoint.sh`) performs certificate conversion on container startup:

1. Validates required environment variables (`LETSENCRYPT_CERT_DIR`, `PKCS12_PASSWORD`, `JKS_KEY_PASSWORD`, `JKS_STORE_PASSWORD`)
2. Converts Let's Encrypt PEM certificates to PKCS12 format using OpenSSL
3. Imports PKCS12 into Java Keystore (JKS) format using keytool
4. Transforms Tomcat's `server.xml` configuration using XSLT
5. Starts Tomcat with `catalina.sh run`

### Dynamic Configuration via XSLT

The `letsencrypt-tomcat.xsl` stylesheet dynamically modifies Tomcat's `server.xml` based on environment variables:

- **HTTP Connector**: Conditionally enabled/disabled, with proxy settings and compression
- **HTTPS Connector**: Adds SSL/TLS configuration with keystore settings when enabled
- **RemoteIpValve**: Optional configuration for X-Forwarded headers when behind a proxy

The XSLT transformation is executed by `xsltproc` with environment variables passed as string parameters.

## Building and Testing

### Build Docker Image

```bash
docker build -t atomgraph/letsencrypt-tomcat .
```

### Run Container

```bash
docker run \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -e LETSENCRYPT_CERT_DIR=/etc/letsencrypt \
  -e PKCS12_PASSWORD=<password> \
  -e JKS_KEY_PASSWORD=<password> \
  -e JKS_STORE_PASSWORD=<password> \
  atomgraph/letsencrypt-tomcat
```

### Test XSLT Transformation

To test XSLT changes without building the full image:

```bash
xsltproc \
  --stringparam http true \
  --stringparam http.port 8080 \
  --stringparam https true \
  --stringparam https.port 8443 \
  --stringparam https.keystoreFile letsencrypt.jks \
  --stringparam https.keystorePass <password> \
  --stringparam https.keyAlias letsencrypt \
  --stringparam https.keyPass <password> \
  letsencrypt-tomcat.xsl /path/to/server.xml
```

## CI/CD

GitHub Actions workflow (`.github/workflows/image.yml`) triggers on git tags:

- Builds multi-platform images (linux/amd64, linux/arm64)
- Pushes to Docker Hub with tags: `latest`, `MAJOR.MINOR.PATCH`, `MAJOR.MINOR`, `MAJOR`
- Uses QEMU for cross-platform builds

## Key Files

- **Dockerfile**: Base image from `tomcat:10.1.34-jdk17`, installs xsltproc
- **entrypoint.sh**: Certificate conversion and Tomcat configuration script
- **letsencrypt-tomcat.xsl**: XSLT stylesheet for server.xml transformation

## Environment Variables

All configuration is done through environment variables. See README.md for the full list of supported variables for HTTP/HTTPS connectors.

Required variables:
- `LETSENCRYPT_CERT_DIR`: Path to Let's Encrypt certificates
- `PKCS12_PASSWORD`: Password for PKCS12 keystore
- `JKS_KEY_PASSWORD`: Password for JKS key
- `JKS_STORE_PASSWORD`: Password for JKS store

## XSLT Parameter Naming Convention

Parameters in the XSLT stylesheet use dot notation (e.g., `Connector.port.http`, `Connector.keystoreFile.https`), while the entrypoint script converts environment variables with underscores (e.g., `HTTP_PORT`, `HTTPS_PORT`) to the corresponding XSLT parameter names with dots and prefixes.
