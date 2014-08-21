<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Name: Diastolic blood pressure
Description: Diastolische bloeddruk
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000">
   <title>Diastolic blood pressure</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]"
         id="tmp-r-77070720-9c71-430a-aac8-2fff71fc3f00">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']])&gt;=1 ">(DiastolicBloodPressure): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']])&lt;=1">(DiastolicBloodPressure): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]"
         id="tmp-r-c259d50a-ce18-46f3-887f-9acb129bd974">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="string(@classCode)='OBS'">(DiastolicBloodPressure): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="string(@moodCode)='EVN'">(DiastolicBloodPressure): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130'])&gt;=1 ">(DiastolicBloodPressure): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130'])&lt;=1">(DiastolicBloodPressure): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:id)&gt;=1 ">(DiastolicBloodPressure): element hl7:id is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:id)&lt;=1">(DiastolicBloodPressure): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:code[(@code='8462-4' and @codeSystem='2.16.840.1.113883.6.1')])&gt;=1 and not(hl7:code[(@code='8462-4' and @codeSystem='2.16.840.1.113883.6.1')]/@nullFlavor)">(DiastolicBloodPressure): element hl7:code[(@code='8462-4' and @codeSystem='2.16.840.1.113883.6.1')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:code[(@code='8462-4' and @codeSystem='2.16.840.1.113883.6.1')])&lt;=1">(DiastolicBloodPressure): element hl7:code[(@code='8462-4' and @codeSystem='2.16.840.1.113883.6.1')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:text)&lt;=1">(DiastolicBloodPressure): element hl7:text appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:statusCode[@code='completed'])&gt;=1 and not(hl7:statusCode[@code='completed']/@nullFlavor)">(DiastolicBloodPressure): element hl7:statusCode[@code='completed'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:statusCode[@code='completed'])&lt;=1">(DiastolicBloodPressure): element hl7:statusCode[@code='completed'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:effectiveTime)&lt;=1">(DiastolicBloodPressure): element hl7:effectiveTime appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:value)&gt;=1 ">(DiastolicBloodPressure): element hl7:value is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="count(hl7:value)&lt;=1">(DiastolicBloodPressure): element hl7:value appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']"
         id="tmp-r-43dd2c11-b52a-4e3d-a02a-dd58fb799a7e">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(DiastolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.130'">(DiastolicBloodPressure): @root SHALL have value '2.16.840.1.113883.3.1937.99.60.5.10.130'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:id
Item: (DiastolicBloodPressure)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:code[(@code='8462-4' and @codeSystem='2.16.840.1.113883.6.1')]
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:code[(@code='8462-4' and @codeSystem='2.16.840.1.113883.6.1')]"
         id="tmp-r-81819078-3cca-4dd9-ab18-1a5dd9a7ef63">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(DiastolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="@nullFlavor or (@code='8462-4' and @codeSystem='2.16.840.1.113883.6.1')">(DiastolicBloodPressure): The element value SHALL be code '8462-4' codeSystem '2.16.840.1.113883.6.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:text
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:text"
         id="tmp-r-5f3391cb-15eb-45a6-9990-ebdc2b15e456">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ED' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(DiastolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ED", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ED"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:statusCode[@code='completed']
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:statusCode[@code='completed']"
         id="tmp-r-c8a9d76c-dee7-4cf1-ac28-4e008e742908">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(DiastolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CS"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="@nullFlavor or (@code='completed')">(DiastolicBloodPressure): The element value SHALL be code 'completed'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:effectiveTime
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:effectiveTime"
         id="tmp-r-208c4852-6083-4efa-a8b0-479b3e4b33f6">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(DiastolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:value
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:value"
         id="tmp-r-fa4ab808-98a3-4ea8-8916-ce9691db103e">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='PQ' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(DiastolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:PQ", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="PQ"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="(@nullFlavor or (@unit='mm[Hg]'))">(DiastolicBloodPressure): value SHALL use unit 'mm[Hg]' </assert>
      <let name="digitok"
           value="matches(string($theValue), '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="$digitok or @nullFlavor">(DiastolicBloodPressure): @value is not a valid PQ number <value-of select="$theValue"/>
      </assert>
      <let name="theUnit" value="@unit"/>
      <let name="UCUMtest"
           value="doc('include/voc-UCUM.xml')/*/ucum[@unit=$theUnit]/@message"/>
      <assert role="warning"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="$UCUMtest='OK' or string-length($UCUMtest)=0">(DiastolicBloodPressure): value/@unit (PQ) SHALL be a valid UCUM unit (<value-of select="$UCUMtest"/>).</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.130
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:interpretationCode
Item: (DiastolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.130']]/hl7:interpretationCode"
         id="tmp-r-565bcba7-0af6-4f15-93b0-2911db0ff360">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(DiastolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.1.11.78-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(DiastolicBloodPressure): The element value SHALL be ObservationInterpretation (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.1.11.78-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(DiastolicBloodPressure): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set ObservationInterpretation (DYNAMIC).</assert>
   </rule>
</pattern>
