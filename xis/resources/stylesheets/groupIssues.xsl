<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:atp="urn:nictiz.atp" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" version="2.0" exclude-result-prefixes="#all">
    <xsl:output method="xml" encoding="UTF-8"/>
	<!--    <xsl:include href="v3mXML2HTMLGenerator2.xsl"/>-->
    <xsl:template match="/validationReport">
        <validationReport>
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:for-each-group select="*[@type='schema']" group-by="@role">
                <xsl:element name="{current-grouping-key()}">
                    <xsl:attribute name="type" select="current-group()[1]/@type"/>
                    <xsl:for-each select="current-group()">
                        <issue>
                            <xsl:copy-of select="@*"/>
                            <xsl:attribute name="count" select="@count"/>
                            <description>
                                <xsl:choose>
                                    <xsl:when test="description/text()[contains(.,':')]">
                                        <xsl:value-of select="description/text()/normalize-space(substring-after(.,':'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="description/text()/normalize-space()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </description>
                            <location line="{location/@line}"/>
                        </issue>
                    </xsl:for-each>
                </xsl:element>
            </xsl:for-each-group>
            <xsl:for-each-group select="*[@type='schematron']" group-by="@role">
                <xsl:element name="{current-grouping-key()}">
                    <xsl:attribute name="type" select="current-group()[1]/@type"/>
                    <xsl:for-each-group select="current-group()" group-by="description">
                        <issue>
                            <xsl:copy-of select="@*"/>
                            <xsl:attribute name="count" select="count(current-group()/location)"/>
                            <description>
                                <xsl:value-of select="current-grouping-key()"/>
                            </description>
                            <xsl:for-each select="current-group()">
                                <location path="{location/@path}"/>
                            </xsl:for-each>
                        </issue>
                    </xsl:for-each-group>
                </xsl:element>
            </xsl:for-each-group>
        </validationReport>
    </xsl:template>
</xsl:stylesheet>