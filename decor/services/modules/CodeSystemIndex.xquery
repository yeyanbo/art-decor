xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw, Alexander Henket, Kai Heitmann
    
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

(: TODO: media-type beter zetten en XML declaration zetten bij XML output :)
declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes";
declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');


let $id            := request:get-parameter('id','')
let $code          := request:get-parameter('code','')
let $effectiveDate := request:get-parameter('effectiveDate','')
let $format        := request:get-parameter('format','xml')
let $language      := request:get-parameter('language',$get:strArtLanguage)

let $parameters    :=  request:get-parameter-names()

let $searchString := 
    for $parKey in $parameters
        let $parValue := request:get-parameter($parKey,'')
    return
        if ($parKey != 'format' and string-length($parValue) > 0) then
            (concat('@',$parKey,'=&apos;',$parValue,'&apos;'))
        else 
            ()
(:
return 
    <warning>{f:getMessage('errorNotImplementedYet',$language),' ',$searchString}</warning>
    
:)

let $projects := collection($get:strDecorData)//decor
(: as of now this is a collection of all mentioned code systems in all value sets :)

let $codesystemsconcepts := collection($get:strDecorData)//valueSet/conceptList/concept

    (:for $vc in $valuesets/conceptList/concept
    (:group $vc as $cvs by $cvs/@codeSystem as $cv
    order by $vc/@codeSystem:)
    return
        <codeSystem id="{$vc/@codeSystem}"/>:)



return 
 if (empty($codesystemsconcepts)) then (
        response:set-status-code(404), 
        response:set-header('Content-Type','text/xml; charset=utf-8'), 
        <error>No code systems mentioned in value sets</error>
) else if (1=1) then (
        (: pretend as if not yet implemented :)
        <warning>{f:getMessage('errorNotImplementedYet',$language),' ',$searchString}</warning>
 )
else (
    response:set-header('Content-Type','text/html; charset=utf-8'),
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>CodeSystemIndex</title>
        <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <h1>Code System Index</h1>
        <div class="content">
            <table class="values" id="codeSystemList">
                <thead>
                    <tr>
                        <th>XML</th>
                        <th>HTML</th>
                        <th>CSV</th>
                        <th>{f:getMessage('columnName','en-US')}</th>
                        <th>{f:getMessage('columnID','en-US')}</th>
                    </tr>
                </thead>
                <tbody>
                {
                    for $codesystem in $codesystemsconcepts
                    (:group $codesystem as $cvs by $codesystem/@codeSystem as $cs:)
                    group by $cs := $codesystem/@codeSystem
                    order by $cs
                    return 
                        <tr style="background-color:white" onMouseover="this.style.backgroundColor='lightblue';" onMouseout="this.style.backgroundColor='white';">
                            <td>xml</td>
                            <td>html</td>
                            <td>csv</td>
                            <td>-</td>
                            <td>{$codesystem[1]/@codeSystem/string()}</td>
                        </tr>
                }
                </tbody>
            </table>
        </div>
    </body>
</html>
)