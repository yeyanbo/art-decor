<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 CE.EPSOS - Coded String with Equivalents
    Status: draft
-->
<rule abstract="true" id="CE.EPSOS" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="CE"/>
    <assert role="error" test="not(hl7:qualifier)"
        >dtr1-1-CE.EPSOS: cannot have qualifier</assert>
</rule>