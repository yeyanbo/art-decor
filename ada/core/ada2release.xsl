<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Copyright (C) 2013-2014  Marc de Graauw

This program is free software; you can redistribute it and/or modify it under the terms 
of the GNU General Public License as published by the Free Software Foundation; 
either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

See http://www.gnu.org/licenses/gpl.html

    Input: a {project}-ada.xml doc
    Output: a {project}-{versionDate}-{language}-ada.xml doc
    
    Will retrieve transaction for each view, output contains all attributes and constructs from {project}-ada.xml doc 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="ada-basics.xsl"/>
    <xsl:variable name="transactions">
        <transactionDatasets>
            <xsl:for-each select="distinct-values(//*/@transactionId/string())">
                <xsl:variable name="uri" select="concat($releaseBaseUri, '?id=', ., '&amp;language=', $language,'&amp;version=', $versionDate, '&amp;format=xml')"/>
                <xsl:copy-of select="document($uri)"/>    
            </xsl:for-each>
        </transactionDatasets>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:result-document href="{replace(base-uri(), '.xml', '-release.xml')}" method="xml">
            <xsl:comment>ADA release generator version 1, <xsl:value-of select="current-dateTime()"/></xsl:comment><xsl:text></xsl:text>
            <xsl:apply-templates/>
<!-- TODO: check if RESTuri exists -->
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="ada">
        <xsl:copy>
            <xsl:attribute name="adaVersion">1</xsl:attribute>
            <xsl:apply-templates select="(@* except @xsi:noNamespaceSchemaLocation)|node()"/>
            <xsl:copy-of select="$transactions"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="view">
        <view>
            <xsl:apply-templates select="@*"></xsl:apply-templates>
            <xsl:variable name="transactionId" select="@transactionId"/>
            <xsl:if test="indexOf">
                <xsl:element name="indexOf">
                    <xsl:copy-of select="indexOf/@*"/>
                    <xsl:variable name="num" select="indexOf/@ref"/>
                    <xsl:attribute name="shortName">
                        <xsl:call-template name="shortName">
                            <xsl:with-param name="name"><xsl:value-of select="//view[@id=$num]/name"></xsl:value-of></xsl:with-param>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
            <xsl:copy-of select="name"/>
            <implementation>
                <xsl:attribute name="shortName">
                    <xsl:call-template name="shortName">
                        <xsl:with-param name="name"><xsl:value-of select="name"></xsl:value-of></xsl:with-param>
                    </xsl:call-template>
                </xsl:attribute>
            </implementation>
            <dataset>
                <xsl:copy-of select="$transactions//dataset[@transactionId=$transactionId]/@*"></xsl:copy-of>
                <xsl:call-template name="copyConcept">
                    <xsl:with-param name="datasetConcepts">
                        <xsl:copy-of select="$transactions//dataset[@transactionId=$transactionId]/concept"></xsl:copy-of>
                    </xsl:with-param>
                    <xsl:with-param name="viewConcepts">
                        <xsl:copy-of select="concepts"></xsl:copy-of>
                    </xsl:with-param>
                </xsl:call-template>                    
            </dataset>
        </view>
    </xsl:template>
    
    <xsl:template name="shortName">
        <xsl:param name="name"/>
        <xsl:value-of select="translate(normalize-space(lower-case($name)),' àáãäåèéêëìíîïòóôõöùúûüýÿç€ßñ','_aaaaaeeeeiiiiooooouuuuuyycEsn')"/>
    </xsl:template>

    <xsl:template name="copyConcept">
        <xsl:param name="datasetConcepts"/>
        <xsl:param name="viewConcepts"/>
        <xsl:for-each select="$datasetConcepts/concept">
            <xsl:variable name="id"><xsl:value-of select="@id"></xsl:value-of></xsl:variable>
            <xsl:choose>
                <xsl:when test="$viewConcepts/concepts/@include='all' or ./@id=$viewConcepts/concepts/concept/@ref">
                    <xsl:copy>
                        <xsl:apply-templates select="@*"></xsl:apply-templates>
                        <xsl:copy-of select="$viewConcepts/concepts/concept[@ref=$id]/@*[not(local-name()='ref')]"/>
                        <xsl:copy-of select="*[not(local-name()='concept')]"></xsl:copy-of>
                        <xsl:call-template name="copyConcept">
                            <xsl:with-param name="datasetConcepts" select="."></xsl:with-param>
                            <xsl:with-param name="viewConcepts"><xsl:copy-of select="$viewConcepts"></xsl:copy-of></xsl:with-param>
                        </xsl:call-template>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="copyConcept">
                        <xsl:with-param name="datasetConcepts" select="."></xsl:with-param>
                        <xsl:with-param name="viewConcepts"><xsl:copy-of select="$viewConcepts"></xsl:copy-of></xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
