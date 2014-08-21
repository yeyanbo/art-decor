<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 CR - Concept Qualifier
    Status: draft
    TODO: check for codes/codesystemen in translations
-->
<rule abstract="true" id="CR" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="ANY"/>
    <assert test="(hl7:value or @nullFlavor) and not(@nullFlavor and node())">dtr1-1-CR: null or value</assert>
</rule>
