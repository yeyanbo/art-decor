<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 TS - Timestamp
    Status: draft
-->
<rule xmlns="http://purl.oclc.org/dsdl/schematron" abstract="true" id="TS">
    <extends rule="QTY"/>
    
    <assert role="error"
           test="(@nullFlavor or @value or *) and not(@nullFlavor and @value)">dtr1-1-TS: null or value or child element in case of extension</assert>
</rule>
