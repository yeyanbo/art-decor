xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at  "art-decor.xqm";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace xdb = "http://exist-db.org/xquery/xmldb";
declare namespace hl7 = "urn:hl7-org:v3";
declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

let $collection := $get:colDecorData
let $projectPrefix := if (request:exists()) then request:get-parameter('prefix','') else 'rivmsp-' 
(:let $projectPrefix := 'peri20-':)
let $decor := $collection//project[@prefix=$projectPrefix]/ancestor::decor
let $valueSets := art:currentValuesets($decor)
let $allTerminologyAssociations := $decor//terminologyAssociation

return 
if ($projectPrefix= '') then (
    if (request:exists()) then (response:set-status-code(404), response:set-header('Content-Type','text/xml; charset=utf-8'), <error>Missing parameter 'prefix'</error>) else ()
)
else (
    if (request:exists()) then response:set-header('Content-Type','text/xml; charset=utf-8') else (),
    <terminologyAssociations prefix="{$projectPrefix}">{
    for $valueSet in $valueSets
    for $terminologyAssociation in $allTerminologyAssociations[@valueSet=$valueSet/@name or @valueSet=$valueSet/@id]
    for $conceptList in $decor//dataset//conceptList[(@id|@ref) = $terminologyAssociation/@conceptId][not(ancestor::history)]
    return 
        (  (:$terminologyAssociation, $valueSet, $conceptList,:)
            for $vsConcept in $valueSet/conceptList/concept
                for $dsConcept in $conceptList/concept
                where $vsConcept/@displayName = $dsConcept/name
                return 
                    if ($dsConcept/@id and not($allTerminologyAssociations[@conceptId=$dsConcept/@id][@code=$vsConcept/@code][@codeSystem=$vsConcept/@codeSystem])) 
                    then <terminologyAssociation conceptId="{$dsConcept/@id}" code="{$vsConcept/@code}" codeSystem="{$vsConcept/@codeSystem}"/> else ()
        )
    }</terminologyAssociations>
)
