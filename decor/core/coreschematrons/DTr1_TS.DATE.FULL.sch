<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 TS.DATE.FULL - constrains TS.DATE so that it shall contain reference to a particular day.
    TS
    Flavor
    .DATE
    .FULL
    Status: draft
-->
<rule abstract="true" id="TS.DATE.FULL" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="TS"/>
        
    <assert role="error" test="@nullFlavor or matches(@value, '^[0-9]{8,8}$')">dtr1-1-TS.DATE.FULL: null or date precision of time stamp shall be YYYYMMDD.</assert>
</rule>