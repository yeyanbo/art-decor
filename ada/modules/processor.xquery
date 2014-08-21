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

import module namespace ada ="http://art-decor.org/ns/ada-common" at "../../../modules/ada-common.xqm";
import module namespace adaxml ="http://art-decor.org/ns/ada-xml" at "../../../modules/ada-xml.xqm";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace xmldb       = "http://exist-db.org/xquery/xmldb";
declare namespace util      = "http://exist-db.org/xquery/util";

let $uuid := if (request:exists()) then request:get-parameter('id', '') else '0c8dbaeb-ae33-4164-978e-ed21738c4f1a'
let $prefix := if (request:exists()) then request:get-parameter('prefix', '') else 'rivmsp-'
let $language := if (request:exists()) then request:get-parameter('language', '') else 'nl-NL'

let $config := doc('../ada-config.xml')/config/chain[@name='mdl-1']
let $docUri := concat(ada:getUri($prefix, 'data'), $uuid, '.xml')
let $doc := ada:getDocument($docUri)
let $docVersion := data($doc/adaxml/data/*/@versionDate)
let $docTransactionId := data($doc/adaxml/data/*/@transactionRef)
let $transactionId := data($config/definition/@transactionId)
let $transactionEffectiveDate := data($config/definition/@transactionEffectiveDate )
let $definitions := doc(data($config/definition/@file))
let $dataset := $definitions//transactionDatasets/dataset[@transactionId=$transactionId][@transactionEffectiveDate=$transactionEffectiveDate]
for $step in $config/step
    let $result := 
        if ($step/@name = 'add-codes')
        then
            let $dataWithCode := adaxml:addCode($doc//data/*, $dataset)
            let $update := update replace $doc/adaxml/data/* with $dataWithCode
            let $step := adaxml:makeStep('complete', 'add-code', ())
            return adaxml:addStep($doc, $step, false())
        else if ($step/@name = 'validate')
        then
            let $schema := $step/@schema
            let $step := adaxml:validateSchema($docUri, $schema)
            return adaxml:addStep($doc, $step, false())
        else if ($step/@name = 'convert')
        then
            let $stylesheet := $step/@stylesheet
            let $step := adaxml:addHL7Data($docUri, $stylesheet)
            return adaxml:addStep($doc, $step, false())
        else ()
    return $result