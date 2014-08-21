<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Name: Systolic blood pressure
Description: Systolische bloeddruk
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000">
   <title>Systolic blood pressure</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]"
         id="tmp-r-a0657141-541b-46b1-89cc-cf0f8f0fc63e">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']])&gt;=1 ">(SystolicBloodPressure): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']])&lt;=1">(SystolicBloodPressure): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]"
         id="tmp-r-89307ef5-cda1-4e9c-84ce-3155656a1ac6">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="string(@classCode)='OBS'">(SystolicBloodPressure): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="string(@moodCode)='EVN'">(SystolicBloodPressure): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129'])&gt;=1 ">(SystolicBloodPressure): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129'])&lt;=1">(SystolicBloodPressure): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:id)&gt;=1 ">(SystolicBloodPressure): element hl7:id is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:id)&lt;=1">(SystolicBloodPressure): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:code[(@code='8480-6' and @codeSystem='2.16.840.1.113883.6.1')])&gt;=1 and not(hl7:code[(@code='8480-6' and @codeSystem='2.16.840.1.113883.6.1')]/@nullFlavor)">(SystolicBloodPressure): element hl7:code[(@code='8480-6' and @codeSystem='2.16.840.1.113883.6.1')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:code[(@code='8480-6' and @codeSystem='2.16.840.1.113883.6.1')])&lt;=1">(SystolicBloodPressure): element hl7:code[(@code='8480-6' and @codeSystem='2.16.840.1.113883.6.1')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:text)&lt;=1">(SystolicBloodPressure): element hl7:text appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:statusCode[@code='completed'])&gt;=1 and not(hl7:statusCode[@code='completed']/@nullFlavor)">(SystolicBloodPressure): element hl7:statusCode[@code='completed'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:statusCode[@code='completed'])&lt;=1">(SystolicBloodPressure): element hl7:statusCode[@code='completed'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:effectiveTime)&lt;=1">(SystolicBloodPressure): element hl7:effectiveTime appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:value)&gt;=1 ">(SystolicBloodPressure): element hl7:value is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="count(hl7:value)&lt;=1">(SystolicBloodPressure): element hl7:value appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']"
         id="tmp-r-05198d2e-c4a0-4515-8658-664b92c01069">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(SystolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.129'">(SystolicBloodPressure): The value for @root SHALL be '2.16.840.1.113883.3.1937.99.60.5.10.129'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:id
Item: (SystolicBloodPressure)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:code[(@code='8480-6' and @codeSystem='2.16.840.1.113883.6.1')]
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:code[(@code='8480-6' and @codeSystem='2.16.840.1.113883.6.1')]"
         id="tmp-r-eda70c2a-f27c-4822-9a36-e34dbc0712cc">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(SystolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="@nullFlavor or (@code='8480-6' and @codeSystem='2.16.840.1.113883.6.1')">(SystolicBloodPressure): The element value SHALL be code '8480-6' codeSystem '2.16.840.1.113883.6.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:text
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:text"
         id="tmp-r-03fe5ae3-4106-4caa-a390-119162447353">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ED' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(SystolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ED", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ED"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:statusCode[@code='completed']
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:statusCode[@code='completed']"
         id="tmp-r-bcc66f6b-3398-46da-a7fc-3d577e27ff5c">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(SystolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CS"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="@nullFlavor or (@code='completed')">(SystolicBloodPressure): The element value SHALL be code 'completed'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:effectiveTime
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:effectiveTime"
         id="tmp-r-f82ba47b-4971-45de-a722-84c04affec9e">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(SystolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:value
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:value"
         id="tmp-r-9537faef-29dc-487a-8797-1c90b4b7fedf">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='PQ' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(SystolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:PQ", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="PQ"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="(@nullFlavor or (@unit='mm[Hg]'))">(SystolicBloodPressure): value SHALL use unit 'mm[Hg]' </assert>
      <let name="digitok"
           value="matches(string($theValue), '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="$digitok or @nullFlavor">(SystolicBloodPressure): @value is not a valid PQ number <value-of select="$theValue"/>
      </assert>
      <let name="theUnit" value="@unit"/>
      <let name="UCUMtest"
           value="doc('include/voc-UCUM.xml')/*/ucum[@unit=$theUnit]/@message"/>
      <assert role="warning"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="$UCUMtest='OK' or string-length($UCUMtest)=0">(SystolicBloodPressure): value/@unit (PQ) SHALL be a valid UCUM unit (<value-of select="$UCUMtest"/>).</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.129
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:interpretationCode
Item: (SystolicBloodPressure)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.129']]/hl7:interpretationCode"
         id="tmp-r-e208dea7-08d7-4383-b70c-3c9317e5d6f6">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(SystolicBloodPressure): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.1.11.78-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(SystolicBloodPressure): The element value SHALL be ObservationInterpretation (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.1.11.78-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(SystolicBloodPressure): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set ObservationInterpretation (DYNAMIC).</assert>
   </rule>
</pattern>
