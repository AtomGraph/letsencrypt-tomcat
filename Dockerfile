FROM tomcat:8.0-jre8

LABEL maintainer="martynas@atomgraph.com"

# USER tomcat

WORKDIR $CATALINA_HOME

# add Tomcat config

COPY conf/server.xml conf/server.xml

# add entrypoint

COPY entrypoint.sh entrypoint.sh

EXPOSE 80 8443

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]