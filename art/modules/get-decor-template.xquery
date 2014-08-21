xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai U. Heitmann

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
import module namespace templ   = "http://art-decor.org/ns/decor/template" at "../api/api-decor-template.xqm";

let $id               := if (request:exists()) then request:get-parameter('id',())[string-length()>0][1] else ()
let $name             := if (request:exists()) then request:get-parameter('name',())[string-length()>0][1] else ()
let $ref              := if (request:exists()) then request:get-parameter('ref',())[string-length()>0][1] else ()
let $useRegexMatching := if (request:exists()) then request:get-parameter('regex',false())[string-length()>0][1] else (false())

let $effectiveDate    := if (request:exists()) then request:get-parameter('effectiveDate',())[string-length()>0][1] else ()
let $projectPrefix    := if (request:exists()) then request:get-parameter('project',())[string-length()>0][1] else ()

let $templates := 
    if (not(empty($id))) then
        if (empty($projectPrefix)) then
            templ:getExpandedTemplateById($id,$effectiveDate)
        else (
            templ:getExpandedTemplateById($id,$effectiveDate,$projectPrefix)
        )
    
    else if (not(empty($name))) then
        if (empty($projectPrefix)) then
            templ:getExpandedTemplateByName($name,$effectiveDate,$useRegexMatching)
        else (
            templ:getExpandedTemplateByName($name,$effectiveDate,$projectPrefix,$useRegexMatching)
        )
    
    else if (not(empty($ref)) and not(empty($projectPrefix))) then
        templ:getExpandedTemplateByRef($ref,$effectiveDate,$projectPrefix)
    
    else ()

return
    $templates