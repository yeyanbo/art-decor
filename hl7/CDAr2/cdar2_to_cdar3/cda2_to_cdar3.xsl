<?xml version="1.0" encoding="UTF-8"?>
<!--
    cda2_to_cdar3.xsl
    Copyright (C) 2012-2013 Alexander Henket, Nictiz, The Netherlands
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
-->
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:hl7="urn:hl7-org:v3"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xs xsi xd hl7 xsl"
                version="2.0">
   <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
      <xd:desc xmlns="">
         <xd:p>
            <xd:b>Generated using cda2xsd_to_cdar3xsl.xsl on:</xd:b>May 21, 2013</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> Alexander Henket, Nictiz, The Netherlands</xd:p>
         <xd:p>
            <xd:b>Email:</xd:b> henket(a)nictiz.nl</xd:p>
         <xd:p>
            <xd:b>Quick Start:</xd:b> At execution time you may set the parameter convertSectionTextToCDAr3Markup to true (default) to convert the Section.text CDAr2 
                            style markup to CDAr3 style markup. Alternatively you may switch to 'compatibility mode' and copy Section.text as-is. <xd:pre>
                            java -jar saxon9.jar -xsl:cda2_to_cdar3.xsl -s:Sample1.CDAr2.xml convertSectionTextToCDAr3Markup=true</xd:pre>
         </xd:p>
         <xd:p>Maps any CDA release 2 to CDA release 3 based on May 2013 Ballot. <ul>
               <li>Class attributes (id, name, addr, etc.) are processed according to RIM order. If the class exists in CDAr3, it is copied into the HL7 V3 namespace. 
                                If the class does not exist in CDAr3, it is copied as-is. Since CDAr3 &gt;= CDAr2, it shall never be the case that something exists in CDAr2, but 
                                does not in CDAr3. There's one supported exception and that is CustodianOrganization.id which was moved to AssignedCustodian.id.</li>
               <li>Class associations (scoping, playing, ActRelationships, Participations) are handled by explicitly doing the defined element first, and then 
                            handling any extensions.</li>
            </ul>
         </xd:p>
         <xd:p>Maps all datatypes that are explicitly present in the CDAr2 specification. It may not map datatypes you explicitly declare in your instance, e.g. PPD_TS. 
                            Supported dtatypes are: 'AD','BL','BN','CD','CE','CO','CV','ED','EIVL_TS','EN','II','INT','IVL_INT','IVL_MO','IVL_PQ','IVL_REAL','IVL_TS','MO','ON',
                            'PIVL_TS','PN','PQ','REAL','RTO_PQ_PQ','SC','ST','TEL','TS'. In the event an unknown datatype is encountered, the XSL gives a message and terminates.</xd:p>
         <xd:p>
            <xd:b>NOTE:</xd:b> in datatypes R1 there used to be a qualifier element to coded elements. This no longer exists in datatypes R2. Hence this element is left
                        out of the output. Instead a comment will be add to the output stating what was omitted leading to data loss. Example: 
                            <xd:pre> Could not map qualifier for: name/code="12313" name/codeSystem="1.34" name/displayName="3453" value/code="23123" value/codeSystem="1.2.3" value/displayName="dsf" </xd:pre>
         </xd:p>
         <xd:p>See http://vimeo.com/16813271 for a video by Grahame Grieve on what changed in datatypes R2.</xd:p>
         <xd:p>CDAr2 was not completely moved over to CDAr3 as it currently stands. In the context of where data would/will not be mapped you'll find a comment that 
                            starts with 'Skipping mapping of'. Currently skipped elements include: 'POCD_MT000040.AuthoringDevice.asMaintainedEntity', 'POCD_MT000040.ClinicalDocument.copyTime',
                            'POCD_MT000040.MaintainedEntity.effectiveTime', 'POCD_MT000040.MaintainedEntity.maintainingPerson' and 'POCD_MT000040UV.Patient.id'</xd:p>
         <xd:p>
            <xd:b>Known issue:</xd:b> Could do a better job at converting the old-style Section.text to new-style HTML-like Section text. Currently done as-is. Posted request on the StrucDoc/ITS lists for guidance on the exact recommended method. </xd:p>
         <xd:p>
            <xd:b>Known issue:</xd:b> CDAr3 doesn't handle Section.ID, ObservationMedia.ID and RegioOfInterest.ID hence any referencing to these is off. Posted request on the StrucDoc/ITS lists to resolve. </xd:p>
      </xd:desc>
   </doc>

   <xsl:output indent="yes"/>

   <xsl:include href="support/dtr1_to_dtr2.xsl"/>

   <!-- Required codeSystem OIDs for CDAr2 CS elements that are CD in CDAr3 -->
   <xsl:variable name="oidActCode">2.16.840.1.113883.5.4</xsl:variable>
   <xsl:variable name="oidParticipationSignature">2.16.840.1.113883.5.89</xsl:variable>
   <xsl:variable name="oidHumanLanguage">2.16.840.1.113883.5.121</xsl:variable>

   <!-- Main template. Copies just the ClinicalDocument element --><xsl:template match="/">
      <xsl:apply-templates select="hl7:ClinicalDocument"/>
   </xsl:template>

   <!-- ClinicalDocument template. Adds schemaLocation to the ClinicalDocument element. --><xsl:template match="hl7:ClinicalDocument">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:attribute name="xsi:schemaLocation"
                        select="'urn:hl7-org:v3 cdar3schemas/multicacheschemas/CDA.xsd'"/>
         <xsl:apply-templates select="self::*" mode="POCD_MT000040.ClinicalDocument"/>
      </xsl:copy>
   </xsl:template>

   <!--POCD_MT000040.Act-->
   <xsl:template match="*" mode="POCD_MT000040.Act">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entryRelationship">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EntryRelationship"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.AssignedAuthor-->
   <xsl:template match="*" mode="POCD_MT000040.AssignedAuthor">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedPerson">
         <xsl:element name="{if (ancestor::hl7:entry) then ('playingPerson') else ('assignedPerson')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PSN'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Person"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:assignedAuthoringDevice">
         <xsl:element name="{if (ancestor::hl7:entry) then ('playingDevice') else ('assignedDevice')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'DEV'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AuthoringDevice"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:representedOrganization">
         <xsl:element name="{if (ancestor::hl7:entry) then ('scopingOrganization') else ('representedOrganization')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.AssignedCustodian-->
   <xsl:template match="*" mode="POCD_MT000040.AssignedCustodian">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <!-- patch for moved attribute --><xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:representedCustodianOrganization/hl7:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-COLL_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:representedCustodianOrganization">
         <xsl:element name="representedCustodianOrganization" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.CustodianOrganization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.AssignedEntity-->
   <xsl:template match="*" mode="POCD_MT000040.AssignedEntity">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedPerson">
         <xsl:element name="{if (ancestor::hl7:entry) then ('playingPerson') else ('assignedPerson')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PSN'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Person"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:representedOrganization">
         <xsl:element name="{if (ancestor::hl7:entry) then ('scopingOrganization') else ('representedOrganization')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.AssociatedEntity-->
   <xsl:template match="*" mode="POCD_MT000040.AssociatedEntity">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-COLL_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:associatedPerson">
         <xsl:element name="associatedPerson" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PSN'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Person"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:scopingOrganization">
         <xsl:element name="scopingOrganization" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Authenticator-->
   <xsl:template match="*" mode="POCD_MT000040.Authenticator">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="hl7:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidParticipationSignature"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedEntity">
         <xsl:element name="assignedEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Author-->
   <xsl:template match="*" mode="POCD_MT000040.Author">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:functionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:choose>
         <xsl:when test="ancestor::hl7:entry">
            <xsl:call-template name="dt-TS-to-IVL_TS">
               <xsl:with-param name="in" select="hl7:time"/>
               <xsl:with-param name="convertNamespace" select="false()"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="dt-TS-to-TS">
               <xsl:with-param name="in" select="hl7:time"/>
               <xsl:with-param name="convertNamespace" select="false()"/>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedAuthor">
         <xsl:element name="{if (ancestor::hl7:entry) then ('role') else ('assignedAuthor')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedAuthor"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.AuthoringDevice-->
   <xsl:template match="*" mode="POCD_MT000040.AuthoringDevice">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:formCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:lotNumberText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:expirationTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:stabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-SC-to-SC">
         <xsl:with-param name="in" select="hl7:manufacturerModelName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-SC-to-SC">
         <xsl:with-param name="in" select="hl7:softwareName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:localRemoteControlStateCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:alertLevelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:lastCalibrationTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Skipping mapping of 'POCD_MT000040.AuthoringDevice.asMaintainedEntity', because there is no matching 'POCD_MT000040UV.Device.asMaintainedEntity' --><!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','formCode','lotNumberText','expirationTime','stabilityTime','manufacturerModelName','softwareName','localRemoteControlStateCode','alertLevelCode','lastCalibrationTime'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Authorization-->
   <xsl:template match="*" mode="POCD_MT000040.Authorization">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:consent">
         <xsl:element name="consent" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Consent"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Birthplace-->
   <xsl:template match="*" mode="POCD_MT000040.Birthplace">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:mobileInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:directionsText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:positionText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:gpsText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:place">
         <xsl:element name="birthplace" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PLC'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Place"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','mobileInd','addr','directionsText','positionText','gpsText'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ClinicalDocument-->
   <xsl:template match="*" mode="POCD_MT000040.ClinicalDocument">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="hl7:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="hl7:setId"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-ST">
         <xsl:with-param name="in" select="hl7:versionNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:completionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:storageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="hl7:copyTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-DSET_ED">
         <xsl:with-param name="in" select="*:bibliographicDesignationText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:recordTarget">
         <xsl:element name="recordTarget" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.RecordTarget"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="author" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:dataEnterer">
         <xsl:element name="dataEnterer" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.DataEnterer"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="informant" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:custodian">
         <xsl:element name="custodian" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Custodian"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informationRecipient">
         <xsl:element name="informationRecipient" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCP'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.InformationRecipient"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:legalAuthenticator">
         <xsl:element name="legalAuthenticator" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.LegalAuthenticator"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:authenticator">
         <xsl:element name="authenticator" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Authenticator"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation1" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant1"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:inFulfillmentOf">
         <xsl:element name="inFulfillmentOf" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'FLFS'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="blockedContextParticipationType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'PART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="true()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.InFulfillmentOf"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:documentationOf">
         <xsl:element name="documentationOf" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'DOC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="blockedContextParticipationType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'PART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="true()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.DocumentationOf"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:relatedDocument">
         <xsl:element name="relatedDocument" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="blockedContextParticipationType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'PART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="true()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.RelatedDocument"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:authorization">
         <xsl:element name="authorization" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUTH'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="blockedContextParticipationType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'PART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="true()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Authorization"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:component">
         <xsl:element name="component" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="false()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Component2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:componentOf">
         <xsl:element name="componentOf" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'COMP'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="blockedContextParticipationType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'PART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="true()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Component1"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','setId','versionNumber','completionCode','storageCode','copyTime','bibliographicDesignationText'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Component1-->
   <xsl:template match="*" mode="POCD_MT000040.Component1">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:encompassingEncounter">
         <xsl:element name="encompassingEncounter" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EncompassingEncounter"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Component2-->
   <xsl:template match="*" mode="POCD_MT000040.Component2">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:nonXMLBody">
         <xsl:element name="nonStructuredBody" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.NonXMLBody"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:structuredBody">
         <xsl:element name="structuredBody" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.StructuredBody"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Component3-->
   <xsl:template match="*" mode="POCD_MT000040.Component3">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:section">
         <xsl:element name="section" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Section"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Component4-->
   <xsl:template match="*" mode="POCD_MT000040.Component4">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="hl7:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="hl7:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:act">
         <xsl:element name="act" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Act"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:encounter">
         <xsl:element name="encounter" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Encounter"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:observation">
         <xsl:element name="observation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Observation"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:observationMedia">
         <xsl:element name="observationMedia" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ObservationMedia"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:organizer">
         <xsl:element name="{if (@classCode='CLUSTER') then ('composition') else ('observation')}"
                      namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="@classCode='CLUSTER'">
               <xsl:attribute name="classCode" select="'COMPOSITION'"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organizer"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:procedure">
         <xsl:element name="procedure" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Procedure"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:regionOfInterest">
         <xsl:element name="regionOfInterest" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.RegionOfInterest"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:substanceAdministration">
         <xsl:element name="substanceAdministration" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.SubstanceAdministration"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:supply">
         <xsl:element name="supply" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Supply"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Component5-->
   <xsl:template match="*" mode="POCD_MT000040.Component5">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:section">
         <xsl:element name="section" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Section"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Consent-->
   <xsl:template match="*" mode="POCD_MT000040.Consent">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Consumable-->
   <xsl:template match="*" mode="POCD_MT000040.Consumable">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:manufacturedProduct">
         <xsl:element name="role" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ROL'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ManufacturedProduct"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Criterion-->
   <xsl:template match="*" mode="POCD_MT000040.Criterion">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ANY-to-ANY">
         <xsl:with-param name="in" select="hl7:value"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:valueNegationInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:interpretationCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','value','valueNegationInd','interpretationCode','methodCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Custodian-->
   <xsl:template match="*" mode="POCD_MT000040.Custodian">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:time"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedCustodian">
         <xsl:element name="assignedCustodian" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedCustodian"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.CustodianOrganization-->
   <xsl:template match="*" mode="POCD_MT000040.CustodianOrganization">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <!-- Skipping mapping of 'POCD_MT000040.CustodianOrganization.id', because there is no matching 'POCD_MT000040UV.CustodianOrganization.id' --><xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ON-to-EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:standardIndustryClassCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','addr','standardIndustryClassCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.DataEnterer-->
   <xsl:template match="*" mode="POCD_MT000040.DataEnterer">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="hl7:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedEntity">
         <xsl:element name="assignedEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Device-->
   <xsl:template match="*" mode="POCD_MT000040.Device">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:formCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:lotNumberText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:expirationTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:stabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-SC-to-SC">
         <xsl:with-param name="in" select="hl7:manufacturerModelName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-SC-to-SC">
         <xsl:with-param name="in" select="hl7:softwareName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:localRemoteControlStateCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:alertLevelCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:lastCalibrationTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','formCode','lotNumberText','expirationTime','stabilityTime','manufacturerModelName','softwareName','localRemoteControlStateCode','alertLevelCode','lastCalibrationTime'))]"/>
   </xsl:template>

   <!--POCD_MT000040.DocumentationOf-->
   <xsl:template match="*" mode="POCD_MT000040.DocumentationOf">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:serviceEvent">
         <xsl:element name="serviceEvent" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ServiceEvent"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.EncompassingEncounter-->
   <xsl:template match="*" mode="POCD_MT000040.EncompassingEncounter">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:admissionReferralSourceCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:lengthOfStayQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:dischargeDispositionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:preAdmitTestInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:specialCourtesiesCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:specialArrangementCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:responsibleParty">
         <xsl:element name="responsibleParty" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ResponsibleParty"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:encounterParticipant">
         <xsl:element name="encounterParticipant" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EncounterParticipant"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:location">
         <xsl:element name="location" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'LOC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Location"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','admissionReferralSourceCode','lengthOfStayQuantity','dischargeDispositionCode','preAdmitTestInd','specialCourtesiesCode','specialArrangementCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Encounter-->
   <xsl:template match="*" mode="POCD_MT000040.Encounter">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:admissionReferralSourceCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:lengthOfStayQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:dischargeDispositionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:preAdmitTestInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:specialCourtesiesCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:specialArrangementCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entryRelationship">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EntryRelationship"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','admissionReferralSourceCode','lengthOfStayQuantity','dischargeDispositionCode','preAdmitTestInd','specialCourtesiesCode','specialArrangementCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.EncounterParticipant-->
   <xsl:template match="*" mode="POCD_MT000040.EncounterParticipant">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedEntity">
         <xsl:element name="assignedEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Entity-->
   <xsl:template match="*" mode="POCD_MT000040.Entity">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:desc"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Entry-->
   <xsl:template match="*" mode="POCD_MT000040.Entry">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:act">
         <xsl:element name="act" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Act"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:encounter">
         <xsl:element name="encounter" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Encounter"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:observation">
         <xsl:element name="observation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Observation"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:observationMedia">
         <xsl:element name="observationMedia" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ObservationMedia"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:organizer">
         <xsl:element name="{if (@classCode='CLUSTER') then ('composition') else ('observation')}"
                      namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="@classCode='CLUSTER'">
               <xsl:attribute name="classCode" select="'COMPOSITION'"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organizer"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:procedure">
         <xsl:element name="procedure" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Procedure"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:regionOfInterest">
         <xsl:element name="regionOfInterest" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.RegionOfInterest"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:substanceAdministration">
         <xsl:element name="substanceAdministration" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.SubstanceAdministration"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:supply">
         <xsl:element name="supply" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Supply"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.EntryRelationship-->
   <xsl:template match="*" mode="POCD_MT000040.EntryRelationship">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="hl7:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="hl7:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:act">
         <xsl:element name="act" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Act"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:encounter">
         <xsl:element name="encounter" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Encounter"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:observation">
         <xsl:element name="observation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Observation"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:observationMedia">
         <xsl:element name="observationMedia" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ObservationMedia"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:organizer">
         <xsl:element name="{if (@classCode='CLUSTER') then ('composition') else ('observation')}"
                      namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="@classCode='CLUSTER'">
               <xsl:attribute name="classCode" select="'COMPOSITION'"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organizer"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:procedure">
         <xsl:element name="procedure" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Procedure"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:regionOfInterest">
         <xsl:element name="regionOfInterest" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.RegionOfInterest"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:substanceAdministration">
         <xsl:element name="substanceAdministration" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.SubstanceAdministration"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:supply">
         <xsl:element name="supply" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Supply"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ExternalAct-->
   <xsl:template match="*" mode="POCD_MT000040.ExternalAct">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ExternalDocument-->
   <xsl:template match="*" mode="POCD_MT000040.ExternalDocument">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="hl7:setId"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-ST">
         <xsl:with-param name="in" select="hl7:versionNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:completionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:storageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:copyTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-DSET_ED">
         <xsl:with-param name="in" select="*:bibliographicDesignationText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','setId','versionNumber','completionCode','storageCode','copyTime','bibliographicDesignationText'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ExternalObservation-->
   <xsl:template match="*" mode="POCD_MT000040.ExternalObservation">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ANY-to-ANY">
         <xsl:with-param name="in" select="*:value"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:valueNegationInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:interpretationCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','value','valueNegationInd','interpretationCode','methodCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ExternalProcedure-->
   <xsl:template match="*" mode="POCD_MT000040.ExternalProcedure">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:approachSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','methodCode','approachSiteCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Guardian-->
   <xsl:template match="*" mode="POCD_MT000040.Guardian">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:guardianPerson">
         <xsl:element name="guardianPerson" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PSN'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Person"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:guardianOrganization">
         <xsl:element name="guardianOrganization" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.HealthCareFacility-->
   <xsl:template match="*" mode="POCD_MT000040.HealthCareFacility">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-COLL_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:location">
         <xsl:element name="playingPlace" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PLC'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Place"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:serviceProviderOrganization">
         <xsl:element name="scopingOrganization" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Informant12-->
   <xsl:template match="*" mode="POCD_MT000040.Informant12">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:choose>
         <xsl:when test="ancestor::hl7:entry">
            <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
               <xsl:with-param name="in" select="hl7:time"/>
               <xsl:with-param name="convertNamespace" select="false()"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
               <xsl:with-param name="in" select="hl7:time"/>
               <xsl:with-param name="convertNamespace" select="false()"/>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedEntity">
         <xsl:element name="{if (ancestor::hl7:entry) then ('role') else ('assignedEntity')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:relatedEntity">
         <xsl:element name="{if (ancestor::hl7:entry) then ('role') else ('relatedEntity')}"
                      namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.RelatedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.InformationRecipient-->
   <xsl:template match="*" mode="POCD_MT000040.InformationRecipient">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:time"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:intendedRecipient">
         <xsl:element name="intendedRecipient" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.IntendedRecipient"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.InFulfillmentOf-->
   <xsl:template match="*" mode="POCD_MT000040.InFulfillmentOf">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:order">
         <xsl:element name="order" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ACT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Order"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.IntendedRecipient-->
   <xsl:template match="*" mode="POCD_MT000040.IntendedRecipient">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:informationRecipient">
         <xsl:element name="informationRecipient" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PSN'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Person"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:receivedOrganization">
         <xsl:element name="receivedOrganization" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.LabeledDrug-->
   <xsl:template match="*" mode="POCD_MT000040.LabeledDrug">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:formCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:lotNumberText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:expirationTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:stabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','formCode','lotNumberText','expirationTime','stabilityTime'))]"/>
   </xsl:template>

   <!--POCD_MT000040.LanguageCommunication-->
   <xsl:template match="*" mode="POCD_MT000040.LanguageCommunication">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:modeCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:proficiencyLevelCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="hl7:preferenceInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('languageCode','modeCode','proficiencyLevelCode','preferenceInd'))]"/>
   </xsl:template>

   <!--POCD_MT000040.LegalAuthenticator-->
   <xsl:template match="*" mode="POCD_MT000040.LegalAuthenticator">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="hl7:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidParticipationSignature"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedEntity">
         <xsl:element name="assignedEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Location-->
   <xsl:template match="*" mode="POCD_MT000040.Location">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:time"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:healthCareFacility">
         <xsl:element name="healthCareFacility" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'SDLOC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.HealthCareFacility"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.MaintainedEntity-->
   <xsl:template match="*" mode="POCD_MT000040.MaintainedEntity">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-COLL_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-QSET_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Skipping mapping of 'POCD_MT000040.MaintainedEntity.maintainingPerson', because there is no matching 'POCD_MT000040UV.MaintainedEntity.maintainingPerson' --><!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ManufacturedProduct-->
   <xsl:template match="*" mode="POCD_MT000040.ManufacturedProduct">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:manufacturedLabeledDrug">
         <xsl:element name="playingManufacturedMaterial" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'MMAT'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.LabeledDrug"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:manufacturedMaterial">
         <xsl:element name="playingManufacturedMaterial" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'MMAT'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Material"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:manufacturerOrganization">
         <xsl:element name="scopingOrganization" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Material-->
   <xsl:template match="*" mode="POCD_MT000040.Material">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:formCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="hl7:lotNumberText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:expirationTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:stabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','formCode','lotNumberText','expirationTime','stabilityTime'))]"/>
   </xsl:template>

   <!--POCD_MT000040.NonXMLBody-->
   <xsl:template match="*" mode="POCD_MT000040.NonXMLBody">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="*:setId"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:versionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:completionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:storageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:copyTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-DSET_ED">
         <xsl:with-param name="in" select="*:bibliographicDesignationText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','setId','versionNumber','completionCode','storageCode','copyTime','bibliographicDesignationText'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Observation-->
   <xsl:template match="*" mode="POCD_MT000040.Observation">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="hl7:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="hl7:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ANY-to-ANY">
         <xsl:with-param name="in" select="hl7:value"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:valueNegationInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:interpretationCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:methodCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entryRelationship">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EntryRelationship"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:referenceRange">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'REFV'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ReferenceRange"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','value','valueNegationInd','interpretationCode','methodCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ObservationMedia-->
   <xsl:template match="*" mode="POCD_MT000040.ObservationMedia">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:value"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:valueNegationInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:interpretationCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entryRelationship">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EntryRelationship"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','value','valueNegationInd','interpretationCode','methodCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ObservationRange-->
   <xsl:template match="*" mode="POCD_MT000040.ObservationRange">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ANY-to-ANY">
         <xsl:with-param name="in" select="hl7:value"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:valueNegationInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:interpretationCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','value','valueNegationInd','interpretationCode','methodCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Order-->
   <xsl:template match="*" mode="POCD_MT000040.Order">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ANY-to-ANY">
         <xsl:with-param name="in" select="*:value"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:valueNegationInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:interpretationCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','value','valueNegationInd','interpretationCode','methodCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Organization-->
   <xsl:template match="*" mode="POCD_MT000040.Organization">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ON-to-DSET_EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:standardIndustryClassCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:asOrganizationPartOf">
         <xsl:element name="asOrganizationPartOf" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PART'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.OrganizationPartOf"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','addr','standardIndustryClassCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.OrganizationPartOf-->
   <xsl:template match="*" mode="POCD_MT000040.OrganizationPartOf">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-COLL_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:wholeOrganization">
         <xsl:element name="wholeOrganization" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Organizer-->
   <xsl:template match="*" mode="POCD_MT000040.Organizer">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-QSET_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ANY-to-ANY">
         <xsl:with-param name="in" select="*:value"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:valueNegationInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:interpretationCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:component">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'COMP'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Component4"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','value','valueNegationInd','interpretationCode','methodCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ParentDocument-->
   <xsl:template match="*" mode="POCD_MT000040.ParentDocument">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="hl7:setId"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-ST">
         <xsl:with-param name="in" select="hl7:versionNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:completionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:storageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:copyTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-DSET_ED">
         <xsl:with-param name="in" select="*:bibliographicDesignationText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','setId','versionNumber','completionCode','storageCode','copyTime','bibliographicDesignationText'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Participant1-->
   <xsl:template match="*" mode="POCD_MT000040.Participant1">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:functionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:associatedEntity">
         <xsl:element name="associatedEntity" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssociatedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Participant2-->
   <xsl:template match="*" mode="POCD_MT000040.Participant2">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:participantRole">
         <xsl:element name="role" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ROL'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ParticipantRole"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ParticipantRole-->
   <xsl:template match="*" mode="POCD_MT000040.ParticipantRole">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:playingDevice">
         <xsl:element name="playingDevice" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'DEV'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Device"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:playingEntity">
         <xsl:element name="playingEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ENT'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.PlayingEntity"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:scopingEntity">
         <xsl:element name="scopingEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ENT'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Entity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Patient-->
   <xsl:template match="*" mode="POCD_MT000040.Patient">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PN-to-DSET_EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:administrativeGenderCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="hl7:birthTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:deceasedInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:deceasedTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:multipleBirthInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:multipleBirthOrderNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:organDonorInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-COLL_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:maritalStatusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:educationLevelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:disabilityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:livingArrangementCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:religiousAffiliationCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:raceCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:ethnicGroupCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:guardian">
         <xsl:element name="guardian" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Guardian"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:birthplace">
         <xsl:element name="birthplace" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Birthplace"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:languageCommunication">
         <xsl:element name="languageCommunication" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.LanguageCommunication"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','administrativeGenderCode','birthTime','deceasedInd','deceasedTime','multipleBirthInd','multipleBirthOrderNumber','organDonorInd','addr','maritalStatusCode','educationLevelCode','disabilityCode','livingArrangementCode','religiousAffiliationCode','raceCode','ethnicGroupCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.PatientRole-->
   <xsl:template match="*" mode="POCD_MT000040.PatientRole">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:veryImportantPersonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:patient">
         <xsl:element name="patient" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PSN'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Patient"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:providerOrganization">
         <xsl:element name="providerOrganization" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ORG'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Organization"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber','veryImportantPersonCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Performer1-->
   <xsl:template match="*" mode="POCD_MT000040.Performer1">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:functionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedEntity">
         <xsl:element name="assignedEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Performer2-->
   <xsl:template match="*" mode="POCD_MT000040.Performer2">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:modeCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedEntity">
         <xsl:element name="role" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Person-->
   <xsl:template match="*" mode="POCD_MT000040.Person">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PN-to-DSET_EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:administrativeGenderCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:birthTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:deceasedInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:deceasedTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:multipleBirthInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:multipleBirthOrderNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:organDonorInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-COLL_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:maritalStatusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:educationLevelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:disabilityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:livingArrangementCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:religiousAffiliationCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:raceCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:ethnicGroupCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','administrativeGenderCode','birthTime','deceasedInd','deceasedTime','multipleBirthInd','multipleBirthOrderNumber','organDonorInd','addr','maritalStatusCode','educationLevelCode','disabilityCode','livingArrangementCode','religiousAffiliationCode','raceCode','ethnicGroupCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Place-->
   <xsl:template match="*" mode="POCD_MT000040.Place">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:mobileInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:directionsText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:positionText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:gpsText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','mobileInd','addr','directionsText','positionText','gpsText'))]"/>
   </xsl:template>

   <!--POCD_MT000040.PlayingEntity-->
   <xsl:template match="*" mode="POCD_MT000040.PlayingEntity">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="hl7:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PN-to-DSET_EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:desc"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Precondition-->
   <xsl:template match="*" mode="POCD_MT000040.Precondition">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:criterion">
         <xsl:element name="observation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'OBS'"/>
            <xsl:attribute name="moodCode" select="'EVN.CRT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Criterion"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Procedure-->
   <xsl:template match="*" mode="POCD_MT000040.Procedure">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:methodCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:approachSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entryRelationship">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EntryRelationship"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','methodCode','approachSiteCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Product-->
   <xsl:template match="*" mode="POCD_MT000040.Product">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:manufacturedProduct">
         <xsl:element name="role" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ManufacturedProduct"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.RecordTarget-->
   <xsl:template match="*" mode="POCD_MT000040.RecordTarget">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:time"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:patientRole">
         <xsl:element name="patientRole" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.PatientRole"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Reference-->
   <xsl:template match="*" mode="POCD_MT000040.Reference">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="hl7:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:externalAct">
         <xsl:element name="act" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ACT'"/>
            <xsl:attribute name="moodCode" select="'EVN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ExternalAct"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:externalObservation">
         <xsl:element name="observation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'OBS'"/>
            <xsl:attribute name="moodCode" select="'EVN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ExternalObservation"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:externalProcedure">
         <xsl:element name="procedure" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PROC'"/>
            <xsl:attribute name="moodCode" select="'EVN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ExternalProcedure"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:externalDocument">
         <xsl:element name="document" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'DOC'"/>
            <xsl:attribute name="moodCode" select="'EVN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ExternalDocument"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ReferenceRange-->
   <xsl:template match="*" mode="POCD_MT000040.ReferenceRange">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:observationRange">
         <xsl:element name="observation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'OBS'"/>
            <xsl:attribute name="moodCode" select="'EVN.CRT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ObservationRange"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.RegionOfInterest.value-->
   <xsl:template match="*" mode="POCD_MT000040.RegionOfInterest.value"><!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')]"/>
   </xsl:template>

   <!--POCD_MT000040.RegionOfInterest-->
   <xsl:template match="*" mode="POCD_MT000040.RegionOfInterest">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidActCode"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_PQ">
         <xsl:with-param name="in" select="hl7:value"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:valueNegationInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:interpretationCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entryRelationship">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EntryRelationship"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','value','valueNegationInd','interpretationCode','methodCode','targetSiteCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.RelatedDocument-->
   <xsl:template match="*" mode="POCD_MT000040.RelatedDocument">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:parentDocument">
         <xsl:element name="parentDocument" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'DOCCLIN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.ParentDocument"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.RelatedEntity-->
   <xsl:template match="*" mode="POCD_MT000040.RelatedEntity">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:relatedPerson">
         <xsl:element name="{if (ancestor::hl7:entry) then ('playingPerson') else ('relatedPerson')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PSN'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Person"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.RelatedSubject-->
   <xsl:template match="*" mode="POCD_MT000040.RelatedSubject">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-COLL_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="hl7:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="hl7:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="{if (ancestor::hl7:entry) then ('playingPerson') else ('subject')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PSN'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.SubjectPerson"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ResponsibleParty-->
   <xsl:template match="*" mode="POCD_MT000040.ResponsibleParty">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-REAL-to-REAL">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:pauseQuantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:checkpointCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:splitCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:joinCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:conjunctionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:localVariableName"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:seperatableInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:assignedEntity">
         <xsl:element name="assignedEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ASSIGNED'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.AssignedEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('sequenceNumber','priorityNumber','pauseQuantity','checkpointCode','splitCode','joinCode','conjunctionCode','localVariableName','seperatableInd','subsetCode','uncertaintyCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Section-->
   <xsl:template match="*" mode="POCD_MT000040.Section">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="hl7:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-StrucDoc.Text-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="*:setId"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:versionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:completionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:storageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:copyTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-DSET_ED">
         <xsl:with-param name="in" select="*:bibliographicDesignationText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="subject" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="author" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="informant" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entry">
         <xsl:element name="entry" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode"
                           select="if (../hl7:*[@typeCode='DRIV']) then ('DRIV') else ('COMP')"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="false()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Entry"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:component">
         <xsl:element name="component" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="false()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Component5"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','setId','versionNumber','completionCode','storageCode','copyTime','bibliographicDesignationText'))]"/>
   </xsl:template>

   <!--POCD_MT000040.ServiceEvent-->
   <xsl:template match="*" mode="POCD_MT000040.ServiceEvent">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:performer">
         <xsl:element name="performer" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer1"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Specimen-->
   <xsl:template match="*" mode="POCD_MT000040.Specimen">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:time"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:specimenRole">
         <xsl:element name="role" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.SpecimenRole"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.SpecimenRole-->
   <xsl:template match="*" mode="POCD_MT000040.SpecimenRole">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-EN-to-DSET_EN">
         <xsl:with-param name="in" select="*:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-DSET_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-DSET_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:certificateText"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-RTO">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-LIST_INT">
         <xsl:with-param name="in" select="*:positionNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:specimenPlayingEntity">
         <xsl:element name="playingEntity" namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'ENT'"/>
            <xsl:attribute name="determinerCode" select="'INSTANCE'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.PlayingEntity"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','name','addr','telecom','statusCode','effectiveTime','certificateText','confidentialityCode','quantity','priorityNumber','positionNumber'))]"/>
   </xsl:template>

   <!--POCD_MT000040.StructuredBody-->
   <xsl:template match="*" mode="POCD_MT000040.StructuredBody">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:text"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="*:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CD">
         <xsl:with-param name="in" select="hl7:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
         <xsl:with-param name="codeSystem" select="$oidHumanLanguage"/>
      </xsl:call-template>
      <xsl:call-template name="dt-II-to-II">
         <xsl:with-param name="in" select="*:setId"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:versionNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:completionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:storageCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:copyTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-DSET_ED">
         <xsl:with-param name="in" select="*:bibliographicDesignationText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:component">
         <xsl:element name="component" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:element name="blockedContextActRelationshipType" namespace="urn:hl7-org:v3">
               <xsl:attribute name="code" select="'ART'"/>
            </xsl:element>
            <xsl:element name="actAttributeContextBlockedInd" namespace="urn:hl7-org:v3">
               <xsl:attribute name="value" select="false()"/>
            </xsl:element>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Component3"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','setId','versionNumber','completionCode','storageCode','copyTime','bibliographicDesignationText'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Subject-->
   <xsl:template match="*" mode="POCD_MT000040.Subject">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:functionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:sequenceNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:priorityNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:noteText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:time"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:modeCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:awarenessCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:signatureCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:signatureText"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:performInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:substitutionConditionCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:subsetCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:relatedSubject">
         <xsl:element name="{if (ancestor::hl7:entry) then ('role') else ('relatedSubject')}"
                      namespace="urn:hl7-org:v3">
            <xsl:attribute name="classCode" select="'PRS'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.RelatedSubject"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('functionCode','sequenceNumber','priorityNumber','noteText','time','modeCode','awarenessCode','signatureCode','signatureText','performInd','substitutionConditionCode','subsetCode','quantity'))]"/>
   </xsl:template>

   <!--POCD_MT000040.SubjectPerson-->
   <xsl:template match="*" mode="POCD_MT000040.SubjectPerson">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="*:id"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="*:code"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="*:quantity"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PN-to-DSET_EN">
         <xsl:with-param name="in" select="hl7:name"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:desc"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="*:statusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="*:existenceTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TEL-to-COLL_TEL">
         <xsl:with-param name="in" select="*:telecom"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:riskCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:handlingCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:administrativeGenderCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="hl7:birthTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:deceasedInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:deceasedTime"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:multipleBirthInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-INT-to-INT">
         <xsl:with-param name="in" select="*:multipleBirthOrderNumber"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:organDonorInd"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-AD-to-COLL_AD">
         <xsl:with-param name="in" select="*:addr"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:maritalStatusCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:educationLevelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:disabilityCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:livingArrangementCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:religiousAffiliationCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:raceCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:ethnicGroupCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','quantity','name','desc','statusCode','existenceTime','telecom','riskCode','handlingCode','administrativeGenderCode','birthTime','deceasedInd','deceasedTime','multipleBirthInd','multipleBirthOrderNumber','organDonorInd','addr','maritalStatusCode','educationLevelCode','disabilityCode','livingArrangementCode','religiousAffiliationCode','raceCode','ethnicGroupCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.SubstanceAdministration-->
   <xsl:template match="*" mode="POCD_MT000040.SubstanceAdministration">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-SXCM_TS-to-QSET_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-QSET_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="hl7:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:methodCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:approachSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-DSET_CD">
         <xsl:with-param name="in" select="*:targetSiteCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:routeCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_PQ-to-PQ">
         <xsl:with-param name="in" select="hl7:doseQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_PQ-to-PQ">
         <xsl:with-param name="in" select="hl7:rateQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO-to-DSET_RTO">
         <xsl:with-param name="in" select="*:doseCheckQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-RTO_PQ_PQ-to-DSET_RTO">
         <xsl:with-param name="in" select="hl7:maxDoseQuantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="hl7:administrationUnitCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:consumable">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'CSM'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Consumable"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entryRelationship">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EntryRelationship"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','methodCode','approachSiteCode','targetSiteCode','routeCode','doseQuantity','rateQuantity','doseCheckQuantity','maxDoseQuantity','administrationUnitCode'))]"/>
   </xsl:template>

   <!--POCD_MT000040.Supply-->
   <xsl:template match="*" mode="POCD_MT000040.Supply">
      <!-- Loop through attributes with a datatype based on RIM order -->
      <xsl:call-template name="dt-II-to-DSET_II">
         <xsl:with-param name="in" select="hl7:id"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CD-to-CD">
         <xsl:with-param name="in" select="hl7:code"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ST-to-ST">
         <xsl:with-param name="in" select="*:derivationExpr"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="*:title"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-ED-to-ED">
         <xsl:with-param name="in" select="hl7:text"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CS-to-CS">
         <xsl:with-param name="in" select="hl7:statusCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-SXCM_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:effectiveTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-GTS-to-IVL_TS">
         <xsl:with-param name="in" select="*:activityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-TS-to-TS">
         <xsl:with-param name="in" select="*:availabilityTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="hl7:priorityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:confidentialityCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_INT-to-IVL_INT">
         <xsl:with-param name="in" select="hl7:repeatNumber"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="*:interruptibleInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:levelCode"/>
         <xsl:with-param name="convertNamespace" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-BL-to-BL">
         <xsl:with-param name="in" select="hl7:independentInd"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:uncertaintyCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-DSET_CD">
         <xsl:with-param name="in" select="*:reasonCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-CE-to-CD">
         <xsl:with-param name="in" select="*:languageCode"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-PQ-to-PQ">
         <xsl:with-param name="in" select="hl7:quantity"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="dt-IVL_TS-to-IVL_TS">
         <xsl:with-param name="in" select="hl7:expectedUseTime"/>
         <xsl:with-param name="convertNamespace" select="true()"/>
      </xsl:call-template>
      <!-- Loop through all official complexTypes from CDAr2 schema -->
      <xsl:for-each select="hl7:subject">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SBJ'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Subject"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:specimen">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'SPC'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Specimen"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:product">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRD'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Product"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:performer">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Performer2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:author">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'AUT'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Author"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:informant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'INF'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Informant12"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:participant">
         <xsl:element name="participation" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Participant2"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:entryRelationship">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:if test="self::node()[@negationInd]">
               <xsl:attribute name="actionNegationInd" select="@negationInd"/>
            </xsl:if>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.EntryRelationship"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:reference">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Reference"/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="hl7:precondition">
         <xsl:element name="outboundRelationship" namespace="urn:hl7-org:v3">
            <xsl:attribute name="typeCode" select="'PRCN'"/>
            <xsl:copy-of select="@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd"/>
            <xsl:call-template name="infrastructureRootElements"/>
            <xsl:apply-templates select="self::*" mode="POCD_MT000040.Precondition"/>
         </xsl:element>
      </xsl:for-each>
      <!-- Run through complexTypes in extensions -->
      <xsl:apply-templates select="*[not(namespace-uri()='urn:hl7-org:v3')][not(local-name()=('id','code','derivationExpr','title','text','statusCode','effectiveTime','activityTime','availabilityTime','priorityCode','confidentialityCode','repeatNumber','interruptibleInd','levelCode','independentInd','uncertaintyCode','reasonCode','languageCode','quantity','expectedUseTime'))]"/>
   </xsl:template>

   <!-- processing-instruction()|comment()|text() -->
   <xsl:template match="processing-instruction()|comment()|text()">
      <xsl:copy-of select="self::node()"/>
   </xsl:template>

   <!-- copy any other node as-is -->
   <xsl:template match="*">
      <xsl:copy-of select="self::node()"/>
   </xsl:template>
</xsl:stylesheet>
