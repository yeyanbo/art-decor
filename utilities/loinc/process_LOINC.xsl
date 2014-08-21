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
	
	java -Xmx8096m -jar saxon9.jar -t -s:G-Standaard_2_XML.xsl -xsl:G-Standaard_2_XML.xsl -o:dummy.xml
	
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:output method="xml" exclude-result-prefixes="#all" encoding="UTF-8"/>

   <xsl:template match="/result">
      <loinc_db>
         <xsl:for-each select="row">

            <concept loinc_num="{@LOINC_NUM}" status="{STATUS}" hl7_v3_dataType="{HL7_V3_DATATYPE}">
               <component length="{string-length(COMPONENT)}" count="{count(tokenize(COMPONENT,'\s'))}">
                  <xsl:value-of select="COMPONENT"/>
               </component>
               <property><xsl:value-of select="PROPERTY"/></property>
               <timing><xsl:value-of select="TIME_ASPCT"/></timing>
               <system><xsl:value-of select="SYSTEM"/></system>
               <scale><xsl:value-of select="SCALE_TYP"/></scale>
               <method><xsl:value-of select="METHOD_TYP"/></method>
               <exUCUMunits><xsl:value-of select="EXAMPLE_UCUM_UNITS"/></exUCUMunits>
               <exUnits><xsl:value-of select="EXAMPLE_UNITS"/></exUnits>
<!--               <rank><xsl:value-of select="COMPONENT"/></rank>-->
               <class><xsl:value-of select="CLASS"/></class>
               <longName length="{string-length(LONG_COMMON_NAME)}" count="{count(tokenize(LONG_COMMON_NAME,'\s'))}"><xsl:value-of select="LONG_COMMON_NAME"/></longName>
               <shortName length="{string-length(SHORTNAME )}" count="{count(tokenize(SHORTNAME ,'\s'))}"><xsl:value-of select="SHORTNAME "/></shortName>
<!--               <type><xsl:value-of select="COMPONENT"/></type>-->
               <orderObs><xsl:value-of select="ORDER_OBS"/></orderObs>
            </concept>

         </xsl:for-each>

      </loinc_db>
   </xsl:template>
</xsl:stylesheet>
