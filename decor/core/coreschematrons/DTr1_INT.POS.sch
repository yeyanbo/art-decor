<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 INT.POS - Integer, positive
    Status: draft
-->
<rule abstract="true" id="INT.POS" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="INT"/>
    
    <assert role="error" test="@nullFlavor or @value > 0">dtr1-2-INT.POS: null or value > 0</assert>
</rule>