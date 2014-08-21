<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 TS.EPSOS - SHALL be precise to the day, SHALL include a time zone if more precise than to the day, and SHOULD be precise to the second. 
    Status: draft
-->
<rule abstract="true" id="TS.EPSOS.TZ" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="TS"/>

    <assert role="error" test="not(@value) or matches(@value,'^[0-9]{8}')"
        >dtr1-1-TS.EPSOS.TZ: time SHALL be precise to the day</assert>
    
    <assert role="warning" test="not(@value) or matches(@value,'^[0-9]{14}')"
        >dtr1-2-TS.EPSOS.TZ: time SHOULD be precise to the second</assert>
    
    <assert role="error" test="not(matches(@value,'^[0-9]{8}')) or contains(@value,'+') or contains(@value,'-')"
        >dtr1-3-TS.EPSOS.TZ: time SHALL include a time zone if more precise than to the day</assert>
</rule>
