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
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

let $account        := request:get-parameter('account','')
let $file           := request:get-parameter('file','')
(:let $file := 'XK_HAPIS1_REPC_IN990003NL_555555112_bijlage XI.xml':)
let $collection     := concat($get:strXisAccounts, '/',$account,'/messages')
let $reports        := concat($get:strXisAccounts, '/',$account,'/reports')
let $attachments    := concat($get:strXisAccounts, '/',$account,'/attachments')

let $removeMain     := 
    if (util:binary-doc-available(concat($collection,'/',xmldb:encode-uri($file))) or doc-available(concat($collection,'/',xmldb:encode-uri($file)))) then
        xmldb:remove($collection,xmldb:encode-uri($file))
    else ()
let $removeMain     := 
    if (util:binary-doc-available(concat($reports,'/',xmldb:encode-uri($file))) or doc-available(concat($reports,'/',xmldb:encode-uri($file)))) then
        xmldb:remove($reports,xmldb:encode-uri($file))
    else ()
return
    if (xmldb:collection-available($attachments)) then (
        for $child in xmldb:get-child-resources($attachments)
        return
            if (matches($child,concat($file,'_[0-9]+'))) then (
                xmldb:remove($attachments,xmldb:encode-uri($child))
            ) else ()
    ) else ()