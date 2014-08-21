<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 REAL - Real
    Status: draft
-->
<rule abstract="true" id="REAL" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="QTY"/>
    
    <assert role="error" test="(@nullFlavor or @value or *) and not(@nullFlavor and @value)"
        >dtr1-1-REAL: null or value or child element in case of extension</assert>
</rule>