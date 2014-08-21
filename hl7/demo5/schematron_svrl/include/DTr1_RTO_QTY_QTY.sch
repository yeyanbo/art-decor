<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Datatype 1.0 RTO_QTY_QTY - Ratio of Quantity
    Status: Draft
-->
<rule xmlns="http://purl.oclc.org/dsdl/schematron"
      abstract="true"
      id="RTO_QTY_QTY">
    <extends rule="QTY"/>
    
    <assert role="error"
           test="@nullFlavor or (hl7:numerator[not(@nullFlavor)] and hl7:denominator[not(@nullFlavor)])">dtr1-1-RTO_QTY_QTY: numerator and denominator required</assert>
    
    <assert role="error"
           test="not(hl7:numerator[@updateMode] or hl7:denominator[@updateMode])">dtr1-2-RTO_QTY_QTY: no updateMode on numerator or denominator</assert>
    <assert role="error" test="not(hl7:uncertainty)">dtr1-3-RTO_QTY_QTY: no uncertainty</assert>
    
</rule>
