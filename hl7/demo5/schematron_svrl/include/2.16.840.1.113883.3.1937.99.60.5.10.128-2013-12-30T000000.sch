<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Name: Blood pressure
Description: Blood pressure
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000">
   <title>Blood pressure</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]
Item: (BloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]"
         id="tmp-r-cf259aee-ac72-47b4-931e-cb0b6fea6c09">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']])&gt;=1 ">(BloodPressure): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']])&lt;=1">(BloodPressure): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]
Item: (BloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]"
         id="tmp-r-296ecb9f-647a-482f-893b-39ce6302b7d1">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@classCode)='OBS'">(BloodPressure): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@moodCode)='EVN'">(BloodPressure): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128'])&gt;=1 ">(BloodPressure): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128'])&lt;=1">(BloodPressure): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:id)&gt;=1 ">(BloodPressure): element hl7:id is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:id)&lt;=1">(BloodPressure): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:code[(@code='35094-2' and @codeSystem='2.16.840.1.113883.6.1')])&gt;=1 and not(hl7:code[(@code='35094-2' and @codeSystem='2.16.840.1.113883.6.1')]/@nullFlavor)">(BloodPressure): element hl7:code[(@code='35094-2' and @codeSystem='2.16.840.1.113883.6.1')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:code[(@code='35094-2' and @codeSystem='2.16.840.1.113883.6.1')])&lt;=1">(BloodPressure): element hl7:code[(@code='35094-2' and @codeSystem='2.16.840.1.113883.6.1')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:text)&lt;=1">(BloodPressure): element hl7:text appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:statusCode[@code='completed'])&gt;=1 and not(hl7:statusCode[@code='completed']/@nullFlavor)">(BloodPressure): element hl7:statusCode[@code='completed'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:statusCode[@code='completed'])&lt;=1">(BloodPressure): element hl7:statusCode[@code='completed'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:effectiveTime)&lt;=1">(BloodPressure): element hl7:effectiveTime appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:value)=0">(BloodPressure): element hl7:value MAY NOT be present.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:methodCode)&lt;=1">(BloodPressure): element hl7:methodCode appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]])&lt;=1">(BloodPressure): element hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]])&lt;=1">(BloodPressure): element hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="count(hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.131']]])&lt;=1">(BloodPressure): element hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.131']]] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']
Item: (BloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']"
         id="tmp-r-df108070-0a9a-4d8a-82fb-194ec1f1e9b5">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.128'">(BloodPressure): @root SHALL have value '2.16.840.1.113883.3.1937.99.60.5.10.128'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:id
Item: (BloodPressure)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:code[(@code='35094-2' and @codeSystem='2.16.840.1.113883.6.1')]
Item: (BloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:code[(@code='35094-2' and @codeSystem='2.16.840.1.113883.6.1')]"
         id="tmp-r-cfa5d944-cac5-4c4a-bedb-313a8f881329">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="@nullFlavor or (@code='35094-2' and @codeSystem='2.16.840.1.113883.6.1')">(BloodPressure): The element value SHALL be code '35094-2' codeSystem '2.16.840.1.113883.6.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:text
Item: (BloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:text"
         id="tmp-r-fb3d2291-fdb8-4254-81f2-cb24ee356a4f">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ED' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ED", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ED"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:statusCode[@code='completed']
Item: (BloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:statusCode[@code='completed']"
         id="tmp-r-0d76484e-5e87-4d48-af76-60702c074aa4">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CS"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="@nullFlavor or (@code='completed')">(BloodPressure): The element value SHALL be code 'completed'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:effectiveTime
Item: (BloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:effectiveTime"
         id="tmp-r-e695f7a7-ddf7-49e0-a14f-4643963f87b6">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:value
Item: (BloodPressure)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:methodCode
Item: (BloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:methodCode"
         id="tmp-r-82d01614-968e-4115-a339-67a56d4d7345">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.1.11.14079-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(BloodPressure): The element value SHALL be ObservationMethod (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.1.11.14079-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(BloodPressure): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set ObservationMethod (DYNAMIC).</assert>
   </rule>

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]]
Item: (BloodPressure)
-->
   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]]">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@typeCode)='COMP'">(BloodPressure): The value for @typeCode SHALL be 'COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@inversionInd)='false'">(BloodPressure): The value for @inversionInd SHALL be 'false'.</assert>
   </rule>

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]]
Item: (BloodPressure)
-->
   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]]">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@typeCode)='COMP'">(BloodPressure): The value for @typeCode SHALL be 'COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@inversionInd)='false'">(BloodPressure): The value for @inversionInd SHALL be 'false'.</assert>
   </rule>

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.128
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.131']]]
Item: (BloodPressure)
-->
   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.128']]/hl7:entryRelationship[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.131']]]">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@typeCode)='COMP'">(BloodPressure): The value for @typeCode SHALL be 'COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.html"
              test="string(@inversionInd)='false'">(BloodPressure): The value for @inversionInd SHALL be 'false'.</assert>
   </rule>
</pattern>
