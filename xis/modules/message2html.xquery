xquery version "1.0";
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

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace xis       = "http://art-decor.org/ns/xis";
declare namespace hl7       = "urn:hl7-org:v3";
declare option exist:serialize "method=xhtml media-type=text/html";

let $account            := request:get-parameter('account',())
let $fileName           := xmldb:encode(request:get-parameter('file',()))

(:
    there two types of calls here. 
  - file name only, which should render a message in the captured messages under the test account
  - full path, which should render a message, normally in the HL7 package directory
:)
let $fileName           := 
    if (contains($fileName,'/')) then
        $fileName
    else (
        concat($get:strXisAccounts, '/',$account,'/messages/',$fileName)
    )

(:
    Optionally we may be called based on the message-id or ClinicalDocument/id inside that file
:)
let $root               := request:get-parameter('root',())[string-length()>0]
let $extension          := request:get-parameter('extension',())[string-length()>0]


let $configuration      := doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:xis
let $resourcesPath      := $configuration/xis:xmlResourcesPath/text()

let $xsltParametersCDA  := ()
let $xsltParameters     :=
    <parameters>
        <param name="vocabPath" value="{concat($resourcesPath,'/vocab/')}"/>
    </parameters>

(: 
    need to login because user credentials are not passed with call
    This login change pertains only to messages under an account, not for HL7 package file
:)
let $login              := xmldb:login("/db", "xis-webservice", "webservice-xs2messages")

let $messages           := 
    if (doc-available($fileName)) then doc($fileName)//*[hl7:interactionId or self::hl7:ClinicalDocument] else ()
let $message            := 
    if (string-length($root)=0)
    then ($messages)
    else if (string-length($extension)=0)
    then ($messages[hl7:id[@root=$root]])
    else ($messages[hl7:id[@root=$root][@extension=$extension]])

return
    if (count($message) != 1) then (
        <html>
        <head>
            <title>Rendering error</title>
            <style type="text/css" media="print, screen">
               body {{
                  font-family:Verdana;
                  font-size:10px;
               }}
            </style>
        </head>
        <body>
            <h3>Error rendering message. Can only render exactly one message at a time. Found {count($message)} in {$fileName} with root={$root} and extension={$extension}</h3>
        </body>
        </html>
    )
    else if ($message/self::hl7:ClinicalDocument) then (
        transform:transform($message, xs:anyURI(concat('xmldb:exist://',$get:strCdaXsl)), $xsltParametersCDA)
    ) 
    else (
        transform:transform($message, xs:anyURI(concat('xmldb:exist://',$get:strXisResources,'/stylesheets/message2html.xsl')), $xsltParameters)
    )
