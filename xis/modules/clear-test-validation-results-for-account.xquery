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
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace hl7="urn:hl7-org:v3";
declare namespace util = 'http://exist-db.org/xquery/util';
declare namespace xis ="http://art-decor.org/ns/xis";
declare namespace xdb = "http://exist-db.org/xquery/xmldb"; 
declare option exist:serialize "indent=no";
declare option exist:serialize "omit-xml-declaration=no";

let $account     := if (request:exists()) then request:get-parameter('account','') else 'rivmsp-graauw'
let $accountPath := concat($get:strXisAccounts, '/', $account)
let $attachments := concat($get:strXisAccounts, '/', $account, '/attachments')
let $reports     := concat($get:strXisAccounts, '/', $account, '/reports')
let $testseries  := concat($get:strXisAccounts, '/', $account, '/testseries.xml')

let $result := 
    try {
        let $dummy := update delete doc($testseries)//validationReport
        let $dummy := update delete doc($testseries)//messageFile
        let $dummy := update replace doc($testseries)//xis:validation/@statusCode with ''
        let $dummy := update replace doc($testseries)//xis:validation/@dateTime with ''
        let $dummy := 
            if (xmldb:collection-available($reports)) then (
                for $doc in xmldb:get-child-resources($reports) return xmldb:remove($reports, $doc)
            ) else ()
        let $dummy :=
            if (xmldb:collection-available($attachments)) then (
                for $doc in xmldb:get-child-resources($attachments) return xmldb:remove($attachments, $doc)
            ) else()
        return 
            <result>OK</result>
    } 
    catch * {
        <error>ERROR {$err:code} deleting results: {$err:description, "', module: ", $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</error>
    }
return $result