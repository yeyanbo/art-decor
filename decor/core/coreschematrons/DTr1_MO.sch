<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Implementatiehandleiding HL7v3 Basiscomponenten, v2.2 - Datatype 1.0 MO - Monetary Amount
    Status: in behandeling
-->
<rule abstract="true" id="MO" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="QTY"/>
    
    <assert role="error" test="(@nullFlavor or (@value and @currency) or *) and not(@nullFlavor and @value)"
        >dtr1-1-MO: null or value or child element in case of extension</assert>
</rule>