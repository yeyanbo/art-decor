<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:key name="classCode" match="Klassen" use="@Klasse"/>
    <xsl:template match="ISO9999">
        <ISO9999>
            <xsl:for-each select="//Klassen[string-length(@Klasse)=2]">
                <xsl:variable name="code" select="@Klasse"/>
                <class code="{@Klasse}">
                    <xsl:apply-templates select="@Titel"/>
                    <xsl:apply-templates select="Toevoegingen"/>
                    <xsl:for-each select="//Klassen[string-length(@Klasse)=5][substring(@Klasse,1,2)=$code]">
                        <xsl:variable name="subCode" select="@Klasse"/>
                        <class code="{@Klasse}">
                            <xsl:apply-templates select="@Titel"/>
                            <xsl:apply-templates select="Toevoegingen"/>
                            <xsl:for-each select="//Klassen[string-length(@Klasse)=8][substring(@Klasse,1,5)=$subCode]">
                                <class code="{@Klasse}">
                                    <xsl:apply-templates select="@Titel"/>
                                    <xsl:apply-templates select="Toevoegingen"/>
                                </class>
                            </xsl:for-each>
                        </class>
                    </xsl:for-each>
                </class>
            </xsl:for-each>
        </ISO9999>
    </xsl:template>
    <xsl:template match="@Titel">
        <title xml:lang="nl-NL" count="{count(tokenize(.,'\s'))}" length="{string-length(.)}">
            <xsl:value-of select="."/>
        </title>
    </xsl:template>
    <xsl:template match="Toevoegingen">
        <xsl:variable name="text">
            <xsl:choose>
                <xsl:when test="string-length(@ToevTermRef)&gt;0">
                    <xsl:value-of select="concat(@ToevTermRef,' - ',key('classCode', @ToevTermRef)/@Titel)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@ToevTekst"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <extension typeCode="{@ToevTypeCode}" typeOrder="{@ToevTypeOrder}" termRef="{@ToevTermRef}">
            <desc xml:lang="nl-NL" count="{count(tokenize($text,'\s'))}" length="{string-length($text)}">
                <xsl:value-of select="$text"/>
            </desc>
        </extension>
    </xsl:template>
</xsl:stylesheet>