xquery version "1.0";
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

import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace request       = "http://exist-db.org/xquery/request";

let $updatedIds     := if (request:exists()) then request:get-data()/ids else ()
let $project        := if (request:exists()) then request:get-parameter('project',())[string-length()>0] else ()

let $cleanIds       := 
    <ids>
    {
        (:
            Old style:
                <baseId id="1.2.3" type="DS" prefix="xyz"/>
                <defaultBaseId id="1.2.3" type="DS"/>
            New style:
                <baseId id="1.2.3" type="DS" prefix="xyz" default="true"/>
                
            Rewrite old style to new style.
        :)
        for $baseId in $updatedIds/baseId[@id[string-length()>0]][@type][@prefix]
        return
            <baseId>
            {
                $baseId/(@*[string-length()>0] except @status)
                ,
                if ($baseId[not(@default)]) then (
                    attribute {'default'} {$updatedIds/defaultBaseId[@id=$baseId/@id]}
                )
                else()
            }
            </baseId>
        ,
        (: For now: keep old style so we can fix all dependent code later :)
        $updatedIds/defaultBaseId[@id[string-length()>0]][@type]
        ,
        for $n in $updatedIds/id[@root[string-length()>0]]
        return
            <id>
            {
                $n/@*,
                $n/designation[@displayName[string-length()>0]][string-length(string-join(.,''))>0]
            }
            </id>
    }
    </ids>
    
let $update         := update replace $get:colDecorData/decor[project/@prefix=$project]/ids with $cleanIds

return
<data-safe>true</data-safe>