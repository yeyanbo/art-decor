xquery version "1.0";
(:
	Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace xmldb   = "http://exist-db.org/xquery/xmldb";
import module namespace sm      = "http://exist-db.org/xquery/securitymanager";
import module namespace repo    = "http://exist-db.org/xquery/repo";

declare function local:exec4group($uri as xs:string) {
    sm:chown($uri,'admin'),
    sm:chgrp($uri,'ada-user'),
    sm:chmod($uri,'rwxr-x---'),
    sm:clear-acl($uri)
};

(:install path for art (/db, /db/apps), no trailing slash :)
declare variable $root := repo:get-root();

let $ada            := if (sm:group-exists('ada-user')) then () else sm:create-group('ada-user')

let $strAda         := if (xmldb:collection-available(concat($root, '/ada'))) then concat($root, '/ada') else xmldb:create-collection($root,'ada')
let $strAdaData     := if (xmldb:collection-available(concat($root, '/ada-data'))) then concat($root, '/ada-data') else xmldb:create-collection($root,'ada-data')
let $strAdaProjects := if (xmldb:collection-available(concat($strAdaData,'/projects'))) then concat($strAdaData,'/projects') else xmldb:create-collection($strAdaData,'projects')

let $collPerm       := (
        sm:chown($strAdaData,'admin'),
        sm:chgrp($strAdaData,'ada-user'),
        sm:chmod($strAdaData,'rwxrwxr--'),
        sm:clear-acl($strAdaData)
    )
let $collPerm       := (
        sm:chown($strAdaProjects,'admin'),
        sm:chgrp($strAdaProjects,'ada-user'),
        sm:chmod($strAdaProjects,'rwxrwxr--'),
        sm:clear-acl($strAdaProjects)
    )
let $collPerm       := (
        sm:chown($strAda,'admin'),
        sm:chgrp($strAda,'ada-user'),
        sm:chmod($strAda,'rwxr-xr--'),
        sm:clear-acl($strAda)
    )

let $collPerm := local:exec4group(concat($strAda, '/conf.xml'))
let $collPerm := local:exec4group(concat($strAda, '/modules'))
let $collPerm :=
    for $resource in xmldb:get-child-resources(concat($strAda, '/modules'))
    return local:exec4group(concat($strAda, '/modules/', $resource))

return if (not(xmldb:collection-available(concat($strAda,'/projects')))) then () else
    for $project in xmldb:get-child-collections(concat($strAda,'/projects'))
    return xmldb:move(concat($strAda,'/projects/',$project),$strAdaProjects)






