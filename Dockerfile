FROM tomcat:8.0-jre8

LABEL maintainer="martynas@atomgraph.com"

RUN apt-get update && apt-get -y install xsltproc

# USER tomcat

WORKDIR $CATALINA_HOME

# add XSLT stylesheet that makes changes to server.xsl

COPY server.xml.xsl conf/server.xml.xsl

# add entrypoint

COPY entrypoint.sh entrypoint.sh

EXPOSE 80 8443

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]