<?xml version="1.0" encoding="UTF-8"?>
<!--
Template derived pattern
===========================================
ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Name: Heart Rate
Description: Hartfrequentie
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="template-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000">
   <title>Heart Rate</title>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]"
         id="tmp-r-d262ddc7-ce77-44ad-b128-217f5d7f0313">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']])&gt;=1 ">(HeartRate): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']])&lt;=1">(HeartRate): element hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]"
         id="tmp-r-6296a995-2dd0-4b0a-b8b0-2fe22812a301">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="string(@classCode)='OBS'">(HeartRate): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="string(@moodCode)='EVN'">(HeartRate): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118'])&gt;=1 ">(HeartRate): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118'] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118'])&lt;=1">(HeartRate): element hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:id)&gt;=1 ">(HeartRate): element hl7:id is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:id)&lt;=1">(HeartRate): element hl7:id appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)])&gt;=1 and not(hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]/@nullFlavor)">(HeartRate): element hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)])&lt;=1">(HeartRate): element hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:text)&lt;=1">(HeartRate): element hl7:text appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:statusCode[@code='completed'])&gt;=1 and not(hl7:statusCode[@code='completed']/@nullFlavor)">(HeartRate): element hl7:statusCode[@code='completed'] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:statusCode[@code='completed'])&lt;=1">(HeartRate): element hl7:statusCode[@code='completed'] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:effectiveTime)&lt;=1">(HeartRate): element hl7:effectiveTime appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:value)&gt;=1 ">(HeartRate): element hl7:value is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:value)&lt;=1">(HeartRate): element hl7:value appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']"
         id="tmp-r-13c8a657-b5bb-449e-8afc-d9fcfbe6043c">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='II' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRate): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:II", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="II"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="string(@root)='2.16.840.1.113883.3.1937.99.60.5.10.118'">(HeartRate): @root SHALL have value '2.16.840.1.113883.3.1937.99.60.5.10.118'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:id
Item: (HeartRate)
-->

   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:code[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code)]"
         id="tmp-r-0f696f1b-8466-4df1-8eb2-1430c5092143">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRate): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(HeartRate): The element value SHALL be HeartRateByMethod Heart Rate By Method (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.7-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(HeartRate): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set HeartRateByMethod Heart Rate By Method (DYNAMIC).</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:text
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:text"
         id="tmp-r-1a1d9a9f-168d-436b-9280-66686f53d338">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='ED' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRate): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:ED", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="ED"/>
      <let name="theValue" value="text()"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:statusCode[@code='completed']
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:statusCode[@code='completed']"
         id="tmp-r-26d7132e-8caa-466b-a8fe-815f0654abba">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRate): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CS"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="@nullFlavor or (@code='completed')">(HeartRate): The element value SHALL be code 'completed'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:effectiveTime
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:effectiveTime"
         id="tmp-r-2a56e824-4f0f-4c37-8fde-a4ac8bcfd409">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='TS' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRate): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:TS", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="TS"/>
      <let name="theValue" value="@value"/>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:value
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:value"
         id="tmp-r-bb1683a7-a233-41d4-8b1c-a4b1ce19ce2f">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='PQ' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRate): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:PQ", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="PQ"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(@nullFlavor or (@unit='/min'))">(HeartRate): value SHALL use unit '/min' </assert>
      <let name="digitok"
           value="matches(string($theValue), '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="$digitok or @nullFlavor">(HeartRate): @value is not a valid PQ number <value-of select="$theValue"/>
      </assert>
      <let name="theUnit" value="@unit"/>
      <let name="UCUMtest"
           value="doc('include/voc-UCUM.xml')/*/ucum[@unit=$theUnit]/@message"/>
      <assert role="warning"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="$UCUMtest='OK' or string-length($UCUMtest)=0">(HeartRate): value/@unit (PQ) SHALL be a valid UCUM unit (<value-of select="$UCUMtest"/>).</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]]
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]]"
         id="tmp-r-5ae6906c-7e90-49e3-8c29-c1406bab0cd6">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="string(@typeCode)='COMP'">(HeartRate): The value for @typeCode SHALL be 'COMP'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="string(@inversionInd)='false'">(HeartRate): The value for @inversionInd SHALL be 'false'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]])&gt;=1 ">(HeartRate): element hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]])&lt;=1">(HeartRate): element hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]]/hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]]/hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]"
         id="tmp-r-ca29d028-843c-400f-b2f2-d91a212f5721">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="string(@classCode)='OBS'">(HeartRate): The value for @classCode SHALL be 'OBS'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="string(@moodCode)='EVN'">(HeartRate): The value for @moodCode SHALL be 'EVN'.</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')])&gt;=1 and not(hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]/@nullFlavor)">(HeartRate): element hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')] is mandatory [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')])&lt;=1">(HeartRate): element hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')] appears to often [max 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor])&gt;=1 ">(HeartRate): element hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor] is required [min 1x].</assert>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="count(hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor])&lt;=1">(HeartRate): element hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor] appears to often [max 1x].</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]]/hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]/hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]]/hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]/hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]"
         id="tmp-r-87103185-5344-4847-952f-55ec225d6e50">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRate): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="@nullFlavor or (@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')">(HeartRate): The element value SHALL be code '8884-9' codeSystem '2.16.840.1.113883.6.1'.</assert>
   </rule>
   <!--
Template derived rules for ID: 2.16.840.1.113883.3.1937.99.60.5.10.118
Context: *[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]]/hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]/hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor]
Item: (HeartRate)
-->

   <rule context="*[hl7:observation[hl7:templateId/@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:observation[hl7:templateId[@root='2.16.840.1.113883.3.1937.99.60.5.10.118']]/hl7:entryRelationship[hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]]/hl7:observation[hl7:code[(@code='8884-9' and @codeSystem='2.16.840.1.113883.6.1')]]/hl7:value[concat(@code,@codeSystem)=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/exception/@code) or @nullFlavor]"
         id="tmp-r-4af4e8e3-3c5c-4e9f-bca4-b990f8b4aa2b">
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="(local-name-from-QName(resolve-QName(@xsi:type,.))='CE' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='urn:hl7-org:v3') or not(@xsi:type)">(HeartRate): If an @xsi:type instruction is present it SHALL be valued "{urn:hl7-org:v3}:CE", found "{<value-of select="namespace-uri-from-QName(resolve-QName(@xsi:type,.))"/>}:<value-of select="local-name-from-QName(resolve-QName(@xsi:type,.))"/>"</assert>
      <extends rule="CE"/>
      <let name="theValue" value="@value"/>
      <let name="theCode" value="@code"/>
      <let name="theCodeSystem" value="@codeSystem"/>
      <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="@nullFlavor or exists(doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet[conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion] or completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]])">(HeartRate): The element value SHALL be HeartRhythm Heart Rhythm (DYNAMIC).</assert>
      <let name="theNullFlavor" value="@nullFlavor"/>
      <let name="validNullFlavorsFound"
           value="exists(doc('include/voc-2.16.840.1.113883.3.1937.99.60.5.11.6-DYNAMIC.xml')/*/valueSet/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008'])"/>
      <assert role="error"
              see="http://decor.nictiz.nl/demo5/demo5-html-20140729T110827/tmp-2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.html"
              test="not(@nullFlavor) or $validNullFlavorsFound">(HeartRate): The null value '<value-of select="@nullFlavor"/>' for @code SHALL be selected from the set of valid null flavors defined for this attribute or those associated with Value Set HeartRhythm Heart Rhythm (DYNAMIC).</assert>
   </rule>
</pattern>
