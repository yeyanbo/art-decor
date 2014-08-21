xquery version "1.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../api/api-server-settings.xqm";

let $uri  := if (request:exists()) then (request:get-parameter('uri',())) else ('http://art-decor.org/decor/services/')
let $type := if (request:exists()) then (request:get-parameter('type',())) else ('')

return
    if ($uri) then (
        adserver:getRepositoriesFromServer($uri)
    )
    else if ($type='all') then (
        adserver:getServerAllRepositories()
    )
    else if ($type='internal') then (
        adserver:getServerInternalRepositories()
    )
    else if ($type='external') then (
        adserver:getServerExternalRepositories()
    )
    else ()