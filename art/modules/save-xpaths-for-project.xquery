xquery version "3.0";
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
import module namespace artx ="http://art-decor.org/ns/art/xpath" at  "art-decor-xpath.xqm";

declare namespace lab="urn:oid:2.16.840.1.113883.2.4.6.10.35.81";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace hl7="urn:hl7-org:v3";
declare namespace util = 'http://exist-db.org/xquery/util';
declare namespace xis="http://art-decor.org/ns/xis";
declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare option exist:serialize "indent=no";
declare option exist:serialize "omit-xml-declaration=no";

let $nl := "&#10;"
let $tab := "&#9;"
let $collection := $get:colDecorData

let $projectPrefix := if (request:exists()) then request:get-parameter('prefix','') else 'peri20-' 
let $dataset := if (request:exists()) then request:get-parameter('dataset','') else '2.16.840.1.113883.2.4.3.11.60.90.77.1.5'
let $lang := if (request:exists()) then request:get-parameter('lang','nl-NL') else 'nl-NL' 
let $version := if (request:exists()) then request:get-parameter('version','') else '2014-02-17T14:55:13'

let $decor := 
    if ($version)
    then $get:colDecorVersion//decor[project[@prefix=$projectPrefix]][@versionDate=$version][empty($lang) or @language=$lang][1]
    else $get:colDecorData//decor[project[@prefix=$projectPrefix]]

let $representingTemplates := 
    if ($dataset = '') then $decor//representingTemplate else $decor//representingTemplate[@sourceDataset=$dataset]

let $allXpaths :=
    <xpaths status="draft" version="{max($decor/project/(version|release)/xs:dateTime(@date))}" generated="{current-dateTime()}">{
        for $representingTemplate in $representingTemplates
        return artx:getXpaths($decor, $representingTemplate)
    }</xpaths>
    
let $path := concat('xmldb:exist://', util:collection-name($decor), '/')
let $runtimedir := 'resources/'
let $dummy := if (not(xmldb:collection-available(concat($path, $runtimedir))))
    then xmldb:create-collection($path, $runtimedir) 
    else ()
    
let $xpathFile := 
    if (empty(doc(concat($path, $runtimedir, $projectPrefix, 'xpaths.xml')))) 
    then xdb:store(concat($path, $runtimedir), concat($projectPrefix, 'xpaths.xml'), <projectXpaths/>)
    else concat($path, $runtimedir, $projectPrefix, 'xpaths.xml')
let $update := update insert $allXpaths into doc($xpathFile)/projectXpaths
(:let $xpath-file := xdb:store(concat($path, $runtimedir), concat($projectPrefix, 'xpaths.xml'), $allXpaths, '.xml'):) 
return $allXpaths