<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 CE - Coded String with Equivalents
    Status: draft
-->
<rule abstract="true" id="CE" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="CD"/>
    <assert role="error" test="not(hl7:qualifier)">dtr1-1-CE: cannot have qualifier</assert>
</rule>