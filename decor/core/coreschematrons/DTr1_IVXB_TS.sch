<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 IVXB_TS - TS
    Status: draft
-->
<rule abstract="true" id="IVXB_TS" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="TS"/>
    <assert role="error" test="not(@nullFlavor and @inclusive)">dtr1-1-IVXB_TS: not inclusive if null</assert>
</rule>