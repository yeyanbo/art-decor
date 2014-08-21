xquery version "3.0";
(:~
:   Copyright (C) 2014-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Kai U. Heitmann
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)

import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../../../art/api/api-server-settings.xqm";
import module namespace templ    = "http://art-decor.org/ns/decor/template" at "../../../art/api/api-decor-template.xqm";
import module namespace msg      = "urn:decor:REST:v1" at "get-message.xquery";

(:declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=no";:)
(:declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=no indent=no 
        doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Transitional//EN
        doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd";:)

declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('http://art-decor.org/ADAR/rv/assets');

(: main proc :)
let $debug            := true()
let $format           := if (request:exists() and string-length(request:get-parameter('format','')[1])>0) then request:get-parameter('format','html')[1] else ('html')
let $language         := if (request:exists() and string-length(request:get-parameter('language','')[1])>0) then request:get-parameter('language',$get:strArtLanguage)[1] else ($get:strArtLanguage)

let $id               := if (request:exists() and string-length(request:get-parameter('id',())[1])>0) then request:get-parameter('id',())[1] else ()
let $name             := if (request:exists() and string-length(request:get-parameter('name',())[1])>0) then request:get-parameter('name',())[1] else ()
let $ref              := if (request:exists() and string-length(request:get-parameter('ref',())[1])>0) then request:get-parameter('ref',())[1] else ()

let $effectiveDate    := if (request:exists() and string-length(request:get-parameter('effectiveDate',())[1])>0) then request:get-parameter('effectiveDate',())[1] else ()
let $projectPrefix    := if (request:exists() and string-length(request:get-parameter('prefix',())[1])>0) then request:get-parameter('prefix',())[1] else ()

let $projectVersion   := if (request:exists() and string-length(request:get-parameter('version',())[1])>0) then request:get-parameter('version',())[1] else ()

let $htmlInline       := if (request:exists() and string-length(request:get-parameter('inline',())[1])>0) then request:get-parameter('inline',())[1] else ()
let $displayHeader    := if ($htmlInline='true') then xs:boolean('false') else xs:boolean('true')

let $artdecordeeplinkprefix := adserver:getServerURLArt()

let $decor            := $get:colDecorData/decor[project/@prefix=$projectPrefix]
let $templates        := 
    if ($projectPrefix and $ref) then
        templ:getExpandedTemplateByRef($ref, $effectiveDate, $projectPrefix, $projectVersion)
    else if ($projectPrefix and $id) then
        templ:getExpandedTemplateById($id, $effectiveDate, $projectPrefix, $projectVersion)
    else if ($projectPrefix and $name) then
        templ:getExpandedTemplateByName($name, $effectiveDate, $projectPrefix, $projectVersion)
    else ()

let $xsltParameters :=
    <parameters>
        <param name="projectDefaultLanguage" value="{$decor/project/@defaultLanguage}"/>
        <param name="artdecordeeplinkprefix" value="{$artdecordeeplinkprefix}"/>
        <param name="rand" value="128"/>
    </parameters>
    
return
    if ((string-length($id)=0 and string-length($name)=0 and string-length($ref)=0) or string-length($projectPrefix)=0) then
        if (request:exists()) then 
            (response:set-status-code(404), response:set-header('Content-Type','text/xml'), <error>{msg:getMessage('errorRetrieveTemplateNotEnoughParameters',$language),' ',
                if (request:exists()) then request:get-query-string() else()}</error>)
        else ''
    else if ($format = 'xml') then (
        if (request:exists()) then 
            response:set-header('Content-Type','text/xml')
        else ''
        ,
        $templates
    ) else (
        if (request:exists()) then
            response:set-header('Content-Type','text/html')
        else (),
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>{($templates//@name)[1]/string()}</title>
                <link href="{$resourcePath}/decor.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
            {
                transform:transform($templates, doc(concat($get:strDecorCore, '/Template2html.xsl')), $xsltParameters)
            }
            </body>
        </html>
    ) (: html :)