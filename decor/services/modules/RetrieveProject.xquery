(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket
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
import module namespace comp     = "http://art-decor.org/ns/art-decor-compile" at "../../../art/api/api-decor-compile.xqm";
import module namespace msg      = "urn:decor:REST:v1" at "get-message.xquery";
import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../../../art/api/api-server-settings.xqm";

declare variable $useLocalAssets      := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath        := if ($useLocalAssets = 'true') then ('../assets') else ('resources');


declare function local:addCacheAttributes($decorproject as element()?) as element()? {
    if ($decorproject) then (
        <decor>
        {
            (: hack alert. This forces the serializer to write our 'foreign' namespace declarations. Reported on the exist list :)
            for $ns-prefix at $i in in-scope-prefixes($decorproject)[not(.=('xml'))]
            let $ns-uri := namespace-uri-for-prefix($ns-prefix, $decorproject)
            return
                attribute {QName($ns-uri,concat($ns-prefix,':dummy-',$i))} {$ns-uri}
            ,
            $decorproject/@*,
            if (string-length(adserver:getServerURLArt())>0) then 
                attribute deeplinkprefix {adserver:getServerURLArt()}
            else (),
            if (string-length(adserver:getServerURLServices())>0) then 
                attribute deeplinkprefixservices {adserver:getServerURLServices()}
            else (),
            $decorproject/node()
        }
        </decor>
    )
    else ()
};

(: mode determines whether or not you want the project to be returned as-is or with resolved references
   'verbatim' gets the project as-is
   'cache' gets the project as-is, but adds decor/@deeplinkprefix and decor/@deeplinkprefixservices for linkback
   'compiled' tries to make this project self-contained by getting referenced content from other projects/repositories into the current project
   'test' retrieves the filters that would be applied when compiled
:)
let $format           := 'xml'
let $mode             := if (request:exists() and string-length(request:get-parameter('mode','verbatim')[1])>0) then request:get-parameter('mode','verbatim')[1] else ('verbatim')
let $language         := if (request:exists() and string-length(request:get-parameter('language',())[1])>0) then request:get-parameter('language',())[1] else ()
let $id               := if (request:exists() and string-length(request:get-parameter('id',())[1])>0) then request:get-parameter('id',())[1] else ()
let $name             := if (request:exists() and string-length(request:get-parameter('name',())[1])>0) then request:get-parameter('name',())[1] else ()
let $projectPrefix    := if (request:exists() and string-length(request:get-parameter('prefix',())[1])>0) then request:get-parameter('prefix',())[1] else ()

let $download         := if (request:exists()) then request:get-parameter('download',('false')) else ('false')

let $decorproject     := 
    if (not(empty($projectPrefix))) then 
        collection($get:strDecorData)//decor[project[@prefix=$projectPrefix]]
    else if (not(empty($id))) then
        collection($get:strDecorData)//decor[project[@id=$id]]
    else if (not(empty($name))) then
        collection($get:strDecorData)//decor[project[name[matches(.,$name)]]]
    else ()

let $now              := datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")
let $language         := if (count($decorproject)=1 and empty($language)) then $decorproject/project/@defaultLanguage/string() else ($language)
let $filenameverbatim := if (count($decorproject)=1) then concat(string-join(tokenize(util:document-name($decorproject),'\.')[position()!=last()],'.'),'-',replace($now,':',''),'-',$language,'.xml') else ()
let $filenamecompiled := if (count($decorproject)=1) then concat(string-join(tokenize(util:document-name($decorproject),'\.')[position()!=last()],'.'),'-',replace($now,':',''),'-',$language,'-compiled.xml') else ()
let $filenamecached   := if (count($decorproject)=1) then concat(string-join(tokenize(util:document-name($decorproject),'\.')[position()!=last()],'.'),'-',replace($now,':',''),'-',$language,'-cached.xml') else ()
let $filters          := if (count($decorproject)=1 and $mode=('compiled','test')) then comp:getCompilationFilters($decorproject) else ()

return 
    if (empty($decorproject)) then (
        (:response:set-status-code(404), <error>{msg:getMessage('errorRetrieveProjectNoResults',$language),' ',if (request:exists()) then request:get-query-string() else()}</error>:)
        response:set-header('Content-Type','text/html; charset=utf-8'),
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>RetrieveProject</title>
                <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
                <h1>RetrieveProject</h1>
                <div class="content">
                <form name="input" action="/decor/services/RetrieveProject" method="get">
                    <table border="0">
                        <tr>
                            <td>Project:</td>
                            <td>
                                <select name="prefix" style="width: 300px;">
                                {
                                    for $p in $get:colDecorData//decor/project
                                    order by lower-case($p/name[1])
                                    return
                                        <option value="{$p/@prefix}">{$p/name[1],' (',$p/@defaultLanguage/string(),')'}</option>
                                }
                                </select> (*)
                            </td>
                        </tr>
                        <tr>
                            <td>Get project as-is (verbatim), with references resolved (compiled) or just retrieve filters (test):</td>
                            <td>
                                <select name="mode" style="width: 300px;">
                                    <option value="verbatim">verbatim</option>
                                    <option value="compiled">compiled</option>
                                    <option value="test">test</option>
                                </select> (*)
                            </td>
                        </tr>
                        <tr>
                            <td>Language to retrieve the project in if you prefer not to retrieve in the default language:</td>
                            <td>
                                <select name="language" style="width: 300px;">
                                    <option value="" selected="true">--default language--</option>
                                    <option value="en-US">en-US</option>
                                    <option value="de-DE">de-DE</option>
                                    <option value="nl-NL">nl-NL</option>
                                </select> (optional)
                            </td>
                        </tr>
                        <tr>
                            <td>Download to disk or show in browser:</td>
                            <td>
                                <select name="download">
                                    <option value="true">Download</option>
                                    <option value="false" selected="true">Show</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td><input type="submit" value="Send"/></td>
                        </tr>
                    </table>
                </form>
                </div>
            </body>
        </html>
    )
    else if (count($decorproject) != 1) then (
        response:set-status-code(404), <error>{msg:getMessage('errorRetrieveProjectNoSingleResult',$language),' ',if (request:exists()) then request:get-query-string() else()}</error>
    )
    else if ($mode = 'test' and $filters[@filter='off']) then (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        if ($download='true') then (
            response:set-header('Content-Disposition', concat('attachment; filename=',$filenamecompiled)),
            processing-instruction {'xml-stylesheet'} {' type="text/xsl" href="http://art-decor.org/ADAR/rv/DECOR2schematron.xsl"'}
        ) else (),
        $filters
    )
    else if ($mode = ('compiled','test')) then (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        if ($download='true') then (
            response:set-header('Content-Disposition', concat('attachment; filename=',$filenamecompiled)),
            processing-instruction {'xml-stylesheet'} {' type="text/xsl" href="http://art-decor.org/ADAR/rv/DECOR2schematron.xsl"'}
        ) else (),
        if ($mode != 'test') then (
            processing-instruction {'xml-model'} {' href="http://art-decor.org/ADAR/rv/DECOR.xsd" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"'}
        ) else (),
        comp:compileDecor($decorproject, $language, $now, $filters, $mode='test')
    )
    else if ($mode = 'cache') then (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        if ($download='true') then (
            response:set-header('Content-Disposition', concat('attachment; filename=',$filenamecached))
        ) else (),
        local:addCacheAttributes($decorproject)
    )
    (:verbatim is the default:)
    else (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        if ($download='true') then (
            response:set-header('Content-Disposition', concat('attachment; filename=',$filenameverbatim)),
            processing-instruction {'xml-stylesheet'} {' type="text/xsl" href="http://art-decor.org/ADAR/rv/DECOR2schematron.xsl"'}
        ) else (),
        processing-instruction {'xml-model'} {' href="http://art-decor.org/ADAR/rv/DECOR.xsd" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"'},
        $decorproject
    )