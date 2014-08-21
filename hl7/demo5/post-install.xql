xquery version "1.0";
(:
    Copyright (C) 2012-2013 Art Decor Expert Group
    
    Author: Gerrit Boers
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace xdb  = "http://exist-db.org/xquery/xmldb";
import module namespace sm   = "http://exist-db.org/xquery/securitymanager";
import module namespace repo = "http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
(:install path for art (/db, /db/apps), no trailing slash :)
declare variable $root := repo:get-root();

(: helper function for setting write permissions :)
declare function local:setPermissions($collection as item(), $collectionOwner as xs:string, $collectionPermissions as xs:string, $resourceOwner as xs:string, $resourcePermissions as xs:string) {
    sm:chown(xs:anyURI($collection),$collectionOwner)
    ,
    sm:chmod(xs:anyURI($collection),$collectionPermissions)
    ,
    
    for $resource in xmldb:get-child-resources($collection)
    return (
        sm:chown(xs:anyURI(concat($collection,'/',$resource)),$resourceOwner),
        sm:chmod(xs:anyURI(concat($collection,'/',$resource)),$resourcePermissions)
    )
    ,
    for $childcollection in xmldb:get-child-collections($collection)
    return (
        local:setPermissions(concat($collection,'/',$childcollection),$collectionOwner,$collectionPermissions,$resourceOwner,$resourcePermissions)
    )
};

local:setPermissions($target,'admin:dba','rwxr-xr-x','admin:dba','rw-r--r--')
