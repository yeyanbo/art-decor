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
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

declare namespace xs    = "http://www.w3.org/2001/XMLSchema";

let $project            := if (request:exists()) then (request:get-parameter('project',())) else ()
let $decor              := $get:colDecorData//decor[project/@prefix=$project]
let $codeSystems        := $decor/terminology/codeSystem
let $language           := if (request:exists()) then (request:get-parameter('language',$decor/project/@defaultLanguage)) else ($decor/project/@defaultLanguage)

return
    <codeSystems projectPrefix="{$project}">
    {
        for $codeSystem in $codeSystems
        order by lower-case($codeSystem/@name)
        return
        <codeSystem id="{$codeSystem/@id|$codeSystem/@ref}" name="{$codeSystem/@name}" displayName="{$codeSystem/@displayName}"/>
    }
    </codeSystems>