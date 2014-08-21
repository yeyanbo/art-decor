<!-- 
Copyright (C) 2013-2014  Marc de Graauw

This program is free software; you can redistribute it and/or modify it under the terms 
of the GNU General Public License as published by the Free Software Foundation; 
either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

See http://www.gnu.org/licenses/gpl.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="ada-basics.xsl"/>

    <xsl:template match="/">
        <xsl:comment>Empty instance generator version 1, <xsl:value-of select="current-dateTime()"/></xsl:comment>
        <xsl:apply-templates select="ada/transactionDatasets/dataset"/>
    </xsl:template>

    <xsl:template match="dataset">
        <xsl:variable name="href" select="concat($projectDiskRoot, 'new/', @shortName, '.xml')"/>
        <xsl:result-document href="{$href}" method="xml">
            <xsl:comment>New XML generator, <xsl:value-of select="current-dateTime()"/></xsl:comment>
            <xsl:apply-templates select="ada/transactionDatasets/dataset"/>
            <xsl:element name="{@shortName}">
                <xsl:attribute name="id">new</xsl:attribute>
                <xsl:attribute name="app">
                    <xsl:value-of select="$projectName"/>
                </xsl:attribute>
                <xsl:attribute name="transactionRef">
                    <xsl:value-of select="@transactionId"/>
                </xsl:attribute>
                <xsl:attribute name="transactionEffectiveDate">
                    <xsl:value-of select="@transactionEffectiveDate"/>
                </xsl:attribute>
                <xsl:copy-of select="/ada/project/@versionDate"/>
                <xsl:copy-of select="/ada/project/@prefix"/>
                <xsl:copy-of select="/ada/project/@language"/>
                <xsl:apply-templates select="concept[@type]"/>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="concept[@type='group']">
        <!-- 'Many' groups start with a row with @hidden (what value it contains is irrelevant, if @hidden is present, the row is hidden).
                This serves a as point to attach new groups when all are removed. -->
        <xsl:if test="not(@maximumMultiplicity='1')">
            <xsl:element name="{implementation/@shortName}-start">
                <xsl:attribute name="conceptId">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:attribute name="hidden">
                    <xsl:value-of select="'true'"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
        <xsl:element name="{implementation/@shortName}">
            <xsl:attribute name="conceptId">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:apply-templates select="concept[@type]"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="concept[@type='item']">
        <xsl:element name="{implementation/@shortName}">
            <xsl:attribute name="conceptId">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:attribute name="value">
                <xsl:if test="valueSet">
                    <xsl:value-of select="valueSet/conceptList[1]/concept[1]/@localId"/>
                </xsl:if>
                <xsl:if test="valueDomain/@type='boolean'">false</xsl:if>
            </xsl:attribute>
            <xsl:if test="valueDomain/property/@unit">
                <xsl:attribute name="unit">
                    <xsl:value-of select="(valueDomain/property/@unit)[1]"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text()|@*"/>
</xsl:stylesheet>
