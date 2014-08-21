xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
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
import module namespace decor   = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";

let $searchTerms    := if (request:exists()) then tokenize(lower-case(request:get-parameter('searchString',())),'\s') else ()
let $projectPrefix  := if (request:exists()) then (request:get-parameter('project',())) else ()

let $decor          := $get:colDecorData//decor[project/@prefix=$projectPrefix]
let $requestHeaders := <headers><header name="Content-Type" value="text/xml"/></headers>
let $repositories   :=
    for $repository in $decor/project/buildingBlockRepository
    return
        <repositoryValueSetList url="{$repository/@url}" ident="{$repository/@ident}">
        {
            httpclient:get(xs:anyURI(concat($repository/@url,'/SearchValueSet?searchString=',$searchTerms,'&amp;prefix=',$repository/@ident)),false(),$requestHeaders)/httpclient:body//valueSet[@id]
        }
        </repositoryValueSetList>


return
<searchResult count="{count($repositories//valueSet)}">
{
    for $valueSet in $repositories//valueSet
    order by $valueSet/@name
    return
        <valueSet url="{$valueSet/parent::repositoryValueSetList/@url}">
        {$valueSet/@*}
        </valueSet>
}
</searchResult>