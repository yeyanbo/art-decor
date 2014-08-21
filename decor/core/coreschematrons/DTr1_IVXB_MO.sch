<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 IVXB_MO - Money
    Status: draft
-->
<rule abstract="true" id="IVXB_MO" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="MO"/>
    <assert role="error" test="not(@nullFlavor and @inclusive)">dtr1-1-IVXB_MO: not inclusive if null</assert>
</rule>