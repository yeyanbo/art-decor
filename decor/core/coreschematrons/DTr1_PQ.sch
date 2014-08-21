<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 PQ - Physical Quantity
    Status: draft
-->
<rule abstract="true" id="PQ" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="QTY"/>
    
    <assert role="error" test="(@nullFlavor or @value or *) and not(@nullFlavor and @value)"
        >dtr1-1-PQ: null or value or child element in case of extension</assert>
    <!--
    <assert role="error" test="not(@nullFlavor) or (@nullFlavor and not(hl7:translation))"
        >dtr1-2-PQ: no translation if null</assert>
    -->
</rule>