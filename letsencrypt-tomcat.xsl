<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="http.proxyName""/>
    <xsl:param name="http.proxyPort"/>
    <xsl:param name="https.port"/>
    <xsl:param name="https.maxThreads"/>
    <xsl:param name="https.clientAuth"/>
    <xsl:param name="https.proxyName"/>
    <xsl:param name="https.proxyPort"/>
    <xsl:param name="letsencrypt.keystoreFile"/>
    <xsl:param name="letsencrypt.keystorePass"/>
    <xsl:param name="letsencrypt.keyAlias"/>
    <xsl:param name="letsencrypt.keyPass"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- redirect HTTP to HTTPS-->
    <!-- @redirectPort requires security-constraint in web.xml: https://tomcat.apache.org/tomcat-8.0-doc/config/http.html -->
    <xsl:template match="Connector[@protocol = 'HTTP/1.1']">
        <xsl:copy>
            <xsl:if test="$http.proxyName">
                <xsl:attribute name="proxyName" value="$http.proxyName"/>
            </xsl:if>
            <xsl:if test="$http.proxyPort">
                <xsl:attribute name="proxyPort" value="$http.proxyPort"/>
            </xsl:if>
            <xsl:if test="$https.port">
                <xsl:attribute name="redirectPort" value="$https.port"/>
            </xsl:if>

            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- enable HTTPS if it's not already enabled -->
    <xsl:template match="Service[not(Connector/@protocol = 'org.apache.coyote.http11.Http11NioProtocol')]/*[last()]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        
        <Connector port="{$https.port}" protocol="org.apache.coyote.http11.Http11NioProtocol"
                   maxThreads="{$https.maxThreads}" SSLEnabled="true" scheme="https" secure="true"
                   keystoreFile="{$letsencrypt.keystoreFile}" keystorePass="{$letsencrypt.keystorePass}"
                   keyAlias="{$letsencrypt.keyAlias}" keyPass="{$letsencrypt.keyPass}"
                   sslProtocol="TLS">
            <xsl:if test="$https.proxyName">
                <xsl:attribute name="proxyName" value="$https.proxyName"/>
            </xsl:if>
            <xsl:if test="$https.proxyPort">
                <xsl:attribute name="proxyPort" value="$https.proxyPort"/>
            </xsl:if>
            <xsl:if test="$https.clientAuth">
                <xsl:attribute name="clientAuth" value="$https.clientAuth"/>
            </xsl:if>
        </Connector>
    </xsl:template>
    
</xsl:stylesheet>