xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";


(: if action=periodic-sandbox-refresh a schedule job is installed, in all other cases  :)
let $action := if (request:exists()) then request:get-parameter('action', '') else ''
let $secret := if (request:exists()) then request:get-parameter('secret', '') else ''


(: the sandbox collection on this server (if any) :)
let $sandbox := $get:colDecorData//decor[project/@prefix='sandbox-']

(: get users - preserve them :)
let $additionalsandboxusers := 
    <a>
    {
        $sandbox//project/author[(@username != "kai") and (@username != "guest") and (@username != "adbot") and (@username != "sigbot")]
    }
    </a>



(: the original sandbox XML :)
let $sandboxorig := 
<decor xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://art-decor.org/ADAR/rv/DECOR.xsd">
    <project id="2.16.840.1.113883.3.1937.99.61.3" prefix="sandbox-" defaultLanguage="en-US">
        <name language="en-US">Sandbox: EKG Report CDA Document</name>
        <name language="nl-NL">Sandbox: ECG-verslag CDA-document</name>
        <desc language="en-US">Sandbox: Electrocardiogram Report as a Minimal CDA Document <p/>
            This is the sandbox as a playgroup to test ART-DECOR, derived from a minimal CDA Release 2 document based on a real use case of an Electrocardiogram Report of a patient 
            (see <a href="http://art-decor.org/art-decor/decor-project--demo3-">The ART-DECOR demo3 example</a>).
            <h1>
                <img src="http://art-decor.org/mediawiki/images/d/d5/Under_construction_icon-blue.svg" width="35px"/>
                Please note that all changes to this project will be overwritten every day at 0300 Coordinated Universal Time UTC</h1>
        </desc>
        <desc language="nl-NL">Sandbox: Electrocardiogram-verslag als een minimaal CDA-document <p/>
            Dit is de sandbox als probeeromgeving om ART-DECOR uit te proberen, afgeleid van een  minimaal CDA Release 2 document gebaseerd op een werkelijke use case van een Electrocardiogram-verslag van een patiënt 
            (zie <a href="http://art-decor.org/art-decor/decor-project--demo3-">Het ART-DECOR demo3 voorbeeld</a>).
            <h1>
                <img src="http://art-decor.org/mediawiki/images/d/d5/Under_construction_icon-blue.svg" width="35px"/>
                Merk op dat alle wijzigingen in dit project dagelijks overschreven worden om 03:00 uur Coordinated Universal Time UTC<br/>
                Afgezien van de projectnaam en deze beschrijving is de inhoud van dit project alleen in het Engels beschikbaar.</h1>
        </desc>
        <copyright years="2012 2013 2014" by="The ART-DECOR expert group" logo="art-decor-logo-small.jpg">
            <addrLine>E info@art-decor.org</addrLine>
            <addrLine>E contact@art-decor.org</addrLine>
        </copyright>
        <author id="1" username="kai">dr Kai U. Heitmann</author>
        <author id="99" username="adbot">ADbot</author>
        {
            $additionalsandboxusers/*
        }
        <reference url="http://art-decor.org/demos/sandbox/"/>
        <buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ad1bbr-"/>
        <version by="1" date="2013-02-10T12:52:00">
            <desc language="en-US">Initial version of sandbox example</desc>
        </version>
        <release by="1" date="2013-02-20T12:52:00" versionLabel="1.0beta">
            <note language="en-US">Initial release of the first complete sandbox example</note>
        </release>
    </project>
    <datasets>
        <dataset id="2.16.840.1.113883.3.1937.99.61.3.1.1" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
            <name language="en-US">Decor Sandbox dataset</name>
            <desc language="en-US">Decor Sandbox dataset: Electrocardiogram Report</desc>
            <concept id="2.16.840.1.113883.3.1937.99.61.3.2.1" type="group" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
                <name language="en-US">Person</name>
                <desc language="en-US">Person</desc>
                <concept id="2.16.840.1.113883.3.1937.99.61.3.2.10" type="item" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
                    <name language="en-US">Name</name>
                    <desc language="en-US">Name of the person</desc>
                    <valueDomain type="complex"/>
                </concept>
                <concept id="2.16.840.1.113883.3.1937.99.61.3.2.20" statusCode="draft" effectiveDate="2013-02-10T00:00:00" type="item">
                    <name language="en-US">National Patient Identifier</name>
                    <desc language="en-US">National Patient Identifier, here: Dutch Burgerservicenummer</desc>
                    <valueDomain type="identifier">
                        <property/>
                    </valueDomain>
                </concept>
                <concept id="2.16.840.1.113883.3.1937.99.61.3.2.30" type="item" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
                    <name language="en-US">Date of birth</name>
                    <desc language="en-US">Date of birth of the person</desc>
                    <valueDomain type="date"/>
                </concept>
                <concept id="2.16.840.1.113883.3.1937.99.61.3.2.40" type="item" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
                    <name language="en-US">Gender</name>
                    <desc language="en-US">Gender of the person</desc>
                    <valueDomain type="code">
                        <conceptList id="2.16.840.1.113883.3.1937.99.61.3.8.40.0">
                            <concept id="2.16.840.1.113883.3.1937.99.61.3.8.40.1">
                                <name language="en-US">male</name>
                            </concept>
                            <concept id="2.16.840.1.113883.3.1937.99.61.3.8.40.2">
                                <name language="en-US">female</name>
                            </concept>
                        </conceptList>
                    </valueDomain>
                </concept>
            </concept>
            <concept id="2.16.840.1.113883.3.1937.99.61.3.2.2" type="group" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
                <name language="en-US">Performing physician</name>
                <desc language="en-US">Performing physician</desc>
                <concept id="2.16.840.1.113883.3.1937.99.61.3.2.60" type="item" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
                    <name language="en-US">Name</name>
                    <desc language="en-US">Name of the physician</desc>
                    <valueDomain type="complex"/>
                </concept>
            </concept>
            <concept id="2.16.840.1.113883.3.1937.99.61.3.2.3" type="group" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
                <name language="en-US">EKG result</name>
                <desc language="en-US">EKG result (impression)</desc>
                <concept id="2.16.840.1.113883.3.1937.99.61.3.2.80" type="item" statusCode="draft" effectiveDate="2013-02-10T00:00:00">
                    <name language="en-US">EKG impression</name>
                    <desc language="en-US">EKG impression ( summary of the result of the electrocardiography)</desc>
                    <valueDomain type="text"/>
                </concept>
            </concept>
        </dataset>
    </datasets>
    <scenarios>
        <actors>
            <actor id="2.16.840.1.113883.3.1937.99.61.3.7.1" type="person">
                <name language="en-US">Physician performing the EKG</name>
            </actor>
        </actors>
        <scenario id="2.16.840.1.113883.3.1937.99.61.3.3.1" effectiveDate="2013-02-10T00:00:00" statusCode="draft">
            <name language="en-US">Electrocardiogram</name>
            <desc language="en-US">Electrocardiography is a commonly used, noninvasive procedure for recording electrical changes in the heart. The record, which is called an electrocardiogram (ECG or EKG), shows the series of waves that relate to the electrical impulses that occur during each beat of the heart. The results are printed on paper and/or displayed on a monitor to provide a visual
                representation of heart function. The waves in a normal record are named P, Q, R, S, and T, and follow in alphabetical order. The number of waves may vary, and other waves may be present. (Citation from: http://www.surgeryencyclopedia.com/Ce-Fi/Electrocardiography.htm) <p/> This example uses a real electrocardiography result report as the background story.</desc>
            <transaction id="2.16.840.1.113883.3.1937.99.61.3.4.1" type="group" effectiveDate="2013-02-10T00:00:00" statusCode="draft">
                <name language="en-US">Electrocardiogram Report</name>
                <desc language="en-US">A patient has ondergone a electrocardiogram and the results are reported.</desc>
                <transaction id="2.16.840.1.113883.3.1937.99.61.3.4.2" type="stationary" label="minicda" model="POCD_MT000040NL" effectiveDate="2013-02-10T00:00:00" statusCode="draft">
                    <name language="en-US">Electrocardiogram Report</name>
                    <desc language="en-US">A patient has ondergone a electrocardiogram and the results are reported.</desc>
                    <actors>
                        <actor id="2.16.840.1.113883.3.1937.99.61.3.7.1" role="sender"/>
                    </actors>
                    <representingTemplate ref="2.16.840.1.113883.3.1937.99.61.3.10.1" flexibility="2013-02-10T00:00:00" sourceDataset="2.16.840.1.113883.3.1937.99.61.3.1.1">
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.1" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true"/>
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.10" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true"/>
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.20" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true"/>
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.30" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R"/>
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.40" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R"/>
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.2" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true"/>
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.60" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true"/>
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.3" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true"/>
                        <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.80" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true"/>
                    </representingTemplate>
                </transaction>
            </transaction>
        </scenario>
    </scenarios>
    <ids><!-- baseIds -->
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.1" type="DS" prefix="sandbox-dataset-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.2" type="DE" prefix="sandbox-dataelement-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.3" type="SC" prefix="sandbox-scenario-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.4" type="TR" prefix="sandbox-transaction-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.5" type="CS" prefix="sandbox-codesystem-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.6" type="IS" prefix="sandbox-issue-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.7" type="AC" prefix="sandbox-actor-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.8" type="CL" prefix="sandbox-conceptlist-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.9" type="EL" prefix="sandbox-element-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.10" type="TM" prefix="sandbox-template-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.11" type="VS" prefix="sandbox-valueset-"/><!-- following base ids are not used in this example sandbox -->
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.16" type="RL" prefix="sandbox-rule-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.17" type="TX" prefix="sandbox-test-data-element-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.18" type="SX" prefix="sandbox-test-scenario-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.19" type="EX" prefix="sandbox-example-instance-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.20" type="QX" prefix="sandbox-test-requirement-"/>
        <baseId id="2.16.840.1.113883.3.1937.99.61.3.21" type="CM" prefix="sandbox-community-"/><!-- default baseIds -->
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.1" type="DS"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.2" type="DE"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.3" type="SC"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.4" type="TR"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.5" type="CS"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.6" type="IS"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.7" type="AC"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.8" type="CL"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.9" type="EL"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.10" type="TM"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.11" type="VS"/><!-- following default base ids are not used in this example sandbox -->
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.16" type="RL"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.17" type="TX"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.18" type="SX"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.19" type="EX"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.20" type="QX"/>
        <defaultBaseId id="2.16.840.1.113883.3.1937.99.61.3.21" type="CM"/>
        <id root="2.16.840.1.113883.2.4.6.3">
            <designation language="en-US" type="preferred" displayName="Dutch National Citizen Identifier BSN">This is an example of a National Citizen Identifier used in health care. It is the real Dutch "Burgerservicenummer", the Citizen Service Numnber. </designation>
        </id>
        <id root="2.16.840.1.113883.6.1">
            <designation language="en-US" type="preferred" displayName="LOINC">LOINC</designation>
        </id>
        <id root="2.16.840.1.113883.6.96">
            <designation language="en-US" type="preferred" displayName="Snomed-CT">Snomed-CT</designation>
        </id>
    </ids>
    <terminology>
        <terminologyAssociation conceptId="2.16.840.1.113883.3.1937.99.61.3.8.40.0" valueSet="AdministrativeGender"/>
        <terminologyAssociation conceptId="2.16.840.1.113883.3.1937.99.61.3.8.40.1" code="M" codeSystem="2.16.840.1.113883.5.1"/>
        <terminologyAssociation conceptId="2.16.840.1.113883.3.1937.99.61.3.8.40.2" code="F" codeSystem="2.16.840.1.113883.5.1"/>
        <codeSystem ref="2.16.840.1.113883.5.1" name="AdministrativeGender" displayName="AdministrativeGender"/>
        <codeSystem ref="2.16.840.1.113883.5.25" name="BasicConfidentialityKind" displayName="BasicConfidentialityKind"/>
        <codeSystem ref="2.16.840.1.113883.6.1" name="LOINC" displayName="LOINC"/>
        <valueSet id="2.16.840.1.113883.1.11.1" name="AdministrativeGender" displayName="AdministrativeGender (HL7)" effectiveDate="2012-07-24T00:00:00" statusCode="final">
            <desc language="en-US">The gender of a person used for adminstrative purposes (as opposed to clinical gender)</desc>
            <conceptList>
                <concept code="F" codeSystem="2.16.840.1.113883.5.1" displayName="Female" level="0" type="L"/>
                <concept code="M" codeSystem="2.16.840.1.113883.5.1" displayName="Male" level="0" type="L"/>
                <concept code="UN" codeSystem="2.16.840.1.113883.5.1" displayName="Undifferentiated" level="0" type="L"/>
            </conceptList>
        </valueSet>
        <valueSet id="2.16.840.1.113883.1.11.16926" name="BasicConfidentialityKind" displayName="Basic Confidentiality Kind (HL7)" effectiveDate="2005-09-01T00:00:00" statusCode="final">
            <conceptList>
                <concept code="N" codeSystem="2.16.840.1.113883.5.25" displayName="Normal" level="0" type="L"/>
                <concept code="R" codeSystem="2.16.840.1.113883.5.25" displayName="Restricted" level="0" type="L"/>
                <concept code="V" codeSystem="2.16.840.1.113883.5.25" displayName="Very restricted" level="0" type="L"/>
            </conceptList>
        </valueSet>
    </terminology>
    <rules>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.1" name="MinimalCDAdocument" displayName="Minimal CDA document" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <desc language="en-US">A minimal CDA Release 2 document, that contains only a few attributes and relationships for the ClinicalDocument class: <ul>
                    <li>typeId: fixed</li>
                    <li>id: unique id of the document instance</li>
                    <li>code: type of document</li>
                    <li>effectiveTime: creation date of the document</li>
                    <li>confidentialityCode: confidentiality level indication for this document</li>
                    <li>recordTarget: the record target (e.g. patient)</li>
                    <li>author: author of this document</li>
                    <li>custodian: custodian for this document</li>
                    <li>component: contains (in this case) structured body</li>
                </ul>
            </desc>
            <classification type="cdadocumentlevel"/>
            <relationship type="SPEC" template="2.16.840.1.113883.10.12.1" flexibility="2005-09-07T00:00:00"/>
            <context path="/"/>
            <example>
                <ClinicalDocument xmlns="urn:hl7-org:v3"><!-- CDA Header -->
                    <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
                    <templateId root="2.16.840.1.113883.3.1937.99.61.3.10.1"/>
                    <id extension="123456789" root="2.16.840.1.113883.3.1937.99.3.2.997788.1"/>
                    <code code="11524-6" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="EKG study report"/>
                    <effectiveTime value="20131020122709"/>
                    <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25"/>
                    <recordTarget><!-- .. --></recordTarget>
                    <author><!-- .. --></author>
                    <custodian><!-- .. --></custodian><!-- CDA Body -->
                    <component>
                        <structuredBody>
                            <component><!-- .. --></component>
                        </structuredBody>
                    </component>
                </ClinicalDocument>
            </example>
            <element name="hl7:ClinicalDocument">
                <include ref="CDAtypeId"/>
                <element name="hl7:templateId" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="II">
                    <desc language="en-US">CDA document template id for this kind of document</desc>
                    <example>
                        <templateId root="2.16.840.1.113883.3.1937.99.61.3.10.1"/>
                    </example>
                    <attribute root="2.16.840.1.113883.3.1937.99.61.3.10.1"/>
                </element>
                <include ref="CDAid"/>
                <element name="hl7:code" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="CE">
                    <example><!-- document type -->
                        <code code="11524-6" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="EKG study report"/>
                    </example>
                    <vocabulary code="11524-6" codeSystem="2.16.840.1.113883.6.1"/>
                </element>
                <include ref="CDAtitle" minimumMultiplicity="0" maximumMultiplicity="1">
                    <example>
                        <title>EKG Report as of 1 February 2013</title>
                    </example>
                </include>
                <include ref="CDAeffectiveTime"/>
                <include ref="CDAconfidentialityCode"/>
                <include ref="CDArecordTarget"/>
                <include ref="CDAauthor"/>
                <include ref="CDAcustodian"/>
                <element name="hl7:component">
                    <example><!-- now for the study results: CDA body -->
                        <component typeCode="COMP" contextConductionInd="true"><!-- ... --></component>
                    </example>
                    <attribute typeCode="COMP" contextConductionInd="true" isOptional="true"/>
                    <element name="hl7:structuredBody">
                        <example>
                            <structuredBody classCode="DOCBODY" moodCode="EVN"><!-- ... --></structuredBody>
                        </example>
                        <attribute classCode="DOCBODY" moodCode="EVN" isOptional="true"/><!-- EKG Impression section, reuqired (otherwise this report is useless) -->
                        <element name="hl7:component" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" contains="EKGImpressionSection">
                            <attribute typeCode="COMP" contextConductionInd="true" isOptional="true"/>
                        </element>
                    </element>
                </element>
            </element>
        </template>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.900001" name="CDAtypeId" displayName="CDA typeId" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <desc language="en-US">The clinical document <tt>typeId</tt> identifies the constraints imposed by CDA R2 on the content, essentially acting as a version identifier. <p/> The <tt>@root</tt> and <tt>@extension</tt> values of this element are specified as shown in the <i>example</i> below. </desc>
            <classification type="cdaheaderlevel"/>
            <item label="CDAtypeId"/>
            <example>
                <typeId extension="POCD_HD000040" root="2.16.840.1.113883.1.3"/>
            </example>
            <element name="hl7:typeId" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="II">
                <attribute extension="POCD_HD000040" root="2.16.840.1.113883.1.3"/>
            </element>
        </template>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.900002" name="CDAid" displayName="CDA id" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <desc language="en-US">The clinical document <tt>id</tt> element is an instance identifier data type. The <tt>@root</tt> attribute is typically an OID. 
                The <tt>@root</tt> uniquely identifies the scope of the <tt>@extension</tt>. The <tt>@root</tt> and <tt>@extension</tt> attributes uniquely identify the document.</desc>
            <classification type="cdaheaderlevel"/>
            <example>
                <id extension="1293878605987" root="2.16.528.1.1007.3.2.1111.21.1"/>
            </example>
            <example>
                <id extension="j86574633" root="2.16.840.1.113883.2.4.6.6.99.23444.17"/>
            </example>
            <element name="hl7:id" datatype="II" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true"/>
        </template>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.900003" name="CDAtitle" displayName="CDA title" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <classification type="cdaheaderlevel"/>
            <element name="hl7:title" datatype="ST" minimumMultiplicity="0" maximumMultiplicity="1"/>
        </template>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.900004" name="CDAeffectiveTime" displayName="CDA effectiveTime" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <desc language="en-US">Date report was created, precise to the second</desc>
            <classification type="cdaheaderlevel"/>
            <example>
                <effectiveTime value="20120611083422"/>
            </example>
            <element name="hl7:effectiveTime" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="TS.DATETIME.MIN" id="2.16.840.1.113883.3.1937.99.61.3.9.900004.1"/>
        </template>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.900005" name="CDAconfidentialityCode" displayName="CDA confidentialityCode" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <classification type="cdaheaderlevel"/>
            <example>
                <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25"/>
            </example>
            <element name="hl7:confidentialityCode" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="CE">
                <vocabulary valueSet="BasicConfidentialityKind"/>
            </element>
        </template>
        <templateAssociation templateId="2.16.840.1.113883.3.1937.99.61.3.10.2001" effectiveDate="2013-02-10T00:00:00">
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.1" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.2001.1"/>
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.10" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.2001.2"/>
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.30" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.2001.4"/>
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.40" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.2001.5"/>
        </templateAssociation>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.2001" name="CDArecordTarget" displayName="CDA recordTarget" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <desc language="en-US">The patient / client</desc>
            <classification type="cdaheaderlevel"/>
            <relationship type="SPEC" template="2.16.840.1.113883.10.12.101" flexibility="2005-09-07T00:00:00"/>
            <example>
                <recordTarget>
                    <patientRole>
                        <id root="2.16.840.1.113883.2.4.6.3" extension="100202020"/>
                        <patient>
                            <name>
                                <given>John</given>
                                <family>Doedidoe</family>
                            </name>
                            <administrativeGenderCode code="M" codeSystem="2.16.840.1.113883.5.1"/>
                            <birthTime value="19620219"/>
                        </patient>
                    </patientRole>
                </recordTarget>
            </example>
            <element name="hl7:recordTarget" id="2.16.840.1.113883.3.1937.99.61.3.9.2001.1">
                <attribute typeCode="RCT" contextControlCode="OP" isOptional="true"/>
                <element name="hl7:patientRole" minimumMultiplicity="1" maximumMultiplicity="1">
                    <attribute classCode="PAT" isOptional="true"/><!-- Element id, here: the national patient identifier -->
                    <include ref="NationalPatientIdentifier" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R"/><!-- Element patient -->
                    <element name="hl7:patient" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R">
                        <example>
                            <patient classCode="PSN" determinerCode="INSTANCE">
                                <name><!-- ... --></name>
                                <administrativeGenderCode code="M" codeSystem="2.16.840.1.113883.5.1"/>
                                <birthTime value="19620219"/>
                            </patient>
                        </example>
                        <attribute classCode="PSN" isOptional="true"/>
                        <attribute determinerCode="INSTANCE" isOptional="true"/><!-- Element name -->
                        <element name="hl7:name" minimumMultiplicity="1" maximumMultiplicity="*" conformance="R" datatype="PN" id="2.16.840.1.113883.3.1937.99.61.3.9.2001.2"/><!-- Element administrativeGenderCode -->
                        <element name="hl7:administrativeGenderCode" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R" datatype="CE" id="2.16.840.1.113883.3.1937.99.61.3.9.2001.5">
                            <vocabulary valueSet="AdministrativeGender"/>
                        </element><!-- Element birthTime -->
                        <element name="hl7:birthTime" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R" datatype="TS" id="2.16.840.1.113883.3.1937.99.61.3.9.2001.4"/>
                    </element>
                </element>
            </element>
        </template>
        <templateAssociation templateId="2.16.840.1.113883.3.1937.99.61.3.10.2002" effectiveDate="2013-02-10T00:00:00">
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.2" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.2002.1"/>
        </templateAssociation>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.2002" name="CDAauthor" displayName="CDA author" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <desc language="en-US">Author of the document</desc>
            <classification type="cdaheaderlevel"/>
            <relationship type="SPEC" template="2.16.840.1.113883.10.12.102" flexibility="2005-09-07T00:00:00"/>
            <example>
                <author>
                    <time value="20131020"/>
                    <assignedAuthor>
                        <id extension="HCP89567" root="2.16.840.1.113883.3.1937.99.3.1.997788"/>
                        <assignedPerson>
                            <name>
                                <given>Kai</given>
                                <family>Heitmann</family>
                            </name>
                        </assignedPerson>
                        <representedOrganization>
                            <name>The World's Best EKG Service Delivery Location</name>
                        </representedOrganization>
                    </assignedAuthor>
                </author>
            </example>
            <element name="hl7:author" minimumMultiplicity="1" maximumMultiplicity="*" isMandatory="true" id="2.16.840.1.113883.3.1937.99.61.3.9.2002.1">
                <attribute typeCode="AUT" isOptional="true"/><!-- Element time -->
                <element name="hl7:time" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="TS.DATE.MIN"/><!-- Element assignedAuthor -->
                <element name="hl7:assignedAuthor" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true">
                    <attribute classCode="ASSIGNED" isOptional="true"/>
                    <element name="hl7:id" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R" datatype="II"/>
                    <element name="hl7:assignedPerson" minimumMultiplicity="0" maximumMultiplicity="1">
                        <include ref="CDAPersonElements" flexibility="2011-12-19T00:00:00"/>
                    </element>
                    <element name="hl7:representedOrganization" minimumMultiplicity="0" maximumMultiplicity="1">
                        <include ref="CDAOrganizationElements"/>
                    </element>
                </element>
            </element>
        </template>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.2003" name="CDAcustodian" displayName="CDA custodian" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <desc language="en-US">Custodian of the document</desc>
            <classification type="cdaheaderlevel"/>
            <relationship type="SPEC" template="2.16.840.1.113883.10.12.104" flexibility="2005-09-07T00:00:00"/>
            <example>
                <custodian>
                    <assignedCustodian>
                        <representedCustodianOrganization>
                            <id root="2.16.840.1.113883.3.1937.99.3.2.997788"/>
                            <name/>
                        </representedCustodianOrganization>
                    </assignedCustodian>
                </custodian>
            </example>
            <element name="hl7:custodian" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true">
                <attribute typeCode="CST" isOptional="true"/>
                <element name="hl7:assignedCustodian" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true">
                    <attribute classCode="ASSIGNED" isOptional="true"/>
                    <element name="hl7:representedCustodianOrganization" minimumMultiplicity="0" maximumMultiplicity="1">
                        <include ref="CDAOrganizationElements"/>
                    </element>
                </element>
            </element>
        </template>
        <templateAssociation templateId="2.16.840.1.113883.3.1937.99.61.3.10.900200" effectiveDate="2011-12-19T00:00:00">
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.60" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.900200.1"/>
        </templateAssociation>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.900200" name="CDAPersonElements" displayName="CDA Person Elements" effectiveDate="2011-12-19T00:00:00" statusCode="active">
            <desc language="en-US">This is the first version of this template</desc>
            <classification type="cdaheaderlevel"/>
            <relationship type="SPEC" template="2.16.840.1.113883.10.12.152" flexibility="2005-09-07T00:00:00"/>
            <attribute classCode="PSN" isOptional="true"/>
            <attribute determinerCode="INSTANCE" isOptional="true"/>
            <element name="hl7:name" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="PN" id="2.16.840.1.113883.3.1937.99.61.3.9.900200.1"/>
        </template>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.900201" name="CDAOrganizationElements" displayName="CDA Organization Elements" effectiveDate="2011-12-19T00:00:00" statusCode="active">
            <desc language="en-US">This is a template with multiple elements on top level (use for inclusion)</desc>
            <classification type="cdaheaderlevel"/>
            <relationship type="SPEC" template="2.16.840.1.113883.10.12.151" flexibility="2005-09-07T00:00:00"/>
            <attribute classCode="ORG" isOptional="true"/>
            <attribute determinerCode="INSTANCE" isOptional="true"/><!-- Element id -->
            <element name="hl7:id" minimumMultiplicity="0" maximumMultiplicity="*" datatype="II"/><!-- Element name -->
            <element name="hl7:name" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="ON"/><!-- Element telecom -->
            <element name="hl7:telecom" minimumMultiplicity="0" maximumMultiplicity="*" datatype="TEL"/><!-- Element addr -->
            <element name="hl7:addr" minimumMultiplicity="0" maximumMultiplicity="1" datatype="AD"/>
        </template>
        <templateAssociation templateId="2.16.840.1.113883.3.1937.99.61.3.10.3001" effectiveDate="2013-02-10T00:00:00">
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.3" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.3001.1"/>
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.80" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.3001.2"/>
        </templateAssociation>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.3001" name="EKGImpressionSection" displayName="EKG impression" effectiveDate="2013-02-10T00:00:00" statusCode="active">
            <classification type="cdasectionlevel"/>
            <relationship type="SPEC" template="2.16.840.1.113883.10.12.201" flexibility="2005-09-07T00:00:00"/>
            <context id="**"/>
            <example>
                <section classCode="DOCSECT"><!-- template id for EKG measurements -->
                    <templateId root="2.16.840.1.113883.3.1937.99.61.3.10.3001"/><!-- section code -->
                    <code code="18844-1" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC"/>
                    <title>Impression</title>
                    <text>Normal sinus rhythm<br/> Ischemic ST-T changes in anterior leads<br/> Poor R Progression in right precordial leads</text>
                </section>
            </example>
            <element name="hl7:section" id="2.16.840.1.113883.3.1937.99.61.3.9.3001.1">
                <attribute classCode="DOCSECT" isOptional="true"/><!-- Element templateId -->
                <element name="hl7:templateId" minimumMultiplicity="1" maximumMultiplicity="1" datatype="II">
                    <attribute root="2.16.840.1.113883.3.1937.99.61.3.10.3001"/>
                </element><!-- Element code -->
                <element name="hl7:code" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="CD">
                    <vocabulary code="18844-1" codeSystem="2.16.840.1.113883.6.1"/>
                </element><!-- Element title -->
                <element name="hl7:title" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="ST"/><!-- Element text -->
                <element name="hl7:text" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="SD.TEXT" id="2.16.840.1.113883.3.1937.99.61.3.9.3001.2"/>
            </element>
        </template><!-- NationalPatientIdentifier -->
        <templateAssociation templateId="2.16.840.1.113883.3.1937.99.61.3.10.110" effectiveDate="2013-01-31T00:00:00">
            <concept ref="2.16.840.1.113883.3.1937.99.61.3.2.20" effectiveDate="2013-02-10T00:00:00" elementId="2.16.840.1.113883.3.1937.99.61.3.9.110.1"/>
        </templateAssociation>
        <template id="2.16.840.1.113883.3.1937.99.61.3.10.110" name="NationalPatientIdentifier" displayName="National Patient Identifier" effectiveDate="2013-01-31T00:00:00" statusCode="active">
            <desc language="en-US">National Patient Identifier: this is an example of a National Citizen Identifier used in health care. It is the real Dutch "Burgerservicenummer", the Citizen Service Numnber. The Burgerservicenummer (BSN) is a unique personal number issued to everyone registered in the 'Gemeentelijke Basisadministratie persoonsgegevens' (GBA), or the Personal Records Database of the municipality. The BSN
                was formerly known as the Social-Fiscal (So-Fi) number. <p/> (Citation: http://www.denhaag.nl/en/residents/to/Burgerservicenummer-BSN.htm) <p/>
                It has the following format: 9N, with preceding zeros if shorter than 9 characters. </desc>
            <example><!-- BSN -->
                <id root="2.16.840.1.113883.2.4.6.3" extension="100202020"/>
            </example>
            <element name="hl7:id" datatype="II.NL.BSN" id="2.16.840.1.113883.3.1937.99.61.3.9.110.1">
                <attribute root="2.16.840.1.113883.2.4.6.3"/>
                <attribute name="extension">
                    <desc language="en-US">Burgerservicenummer (National Patient Identifier)</desc>
                </attribute>
            </element>
        </template>
    </rules>
</decor>


(: get login credentials :)
let $theactingnotifierusername := if (request:exists()) then request:get-parameter('user', '') else ''
let $theactingnotifierpassword := if (request:exists()) then request:get-parameter('password', '') else ''


(: update if not empty and action parameter is set to the secret word :)
return
    if ($secret='61fgs756.s9' and (xmldb:login('/db', $theactingnotifierusername, $theactingnotifierpassword)) and not(empty($sandboxorig))) then
        <refresh-sandbox status="ATTEMPT">
        {
            let $updatedel := 
                if ($action='--periodic-sandbox-refresh' and not(empty($sandbox)) )
                then (update delete $sandbox/*)
                else ()
            let $update := 
                if (not(empty($sandbox)) )
                then (update insert $sandboxorig/node() into $sandbox) 
                else ()
            return
                if (empty($sandbox)) then 'NOSANDBOX'
                else if (count($sandbox)=1) then 'OK' 
                else 'FAILED'
        }
        </refresh-sandbox>
    else 
        <refresh-sandbox status="NOTAUTHENTICATED"/>
