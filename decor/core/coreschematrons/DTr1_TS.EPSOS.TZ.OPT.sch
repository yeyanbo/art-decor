<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 TS.EPSOS.TZ.OPT - SHALL be precise at least to the year, SHOULD be precise to the day, and MAY omit time zone.
    Status: draft
-->
<rule abstract="true" id="TS.EPSOS.TZ.OPT" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="TS"/>

    <assert role="error" test="not(@value) or matches(@value,'^[0-9]{4}')"
        >dtr1-1-TS.EPSOS.TZ.OPT: time SHALL be precise to at least the year</assert>
    
    <assert role="warning" test="not(@value) or matches(@value,'^[0-9]{8}')"
        >dtr1-2-TS.EPSOS.TZ.OPT: time SHOULD be precise to the day</assert>
    
</rule>
