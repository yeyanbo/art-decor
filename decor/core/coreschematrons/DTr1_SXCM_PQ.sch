<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 SXCM_PQ - PQ
    Status: draft
-->
<rule abstract="true" id="SXCM_PQ" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="PQ"/>
    <assert role="error" test="not(@nullFlavor and @operator)">dtr1-1-SXCM_PQ: not operator if null</assert>
</rule>