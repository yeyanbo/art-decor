xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket
    
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

declare variable $acceptMediaType   := ('text/xml','application/xml');

(:<content xsi:type="xs:base64Binary" mediatype="" filename="" size=""/>:)
let $account            := if (request:exists()) then (request:get-parameter('account',())) else ()
let $filecontent        := if (request:exists()) then (request:get-data()/content) else ()
let $filename           := $filecontent/@filename
let $mediatype          := $filecontent/@mediatype
let $size               := $filecontent/@size
let $messageStoragePath := concat($get:strXisAccounts, '/',$account,'/messages')

let $return             :=
    if (not(xmldb:collection-available($messageStoragePath))) then
        error(QName('http://art-decor.org/ns/error', 'AccountDoesNotExist'), concat('This account does not exist: ',$account))
    else if (not($mediatype = $acceptMediaType)) then 
        error(QName('http://art-decor.org/ns/error', 'UnsupportedFileType'), concat('File must be an XML file with media type ',$acceptMediaType,'. Found ',$mediatype))
    else (
        (:...:)
    )

let $data-safe          :=
    if (not(empty($account) or empty($filecontent))) then
        (:Hack alert: upload fails when content has UTF-8 Byte Order Marker. the UTF-8 representation of the BOM is the byte sequence 0xEF,0xBB,0xBF:)
        let $filecontent    := util:base64-decode($filecontent)
        let $content-no-bom := if (string-to-codepoints(substring($filecontent,1,1))=65279) then (substring($filecontent,2)) else ($filecontent)
        let $login          := xmldb:login("/db", "xis-webservice", "webservice-xs2messages")
        let $store          := xmldb:store($messageStoragePath, encode-for-uri($filename), $content-no-bom)
        return true()
    else (
        false()
    )

return
<data-safe>{$data-safe}</data-safe>