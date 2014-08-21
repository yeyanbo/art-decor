xquery version "3.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)
module namespace adpfix         = "http://art-decor.org/ns/art-decor-permissions";
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
declare namespace sm            = "http://exist-db.org/xquery/securitymanager";

(:  Mode            Octal
 :  rw-r--r--   ==  0644
 :  rw-rw-r--   ==  0664
 :  rwxr-xr--   ==  0754
 :  rwxr-xr-x   ==  0755
 :  rwxrwxr-x   ==  0775
 :)

(:install path for art (normally /db/apps/), includes trailing slash :)
declare variable $adpfix:root   := repo:get-root();

(:
:   Call to fix any potential permissions problems in the paths
:       /db/apps/art/modules
:       /db/apps/art/resources
:       /db/apps/art-data
:   Dependency: $get:strArt, $get:strArtResources, $get:strArtData
:)
declare function adpfix:setArtPermissions() {
    local:checkIfUserDba(),
    sm:chown(xs:anyURI($get:strArtResources),'admin:decor'),
    sm:chmod(xs:anyURI($get:strArtResources),sm:octal-to-mode('0775')),
    sm:clear-acl(xs:anyURI($get:strArtResources)),
    
    sm:chown(xs:anyURI(concat($get:strArtResources,'/decor-locks.xml')),'admin:decor'),
    sm:chmod(xs:anyURI(concat($get:strArtResources,'/decor-locks.xml')),sm:octal-to-mode('0775')),
    sm:clear-acl(xs:anyURI(concat($get:strArtResources,'/decor-locks.xml'))),
    
    local:setArtQueryPermissions(),
    local:setArtDataPermissions()
};

(:
:   Call to fix any potential permissions problems in the path /db/apps/art/modules
:   Dependency: $get:strArt
:)
declare function local:setArtQueryPermissions() {
    for $query in xmldb:get-child-resources(xs:anyURI(concat($get:strArt,'/modules')))
    return (
        sm:chown(xs:anyURI(concat($adpfix:root,'art/modules/',$query)),'admin:decor'),
        if (starts-with($query,('art-decor','check','collect','get','login','retrieve','search'))) then
            sm:chmod(xs:anyURI(concat($adpfix:root,'art/modules/',$query)),sm:octal-to-mode('0755'))
        else(
            sm:chmod(xs:anyURI(concat($adpfix:root,'art/modules/',$query)),sm:octal-to-mode('0754'))
        )
        ,
        sm:clear-acl(xs:anyURI(concat($adpfix:root,'art/modules/',$query)))
    )
};

(:
:   Call to fix any potential permissions problems in the path /db/apps/art-data
:   Dependency: $get:strArtData
:)
declare function local:setArtDataPermissions() {
    for $file in xmldb:get-child-resources(xs:anyURI($get:strArtData))
    return (
        sm:chown(xs:anyURI(concat($get:strArtData,'/',$file)),'admin:decor'),
        sm:chmod(xs:anyURI(concat($get:strArtData,'/',$file)),sm:octal-to-mode('0644')),
        sm:clear-acl(xs:anyURI(concat($get:strArtData,'/',$file)))
    )
    ,
    for $file in xmldb:get-child-resources(xs:anyURI($get:strArtData))[.=('user-info.xml','user-subscriptions.xml')]
    return (
        sm:chown(xs:anyURI(concat($get:strArtData,'/',$file)),'admin:decor'),
        sm:chmod(xs:anyURI(concat($get:strArtData,'/',$file)),sm:octal-to-mode('0664')),
        sm:clear-acl(xs:anyURI(concat($get:strArtData,'/',$file)))
    )
};

(:
:   Call to fix any potential permissions problems in the paths:
:       /db/apps/decor/cache
:       /db/apps/decor/data
:       /db/apps/decor/releases
:   Dependency: $get:strArtData, $get:strDecorCache, $get:strDecorData, $get:strDecorVersion
:   NOTE: path /db/apps/decor/core has its own installer
:)
declare function adpfix:setDecorPermissions() {
    local:checkIfUserDba(),
    sm:chown(xs:anyURI(concat($adpfix:root,'decor')),'admin:decor'),
    sm:chmod(xs:anyURI(concat($adpfix:root,'decor')),sm:octal-to-mode('0775')),
    sm:clear-acl(xs:anyURI(concat($adpfix:root,'decor'))),
    
    local:setPermissions($get:strDecorCache, 'admin:decor', sm:octal-to-mode('0775'), 'admin:decor', sm:octal-to-mode('0644')),
    local:setPermissions($get:strDecorData, 'admin:decor', sm:octal-to-mode('0775'), 'admin:decor', sm:octal-to-mode('0664')),
    local:setPermissions($get:strDecorVersion, 'admin:decor', sm:octal-to-mode('0775'), 'admin:decor', sm:octal-to-mode('0644'))
};

(:
:   Helper function with recursion for adpfix:setDecorPermissions()
:)
declare function local:setPermissions($path as xs:string, $collown as xs:string, $collmode as xs:string, $resown as xs:string, $resmode as xs:string) {
    sm:chown(xs:anyURI($path),$collown),
    sm:chmod(xs:anyURI($path),$collmode),
    sm:clear-acl(xs:anyURI($path)),
    for $res in xmldb:get-child-resources(xs:anyURI($path))
    return (
        sm:chown(xs:anyURI(concat($path,'/',$res)),$resown),
        sm:chmod(xs:anyURI(concat($path,'/',$res)),$resmode),
        sm:clear-acl(xs:anyURI(concat($path,'/',$res)))
    )
    ,
    for $collection in xmldb:get-child-collections($path)
    return
        local:setPermissions(concat($path,'/',$collection), $collown, $collmode, $resown, $resmode)
};

(:
:   Call to get an overview of permissions in the database. Input may be a collection or a resource. 
:   If it is a collection, all subpaths below that are returned too. The output is a (nested)
:   element sm:permission exactly as sm:get-permissions($path) would return it, but with @path added
:   containing the full path to the collection/resource.
:   Example output:
:   <sm:permission xmlns:sm="http://exist-db.org/xquery/securitymanager" path="/db/apps/art" owner="admin" group="dba" mode="rwxr-xr-x">
        <sm:acl entries="0"/>
        <sm:permission path="/db/apps/art/api" owner="admin" group="dba" mode="rwxr-xr-x">
            <sm:acl entries="0"/>
            <sm:permission path="/db/apps/art/api/api-decor-codesystem.xqm" owner="admin" group="dba" mode="rwxr-xr-x">
                <sm:acl entries="0"/>
            </sm:permission>
            ...
        </sm:permission>
        <sm:permission path="/db/apps/art/build.xml" owner="admin" group="dba" mode="rw-r--r--">
            <sm:acl entries="0"/>
        </sm:permission>
        ...
        <sm:permission path="/db/apps/art/install-data" owner="admin" group="dba" mode="rwxr-xr-x">
            ...
        </sm:permission>
        <sm:permission path="/db/apps/art/modules" owner="admin" group="dba" mode="rwxr-xr-x">
            ...
        </sm:permission>
        ...
        <sm:permission path="/db/apps/art/resources" owner="admin" group="decor" mode="rwxrwxr-x">
            ...
        </sm:permission>
        <sm:permission path="/db/apps/art/xforms" owner="admin" group="dba" mode="rwxr-xr-x">
            ...
        </sm:permission>
    </sm:permission>
:)
declare function adpfix:getCurrentPermissions($path as xs:string) as element(permissions) {
    let $check  := local:checkIfUserDba()
    let $check  :=
        if (xmldb:collection-available($path) or util:binary-doc-available($path) or doc-available($path)) then () else (
            error(QName('http://art-decor.org/ns/art-decor-permissions', 'NotFound'), concat('Supplied path does not exist. ',$path))
        )
    
    let $perm   := sm:get-permissions(xs:anyURI($path))
    return
        <sm:permission path="{$path}">
        {
            $perm/sm:permission/(@* except @path),    (:normally: @owner/@group/@mode:)
            $perm/sm:permission/node(),               (:potential for ACLs <sm:acl entries="0"/>:)
            if (xmldb:collection-available($path)) then (
                for $res in (xmldb:get-child-resources($path) , xmldb:get-child-collections($path))
                order by lower-case($res)
                return
                    adpfix:getCurrentPermissions(concat($path,'/',$res))
            ) else ()
        }
        </sm:permission>
};

declare function local:checkIfUserDba() {
    if (sm:is-dba(xmldb:get-current-user())) then () else (
        error(QName('http://art-decor.org/ns/art-decor-permissions', 'NotAllowed'), concat('Only dba user can use this module. ',xmldb:get-current-user()))
    )
};