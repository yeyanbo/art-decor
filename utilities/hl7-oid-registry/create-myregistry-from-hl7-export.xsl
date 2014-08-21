<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (C) 2011-2013 Art-Decor Expert Group
    
    Author: Alexander Henket
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:local="urn:local"
    exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 31, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> ahenket</xd:p>
            <xd:p>Maps as much data as possible from the HL7 Registry in ISO 13582 Sharing of OIR Registries format.<xd:p>Prerequisite: export the HL7 Registry with all fields (http://www.hl7.org/oid/index.cfm - option "All OIDs" under "OID Excel Reports", use format XML). The export contains descriptions (3 fields) with things like &#233;. Could not find how to replace in xquery, so best to replace those before running this query.</xd:p></xd:p>
            <xd:p>The current mapping is as follows: <xd:ul>
                    <xd:li>Retrieve only OIDs with pattern [^[\d\.]+$]: This means we're skipping '0160/01/03 12:00:00', '2001/02/16 12:00:00', '655F67B1-2B11-4038-B82F-F6AB2F566F87', 'http://www.oid-info.com/get/2.16.840.1.113883.3.20'</xd:li>
                    <xd:li>Retrieve only OIDs with lower-case(assignment_status)=('complete','retired','deprecated','obsolete')<br/> This means we're skipping status 'unknown', 'edited', 'rejected', 'pending', 'proposed'</xd:li>
                    <xd:li>OID creation date is Entry_Timestamp, Date_begun, Date_finalized or nullFlavor NI</xd:li>
                    <xd:li>Registration authority is fixed to HL7 International</xd:li>
                </xd:ul></xd:p>
            <xd:pre>Is mapped?      HL7                         Remark
y               Comp_OID                    
y               Symbolic_name               adjusted to ISO 13582 format
y               CodingSystemName            
y               SubmitterFirst              
y               SubmitterLast               
y               Submitter_Email             
y               Submitter2                  Additional property
y               Contact_person_desc         
y               Contact_person_address      
y               Contact_person_phone        
y               Contact_person_email        
y               Contact_person_info         
y               Resp_body_name              
y               Resp_body_address           
y               Resp_body_phone             
y               Resp_body_email             
y               Resp_body_URL               
y               Resp_body_Type              
y               Resp_body_oid               
y               External_OID_flag           Additional property
y               externalOIDsubType          Additional property
y               replacedBy                  Additional property
y               Oid_Type                    Additional property and used to value category/@code
y               assignment_status           
y               AA_OID                      Additional property
y               AA_description              Additional property
y               Object_description          
y               Date_begun                  
y               Date_finalized              
y               Entry_Timestamp             
y               T396mnemonic                Additional property
y               Preferred_Realm             </xd:pre>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:param name="registryFileName" select="'hl7org-oids.xml'"/>
    
    <xsl:template match="/">
        <xsl:result-document href="{$registryFileName}" omit-xml-declaration="yes" indent="yes">
            <myoidregistry xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="hl7org" xsi:noNamespaceSchemaLocation="http://decor.nictiz.nl:8877/tools/oids/core/DECORmyoidregistry.xsd">
                <access>
                    <author username="kai" rights="rw"/>
                    <author username="maarten" rights="rw"/>
                    <author username="alexander" rights="rw"/>
                </access>
                <registry>
                    <validTime>
                        <low value="{replace(substring(string(current-dateTime()),1,10),'-','')}"/>
                    </validTime>
                    <scopedOID value="2.16.840.1.113883"/>
                    <name value="The HL7 International Registry"/>
                    <description language="en-US" mediaType="text/plain" value="This is the HL7 International registry"/>
                    <description language="nl-NL" mediaType="text/plain" value="Dit is het HL7 International register"/>
                    <person>
                        <name>
                            <part type="GIV" value="Ted"/>
                            <part type="FAM" value="Klein"/>
                        </name>
                    </person>
                    <hostingOrganization>
                        <name>
                            <part value="ART-DECOR"/>
                        </name>
                    </hostingOrganization>
                    <xsl:for-each select="dataroot/OID_root[Comp_OID[matches(text(),'^[\d\.]+$')]][assignment_status[lower-case(.)=('complete','retired','deprecated','obsolete')]]">
                        <xsl:variable name="dateBegun" select="local:convertUSDateTimeToTimestamp(Date_begun/normalize-space(text()))"/>
                        <xsl:variable name="dateFinal" select="local:convertUSDateTimeToTimestamp(Date_finalized/normalize-space(text()))"/>
                        <xsl:variable name="dateEntry" select="local:convertUSDateTimeToTimestamp(Date_finalized/normalize-space(text()))"/>
                        <xsl:variable name="externalFlag" select="lower-case(External_OID_flag/normalize-space(text()))"/>
                        <xsl:variable name="symbolicName" select="local:cleanSymbolicName(Symbolic_name/normalize-space(text()))"/>
                        
                        <oid>
                            <dotNotation value="{Comp_OID/normalize-space(text())}"/>
                            <xsl:if test="string-length($symbolicName)>0">
                                <symbolicName value="{$symbolicName}"/>
                            </xsl:if>
                            <!-- 
                                N   - node
                                NRA - registration authority (RA)
                                NMN - structure for the management of OIDs (it is not good practice but we know that some of these nodes in some registries also identify objects, which should not be)
                                L   - leaf
                                LIO - identifies an instance of an object
                                LNS - a namespace identifier
                            -->
                            <category code="{local:getCategory(Comp_OID/normalize-space(text()),Oid_Type/normalize-space(text()))}"/>
                            <status code="{local:getStatus(assignment_status/text())}"/>
                            <creationDate>
                                <xsl:choose>
                                    <xsl:when test="string-length($dateEntry)>0">
                                        <xsl:attribute name="value" select="$dateEntry"/>
                                    </xsl:when>
                                    <xsl:when test="string-length($dateBegun)>0">
                                        <xsl:attribute name="value" select="$dateBegun"/>
                                    </xsl:when>
                                    <xsl:when test="string-length($dateFinal)>0">
                                        <xsl:attribute name="value" select="$dateFinal"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="nullFlavor" select="'NI'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </creationDate>
                            <realm code="{Preferred_Realm/normalize-space(text())}"/>
                            <xsl:variable name="oidDescription" select="local:cleanDescription(Object_description/text())"/>
                            <description language="en-US" mediaType="text/plain" value="{$oidDescription}">
                                <xsl:if test="CodingSystemName[string-length()>0]">
                                    <thumbnail value="{CodingSystemName/normalize-space(text())}"/>
                                </xsl:if>
                            </description>
                            <registrationAuthority>
                                <code code="PRI"/>
                                <scopingOrganization>
                                    <name>
                                        <part value="HL7 International"/>
                                    </name>
                                </scopingOrganization>
                            </registrationAuthority>
                            <responsibleAuthority>
                                <code code="PRI"/>
                                <statusCode code="active"/>
                                <validTime>
                                    <xsl:choose>
                                        <xsl:when test="string-length($dateEntry)>0">
                                            <low value="{$dateEntry}"/>
                                        </xsl:when>
                                        <xsl:when test="string-length($dateBegun)>0">
                                            <low value="{$dateBegun}"/>
                                        </xsl:when>
                                        <xsl:when test="string-length($dateFinal)>0">
                                            <low value="{$dateFinal}"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="nullFlavor" select="'NI'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </validTime>
                                <xsl:variable name="contactName" select="Contact_person_desc/normalize-space(text())"/>
                                <xsl:variable name="contactAddr" select="Contact_person_address/string()"/>
                                <xsl:variable name="contactPhone" select="Contact_person_phone/normalize-space(text())"/>
                                <xsl:variable name="contactEmail" select="Contact_person_email/normalize-space(text())"/>
                                <xsl:variable name="contactTitle" select="Contact_person_info/normalize-space(text())"/>
                                <xsl:if test="string-length($contactName)>0 or string-length($contactAddr)>0 or string-length($contactPhone)>0 or string-length($contactEmail)>0 or string-length($contactTitle)>0">
                                    <person>
                                        <name>
                                            <xsl:choose>
                                                <xsl:when test="string-length($contactName)>0">
                                                    <part value="{$contactName}"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:attribute name="nullFlavor" select="'NI'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </name>
                                        <xsl:if test="string-length($contactAddr)>0">
                                            <addr>
                                                <xsl:for-each select="tokenize($contactAddr,'\n')[not(normalize-space()=$contactName)]">
                                                    <part value="{normalize-space(.)}"/>
                                                </xsl:for-each>
                                            </addr>
                                        </xsl:if>
                                        <xsl:if test="string-length($contactPhone)>0">
                                            <telecom value="{concat('tel:',replace($contactPhone,' ','%20'))}"/>
                                        </xsl:if>
                                        <xsl:if test="string-length($contactEmail)>0">
                                            <telecom value="{concat('mailto:',$contactEmail)}"/>
                                        </xsl:if>
                                    </person>
                                </xsl:if>
                                <scopingOrganization>
                                    <xsl:variable name="responsibleBodyName" select="Resp_body_name/normalize-space(text())"/>
                                    <xsl:if test="string-length(Resp_body_oid[matches(normalize-space(text()),'^[\d\.]+$')])>0">
                                        <id value="{Resp_body_oid/normalize-space(text())}"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="string-length($responsibleBodyName)>0">
                                            <name>
                                                <part value="{$responsibleBodyName}"/>
                                            </name>
                                        </xsl:when>
                                        <xsl:when test="starts-with($externalFlag,'int')">
                                            <name>
                                                <part value="HL7 International"/>
                                            </name>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <name nullFlavor="NI"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="string-length(Resp_body_address/normalize-space(text()))>0">
                                        <addr>
                                            <xsl:for-each select="tokenize(Resp_body_address/text(),'\n')[not(normalize-space()=$responsibleBodyName)]">
                                                <part value="{normalize-space(.)}"/>
                                            </xsl:for-each>
                                        </addr>
                                    </xsl:if>
                                    <xsl:if test="string-length(Resp_body_phone/normalize-space(text()))>0">
                                        <telecom value="{concat('tel:',replace(Resp_body_phone/normalize-space(text()),' ','%20'))}"/>
                                    </xsl:if>
                                    <xsl:if test="string-length(Resp_body_email/normalize-space(text()))>0">
                                        <telecom value="{concat('mailto:',Resp_body_email/normalize-space(text()))}"/>
                                    </xsl:if>
                                    <xsl:if test="string-length(Resp_body_URL/normalize-space(text()))>0">
                                        <telecom value="{Resp_body_URL/normalize-space(text())}"/>
                                    </xsl:if>
                                </scopingOrganization>
                            </responsibleAuthority>
                            
                            <xsl:variable name="submissionDate" select="local:convertUSDateTimeToTimestamp(Date_begun/normalize-space(text()))"/>
                            <xsl:variable name="submissionFirst" select="SubmitterFirst/normalize-space(text())"/>
                            <xsl:variable name="submissionLast" select="SubmitterLast/normalize-space(text())"/>
                            <xsl:variable name="submissionEmail" select="Submitter_Email/normalize-space(text())"/>
                            
                            <xsl:if test="string-length($submissionDate)>0 and string-length(concat($submissionFirst,$submissionLast))>0">
                                <submittingAuthority>
                                    <code code="PRI"/>
                                    <applicationDate value="{$submissionDate}"/>
                                    <person>
                                        <name>
                                            <xsl:if test="string-length($submissionFirst)>0">
                                                <part value="{$submissionFirst}" type="GIV"/>
                                            </xsl:if>
                                            <xsl:if test="string-length($submissionLast)>0">
                                                <part value="{$submissionLast}" type="FAM"/>
                                            </xsl:if>
                                        </name>
                                        <xsl:if test="string-length($submissionEmail)>0">
                                            <telecom value="{concat('mailto:',$submissionEmail)}"/>
                                        </xsl:if>
                                    </person>
                                    <scopingOrganization>
                                        <name nullFlavor="NI"/>
                                    </scopingOrganization>
                                </submittingAuthority>
                            </xsl:if>
                            <xsl:if test="Oid_Type[string-length(normalize-space())>0]">
                                    <additionalProperty>
                                        <attribute value="Oid_Type"/>
                                        <value value="{Oid_Type/text()}"/>
                                    </additionalProperty>
                            </xsl:if>
                            <xsl:if test="Submitter2[string-length(normalize-space())>0]">
                                    <additionalProperty>
                                        <attribute value="Submitter2"/>
                                        <value value="{Submitter2/text()}"/>
                                    </additionalProperty>
                            </xsl:if>
                            <xsl:if test="Resp_body_Type[string-length(normalize-space())>0]">
                                    <additionalProperty>
                                        <attribute value="Resp_body_Type"/>
                                        <value value="{Resp_body_Type/text()}"/>
                                    </additionalProperty>
                            </xsl:if>
                            <xsl:if test="External_OID_flag[string-length(normalize-space())>0]">
                                    <additionalProperty>
                                        <attribute value="External_OID_flag"/>
                                        <value value="{External_OID_flag/lower-case(text())}"/>
                                    </additionalProperty>
                            </xsl:if>
                            <xsl:if test="externalOIDsubType[string-length(normalize-space())>0]">
                                    <additionalProperty>
                                        <attribute value="externalOIDsubType"/>
                                        <value value="{externalOIDsubType/text()}"/>
                                    </additionalProperty>
                            </xsl:if>
                            <xsl:if test="AA_OID[string-length(normalize-space())>0]">
                                    <additionalProperty>
                                        <attribute value="AA_OID"/>
                                        <value value="{AA_OID/text()}"/>
                                    </additionalProperty>
                            </xsl:if>
                            <xsl:if test="AA_description[string-length(normalize-space())>0]">
                                <additionalProperty>
                                    <attribute value="AA_description"/>
                                    <value value="{local:cleanDescription(AA_description/text())}"/>
                                </additionalProperty>
                            </xsl:if>
                            <xsl:if test="T396mnemonic[string-length(normalize-space())>0]">
                                <additionalProperty>
                                    <attribute value="T396mnemonic"/>
                                    <value value="{T396mnemonic/text()}"/>
                                </additionalProperty>
                            </xsl:if>
                            <xsl:if test="replacedBy[string-length(normalize-space())>0]">
                                    <additionalProperty>
                                        <attribute value="replacedBy"/>
                                        <value value="{replacedBy/text()}"/>
                                    </additionalProperty>
                            </xsl:if>
                        </oid>
                    </xsl:for-each>
                </registry>
            </myoidregistry>
        </xsl:result-document>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Return category</xd:p>
        </xd:desc>
        <xd:param name="oid">The OID from the field 'Comp_OID'</xd:param>
        <xd:param name="oidtype">The HL7 V3 Registry type from the field 'Oid_Type'</xd:param>
        <xd:return>ISO 13582 OID category</xd:return>
    </xd:doc>
    <xsl:function name="local:getCategory" as="xs:string">
        <xsl:param name="oid" as="xs:string?"/>
        <xsl:param name="oidtype" as="xs:string?"/>
        
        <xsl:choose>
            <xsl:when test="$oid = concat('2.16.840.1.113883.',$oidtype)">
                <xsl:text>NMN</xsl:text>
            </xsl:when>
            <xsl:when test="1">
                <!-- 1 - OID for an HL7 Internal Object -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="2">
                <!-- 2 - OID for an HL7 Body or Group -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="3">
                <!-- 3 - Root to be a Registration Authority -->
                <xsl:text>NRA</xsl:text>
            </xsl:when>
            <xsl:when test="4">
                <!-- 4 - OID for a Registered Namespace -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="5">
                <!-- 5 - OID for an HL7 Internal Code System -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="6">
                <!-- 6 - OID for an External Code System -->
                <xsl:text>L</xsl:text>
            </xsl:when>
            <xsl:when test="7">
                <!-- 7 - OID for an HL7 Document -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="8">
                <!-- 8 - OID for an HL7 Document Artifact -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="9">
                <!-- 9 - OID for an HL7 Conformance Profile -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="10">
                <!-- 10 - OID for an HL7 Template -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="11">
                <!-- 11 - OID for an HL7 Internal Value Set -->
                <xsl:text>L</xsl:text>
            </xsl:when>
            <xsl:when test="12">
                <!-- 12 - OID for an Version 2.x Table -->
                <xsl:text>L</xsl:text>
            </xsl:when>
            <xsl:when test="13">
                <!-- 13 - OID for an External Value Set -->
                <xsl:text>L</xsl:text>
            </xsl:when>
            <xsl:when test="14">
                <!-- 14 - branch node subtype -->
                <xsl:text>N</xsl:text>
            </xsl:when>
            <xsl:when test="15">
                <!-- 15 - Defined external codesets -->
                <xsl:text>L</xsl:text>
            </xsl:when>
            <xsl:when test="17">
                <!-- 17 - Other Type OID -->
                <xsl:text>LNS</xsl:text>
            </xsl:when>
            <xsl:when test="18">
                <!-- 18 - OID for a Version 2.x Coding System -->
                <xsl:text>L</xsl:text>
            </xsl:when>
            <xsl:when test="19">
                <!-- 19 - OID for a published HL7 Example -->
                <xsl:text>NMN</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!--  don't know. go to default value  -->
                <xsl:text>LNS</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Return statusCode</xd:p>
        </xd:desc>
        <xd:param name="input">required. HL7 V3 Registry status code</xd:param>
        <xd:return>ISO 13582 status code</xd:return>
    </xd:doc>
    <xsl:function name="local:getStatus" as="xs:string">
        <xsl:param name="input" as="xs:string?"/>
        <xsl:variable name="cleanInput" select="lower-case($input)"/>
        <xsl:choose>
            <xsl:when test="$cleanInput='complete'">
                <xsl:text>completed</xsl:text>
            </xsl:when>
            <xsl:when test="$cleanInput='unknown'">
                <xsl:text>unknown</xsl:text>
            </xsl:when>
            <xsl:when test="$cleanInput='retired'">
                <xsl:text>retired</xsl:text>
            </xsl:when>
            <xsl:when test="$cleanInput='deprecated'">
                <xsl:text>retired</xsl:text>
            </xsl:when>
            <xsl:when test="$cleanInput='obsolete'">
                <xsl:text>retired</xsl:text>
            </xsl:when>
            <xsl:when test="$cleanInput='pending'">
                <xsl:text>pending</xsl:text>
            </xsl:when>
            <xsl:when test="$cleanInput='rejected'">
                <xsl:text>unknown</xsl:text>
            </xsl:when>
            <xsl:when test="$cleanInput='proposed'">
                <xsl:text>pending</xsl:text>
            </xsl:when>
            <xsl:when test="$cleanInput='edited'">
                <xsl:text>unknown</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>unknown</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Returns a valid ISO 21090 formatted timestamp or the empty string</xd:p>
        </xd:desc>
        <xd:param name="input">optional. String in the HL7 Registry with a US date time yyyy/mm/dd hh:mm:ss</xd:param>
        <xd:return>Valid ISO 21090 TS (yyyyMMddHHmmss) or empty string</xd:return>
    </xd:doc>
    <xsl:function name="local:convertUSDateTimeToTimestamp" as="xs:string?">
        <xsl:param name="input" as="xs:string?"/>
        <xsl:if test="matches(normalize-space($input),'^\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}$')">
            <xsl:value-of select="replace(normalize-space($input),'[^\d]','')"/>
        </xsl:if>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The HL7 Registry contains symbolic names, but they do not match the pattern for it as layed out in ISO 13582:
                "A symbolic short name, unique among the siblings of the arc of the OID. The ISO rules on Secondary Arc Identifiers, 
                as laid out in Rec. ITU-T | ISO/IEC 9834-1 Procedures for Registration Authorities, section 6.2.2, apply: 
                <xd:ul><xd:li>identifiers of an arc are required to commence with a lowercase letter, and to contain only letters, digits, and hyphens.</xd:li> 
                <xd:li>the last characters shall not be a hyphen - there shall be no two consecutive hyphens in the name"</xd:li></xd:ul></xd:p>
            <xd:p>The function prefixes a lower-case x if the first character is not [a-zA-Z], the function lower-cases the first character
                if it is [A-Z]. The function replaces any character that is not in [a-zA-Z0-9-] with a hyphen ("-") and replaces all double
                hyphens with a singular hyphen. Finally if the string ends in a hyphen, it removes that last character.</xd:p>
            <xd:p>Examples of actual input and output:</xd:p>
            <xd:ul>
                <xd:li>CMET > cMET</xd:li>
                <xd:li>OklahomaDLN > oklahomaDLN</xd:li>
                <xd:li>Service actor type > service-actor-type</xd:li>
                <xd:li>x_ActMoodDefEvn > x-ActMoodDefEvn</xd:li>
                <xd:li>Test of Email Server ---Delete---- > test-of-Email-Server-Delete</xd:li>
            </xd:ul>
        </xd:desc>
        <xd:param name="input">optional. String in the HL7 Inc registry that holds the symbolic name</xd:param>
        <xd:return>Valid symbolic name or an empty string</xd:return>
    </xd:doc>
    <xsl:function name="local:cleanSymbolicName" as="xs:string?">
        <xsl:param name="input" as="xs:string?"/>
        <xsl:variable name="output" select="normalize-space($input)"/>
        
        <!-- first char must be a-z -->
        <xsl:variable name="output-xstart">
            <xsl:if test="string-length($output)>0 and not(matches($output,'^[a-zA-Z]'))">
                <xsl:text>x</xsl:text>
            </xsl:if>
            <xsl:value-of select="$output"/>
        </xsl:variable>
        <!-- first char must be lower case -->
        <xsl:variable name="output-firstchar">
            <xsl:if test="string-length($output-xstart)>0">
                <xsl:value-of select="concat(lower-case(substring($output-xstart,1,1)),substring($output-xstart,2))"/>
            </xsl:if>
        </xsl:variable>
        <!-- replace any character that is not in range [a-zA-Z0-9-] with a hyphen -->
        <xsl:variable name="output-legalchars" select="replace($output-firstchar,'[^a-zA-Z0-9-]','-')"/>
        <!-- replace double hyphens with a singular hyphen, need function -->
        <xsl:variable name="output-singlehyphen" select="local:replaceAll(replace($output-legalchars,'--','-'),'--','-')"/>
        <!-- last char must not be - -->
        <xsl:choose>
            <xsl:when test="ends-with($output-singlehyphen,'-')">
                <xsl:value-of select="substring($output-singlehyphen,1,string-length($output-singlehyphen)-1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$output-singlehyphen"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Recurses until there's positively no more occurence of the search string to replace. The regular
                replace() function will leave occurences if they are nested. Example: replace('---Test---','--','-')
                yields '--Test--'</xd:p>
        </xd:desc>
        <xd:param name="input">optional. String to replace contents in</xd:param>
        <xd:param name="search">required. Search string</xd:param>
        <xd:param name="replace">required. String to replace search string with</xd:param>
        <xd:return>Input string with all occurences of $search replaced with $replace</xd:return>
    </xd:doc>
    <xsl:function name="local:replaceAll" as="xs:string?">
        <xsl:param name="input" as="xs:string?"/>
        <xsl:param name="search" as="xs:string"/>
        <xsl:param name="replace" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="contains($input,$search)">
                <xsl:value-of select="local:replaceAll(replace($input,$search,$replace),$search,$replace)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replaces all occurences of &amp;(quot|lt|gt|apos|amp); with a normal entity, and cleans up a couple of mangled others. These characters appear to be corruption from encoding conversion problems between the entry form and the underlying Registry database</xd:p>
        </xd:desc>
        <xd:param name="input">optional. String to replace contents in</xd:param>
        <xd:return>Input string with all occurences of escaped entities replaced with regular entities</xd:return>
    </xd:doc>
    <xsl:function name="local:cleanDescription" as="xs:string?">
        <xsl:param name="input" as="xs:string?"/>
        <xsl:variable name="a1" select="local:replaceAll(local:replaceAll($input,'&amp;amp;quot;','&quot;'),'&amp;quot;','&quot;')"/>
        <xsl:variable name="a2" select="local:replaceAll(local:replaceAll($a1,'&amp;amp;apos;',''''),'&amp;apos;','''')"/>
        <xsl:variable name="a3" select="local:replaceAll(local:replaceAll($a2,'&amp;amp;lt;','&lt;'),'&amp;lt;','&lt;')"/>
        <xsl:variable name="a4" select="local:replaceAll(local:replaceAll($a3,'&amp;amp;gt;','&gt;'),'&amp;gt;','>')"/>
        <xsl:variable name="a5" select="local:replaceAll(local:replaceAll($a4,'&amp;amp;','&amp;'),'&amp;amp;','&amp;')"/>
        
        <!-- Mangled UTF-8 in the original entry form probably, that looked like smart single quotes -->
        <xsl:variable name="a51" select="local:replaceAll($a5,'&amp;#226;&amp;#128;&amp;#153;','''')"/>
        <xsl:variable name="a52" select="local:replaceAll($a51,'&amp;#226;&amp;#128;&amp;#156;','''')"/>
        <xsl:variable name="a53" select="local:replaceAll($a52,'&amp;#226;&amp;#128;','''')"/>
        <!-- Handle any of these UTF-8 constituents in other contexts -->
        <xsl:variable name="a54" select="replace($a53,'&amp;#128;','')"/>
        <xsl:variable name="a55" select="replace($a54,'&amp;#153;','')"/>
        <xsl:variable name="a56" select="replace($a54,'&amp;#156;','')"/>
        <xsl:variable name="a57" select="replace($a55,'&amp;#226;','&#226;')"/>
        
        <xsl:variable name="a6" select="local:replaceAll($a57,'&amp;#146;','''')"/>
        <xsl:variable name="a7" select="local:replaceAll($a6,'&amp;#147;','&quot;')"/>
        <xsl:variable name="a8" select="local:replaceAll($a7,'&amp;#148;','&quot;')"/>
        <xsl:variable name="a9" select="replace($a8,'&amp;#150;','-')"/>
        <xsl:variable name="a10" select="local:replaceAll($a9,'&#732;','''')"/>
        <xsl:variable name="a11" select="replace($a10,'&amp;#8211;','-')"/>
        <xsl:variable name="a12" select="replace($a11,'&amp;#8226;','•')"/>
        <xsl:variable name="a13" select="local:replaceAll($a12,'&#x92;','''')"/>
        
        <xsl:value-of select="$a13"/>
    </xsl:function>
</xsl:stylesheet>