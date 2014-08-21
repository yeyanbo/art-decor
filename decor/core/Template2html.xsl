<!-- 
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Dr. Kai U. Heitmann
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
    
    
    Icons by Axialis Team
    <a href="http://www.axialis.com/free/icons">Icons</a> by <a href="http://www.axialis.com">Axialis Team</a>
    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" exclude-result-prefixes="#all">
    
    <!--
        parameters
        ==========
        to this XSLT and all invoked scripts
    -->
    <xsl:param name="artdecordeeplinkprefix"/>
    
    <!-- not used yet, only by DECORbasics -->
    <xsl:param name="projectDefaultLanguage"/>
    <xsl:variable name="defaultLanguage" select="$projectDefaultLanguage"/>
    
    
    <!-- fixed parameters  -->
    <xsl:param name="switchCreateSchematron" select="false()"/>
    <xsl:param name="switchCreateSchematronWithWrapperIncludes" select="false()"/>
    <xsl:param name="switchCreateDocHTML" select="false()"/>
    <xsl:param name="switchCreateDocSVG" select="false()"/>
    <xsl:param name="switchCreateDocDocbook" select="false()"/>
    <xsl:param name="useLocalAssets" select="false()"/>
    <xsl:param name="useLocalLogos" select="false()"/>
    <xsl:param name="inDevelopment" select="false()"/>
    <xsl:param name="switchCreateDatatypeChecks" select="false()"/>
    <xsl:param name="useCustomLogo" select="false()"/>
    <xsl:param name="useCustomLogoSRC" select="false()"/>
    <xsl:param name="useCustomLogoHREF" select="false()"/>
    <xsl:param name="createDefaultInstancesForRepresentingTemplates" select="false()"/>
    <xsl:param name="skipCardinalityChecks" select="false()"/>
    <xsl:param name="skipPredicateCreation" select="false()"/>
    <xsl:param name="useLatestDecorVersion" select="false()"/>
    <xsl:param name="latestVersion" select="''"/>
    <xsl:param name="hideColumns" select="false()"/>
    <xsl:param name="logLevel" select="'INFO'"/>
    <!-- 
    
    -->
    <xsl:include href="../../decor/core/DECOR2html.xsl"/>
    <xsl:include href="../../decor/core//DECOR-basics.xsl"/>
    
    
    <!-- 
    
    -->
    <xsl:output method="xml" indent="no" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all" name="xml"/>
    <xsl:output method="html" indent="no" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <!-- 
    
    -->
    <xsl:template match="/">
        <xsl:variable name="tp">
            <xsl:copy-of select="/*/template/template[@id]"/>
        </xsl:variable>
        <xsl:for-each select="$tp/*">
            <xsl:variable name="templatename">
                <xsl:choose>
                    <xsl:when test="string-length(@displayName)&gt;0">
                        <xsl:value-of select="@displayName"/>
                        <xsl:if test="@name and (@name != @displayName)">
                            <i>
                                <xsl:text> / </xsl:text>
                                <xsl:value-of select="@name"/>
                            </i>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="string-length(@name)&gt;0">
                        <i>
                            <xsl:value-of select="@name"/>
                        </i>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'rulesNoNameOrDisplaynameDefinedYet'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <h1>
                <xsl:value-of select="$templatename"/>
            </h1>
            <xsl:variable name="t">
                <xsl:apply-templates select=".">
                    <xsl:with-param name="templatename" select="$templatename"/>
                </xsl:apply-templates>
            </xsl:variable> 
            <xsl:apply-templates select="$t" mode="simplify"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="table" mode="simplify">
        <table class="artdecor">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="style" select="'background: transparent;'"/>
            <xsl:apply-templates mode="simplify"/>
        </table>
    </xsl:template>
    <xsl:template match="th|tr|font|i|br|tt|span|strong|ul|li|p" mode="simplify">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="simplify"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="td|div" mode="simplify">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@* except (@id|@onclick|@class)"/>
            <xsl:apply-templates mode="simplify"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="thead|tbody" mode="simplify">
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <xsl:template match="a" mode="simplify">
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <!--
    <xsl:template match="img[@src='http://art-decor.org/ADAR/rv/assets/treeblank.png']" mode="simplify">
        <xsl:text>[[Datei:Treeblank.png|15px]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='http://art-decor.org/ADAR/rv/assets/treetree.png']" mode="simplify">
        <xsl:text>[[Datei:Treetree.png|15px]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='http://art-decor.org/ADAR/rv/assets/notice.png']" mode="simplify">
        <xsl:text>[[Datei:Notice.png|15px]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='http://art-decor.org/ADAR/rv/assets/en-US.png']" mode="simplify">
        <xsl:text>[[Datei:EN-US.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='http://art-decor.org/ADAR/rv/assets/de-DE.png']" mode="simplify">
        <xsl:text>[[Datei:DE-DE.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='http://art-decor.org/ADAR/rv/assets/nl-NL.png']" mode="simplify">
        <xsl:text>[[Datei:NL-NL.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='http://art-decor.org/ADAR/rv/assets/alert.png']" mode="simplify">
        <xsl:text>[[Datei:Alert.png|15px]]</xsl:text>
    </xsl:template>
    -->
    <xsl:template match="*" mode="simplify">
        <xsl:copy-of select="." copy-namespaces="no" exclude-result-prefixes="#all"/>
    </xsl:template>
    <!--
    <xsl:template match="text()" mode="simplify">
        <xsl:value-of select="."/>
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    -->
    <xsl:template match="*/text()[normalize-space(.)][../*]" mode="simplify">
        <xsl:value-of select="translate(., '&#xA;&#xD;', ' ')"/>
    </xsl:template>
    <xsl:template match="text()" mode="simplify">
        <xsl:value-of select="translate(., '&#xA;&#xD;', ' ')"/>
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="simplify"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>