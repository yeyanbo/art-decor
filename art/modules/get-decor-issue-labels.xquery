xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace request       = "http://exist-db.org/xquery/request";

let $projectPrefix      := if (request:exists()) then (request:get-parameter('project',())) else ()
let $language           := if (request:exists()) then (request:get-parameter('language',())) else ()
(:
    <labels>
        <label code="" name="" color="">
            <desc language="en-US">....</desc>
        </label>
    </labels>
:)
let $labels             := $get:colDecorData//decor[project/@prefix=$projectPrefix]/issues/labels

return
    <labels>
    {
        for $label in $labels/label
        return
            <label code="{$label/@code}" name="{$label/@name}" color="{$label/@color}">
            {
                for $node in $label/desc
                return
                    art:serializeNode($node)
            }
            </label>
    }
    </labels>