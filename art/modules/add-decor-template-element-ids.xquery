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

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

let $projectPrefix          := if (request:exists()) then request:get-parameter('prefix',()) else ()

let $decor                  := $get:colDecorData//decor[project/@prefix=$projectPrefix]

let $templateId             := if (request:exists()) then request:get-parameter('id',()) else ()
let $templateEffectiveDate  := if (request:exists()) then request:get-parameter('effectiveDate',()) else ()

let $template               := $decor//template[@id=$templateId][@effectiveDate=$templateEffectiveDate]

let $defaultElementBaseId   := $decor//ids/defaultBaseId[@type='EL']/@id
let $elementBaseId          := 
    if ($defaultElementBaseId) then
        if (not(ends-with($defaultElementBaseId,'.'))) 
        then concat($defaultElementBaseId,'.') 
        else $defaultElementBaseId/string()
    else ()
let $elementIncr            :=
    if ($elementBaseId) then
        if ($decor//@id[starts-with(.,$elementBaseId)]) then
            max($decor//@id[starts-with(.,$elementBaseId)]/number(tokenize(.,'\.')[last()]))
        else (0)
    else ()

let $update                 :=
    if ($elementBaseId) then
        for $element at $pos in $template//element[not(@id)]
        return
        update insert attribute id {concat($elementBaseId,$elementIncr+$pos)} into $element
    else ()
return
    <data-safe>true</data-safe>