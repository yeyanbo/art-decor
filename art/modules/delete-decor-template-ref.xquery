xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

(:
   Xquery for deleting template ref
   Input: post of template element:
   <template projectPrefix="demo1-" ref="2.16.840.1.113883.1.10.1234" name="x" displayName="y"/>
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";


let $projectPrefix := request:get-parameter('prefix','')
let $ref := request:get-parameter('ref','')

(:get decor file:)
let $decor := $get:colDecorData//decor[project/@prefix=$projectPrefix]
let $templateRef := $decor//template[@ref=$ref]
(: get user for permission check:)
let $user := xmldb:get-current-user()
let $response :=
    if ($user=$decor/project/author/@username) then (
        update delete $templateRef,
        <response>OK</response>
    ) else (
        <response>NO PERMISSION</response>
    )
   
return
    $response