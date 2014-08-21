xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

(:
   Xquery for inserting template ref into rules
   Input: post of template element:
   <template projectPrefix="demo1-" ref="2.16.840.1.113883.1.10.1" name="x" displayName="y"/>
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";


let $templateRef := request:get-data()/template

(:get decor file:)
let $decor :=$get:colDecorData//decor[project/@prefix=$templateRef/@projectPrefix]

(: get user for permission check:)
let $user := xmldb:get-current-user()

let $ref :=
    <template>
    {
        $templateRef/@*[not(name()='projectPrefix')]
    }
    </template>
    
let $alreadyrefed := count($decor/rules/template[@ref=$templateRef/@ref]) > 0
       
let $response :=
    if ($user=$decor/project/author/@username) then (
        if ($alreadyrefed)
        then <response>OK</response>
        else (
            if (not($decor/rules) and $decor/terminology) then
                update insert <rules/> following $decor/terminology
            else if (not($decor/rules) and not($decor/terminology) and $decor/ids) then
                update insert <rules/> following $decor/ids
            else(),
            update insert $ref into $decor/rules,
            <response>OK</response>
        )
    ) else (
        <response>NO PERMISSION</response>
    )
return
    $response