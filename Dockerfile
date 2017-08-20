FROM tomcat:8.0-jre8

LABEL maintainer="martynas@atomgraph.com"

RUN apt-get update && \
  apt-get -y install xsltproc

# USER tomcat

WORKDIR $CATALINA_HOME

# add XSLT stylesheet that makes changes to server.xml

COPY letsencrypt-tomcat.xsl conf/letsencrypt-tomcat.xsl

# add entrypoint

COPY entrypoint.sh entrypoint.sh

EXPOSE 80 8443

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]