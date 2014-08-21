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

let $project     := if (request:exists()) then request:get-parameter('project',()) else ()
let $version     := if (request:exists()) then request:get-parameter('version',()) else ()
let $classified  := if (request:exists()) then request:get-parameter('classified',()) else ()

return
    templ:getTemplateList((),(),(),$project,$version,$classified='true')