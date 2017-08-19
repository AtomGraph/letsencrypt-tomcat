<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
    <xsl:output method="xml" indent="yes"/>
  
    <xsl:param name="letsencrypt.keystoreFile"/>
    <xsl:param name="letsencrypt.keystorePass"/>
    <xsl:param name="letsencrypt.keyAlias"/>
    <xsl:param name="letsencrypt.keyPass"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- disable HTTP -->
    <xsl:template match="Connector[@protocol = 'HTTP/1.1']"/>

    <!-- enable HTTPS -->
    <xsl:template match="Service/*[position() = last()]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        
        <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
                   maxThreads="150" SSLEnabled="true" scheme="https" secure="true"
                   keystoreFile="{$letsencrypt.keystoreFile}" keystorePass="{$letsencrypt.keystorePass}"
                   keyAlias="{$letsencrypt.keyAlias}" keyPass="{$letsencrypt.keyPass}"
                   clientAuth="want" sslProtocol="TLS" />
    </xsl:template>
    
</xsl:stylesheet>