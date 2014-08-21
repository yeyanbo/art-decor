xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw, Alexander Henket
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace f   = "urn:decor:REST:v1" at "get-message.xquery";

declare namespace hl7="urn:hl7-org:v3";
declare namespace xs="http://www.w3.org/2001/XMLSchema";

declare option exist:serialize "method=xhtml media-type=text/html";
declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');

let $xslFile := xs:anyURI(concat('xmldb:exist://',$get:root,'decor/services/resources/stylesheets/decor-transaction-group-2-svg.xsl'))

(: let $projectId := request:get-parameter('id','') :)
(: let $projectName := request:get-parameter('name','') :)
let $projectPrefix := request:get-parameter('prefix','')
let $language      := request:get-parameter('language',$get:strArtLanguage)
let $id            := 
    <parameters>
        <param name="doFunctionalView" value="true"/>
        <param name="doTechnicalView" value="false"/>
        <param name="language" value="{$language}"/>
        <param name="transactionGroupId" value="{request:get-parameter('id','')}"/>
        <param name="textFunctionalPerspective" value="{f:getMessage('textFunctionalPerspective',$language)}"/>
        <param name="textTechnicalPerspective" value="{f:getMessage('textTechnicalPerspective',$language)}"/>
    </parameters>

let $decorProject :=
    if (string-length($projectPrefix)>0) then
        collection($get:strDecorData)//decor[project/@prefix=$projectPrefix]
    else ()
let $html := 
        if ( string-length($projectPrefix)>0 ) then
            transform:transform($decorProject, $xslFile, $id)
        else (
            <html>
                <head>
                    <title>{f:getMessage('titleError',$language)}</title>
                    <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
                </head>
                <body>
                    <h1>{f:getMessage('errorGetImageNotEnoughParameters',$language)}</h1>
                </body>
            </html>
        )
return
$html