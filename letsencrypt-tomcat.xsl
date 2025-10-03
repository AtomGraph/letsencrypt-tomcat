<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="Connector.http"/>
    <xsl:param name="Connector.scheme.http"/>
    <xsl:param name="Connector.port.http"/>
    <xsl:param name="Connector.proxyName.http"/>
    <xsl:param name="Connector.proxyPort.http"/>
    <xsl:param name="Connector.redirectPort.http"/>
    <xsl:param name="Connector.connectionTimeout.http"/>
    <xsl:param name="Connector.compression.http"/>
    <xsl:param name="Connector.https"/>
    <xsl:param name="Connector.scheme.https"/>
    <xsl:param name="Connector.port.https"/>
    <xsl:param name="Connector.maxThreads.https"/>
    <xsl:param name="Connector.clientAuth.https"/>
    <xsl:param name="Connector.proxyName.https"/>
    <xsl:param name="Connector.proxyPort.https"/>
    <xsl:param name="Connector.keystoreFile.https"/>
    <xsl:param name="Connector.keystorePass.https"/>
    <xsl:param name="Connector.keyAlias.https"/>
    <xsl:param name="Connector.keyPass.https"/>
    <xsl:param name="Connector.compression.https"/>
    <xsl:param name="RemoteIpValve" select="'false'"/>
    <xsl:param name="RemoteIpValve.protocolHeader" select="'X-Forwarded-Proto'"/>
    <xsl:param name="RemoteIpValve.portHeader" select="'X-Forwarded-Port'"/>
    <xsl:param name="RemoteIpValve.remoteIpHeader" select="'X-Forwarded-For'"/>
    <xsl:param name="RemoteIpValve.hostHeader" select="'X-Forwarded-Host'"/>

    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- redirect HTTP to HTTPS-->
    <!-- @redirectPort requires security-constraint in web.xml: https://tomcat.apache.org/tomcat-8.0-doc/config/http.html -->
    <xsl:template match="Connector[@protocol = 'HTTP/1.1']">
        <!-- xsltproc does not support boolean parameters -->
        <xsl:if test="translate($Connector.http, $lowercase, $uppercase) = 'TRUE'">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>

                <xsl:if test="$Connector.scheme.http">
                    <xsl:attribute name="scheme">
                        <xsl:value-of select="$Connector.scheme.http"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.port.http">
                    <xsl:attribute name="port">
                        <xsl:value-of select="$Connector.port.http"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.proxyName.http">
                    <xsl:attribute name="proxyName">
                        <xsl:value-of select="$Connector.proxyName.http"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.proxyPort.http">
                    <xsl:attribute name="proxyPort">
                        <xsl:value-of select="$Connector.proxyPort.http"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.redirectPort.http">
                    <xsl:attribute name="redirectPort">
                        <xsl:value-of select="$Connector.redirectPort.http"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.connectionTimeout.http">
                    <xsl:attribute name="connectionTimeout">
                        <xsl:value-of select="$Connector.connectionTimeout.http"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.compression.http">
                    <xsl:attribute name="compression">
                        <xsl:value-of select="$Connector.compression.http"/>
                    </xsl:attribute>
                </xsl:if>

                <xsl:apply-templates select="node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Server/Service/Engine">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>

            <!-- add RemoteIpValve if requested and not already present -->
            <xsl:if test="translate($RemoteIpValve, $lowercase, $uppercase) = 'TRUE' and not(Valve[@className='org.apache.catalina.valves.RemoteIpValve'])">
                <Valve className="org.apache.catalina.valves.RemoteIpValve">
                    <xsl:attribute name="protocolHeader">
                        <xsl:value-of select="$RemoteIpValve.protocolHeader"/>
                    </xsl:attribute>
                    <xsl:attribute name="portHeader">
                        <xsl:value-of select="$RemoteIpValve.portHeader"/>
                    </xsl:attribute>
                    <xsl:attribute name="remoteIpHeader">
                        <xsl:value-of select="$RemoteIpValve.remoteIpHeader"/>
                    </xsl:attribute>
                    <xsl:attribute name="hostHeader">
                        <xsl:value-of select="$RemoteIpValve.hostHeader"/>
                    </xsl:attribute>
                </Valve>
            </xsl:if>

            <xsl:apply-templates select="node()"/>
        </xsl:copy>

        <!-- add HTTPS connector after Engine if not already present -->
        <xsl:if test="not(../Connector[@protocol = 'org.apache.coyote.http11.Http11NioProtocol']) and translate($Connector.https, $lowercase, $uppercase) = 'TRUE'">
            <Connector port="{$Connector.port.https}" protocol="org.apache.coyote.http11.Http11NioProtocol"
                       maxThreads="{$Connector.maxThreads.https}" SSLEnabled="true" secure="true"
                       keystoreFile="{$Connector.keystoreFile.https}" keystorePass="{$Connector.keystorePass.https}"
                       keyAlias="{$Connector.keyAlias.https}" keyPass="{$Connector.keyPass.https}"
                       sslProtocol="TLS">
                <xsl:if test="$Connector.scheme.https">
                    <xsl:attribute name="scheme">
                        <xsl:value-of select="$Connector.scheme.https"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.proxyName.https">
                    <xsl:attribute name="proxyName">
                        <xsl:value-of select="$Connector.proxyName.https"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.proxyPort.https">
                    <xsl:attribute name="proxyPort">
                        <xsl:value-of select="$Connector.proxyPort.https"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.clientAuth.https">
                    <xsl:attribute name="clientAuth">
                        <xsl:value-of select="$Connector.clientAuth.https"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$Connector.compression.https">
                    <xsl:attribute name="compression">
                        <xsl:value-of select="$Connector.compression.https"/>
                    </xsl:attribute>
                </xsl:if>
            </Connector>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>