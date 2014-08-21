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
import module namespace art      = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../../../art/api/api-server-settings.xqm";
import module namespace msg      = "urn:decor:REST:v1" at "get-message.xquery";
declare namespace hl7            = "urn:hl7-org:v3";
declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=yes";

declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');
declare variable $strArtURL      := adserver:getServerURLArt();

declare function local:getpage ($errorstring as xs:string?,$language as xs:string) as item()* {
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>{msg:getMessage('titleRenderCDA',$language)}</title>
            <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
        </head>
        <body>
            <h1>{msg:getMessage('titleRenderCDA',$language)}
                <span style="float:right;">
                    <img src="{$strArtURL}img/flags/nl.png" onclick="location.href=window.location.pathname+'?language=nl-NL{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                    <img src="{$strArtURL}img/flags/de.png" onclick="location.href=window.location.pathname+'?language=de-DE{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                    <img src="{$strArtURL}img/flags/us.png" onclick="location.href=window.location.pathname+'?language=en-US{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                </span>
            </h1>
            <div>
            {
                if (string-length($errorstring)>0) then (
                    <h2>{msg:getMessage('headingError',$language)}</h2>,
                    <p><strong>{$errorstring}</strong></p>
                ) else ()
            }
            <h2>{msg:getMessage('headingUpload',$language)}</h2>
            <p>{msg:getMessage('instructionsRenderCDA',$language)}</p>
            <form action="RenderCDA?language={$language}" enctype="multipart/form-data" method="post">
                <table>
                    <tr>
                        <td>
                            <input type="file" name="upload" />
                        </td>
                        <td>
                            <input type="radio" name="action" value="show" checked="checked">{msg:getMessage('buttonShow',$language)}</input>
                            <input type="radio" name="action" value="convert">{msg:getMessage('buttonConvert',$language)}</input> 
                        </td>
                        <td style="padding-left: 1em;" align="right">
                            <input type="submit" value="{msg:getMessage('buttonGo',$language)}" />
                        </td>
                    </tr>
                </table>
            </form>
            <h2>{msg:getMessage('headingCommandline',$language)}</h2>
            <p>{art:parseNode(<x>{msg:getMessage('instructionsRenderCDACommandLine1',$language)}</x>)/node()} <pre>curl -F "upload=@cda.xml" -o "cda.html" http://decor.nictiz.nl/decor/services/RenderCDA?action=show</pre></p>
            <p>{art:parseNode(<x>{msg:getMessage('instructionsRenderCDACommandLine2',$language)}</x>)/node()} <pre>curl -F "upload=@cdar2.xml" -o "cdar3.xml" http://decor.nictiz.nl/decor/services/RenderCDA?action=convert</pre></p>
            </div>
        </body>
    </html>
};

let $filedata         := if (request:exists() and request:is-multipart-content()) then request:get-uploaded-file-data('upload') else ()
let $fileaction       := if (request:exists()) then request:get-parameter('action','show') else ()
(:let $filename         := if (request:exists()) then request:get-uploaded-file-name('upload') else ()
let $filesize         := if (request:exists()) then request:get-uploaded-file-size('upload') else ():)
let $language           := request:get-parameter('language',$get:strArtLanguage)

let $xslfile          := 
    if ($fileaction='show') 
    then xs:anyURI(concat('xmldb:exist://',$get:strHl7,'/CDAr2/xsl/cda.xsl'))
    else xs:anyURI(concat('xmldb:exist://',$get:strHl7,'/CDAr2/cdar2_to_cdar3/cda2_to_cdar3.xsl'))
let $xslparams       := 
    if ($fileaction='show') 
    then <parameters><param name="textLang" value="{$language}"/></parameters>
    else ()
    
let $error-transform  := "Error rendering the document"


return 
if (empty($filedata)) then (
        response:set-status-code(200), 
        response:set-header('Content-Type','text/html; charset=utf-8'),
        local:getpage('',$language)
) else if ($fileaction='convert') then (
    (:converting to CDAr3:)
    try {
        (: convert base64 to string :)
        (: parse into node :)
        response:set-status-code(200), 
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        transform:transform(util:parse(util:binary-to-string($filedata)), $xslfile, ())
    }
    catch * {
        response:set-status-code(500), 
        response:set-header('Content-Type','text/html; charset=utf-8'),
        local:getpage(string-join(($error-transform,': ',$err:code,' - ',$err:description),''),$language)
    }
) else (
    (:rendering in HTML:)
    try {
        (: convert base64 to string :)
        (: parse into node :)
        response:set-status-code(200), 
        response:set-header('Content-Type','text/html; charset=utf-8'),
        transform:transform(util:parse(util:binary-to-string($filedata)), $xslfile, ())
    }
    catch * {
        response:set-status-code(500), 
        response:set-header('Content-Type','text/html; charset=utf-8'),
        local:getpage(string-join(($error-transform,': ',$err:code,' - ',$err:description),''),$language)
    }
)
