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
   Stylesheet for creating extract of ClaML file for navigation purposes.
   - Adds the Rubric[@kind=preferred'] to all SubClasses.
   - Element not needed for navigating the hierarchy are removed.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:key name="classCode" match="Class" use="@code"/>
    <xsl:template match="/ClaML">
      <!-- make root element different -->
        <ClaML-denormalized>
         <!-- include Meta elements -->
            <xsl:for-each select="Meta">
                <xsl:copy-of copy-namespaces="no" select="."/>
            </xsl:for-each>
         <!-- include Identifier and Title element -->
            <xsl:copy-of copy-namespaces="no" select="Identifier|Title"/>
         <!-- Build rootClass -->
            <Class code="rootClass">
                <xsl:for-each select="Class[not(SuperClass)]">
                    <SubClass subCount="{count(SubClass)}">
                        <xsl:copy-of select="@*"/>
                        <xsl:copy-of select="Rubric[@kind='preferred']"/>
                    </SubClass>
                </xsl:for-each>
                <Rubric kind="preferred">
                    <Label xml:lang="nl">
                        <xsl:value-of select="Title/@name"/>
                    </Label>
                </Rubric>
                <Rubric kind="description">
                    <Label xml:lang="nl">
                        <xsl:value-of select="Title"/>
                    </Label>
                </Rubric>
            </Class>
         <!-- include all Class elements -->
            <xsl:for-each select="Class">
                <Class code="{@code}" kind="{@kind}">
               <!-- include Meta elements -->
                    <xsl:for-each select="Meta">
                        <xsl:copy-of copy-namespaces="no" select="."/>
                    </xsl:for-each>
               <!-- copy SuperClass elements and include the preferred Label -->
                    <xsl:for-each select="SuperClass">
                        <SuperClass code="{@code}">
                            <xsl:copy-of copy-namespaces="no" select="key('classCode',@code)/Rubric[@kind='preferred']"/>
                        </SuperClass>
                    </xsl:for-each>
               <!-- cope all SubClasses, include the preferred Label and and SubClass count -->
                    <xsl:for-each select="SubClass">
                        <SubClass code="{@code}" subCount="{count(key('classCode',@code)/SubClass)}">
                            <xsl:copy-of copy-namespaces="no" select="key('classCode',@code)/Rubric[@kind='preferred']"/>
                        </SubClass>
                    </xsl:for-each>
               <!-- copy all rubrics-->
                    <xsl:for-each select="Rubric">
                        <xsl:copy-of copy-namespaces="no" select="."/>
                    </xsl:for-each>
                </Class>
            </xsl:for-each>
        </ClaML-denormalized>
    </xsl:template>
</xsl:stylesheet>