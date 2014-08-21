<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Name: Oxygen Saturation
Description: O2 saturatie (SO2)
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000">
   <title>Oxygen Saturation</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]"
         id="tmp-r-16c26f6f-ca87-4355-8ef2-cf182d931dcd">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']])&gt;=1 ">(OxygenSaturation): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']])&lt;=1">(OxygenSaturation): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]"
         id="tmp-r-827ef410-db14-41f9-a79d-1bbbe337477c">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="string(@classCode)='OBS'">(OxygenSaturation): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="string(@moodCode)='EVN'">(OxygenSaturation): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127'])&gt;=1 ">(OxygenSaturation): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127'])&lt;=1">(OxygenSaturation): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:id)&gt;=1 ">(OxygenSaturation): element hl7:id is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:id)&lt;=1">(OxygenSaturation): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:code[(@code='2710-2' and @codeSystem='2.16.840.1.113883.6.1')])&gt;=1 and not(hl7:code[(@code='2710-2' and @codeSystem='2.16.840.1.113883.6.1')]/@nullFlavor)">(OxygenSaturation): element hl7:code[(@code='2710-2' and @codeSystem='2.16.840.1.113883.6.1')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:code[(@code='2710-2' and @codeSystem='2.16.840.1.113883.6.1')])&lt;=1">(OxygenSaturation): element hl7:code[(@code='2710-2' and @codeSystem='2.16.840.1.113883.6.1')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:text)&lt;=1">(OxygenSaturation): element hl7:text appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:statusCode[@code='completed'])&gt;=1 and not(hl7:statusCode[@code='completed']/@nullFlavor)">(OxygenSaturation): element hl7:statusCode[@code='completed'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:statusCode[@code='completed'])&lt;=1">(OxygenSaturation): element hl7:statusCode[@code='completed'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:effectiveTime)&lt;=1">(OxygenSaturation): element hl7:effectiveTime appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:value)&gt;=1 ">(OxygenSaturation): element hl7:value is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:value)&lt;=1">(OxygenSaturation): element hl7:value appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:entryRelationship[hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]])&lt;=1">(OxygenSaturation): element hl7:entryRelationship[hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']"
         id="tmp-r-d728954c-68b2-44fc-82ed-fd385690f423">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OxygenSaturation): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.127'">(OxygenSaturation): @root SHALL have value '2.16.840.1.113883.3.1937.99.60.5.10.127'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:id
Item: (OxygenSaturation)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:code[(@code='2710-2' and @codeSystem='2.16.840.1.113883.6.1')]
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:code[(@code='2710-2' and @codeSystem='2.16.840.1.113883.6.1')]"
         id="tmp-r-ed380de5-29e4-430e-88c6-458ff7e91ed4">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OxygenSaturation): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="@nullFlavor or (@code='2710-2' and @codeSystem='2.16.840.1.113883.6.1')">(OxygenSaturation): The element value SHALL be code '2710-2' codeSystem '2.16.840.1.113883.6.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:text
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:text"
         id="tmp-r-33792ff7-612c-46b2-b52e-20bedbea2832">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ED' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OxygenSaturation): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ED", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ED"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:statusCode[@code='completed']
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:statusCode[@code='completed']"
         id="tmp-r-c77e6b4f-8452-43f8-91e5-2e732e720ced">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OxygenSaturation): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CS"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="@nullFlavor or (@code='completed')">(OxygenSaturation): The element value SHALL be code 'completed'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:effectiveTime
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:effectiveTime"
         id="tmp-r-7f36ac30-81e2-4a89-9a73-6e3fd5cf98cb">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OxygenSaturation): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:value
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:value"
         id="tmp-r-06024d7c-8656-44e4-a301-c9922bd7f5c4">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='PQ' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(OxygenSaturation): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:PQ", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="PQ"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="(@nullFlavor or (@unit='%'))">(OxygenSaturation): value SHALL use unit '%' </assert>
      <let name="digitok"
           value="matches(string($theValue), '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="$digitok or @nullFlavor">(OxygenSaturation): @value is not a valid PQ number <value-of select="$theValue"/>
      </assert>
      <let name="theUnit" value="@unit"/>
      <let name="UCUMtest"
           value="doc('include/voc-UCUM.xml')/*/ucum[@unit=$theUnit]/@message"/>
      <assert role="warning"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="$UCUMtest='OK' or string-length($UCUMtest)=0">(OxygenSaturation): value/@unit (PQ) SHALL be a valid UCUM unit (<value-of select="$UCUMtest"/>).</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:entryRelationship[hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]]
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:entryRelationship[hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]]"
         id="tmp-r-94bb885d-b27b-42d9-9b59-98272e099840">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="string(@typeCode)='COMP'">(OxygenSaturation): The value for @typeCode SHALL be 'COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="string(@inversionInd)='false'">(OxygenSaturation): The value for @inversionInd SHALL be 'false'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]])&gt;=1 ">(OxygenSaturation): element hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]])&lt;=1">(OxygenSaturation): element hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:entryRelationship[hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:entryRelationship[hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]"
         id="tmp-r-01ce4844-4a12-49d8-9495-c9b7b4ceb558">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="string(@classCode)='PROC'">(OxygenSaturation): The value for @classCode SHALL be 'PROC'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="string(@moodCode)='EVN'">(OxygenSaturation): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')])&gt;=1 and not(hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]/@nullFlavor)">(OxygenSaturation): element hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="count(hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')])&lt;=1">(OxygenSaturation): element hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.127
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:entryRelationship[hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]/hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]
Item: (OxygenSaturation)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.127']]/hl7:entryRelationship[hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]]/hl7:procedure[hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]]/hl7:code[(@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')]"
         id="tmp-r-36fc1d01-e380-42dd-b798-9f14366d163f">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.html"
              test="@nullFlavor or (@code='57485005' and @codeSystem='2.16.840.1.113883.6.96')">(OxygenSaturation): The element value SHALL be code '57485005' codeSystem '2.16.840.1.113883.6.96'.</assert>
   </rule>
</pattern>
