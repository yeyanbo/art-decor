xquery version "3.0";
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
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
declare namespace request = "http://exist-db.org/xquery/request";

declare variable $acceptMaxBytes    := 500000;
declare variable $acceptMediaType   := '^image/.*';

declare function local:storeLogo($decor as element(decor), $projectPrefix as xs:string, $mediaType as xs:string?, $filename as xs:string, $filecontent as xs:base64Binary) as element() {

let $basecollection     := util:collection-name($decor)
let $logoscollection    := concat($projectPrefix,'logos')
let $fullcollection     := concat($basecollection,'/',$logoscollection)

let $return             :=
    if (xmldb:collection-available($fullcollection)) then () else (
        let $coll   := xmldb:create-collection($basecollection,$logoscollection)
        return
        (:sm:chown(xs:anyURI(concat('xmldb:exist://',$fullcollection)),'admin:decor'),:)
        sm:chgrp(xs:anyURI(concat('xmldb:exist://',$coll)),'decor'),
        sm:chmod(xs:anyURI(concat('xmldb:exist://',$fullcollection)),sm:octal-to-mode('0775')),
        sm:clear-acl(xs:anyURI(concat('xmldb:exist://',$fullcollection)))
    )

let $return             :=
    if (string-length($mediaType)>0) then
        xmldb:store($fullcollection, $filename, $filecontent, $mediaType)
    else (
        xmldb:store($fullcollection, $filename, $filecontent)
    )

let $return             :=
    (
        (:sm:chown(xs:anyURI(concat('xmldb:exist://',$return)),'admin:decor'),:)
        sm:chgrp(xs:anyURI(concat('xmldb:exist://',$return)),'decor'),
        sm:chmod(xs:anyURI(concat('xmldb:exist://',$return)),sm:octal-to-mode('0775')),
        sm:clear-acl(xs:anyURI(concat('xmldb:exist://',$return)))
    )

return
    <data-safe filename="{$filename}">true</data-safe>
};

(:<content xsi:type="xs:base64Binary" mediatype="" filename="" size=""/>:)
let $projectPrefix      := if (request:exists()) then (request:get-parameter('project',())) else ()
let $filecontent        := if (request:exists()) then (request:get-data()/content) else ()
let $filename           := $filecontent/@filename
let $mediatype          := $filecontent/@mediatype
let $size               := $filecontent/@size
let $decor              := $get:colDecorData//decor[project/@prefix=$projectPrefix]

let $return             :=
    if ($size castable as xs:integer and xs:integer($size) > 500000) then
        error(QName('http://art-decor.org/ns/error', 'FileTooBig'), concat('File must be less than ',$acceptMaxBytes,'Bytes. Got: ',$size))
    else if (not(matches($mediatype,$acceptMediaType))) then 
        error(QName('http://art-decor.org/ns/error', 'UnsupportedFileType'), concat('File must be a web supported image. Found ',$mediatype))
    else (
        (:...:)
    )

return
    local:storeLogo($decor,$projectPrefix,$mediatype,$filename,$filecontent)