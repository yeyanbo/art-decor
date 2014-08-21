<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2011
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
--><!-- 
   Stylesheet for creating descriptions file for full text search
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:key name="classCode" match="Class" use="@code"/>
    <xsl:template match="/ClaML">
      <!-- descriptions -->
        <descriptions>
           <!-- first classification identifier -->
            <xsl:variable name="classificationId" select="Identifier[1]/@uid"/>
            <xsl:variable name="classificationName" select="Title/@name"/>
         <!-- get descriptions from classes -->
            <xsl:for-each select="Class">
                <xsl:variable name="superClasses">
                    <xsl:for-each select="SuperClass">
                        <name>
                            <xsl:value-of select="key('classCode',@code)/Rubric[@kind='preferred']/Label"/>
                        </name>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="classCode" select="@code"/>
                <xsl:for-each select="Rubric[@kind='preferred']">
                    <xsl:for-each select="Label">
                        <description count="{count(tokenize(.,'\s'))}" length="{string-length(.)}" conceptId="{$classCode}" type="pref" language="{@xml:lang}" superClasses="{string-join($superClasses/name,', ')}" classificationId="{$classificationId}" classificationName="{$classificationName}">
                            <xsl:value-of select="."/>
                        </description>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </descriptions>
    </xsl:template>
</xsl:stylesheet>