<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
    <xsl:output method="xml" indent="yes"/>
  
    <xsl:param name="https.port" select="8443"/>
    <xsl:param name="https.maxThreads" select="150"/>
    <xsl:param name="https.clientAuth" select="'want'"/>
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
	    <xsl:attribute name="redirectPort" value="{$https.port}"/>
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
                   clientAuth="{$https.clientAuth}" sslProtocol="TLS" />
    </xsl:template>
    
</xsl:stylesheet>