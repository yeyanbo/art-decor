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

let $labels             := if (request:exists()) then (request:get-data()/labels) else ()
let $projectPrefix      := if (request:exists()) then (request:get-parameter('project',())) else ()

(:
    <labels>
        <label code="" name="" color="">
            <desc language="en-US">....</desc>
        </label>
    </labels>
:)
let $decor              := $get:colDecorData//decor[project/@prefix=$projectPrefix]
let $currentIssues      := $decor/issues
let $currentLabels      := $currentIssues/labels
let $username           := xmldb:get-current-user()
let $isauthor           := $decor/project/author[@username=$username]

let $newLabels          :=
    <labels>
    {
        for $label in $labels/label[string-length(@code)>0][string-length(@name)>0]
        return
            <label>
            {
                $label/(@code|@name|@color)
                ,
                for $node in $label/desc[string-length(string-join(.//text(),''))>0]
                return
                    art:parseNode($node)
            }
            </label>
    }
    </labels>
    
let $update             :=
    if ($labels and $isauthor) then
        let $update     :=
            if (not($currentIssues)) then
                update insert <issues>{$newLabels}</issues> into $decor
            else if (not($currentLabels)) then
                update insert $newLabels preceding $currentIssues/*[1]
            else (
                update replace $currentLabels with $newLabels
            )
        return 
            true()
    else (
        false()
    )

return
    <data-safe>true</data-safe>
