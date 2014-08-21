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
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
declare namespace sm            = "http://exist-db.org/xquery/securitymanager";

(:  Mode            Octal
 :  rw-r--r--   ==  0644
 :  rw-rw-r--   ==  0664
 :  rwxr-xr--   ==  0754
 :  rwxr-xr-x   ==  0755
 :  rwxrwxr-x   ==  0775
 :)

(:install path for art (normally /db/apps/), includes trailing slash :)
declare variable $adpfix:root       := repo:get-root();
declare variable $adpfix:xisdata   := concat($adpfix:root,'xis-data');

(:
:   Call to fix any potential permissions problems in the paths:
:       /db/apps/xis-data
:   Dependency: $get:strXisHelperConfig, $get:strXisAccounts
:   NOTE: path /db/apps/decor/core has its own installer
:)
declare function adpfix:setXisDataPermissions() {
    local:checkIfUserDba(),
    sm:chown(xs:anyURI($adpfix:xisdata),'admin:xis'),
    sm:chmod(xs:anyURI($adpfix:xisdata),sm:octal-to-mode('0775')),
    sm:clear-acl(xs:anyURI($adpfix:xisdata)),
    
    (:default for all resources immediately under xis-data:)
    for $res in xmldb:get-child-resources($adpfix:xisdata)
    return (
        sm:chown(xs:anyURI(concat($adpfix:xisdata,'/',$res)),'admin:xis'),
        sm:chmod(xs:anyURI(concat($adpfix:xisdata,'/',$res)),sm:octal-to-mode('0664')),
        sm:clear-acl(xs:anyURI(concat($adpfix:xisdata,'/',$res)))
    )
    ,
    (:exceptions for these resources immediately under xis-data:)
    for $res in xmldb:get-child-resources($adpfix:xisdata)[.=('soap-service-list.xml')]
    return (
        sm:chown(xs:anyURI(concat($adpfix:xisdata,'/',$res)),'admin:xis'),
        sm:chmod(xs:anyURI(concat($adpfix:xisdata,'/',$res)),sm:octal-to-mode('0644')),
        sm:clear-acl(xs:anyURI(concat($adpfix:xisdata,'/',$res)))
    )
    ,
    sm:chown(xs:anyURI($get:strXisAccounts),'admin:xis'),
    sm:chmod(xs:anyURI($get:strXisAccounts),sm:octal-to-mode('0775')),
    sm:clear-acl(xs:anyURI($get:strXisAccounts)),
    
    if (xmldb:collection-available($get:strXisHelperConfig)) then
        local:setPermissions($get:strXisHelperConfig, 'admin:xis', sm:octal-to-mode('0755'), 'admin:decor', sm:octal-to-mode('0644'))
    else (),
    if (xmldb:collection-available(concat($adpfix:xisdata,'/vocab'))) then
        local:setPermissions(concat($adpfix:xisdata,'/vocab'), 'admin:xis', sm:octal-to-mode('0755'), 'admin:decor', sm:octal-to-mode('0644'))
    else ()
};

(:
:   Helper function with recursion for adpfix:setXisDataPermissions()
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

declare function local:checkIfUserDba() {
    if (sm:is-dba(xmldb:get-current-user())) then () else (
        error(QName('http://art-decor.org/ns/art-decor-permissions', 'NotAllowed'), concat('Only dba user can use this module. ',xmldb:get-current-user()))
    )
};