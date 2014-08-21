xquery version "3.0";
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

import module namespace get    = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
import module namespace aduser = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";

let $projectPrefix     := if (request:exists()) then request:get-parameter('prefix',()) else ()
let $notifierSetting   := if (request:exists()) then request:get-parameter('notifier','') else ('')

let $decorIssues       := $get:colDecorData/decor[project/@prefix=$projectPrefix]/issues

let $projectUpdate     := 
    if (exists($decorIssues) and $notifierSetting=('on','off','')) then
        if ($decorIssues[@notifier]) then 
            update value $decorIssues/@notifier with $notifierSetting
        else (
            update insert attribute notifier {$notifierSetting} into $decorIssues
        )
    else ()

return
    <data-safe>true</data-safe>