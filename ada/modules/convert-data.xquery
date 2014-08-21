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
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace xdb       = "http://exist-db.org/xquery/xmldb";
declare namespace util      = "http://exist-db.org/xquery/util";
declare namespace hl7       = "urn:hl7-org:v3";
declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

let $uuid := if (request:exists()) then request:get-parameter('id', '') else '92586026-99cf-4b2e-bc34-8b8b21ac243e'
let $app := if (request:exists()) then request:get-parameter('prefix', '') else 'counseling'
let $language := if (request:exists()) then request:get-parameter('language', '') else 'nl-NL'
let $doc := concat(ada:getUri($app, 'data'), $uuid, '.xml')
let $stylesheet := concat(ada:getUri($app, 'xslt'), 'main-templates.xsl')

let $result := adaxml:addHL7Data($doc, $stylesheet)
(: For the time being, store in /hl7 collection :)
let $store  := xmldb:store(ada:getUri($app, 'hl7'), concat($uuid, '.xml'), adaxml:getDocument($doc)//hl7data/*)
return $result