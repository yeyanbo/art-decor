xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at  "art-decor.xqm";
import module namespace vs  = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";
declare namespace hl7 = "urn:hl7-org:v3";
declare namespace cda = "urn:hl7-org:v3";

(:
    Rewrite all shorthands to the same name/value format to ease processing
:)
declare function local:normalizeAttributes($attributes as element()*) as element()* {
    for $attribute in $attributes[@selected][not(@prohibited='true')]
    for $att in $attribute/@*[not(name()=('xsi:type','selected','originalOpt','originalType','conf','isOptional','prohibited','datatype','value'))]
    let $anme := if ($att[name()='name']) then $att/string() else ($att/name())
    let $aval := if ($att[name()='name']) then $att/../@value/string() else ($att/string())
    return
        <attribute name="{$anme}">
        {
            if (string-length($aval)>0) then 
                attribute value {$aval}
            else (),
            $att/../@isOptional,
            $att/../@prohibited,
            $att/../@datatype,
            $att/../node()
        }
        </attribute>
};

declare function local:processElement($element as element(),$decor as element()) as element()? {
    if ($element/@selected and not($element/@conformance='NP')) then
        (: strip namespace prefix and predicate from element/@name :)
        let $elmpfx     := substring-before($element/@name,':')
        let $elmns      := if ($elmpfx=('hl7','cda','',())) then () else (namespace-uri-for-prefix($elmpfx,$decor))
        let $elmname    := replace($element/@name,'^([^:]+:)?([^\s\[]+)\s*(\[.*)?','$2')
        (: in older (hand created) templates people may have used double declarations in one attribute element, e.g.
            <attribute classCode="OBS" moodCode="EVN"/>
           Also we might encounter a mix of name/value versus shorthands. Normalize before processing to name/value
        :)
        let $attributes := local:normalizeAttributes($element/attribute)
        return
        element {if ($elmns) then QName($elmns,concat($elmpfx,':',$elmname)) else $elmname} {
            if ($element/@originalType='ANY') then
                (: poor mans solution for INT.POS, AD.NL and other flavors. Should check
                    DECOR-supported-datatypes.xml
                :)
                attribute xsi:type {tokenize($element/@datatype,'\.')[1]}
            else()
            ,
            (: check normalized element/attribute :)
            for $att in $attributes
            group by $anme := $att/@name/string()
            return
                if ($att[1]/@value) then 
                    attribute {$anme} {$att[1]/@value}
                else if ($att[1]/vocabulary) then (
                    if ($att[1]/vocabulary[1]/@valueSet) then
                        let $vsref     := $att[1]/vocabulary[1]/@valueSet
                        let $vsflex    := $att[1]/vocabulary[1]/@flexibility
                        let $valueSet  := vs:getExpandedValueSetByRef($vsref,$vsflex,$decor/project/@prefix)
                        let $firstCode := ($valueSet//conceptList/concept[not(@type=('D','A'))])[1]
                        return (
                            attribute {$anme} {$firstCode/@code}
                        )
                    else if ($att[1]/vocabulary[1]/@code) then (
                        attribute {$anme} {$att[1]/vocabulary[1]/@code}
                    )
                    else ()
                )
                else if ($att[1][@datatype=('bn','bl')]) then
                    attribute {$anme} {'false'}
                else if ($att[1][@datatype=('set_cs','cs')]) then
                    attribute {$anme} {'cs'}
                else if ($att[1][@datatype=('int')]) then
                    let $int            := if ($element/property/@minInclude) then $element/property/@minInclude else (1)
                    return
                    attribute {$anme} {$int}
                else if ($att[1][@datatype=('real')]) then
                    let $int            := if ($element/property/@minInclude) then $element/property/@minInclude else (1)
                    let $intfrac        := tokenize($int,'\.')[2]
                    let $fractionDigits := if ($element/property[1]/@fractionDigits[matches(.,'\d')]) then xs:integer(replace($element/property[1]/@fractionDigits,'!','')) else (0)
                    let $intfracadd     := 
                        string-join(if (string-length($intfrac) lt $fractionDigits) then 
                            for $i in (1 to ($fractionDigits - string-length($intfrac)))
                            return '0'
                        else (),'')
                    let $real           := concat($int,if (not(contains($int,'.')) and string-length($intfracadd)>0) then '.' else(),$intfracadd)
                    return
                    attribute {$anme} {$real}
                else if ($att[1][@datatype=('ts')]) then
                    attribute {$anme} {format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]','en',(),())}
                else if ($att[1][@datatype=('uid','oid')]) then
                    attribute {$anme} {'1.2.3.999'}
                else if ($att[1][@datatype=('uuid')]) then
                    attribute {$anme} {'550e8400-e29b-41d4-a716-446655440000'}
                else if ($att[1][@datatype=('ruid')]) then
                    attribute {$anme} {'FsLo5xllxHinTYAGyEVldE'}
                else (
                    attribute {$anme} {'--TODO--'}
                )
            ,
            (: check element vocabulary :)
            if ($element/vocabulary[1]/@valueSet) then
                let $vsref     := $element/vocabulary[1]/@valueSet
                let $vsflex    := $element/vocabulary[1]/@flexibility
                let $valueSet  := vs:getExpandedValueSetByRef($vsref,$vsflex,$decor/project/@prefix)
                let $firstCode := ($valueSet//conceptList/concept[not(@type=('D','A'))])[1]
                return (
                    attribute code {$firstCode/@code},
                    (:this fails for e.g. hl7:statusCode without a datatype and vocabulary with @codeSystem:)
                    if (not(starts-with($element/@datatype,'CS'))) then ( 
                        attribute displayName {$firstCode/@displayName},
                        attribute codeSystem {$firstCode/@codeSystem}
                    )
                    else ()
                )
            else if ($element/vocabulary[1]/@code) then (
                $element/vocabulary[1]/@code,
                (:this fails for e.g. hl7:statusCode without a datatype and vocabulary with @codeSystem:)
                if (not(starts-with($element/@datatype,'CS'))) then (
                    $element/vocabulary[1]/@codeSystem,
                    $element/vocabulary[1]/@displayName
                ) else ()
            )
            else()
            ,
            if ($element[not(@contains)][not($attributes[@name='root' or @name='extension'])]/@datatype='II') then (
                attribute root {'1.2.3.999'},
                attribute extension {'--example only--'}
            )
            else ()
            ,
            if ($element[not(@contains)][not($attributes/@name='value')]/@datatype=('BL','BN')) then
                attribute value {'false'}
            else if ($element[not($attributes/@name='value')]/@datatype=('INT','INT.POS','INT.NONNEG')) then
                let $int := if ($element/property/@minInclude) then $element/property/@minInclude else (1)
                return
                attribute value {$int}
            else if ($element[not(@contains)][not($attributes/@name='value')]/@datatype=('REAL','REAL.POS','REAL.NONNEG')) then
                let $int            := if ($element/property/@minInclude) then $element/property/@minInclude else (1)
                let $intfrac        := tokenize($int,'\.')[2]
                let $fractionDigits := if ($element/property[1]/@fractionDigits[matches(.,'\d')]) then xs:integer(replace($element/property[1]/@fractionDigits,'!','')) else (0)
                let $intfracadd     := 
                    string-join(if (string-length($intfrac) lt $fractionDigits) then 
                        for $i in (1 to ($fractionDigits - string-length($intfrac)))
                        return '0'
                    else (),'')
                let $real           := concat($int,if (not(contains($int,'.')) and string-length($intfracadd)>0) then '.' else(),$intfracadd)
                return
                attribute value {$real}
            else if ($element[not(@contains)][not($attributes/@name='value')]/@datatype='TEL') then
                attribute value {'tel:+1-12345678'}
            else if ($element[not(@contains)][not($attributes/@name='value')]/@datatype='URL') then
                attribute value {'http:mydomain.org'}
            else if ($element[not(@contains)][not($attributes/@name='value')]/@datatype='TS') then
                attribute value {format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]','en',(),())}
            else if ($element[not(@contains)][not($attributes/@name='value')]/@datatype='TS.DATE') then
                attribute value {format-dateTime(current-dateTime(),'[Y0001][M01][D01]','en',(),())}
            else if ($element[not(@contains)][not(include|choice|element)]/@datatype='IVL_TS') then
                element low {attribute value {format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]','en',(),())}}
            else if ($element[not(@contains)][not($element/(include|choice|element))]/@datatype='PQ') then
                (attribute value {1}, $element/property[1]/@unit)
            else if ($element[not(@contains)][not($element/(include|choice|element))]/@datatype='IVL_PQ') then
                element low {attribute value {1}, $element/property[1]/@unit}
            else if ($element[not(@contains)][not($element/(include|choice|element))]/@datatype='MO') then
                (attribute value {1}, $element/property[1]/@currency)
            else if ($element[not(@contains)][not($element/(include|choice|element))]/@datatype='IVL_MO') then
                element low {attribute value {1}, $element/property[1]/@currency}
            else ()
            ,
            if ($element/text) then
                $element/text[1]/node()
            else ()
            ,
            if ($element[not(@contains|include|choice|element|text)]/@datatype=('EN','ON','PN','TN')) then
                $elmname
            else ()
            ,
            if ($element[not(@contains|include|choice|element|text)]/@datatype=('ADXP','ENXP','SC')) then
                $elmname
            else ()
            ,
            if ($element[not(@contains|include|choice|element|text)]/@datatype=('AD')) then
                $elmname
            else ()
            ,
            for $child in $element/(element|include|choice)
            return
                if ($child/self::element) then
                    local:processElement($child,$decor)
                else if ($child/self::include) then
                    local:processInclude($child,$decor)
                else if ($child/self::choice) then
                    local:processChoice($child,$decor)
                else ()
            ,
            if ($element[@contains]) then
                comment {concat(' template ',$element/@contains,' (',if ($element/@flexibility) then $element/@flexibility else ('dynamic'),') ')}
            else ()
        }
    else()
};

declare function local:processInclude($element as element(),$decor as element()) as item()* {
    if ($element/@selected and not($element/@conformance='NP')) then (
        '&#10;',
        comment {concat(' include template ',$element/@ref,' (',if ($element/@flexibility) then $element/@flexibility else ('dynamic'),') ', if ($element[@minimumMultiplicity or @maximumMultiplicity]) then concat($element/@minimumMultiplicity,'..',$element/@maximumMultiplicity,' ') else (),if ($element/@isMandatory='true') then 'M' else ($element/@conformance))}
    )
    else ()
};

declare function local:processChoice($element as element(),$decor as element()) as item()* {
    if ($element/@selected) then (
        '&#10;',
        comment {
            if ($element[@minimumMultiplicity or @maximumMultiplicity]) then
                concat(' choice min/max: ',$element/@minimumMultiplicity,'..',$element/@maximumMultiplicity,'&#10;')
            else (
                concat(' choice: &#10;')
            )
            ,
            for $child in $element/(element|include|choice)[@selected]
            return (
                if ($child/self::element) then (
                    concat('    element ',$child/@name,if ($child/@contains) then concat(' containing template ',$child/@contains,' (',if ($child/@flexibility) then $child/@flexibility else ('dynamic'),')') else (),'&#10;')
                )
                else if ($child/self::include) then
                    concat('    include template ',$child/@ref,' (',if ($element/@flexibility) then $element/@flexibility else ('dynamic'),') ','&#10;')
                else if ($child/self::choice) then
                    concat('    choice','&#10;')
                else ()
            )
        }
    )
    else ()
};

let $template   := if (request:exists()) then request:get-data()/template else ()
(:let $template   :=
<template id="2.16.840.1.113883.10.12.303" name="Lichaamslengte" displayName="Lichaamslengte" effectiveDate="2005-09-07T00:00:00" statusCode="new" versionLabel="" isClosed="false" baseId="2.16.840.1.113883.2.4.3.46.99.3.10" projectPrefix="demo-" conceptId="2.16.840.1.113883.2.4.3.46.99.3.2.19" conceptEffectiveDate="2013-04-02T14:47:48">
<desc language="en-US">
Template CDA Observation (prototype, directly derived from POCD_RM000040 MIF)
</desc>
<desc language="nl-NL">
Template CDA Observation (prototype, direct afgeleid uit POCD_RM000040 MIF)
</desc>
<desc language="de-DE">
Template CDA Observation (Prototyp, direkt abgeleitet aus POCD_RM000040 MIF)
</desc>
<classification type="cdaentrylevel"/>
<context id="**"/>
<example type="neutral" caption=""/>
<element name="hl7:observation" selected="" conformance="R" isMandatory="false">
<attribute classCode="OBS" isOptional="false" originalOpt="false" selected=""/>
<attribute name="moodCode" datatype="cs" isOptional="false" originalOpt="false" selected="">
<vocabulary valueSet="ActMoodDocumentObservation"/>
</attribute>
<attribute name="negationInd" datatype="bl" isOptional="true" originalOpt="true"/>
<element name="hl7:templateId" minimumMultiplicity="1" maximumMultiplicity="1" datatype="II" originalType="II" originalMin="1" originalMax="1" selected="" conformance="R" isMandatory="false">
<attribute root="2.16.840.1.113883.10.12.303" isOptional="false" originalOpt="false" selected=""/>
</element>
<element name="hl7:id" minimumMultiplicity="0" maximumMultiplicity="*" datatype="II" originalType="II" originalMin="0" originalMax="*" conformance="R" isMandatory="false"/>
<element name="hl7:code" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R" datatype="CD" originalType="CD" originalMin="1" originalMax="1" selected="" isMandatory="false">
<vocabulary code="50373000" codeSystem="2.16.840.1.113883.6.96"/>
<vocabulary code="8302-2" codeSystem="2.16.840.1.113883.6.1"/>
</element>
<element name="hl7:derivationExpr" minimumMultiplicity="0" maximumMultiplicity="1" datatype="ST" originalType="ST" originalMin="0" originalMax="1" conformance="R" isMandatory="false"/>
<element name="hl7:text" minimumMultiplicity="0" maximumMultiplicity="1" datatype="ED" originalType="ED" originalMin="0" originalMax="1" conformance="R" isMandatory="false"/>
<element name="hl7:statusCode" minimumMultiplicity="0" maximumMultiplicity="1" datatype="CS" originalType="CS" originalMin="0" originalMax="1" conformance="R" isMandatory="false">
<vocabulary valueSet="ActStatus"/>
</element>
<element name="hl7:effectiveTime" minimumMultiplicity="0" maximumMultiplicity="1" datatype="IVL_TS" originalType="IVL_TS" originalMin="0" originalMax="1" conformance="R" isMandatory="false"/>
<element name="hl7:priorityCode" minimumMultiplicity="0" maximumMultiplicity="1" datatype="CE" originalType="CE" originalMin="0" originalMax="1" conformance="R" isMandatory="false">
<vocabulary valueSet="ActPriority"/>
</element>
<element name="hl7:repeatNumber" minimumMultiplicity="0" maximumMultiplicity="1" datatype="IVL_INT" originalType="IVL_INT" originalMin="0" originalMax="1" conformance="R" isMandatory="false"/>
<element name="hl7:languageCode" minimumMultiplicity="0" maximumMultiplicity="1" datatype="CS" originalType="CS" originalMin="0" originalMax="1" conformance="R" isMandatory="false">
<vocabulary valueSet="HumanLanguage"/>
</element>
<element name="hl7:value" minimumMultiplicity="0" maximumMultiplicity="*" datatype="PQ" originalType="ANY" originalMin="0" originalMax="*" conformance="R" isMandatory="false" selected="" concept="">
<property unit="m" minInclude="0" maxInclude="3" fractionDigits="2"/>
<property unit="cm" minInclude="0" maxInclude="300" fractionDigits="0"/>
</element>
<element name="hl7:interpretationCode" minimumMultiplicity="0" maximumMultiplicity="*" datatype="CE" originalType="CE" originalMin="0" originalMax="*" conformance="R" isMandatory="false">
<vocabulary valueSet="ObservationInterpretation"/>
</element>
<element name="hl7:methodCode" minimumMultiplicity="0" maximumMultiplicity="*" datatype="CE" originalType="CE" originalMin="0" originalMax="*" conformance="R" isMandatory="false">
<vocabulary valueSet="ObservationMethod"/>
</element>
<element name="hl7:targetSiteCode" minimumMultiplicity="0" maximumMultiplicity="*" datatype="CD" originalType="CD" originalMin="0" originalMax="*" conformance="R" isMandatory="false">
<vocabulary valueSet="ActSite"/>
</element>
<element name="hl7:referenceRange" minimumMultiplicity="0" maximumMultiplicity="*" originalMin="0" originalMax="*" conformance="R" isMandatory="false">
<attribute typeCode="REFV" isOptional="false" originalOpt="false" selected=""/>
<element name="hl7:observationRange" minimumMultiplicity="1" maximumMultiplicity="1" originalMin="1" originalMax="1" selected="" conformance="R" isMandatory="false">
<attribute classCode="OBS" isOptional="false" originalOpt="false" selected=""/>
<attribute moodCode="EVN.CRT" isOptional="false" originalOpt="false" selected=""/>
<element name="hl7:code" minimumMultiplicity="0" maximumMultiplicity="1" datatype="CD" originalType="CD" originalMin="0" originalMax="1" conformance="R" isMandatory="false">
<vocabulary valueSet="ActCode"/>
</element>
<element name="hl7:text" minimumMultiplicity="0" maximumMultiplicity="1" datatype="ED" originalType="ED" originalMin="0" originalMax="1" conformance="R" isMandatory="false"/>
<element name="hl7:value" minimumMultiplicity="0" maximumMultiplicity="1" datatype="ANY" originalType="ANY" originalMin="0" originalMax="1" conformance="R" isMandatory="false"/>
<element name="hl7:interpretationCode" minimumMultiplicity="0" maximumMultiplicity="1" datatype="CE" originalType="CE" originalMin="0" originalMax="1" conformance="R" isMandatory="false">
<vocabulary valueSet="ObservationInterpretation"/>
</element>
</element>
</element>
</element>
</template>:)

let $decor      := $get:colDecorData//decor[project/@prefix=$template/@projectPrefix]

return
<example>
{
for $element in $template/(element|include|choice)
return
    if ($element/self::element) then (
        if (response:exists()) then
            util:serialize(local:processElement($element,$decor),'method=xml encoding=UTF-8')
        else (
            local:processElement($element,$decor)
        )
    )
    else if ($element/self::include) then
        if (response:exists()) then
            util:serialize(local:processInclude($element,$decor),'method=xml encoding=UTF-8')
        else (
            local:processInclude($element,$decor)
        )
    else if ($element/self::choice) then
        if (response:exists()) then
            util:serialize(local:processChoice($element,$decor),'method=xml encoding=UTF-8')
        else (
            local:processChoice($element,$decor)
        )
    else ()
}
</example>