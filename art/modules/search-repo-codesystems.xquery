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


import module namespace get         = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace decor       = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";
import module namespace adserver    = "http://art-decor.org/ns/art-decor-server" at "../api/api-server-settings.xqm";

let $searchTerms    := if (request:exists()) then tokenize(lower-case(request:get-parameter('searchString',())),'\s') else ()
let $projectPrefix  := if (request:exists()) then (request:get-parameter('project',())) else ()
let $thisServer     := adserver:getServerURLServices()

let $decor          := $get:colDecorData//decor[project/@prefix=$projectPrefix]
let $requestHeaders := <headers><header name="Content-Type" value="text/xml"/></headers>

let $internalrepositories   :=
    for $repository in $decor/project/buildingBlockRepository[@url=$thisServer]
    return
        <repositoryCodeSystemList url="{$repository/@url}" ident="{$repository/@ident}">
        {
            $get:colDecorData//decor[project/@prefix=$repository/@ident]/terminology/codeSystem[@id]
        }
        </repositoryCodeSystemList>
    
let $externalrepositories   :=
    for $repository in $decor/project/buildingBlockRepository[not(@url=$thisServer)]
    return
        <repositoryCodeSystemList url="{$repository/@url}" ident="{$repository/@ident}">
        {
            httpclient:get(xs:anyURI(concat($repository/@url,'/SearchCodeSystem?searchString=',$searchTerms,'&amp;prefix=',$repository/@ident)),false(),$requestHeaders)/httpclient:body//codeSystem[@id]
        }
        </repositoryCodeSystemList>

let $repositories           := $internalrepositories | $externalrepositories

return
<searchResult count="{count($repositories/codeSystem)}">
{
    for $codeSystem in $repositories/codeSystem
    order by $codeSystem/@name
    return
        <codeSystem>
        {
            $codeSystem/parent::*/@url,
            $codeSystem/parent::*/@ident,
            $codeSystem/(@* except (@url|@ident))
        }
        </codeSystem>
}
</searchResult>