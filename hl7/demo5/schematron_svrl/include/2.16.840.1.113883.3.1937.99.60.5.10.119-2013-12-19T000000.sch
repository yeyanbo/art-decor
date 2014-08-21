<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Name: Body Height
Description: Lichaamslengte
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000">
   <title>Body Height</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]"
         id="tmp-r-65d02290-36d2-450c-825a-877000033f05">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']])&gt;=1 ">(BodyHeight): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']])&lt;=1">(BodyHeight): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]"
         id="tmp-r-96162cf3-28ce-4ac0-bc5e-21d599889693">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="string(@classCode)='OBS'">(BodyHeight): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="string(@moodCode)='EVN'">(BodyHeight): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119'])&gt;=1 ">(BodyHeight): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119'])&lt;=1">(BodyHeight): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:id)&gt;=1 ">(BodyHeight): element hl7:id is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:id)&lt;=1">(BodyHeight): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)])&gt;=1 and not(hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]/@nullFlavor)">(BodyHeight): element hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)])&lt;=1">(BodyHeight): element hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:text)&lt;=1">(BodyHeight): element hl7:text appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:statusCode[@code='completed'])&gt;=1 and not(hl7:statusCode[@code='completed']/@nullFlavor)">(BodyHeight): element hl7:statusCode[@code='completed'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:statusCode[@code='completed'])&lt;=1">(BodyHeight): element hl7:statusCode[@code='completed'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:effectiveTime)&lt;=1">(BodyHeight): element hl7:effectiveTime appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:value)&gt;=1 ">(BodyHeight): element hl7:value is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:value)&lt;=1">(BodyHeight): element hl7:value appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']"
         id="tmp-r-c7f34b21-e165-4c88-9018-b436ed14d503">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BodyHeight): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.119'">(BodyHeight): @root SHALL have value '2.16.840.1.113883.3.1937.99.60.5.10.119'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:id
Item: (BodyHeight)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]"
         id="tmp-r-a4c00968-911b-4cd3-b205-1a1037f3429c">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BodyHeight): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(BodyHeight): The element value SHALL be BodyHeightByMethod Body Height By Method (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(BodyHeight): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set BodyHeightByMethod Body Height By Method (DYNAMIC).</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="count(hl7:originalText)&lt;=1">(BodyHeight): element hl7:originalText appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]/hl7:originalText
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.10-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]/hl7:originalText"
         id="tmp-r-07ae6623-8c9c-4931-b21a-5c3c60e292bd">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ED' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BodyHeight): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ED", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ED"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:text
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:text"
         id="tmp-r-a0ef0c05-655c-411a-ab58-78d096d3ab2b">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ED' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BodyHeight): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ED", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ED"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:statusCode[@code='completed']
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:statusCode[@code='completed']"
         id="tmp-r-14cd1d5e-6bb5-417a-91b2-21ba352863e6">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BodyHeight): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CS"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="@nullFlavor or (@code='completed')">(BodyHeight): The element value SHALL be code 'completed'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:effectiveTime
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:effectiveTime"
         id="tmp-r-530a4dcb-d2d0-477e-a899-ade3c1ebe26a">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BodyHeight): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.119
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:value
Item: (BodyHeight)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.119']]/hl7:value"
         id="tmp-r-d83095fc-e2de-45cf-9ffc-e072bdb1f781">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='PQ' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(BodyHeight): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:PQ", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="PQ"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="(@nullFlavor or (@unit='cm' and number($theValue)&gt;=0 and number($theValue)&lt;=250)) or (@nullFlavor or (@unit='m' and number($theValue)&gt;=0.00 and number($theValue)&lt;=2.50 and (matches(string($theValue), '^[-+]?[0-9]*\.[0-9]{2,99}$'))))">(BodyHeight): value SHALL use unit 'cm' and be in range [0..250]   or use unit 'm' and be in range [0.00..2.50]  and have a minumum of 2 fractional digits </assert>
      <let name="digitok"
           value="matches(string($theValue), '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="$digitok or @nullFlavor">(BodyHeight): @value is not a valid PQ number <value-of select="$theValue"/>
      </assert>
      <let name="theUnit" value="@unit"/>
      <let name="UCUMtest"
           value="doc('include/voc-UCUM.xml')/*/ucum[@unit=$theUnit]/@message"/>
      <assert role="warning"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.html"
              test="$UCUMtest='OK' or string-length($UCUMtest)=0">(BodyHeight): value/@unit (PQ) SHALL be a valid UCUM unit (<value-of select="$UCUMtest"/>).</assert>
   </rule>
</pattern>
