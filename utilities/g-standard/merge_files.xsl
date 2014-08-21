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
	
	
	Run with:
	
	java -Xmx8096m -jar saxon9.jar -t -s:merge_files.xsl -xsl:merge_files.xsl -o:file-merge.xml
	
-->
<!-- 
   stylesheet for merging several files into one large xml file for processing
   
   Run with
   java -Xmx2048m -jar saxon9.jar -t -s:merge_files.xsl -xsl:merge_files.xsl -o:file-merge.xml
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
   <xsl:output method="xml" exclude-result-prefixes="#all" encoding="iso-8859-1"/>
   <!-- characterset of input files, incorrect setting will result in error: Failed to read input file .... (java.nio.charset.MalformedInputException) - Input length = 1 -->
   <xsl:template match="/">
      <files>
         <!-- Bestand 711 Generieke Produkten -->
         <xsl:variable name="generics" select="doc('XML/BST711T.xml')/BST711T"/>
         <xsl:for-each select="$generics/row">
            <gpk>
               <xsl:for-each select="@*">
                  <xsl:attribute name="{lower-case(name(.))}" select="."/>
               </xsl:for-each>
            </gpk>
         </xsl:for-each>
         <!-- Bestand 051 Voorschrijfpr. geneesmiddel identific. -->
         <xsl:variable name="prks" select="doc('XML/BST051T.xml')/BST051T"/>
         <xsl:for-each select="$prks/row">
            <prk>
               <xsl:for-each select="@*">
                  <xsl:attribute name="{lower-case(name(.))}" select="."/>
               </xsl:for-each>
            </prk>
         </xsl:for-each>
         <!-- Bestand 031 Handelsproducten -->
         <xsl:variable name="hpks" select="doc('XML/BST031T.xml')/BST031T"/>
         <xsl:for-each select="$hpks/row">
            <hpk>
               <xsl:for-each select="@*">
                  <xsl:attribute name="{lower-case(name(.))}" select="."/>
               </xsl:for-each>
            </hpk>
         </xsl:for-each>
         <!-- Bestand 004 Artikelen -->
         <xsl:variable name="zis" select="doc('XML/BST004T.xml')/BST004T"/>
         <xsl:for-each select="$zis/row">
            <art>
               <xsl:for-each select="@*">
                  <xsl:attribute name="{lower-case(name(.))}" select="."/>
               </xsl:for-each>
            </art>
         </xsl:for-each>
         <!-- Bestand 800 ATC/DDD-gegevens -->
         <xsl:variable name="atc" select="doc('XML/BST800T.xml')/BST800T"/>
         <xsl:for-each select="$atc/row">
            <atc>
               <xsl:for-each select="@*">
                  <xsl:attribute name="{lower-case(name(.))}" select="."/>
               </xsl:for-each>
            </atc>
         </xsl:for-each>
         <!-- Bestand 020 Namen -->
         <xsl:variable name="names" select="doc('XML/BST020T.xml')/BST020T"/>
         <xsl:for-each select="$names/row">
            <name>
               <xsl:for-each select="@*">
                  <xsl:attribute name="{lower-case(name(.))}" select="."/>
               </xsl:for-each>
            </name>
         </xsl:for-each>
         <!-- Bestand 902 Thesauri totaal -->
         <xsl:variable name="thes" select="doc('XML/BST902T.xml')/BST902T"/>
         <xsl:for-each select="$thes/row">
            <thes>
               <xsl:for-each select="@*">
                  <xsl:attribute name="{lower-case(name(.))}" select="."/>
               </xsl:for-each>
            </thes>
         </xsl:for-each>
      </files>
   </xsl:template>
</xsl:stylesheet>