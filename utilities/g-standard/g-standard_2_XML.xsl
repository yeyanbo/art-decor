<?xml version="1.0" encoding="UTF-8"?>
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
	
	java -Xmx8096m -jar saxon9.jar -t -s:G-Standaard_2_XML.xsl -xsl:g-standard_2_XML.xsl -o:dummy.xml
	
-->
<!-- 
   stylesheet for converting g-standard ascii files to XML
   - The ascii files must be in a directory 'Text' on the same level as this stylesheet.
   - The output is written to a directory 'XML' on the same level as this stylesheet.
   
   usage:
   java -Xmx2048m -jar saxon9.jar -t -s:g-standard_2_XML.xsl -xsl:g-standard_2_XML.xsl -o:dummy.xml
   
-->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:output method="xml" exclude-result-prefixes="#all" encoding="iso-8859-1"/>
   <!-- characterset of input files, incorrect setting will result in error: Failed to read input file .... (java.nio.charset.MalformedInputException) - Input length = 1 -->
   <xsl:variable name="charSet" select="'iso-8859-1'"/>
   <!-- file containing the file &amp; field definitions (BST001T) -->
   <xsl:variable name="definitionsFileName" select="'BST001T'"/>
   <!-- open definitions file -->
   <xsl:variable name="definitionsFile" select="unparsed-text(concat('Text/',$definitionsFileName),$charSet)"/>
   <xsl:variable name="definitions">
      <xsl:element name="{$definitionsFileName}">
         <xsl:for-each select="tokenize($definitionsFile,'\n')">
            <field>
               <xsl:attribute name="bstnum" select="normalize-space(substring(.,1,4))"/>
               <xsl:attribute name="mutkod" select="normalize-space(substring(.,5,1))"/>
               <xsl:attribute name="mdbst" select="normalize-space(substring(.,6,20))"/>
               <xsl:attribute name="mdvnr" select="normalize-space(substring(.,26,3))"/>
               <xsl:attribute name="mdrnam" select="normalize-space(substring(.,29,10))"/>
               <xsl:attribute name="mdroms" select="normalize-space(substring(.,39,50))"/>
               <xsl:attribute name="mdrcod" select="normalize-space(substring(.,89,8))"/>
               <xsl:attribute name="mdrsle" select="normalize-space(substring(.,97,2))"/>
               <xsl:attribute name="mdrtyp" select="normalize-space(substring(.,99,1))"/>
               <xsl:attribute name="mdrlen" select="normalize-space(substring(.,100,4))"/>
               <xsl:attribute name="mdrdec" select="normalize-space(substring(.,104,2))"/>
               <xsl:attribute name="mdropm" select="normalize-space(substring(.,106,6))"/>
            </field>
         </xsl:for-each>
      </xsl:element>
   </xsl:variable>
   <!-- variable contains file definitions grouped by file -->
   <xsl:variable name="fileList">
      <list>
         <xsl:for-each-group select="$definitions/BST001T/field" group-by="@mdbst">
            <xsl:element name="file">
               <xsl:attribute name="name" select="current-grouping-key()"/>
               <xsl:for-each select="current-group()">
                  <xsl:copy-of select="."/>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each-group>
      </list>
   </xsl:variable>
   <xsl:template match="/">
      <result>
         <xsl:for-each select="$fileList/list/file">
            <!-- test if @name is not empty -->
            <xsl:if test="@name != ''">
               <xsl:variable name="fieldList" select="field"/>
               <xsl:variable name="currentFile" select="unparsed-text(concat('Text/',@name),$charSet)"/>
               <xsl:result-document indent="yes" encoding="{$charSet}" href="{concat('XML/',@name,'.xml')}">
                  <xsl:element name="{@name}">
                     <xsl:for-each select="tokenize($currentFile,'\n')">
                        <xsl:variable name="currentRow" select="."/>
                        <!-- test if row is not empty -->
                        <xsl:if test="$currentRow != ''">
                           <row>
                              <xsl:for-each select="$fieldList">
                                 <xsl:variable name="start" select="sum(preceding-sibling::field/@mdrlen)+1"/>
                                 <xsl:choose>
                                    <xsl:when test="@mdrnam='******'">
                                       <xsl:attribute name="LEEG" select="normalize-space(substring($currentRow,$start,@mdrlen))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                       <xsl:choose>
                                          <xsl:when test="@mdrtyp='N'">
                                             <xsl:choose>
                                                <xsl:when test="number(@mdrdec)&gt;0">
                                                  <xsl:variable name="value" select="normalize-space(substring($currentRow,$start,@mdrlen))"/>
                                                  <xsl:variable name="number" select="concat(substring($value,1,@mdrlen - @mdrdec),'.',substring($value,(@mdrlen + 1 ) - @mdrdec,@mdrdec))"/>
                                                  <xsl:attribute name="{@mdrnam}" select="number($number)"/>
                                                  <!--                                             <xsl:attribute name="{@mdrnam}" select="normalize-space(substring($currentRow,$start,@mdrlen))"/>-->
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:choose>
                                                  <xsl:when test="substring($currentRow,$start,@mdrlen) castable as xs:integer">
                                                  <xsl:attribute name="{@mdrnam}" select="xs:integer(substring($currentRow,$start,@mdrlen))"/>
                                                  <!--                                                   <xsl:attribute name="{@mdrnam}" select="normalize-space(substring($currentRow,$start,@mdrlen))"/>-->
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:attribute name="{@mdrnam}" select="normalize-space(substring($currentRow,$start,@mdrlen))"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:otherwise>
                                             </xsl:choose>
                                          </xsl:when>
                                          <xsl:otherwise>
                                             <xsl:attribute name="{@mdrnam}" select="normalize-space(substring($currentRow,$start,@mdrlen))"/>
                                          </xsl:otherwise>
                                       </xsl:choose>
                                    </xsl:otherwise>
                                 </xsl:choose>
                              </xsl:for-each>
                           </row>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:result-document>
            </xsl:if>
         </xsl:for-each>
      </result>
   </xsl:template>
</xsl:stylesheet>

