<?xml version="1.0" encoding="UTF-8"?>
<!--
    cda2xsd_to_cdar3xsl.xsl
    Copyright (C) 2012-2013 Alexander Henket, Nictiz, The Netherlands
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:hl7="urn:hl7-org:v3"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 25, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> Alexander Henket, Nictiz, The Netherlands</xd:p>
            <xd:p><xd:b>Purpose:</xd:b> Builds an XSL 2.0 transform to convert any valid CDAr2 instance document to a valid CDAr3 instance document. To (re)create the transform ../cda2_to_cdar3.xsl, run: <xd:pre>
                java -jar saxon9.jar -xsl:cdar2xsd_to_cdar3xsl.xsl -s:cdar2xsd_to_cdar3xsl.xsl</xd:pre></xd:p>
            <xd:p><xd:b>History:</xd:b> <xd:ul>
                <xd:li><xd:b>2013-05-14</xd:b>
                    <xd:ul>
                        <xd:li>Updated for May 2013 draft for comment of CDAr3</xd:li>
                        <xd:li>Rewritten logic to obtain datatyped elements by using RIM coreMif to get the list of valid attributes for a given class, also allowing for correct order processing</xd:li>
                        <xd:li>Rewritten so the datatype transforms are now available as an include, and handle namespace conversion if necessary</xd:li>
                        <xd:li>Patch for RegionOfInterest.value which was not handled due to its exceptional nature</xd:li>
                    </xd:ul>
                </xd:li>
                <xd:li><xd:b>2013-03-07</xd:b>
                    <xd:ul>
                        <xd:li>Added codeSystem to conversions from CS to CD (languageCode, signatureCode, RegionOfInterest.code)</xd:li>
                    </xd:ul>
                </xd:li>
            </xd:ul></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes"/>
    <xsl:param name="cdar3xsd" select="'../cdar3schemas/multicacheschemas/CDA.xsd'"/>
    
    <!-- CDAr2 contents -->
    <xsl:param name="cdar2pocdXsd" select="'../cdar2schemas/schemas/POCD_MT000040.xsd'"/>
    <!-- CDAr3 contents -->
    <xsl:param name="cdar3pocdXsd" select="'../cdar3schemas/multicacheschemas/POCD_MT000040UV.xsd'"/>
    <!-- CDAr3 Clinical Statements -->
    <xsl:param name="cdar3csXsd" select="'../cdar3schemas/multicacheschemas/COCT_MT980000UV.xsd'"/>
    <!-- CDAr3 Participants -->
    <xsl:param name="cdar3partXsd" select="'../cdar3schemas/multicacheschemas/COCT_MT990000UV.xsd'"/>
    <!-- RIM 0235 or older coremif to tell us what may be part of a certain class in DTr1. Note: 2.35 is last version in DTr1 -->
    <xsl:param name="rimcoremif-dtr1" select="'DEFN=UV=RIM=0235R1.coremif'"/>
    <!-- RIM 0242 or another coremif to tell us what may be part of a certain class in DTr2 -->
    <xsl:param name="rimcoremif-dtr2" select="'DEFN=UV=RIM=0242.coremif'"/>
    
    <!-- List of infrastructureRoot elements -->
    <xsl:variable name="infrastructureRoot" as="xs:string*" select="('realmCode','typeId','templateId')"/>
    <!-- Mapping table to tell us what CDAr3 complexType a given CDAr2 complextype maps into, and what the RIM class is for that CDAr2 complexType (Role, Act, ...) if applicable -->
    <xsl:variable name="mappingTable">
        <!--wrap>
            <xsl:for-each select="document($cdar2pocdXsd)//xs:complexType">
                <map cdar2="{@name}" cdar3="{replace(@name,'POCD_MT000040.','POCD_MT000040UV.')}"/>
            </xsl:for-each>
        </wrap-->
        <wrap>
            <!-- Header (and maybe body too) -->
            <map cdar2="POCD_MT000040.InfrastructureRoot.typeId" cdar3="POCD_MT000040UV.InfrastructureRoot.typeId"/>
            <map cdar2="POCD_MT000040.InfrastructureRoot.templateId" cdar3="POCD_MT000040UV.InfrastructureRoot.templateId"/>
            <map cdar2="POCD_MT000040.AssignedAuthor" cdar3="POCD_MT000040UV.AssignedAuthor" class="Role"/>
            <map cdar2="POCD_MT000040.AssignedCustodian" cdar3="POCD_MT000040UV.AssignedCustodian" class="Role"/>
            <map cdar2="POCD_MT000040.AssignedEntity" cdar3="POCD_MT000040UV.AssignedEntity" class="Role"/>
            <map cdar2="POCD_MT000040.AssociatedEntity" cdar3="POCD_MT000040UV.AssociatedEntity" class="Role"/>
            <map cdar2="POCD_MT000040.Authenticator" cdar3="POCD_MT000040UV.Authenticator" class="Participation"/>
            <map cdar2="POCD_MT000040.Author" cdar3="POCD_MT000040UV.Author" class="Participation"/>
            <map cdar2="POCD_MT000040.AuthoringDevice" cdar3="POCD_MT000040UV.Device" class="Device"/>
            <map cdar2="POCD_MT000040.Authorization" cdar3="POCD_MT000040UV.Authorization" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Birthplace" cdar3="POCD_MT000040UV.Birthplace" class="Place"/>
            <map cdar2="POCD_MT000040.ClinicalDocument" cdar3="POCD_MT000040UV.ClinicalDocument" class="Document"/>
            <map cdar2="POCD_MT000040.Component1" cdar3="POCD_MT000040UV.Component1" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Component2" cdar3="POCD_MT000040UV.Component2" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Component3" cdar3="POCD_MT000040UV.Component3" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Component5" cdar3="POCD_MT000040UV.Component5" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Consent" cdar3="POCD_MT000040UV.Consent" class="Act"/>
            <map cdar2="POCD_MT000040.Custodian" cdar3="POCD_MT000040UV.Custodian" class="Participation"/>
            <map cdar2="POCD_MT000040.CustodianOrganization" cdar3="POCD_MT000040UV.CustodianOrganization" class="Organization"/>
            <map cdar2="POCD_MT000040.DataEnterer" cdar3="POCD_MT000040UV.DataEnterer" class="Participation"/>
            <map cdar2="POCD_MT000040.DocumentationOf" cdar3="POCD_MT000040UV.DocumentationOf" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.EncompassingEncounter" cdar3="POCD_MT000040UV.EncompassingEncounter" class="PatientEncounter"/>
            <map cdar2="POCD_MT000040.EncounterParticipant" cdar3="POCD_MT000040UV.EncounterParticipant" class="Participation"/>
            <map cdar2="POCD_MT000040.Entry" cdar3="POCD_MT000040UV.Entry" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Guardian" cdar3="POCD_MT000040UV.Guardian" class="Role"/>
            <map cdar2="POCD_MT000040.HealthCareFacility" cdar3="POCD_MT000040UV.HealthCareFacility" class="Role"/>
            <map cdar2="POCD_MT000040.Informant12" cdar3="POCD_MT000040UV.Informant" class="Participation"/>
            <map cdar2="POCD_MT000040.InformationRecipient" cdar3="POCD_MT000040UV.InformationRecipient" class="Participation"/>
            <map cdar2="POCD_MT000040.InFulfillmentOf" cdar3="POCD_MT000040UV.InFulfillmentOf" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.IntendedRecipient" cdar3="POCD_MT000040UV.IntendedRecipient" class="Role"/>
            <map cdar2="POCD_MT000040.LanguageCommunication" cdar3="POCD_MT000040UV.LanguageCommunication" class="LanguageCommunication"/>
            <map cdar2="POCD_MT000040.LegalAuthenticator" cdar3="POCD_MT000040UV.LegalAuthenticator" class="Participation"/>
            <map cdar2="POCD_MT000040.Location" cdar3="POCD_MT000040UV.Location" class="Participation"/>
            <map cdar2="POCD_MT000040.MaintainedEntity" cdar3="POCD_MT000040UV.MaintainedEntity" class="Role"/>
            <map cdar2="POCD_MT000040.NonXMLBody" cdar3="POCD_MT000040UV.NonStructuredBody" class="Document"/>
            <map cdar2="POCD_MT000040.Order" cdar3="POCD_MT000040UV.Order" class="Observation"/>
            <map cdar2="POCD_MT000040.Organization" cdar3="POCD_MT000040UV.Organization" class="Organization"/>
            <map cdar2="POCD_MT000040.OrganizationPartOf" cdar3="POCD_MT000040UV.OrganizationPartOf" class="Role"/>
            <map cdar2="POCD_MT000040.ParentDocument" cdar3="POCD_MT000040UV.ParentDocument" class="Document"/>
            <!-- CDA r3 Sept 2012 -->
            <map cdar2="POCD_MT000040.Participant1" cdar3="POCD_MT000040UV.Participant1" class="Participation"/>
            <!-- CDA r3 Sept 2013 -->
            <map cdar2="POCD_MT000040.Participant1" cdar3="POCD_MT000040UV.Participant" class="Participation"/>
            <map cdar2="POCD_MT000040.Patient" cdar3="POCD_MT000040UV.Patient" class="Person"/>
            <map cdar2="POCD_MT000040.PatientRole" cdar3="POCD_MT000040UV.PatientRole" class="Patient"/>
            <map cdar2="POCD_MT000040.Performer1" cdar3="POCD_MT000040UV.Performer1" class="Participation"/>
            <map cdar2="POCD_MT000040.Person" cdar3="POCD_MT000040UV.Person" class="Person"/>
            <map cdar2="POCD_MT000040.Place" cdar3="POCD_MT000040UV.Place" class="Place"/>
            <map cdar2="POCD_MT000040.RecordTarget" cdar3="POCD_MT000040UV.RecordTarget" class="Participation"/>
            <map cdar2="POCD_MT000040.RelatedDocument" cdar3="POCD_MT000040UV.RelatedDocument" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.RelatedEntity" cdar3="POCD_MT000040UV.RelatedEntity" class="Role"/>
            <map cdar2="POCD_MT000040.RelatedSubject" cdar3="POCD_MT000040UV.RelatedSubject" class="Role"/>
            <map cdar2="POCD_MT000040.ResponsibleParty" cdar3="POCD_MT000040UV.ResponsibleParty" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Section" cdar3="POCD_MT000040UV.Section" class="Document"/>
            <map cdar2="POCD_MT000040.ServiceEvent" cdar3="POCD_MT000040UV.ServiceEvent" class="Act"/>
            <map cdar2="POCD_MT000040.StructuredBody" cdar3="POCD_MT000040UV.StructuredBody" class="Document"/>
            <map cdar2="POCD_MT000040.Subject" cdar3="POCD_MT000040UV.Subject" class="Participation"/>
            <map cdar2="POCD_MT000040.SubjectPerson" cdar3="POCD_MT000040UV.SubjectPerson" class="Person"/>
            
            <!-- Entry Clinical Statement choice box with actrelationships and connected acts -->
            <map cdar2="POCD_MT000040.Act" cdar3="COCT_MT980000UV.Act" class="Act"/>
            <map cdar2="POCD_MT000040.Component4" cdar3="COCT_MT980000UV.SourceOf" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Consumable" cdar3="COCT_MT980000UV.Participant" class="Participation"/>
            <map cdar2="POCD_MT000040.Criterion" cdar3="COCT_MT980000UV.Observation" class="Observation"/>
            <map cdar2="POCD_MT000040.Encounter" cdar3="COCT_MT980000UV.Encounter" class="PatientEncounter"/>
            <map cdar2="POCD_MT000040.Device" cdar3="COCT_MT990000UV.Device" class="Device"/>
            <map cdar2="POCD_MT000040.Entity" cdar3="COCT_MT990000UV.Entity" class="Entity"/>
            <map cdar2="POCD_MT000040.EntryRelationship" cdar3="COCT_MT980000UV.SourceOf" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.ExternalAct" cdar3="COCT_MT980000UV.Act" class="Act"/>
            <map cdar2="POCD_MT000040.ExternalDocument" cdar3="COCT_MT980000UV.Document" class="Document"/>
            <map cdar2="POCD_MT000040.ExternalObservation" cdar3="COCT_MT980000UV.Observation" class="Observation"/>
            <map cdar2="POCD_MT000040.ExternalProcedure" cdar3="COCT_MT980000UV.Procedure" class="Procedure"/>
            <map cdar2="POCD_MT000040.LabeledDrug" cdar3="COCT_MT990000UV.ManufacturedMaterial" class="ManufacturedMaterial"/>
            <map cdar2="POCD_MT000040.ManufacturedProduct" cdar3="COCT_MT990000UV.Role" class="Role"/>
            <map cdar2="POCD_MT000040.Material" cdar3="COCT_MT990000UV.ManufacturedMaterial" class="ManufacturedMaterial"/>
            <map cdar2="POCD_MT000040.Organizer" cdar3="COCT_MT980000UV.Observation" class="Observation"/>
            <map cdar2="POCD_MT000040.Observation" cdar3="COCT_MT980000UV.Observation" class="Observation"/>
            <map cdar2="POCD_MT000040.ObservationMedia" cdar3="COCT_MT980000UV.ObservationMedia" class="Observation"/>
            <map cdar2="POCD_MT000040.ObservationRange" cdar3="COCT_MT980000UV.Observation" class="Observation"/>
            <map cdar2="POCD_MT000040.Participant2" cdar3="COCT_MT980000UV.Participant" class="Participation"/>
            <map cdar2="POCD_MT000040.ParticipantRole" cdar3="COCT_MT990000UV.Role" class="Role"/>
            <map cdar2="POCD_MT000040.Performer2" cdar3="COCT_MT980000UV.Participant" class="Participation"/>
            <map cdar2="POCD_MT000040.PlayingEntity" cdar3="COCT_MT990000UV.Entity" class="Entity"/>
            <map cdar2="POCD_MT000040.Precondition" cdar3="COCT_MT980000UV.SourceOf" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.Procedure" cdar3="COCT_MT980000UV.Procedure" class="Procedure"/>
            <map cdar2="POCD_MT000040.Product" cdar3="COCT_MT980000UV.Participant" class="Participation"/>
            <map cdar2="POCD_MT000040.Reference" cdar3="COCT_MT980000UV.SourceOf" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.ReferenceRange" cdar3="COCT_MT980000UV.SourceOf" class="ActRelationship"/>
            <map cdar2="POCD_MT000040.RegionOfInterest" cdar3="COCT_MT980000UV.RegionOfInterest" class="Observation"/>
            <map cdar2="POCD_MT000040.Specimen" cdar3="COCT_MT980000UV.Participant" class="Participation"/>
            <map cdar2="POCD_MT000040.SpecimenRole" cdar3="COCT_MT990000UV.Role" class="Role"/><!-- ? -->
            <map cdar2="POCD_MT000040.SubstanceAdministration" cdar3="COCT_MT980000UV.SubstanceAdministration" class="SubstanceAdministration"/>
            <map cdar2="POCD_MT000040.Supply" cdar3="COCT_MT980000UV.Supply" class="Supply"/>
            
            <!-- Entry Clinical Statement choice box with participations and connected roles/entities -->
            
            <map cdar2="POCD_MT000040.RegionOfInterest.value" cdar3="POCD_MT000040UV.RegionOfInterest.value"/><!-- ? -->
            
        </wrap>
    </xsl:variable>
    <!-- Build flat list of RIM classes and their immutable attributes in DTr1 -->
    <xsl:variable name="rimClassesDTr1">
        <rim>
            <xsl:apply-templates select="doc($rimcoremif-dtr1)/*:staticModel/*:containedClass" mode="getClass"/>
        </rim>
    </xsl:variable>
    <!-- Build flat list of RIM classes and their immutable attributes in DTr2 -->
    <xsl:variable name="rimClassesDTr2">
        <rim>
            <xsl:apply-templates select="doc($rimcoremif-dtr2)/*:staticModel/*:containedClass" mode="getClass"/>
        </rim>
    </xsl:variable>
    
    <xsl:template match="/">
        <!-- Sanity check for our own typos, e.g. Participant instead of Participation -->
        <xsl:for-each select="$mappingTable//map[@class]">
            <xsl:variable name="class" select="@class"/>
            <xsl:if test="not($rimClassesDTr1/rim/class[@name=$class])">
                <xsl:message terminate="yes">*** ERROR: technical error in mapping table for cdar2=<xsl:value-of select="@cdar2"/>. Incorrect value for class=<xsl:value-of select="@class"/>. Need to call a valid RIM class type.</xsl:message>
            </xsl:if>
        </xsl:for-each>
        
        <xsl:result-document href="../cda2_to_cdar3.xsl" indent="yes">
            <xsl:comment>
    cda2_to_cdar3.xsl
    Copyright (C) 2012-2013 Alexander Henket, Nictiz, The Netherlands
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
</xsl:comment>
            <xsl:text>&#10;</xsl:text>
            <xsl:element name="xsl:stylesheet" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
                <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
                <xsl:namespace name="xd" select="'http://www.oxygenxml.com/ns/doc/xsl'"/>
                <xsl:namespace name="hl7" select="'urn:hl7-org:v3'"/>
                <xsl:attribute name="exclude-result-prefixes" select="'xs xsi xd hl7 xsl'"/>
                <xsl:attribute name="version" select="'2.0'"/>
                <xsl:element name="doc" namespace="http://www.oxygenxml.com/ns/doc/xsl">
                    <xsl:attribute name="scope">stylesheet</xsl:attribute>
                    <xd:desc>
                        <xd:p><xd:b>Generated using cda2xsd_to_cdar3xsl.xsl on:</xd:b> <xsl:value-of select="format-dateTime(current-dateTime(),'[MNn] [D], [Y]', 'en', (), ())"/></xd:p>
                        <xd:p><xd:b>Author:</xd:b> Alexander Henket, Nictiz, The Netherlands</xd:p>
                        <xd:p><xd:b>Email:</xd:b> henket(a)nictiz.nl</xd:p>
                        <xd:p><xd:b>Quick Start:</xd:b> At execution time you may set the parameter convertSectionTextToCDAr3Markup to true (default) to convert the Section.text CDAr2 
                            style markup to CDAr3 style markup. Alternatively you may switch to 'compatibility mode' and copy Section.text as-is. <xd:pre>
                            java -jar saxon9.jar -xsl:cda2_to_cdar3.xsl -s:Sample1.CDAr2.xml convertSectionTextToCDAr3Markup=true</xd:pre></xd:p>
                        <xd:p>Maps any CDA release 2 to CDA release 3 based on May 2013 Ballot. <ul>
                            <li>Class attributes (id, name, addr, etc.) are processed according to RIM order. If the class exists in CDAr3, it is copied into the HL7 V3 namespace. 
                                If the class does not exist in CDAr3, it is copied as-is. Since CDAr3 &gt;= CDAr2, it shall never be the case that something exists in CDAr2, but 
                                does not in CDAr3. There's one supported exception and that is CustodianOrganization.id which was moved to AssignedCustodian.id.</li>
                            <li>Class associations (scoping, playing, ActRelationships, Participations) are handled by explicitly doing the defined element first, and then 
                            handling any extensions.</li>
                        </ul></xd:p>
                        <xd:p>Maps all datatypes that are explicitly present in the CDAr2 specification. It may not map datatypes you explicitly declare in your instance, e.g. PPD_TS. 
                            Supported dtatypes are: 'AD','BL','BN','CD','CE','CO','CV','ED','EIVL_TS','EN','II','INT','IVL_INT','IVL_MO','IVL_PQ','IVL_REAL','IVL_TS','MO','ON',
                            'PIVL_TS','PN','PQ','REAL','RTO_PQ_PQ','SC','ST','TEL','TS'. In the event an unknown datatype is encountered, the XSL gives a message and terminates.</xd:p>
                        <xd:p><xd:b>NOTE:</xd:b> in datatypes R1 there used to be a qualifier element to coded elements. This no longer exists in datatypes R2. Hence this element is left
                        out of the output. Instead a comment will be add to the output stating what was omitted leading to data loss. Example: 
                            <xd:pre> Could not map qualifier for: name/code="12313" name/codeSystem="1.34" name/displayName="3453" value/code="23123" value/codeSystem="1.2.3" value/displayName="dsf" </xd:pre></xd:p>
                        <xd:p>See http://vimeo.com/16813271 for a video by Grahame Grieve on what changed in datatypes R2.</xd:p>
                        <xd:p>CDAr2 was not completely moved over to CDAr3 as it currently stands. In the context of where data would/will not be mapped you'll find a comment that 
                            starts with 'Skipping mapping of'. Currently skipped elements include: 'POCD_MT000040.AuthoringDevice.asMaintainedEntity', 'POCD_MT000040.ClinicalDocument.copyTime',
                            'POCD_MT000040.MaintainedEntity.effectiveTime', 'POCD_MT000040.MaintainedEntity.maintainingPerson' and 'POCD_MT000040UV.Patient.id'</xd:p>
                        <xd:p><xd:b>Known issue:</xd:b> Could do a better job at converting the old-style Section.text to new-style HTML-like Section text. Currently done as-is. Posted request on the StrucDoc/ITS lists for guidance on the exact recommended method. </xd:p>
                        <xd:p><xd:b>Known issue:</xd:b> CDAr3 doesn't handle Section.ID, ObservationMedia.ID and RegioOfInterest.ID hence any referencing to these is off. Posted request on the StrucDoc/ITS lists to resolve. </xd:p>
                    </xd:desc>
                </xsl:element>
                
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:element name="xsl:output">
                    <xsl:attribute name="indent" select="'yes'"/>
                </xsl:element>
                
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href" select="'support/dtr1_to_dtr2.xsl'"/>
                </xsl:element>
                
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:comment> Required codeSystem OIDs for CDAr2 CS elements that are CD in CDAr3 </xsl:comment>
                <xsl:text>&#10;   </xsl:text>
                <xsl:element name="xsl:variable">
                    <xsl:attribute name="name" select="'oidActCode'"/>
                    <xsl:text>2.16.840.1.113883.5.4</xsl:text>
                </xsl:element>
                <xsl:element name="xsl:variable">
                    <xsl:attribute name="name" select="'oidParticipationSignature'"/>
                    <xsl:text>2.16.840.1.113883.5.89</xsl:text>
                </xsl:element>
                <xsl:element name="xsl:variable">
                    <xsl:attribute name="name" select="'oidHumanLanguage'"/>
                    <xsl:text>2.16.840.1.113883.5.121</xsl:text>
                </xsl:element>
                
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:comment> Main template. Copies just the ClinicalDocument element </xsl:comment>
                <xsl:element name="xsl:template">
                    <xsl:attribute name="match" select="'/'"/>
                    
                    <xsl:element name="xsl:apply-templates">
                        <xsl:attribute name="select" select="'hl7:ClinicalDocument'"/>
                    </xsl:element>
                </xsl:element>
                
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:comment> ClinicalDocument template. Adds schemaLocation to the ClinicalDocument element. </xsl:comment>
                <xsl:element name="xsl:template">
                    <xsl:attribute name="match" select="'hl7:ClinicalDocument'"/>
                    
                    <xsl:element name="xsl:copy">
                        <xsl:element name="xsl:copy-of">
                            <xsl:attribute name="select" select="'@*'"/>
                        </xsl:element>
                        <xsl:element name="xsl:attribute">
                            <xsl:attribute name="name" select="'xsi:schemaLocation'"/>
                            <xsl:attribute name="select"><xsl:text>'urn:hl7-org:v3 cdar3schemas/multicacheschemas/CDA.xsd'</xsl:text></xsl:attribute>
                        </xsl:element>
                        
                        <xsl:element name="xsl:apply-templates">
                            <xsl:attribute name="select" select="'self::*'"/>
                            <xsl:attribute name="mode" select="'POCD_MT000040.ClinicalDocument'"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                
                <xsl:apply-templates select="document($cdar2pocdXsd)//xs:complexType[not(starts-with(@name,'POCD_MT000040.InfrastructureRoot.'))]"/>
                
                <xsl:call-template name="fallbackConversions"/>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="xs:complexType">
        <xsl:variable name="complexTypeR2" select="."/>
        <xsl:variable name="complexTypeR2-name" select="@name"/>
        <!-- TODO: fix duplicate entry more intelligently -->
        <xsl:variable name="complexTypeR2-class" select="$mappingTable//map[@cdar2=$complexTypeR2-name][1]/@class"/>
        <xsl:variable name="complexTypeR3-name" select="$mappingTable//map[@cdar2=$complexTypeR2-name][1]/@cdar3"/>
        <xsl:variable name="complexTypeR3">
            <xsl:choose>
                <xsl:when test="starts-with($complexTypeR3-name,'POCD_MT000040UV.')">
                    <xsl:copy-of select="document($cdar3pocdXsd)//xs:complexType[@name=$complexTypeR3-name]"/>
                </xsl:when>
                <xsl:when test="starts-with($complexTypeR3-name,'COCT_MT980000UV.')">
                    <xsl:copy-of select="document($cdar3csXsd)//xs:complexType[@name=$complexTypeR3-name]"/>
                </xsl:when>
                <xsl:when test="starts-with($complexTypeR3-name,'COCT_MT990000UV.')">
                    <xsl:copy-of select="document($cdar3partXsd)//xs:complexType[@name=$complexTypeR3-name]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>Cannot map complexType '<xsl:value-of select="$complexTypeR2-name"/>' to '<xsl:value-of select="$complexTypeR3-name"/>'. Unknown source file.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="clinicalStatement" as="xs:string*" select="('POCD_MT000040.Act','POCD_MT000040.Encounter','POCD_MT000040.Organizer','POCD_MT000040.Observation','POCD_MT000040.ObservationMedia','POCD_MT000040.Procedure','POCD_MT000040.RegionOfInterest','POCD_MT000040.SubstanceAdministration','POCD_MT000040.Supply')"/>
        <!-- Contains the list of datatyped element names that are valid for this complexType based on the RIM -->
        <xsl:variable name="allElementsDatatype" as="xs:string*" select="$rimClassesDTr2//class[@name=$complexTypeR2-class]/attribute/@name"/>
        <!-- Contains the list of association element names that are valid for this complexType based on the CDAr2 -->
        <xsl:variable name="allElementsAssociation" as="xs:string*" select=".//xs:element[starts-with(@type,'POCD_MT000040.')]/@name"/>
        
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:comment> <xsl:value-of select="$complexTypeR2-name"/> </xsl:comment>
        <xsl:text>&#10;   </xsl:text>
        <xsl:element name="xsl:template">
            <xsl:attribute name="match" select="'*'"/>
            <xsl:attribute name="mode" select="@name"/>
            
            <xsl:variable name="elementNameMap">
                <wrap>
                    <map cdar2="POCD_MT000040.AssignedAuthor.assignedAuthoringDevice" cdar3="assignedDevice"/>
                    <map cdar2="POCD_MT000040.Birthplace.place" cdar3="birthplace"/>
                    <map cdar2="POCD_MT000040.ClinicalDocument.participant" cdar3="participation1"/>
                    <map cdar2="POCD_MT000040.Component2.nonXMLBody" cdar3="nonStructuredBody"/>
                    <map cdar2="POCD_MT000040.Component4.organizer" cdar3="observation"/>
                    <map cdar2="POCD_MT000040.Consumable.manufacturedProduct" cdar3="role"/>
                    <map cdar2="POCD_MT000040.Entry.organizer" cdar3="observation"/>
                    <map cdar2="POCD_MT000040.EntryRelationship.organizer" cdar3="observation"/>
                    <map cdar2="POCD_MT000040.Organizer.component" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Act.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Act.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Act.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Act.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Act.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Act.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Act.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Act.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Act.reference" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Encounter.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Encounter.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Encounter.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Encounter.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Encounter.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Encounter.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Encounter.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Encounter.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Encounter.reference" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.HealthCareFacility.location" cdar3="playingPlace"/>
                    <map cdar2="POCD_MT000040.HealthCareFacility.serviceProviderOrganization" cdar3="scopingOrganization"/>
                    <map cdar2="POCD_MT000040.ManufacturedProduct.manufacturedLabeledDrug" cdar3="playingManufacturedMaterial"/>
                    <map cdar2="POCD_MT000040.ManufacturedProduct.manufacturedMaterial" cdar3="playingManufacturedMaterial"/>
                    <map cdar2="POCD_MT000040.ManufacturedProduct.manufacturerOrganization" cdar3="scopingOrganization"/>
                    <map cdar2="POCD_MT000040.Organizer.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Organizer.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Organizer.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Organizer.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Organizer.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Organizer.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Organizer.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Organizer.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Organizer.reference" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Observation.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Observation.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Observation.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Observation.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Observation.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Observation.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Observation.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Observation.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Observation.reference" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Observation.referenceRange" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.ObservationMedia.reference" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Participant2.participantRole" cdar3="role"/>
                    <map cdar2="POCD_MT000040.Performer2.assignedEntity" cdar3="role"/>
                    <map cdar2="POCD_MT000040.Precondition.criterion" cdar3="observation"/>
                    <map cdar2="POCD_MT000040.Procedure.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Procedure.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Procedure.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Procedure.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Procedure.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Procedure.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Procedure.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Procedure.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Procedure.reference" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Product.manufacturedProduct" cdar3="role"/>
                    <map cdar2="POCD_MT000040.Reference.externalAct" cdar3="act"/>
                    <map cdar2="POCD_MT000040.Reference.externalDocument" cdar3="document"/>
                    <map cdar2="POCD_MT000040.Reference.externalObservation" cdar3="observation"/>
                    <map cdar2="POCD_MT000040.Reference.externalProcedure" cdar3="procedure"/>
                    <map cdar2="POCD_MT000040.ReferenceRange.observationRange" cdar3="observation"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.RegionOfInterest.reference" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Specimen.specimenRole" cdar3="role"/>
                    <map cdar2="POCD_MT000040.SpecimenRole.specimenPlayingEntity" cdar3="playingEntity"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.consumable" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.SubstanceAdministration.reference" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Supply.entryRelationship" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Supply.author" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Supply.informant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Supply.participant" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Supply.performer" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Supply.subject" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Supply.precondition" cdar3="outboundRelationship"/>
                    <map cdar2="POCD_MT000040.Supply.product" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Supply.specimen" cdar3="participation"/>
                    <map cdar2="POCD_MT000040.Supply.reference" cdar3="outboundRelationship"/>
                </wrap>
            </xsl:variable>
            
            <!-- First loop through all possible attributes in the RIM. Some exist both in R2 and R3, others in R3 but 
                 not in R2 (only as extension), and finally some may be both extensions in R2 and R3 (headers)
                 - When exist in both or in neither handle datatype and leave namespace, resp. hl7 or some other
                 - When exist in R3 but not in R2, handle namespace conversion
            -->
            <xsl:if test="count($allElementsDatatype)>0">
                <xsl:text>&#10;      </xsl:text>
                <xsl:comment> Loop through attributes with a datatype based on RIM order </xsl:comment>
                <xsl:text>&#10;      </xsl:text>
            </xsl:if>
            <xsl:for-each select="$rimClassesDTr2//class[@name=$complexTypeR2-class]/attribute">
                <xsl:variable name="nm" select="@name"/>
                <xsl:variable name="dtr1" select="@dtr1"/>
                <xsl:variable name="dtr2" select="@dtr2"/>

                <xsl:variable name="isInCDAr2" select="exists($complexTypeR2//xs:element[@name=$nm])" as="xs:boolean"/>
                <xsl:variable name="isInCDAr3" select="exists($complexTypeR3//xs:element[@name=$nm])" as="xs:boolean"/>

                <xsl:variable name="cdar2dt">
                    <xsl:choose>
                        <xsl:when test="not($isInCDAr2)">
                            <xsl:value-of select="$dtr1"/>
                        </xsl:when>
                        <xsl:when test="$complexTypeR2//xs:element[@name=$nm]/@type='POCD_MT000040.RegionOfInterest.value'">
                            <xsl:value-of select="'INT'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$complexTypeR2//xs:element[@name=$nm]/@type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="cdar3dt" select="if ($isInCDAr3) then ($complexTypeR3//xs:element[@name=$nm]/@type) else ($dtr2)"/>

                <xsl:choose>
                    <!-- informant.time and author.time map differently under entry than the other occurences -->
                    <xsl:when test="($complexTypeR2-name='POCD_MT000040.Author' and $nm='time') or ($complexTypeR2-name='POCD_MT000040.Informant12' and $nm='time')">
                        <xsl:element name="xsl:choose">
                            <xsl:element name="xsl:when">
                                <xsl:attribute name="test" select="'ancestor::hl7:entry'"/>
                                
                                <xsl:element name="xsl:call-template">
                                    <xsl:attribute name="name" select="concat('dt-',$cdar2dt,'-to-IVL_TS')"/>
                                    
                                    <xsl:element name="xsl:with-param">
                                        <xsl:attribute name="name" select="'in'"/>
                                        <xsl:attribute name="select" select="concat('hl7:',$nm)"/>
                                    </xsl:element>
                                    <xsl:element name="xsl:with-param">
                                        <xsl:attribute name="name" select="'convertNamespace'"/>
                                        <xsl:attribute name="select" select="'false()'"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="xsl:otherwise">
                                
                                <xsl:element name="xsl:call-template">
                                    <xsl:attribute name="name" select="concat('dt-',$cdar2dt,'-to-',$cdar3dt)"/>
                                    
                                    <xsl:element name="xsl:with-param">
                                        <xsl:attribute name="name" select="'in'"/>
                                        <xsl:attribute name="select" select="concat('hl7:',$nm)"/>
                                    </xsl:element>
                                    <xsl:element name="xsl:with-param">
                                        <xsl:attribute name="name" select="'convertNamespace'"/>
                                        <xsl:attribute name="select" select="'false()'"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$complexTypeR2-name='POCD_MT000040.Organizer' and $nm='effectiveTime'">
                        <xsl:element name="xsl:call-template">
                            <xsl:attribute name="name" select="concat('dt-',$cdar2dt,'-to-QSET_TS')"/>
                            
                            <xsl:element name="xsl:with-param">
                                <xsl:attribute name="name" select="'in'"/>
                                <xsl:attribute name="select" select="concat('hl7:',$nm)"/>
                            </xsl:element>
                            <xsl:element name="xsl:with-param">
                                <xsl:attribute name="name" select="'convertNamespace'"/>
                                <xsl:attribute name="select" select="'false()'"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$complexTypeR2-name='POCD_MT000040.AssignedCustodian' and $nm='id'">
                        <xsl:comment> patch for moved attribute </xsl:comment>
                        <xsl:element name="xsl:call-template">
                            <xsl:attribute name="name" select="'dt-II-to-DSET_II'"/>
                            
                            <xsl:element name="xsl:with-param">
                                <xsl:attribute name="name" select="'in'"/>
                                <xsl:attribute name="select" select="'hl7:representedCustodianOrganization/hl7:id'"/>
                            </xsl:element>
                            <xsl:element name="xsl:with-param">
                                <xsl:attribute name="name" select="'convertNamespace'"/>
                                <xsl:attribute name="select" select="'false()'"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="not($complexTypeR2-name='POCD_MT000040.CustodianOrganization' and $nm='id')">
                        <xsl:element name="xsl:call-template">
                            <xsl:attribute name="name" select="concat('dt-',$cdar2dt,'-to-',$cdar3dt)"/>

                            <xsl:element name="xsl:with-param">
                                <xsl:attribute name="name" select="'in'"/>
                                <xsl:attribute name="select" select="if ($isInCDAr2) then (concat('hl7:',$nm)) else (concat('*:',$nm))"/>
                            </xsl:element>
                            <xsl:element name="xsl:with-param">
                                <xsl:attribute name="name" select="'convertNamespace'"/>
                                <xsl:attribute name="select" select="if ($isInCDAr3) then 'true()' else'false()'"/>
                            </xsl:element>
                            <xsl:choose>
                                <xsl:when test="$cdar2dt='CS' and $cdar3dt='CD' and $nm='languageCode'">
                                    <xsl:element name="xsl:with-param">
                                        <xsl:attribute name="name" select="'codeSystem'"/>
                                        <xsl:attribute name="select" select="'$oidHumanLanguage'"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:when test="$cdar2dt='CS' and $cdar3dt='CD' and $nm='signatureCode'">
                                    <xsl:element name="xsl:with-param">
                                        <xsl:attribute name="name" select="'codeSystem'"/>
                                        <xsl:attribute name="select" select="'$oidParticipationSignature'"/>
                                    </xsl:element>
                                </xsl:when>
                                <!-- Only applicable to RegionOfInterest code (CIRCLE, ELLIPSE, POINT, POLY) -->
                                <xsl:when test="$cdar2dt='CS' and $cdar3dt='CD' and $nm='code'">
                                    <xsl:element name="xsl:with-param">
                                        <xsl:attribute name="name" select="'codeSystem'"/>
                                        <xsl:attribute name="select" select="'$oidActCode'"/>
                                    </xsl:element>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:comment> Skipping mapping of '<xsl:value-of select="concat($complexTypeR2-name,'.',$nm)"/>', because there is no matching '<xsl:value-of select="concat($complexTypeR3-name,'.',$nm)"/>' </xsl:comment>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <xsl:if test="count($allElementsAssociation)>0">
                <xsl:if test="count($allElementsDatatype)=0">
                    <xsl:text>&#10;      </xsl:text>
                </xsl:if>
                <xsl:comment> Loop through all official complexTypes from CDAr2 schema </xsl:comment>
                <xsl:text>&#10;      </xsl:text>
            </xsl:if>
            <xsl:for-each select=".//xs:element[starts-with(@type,'POCD_MT000040.')]">
                <xsl:variable name="cdar2name" select="@name"/>
                <xsl:variable name="cdar2type" select="@type"/>
                <xsl:variable name="cdar3name" select="if ($elementNameMap//map[@cdar2=concat($complexTypeR2-name,'.',$cdar2name)]) then ($elementNameMap//map[@cdar2=concat($complexTypeR2-name,'.',$cdar2name)]/@cdar3) else ($cdar2name)"/>
                
                <xsl:choose>
                    <xsl:when test="$cdar2type='POCD_MT000040.RegionOfInterest.value'"/>
                    <xsl:when test="$complexTypeR3//xs:element[@name=$cdar3name] or count(index-of($infrastructureRoot,$cdar2name))&gt;0">
                        <xsl:variable name="ctr3sub" select="$complexTypeR3//xs:element[@name=$cdar2name]/@type"/>
                        <xsl:choose>
                            <!-- 
                                <xs:element name="typeId" type="POCD_MT000040.InfrastructureRoot.typeId"  minOccurs="0"/>
                                <xs:element name="templateId" type="POCD_MT000040.InfrastructureRoot.templateId"  minOccurs="0" maxOccurs="unbounded"/> 
                            -->
                            <xsl:when test="$cdar2name='realmCode'"/>
                            <xsl:when test="$cdar2type='POCD_MT000040.InfrastructureRoot.typeId'"/>
                            <xsl:when test="$cdar2type='POCD_MT000040.InfrastructureRoot.templateId'"/>
                            <xsl:when test="$complexTypeR2-name='POCD_MT000040.ClinicalDocument' and $cdar2name='componentOf'"/>
                            <xsl:otherwise>
                                <xsl:variable name="hasNegationInd" select="exists(document($cdar2pocdXsd)//xs:complexType[@name=$cdar2type]/xs:attribute[@name='negationInd'])"/>
                                
                                <xsl:element name="xsl:for-each">
                                    <xsl:attribute name="select" select="concat('hl7:',$cdar2name)"/>
                                    
                                    <xsl:element name="xsl:element">
                                        <xsl:attribute name="name">
                                            <xsl:choose>
                                                <xsl:when test="$cdar2type='POCD_MT000040.Organizer'">
                                                    <xsl:text>{if (@classCode='CLUSTER') then ('composition') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.Author' and $cdar2name='assignedAuthor'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('role') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.AssignedAuthor' and $cdar2name='assignedPerson'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('playingPerson') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.AssignedAuthor' and $cdar2name='assignedAuthoringDevice'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('playingDevice') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.AssignedAuthor' and $cdar2name='representedOrganization'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('scopingOrganization') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.AssignedEntity' and $cdar2name='assignedPerson'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('playingPerson') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.AssignedEntity' and $cdar2name='representedOrganization'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('scopingOrganization') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.Informant12' and $cdar2name='assignedEntity'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('role') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.Informant12' and $cdar2name='relatedEntity'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('role') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.Subject' and $cdar2name='relatedSubject'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('role') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.RelatedSubject' and $cdar2name='subject'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('playingPerson') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$complexTypeR2-name='POCD_MT000040.RelatedEntity' and $cdar2name='relatedPerson'">
                                                    <xsl:text>{if (ancestor::hl7:entry) then ('playingPerson') else ('</xsl:text><xsl:value-of select="$cdar3name"/><xsl:text>')}</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$cdar3name"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <xsl:attribute name="namespace" select="'urn:hl7-org:v3'"/>
                                        
                                        <!-- Start of attributes -->
                                        <xsl:call-template name="handleSpecificAttributes">
                                            <xsl:with-param name="in" select="concat($complexTypeR2-name,'.',$cdar2name)"/>
                                        </xsl:call-template>
                                        <xsl:element name="xsl:copy-of">
                                            <xsl:attribute name="select" select="'@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd'"/>
                                        </xsl:element>
                                        <xsl:if test="$hasNegationInd">
                                            <xsl:element name="xsl:if">
                                                <xsl:attribute name="test" select="'self::node()[@negationInd]'"/>
                                                
                                                <xsl:element name="xsl:attribute">
                                                    <xsl:attribute name="name" select="'actionNegationInd'"/>
                                                    <xsl:attribute name="select" select="'@negationInd'"/>
                                                </xsl:element>
                                            </xsl:element>
                                        </xsl:if>
                                        <xsl:if test="$cdar2name='organizer'">
                                            <xsl:element name="xsl:if">
                                                <xsl:attribute name="test">
                                                    <xsl:text>@classCode='CLUSTER'</xsl:text>
                                                </xsl:attribute>
                                                
                                                <xsl:element name="xsl:attribute">
                                                    <xsl:attribute name="name" select="'classCode'"/>
                                                    <xsl:attribute name="select">
                                                        <xsl:text>'COMPOSITION'</xsl:text>
                                                    </xsl:attribute>
                                                </xsl:element>
                                            </xsl:element>
                                        </xsl:if>
                                        <!-- End of attributes -->
                                        
                                        <xsl:element name="xsl:call-template">
                                            <xsl:attribute name="name" select="'infrastructureRootElements'"/>
                                        </xsl:element>
                                        
                                        <!-- Do ActRelationship stuff -->
                                        <xsl:call-template name="handleSpecificElements">
                                            <xsl:with-param name="in" select="concat($complexTypeR2-name,'.',$cdar2name)"/>
                                        </xsl:call-template>
                                        
                                        <xsl:element name="xsl:apply-templates">
                                            <xsl:attribute name="select" select="'self::*'"/>
                                            <xsl:attribute name="mode" select="$cdar2type"/>
                                        </xsl:element>
                                        <!-- End of elements -->
                                    </xsl:element>
                                </xsl:element>
                                
                                <!-- Filthy hack ... somehow in CDAr3 the component and componentOf are switched, so wait until we have component, and then append componentOf -->
                                <xsl:if test="$complexTypeR2-name='POCD_MT000040.ClinicalDocument' and $cdar2name='component'">
                                    <xsl:variable name="hcdar2name" select="'componentOf'"/>
                                    <xsl:variable name="hcdar3name" select="if ($elementNameMap//map[@cdar2=concat($complexTypeR2-name,'.',$hcdar2name)]) then ($elementNameMap//map[@cdar2=concat($complexTypeR2-name,'.',$hcdar2name)]/@cdar3) else ($hcdar2name)"/>
                                    <xsl:variable name="hctsub" select="'POCD_MT000040.Component1'"/>
                                    
                                    <xsl:element name="xsl:for-each">
                                        <xsl:attribute name="select" select="concat('hl7:',$hcdar2name)"/>
                                        
                                        <xsl:element name="xsl:element">
                                            <xsl:attribute name="name" select="$hcdar3name"/>
                                            <xsl:attribute name="namespace" select="'urn:hl7-org:v3'"/>
                                            
                                            <!-- Start of attributes -->
                                            <xsl:call-template name="handleSpecificAttributes">
                                                <xsl:with-param name="in" select="concat($complexTypeR2-name,'.',$hcdar2name)"/>
                                            </xsl:call-template>
                                            <xsl:element name="xsl:copy-of">
                                                <xsl:attribute name="select" select="'@nullFlavor|@typeCode|@classCode|@moodCode|@determinerCode|@inversionInd'"/>
                                            </xsl:element>
                                            <xsl:element name="xsl:if">
                                                <xsl:attribute name="test" select="'self::node()[@negationInd]'"/>
                                                
                                                <xsl:element name="xsl:attribute">
                                                    <xsl:attribute name="name" select="'actionNegationInd'"/>
                                                    <xsl:attribute name="select" select="'@negationInd'"/>
                                                </xsl:element>
                                            </xsl:element>
                                            <!-- End of attributes -->
                                            
                                            <xsl:element name="xsl:call-template">
                                                <xsl:attribute name="name" select="'infrastructureRootElements'"/>
                                            </xsl:element>
                                            
                                            <!-- Do ActRelationship stuff -->
                                            <xsl:call-template name="handleSpecificElements">
                                                <xsl:with-param name="in" select="concat($complexTypeR2-name,'.',$hcdar2name)"/>
                                            </xsl:call-template>
                                            
                                            <xsl:element name="xsl:apply-templates">
                                                <xsl:attribute name="select" select="'self::*'"/>
                                                <xsl:attribute name="mode" select="$hctsub"/>
                                            </xsl:element>
                                            <!-- End of elements -->
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:comment> Skipping mapping of '<xsl:value-of select="concat($complexTypeR2-name,'.',$cdar2name)"/>', because there is no matching '<xsl:value-of select="concat($complexTypeR3-name,'.',$cdar3name)"/>' </xsl:comment>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        
            <xsl:comment> Run through complexTypes in extensions </xsl:comment>
            <xsl:text>&#10;      </xsl:text>
            <xsl:element name="xsl:apply-templates">
                <xsl:attribute name="select">
                    <xsl:text>*[not(namespace-uri()='urn:hl7-org:v3')]</xsl:text>
                    <xsl:if test="count($allElementsDatatype)>0">
                        <xsl:text>[not(local-name()=(</xsl:text>
                        <xsl:for-each select="$allElementsDatatype">
                            <xsl:text>'</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>'</xsl:text>
                            <xsl:if test="position()!=last()">
                                <xsl:text>,</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>))]</xsl:text>
                    </xsl:if>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="handleSpecificAttributes">
        <xsl:param name="in"/>
        
        <xsl:choose>
            <xsl:when test="ends-with($in,'.patient') or $in='POCD_MT000040.Guardian.guardianPerson' or ends-with($in,'.assignedPerson') or ends-with($in,'.relatedPerson') or $in='POCD_MT000040.RelatedSubject.subject' or ends-with($in,'.associatedPerson')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PSN'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.relatedSubject')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PRS'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.providerOrganization') or ends-with($in,'.representedCustodianOrganization') or ends-with($in,'.receivedOrganization') or ends-with($in,'.representedOrganization') or ends-with($in,'.manufacturerOrganization') or ends-with($in,'.scopingOrganization') or ends-with($in,'.serviceProviderOrganization')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ORG'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.assignedAuthoringDevice')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'DEV'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.place')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PLC'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.assignedEntity') or $in='POCD_MT000040.InformationRecipient.intendedRecipient'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ASSIGNED'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.asOrganizationPartOf')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PART'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.IntendedRecipient.informationRecipient'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PSN'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ClinicalDocument.informationRecipient'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PRCP'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ClinicalDocument.documentationOf'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'DOC'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ClinicalDocument.inFulfillmentOf'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'FLFS'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ClinicalDocument.authorization'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'AUTH'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ClinicalDocument.componentOf' or $in='POCD_MT000040.Organizer.component'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'COMP'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.consumable')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'CSM'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.product')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PRD'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.specimen')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'SPC'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.performer')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PRF'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.author')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'AUT'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.informant')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INF'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Author.assignedAuthor'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ASSIGNED'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not($in='POCD_MT000040.RelatedSubject.subject') and ends-with($in,'.subject')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'SBJ'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.informant')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INF'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Section.entry'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>if (../hl7:*[@typeCode='DRIV']) then ('DRIV') else ('COMP')</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Observation.referenceRange'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'REFV'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.wholeOrganization')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ORG'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.EncompassingEncounter.location'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'LOC'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Participant2.participantRole'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ROL'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ReferenceRange.observationRange' or $in='POCD_MT000040.Precondition.criterion'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'OBS'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'moodCode'"/>
                    <xsl:attribute name="select"><xsl:text>'EVN.CRT'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Reference.externalAct'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ACT'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'moodCode'"/>
                    <xsl:attribute name="select"><xsl:text>'EVN'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Reference.externalDocument'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'DOC'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'moodCode'"/>
                    <xsl:attribute name="select"><xsl:text>'EVN'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Reference.externalObservation'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'OBS'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'moodCode'"/>
                    <xsl:attribute name="select"><xsl:text>'EVN'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Reference.externalProcedure'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PROC'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'moodCode'"/>
                    <xsl:attribute name="select"><xsl:text>'EVN'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Location.healthCareFacility'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'SDLOC'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.InFulfillmentOf.order'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ACT'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.RelatedDocument.parentDocument'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'DOCCLIN'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.HealthCareFacility.location'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PLC'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ends-with($in,'.precondition')">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'typeCode'"/>
                    <xsl:attribute name="select"><xsl:text>'PRCN'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.Consumable.manufacturedProduct'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ROL'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ManufacturedProduct.manufacturedLabeledDrug' or $in='POCD_MT000040.ManufacturedProduct.manufacturedMaterial'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'MMAT'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ParticipantRole.playingEntity' or $in='POCD_MT000040.SpecimenRole.specimenPlayingEntity'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ENT'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ParticipantRole.playingDevice'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'DEV'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ParticipantRole.scopingEntity'">
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'classCode'"/>
                    <xsl:attribute name="select"><xsl:text>'ENT'</xsl:text></xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:attribute">
                    <xsl:attribute name="name" select="'determinerCode'"/>
                    <xsl:attribute name="select"><xsl:text>'INSTANCE'</xsl:text></xsl:attribute>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="handleSpecificElements">
        <xsl:param name="in"/>
        
        <xsl:choose>
            <xsl:when test="$in='POCD_MT000040.ClinicalDocument.documentationOf' or $in='POCD_MT000040.ClinicalDocument.inFulfillmentOf' or $in='POCD_MT000040.ClinicalDocument.authorization' or $in='POCD_MT000040.ClinicalDocument.componentOf' or $in='POCD_MT000040.ClinicalDocument.relatedDocument'">
                <xsl:element name="xsl:element">
                    <xsl:attribute name="name" select="'blockedContextActRelationshipType'"/>
                    <xsl:attribute name="namespace" select="'urn:hl7-org:v3'"/>
                    
                    <xsl:element name="xsl:attribute">
                        <xsl:attribute name="name" select="'code'"/>
                        <xsl:attribute name="select"><xsl:text>'ART'</xsl:text></xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="xsl:element">
                    <xsl:attribute name="name" select="'blockedContextParticipationType'"/>
                    <xsl:attribute name="namespace" select="'urn:hl7-org:v3'"/>
                    
                    <xsl:element name="xsl:attribute">
                        <xsl:attribute name="name" select="'code'"/>
                        <xsl:attribute name="select"><xsl:text>'PART'</xsl:text></xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="xsl:element">
                    <xsl:attribute name="name" select="'actAttributeContextBlockedInd'"/>
                    <xsl:attribute name="namespace" select="'urn:hl7-org:v3'"/>
                    
                    <xsl:element name="xsl:attribute">
                        <xsl:attribute name="name" select="'value'"/>
                        <xsl:attribute name="select" select="'true()'"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$in='POCD_MT000040.ClinicalDocument.component' or $in='POCD_MT000040.StructuredBody.component' or $in='POCD_MT000040.Section.component' or $in='POCD_MT000040.Section.entry'">
                <xsl:element name="xsl:element">
                    <xsl:attribute name="name" select="'blockedContextActRelationshipType'"/>
                    <xsl:attribute name="namespace" select="'urn:hl7-org:v3'"/>
                    
                    <xsl:element name="xsl:attribute">
                        <xsl:attribute name="name" select="'code'"/>
                        <xsl:attribute name="select"><xsl:text>'ART'</xsl:text></xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="xsl:element">
                    <xsl:attribute name="name" select="'actAttributeContextBlockedInd'"/>
                    <xsl:attribute name="namespace" select="'urn:hl7-org:v3'"/>
                    
                    <xsl:element name="xsl:attribute">
                        <xsl:attribute name="name" select="'value'"/>
                        <xsl:attribute name="select" select="'false()'"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="fallbackConversions">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:comment> processing-instruction()|comment()|text() </xsl:comment>
        <xsl:text>&#10;   </xsl:text>
        <xsl:element name="xsl:template">
            <xsl:attribute name="match" select="'processing-instruction()|comment()|text()'"/>
            
            <xsl:element name="xsl:copy-of">
                <xsl:attribute name="select" select="'self::node()'"/>
            </xsl:element>
        </xsl:element>
        
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:comment> copy any other node as-is </xsl:comment>
        <xsl:text>&#10;   </xsl:text>
        <xsl:element name="xsl:template">
            <xsl:attribute name="match" select="'*'"/>
            
            <xsl:element name="xsl:copy-of">
                <xsl:attribute name="select" select="'self::node()'"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- Helper template for building RIM model stuff -->
    <xsl:template match="*:containedClass" mode="getClass">
        <xsl:variable name="attributes">
            <xsl:apply-templates select="*:class/*:attribute" mode="createAttr"/>
            
            <xsl:for-each select="*:class/*:parentClass[not(@name='InfrastructureRoot')]">
                <xsl:variable name="pc" select="@name"/>
                <xsl:apply-templates select="/*:staticModel/*:containedClass[*:class[@name=$pc]]" mode="getAttr"/>
            </xsl:for-each>
        </xsl:variable>
        
        <class name="{*:class/@name}">
            <xsl:for-each select="$attributes/attribute">
                <xsl:sort select="number(@sortKey)"/>
                <xsl:copy-of select="self::node()"/>
            </xsl:for-each>
        </class>
    </xsl:template>
    
    <!-- Helper template for building RIM model stuff -->
    <xsl:template match="*:containedClass" mode="getAttr">
        <xsl:apply-templates select="*:class/*:attribute" mode="createAttr"/>
        
        <xsl:for-each select="*:class/*:parentClass[not(@name='InfrastructureRoot')]">
            <xsl:variable name="pc" select="@name"/>
            <xsl:apply-templates select="/*:staticModel/*:containedClass[*:class[@name=$pc]]" mode="#current"/>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Helper template for building RIM model stuff -->
    <xsl:template match="*:attribute" mode="createAttr">
        <xsl:variable name="class" select="../@name"/>
        <xsl:variable name="nm" select="@name"/>
        <!-- The tokenize stuff takes care of flavors which are not really interesting in this context -->
        <xsl:variable name="dtr1">
            <xsl:variable name="dt" select="tokenize(doc($rimcoremif-dtr1)/*:staticModel/*:containedClass[*:class[@name=$class]]/*:class/*:attribute[@name=$nm]/*:type/@name,'\.')[1]"/>
            <xsl:if test="not($dt=('BAG','LIST','SET'))">
                <xsl:value-of select="$dt"/>
                <xsl:if test="doc($rimcoremif-dtr1)/*:staticModel/*:containedClass[*:class[@name=$class]]/*:class/*:attribute[@name=$nm]/*:type/*:argumentDatatype">
                    <xsl:text>_</xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:for-each select="doc($rimcoremif-dtr1)/*:staticModel/*:containedClass[*:class[@name=$class]]/*:class/*:attribute[@name=$nm]/*:type/*:argumentDatatype/@name">
                <xsl:value-of select="tokenize(.,'\.')[1]"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>_</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="dtr2">
            <xsl:value-of select="tokenize(*:type/@name,'\.')[1]"/>
            <xsl:if test="*:type/*:argumentDatatype">
                <xsl:text>_</xsl:text>
            </xsl:if>
            <xsl:for-each select="*:type/*:argumentDatatype/@name">
                <xsl:value-of select="tokenize(.,'\.')[1]"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>_</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="not(string(@isImmutable)='true')">
            <attribute name="{@name}" sortKey="{@sortKey}" minimumMultiplicity="{@minimumMultiplicity}" maximumMultiplicity="{@maximumMultiplicity}" dtr1="{$dtr1}" dtr2="{$dtr2}" conformance="{@conformance}" isMandatory="{@isMandatory}"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>