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

(:
    FIXME eXist 2.0 alert!
    This works in 1.5:
    for $valueSet in $decorProjectValuesets/valueSet
    group $valueSet as $versions by $valueSet/@id as $id, $valueSet/@name as $name
    ...
    $versions[1]...
    
    And this in eXist 2.0
    for $valueSet in $decorProjectValuesets/valueSet
    group by $id := $valueSet/@id , $name := $valueSet/@name
    ...
    $valueSet[1]...
:)
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
declare namespace xs        = "http://www.w3.org/2001/XMLSchema";
declare namespace xforms    = "http://www.w3.org/2002/xforms";

let $project               := if (request:exists()) then request:get-parameter('project',()) else ()
(:let $project               := 'peri20-':)
let $decorProjectValuesets := $get:colDecorData//decor[project/@prefix=$project]/terminology/valueSet

return
<valueSetList>
{
    for $valueSet in $decorProjectValuesets
    (:no effectiveDate on @ref, so might be empty:)
    let $latestVersion  := max($valueSet/xs:dateTime(@effectiveDate))
    let $latestValueSet := if (empty($latestVersion)) then $valueSet[1] else ($valueSet[@effectiveDate=$latestVersion][1])
    group by $name := $valueSet/@name
    order by $name
    return
    <valueSet>
    {
        $latestValueSet/@name,
        $latestValueSet/@displayName,
        $latestValueSet/@effectiveDate,
        if ($latestValueSet/@id[string-length()>0]) then (
            $latestValueSet/@id
        ) else (
            $latestValueSet/@ref
        ),
        $latestValueSet/@statusCode
    }
    </valueSet>
}
</valueSetList>