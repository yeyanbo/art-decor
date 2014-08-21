<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2012 Art Decor Expert group, www.art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
	
	Converts ASCII to xml
	Column names are derived from forst row
	LOINC_NUM will be attribute of row, all other columns become elements. 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:output method="xml" exclude-result-prefixes="#all" encoding="iso-8859-1"/>
   <!-- characterset of input file, incorrect setting will result in error: Failed to read input file .... (java.nio.charset.MalformedInputException) - Input length = 1 -->
   <xsl:variable name="charSet" select="'iso-8859-1'"/>

   <xsl:variable name="loincTab" select="'LOINC240/LOINCDB.TXT'"/>
   <!-- open file -->
   <xsl:variable name="loincFile" select="unparsed-text($loincTab,$charSet)"/>

   <xsl:variable name="rawColumns" select="tokenize(tokenize($loincFile,'\r\n')[1],'\t')"> </xsl:variable>
   <xsl:variable name="columns">
      <xsl:for-each select="$rawColumns">
         <name>
            <xsl:value-of select="substring(.,2,string-length(.)-2)"/>
         </name>
      </xsl:for-each>
   </xsl:variable>

   <xsl:template match="/">
      <result>
         <xsl:for-each select="tokenize($loincFile,'\r\n')">
            <xsl:if test="position()>1">
               <row>
                  <xsl:for-each select="tokenize(.,'\t')">
                     <xsl:variable name="position" select="position()"/>
                     <xsl:choose>
                        <xsl:when test="$columns/name[$position]=('LOINC_NUM')">
                           <xsl:attribute name="{$columns/name[$position]}">
                              <xsl:choose>
                                 <xsl:when test="string-length(.)&gt;0">
                                    <xsl:value-of select="substring(.,2,string-length(.)-2)"/>
                                 </xsl:when>
                                 <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                 </xsl:otherwise>
                              </xsl:choose>
                           </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:element name="{$columns/name[$position]}">
                              <xsl:choose>
                                 <xsl:when test="string-length(.)&gt;0">
                                    <xsl:value-of select="substring(.,2,string-length(.)-2)"/>
                                 </xsl:when>
                                 <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                 </xsl:otherwise>
                              </xsl:choose>
                           </xsl:element>
                        </xsl:otherwise>
                     </xsl:choose>

                  </xsl:for-each>
               </row>
            </xsl:if>
         </xsl:for-each>
      </result>
   </xsl:template>
</xsl:stylesheet>
