<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.3001
Name: Vital Signs Section
Description: 
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000">
   <title>Vital Signs Section</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.3001
Context: *[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]
Item: (VitalSignsSection)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.3001
Context: *[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]
Item: (VitalSignsSection)
-->

   <rule context="*[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]"
         id="tmp-r-66f2dcdf-f9bf-4dc7-a5f0-6bb78ef7e6ff">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="string(@classCode)='DOCSECT' or not(@classCode)">(VitalSignsSection): The value for @classCode SHALL be 'DOCSECT'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001'])&gt;=1 ">(VitalSignsSection): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001'])&lt;=1">(VitalSignsSection): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="count(hl7:code[(@code='8716-3' and @codeSystem='2.16.840.1.113883.6.1')])&gt;=1 and not(hl7:code[(@code='8716-3' and @codeSystem='2.16.840.1.113883.6.1')]/@nullFlavor)">(VitalSignsSection): element hl7:code[(@code='8716-3' and @codeSystem='2.16.840.1.113883.6.1')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="count(hl7:code[(@code='8716-3' and @codeSystem='2.16.840.1.113883.6.1')])&lt;=1">(VitalSignsSection): element hl7:code[(@code='8716-3' and @codeSystem='2.16.840.1.113883.6.1')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="count(hl7:title)&gt;=1 and not(hl7:title/@nullFlavor)">(VitalSignsSection): element hl7:title is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="count(hl7:title)&lt;=1">(VitalSignsSection): element hl7:title appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="count(hl7:text)&gt;=1 and not(hl7:text/@nullFlavor)">(VitalSignsSection): element hl7:text is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="count(hl7:text)&lt;=1">(VitalSignsSection): element hl7:text appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.3001
Context: *[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']
Item: (VitalSignsSection)
-->

   <rule context="*[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']"
         id="tmp-r-81c70343-1e24-48aa-a486-5bbb7c72d5f2">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(VitalSignsSection): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.3001'">(VitalSignsSection): The value for @root SHALL be '2.16.840.1.113883.3.1937.99.60.5.10.3001'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.3001
Context: *[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:code[(@code='8716-3' and @codeSystem='2.16.840.1.113883.6.1')]
Item: (VitalSignsSection)
-->

   <rule context="*[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:code[(@code='8716-3' and @codeSystem='2.16.840.1.113883.6.1')]"
         id="tmp-r-6ebaf6cd-d042-430e-9640-011adfa49c91">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CD' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(VitalSignsSection): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CD", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CD"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="@nullFlavor or (@code='8716-3' and @codeSystem='2.16.840.1.113883.6.1')">(VitalSignsSection): The element value SHALL be code '8716-3' codeSystem '2.16.840.1.113883.6.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.3001
Context: *[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:title
Item: (VitalSignsSection)
-->

   <rule context="*[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:title"
         id="tmp-r-84643b3c-181e-4555-82d1-04a36b4cccb9">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ST' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(VitalSignsSection): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ST", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ST"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.3001
Context: *[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:text
Item: (VitalSignsSection)
-->

   <rule context="*[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:text"
         id="tmp-r-6c95dfc1-e07a-4994-8b92-ce095b78cb64">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='SD.TEXT' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(VitalSignsSection): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:SD.TEXT", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="SD.TEXT"/>
      <let name="theValue" value="@value"/>
   </rule>

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.3001
Context: *[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:entry[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.115']]]
Item: (VitalSignsSection)
-->
   <rule context="*[hl7:section[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:section[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.3001']]/hl7:entry[hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.115']]]">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="not(@typeCode) or (string-length(@typeCode)&gt;0 and not(matches(@typeCode,'\s')))">(VitalSignsSection): Attribute @typeCode SHALL be of data type 'cs'</assert>
      <let name="theAttValue"
           value="distinct-values(tokenize(normalize-space(@typeCode),' '))"/>
      <let name="theAttCheck"
           value="distinct-values(for $code in tokenize(@typeCode,' ') return if ($code=('COMP')) then ($code) else ())"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="not(@typeCode) or count($theAttValue) = count($theAttCheck)">(VitalSignsSection): The value for typeCode SHALL be 'code COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.html"
              test="not(@contextConductionInd) or string(@contextConductionInd)=('true','false')">(VitalSignsSection): Attribute @contextConductionInd SHALL be of data type 'bl'</assert>
   </rule>
</pattern>
