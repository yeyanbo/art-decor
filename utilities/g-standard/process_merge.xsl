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
-->
<!-- 
   stylesheet for creating hierarchical xml file for generic products (GPK) from the merged files
   
   Run with:
	
	java -Xmx2048m -jar saxon9.jar -t -s:file-merge.xml -xsl:process_merge.xsl -o:gpk.xml
   
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
   <xsl:output method="xml" exclude-result-prefixes="#all" encoding="iso-8859-1"/>

   <xsl:key name="gpk" match="gpk" use="@gpkode"/>
   <xsl:key name="prk" match="prk" use="@gpkode"/>
   <xsl:key name="hpk" match="hpk" use="@prkode"/>
   <xsl:key name="atk" match="art" use="@hpkode"/>
   <xsl:key name="name" match="name" use="@nmnr"/>
   <xsl:key name="thes" match="thes" use="concat(@tsnr,@tsitnr)"/>
   <!--   <xsl:key name="thesIt" match="thes" use="@tsitnr"/>-->
   <xsl:key name="atc" match="atc" use="@atcode"/>
   <xsl:template match="/files">
      <generiekeProducten>
         <xsl:for-each select="gpk">
            <xsl:variable name="gpkode" select="@gpkode"/>
            <xsl:variable name="naam" select="key('name',@gpnmnr)"/>
            <xsl:variable name="stofNaam" select="key('name',@gpstnr)"/>
            <xsl:variable name="vorm" select="key('thes',concat(@thktvr,@gpktvr))"/>
            <xsl:variable name="toedieningsweg" select="key('thes',concat(@thktwg,@gpktwg))"/>
            <xsl:variable name="atc" select="key('atc',@atcode)"/>
            <product gpkode="{$gpkode}" atcode="{@atcode}">
               <naam>
                  <etiket>
                     <xsl:value-of select="$naam/@nmetik"/>
                  </etiket>
                  <kort>
                     <xsl:value-of select="$naam/@nmnm40"/>
                  </kort>
                  <volledig>
                     <xsl:value-of select="$naam/@nmnaam"/>
                  </volledig>
               </naam>
               <stofNaam>
                  <etiket>
                     <xsl:value-of select="$stofNaam/@nmetik"/>
                  </etiket>
                  <kort>
                     <xsl:value-of select="$stofNaam/@nmnm40"/>
                  </kort>
                  <volledig>
                     <xsl:value-of select="$stofNaam/@nmnaam"/>
                  </volledig>
               </stofNaam>
               <vorm>
                  <nm15>
                     <xsl:value-of select="$vorm/@thnm15"/>
                  </nm15>
                  <nm25>
                     <xsl:value-of select="$vorm/@thnm25"/>
                  </nm25>
                  <nm50>
                     <xsl:value-of select="$vorm/@thnm50"/>
                  </nm50>
               </vorm>
               <toedieningsweg>
                  <nm15>
                     <xsl:value-of select="$toedieningsweg/@thnm15"/>
                  </nm15>
                  <nm25>
                     <xsl:value-of select="$toedieningsweg/@thnm25"/>
                  </nm25>
                  <nm50>
                     <xsl:value-of select="$toedieningsweg/@thnm50"/>
                  </nm50>
               </toedieningsweg>
               <atc>
                  <omschrijving>
                     <xsl:value-of select="$atc/@atomsn"/>
                  </omschrijving>
               </atc>
               <xsl:for-each select="key('prk',$gpkode)">
                  <xsl:variable name="prkode" select="@prkode"/>
                  <prk prkode="{$prkode}">
                     <naamstoevoeging>
                        <xsl:value-of select="@prntoe"/>
                     </naamstoevoeging>
                     <xsl:for-each select="key('hpk',$prkode)">
                        <xsl:variable name="hpkode" select="@hpkode"/>
                        <xsl:variable name="hpnaam" select="key('name',@hpnamn)"/>
                        <hpk hpkode="{$hpkode}">
                           <naam>
                              <etiket>
                                 <xsl:value-of select="$hpnaam/@nmetik"/>
                              </etiket>
                              <kort>
                                 <xsl:value-of select="$hpnaam/@nmnm40"/>
                              </kort>
                              <volledig>
                                 <xsl:value-of select="$hpnaam/@nmnaam"/>
                              </volledig>
                           </naam>
                           <xsl:for-each select="key('atk',$hpkode)">
                              <xsl:variable name="atkode" select="@atkode"/>
                              <xsl:variable name="atnaam" select="key('name',@atnmnr)"/>
                              <artikel atkode="{$atkode}">
                                 <naam>
                                    <etiket>
                                       <xsl:value-of select="$atnaam/@nmetik"/>
                                    </etiket>
                                    <kort>
                                       <xsl:value-of select="$atnaam/@nmnm40"/>
                                    </kort>
                                    <volledig>
                                       <xsl:value-of select="$atnaam/@nmnaam"/>
                                    </volledig>
                                 </naam>
                              </artikel>
                           </xsl:for-each>
                        </hpk>
                     </xsl:for-each>
                  </prk>
               </xsl:for-each>
            </product>
         </xsl:for-each>
      </generiekeProducten>
   </xsl:template>
</xsl:stylesheet>
