xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

let $package-navigation     := if (request:exists()) then request:get-parameter('package',()) else ('nictiz')
let $project-data           := if (request:exists()) then request:get-data() else (<decor><project prefix="hui-"/></decor>)
let $project-prefix         := ($project-data/decor/project/@prefix/string())[1]

let $projectStoreParent     := concat($get:strDecorData,'/',$package-navigation)
let $projectStoreResource   := concat($project-prefix,'decor.xml')
let $projectStoreCollection := substring($project-prefix,1,string-length($project-prefix)-1)
let $projectLogosCollection := concat($project-prefix,'logos')

let $data-safe :=
    if (empty($project-prefix)) then
        'Project has no prefix in /decor/project/@prefix'
    else if (not(xmldb:collection-available($projectStoreParent))) then
        concat('Package collection does not exist: ',$projectStoreParent)
    else if (xmldb:collection-available(concat($projectStoreParent,'/',$projectStoreCollection))) then
        concat('Project collection already exists: ',$projectStoreCollection)
    else if (not(sm:has-access($projectStoreParent,'rwx'))) then
        concat('Current user has no write privileges: ',xmldb:get-current-user())
    else (
        let $create-parent  := xmldb:create-collection($projectStoreParent,$projectStoreCollection)
        let $parent-chown   := sm:chown($create-parent,'admin:decor')
        let $parent-chmod   := sm:chmod($create-parent,'rwxrwxr-x')
        
        let $create-logos   := xmldb:create-collection($create-parent,$projectLogosCollection)
        let $logos-chown    := sm:chown($create-logos,'admin:decor')
        let $logos-chmod    := sm:chmod($create-logos,'rwxrwxr-x')
        
        let $create-project := xmldb:store($create-parent,$projectStoreResource,$project-data)
        let $project-chown  := sm:chown($create-project,'admin:decor')
        let $project-chmod  := sm:chmod($create-project,'rw-rw-r--')
        
        return ()
    )
    
return
    <data-safe error="{$data-safe}">{empty($data-safe)}</data-safe>
