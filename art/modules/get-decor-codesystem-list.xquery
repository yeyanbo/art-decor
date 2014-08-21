xquery version "3.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace xs="http://www.w3.org/2001/XMLSchema";

let $project            := if (request:exists()) then (request:get-parameter('project',())) else ()
let $decor              := $get:colDecorData//decor[project/@prefix=$project]
let $codeSystems        := $decor/terminology/codeSystem
let $usedCodeSystems    := distinct-values($decor//terminologyAssociation/@codeSystem | $decor//valueSet//@codeSystem | $decor//vocabulary/@codeSystem)
let $language           := if (request:exists()) then (request:get-parameter('language',$decor/project/@defaultLanguage)) else ($decor/project/@defaultLanguage)

return
    <codeSystems projectPrefix="{$project}">
    {
        for $codeSystem in $codeSystems
        group by $name := $codeSystem/@name
        order by lower-case($name)
        return
            <codeSystem name="{$name}" displayName="{$codeSystem[1]/@displayName}">
            {
                $codeSystem[1]/@id,
                $codeSystem[1]/@ref,
                $codeSystem[1]/@statusCode
            }
            </codeSystem>
        ,
        <usedCodeSystems>
        {
             for $usedId in $usedCodeSystems
             let $oidName := art:getNameForOID($usedId,$language,$decor/project/@prefix)
             order by $usedId
             return
                 <codeSystem ref="{$usedId}" name="{$oidName}" displayName="{$oidName}"/>
        }
        </usedCodeSystems>
    }
    </codeSystems>