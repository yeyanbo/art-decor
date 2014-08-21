<!--
	Copyright (C) 2011 Nictiz
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:variable name="charSet" select="'UTF-8'"/>
    <xsl:template match="/file">
        <xsl:variable name="fileName" select="@name"/>
        <xsl:variable name="rowName" select="@rows"/>
        <xsl:variable name="rootName" select="@root"/>
        <xsl:variable name="file" select="."/>
        <xsl:element name="{$rootName}">
               <!-- get column descriptions from first row-->
            <xsl:variable name="columns" select="tokenize(tokenize($file,'\r\n')[1],'\t')"/>
            <xsl:for-each select="tokenize($file,'\r\n')">
                <xsl:if test="position()&gt;1">
                    <xsl:element name="{$rowName}">
                        <xsl:for-each select="tokenize(.,'\t')">
                            <xsl:variable name="position" select="position()"/>
                            <xsl:attribute name="{$columns[$position]}">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>