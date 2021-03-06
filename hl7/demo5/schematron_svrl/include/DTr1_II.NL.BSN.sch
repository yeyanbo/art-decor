<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 - Instance Identifier, NL flavor BSN
    II
    Flavor
    .NL The Netherlands
    .BSN Burgerservicenummer (BSN) Nederland, fixed OID 2.16.840.1.113883.2.4.6.3
    Status: draft
-->
<rule xmlns="http://purl.oclc.org/dsdl/schematron"
      abstract="true"
      id="II.NL.BSN">
    <extends rule="II"/>

    <assert role="error" test="@nullFlavor or @root='2.16.840.1.113883.2.4.6.3'">dtr1-1-II.NL.BSN: Burgerservicenummer @root MOET 2.16.840.1.113883.2.4.6.3 zijn indien niet null</assert>
    <assert role="error"
           test="not(@root='2.16.840.1.113883.2.4.6.3') or matches(@extension,'^[0-9]{9}$')">dtr1-2-II.NL.BSN: Burgerservicenummer MOET 9 cijfers lang zijn</assert>
    <assert role="error"
           test="not(@root='2.16.840.1.113883.2.4.6.3') or (         (   number(substring(@extension,1,1))*9 )+         (   number(substring(@extension,2,1))*8 )+         (   number(substring(@extension,3,1))*7 )+         (   number(substring(@extension,4,1))*6 )+         (   number(substring(@extension,5,1))*5 )+         (   number(substring(@extension,6,1))*4 )+         (   number(substring(@extension,7,1))*3 )+         (   number(substring(@extension,8,1))*2 )+         (   number(substring(@extension,9,1))*-1) ) mod 11=0">dtr1-3-II.NL.BSN: Burgerservicenummer voldoet niet aan modulo 11 proef</assert>
</rule>
