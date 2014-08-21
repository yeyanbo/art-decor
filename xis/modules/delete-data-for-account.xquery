xquery version "3.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Marc de Graauw, Maarten Ligtvoet
	
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

let $input-account    := if (request:exists()) then request:get-parameter('account','') else 'test'
(: only allow characters that are in a whitelist :)
let $filter-account   := replace($input-account, "[^0-9a-zA-Z-_]", "")
let $collection       := if($filter-account) then xs:anyURI(concat($get:strXisAccounts, '/', $filter-account)) else ('account_not_writable')
(: does this path exist and is writable for this user? :)
let $account          := if(xmldb:collection-available($collection)) then (if (sm:has-access($collection,"w")) then $collection else 'account_not_writable') else 'account_not_writable'
let $attachments      := concat($account, '/attachments')
let $messages         := concat($account, '/messages')
let $reports          := concat($account, '/reports')

let $result := 
    if (not(matches($account,'account_not_writable'))) then (
        try {
            let $dummy := 
                if (xmldb:collection-available($attachments)) then (
                    for $doc in xmldb:get-child-resources($attachments) 
                    return xmldb:remove($attachments, $doc)
                ) else ()
            let $dummy := 
                if (xmldb:collection-available($messages)) then (
                    for $doc in xmldb:get-child-resources($messages) return xmldb:remove($messages, $doc)
                ) else ()
            let $dummy := 
                if (xmldb:collection-available($reports)) then (
                    for $doc in xmldb:get-child-resources($reports) return xmldb:remove($reports, $doc)
                ) else ()
            return 
                <result>OK</result>
        } 
        catch * {
            <error>ERROR {$err:code} deleting results: {$err:description, "', module: ", $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</error>
        }
    )
    else 
    (
        let $error := <error>ERROR: account not writable</error>
        let $g := util:log('ERROR', concat('---------- xis: delete-data-for-account.xquery: ',$error))
        return ($error)
    )
return $result