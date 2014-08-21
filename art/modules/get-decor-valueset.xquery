xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace vs  = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace xs        = "http://www.w3.org/2001/XMLSchema";
declare namespace xforms    = "http://www.w3.org/2002/xforms";

let $id               := if (request:exists()) then request:get-parameter('id',())[string-length()>0][1] else ()
let $name             := if (request:exists()) then request:get-parameter('name',())[string-length()>0][1] else ()
let $ref              := if (request:exists()) then request:get-parameter('ref',())[string-length()>0][1] else ()
let $useRegexMatching := if (request:exists()) then request:get-parameter('regex',false())[string-length()>0][1] else (false())

let $effectiveDate    := if (request:exists()) then request:get-parameter('effectiveDate',())[string-length()>0][1] else ()
let $projectPrefix    := if (request:exists()) then request:get-parameter('project',())[string-length()>0][1] else ('demo1-')

let $valueSets := 
    if (not(empty($id))) then
        if (empty($projectPrefix)) then
            vs:getExpandedValueSetById($id,$effectiveDate)
        else (
            vs:getExpandedValueSetById($id,$effectiveDate,$projectPrefix)
        )
    
    else if (not(empty($name))) then
        if (empty($projectPrefix)) then
            vs:getExpandedValueSetByName($name,$effectiveDate,$useRegexMatching)
        else (
            vs:getExpandedValueSetByName($name,$effectiveDate,$projectPrefix,$useRegexMatching)
        )
    
    else if (not(empty($ref)) and not(empty($projectPrefix))) then
        vs:getExpandedValueSetByRef($ref,$effectiveDate,$projectPrefix)
    
    else ()

return
<valueSetVersions>
{
    for $valueSet in $valueSets/descendant-or-self::valueSet
    order by xs:dateTime($valueSet/@effectiveDate) descending
    return
        <valueSet>
        {
            $valueSet/@*,
            if (not($valueSet/@url)) then $valueSet/parent::*/@url else (),
            if (not($valueSet/@ident)) then $valueSet/parent::*/@ident else (),
            $valueSet/node()
        }
        </valueSet>
}
</valueSetVersions>