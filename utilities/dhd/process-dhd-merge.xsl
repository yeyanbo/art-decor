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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:output method="xml" exclude-result-prefixes="#all" encoding="UTF-8" indent="no"/>
   <xsl:key name="thesaurusDomeinId" match="thesaurusDomein" use="@ID_Thesaurus"/>
   <xsl:key name="specialisme" match="specialisme" use="@SpecialismeCode"/>
   <xsl:key name="term" match="term" use="@ID_Thesaurus"/>
   <xsl:key name="thesaurusIcd" match="thesaurusICD" use="@ID_Thesaurus"/>
   <xsl:key name="icd" match="ICD" use="@ICD10_Code"/>
   <xsl:key name="diagnoseDBC" match="diagnoseDBC" use="@ID_Thesaurus"/>
   <xsl:key name="dbc" match="DBC" use="concat(@SpecialismeCode,'-',@DiagnoseTypering)"/>
   <xsl:template match="/dhd">
      <thesaurus>
         <xsl:for-each select="mapping">
            <xsl:variable name="currentId" select="@ID_Thesaurus"/>
            <xsl:variable name="icdCode" select="@ICD10Code"/>
            <diagnose>
               <xsl:attribute name="thesaurusId">
                  <xsl:value-of select="$currentId"/>
               </xsl:attribute>
               <xsl:attribute name="snomedId">
                  <xsl:value-of select="@ID_Snomed"/>
               </xsl:attribute>
               <xsl:attribute name="snomedOmschrijving">
                  <xsl:value-of select="@Snomed_omschrijving"/>
               </xsl:attribute>
<!--               <xsl:attribute name="klasse">
                  <xsl:value-of select="@klasse"/>
               </xsl:attribute>
               <xsl:attribute name="versie">
                  <xsl:value-of select="@versie"/>
               </xsl:attribute>-->

               <!-- ICD10 -->
               <xsl:for-each select="key('thesaurusIcd',$currentId)">
                  <xsl:variable name="code" select="@ICD10_Code"/>
                  <icd10 volgorde="{@Volgorde}" code="{concat(substring($code,1,3),'.',substring($code,4,string-length($code)-3))}" term="{key('icd', $code)[1]/@DiagnoseTypering}"/>
               </xsl:for-each>
               <!-- DBC -->
               <xsl:for-each select="key('diagnoseDBC',$currentId)">
                  <xsl:variable name="key" select="concat(@SpecialismeCode,'-',@DiagnoseTypering)"/>
                  <dbc SpecialismeCode="{@SpecialismeCode}" Specialisme="{key('specialisme',xs:string(xs:decimal(@SpecialismeCode)))[1]/@Specialisme}" DiagnoseTypering="{@DiagnoseTypering}" DiagnoseOms="{key('dbc',$key)/@DiagnoseOms}"/>
               </xsl:for-each>

               <term type="referentie" count="{count(tokenize(@ReferentieTerm,'\s'))}" length="{string-length(@ReferentieTerm)}">
                  <xsl:value-of select="@ReferentieTerm"/>
               </term>
               <xsl:for-each select="key('term',$currentId)">
                  <term type="synoniem" count="{count(tokenize(@InterfaceTerm,'\s'))}" length="{string-length(@InterfaceTerm)}">
                     <xsl:value-of select="@InterfaceTerm"/>
                  </term>
               </xsl:for-each>
               <xsl:for-each select="key('thesaurusDomeinId', $currentId)">
                  <xsl:variable name="code" select="@SpecialismeCode"/>
                  <xsl:variable name="sub" select="@SubSpecialismeKort"/>
                  <xsl:copy-of select="//specialisme[@SpecialismeCode=$code][@SubSpecialismeKort=$sub]"/>
               </xsl:for-each>
            </diagnose>
         </xsl:for-each>
      </thesaurus>
   </xsl:template>
</xsl:stylesheet>
