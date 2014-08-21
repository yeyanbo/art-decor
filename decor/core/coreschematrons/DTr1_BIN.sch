<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 - BIN
    Status: draft
-->
<rule abstract="true" id="BIN" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="ANY"/>

    <assert role="error"
           test="@nullFlavor or count(*)&gt;0  or text()[string-length(normalize-space())&gt;0]">dtr1-1-BIN: there must be a nullFlavor, or content must be non-empty</assert>
</rule>