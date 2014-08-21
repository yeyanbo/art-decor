xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw

    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
import module namespace art = "http://art-decor.org/ns/art" at "../../art/modules/art-decor.xqm";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace xmldb     = "http://exist-db.org/xquery/xmldb";
declare namespace output    = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option output:media-type "text/javascript";

(: get data and eliminate undesired tokens from displayNames :)
declare function local:attText($att as attribute()) as xs:string {
    translate(data($att), "'", "")
};

let $nl             := "&#10;"
let $language       := if (request:exists()) then request:get-parameter('language', '') else ''
let $prefix         := if (request:exists()) then request:get-parameter('prefix',()) else 'peri20-'
let $id             := if (request:exists()) then request:get-parameter('id', '') else '2.16.840.1.113883.2.4.6.10.90.70'
let $dataset        := if (request:exists()) then request:get-parameter('dataset', '') else ''

let $decor          := collection('/db/apps/decor/data')//decor[project/@prefix=$prefix]
let $language       := if ($language = '') then data($decor/project/@defaultLanguage) else $language
let $dataset        := if ($dataset) then $dataset else $decor//dataset[last()]/@id/string()
let $conceptList    := 
    for $concept in $decor//dataset[@id=$dataset]//concept[not(ancestor::history)][not(parent::conceptList)]
    return 
        <concept>
        {
            $concept/@*, 
            if ($concept/inherit) then (
                let $orig := art:getOriginalConceptName($concept/inherit) 
                return 
                    if ($orig/name[@language=$language]) then $orig/name[@language=$language] else ($orig/name[1])
            ) 
            else (
                if ($concept/name[@language=$language]) then $concept/name[@language=$language] else ($concept/name[1])
            ),
            <parent>{
                if ($concept/../inherit) then (
                    let $orig := art:getOriginalConceptName($concept/../inherit) 
                    return 
                        if ($orig/name[@language=$language]) then $orig/name[@language=$language] else ($orig/name[1])
                ) 
                else (
                    if ($concept/../name[@language=$language]) then $concept/../name[@language=$language] else ($concept/../name[1])
                )
            }</parent>
        }
        </concept>
let $baseIds    := string-join(
        for $baseId in $decor/ids/baseId[@type='TM']
        let $defaultBaseId := $baseId/../defaultBaseId[@id=$baseId/@id] | $baseId[@default='true']
        let $defaultText   := if ($defaultBaseId) then ' (default)' else ()
        return concat("{ text : '", '"', $baseId/@id, '.new"', "', displayText: '", $baseId/@id, $defaultText, "'}")
    ,', ')

let $javascript := (
    'var effectiveDates = [ { text: ', concat("'", '"', substring(xs:string(current-dateTime()), 1, 19), '"', "'"), ', displayText : "now"},'
     ,$nl, '{text: ', concat("'", '"', substring(xs:string(current-dateTime()), 1, 11), '00:00:00"', "'"), ', displayText : "today"},'
     ,$nl, for $effectiveDate in distinct-values($decor//template/@effectiveDate) order by $effectiveDate descending 
      return concat("{ text : '", '"', $effectiveDate, '"', "', displayText: '", $effectiveDate, "'},", $nl)
    ,'{text : "---", displayText : "---"}];'
    ,
    $nl,
    'var projectValuesets = [',
    for $valuesetName in fn:distinct-values($decor/terminology//valueSet/@name)
        (:let $effectiveDates := 
        for $effectiveDate in $decor/terminology//valueSet[@name=$valuesetName]/@effectiveDate 
        return concat(" effectiveDate: '", data($effectiveDate), "'")
        :)
    order by $valuesetName ascending
        (:return concat("{ text : '", '"', $valuesetName, '"', "', displayText: '", $valuesetName, "', effectiveDates : {", fn:string-join($effectiveDates, ','), " }},", $nl):)
    return (
        concat("{ text : '", '"', $valuesetName, '"', "', displayText: '", $valuesetName, " (dynamic)'},", $nl),
        for $valueset in $decor/terminology//valueSet[@name=$valuesetName][@effectiveDate]
        order by $valueset/@effectiveDate descending
        return concat("{ text : '", '"', $valuesetName, '" flexibility="', $valueset/@effectiveDate, '"', "', displayText: '", $valuesetName, " (", $valueset/@effectiveDate, ")'},", $nl)
    )
    ,'{text : "---", displayText : "---"}];',
    $nl,
    'var projectTemplates = [',
    for $templateName in distinct-values($decor//template/@name)
    order by $templateName ascending
    return (
        concat("{ text : '", '"', $templateName, '"', "', displayText: '", $templateName, " (dynamic)'},", $nl),
        for $template in $decor//template[@name=$templateName]
        order by $template/@effectiveDate descending
        return concat("{ text : '", '"', $templateName, '" flexibility="', $template/@effectiveDate, '"', "', displayText: '", $templateName, " (", $template/@effectiveDate, ")'},", $nl)
    )
    ,
    '{text : "---", displayText : "---"}];',
    $nl,
    'var projectIds = [',
    for $id in $decor//ids/id
    order by $id/designation[1]/@displayName ascending
    return concat("{ text : '", '"', data($id/@root), '"', "', displayText: '", local:attText($id/designation[1]/@displayName), "'},", $nl)
    ,
    '{text : "---", displayText : "---"}];',
    $nl,
    'var projectConcepts = [',
    for $concept in $conceptList
    order by $concept/name ascending, $concept/@effectiveDate descending
    return concat("{ text : '", '"', data($concept/@id), '" effectiveDate="', $concept/@effectiveDate, '"', "', displayText: '", art:shortName($concept/name[1]), " (", $concept/@effectiveDate, ") -- ", art:shortName($concept/parent/name[1]), "'},", $nl)
    ,
    '{text : "---", displayText : "---"}];',
    $nl,
    'var baseIds = [',$baseIds,'];',
    $nl,
    'var elementIds = [',
    if ($id='') then '' else for $num in (1 to 9)
    return concat('"', $id, '.', $num, '", ')
    ,'""];'
    )
return $javascript