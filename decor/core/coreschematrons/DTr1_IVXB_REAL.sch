<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 IVXB_REAL - Real
    Status: draft
-->
<rule abstract="true" id="IVXB_REAL" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="REAL"/>
    <assert role="error" test="not(@nullFlavor and @inclusive)">dtr1-1-IVXB_REAL: not inclusive if null</assert>
</rule>