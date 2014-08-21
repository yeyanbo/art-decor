(:
    Copyright (C) 2013-2014  Marc de Graauw
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
xquery version "3.0";

import module namespace ada ="http://art-decor.org/ns/ada-common" at "ada-common.xqm";
import module namespace adaxml ="http://art-decor.org/ns/ada-xml" at "ada-xml.xqm";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace xmldb       = "http://exist-db.org/xquery/xmldb";
declare namespace util      = "http://exist-db.org/xquery/util";

let $uuid := if (request:exists()) then request:get-parameter('id', '') else '0c8dbaeb-ae33-4164-978e-ed21738c4f1a'
let $prefix := if (request:exists()) then request:get-parameter('prefix', '') else 'rivmsp-'
let $language := if (request:exists()) then request:get-parameter('language', '') else 'nl-NL'

let $doc := doc(concat(ada:getUri($prefix, 'data'), $uuid, '.xml'))
let $version := data($doc/adaxml/data/*/@versionDate)
let $transactionId := data($doc/adaxml/data/*/@transactionRef)
let $dataset := doc(concat(ada:getUri($prefix, 'definitions'), $prefix, translate($version, '-:', ''), '-', $language, '-ada-release.xml'))//transactionDatasets/dataset[@transactionId=$transactionId]
let $data := adaxml:addConceptId($doc/adaxml/data/*, $dataset)
let $dataWithLocalId := adaxml:addLocalId($data, $dataset)
let $dataWithCode := adaxml:addCode($dataWithLocalId, $dataset)
let $status := 'beautified'
(:let $step := 
    <step status-before="{$doc/adaxml/meta/@status}" status-after="{$status}" time="{fn:current-dateTime()}">
        {
        element data-before {$doc/adaxml/data}
        }
    </step>
:)
let $step := 
    <step status-before="{$doc/adaxml/meta/@status}" status-after="{$status}" time="{fn:current-dateTime()}"/>
let $update := update insert $step into $doc/adaxml/meta
let $update := update replace $doc/adaxml/meta/@status with $status
let $update := update replace $doc/adaxml/data/* with $dataWithCode
return 
    element adaxml {$doc/*/@*, $doc/*/meta, element data {$dataWithCode}}