<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Name: HeartRatePeripheral
Description: Pols
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000">
   <title>HeartRatePeripheral</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]"
         id="tmp-r-c8904f5b-bad3-4cde-8b71-a9948a03f67a">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']])&gt;=1 ">(HeartRatePeripheral): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']])&lt;=1">(HeartRatePeripheral): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]"
         id="tmp-r-8477e000-4653-4ac4-ad02-a99924b1cae9">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="string(@classCode)='OBS'">(HeartRatePeripheral): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="string(@moodCode)='EVN'">(HeartRatePeripheral): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125'])&gt;=1 ">(HeartRatePeripheral): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125'])&lt;=1">(HeartRatePeripheral): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:id)&gt;=1 ">(HeartRatePeripheral): element hl7:id is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:id)&lt;=1">(HeartRatePeripheral): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:code[(@code='8893-0' and @codeSystem='2.16.840.1.113883.6.1')])&gt;=1 and not(hl7:code[(@code='8893-0' and @codeSystem='2.16.840.1.113883.6.1')]/@nullFlavor)">(HeartRatePeripheral): element hl7:code[(@code='8893-0' and @codeSystem='2.16.840.1.113883.6.1')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:code[(@code='8893-0' and @codeSystem='2.16.840.1.113883.6.1')])&lt;=1">(HeartRatePeripheral): element hl7:code[(@code='8893-0' and @codeSystem='2.16.840.1.113883.6.1')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:text)&lt;=1">(HeartRatePeripheral): element hl7:text appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:statusCode[@code='completed'])&gt;=1 and not(hl7:statusCode[@code='completed']/@nullFlavor)">(HeartRatePeripheral): element hl7:statusCode[@code='completed'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:statusCode[@code='completed'])&lt;=1">(HeartRatePeripheral): element hl7:statusCode[@code='completed'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:effectiveTime)&lt;=1">(HeartRatePeripheral): element hl7:effectiveTime appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:value)&gt;=1 ">(HeartRatePeripheral): element hl7:value is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:value)&lt;=1">(HeartRatePeripheral): element hl7:value appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']"
         id="tmp-r-20c8e067-7060-4e19-8280-4c5246c8310e">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRatePeripheral): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.125'">(HeartRatePeripheral): @root SHALL have value '2.16.840.1.113883.3.1937.99.60.5.10.125'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:id
Item: (HeartRatePeripheral)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:code[(@code='8893-0' and @codeSystem='2.16.840.1.113883.6.1')]
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:code[(@code='8893-0' and @codeSystem='2.16.840.1.113883.6.1')]"
         id="tmp-r-18f8006d-7698-4ab5-8cf9-07b9c343b7db">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRatePeripheral): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="@nullFlavor or (@code='8893-0' and @codeSystem='2.16.840.1.113883.6.1')">(HeartRatePeripheral): The element value SHALL be code '8893-0' codeSystem '2.16.840.1.113883.6.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:text
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:text"
         id="tmp-r-704927d5-5959-450e-b7f2-f08f3f411889">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ED' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRatePeripheral): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ED", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ED"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:statusCode[@code='completed']
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:statusCode[@code='completed']"
         id="tmp-r-41a089d1-d943-48ff-b9cc-afe1866a993d">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRatePeripheral): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CS"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="@nullFlavor or (@code='completed')">(HeartRatePeripheral): The element value SHALL be code 'completed'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:effectiveTime
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:effectiveTime"
         id="tmp-r-1206ecaa-1d76-4ace-a512-6dc42e1c844d">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRatePeripheral): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:value
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:value"
         id="tmp-r-a8d7a9e1-82cb-4a57-b543-0dd8d0390c5e">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='PQ' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRatePeripheral): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:PQ", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="PQ"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(@nullFlavor or (@unit='/min'))">(HeartRatePeripheral): value SHALL use unit '/min' </assert>
      <let name="digitok"
           value="matches(string($theValue), '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="$digitok or @nullFlavor">(HeartRatePeripheral): @value is not a valid PQ number <value-of select="$theValue"/>
      </assert>
      <let name="theUnit" value="@unit"/>
      <let name="UCUMtest"
           value="doc('include/voc-UCUM.xml')/*/ucum[@unit=$theUnit]/@message"/>
      <assert role="warning"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="$UCUMtest='OK' or string-length($UCUMtest)=0">(HeartRatePeripheral): value/@unit (PQ) SHALL be a valid UCUM unit (<value-of select="$UCUMtest"/>).</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]]
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]]"
         id="tmp-r-e211be0b-6a13-4915-bff4-b0f1f5268874">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="string(@typeCode)='COMP'">(HeartRatePeripheral): The value for @typeCode SHALL be 'COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="string(@inversionInd)='false'">(HeartRatePeripheral): The value for @inversionInd SHALL be 'false'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]])&gt;=1 ">(HeartRatePeripheral): element hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]])&lt;=1">(HeartRatePeripheral): element hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]"
         id="tmp-r-b1fff75b-3552-415c-8929-dbc97ea3e719">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="string(@classCode)='OBS'">(HeartRatePeripheral): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="string(@moodCode)='EVN'">(HeartRatePeripheral): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')])&gt;=1 and not(hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]/@nullFlavor)">(HeartRatePeripheral): element hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')])&lt;=1">(HeartRatePeripheral): element hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor])&gt;=1 ">(HeartRatePeripheral): element hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="count(hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor])&lt;=1">(HeartRatePeripheral): element hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]/hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]/hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]"
         id="tmp-r-33e25dd9-e548-4cb5-9224-b9c31bee0730">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRatePeripheral): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="@nullFlavor or (@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')">(HeartRatePeripheral): The element value SHALL be code '364095004' codeSystem '2.16.840.1.113883.6.96'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.125
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]/hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor]
Item: (HeartRatePeripheral)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.125']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:observation[hl7:code[(@code='364095004' and @codeSystem='2.16.840.1.113883.6.96')]]/hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor]"
         id="tmp-r-66f8664e-4d69-48c8-aff7-3760c2656018">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRatePeripheral): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(HeartRatePeripheral): The element value SHALL be PulseRhythm Pulse Rhythm (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.5-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(HeartRatePeripheral): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set PulseRhythm Pulse Rhythm (DYNAMIC).</assert>
   </rule>
</pattern>
