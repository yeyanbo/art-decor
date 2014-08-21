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

let $newUserEmail      := if (request:exists()) then request:get-parameter('email','') else ('')
let $updateAllProjects := if (request:exists()) then request:get-parameter('updateprojects','false') else ('false')
let $updateProject     := if (request:exists()) then request:get-parameter('updateproject',()) else ()

let $userUpdate        := 
    if (string-length($updateProject)=0) then
        aduser:setUserEmail(xmldb:get-current-user(),$newUserEmail)
    else ()
let $userUpdate        := 
    if ($updateAllProjects='true') then
        for $author in $get:colDecorData//decor/project/author[@username=xmldb:get-current-user()]
        return
            if ($author[@email]) then 
                update value $author/@email with $newUserEmail
            else (
                update insert attribute email {$newUserEmail} into $author
            )
    else if (string-length($updateProject)>0) then
        for $author in $get:colDecorData//decor/project[@prefix=$updateProject]/author[@username=xmldb:get-current-user()]
        return
            if ($author[@email]) then 
                update value $author/@email with $newUserEmail
            else (
                update insert attribute email {$newUserEmail} into $author
            )
    else ()

return
    <email username="{xmldb:get-current-user()}" default="{aduser:getUserEmail(xmldb:get-current-user())}">
    {
        for $author in $get:colDecorData//decor/project/author[@username=xmldb:get-current-user()]
        return
            <project prefix="{$author/parent::project/@prefix/string()}" name="{$author/parent::project/name[1]/text()}" email="{$author/@email/string()}"/>
    }
    </email>