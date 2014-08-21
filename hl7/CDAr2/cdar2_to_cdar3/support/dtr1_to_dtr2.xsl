<?xml version="1.0" encoding="UTF-8"?>
<!--
    dtr1_to_dtr2.xsl
    Copyright (C) 2012-2013 Alexander-Henket, Nictiz, The Netherlands
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
-->
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:hl7="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xs xsi xd hl7 xsl" version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b>May 13, 2013</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> Alexander-Henket, Nictiz, The Netherlands</xd:p>
         <xd:p>
            <xd:b>Email:</xd:b> henket(a)nictiz.nl</xd:p>
         <xd:p>Maps all datatypes that are explicitly present in the CDAr2 specification. It may not map datatypes you explicitly declare in your instance, e.g. PPD_TS. Supported dtatypes are: 'AD','BL','BN','CD','CE','CO','CV','ED','EIVL_TS','EN','II','INT','IVL_INT','IVL_MO','IVL_PQ','IVL_REAL','IVL_TS','MO','ON', 'PIVL_TS','PN','PQ','REAL','RTO_PQ_PQ','SC','ST','TEL','TS'. In the event an unknown datatype is encountered, the XSL gives a message and terminates.</xd:p>
         <xd:p>
            <xd:b>NOTE:</xd:b> in datatypes R1 there used to be a qualifier element to coded elements. This no longer exists in datatypes R2. Hence this element is left out of the output. Instead a comment will be add to the output stating what was omitted leading to data loss. Example: <xd:pre> Could not map qualifier for: name/code="12313" name/codeSystem="1.34" name/displayName="3453" value/code="23123" value/codeSystem="1.2.3" value/displayName="dsf" </xd:pre>
         </xd:p>
         <xd:p>See <a href="http://vimeo.com/16813271">http://vimeo.com/16813271</a> for a video by Grahame Grieve on what changed in datatypes R2.</xd:p>
      </xd:desc>
   </xd:doc>
   
   <!-- If true() then converts all CDAr1/CDAr2 NarrativeBlock parts in Section.text to new style XHTML elements and attributes. If false() then copies as-is -->
   <xsl:param name="convertSectionTextToCDAr3Markup" select="true()" as="xs:boolean"/>
   
   <!-- Mapping of DTr1 elements to DTr2 types -->
   <xsl:variable name="postalMapping">
      <wrap>
         <map cdar2="additionalLocator" cdar3="ADL"/>
         <map cdar2="unitID" cdar3="UNID"/>
         <map cdar2="unitType" cdar3="UNIT"/>
         <map cdar2="deliveryAddressLine" cdar3="DAL"/>
         <map cdar2="deliveryInstallationType" cdar3="DINST"/>
         <map cdar2="deliveryInstallationArea" cdar3="DINSTA"/>
         <map cdar2="deliveryInstallationQualifier" cdar3="DINSTQ"/>
         <map cdar2="deliveryMode" cdar3="DMOD"/>
         <map cdar2="deliveryModeIdentifier" cdar3="DMODID"/>
         <map cdar2="streetAddressLine" cdar3="SAL"/>
         <map cdar2="houseNumber" cdar3="BNR"/>
         <map cdar2="houseNumberNumeric" cdar3="BNN"/>
         <map cdar2="buildingNumberSuffix" cdar3="BNS"/>
         <map cdar2="streetName" cdar3="STR"/>
         <map cdar2="streetNameBase" cdar3="STB"/>
         <map cdar2="streetNameType" cdar3="STTYP"/>
         <map cdar2="direction" cdar3="DIR"/>
         <map cdar2="careOf" cdar3="CAR"/>
         <map cdar2="censusTract" cdar3="CEN"/>
         <map cdar2="country" cdar3="CNT"/>
         <map cdar2="county" cdar3="CPA"/>
         <map cdar2="city" cdar3="CTY"/>
         <map cdar2="delimiter" cdar3="DEL"/>
         <map cdar2="postBox" cdar3="POB"/>
         <map cdar2="precinct" cdar3="PRE"/>
         <map cdar2="state" cdar3="STA"/>
         <map cdar2="postalCode" cdar3="ZIP"/>
      </wrap>
   </xsl:variable>

   <!-- infrastructureRootElements -->
   <xd:doc>
      <xd:desc>
         <xd:p>Handles transformation of infrastructureRoot attributes: realmCode, typeId, templateId</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template name="infrastructureRootElements">
      <xsl:call-template name="dt-CS-to-DSET_CS">
         <xsl:with-param name="in" select="hl7:realmCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="hl7:typeId"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:templateId"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-AD-to-AD -->
   <xd:doc>
      <xd:desc>
         <xd:p>Handles transformation of a single element of type AD (Address) to single element of type AD.</xd:p>
      </xd:desc>
      <xd:param name="in">input element to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-AD-to-AD">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@use|$in/@nullFlavor|$in/@xsi:type"/>
            <xsl:if test="$in/*:useablePeriod/*:low[@value]">
               <xsl:attribute name="validTimeLow" select="$in/*:useablePeriod/*:low/@value"/>
            </xsl:if>
            <xsl:if test="$in/*:useablePeriod/*:high[@value]">
               <xsl:attribute name="validTimeHigh" select="$in/*:useablePeriod/*:high/@value"/>
            </xsl:if>
            <xsl:for-each select="$in/text()[string-length(normalize-space(.))&gt;0]|$in/*[not(self::*:useablePeriod)]">
               <xsl:variable name="partType">
                  <xsl:variable name="partName" select="local-name()"/>
                  <xsl:value-of select="$postalMapping//map[@cdar2=$partName]/@cdar3"/>
               </xsl:variable>
               <xsl:element name="part" namespace="urn:hl7-org:v3">
                  <xsl:for-each select="@code|@codeSystem|@codeSystemName|@codeSystemVersion|@nullFlavor">
                     <xsl:attribute name="{name()}" select="."/>
                  </xsl:for-each>
                  <xsl:if test="string-length($partType)&gt;0">
                     <xsl:attribute name="type" select="$partType"/>
                  </xsl:if>
                  <xsl:attribute name="value" select="."/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-AD-to-COLL_AD -->
   <xd:doc>
      <xd:desc>
         <xd:p>Handles transformation of a single element of type AD (Address) to list of elements of type AD.</xd:p>
      </xd:desc>
      <xd:param name="in">input element to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-AD-to-COLL_AD">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
         <xsl:with-param name="dt" select="'DSET_AD'"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-AD-to-DSET_AD -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-AD-to-DSET_AD">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:if test="$in[1]/@xsi:type or string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="'DSET_AD'"/>
            </xsl:if>
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:for-each select="@use|@nullFlavor">
                     <xsl:attribute name="{name()}" select="."/>
                  </xsl:for-each>
                  <xsl:if test="*:useablePeriod/*:low[@value]">
                     <xsl:attribute name="validTimeLow" select="*:useablePeriod/*:low/@value"/>
                  </xsl:if>
                  <xsl:if test="*:useablePeriod/*:high[@value]">
                     <xsl:attribute name="validTimeHigh" select="*:useablePeriod/*:high/@value"/>
                  </xsl:if>
                  <xsl:for-each select="text()[string-length(normalize-space(.))&gt;0]|*[not(self::*:useablePeriod)]">
                     <xsl:variable name="partType">
                        <xsl:variable name="partName" select="local-name()"/>
                        <xsl:value-of select="$postalMapping//map[@cdar2=$partName]/@cdar3"/>
                     </xsl:variable>
                     <xsl:element name="part" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
                        <xsl:for-each select="@code|@codeSystem|@codeSystemName|@codeSystemVersion|@nullFlavor">
                           <xsl:attribute name="{name()}" select="."/>
                        </xsl:for-each>
                        <xsl:if test="string-length($partType)&gt;0">
                           <xsl:attribute name="type" select="$partType"/>
                        </xsl:if>
                        <xsl:attribute name="value" select="."/>
                     </xsl:element>
                  </xsl:for-each>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-ANY-to-ANY -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-ANY-to-ANY">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:choose>
            <xsl:when test="$in/@xsi:type='AD'">
               <xsl:call-template name="dt-AD-to-AD">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='BL'">
               <xsl:call-template name="dt-BL-to-BL">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='BN'">
               <xsl:call-template name="dt-BN-to-BN">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='CD'">
               <xsl:call-template name="dt-CD-to-CD">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='CE'">
               <xsl:call-template name="dt-CE-to-CE">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='CO'">
               <xsl:call-template name="dt-CO-to-CO">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='CV'">
               <xsl:call-template name="dt-CV-to-CV">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='ED'">
               <xsl:call-template name="dt-ED-to-ED">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='EIVL_TS'">
               <xsl:call-template name="dt-EIVL_TS-to-EIVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='EN'">
               <xsl:call-template name="dt-EN-to-EN">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='II'">
               <xsl:call-template name="dt-II-to-II">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='INT'">
               <xsl:call-template name="dt-INT-to-INT">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='IVL_INT'">
               <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='IVL_MO'">
               <xsl:call-template name="dt-IVL_MO-to-IVL_MO">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='IVL_PQ'">
               <xsl:call-template name="dt-IVL_PQ-to-IVL_PQ">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='IVL_REAL'">
               <xsl:call-template name="dt-IVL_REAL-to-IVL_REAL">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='IVL_TS'">
               <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='MO'">
               <xsl:call-template name="dt-MO-to-MO">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='ON'">
               <xsl:call-template name="dt-ON-to-ON">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='PIVL_TS'">
               <xsl:call-template name="dt-PIVL_TS-to-PIVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='PN'">
               <xsl:call-template name="dt-PN-to-PN">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='PQ'">
               <xsl:call-template name="dt-PQ-to-PQ">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='REAL'">
               <xsl:call-template name="dt-REAL-to-REAL">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='RTO_PQ_PQ'">
               <xsl:call-template name="dt-RTO_PQ_PQ-to-RTO_PQ_PQ">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='SC'">
               <xsl:call-template name="dt-SC-to-SC">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='ST'">
               <xsl:call-template name="dt-ST-to-ST">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='TEL'">
               <xsl:call-template name="dt-TEL-to-TEL">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='TS'">
               <xsl:call-template name="dt-TS-to-TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message terminate="yes"> ERROR Found unsupported datatype '<xsl:value-of select="$in/@xsi:type"/>' in <xsl:value-of select="$in[1]/name()"/>
               </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <!-- dt-BL-to-BL -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-BL-to-BL">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@value|$in/@nullFlavor|$in/@xsi:type"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-BN-to-BN -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-BN-to-BN">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-CD-to-CD -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CD-to-CD">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:if test="$in[@xsi:type]">
               <xsl:choose>
                  <xsl:when test="$in/@xsi:type='CO' or $in/@xsi:type='CS'">
                     <xsl:attribute name="xsi:type" select="$in/@xsi:type"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:attribute name="xsi:type" select="'CD'"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:if>
            <xsl:copy-of select="$in/@code|$in/@codeSystem|$in/@codeSystemName|$in/@codeSystemVersion|$in/@nullFlavor"/>
            <xsl:if test="$in[@displayName]">
               <xsl:element name="displayName" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
                  <xsl:attribute name="value" select="$in/@displayName"/>
               </xsl:element>
            </xsl:if>
            <xsl:call-template name="dt-ED-to-ED">
               <xsl:with-param name="in" select="$in/*:originalText"/>
               <xsl:with-param name="convertNamespace" select="true()"/>
            </xsl:call-template>
            <xsl:call-template name="dt-CR-to-DSET_CR">
               <xsl:with-param name="in" select="$in/*:qualifier"/>
               <xsl:with-param name="convertNamespace" select="true()"/>
            </xsl:call-template>
            <xsl:call-template name="dt-CD-to-CD">
               <xsl:with-param name="in" select="$in/*:translation"/>
               <xsl:with-param name="convertNamespace" select="true()"/>
            </xsl:call-template>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-CD-to-DSET_CD -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CD-to-DSET_CD">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:if test="$in[@xsi:type]">
               <xsl:attribute name="xsi:type" select="'DSET_CD'"/>
            </xsl:if>
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:for-each select="@code|@codeSystem|@codeSystemName|@codeSystemVersion|@nullFlavor">
                     <xsl:attribute name="{name()}" select="."/>
                  </xsl:for-each>
                  <xsl:if test="self::node()[@displayName]">
                     <xsl:element name="displayName" namespace="urn:hl7-org:v3">
                        <xsl:attribute name="value" select="@displayName"/>
                     </xsl:element>
                  </xsl:if>
                  <xsl:call-template name="dt-ED-to-ED">
                     <xsl:with-param name="in" select="*:originalText"/>
                     <xsl:with-param name="convertNamespace" select="true()"/>
                  </xsl:call-template>
                  <xsl:call-template name="dt-CR-to-DSET_CR">
                     <xsl:with-param name="in" select="*:qualifier"/>
                     <xsl:with-param name="convertNamespace" select="true()"/>
                  </xsl:call-template>
                  <xsl:call-template name="dt-CD-to-CD">
                     <xsl:with-param name="in" select="*:translation"/>
                     <xsl:with-param name="convertNamespace" select="true()"/>
                  </xsl:call-template>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-CE-to-CE -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CE-to-CE">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-CE-to-CD -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CE-to-CD">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-CE-to-DSET_CD -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CE-to-DSET_CD">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-CO-to-CO -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CO-to-CO">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@nullFlavor|$in/@xsi:type"/>
            <xsl:if test="$in[@code]">
               <xsl:element name="code" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="$in/@code|$in/@codeSystem|$in/@codeSystemName|$in/@codeSystemVersion|$in/@nullFlavor"/>
                  <xsl:if test="$in[@displayName]">
                     <xsl:element name="displayName" namespace="urn:hl7-org:v3">
                        <xsl:attribute name="value" select="$in/@displayName"/>
                     </xsl:element>
                  </xsl:if>
                  <xsl:call-template name="dt-ED-to-ED">
                     <xsl:with-param name="in" select="$in/*:originalText"/>
                     <xsl:with-param name="convertNamespace" select="true()"/>
                  </xsl:call-template>
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-CR-to-DSET_CR -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CR-to-DSET_CR">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:comment> Could not map qualifier for: <xsl:for-each select="$in/*:name/@code|$in/*:name/@codeSystem|$in/*:name/@displayName|$in/*:value/@code|$in/*:value/@codeSystem|$in/*:value/@displayName">
               <xsl:value-of select="concat(name(..),'/',name(),'=&#34;',.,'&#34; ')"/>
            </xsl:for-each>
         </xsl:comment>
      </xsl:if>
   </xsl:template>
   <!-- dt-CS-to-CS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CS-to-CS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@*"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-CS-to-CD -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="codeSystem"/>
   </xd:doc>
   <xsl:template name="dt-CS-to-CD">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="codeSystem"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@*"/>
            <xsl:if test="$in/@code">
               <xsl:attribute name="codeSystem" select="$codeSystem"/>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-CS-to-DSET_CS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CS-to-DSET_CS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@code|@nullFlavor"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-CV-to-CV -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-CV-to-CV">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-ED-to-ED -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-ED-to-ED">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@mediaType|$in/@language|$in/@compression|$in/@nullFlavor|$in/@xsi:type"/>
            <!-- SHA-1 is now SHA1 and SHA-256 is now SHA256 -->
            <xsl:if test="$in/@integrityCheckAlgorithm">
               <xsl:attribute name="integrityCheckAlgorithm" select="replace($in/@integrityCheckAlgorithm,'-','')"/>
            </xsl:if>
            <xsl:if test="$in/text()[string-length(normalize-space(.))&gt;0]">
               <xsl:choose>
                  <xsl:when test="$in/@representation='B64'">
                     <xsl:element name="data" namespace="urn:hl7-org:v3">
                        <xsl:copy-of select="$in/text()[string-length(normalize-space(.))&gt;0]"/>
                     </xsl:element>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:element name="xml" namespace="urn:hl7-org:v3">
                        <xsl:copy-of select="$in/text()[string-length(normalize-space(.))&gt;0]"/>
                     </xsl:element>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:if>
            <xsl:if test="$in/*:reference">
               <xsl:element name="reference" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="$in/*:reference/(@*|*)" copy-namespaces="no"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$in/*:thumbnail">
               <xsl:element name="thumbnail" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="$in/*:thumbnail/(@*|*)" copy-namespaces="no"/>
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-ED-to-DSET_ED -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-ED-to-DSET_ED">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:if test="$in[1]/@xsi:type or string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="'DSET_ED'"/>
            </xsl:if>
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@mediaType|@language|@compression|@nullFlavor|@xsi:type"/>
                  <!-- SHA-1 is now SHA1 and SHA-256 is now SHA256 -->
                  <xsl:if test="@integrityCheckAlgorithm">
                     <xsl:attribute name="integrityCheckAlgorithm" select="replace(@integrityCheckAlgorithm,'-','')"/>
                  </xsl:if>
                  <xsl:if test="text()[string-length(normalize-space(.))&gt;0]">
                     <xsl:choose>
                        <xsl:when test="@representation='B64'">
                           <xsl:element name="data" namespace="urn:hl7-org:v3">
                              <xsl:copy-of select="text()[string-length(normalize-space(.))&gt;0]"/>
                           </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:element name="xml" namespace="urn:hl7-org:v3">
                              <xsl:copy-of select="text()[string-length(normalize-space(.))&gt;0]"/>
                           </xsl:element>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:if>
                  <xsl:if test="*:reference">
                     <xsl:element name="reference" namespace="urn:hl7-org:v3">
                        <xsl:copy-of select="*:reference/(@*|*)" copy-namespaces="no"/>
                     </xsl:element>
                  </xsl:if>
                  <xsl:if test="*:thumbnail">
                     <xsl:element name="thumbnail" namespace="urn:hl7-org:v3">
                        <xsl:copy-of select="*:thumbnail/(@*|*)" copy-namespaces="no"/>
                     </xsl:element>
                  </xsl:if>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-EIVL_TS-to-EIVL_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-EIVL_TS-to-EIVL_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@nullFlavor|$in/@xsi:type"/>
            <xsl:if test="$in/*:event/@code">
               <xsl:attribute name="event" select="$in/*:event/@code"/>
            </xsl:if>
            <xsl:if test="$in/*:offset">
               <xsl:call-template name="dt-IVL_PQ-to-IVL_PQ">
                  <xsl:with-param name="in" select="$in/*:offset"/>
                  <xsl:with-param name="convertNamespace" select="true()"/>
               </xsl:call-template>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-EN-to-EN -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-EN-to-EN">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@nullFlavor|$in/@xsi:type"/>
            <!-- @use code 'L' needs to be 'C'. Only one other code with an 'L' which is 'SYL'. Replace SYL, replace L, restore SYL -->
            <xsl:if test="$in/@use">
               <xsl:attribute name="use" select="replace(replace(replace($in/@use,'SYL','SYK'),'L','C'),'SYK','SYL')"/>
            </xsl:if>
            <xsl:if test="$in/*:validTime/*:low[@value]">
               <xsl:attribute name="validTimeLow" select="$in/*:validTime/*:low/@value"/>
            </xsl:if>
            <xsl:if test="$in/*:validTime/*:high[@value]">
               <xsl:attribute name="validTimeHigh" select="$in/*:validTime/*:high/@value"/>
            </xsl:if>
            <xsl:for-each select="$in/text()[string-length(normalize-space(.))&gt;0]|$in/*[not(self::*:validTime)]">
               <xsl:variable name="partType">
                  <xsl:choose>
                     <xsl:when test="self::*:given or self::*:prefix or self::*:suffix">
                        <xsl:text>GIV</xsl:text>
                     </xsl:when>
                     <xsl:when test="self::*:family">
                        <xsl:text>FAM</xsl:text>
                     </xsl:when>
                     <xsl:when test="self::*:delimiter">
                        <xsl:text>DEL</xsl:text>
                     </xsl:when>
                     <xsl:when test="self::*:title">
                        <xsl:text>TITLE</xsl:text>
                     </xsl:when>
                  </xsl:choose>
               </xsl:variable>
               <xsl:variable name="partQualifier">
                  <xsl:variable name="partQualifierExtra">
                     <xsl:choose>
                        <xsl:when test="self::*:prefix">
                           <xsl:text> PFX</xsl:text>
                        </xsl:when>
                        <xsl:when test="self::*:suffix">
                           <xsl:text> SFX</xsl:text>
                        </xsl:when>
                     </xsl:choose>
                  </xsl:variable>
                  <xsl:value-of select="normalize-space(concat(@qualifier,$partQualifierExtra))"/>
               </xsl:variable>
               <xsl:element name="part" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
                  <xsl:for-each select="@code|@codeSystem|@codeSystemName|@codeSystemVersion|@nullFlavor">
                     <xsl:attribute name="{name()}" select="."/>
                  </xsl:for-each>
                  <xsl:if test="string-length($partType)&gt;0">
                     <xsl:attribute name="type" select="$partType"/>
                  </xsl:if>
                  <xsl:attribute name="value" select="."/>
                  <xsl:if test="string-length($partQualifier)&gt;0">
                     <xsl:attribute name="qualifier" select="$partQualifier"/>
                  </xsl:if>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-EN-to-COLL_EN -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-EN-to-COLL_EN">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
         <xsl:with-param name="dt" select="'DSET_EN'"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-EN-to-DSET_EN -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-EN-to-DSET_EN">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:if test="$in[1]/@xsi:type or string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="'DSET_EN'"/>
            </xsl:if>
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@nullFlavor|@xsi:type"/>
                  <!-- @use code 'L' needs to be 'C'. Only one other code with an 'L' which is 'SYL'. Replace SYL, replace L, restore SYL -->
                  <xsl:if test="@use">
                     <xsl:attribute name="use" select="replace(replace(replace(@use,'SYL','SYK'),'L','C'),'SYK','SYL')"/>
                  </xsl:if>
                  <xsl:if test="*:validTime/*:low[@value]">
                     <xsl:attribute name="validTimeLow" select="*:validTime/*:low/@value"/>
                  </xsl:if>
                  <xsl:if test="*:validTime/*:high[@value]">
                     <xsl:attribute name="validTimeHigh" select="*:validTime/*:high/@value"/>
                  </xsl:if>
                  <xsl:for-each select="text()[string-length(normalize-space(.))&gt;0]|*[not(self::*:validTime)]">
                     <xsl:variable name="partType">
                        <xsl:choose>
                           <xsl:when test="self::*:given or self::*:prefix or self::*:suffix">
                              <xsl:text>GIV</xsl:text>
                           </xsl:when>
                           <xsl:when test="self::*:family">
                              <xsl:text>FAM</xsl:text>
                           </xsl:when>
                           <xsl:when test="self::*:delimiter">
                              <xsl:text>DEL</xsl:text>
                           </xsl:when>
                           <xsl:when test="self::*:title">
                              <xsl:text>TITLE</xsl:text>
                           </xsl:when>
                        </xsl:choose>
                     </xsl:variable>
                     <xsl:variable name="partQualifier">
                        <xsl:variable name="partQualifierExtra">
                           <xsl:choose>
                              <xsl:when test="self::*:prefix">
                                 <xsl:text> PFX</xsl:text>
                              </xsl:when>
                              <xsl:when test="self::*:suffix">
                                 <xsl:text> SFX</xsl:text>
                              </xsl:when>
                           </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space(concat(@qualifier,$partQualifierExtra))"/>
                     </xsl:variable>
                     <xsl:element name="part" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
                        <xsl:for-each select="@code|@codeSystem|@codeSystemName|@codeSystemVersion|@nullFlavor">
                           <xsl:attribute name="{name()}" select="."/>
                        </xsl:for-each>
                        <xsl:if test="string-length($partType)&gt;0">
                           <xsl:attribute name="type" select="$partType"/>
                        </xsl:if>
                        <xsl:attribute name="value" select="."/>
                        <xsl:if test="string-length($partQualifier)&gt;0">
                           <xsl:attribute name="qualifier" select="$partQualifier"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:for-each>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-GTS-to-IVL_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-GTS-to-IVL_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:param name="dt"/>
      <xsl:call-template name="dt-IVL-to-IVL">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
         <xsl:with-param name="nm" select="$nm"/>
         <xsl:with-param name="dt" select="$dt"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-GTS-to-QSET_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-GTS-to-QSET_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:param name="dt"/>
      <xsl:call-template name="dt-SXCM_TS-to-QSET_TS">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-II-to-II -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-II-to-II">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/(@root|@extension|@nullFlavor|@xsi:type)"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-II-to-DSET_II -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-II-to-DSET_II">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@root|@extension|@nullFlavor|@xsi:type"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-INT-to-INT -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-INT-to-INT">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:copy-of select="$in/self::*"/>
   </xsl:template>
   <!-- dt-INT-to-ST -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-INT-to-ST">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:attribute name="value" select="$in/@value"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-INT-to-LIST_INT -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-INT-to-LIST_INT">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:if test="$in[1]/@xsi:type or string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="'LIST_INT'"/>
            </xsl:if>
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@*"/>
                  <xsl:copy-of select="*"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-INT-to-LIST_PQ (RegionOfInterest) -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-INT-to-LIST_PQ">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:if test="$in[1]/@xsi:type or string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="'LIST_PQ'"/>
            </xsl:if>
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@*"/>
                  <xsl:copy-of select="*"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-IVL-to-IVL -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-IVL-to-IVL">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{if (string-length($nm)&gt;0) then ($nm) else (local-name($in))}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@nullFlavor|$in/@xsi:type"/>
            <xsl:if test="string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="$dt"/>
            </xsl:if>
            <xsl:if test="$in/*:low/@inclusive">
               <xsl:attribute name="lowClosed" select="$in/*:low/@inclusive"/>
            </xsl:if>
            <xsl:if test="$in/*:high/@inclusive">
               <xsl:attribute name="highClosed" select="$in/*:high/@inclusive"/>
            </xsl:if>
            <xsl:for-each select="$in/*:low|$in/*:high|$in/width">
               <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@value|@unit|@nullFlavor"/>
                  <xsl:call-template name="dt-PQR-to-PQR">
                     <xsl:with-param name="in" select="*:translation"/>
                     <xsl:with-param name="convertNamespace" select="true()"/>
                  </xsl:call-template>
               </xsl:element>
            </xsl:for-each>
            <xsl:if test="$in[*:center]">
               <xsl:element name="any" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="$in/*:center/@value|$in/*:center/@unit|$in/*:center/@nullFlavor"/>
                  <xsl:call-template name="dt-PQR-to-PQR">
                     <xsl:with-param name="in" select="$in/*:center/*:translation"/>
                     <xsl:with-param name="convertNamespace" select="true()"/>
                  </xsl:call-template>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$in[@value or *:translation]">
               <xsl:element name="any" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="$in/@value|$in/@unit|$in/@nullFlavor"/>
                  <xsl:call-template name="dt-PQR-to-PQR">
                     <xsl:with-param name="in" select="$in/*:translation"/>
                     <xsl:with-param name="convertNamespace" select="true()"/>
                  </xsl:call-template>
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-IVL_INT-to-IVL_INT -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-IVL_INT-to-IVL_INT">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-IVL-to-IVL">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-IVL_MO-to-IVL_MO -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-IVL_MO-to-IVL_MO">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-IVL-to-IVL">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-IVL_PQ-to-IVL_PQ -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-IVL_PQ-to-IVL_PQ">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-IVL-to-IVL">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-IVL_PQ-to-PQ -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-IVL_PQ-to-PQ">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/(@nullFlavor|@unit|@value)"/>
            <xsl:copy-of select="$in/*:center/(@nullFlavor|@unit|@value)"/>
            <xsl:if test="$in/*:center/*:translation">
               <xsl:call-template name="dt-PQR-to-PQR">
                  <xsl:with-param name="in" select="$in/*:center/*:translation"/>
                  <xsl:with-param name="convertNamespace" select="true()"/>
               </xsl:call-template>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-PQR-to-PQR -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-PQR-to-PQR">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:for-each select="$in">
            <xsl:element name="{local-name()}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
               <xsl:copy-of select="@code|@codeSystem|@codeSystemName|@codeSystemVersion|@nullFlavor|@value"/>
               <xsl:if test="self::node()[@displayName]">
                  <xsl:element name="displayName" namespace="urn:hl7-org:v3">
                     <xsl:attribute name="value" select="@displayName"/>
                  </xsl:element>
               </xsl:if>
               <xsl:call-template name="dt-ED-to-ED">
                  <xsl:with-param name="in" select="*:originalText"/>
                  <xsl:with-param name="convertNamespace" select="true()"/>
               </xsl:call-template>
            </xsl:element>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>
   <!-- dt-IVL_REAL-to-IVL_REAL -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-IVL_REAL-to-IVL_REAL">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-IVL-to-IVL">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-IVL_TS-to-IVL_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-IVL_TS-to-IVL_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:param name="dt"/>
      <xsl:call-template name="dt-IVL-to-IVL">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
         <xsl:with-param name="nm" select="$nm"/>
         <xsl:with-param name="dt" select="$dt"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-IVL_TS-to-QSET_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-IVL_TS-to-QSET_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@nullFlavor"/>
            <xsl:attribute name="xsi:type" select="'IVL_TS'"/>
            <xsl:if test="$in/*:low/@inclusive">
               <xsl:attribute name="lowClosed" select="$in/*:low/@inclusive"/>
            </xsl:if>
            <xsl:if test="$in/*:high/@inclusive">
               <xsl:attribute name="highClosed" select="$in/*:high/@inclusive"/>
            </xsl:if>
            <xsl:for-each select="$in/*:low|$in/*:high|$in/width">
               <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@* except @inclusive"/>
               </xsl:element>
            </xsl:for-each>
            <xsl:if test="$in[*:center]">
               <xsl:element name="any" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="$in/*:center/(@value|@nullFlavor)"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$in[@value]">
               <xsl:element name="any" namespace="urn:hl7-org:v3">
                  <xsl:attribute name="value" select="$in/@value"/>
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-MO-to-MO -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-MO-to-MO">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@*" copy-namespaces="no"/>
            <xsl:for-each select="$in/*">
               <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@*|*" copy-namespaces="no"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-ON-to-ON -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-ON-to-ON">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-EN-to-EN">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-ON-to-DSET_EN -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-ON-to-DSET_EN">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-ON-to-EN -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-ON-to-EN">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-EN-to-EN">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-PIVL_TS-to-PIVL_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-PIVL_TS-to-PIVL_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{if (string-length($nm)&gt;0) then ($nm) else (local-name($in))}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/(@nullFlavor|@xsi:type)"/>
            <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
               <xsl:with-param name="in" select="$in/*:phase"/>
               <xsl:with-param name="convertNamespace" select="true()"/>
            </xsl:call-template>
            <xsl:call-template name="dt-PQ-to-PQ">
               <xsl:with-param name="in" select="$in/*:period"/>
               <xsl:with-param name="convertNamespace" select="true()"/>
            </xsl:call-template>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-PN-to-PN -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-PN-to-PN">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-EN-to-EN">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-PN-to-DSET_EN -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-PN-to-DSET_EN">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-PQ-to-PQ -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-PQ-to-PQ">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@*" copy-namespaces="no"/>
            <xsl:for-each select="$in/*">
               <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@*|*" copy-namespaces="no"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-REAL-to-REAL -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-REAL-to-REAL">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@*" copy-namespaces="no"/>
            <xsl:for-each select="$in/*">
               <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@*|*" copy-namespaces="no"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-RTO-to-RTO TODO: now assumes PQ_PQ where it might not be... -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-RTO-to-RTO">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:call-template name="dt-RTO_PQ_PQ-to-RTO_PQ_PQ">
            <xsl:with-param name="in" select="$in"/>
            <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>
   <!-- dt-RTO_PQ_PQ-to-RTO_PQ_PQ -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-RTO_PQ_PQ-to-RTO_PQ_PQ">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:attribute name="xsi:type" select="'RTO'"/>
            <xsl:for-each select="$in/*:numerator|$in/*:denominator">
               <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@*"/>
                  <xsl:attribute name="xsi:type" select="'PQ'"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-RTO-to-DSET_RTO -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-RTO-to-DSET_RTO">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:call-template name="dt-RTO_PQ_PQ-to-DSET_RTO">
            <xsl:with-param name="in" select="$in"/>
            <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>
   <!-- dt-RTO_PQ_PQ-to-DSET_RTO -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-RTO_PQ_PQ-to-DSET_RTO">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@xsi:type"/>
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@*"/>
                  <xsl:for-each select="*:numerator|*:denominator">
                     <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
                        <xsl:attribute name="xsi:type" select="'PQ'"/>
                        <xsl:copy-of select="@*"/>
                     </xsl:element>
                  </xsl:for-each>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-SC-to-SC -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-SC-to-SC">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@nullFlavor|$in/@language|$in/@xsi:type"/>
            <xsl:if test="$in/text()[string-length(.)&gt;0]">
               <xsl:attribute name="value" select="$in/text()"/>
            </xsl:if>
            <xsl:if test="count($in/@code|$in/@displayName)&gt;0">
               <xsl:element name="code" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="$in/(@code|@codeSystem|@codeSystemName|@codeSystemVersion)"/>
                  <xsl:if test="$in[@displayName]">
                     <xsl:element name="displayName" namespace="urn:hl7-org:v3">
                        <xsl:attribute name="value" select="$in/@displayName"/>
                     </xsl:element>
                  </xsl:if>
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-ST-to-ST -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-ST-to-ST">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in)}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@nullFlavor|$in/@xsi:type"/>
            <xsl:attribute name="value" select="$in/text()"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-SXCM_TS-to-SXCM_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-SXCM_TS-to-SXCM_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:if test="not(empty($in))">
         <xsl:choose>
            <xsl:when test="$in/@xsi:type='IVL_TS'">
               <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
                  <xsl:with-param name="nm" select="$nm"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='PIVL_TS'">
               <xsl:call-template name="dt-PIVL_TS-to-PIVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
                  <xsl:with-param name="nm" select="$nm"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='EIVL_TS'">
               <xsl:call-template name="dt-EIVL_TS-to-EIVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
                  <xsl:with-param name="nm" select="$nm"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in/@xsi:type='TS'">
               <xsl:call-template name="dt-TS-to-TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
                  <xsl:with-param name="nm" select="$nm"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="not($in/@xsi:type)">
               <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
                  <xsl:with-param name="nm" select="$nm"/>
                  <xsl:with-param name="dt" select="'IVL_TS'"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message terminate="yes"> ERROR Found unsupported datatype '<xsl:value-of select="$in/@xsi:type"/>' in <xsl:value-of select="$in[1]/name()"/>
               </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <!-- dt-SXCM_TS-to-IVL_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-SXCM_TS-to-IVL_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:choose>
            <xsl:when test="$in/@xsi:type='IVL_TS'">
               <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$in[not(@xsi:type)]">
               <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
                  <xsl:with-param name="in" select="$in"/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
                  <xsl:with-param name="dt" select="IVL_TS"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message terminate="yes"> ERROR Found unsupported datatype '<xsl:value-of select="$in/@xsi:type"/>' in <xsl:value-of select="$in[1]/name()"/>
               </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <!-- dt-SXCM_TS-to-QSET_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-SXCM_TS-to-QSET_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:attribute name="xsi:type" select="'QSI_TS'"/>
            <xsl:for-each select="$in">
               <xsl:call-template name="dt-SXCM_TS-to-SXCM_TS">
                  <xsl:with-param name="in" select="."/>
                  <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
                  <xsl:with-param name="nm" select="'term'"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-StrucDoc.Text-to-ED -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-StrucDoc.Text-to-ED">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <!-- TODO: @ID and @styleCode seem no longer supported in ED... missing anything without them? -->
            <!-- NOTE: not copying @mediaType as this has a default value and is updated from DTr1 (text/x-hl7-text+xml) to DTr2 (text/x-hl7-text+xml-r2)-->
            <xsl:copy-of select="$in/@language"/>
            <xsl:element name="xml" namespace="urn:hl7-org:v3">
               <xsl:choose>
                  <xsl:when test="$convertSectionTextToCDAr3Markup">
                     <xsl:apply-templates select="$in/node()" mode="NarrativeBlock"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:attribute name="xsi:type" select="'SD.TEXT'"/>
                     <xsl:copy-of select="$in/node()"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:element>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles (almost) any attribute in the Narrative Block</xd:p>
      </xd:desc>
      <xd:param name="in">element to process the attributes off</xd:param>
   </xd:doc>
   <xsl:template name="narrativeBlockAttributes">
      <xsl:param name="in"/>

      <xsl:variable name="styleContents">
         <!--
               Bold { font-weight: bold; }
               Underline { text-decoration:underline; }
               Italics { font-style:italic; }
               Emphasis { font-weight: bold;  letter-spacing:2px; }
               Lrule { border-left:1px solid black; }
               Rrule { border-right:1px solid black; } 
               Toprule { border-top:1px solid black; }
               Botrule { border-bottom:1px solid black; }
               Arabic { list-style: arabic; }
               LittleRoman { list-style: lower-roman; }
               BigRoman { list-style: upper-roman; }
               LittleAlpha { list-style: lower-alpha; }
               BigAlpha { list-style: upper-alpha; }
               Disc { list-style: disc; }
               Circle { list-style: circle; }
               Square { list-style: square; }
            -->
         <xsl:for-each select="tokenize($in/@styleCode,' ')">
            <xsl:choose>
               <!-- Font style (Defines font rendering characteristics.)-->
               <!-- Render with a bold font.-->
               <xsl:when test=".='Bold'">
                  <xsl:text>font-weight: bold; </xsl:text>
               </xsl:when>
               <!-- Render with an underlined font.-->
               <xsl:when test=".='Underline'">
                  <xsl:text>text-decoration:underline; </xsl:text>
               </xsl:when>
               <!-- Render italicized.-->
               <xsl:when test=".='Italics'">
                  <xsl:text>font-style:italic; </xsl:text>
               </xsl:when>
               <!-- Render with some type of emphasis.-->
               <xsl:when test=".='Emphasis'">
                  <xsl:text>font-weight: bold;  font-style:italic; </xsl:text>
               </xsl:when>
               <!-- Table rule style (Defines table cell rendering characteristics.)-->
               <xsl:when test=".='Lrule'">
                  <xsl:text>border-left:1px solid black; </xsl:text>
               </xsl:when>
               <!-- Render cell with left-sided rule.-->
               <xsl:when test=".='Rrule'">
                  <xsl:text>border-right:1px solid black; </xsl:text>
               </xsl:when>
               <!-- Render cell with right-sided rule.-->
               <xsl:when test=".='Toprule'">
                  <xsl:text>border-top:1px solid black; </xsl:text>
               </xsl:when>
               <!-- Render cell with rule on top.-->
               <xsl:when test=".='Botrule'">
                  <xsl:text>border-bottom:1px solid black; </xsl:text>
               </xsl:when>
               <!-- Render cell with rule on bottom.-->
               <!-- Ordered list style (Defines rendering characteristics for ordered lists.)-->
               <xsl:when test=".='Arabic'">
                  <xsl:text>list-style: arabic; </xsl:text>
               </xsl:when>
               <!-- List is ordered using Arabic numerals: 1, 2, 3.-->
               <xsl:when test=".='LittleRoman'">
                  <xsl:text>list-style: lower-roman; </xsl:text>
               </xsl:when>
               <!-- List is ordered using little Roman numerals: i, ii, iii.-->
               <xsl:when test=".='BigRoman'">
                  <xsl:text>list-style: upper-roman; </xsl:text>
               </xsl:when>
               <!-- List is ordered using big Roman numerals: I, II, III.-->
               <xsl:when test=".='LittleAlpha'">
                  <xsl:text>list-style: lower-alpha; </xsl:text>
               </xsl:when>
               <!-- List is ordered using little alpha characters: a, b, c.-->
               <xsl:when test=".='BigAlpha'">
                  <xsl:text>list-style: upper-alpha; </xsl:text>
               </xsl:when>
               <!-- List is ordered using big alpha characters: A, B, C.-->
               <!-- Unordered list style (Defines rendering characteristics for unordered lists.)-->
               <!-- List bullets are simple solid discs.-->
               <xsl:when test=".='Disc'">
                  <xsl:text>list-style: disc; </xsl:text>
               </xsl:when>
               <!-- List bullets are hollow discs.-->
               <xsl:when test=".='Circle'">
                  <xsl:text>list-style: circle; </xsl:text>
               </xsl:when>
               <!-- List bullets are solid squares.-->
               <xsl:when test=".='Square'">
                  <xsl:text>list-style: square; </xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message> *** WARNING: Skipping unknown @styleCode entry '<xsl:value-of select="."/>' on element <xsl:value-of select="string-join($in/ancestor-or-self::*/name(),'/')"/>.</xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>

         <xsl:if test="$in[@revised='delete']">
            <xsl:text>display: none; </xsl:text>
         </xsl:if>
      </xsl:variable>
      <xsl:if test="string-length(string-join($styleContents,''))>0">
         <xsl:attribute name="style" select="$styleContents"/>
      </xsl:if>

      <xsl:for-each select="$in/@*">
         <xsl:choose>
            <xsl:when test="name(.)='ID'">
               <xsl:attribute name="id" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='IDREF'"> </xsl:when>
            <xsl:when test="name(.)='align'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='axis'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='border'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='cellpadding'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='cellspacing'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='char'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='charoff'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='colspan'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='frame'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='headers'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='href'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='language'">
               <xsl:attribute name="lang" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='listType'">
               <!-- Handled in List element -->
            </xsl:when>
            <!--xsl:when test="name(.)='mediaType'"/-->
            <xsl:when test="name(.)='name'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='referencedObject'"> </xsl:when>
            <xsl:when test="name(.)='rel'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='rev'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="$in[@revised='delete']">
               <!-- Handled in style attribute -->
            </xsl:when>
            <xsl:when test="$in[@revised='insert']">
               <!-- Handle at all? CDAr1 compatibility mode -->
            </xsl:when>
            <xsl:when test="name(.)='rowspan'">
               <xsl:attribute name="rowspan" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='rules'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='scope'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='span'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='summary'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='title'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='valign'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>
            <xsl:when test="name(.)='width'">
               <xsl:attribute name="{name(.)}" select="."/>
            </xsl:when>

         </xsl:choose>
      </xsl:for-each>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles text, processing-instructions and comments by copying them as-is</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="text()|processing-instruction()|comment()" mode="NarrativeBlock">
      <xsl:copy/>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles br</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:br" mode="NarrativeBlock">
      <xsl:element name="br" namespace="urn:hl7-org:v3"/>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles caption</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:caption" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles col</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:col" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles colgroup</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:colgroup" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles content</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:content" mode="NarrativeBlock">
      <xsl:element name="span" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles footnote</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:footnote" mode="NarrativeBlock">
      <xsl:variable name="id" select="@ID"/>
      <xsl:variable name="footNoteNum" select="//hl7:footnote[@ID=$id]/position()"/>

      <xsl:element name="span" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <a name="{@ID}"/>
         <xsl:text>[</xsl:text>
         <xsl:value-of select="$footNoteNum"/>
         <xsl:text>] </xsl:text>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles footnoteRef</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:footnoteRef" mode="NarrativeBlock">
      <xsl:variable name="idref" select="@IDREF"/>
      <xsl:variable name="footNoteNum" select="//hl7:footnote[@ID=$idref]/position()"/>

      <sup>
         <xsl:text>[</xsl:text>
         <a href="#{$idref}">
            <xsl:value-of select="$footNoteNum"/>
         </a>
         <xsl:text>]</xsl:text>
      </sup>
      <xsl:text> </xsl:text>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles item</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:item" mode="NarrativeBlock">
      <xsl:element name="li" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles linkHtml</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:linkHtml" mode="NarrativeBlock">
      <xsl:element name="a" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles list</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:list" mode="NarrativeBlock">
      <xsl:choose>
         <xsl:when test="@listType='ordered'">
            <xsl:element name="ol" namespace="urn:hl7-org:v3">
               <xsl:call-template name="narrativeBlockAttributes">
                  <xsl:with-param name="in" select="."/>
               </xsl:call-template>
               <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:element name="ul" namespace="urn:hl7-org:v3">
               <xsl:call-template name="narrativeBlockAttributes">
                  <xsl:with-param name="in" select="."/>
               </xsl:call-template>
               <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles paragraph</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:paragraph" mode="NarrativeBlock">
      <xsl:element name="p" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles renderMultiMedia</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:renderMultiMedia" mode="NarrativeBlock">
      <xsl:element name="span" namespace="urn:hl7-org:v3">
         <xsl:for-each select="tokenize(@referencedObject,' ')">
            <xsl:element name="img" namespace="urn:hl7-org:v3">
               <xsl:attribute name="alt"/>
               <xsl:attribute name="src" select="."/>
               <!--float: left; border: 0px; margin-right: 5px; left aligns the images next to eachother, avoids a border (IE), and keeps some space around them (Top Right Bottom Left) -->
               <xsl:attribute name="style" select="'float: left; border: 0px; margin: 5px 5px 5px 5px; '"/>
            </xsl:element>
         </xsl:for-each>
         <xsl:if test="caption">
            <!-- display: block; makes the span go to the next line, underneath the image(s) -->
            <xsl:element name="span" namespace="urn:hl7-org:v3">
               <xsl:attribute name="style" select="'display: block; '"/>
               <xsl:apply-templates select="caption/node()"/>
            </xsl:element>
         </xsl:if>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles sub</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:sub" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles sup</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:sup" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles table</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:table" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles tbody</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:tbody" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles td</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:td" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:choose>
            <xsl:when test="@abbr">
               <xsl:element name="abbr" namespace="urn:hl7-org:v3">
                  <xsl:attribute name="title" select="@abbr"/>
                  <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles tfoot</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:tfoot" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles th</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:th" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:choose>
            <xsl:when test="@abbr">
               <xsl:element name="abbr" namespace="urn:hl7-org:v3">
                  <xsl:attribute name="title" select="@abbr"/>
                  <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles thead</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:thead" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Handles tr</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="hl7:tr" mode="NarrativeBlock">
      <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
         <xsl:call-template name="narrativeBlockAttributes">
            <xsl:with-param name="in" select="."/>
         </xsl:call-template>
         <xsl:apply-templates select="node()" mode="NarrativeBlock"/>
      </xsl:element>
   </xsl:template>
   <!-- dt-TEL-to-TEL -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-TEL-to-TEL">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@*" copy-namespaces="no"/>
            <xsl:for-each select="$in/*">
               <xsl:element name="{local-name()}" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@*|*" copy-namespaces="no"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-TEL-to-COLL_TEL -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
   </xd:doc>
   <xsl:template name="dt-TEL-to-COLL_TEL">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="$in"/>
         <xsl:with-param name="convertNamespace" select="$convertNamespace"/>
         <xsl:with-param name="dt" select="'DSET_AD'"/>
      </xsl:call-template>
   </xsl:template>
   <!-- dt-TEL-to-DSET_TEL -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-TEL-to-DSET_TEL">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{local-name($in[1])}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:if test="$in[1]/@xsi:type or string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="'DSET_TEL'"/>
            </xsl:if>
            <xsl:for-each select="$in">
               <xsl:element name="item" namespace="urn:hl7-org:v3">
                  <xsl:copy-of select="@use|@value|@nullFlavor"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-TS-to-TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-TS-to-TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{if (string-length($nm)&gt;0) then ($nm) else (local-name($in))}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/(@value|@nullFlavor|@xsi:type)"/>
            <xsl:if test="string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="$dt"/>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- dt-TS-to-IVL_TS -->
   <xd:doc>
      <xd:desc>
         <xd:p/>
      </xd:desc>
      <xd:param name="in">input element(s) to transform</xd:param>
      <xd:param name="convertNamespace">whether or not we should copy into HL7 namespace or leave as-is</xd:param>
      <xd:param name="nm">name of the element to create</xd:param>
      <xd:param name="dt">explicit datatype of the element to create</xd:param>
   </xd:doc>
   <xsl:template name="dt-TS-to-IVL_TS">
      <xsl:param name="in"/>
      <xsl:param name="convertNamespace" required="yes" as="xs:boolean"/>
      <xsl:param name="nm"/>
      <xsl:param name="dt"/>
      <xsl:if test="not(empty($in))">
         <xsl:element name="{if (string-length($nm)&gt;0) then ($nm) else (local-name($in))}" namespace="{if ($convertNamespace) then ('urn:hl7-org:v3') else (namespace-uri($in[1]))}">
            <xsl:copy-of select="$in/@nullFlavor"/>
            <xsl:if test="string-length($dt)&gt;0">
               <xsl:attribute name="xsi:type" select="$dt"/>
            </xsl:if>
            <xsl:if test="$in[@value]">
               <xsl:element name="any" namespace="urn:hl7-org:v3">
                  <xsl:attribute name="value" select="$in/@value"/>
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:if>
   </xsl:template>
</xsl:stylesheet>
