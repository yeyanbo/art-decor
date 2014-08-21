<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    AD.EPSOS - Address
    Status: draft
-->
<rule abstract="true" id="AD.EPSOS" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="AD"/>
    
    <assert role="error" test="@nullFlavor or hl7:*">dtr1-1-AD.EPSOS: if addr is not null at least one sub element has to be provided</assert>
</rule>
