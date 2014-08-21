xquery version "3.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers
	
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
declare namespace soap="http://schemas.xmlsoap.org/soap/envelope/";
declare namespace hl7="urn:hl7-org:v3";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xis="http://art-decor.org/ns/xis";

(: Log debug messages? :)
let $debug             := true()

(: account :)
let $account           := if (request:exists()) then request:get-parameter('account',()) else()
(: file name :)
let $file              := if (request:exists()) then request:get-parameter('file',()) else()
(: xpath to fragment :)
let $xpath             := if (request:exists()) then request:get-parameter('xpath',()) else()
(: Message-id/@root      -- only works for HL7 :)
(:let $root              := if (request:exists()) then request:get-parameter('root',('')) else():)
(: Message-id/@extension -- only works for HL7 :)
(:let $extension         := if (request:exists()) then request:get-parameter('extension',('')) else():)

(:let $root      := '2.16.840.1.113883.2.4.6.6.42'
let $extension := 'df3cc36b-0517-4af4-b9a9-d3dae2fdca17':)

(:let $g := if ($debug) then (util:log('DEBUG', concat('============ Supplied parameters: file=',$file,' root=',$root,' extension=',$extension))) else ():)
let $g := if ($debug) then (util:log('DEBUG', concat('===(RetrieveMessage)=== Supplied parameters: account=',$account, 'file=',$file,' xpath=',$xpath))) else ()

(: Messages are normally only located in the collection xis/<account>/messages/. Get the resource (file). 
   Then return the requested fragment of that file based on the provided xpath expression, or the full contents if
   xpath is empty
:)

(: Read account option to switch xml display off :)
let $getMessageXmlOff := 
    if (not(empty($account))) then
        exists(doc($get:strTestAccounts)//xis:testAccount[@name=$account]//xis:getMessageXml[string(.)='false'])
    else (false())

(: write the $getMessageXmlOff to exist log :)
let $g                  := util:log('DEBUG', concat('---($getMessageXmlOff)--- Is xis display on (switch=false=default) or off (switch=true) ', $getMessageXmlOff))

let $strFile := 
    if (not(empty($account) or empty($file))) then
        concat($get:strXisAccounts,'/',$account,'/messages/',encode-for-uri($file))
    else ()

let $messages := 
    try {
        if ($getMessageXmlOff) then (
            <result>Message retrieval switched off for this account. {$account}</result>
        )
        else if (not(doc-available($strFile))) then (
            <result>Message could not be found. Account {$account}, File {$file}</result>
        )
        else (
           if (string-length($xpath)>0) then (
                doc($strFile)//*[util:node-xpath(.)=$xpath]
           ) else (
                doc($strFile)/*
           )
       )
    }
    catch * {
        <issue type="message" role="error">
            <description>ERROR (RetrieveMessage) {$err:code} in retrieval of message from file '{$file}' with xpath '{$xpath}': 
            {$err:description, "', module: ", $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</description>
            <location line=""/>
        </issue>
    }

let $g := if ($debug) then (util:log('DEBUG', concat('===(RetrieveMessage)=== Message instance found? ',count($messages)))) else ()

return
<message>
{
    for $message in $messages
    return
        $message
}
</message>