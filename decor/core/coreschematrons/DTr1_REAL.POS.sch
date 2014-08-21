<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 REAL.POS - Real Positive
    Status: draft
-->
<rule abstract="true" id="REAL.POS" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="REAL"/>
    
    <assert role="error" test="@nullFlavor or @value > 0">dtr1-1-REAL.POS: null or value > 0</assert>
</rule>