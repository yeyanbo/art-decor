<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 CO - Coded Ordinal
    Status: draft
-->
<rule abstract="true" id="CO" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="CV"/>

    <assert role="error" test="not(hl7:translation)">dtr1-1-CO: cannot have translation</assert>
    
</rule>
