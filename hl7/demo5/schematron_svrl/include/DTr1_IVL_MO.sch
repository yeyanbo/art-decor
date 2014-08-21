<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 IVL_PQ - Interval of Physical Quantity
    Status: draft
-->
<rule xmlns="http://purl.oclc.org/dsdl/schematron"
      abstract="true"
      id="IVL_MO">
    <extends rule="SXCM_MO"/>

    <assert role="error"
           test="(@nullFlavor and not(@value|@unit|hl7:*)) or (not(@nullFlavor) and (@value|hl7:*))">dtr1-1-IVL_MO: null violation. Cannot have @nullFlavor and @value or child elements, or the other way around</assert>
    <assert role="error" test="not(hl7:*[@nullFlavor and (@value|@unit)])">dtr1-2-IVL_MO: null violation. Cannot have @nullFlavor and @value on any child elements</assert>
    
    <assert role="error" test="not(@value and hl7:* except hl7:translation)">dtr1-3-IVL_MO: co-occurence violation. Cannot have @value and other child elements except translations</assert>
    <assert role="error" test="not(hl7:center and (hl7:low|hl7:high|hl7:width))">dtr1-4-IVL_MO: co-occurence violation. Cannot have center and other child elements</assert>
    <assert role="error" test="not(hl7:*[@updateMode])">dtr1-5-IVL_MO: no updateMode on IVL attributes</assert>
    
    <assert role="error" test="not(hl7:low/@value = hl7:high/@value)">dtr1-6-IVL_MO: low/@value must not be equal to high/@value</assert>
    
    <!-- width has datatype PQR, which extends CV ((){1}(((0[1-9])|([12]\d)|(3[01]))?)?)? -->
    <assert role="error" test="not(hl7:width[@unit][not(@value)])">dtr1-1-PQR: width element: no unit without value</assert>
    <assert role="error" test="not(hl7:width/hl7:translation)">dtr1-2-PQR: width element: no translation</assert>
    
    <assert role="error"
           test="not(hl7:low/@value and hl7:high/@value) or hl7:low/number(@value) &lt; hl7:high/number(@value)">dtr1-7-IVL_MO: low/@value must be lower than high/@value</assert>
    
    <assert role="error"
           test="not(hl7:low/@currency and hl7:high/@currency) or hl7:low/@currency = hl7:high/@currency">dtr1-8-IVL_MO: currency in low and high must be equal</assert>
    
    <assert role="error"
           test="not(hl7:translation and hl7:* except hl7:translation)">dtr1-9-IVL_MO: co-occurence violation. Cannot have translation and other child elements except translation</assert>
</rule>
