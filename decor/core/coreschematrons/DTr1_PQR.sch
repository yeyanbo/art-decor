<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 PQR - Physical Quantity Representation
    Status: draft
-->
<rule abstract="true" id="PQR" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="CV"/>
    <assert role="error" test="not(@nullFlavor and @value)">dtr1-1-PQR: not null and value</assert>
</rule>
