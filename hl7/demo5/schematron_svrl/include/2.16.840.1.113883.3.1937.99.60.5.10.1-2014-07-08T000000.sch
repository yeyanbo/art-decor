<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.1
Name: Vital Signs Summary CDA document
Description: Een minimaal CDA Release 2 document die alleen een paar attributen en relaties voor een ClinicalDocument class bevat:  
                     typeId: vast 
                     id: uniek id van de document instantiatie 
                     code: type van het document 
                     effectiveTime: datum waarop document is gecreëerd 
                     confidentialityCode: indicatie van level van vertrouwen voor dit document 
                     recordTarget: onderwerp (bv. patient) 
                     author: auteur van dit document 
                     custodian: beheerder van dit document 
                     component: bevat (in dit geval) een gestructureerde inhoud 
                 
            
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000">
   <title>Vital Signs Summary CDA document</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.1
Context: /
Item: (VitalSignsCDAdocument)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.1
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]
Item: (VitalSignsCDAdocument)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]"
         id="tmp-r-ad961a1b-6962-4be2-958a-c103b55e088a">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:typeId[@root='2.16.840.1.113883.1.3'])&gt;=1 and not(hl7:typeId[@root='2.16.840.1.113883.1.3']/@nullFlavor)">(VitalSignsCDAdocument): element hl7:typeId[@root='2.16.840.1.113883.1.3'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:typeId[@root='2.16.840.1.113883.1.3'])&lt;=1">(VitalSignsCDAdocument): element hl7:typeId[@root='2.16.840.1.113883.1.3'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1'])&gt;=1 and not(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']/@nullFlavor)">(VitalSignsCDAdocument): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1'])&lt;=1">(VitalSignsCDAdocument): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:id)&gt;=1 and not(hl7:id/@nullFlavor)">(VitalSignsCDAdocument): element hl7:id is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:id)&lt;=1">(VitalSignsCDAdocument): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:code[(@code='51848-0' and @codeSystem='2.16.840.1.113883.6.1')])&gt;=1 and not(hl7:code[(@code='51848-0' and @codeSystem='2.16.840.1.113883.6.1')]/@nullFlavor)">(VitalSignsCDAdocument): element hl7:code[(@code='51848-0' and @codeSystem='2.16.840.1.113883.6.1')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:code[(@code='51848-0' and @codeSystem='2.16.840.1.113883.6.1')])&lt;=1">(VitalSignsCDAdocument): element hl7:code[(@code='51848-0' and @codeSystem='2.16.840.1.113883.6.1')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:title)&lt;=1">(VitalSignsCDAdocument): element hl7:title appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:effectiveTime)&gt;=1 and not(hl7:effectiveTime/@nullFlavor)">(VitalSignsCDAdocument): element hl7:effectiveTime is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:effectiveTime)&lt;=1">(VitalSignsCDAdocument): element hl7:effectiveTime appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:confidentialityCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)])&gt;=1 and not(hl7:confidentialityCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]/@nullFlavor)">(VitalSignsCDAdocument): element hl7:confidentialityCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:confidentialityCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)])&lt;=1">(VitalSignsCDAdocument): element hl7:confidentialityCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:author)&gt;=1 and not(hl7:author/@nullFlavor)">(VitalSignsCDAdocument): element hl7:author is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:custodian)&gt;=1 and not(hl7:custodian/@nullFlavor)">(VitalSignsCDAdocument): element hl7:custodian is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:custodian)&lt;=1">(VitalSignsCDAdocument): element hl7:custodian appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900001
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:typeId[@root='2.16.840.1.113883.1.3']
Item: (CDAtypeId)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:typeId[@root='2.16.840.1.113883.1.3']"
         id="tmp-r-ef8c3de8-3219-4a53-9312-b5f161a34078">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900001-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDAtypeId): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900001-2014-07-08T000000.html"
              test="string(@extension)='POCD_HD000040'">(CDAtypeId): The value for @extension SHALL be 'POCD_HD000040'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900001-2014-07-08T000000.html"
              test="string(@root)='2.16.840.1.113883.1.3'">(CDAtypeId): @root SHALL have value '2.16.840.1.113883.1.3'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.1
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']
Item: (VitalSignsCDAdocument)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']"
         id="tmp-r-cd6ff3fc-03a9-43a3-b5de-4f6844cdd124">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(VitalSignsCDAdocument): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.1'">(VitalSignsCDAdocument): @root SHALL have value '2.16.840.1.113883.3.1937.99.60.5.10.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900002
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:id
Item: (CDAid)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:id"
         id="tmp-r-5824d84a-a530-4aa8-acf1-bc564f31340d">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900002-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDAid): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.1
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:code[(@code='51848-0' and @codeSystem='2.16.840.1.113883.6.1')]
Item: (VitalSignsCDAdocument)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:code[(@code='51848-0' and @codeSystem='2.16.840.1.113883.6.1')]"
         id="tmp-r-bb081468-3057-48a2-a1b6-94bbc172f427">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(VitalSignsCDAdocument): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="@nullFlavor or (@code='51848-0' and @codeSystem='2.16.840.1.113883.6.1')">(VitalSignsCDAdocument): The element value SHALL be code '51848-0' codeSystem '2.16.840.1.113883.6.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900003
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:title
Item: (CDAtitle)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:title"
         id="tmp-r-5e36a78c-4c5b-4087-9d27-bef568830a9f">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900003-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ST' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDAtitle): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ST", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ST"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900004
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:effectiveTime
Item: (CDAeffectiveTime)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:effectiveTime"
         id="tmp-r-d066b270-f167-456f-913a-8d40b01ed291">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900004-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDAeffectiveTime): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS.DATETIME.MIN"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900005
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:confidentialityCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]
Item: (CDAconfidentialityCode)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:confidentialityCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]"
         id="tmp-r-cb45c5c7-344c-4320-8d3a-b62f05eed665">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900005-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDAconfidentialityCode): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900005-2014-07-08T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(CDAconfidentialityCode): The element value SHALL be BasicConfidentialityKind Basic Confidentiality Kind (HL7) (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.1.11.16926-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900005-2014-07-08T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(CDAconfidentialityCode): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set BasicConfidentialityKind Basic Confidentiality Kind (HL7) (DYNAMIC).</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2001
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget
Item: (CDArecordTarget)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget"
         id="tmp-r-1cc552e5-95f9-4266-a03d-66d367aedc35">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="string(@typeCode)='RCT' or not(@typeCode)">(CDArecordTarget): The value for @typeCode SHALL be 'RCT'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="string(@contextControlCode)='OP' or not(@contextControlCode)">(CDArecordTarget): The value for @contextControlCode SHALL be 'OP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:patientRole)&gt;=1 ">(CDArecordTarget): element hl7:patientRole is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:patientRole)&lt;=1">(CDArecordTarget): element hl7:patientRole appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2001
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole
Item: (CDArecordTarget)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole"
         id="tmp-r-c15296fb-e429-4573-b1c8-3aab4e200892">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="string(@classCode)='PAT' or not(@classCode)">(CDArecordTarget): The value for @classCode SHALL be 'PAT'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:id[@root='2.16.840.1.113883.2.4.6.3'])&gt;=1 ">(CDArecordTarget): element hl7:id[@root='2.16.840.1.113883.2.4.6.3'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:id[@root='2.16.840.1.113883.2.4.6.3'])&lt;=1">(CDArecordTarget): element hl7:id[@root='2.16.840.1.113883.2.4.6.3'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:patient)&gt;=1 ">(CDArecordTarget): element hl7:patient is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:patient)&lt;=1">(CDArecordTarget): element hl7:patient appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900207
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:id[@root='2.16.840.1.113883.2.4.6.3']
Item: (NationalPatientIdentifier)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:id[@root='2.16.840.1.113883.2.4.6.3']"
         id="tmp-r-30909562-80cb-470c-acc6-4e408e0ddd57">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900207-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(NationalPatientIdentifier): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II.NL.BSN"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900207-2014-07-08T000000.html"
              test="string(@root)='2.16.840.1.113883.2.4.6.3'">(NationalPatientIdentifier): @root SHALL have value '2.16.840.1.113883.2.4.6.3'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2001
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:patient
Item: (CDArecordTarget)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:patient"
         id="tmp-r-7f72fb74-0e36-4d53-b2df-4f8999400118">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="string(@classCode)='PSN' or not(@classCode)">(CDArecordTarget): The value for @classCode SHALL be 'PSN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="string(@determinerCode)='INSTANCE' or not(@determinerCode)">(CDArecordTarget): The value for @determinerCode SHALL be 'INSTANCE'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:name)&gt;=1 ">(CDArecordTarget): element hl7:name is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:administrativeGenderCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor])&gt;=1 ">(CDArecordTarget): element hl7:administrativeGenderCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:administrativeGenderCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor])&lt;=1">(CDArecordTarget): element hl7:administrativeGenderCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:birthTime)&gt;=1 ">(CDArecordTarget): element hl7:birthTime is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="count(hl7:birthTime)&lt;=1">(CDArecordTarget): element hl7:birthTime appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2001
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name
Item: (CDArecordTarget)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name"
         id="tmp-r-ae4548e1-c613-4580-a57b-13c7b23f4e98">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='PN' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDArecordTarget): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:PN", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="PN"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2001
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:administrativeGenderCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor]
Item: (CDArecordTarget)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:administrativeGenderCode[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor]"
         id="tmp-r-29fa6519-10ac-4ddf-a76b-ca004e8143a9">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDArecordTarget): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(CDArecordTarget): The element value SHALL be AdministrativeGender (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.1.11.1-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(CDArecordTarget): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set AdministrativeGender (DYNAMIC).</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2001
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:birthTime
Item: (CDArecordTarget)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:birthTime"
         id="tmp-r-af0959da-c1ea-4077-8978-d4b61f3aa123">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2001-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDArecordTarget): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2002
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author
Item: (CDAauthor)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author"
         id="tmp-r-f6634026-c5ff-43ea-920f-b77756e3ac95">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="string(@typeCode)='AUT' or not(@typeCode)">(CDAauthor): The value for @typeCode SHALL be 'AUT'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:time)&gt;=1 and not(hl7:time/@nullFlavor)">(CDAauthor): element hl7:time is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:time)&lt;=1">(CDAauthor): element hl7:time appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:assignedAuthor)&gt;=1 and not(hl7:assignedAuthor/@nullFlavor)">(CDAauthor): element hl7:assignedAuthor is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:assignedAuthor)&lt;=1">(CDAauthor): element hl7:assignedAuthor appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2002
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:time
Item: (CDAauthor)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:time"
         id="tmp-r-5a024ae8-4ab1-4a5c-b1b2-d689b8d79fb7">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDAauthor): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS.DATE.MIN"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2002
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor
Item: (CDAauthor)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor"
         id="tmp-r-2abea0ee-74cf-41f1-b164-9ce0ff1bbfa5">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="string(@classCode)='ASSIGNED' or not(@classCode)">(CDAauthor): The value for @classCode SHALL be 'ASSIGNED'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:id)&gt;=1 ">(CDAauthor): element hl7:id is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:id)&lt;=1">(CDAauthor): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:assignedPerson)&lt;=1">(CDAauthor): element hl7:assignedPerson appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:representedOrganization)&lt;=1">(CDAauthor): element hl7:representedOrganization appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2002
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:id
Item: (CDAauthor)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:id"
         id="tmp-r-54db6bef-e905-4938-a83a-4576822125cb">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(CDAauthor): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2002
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:assignedPerson
Item: (CDAauthor)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:assignedPerson"
         id="tmp-r-a2fd8848-c4eb-4ec8-8bfc-355263c91b32">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="string(@classCode)='PSN' or not(@classCode)">(CDAauthor): The value for @classCode SHALL be 'PSN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="string(@determinerCode)='INSTANCE' or not(@determinerCode)">(CDAauthor): The value for @determinerCode SHALL be 'INSTANCE'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:name)&gt;=1 and not(hl7:name/@nullFlavor)">(CDAauthor): element hl7:name is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:name)&lt;=1">(CDAauthor): element hl7:name appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900200
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:assignedPerson/hl7:name
Item: (PersonElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:assignedPerson/hl7:name"
         id="tmp-r-f4ea529b-f98b-4d2b-bdf7-e394dde3811a">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900200-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='PN' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(PersonElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:PN", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="PN"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900200-2014-07-08T000000.html"
              test="count(hl7:family)&gt;=1 and not(hl7:family/@nullFlavor)">(PersonElements): element hl7:family is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900200-2014-07-08T000000.html"
              test="count(hl7:family)&lt;=1">(PersonElements): element hl7:family appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900200-2014-07-08T000000.html"
              test="count(hl7:given)&gt;=1 and not(hl7:given/@nullFlavor)">(PersonElements): element hl7:given is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900200-2014-07-08T000000.html"
              test="count(hl7:given)&lt;=1">(PersonElements): element hl7:given appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900200
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:assignedPerson/hl7:name/hl7:family
Item: (PersonElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:assignedPerson/hl7:name/hl7:family"
         id="tmp-r-08ca2c52-b28f-4c90-a70d-e995b94dd3d0">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900200-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ST' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(PersonElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ST", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ST"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900200
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:assignedPerson/hl7:name/hl7:given
Item: (PersonElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:assignedPerson/hl7:name/hl7:given"
         id="tmp-r-41ff72a8-fef9-4877-a250-8c3355832752">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900200-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ST' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(PersonElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ST", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ST"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2002
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization
Item: (CDAauthor)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization"
         id="tmp-r-5ad5019e-55fa-4604-9e84-fe9e0179cb56">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="string(@classCode)='ORG' or not(@classCode)">(CDAauthor): The value for @classCode SHALL be 'ORG'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="string(@determinerCode)='INSTANCE' or not(@determinerCode)">(CDAauthor): The value for @determinerCode SHALL be 'INSTANCE'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:name)&gt;=1 and not(hl7:name/@nullFlavor)">(CDAauthor): element hl7:name is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:name)&lt;=1">(CDAauthor): element hl7:name appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2002-2014-07-08T000000.html"
              test="count(hl7:addr)&lt;=1">(CDAauthor): element hl7:addr appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900201
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization/hl7:id
Item: (OrganizationElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization/hl7:id"
         id="tmp-r-542e528e-d519-4efe-98ce-bd36e18e6e57">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900201-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OrganizationElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900201
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization/hl7:name
Item: (OrganizationElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization/hl7:name"
         id="tmp-r-dcf9560a-57b1-47e9-bdeb-b283ab8bbafe">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900201-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ON' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OrganizationElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ON", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ON"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900201
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization/hl7:telecom
Item: (OrganizationElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization/hl7:telecom"
         id="tmp-r-4b3db8f4-c3f6-41ce-99ba-dd669d4c4ac9">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900201-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TEL' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OrganizationElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TEL", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TEL"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900201
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization/hl7:addr
Item: (OrganizationElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:author/hl7:assignedAuthor/hl7:representedOrganization/hl7:addr"
         id="tmp-r-a64bb059-f59e-4f96-8e0b-fdf3c6e26306">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900201-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='AD' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OrganizationElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:AD", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="AD"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2003
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian
Item: (CDAcustodian)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian"
         id="tmp-r-bacd6cec-b221-4137-a18f-33a867053617">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="string(@typeCode)='CST' or not(@typeCode)">(CDAcustodian): The value for @typeCode SHALL be 'CST'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="count(hl7:assignedCustodian)&gt;=1 and not(hl7:assignedCustodian/@nullFlavor)">(CDAcustodian): element hl7:assignedCustodian is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="count(hl7:assignedCustodian)&lt;=1">(CDAcustodian): element hl7:assignedCustodian appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2003
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian
Item: (CDAcustodian)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian"
         id="tmp-r-6059af2b-a3ed-41e5-a2a7-f58400ece3ef">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="string(@classCode)='ASSIGNED' or not(@classCode)">(CDAcustodian): The value for @classCode SHALL be 'ASSIGNED'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="count(hl7:representedCustodianOrganization)&lt;=1">(CDAcustodian): element hl7:representedCustodianOrganization appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.2003
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization
Item: (CDAcustodian)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization"
         id="tmp-r-4391a39d-b211-4519-aafc-75d953190c6d">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="string(@classCode)='ORG' or not(@classCode)">(CDAcustodian): The value for @classCode SHALL be 'ORG'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="string(@determinerCode)='INSTANCE' or not(@determinerCode)">(CDAcustodian): The value for @determinerCode SHALL be 'INSTANCE'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="count(hl7:name)&gt;=1 and not(hl7:name/@nullFlavor)">(CDAcustodian): element hl7:name is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="count(hl7:name)&lt;=1">(CDAcustodian): element hl7:name appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.2003-2014-07-08T000000.html"
              test="count(hl7:addr)&lt;=1">(CDAcustodian): element hl7:addr appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900201
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:id
Item: (OrganizationElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:id"
         id="tmp-r-28bf44e0-7865-4f34-ba3c-b2613e650a56">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900201-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OrganizationElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900201
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:name
Item: (OrganizationElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:name"
         id="tmp-r-1c949525-18a9-4657-b839-aae17e7ae557">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900201-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ON' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OrganizationElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ON", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ON"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900201
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:telecom
Item: (OrganizationElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:telecom"
         id="tmp-r-a3009310-a409-4f77-a6dc-9747c73e89de">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900201-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TEL' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OrganizationElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TEL", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TEL"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.900201
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:addr
Item: (OrganizationElements)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:addr"
         id="tmp-r-5c24ecfa-12cd-4953-b497-cf5d984fa16c">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.900201-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='AD' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OrganizationElements): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:AD", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="AD"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.1
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:component
Item: (VitalSignsCDAdocument)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:component"
         id="tmp-r-5b57c965-91e2-4c70-87f2-214008a6a417">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="string(@typeCode)='COMP' or not(@typeCode)">(VitalSignsCDAdocument): The value for @typeCode SHALL be 'COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="string(@contextConductionInd)='true' or not(@contextConductionInd)">(VitalSignsCDAdocument): The value for @contextConductionInd SHALL be 'true'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.1
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:component/hl7:structuredBody
Item: (VitalSignsCDAdocument)
-->

   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:component/hl7:structuredBody"
         id="tmp-r-6ad679e7-384c-4a47-9efa-294d3f5c948e">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="string(@classCode)='DOCBODY' or not(@classCode)">(VitalSignsCDAdocument): The value for @classCode SHALL be 'DOCBODY'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="string(@moodCode)='EVN' or not(@moodCode)">(VitalSignsCDAdocument): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:component[hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]])&gt;=1 and not(hl7:component[hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]]/@nullFlavor)">(VitalSignsCDAdocument): element hl7:component[hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="count(hl7:component[hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]])&lt;=1">(VitalSignsCDAdocument): element hl7:component[hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]] appears to often [max 1x].</assert>
   </rule>

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.1
Context: /hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:component/hl7:structuredBody/hl7:component[hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]]
Item: (VitalSignsCDAdocument)
-->
   <rule context="/hl7:ClinicalDocument[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.1']]/hl7:component/hl7:structuredBody/hl7:component[hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]]">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="string(@typeCode)='COMP' or not(@typeCode)">(VitalSignsCDAdocument): The value for @typeCode SHALL be 'COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.html"
              test="string(@contextConductionInd)='true' or not(@contextConductionInd)">(VitalSignsCDAdocument): The value for @contextConductionInd SHALL be 'true'.</assert>
   </rule>
</pattern>
