xquery version "3.0";
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
import module namespace sm = "http://exist-db.org/xquery/securitymanager";
import module namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace xis="http://art-decor.org/ns/xis";
import module namespace repo="http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
declare variable $root := repo:get-root();

(: helper function for setting write permissions :)
declare function local:setPermissions() {
    (: 754 == -rwxr-xr-- :)
    
    for $x in xmldb:get-child-resources(concat($root,'/temple/modules'))
    return (
        sm:chown(xs:anyURI(concat('xmldb:exist:///',$root,'/temple/modules/',$x)),'admin'),
        sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$root,'/temple/modules/',$x)),'dba'),
        sm:chmod(xs:anyURI(concat('xmldb:exist:///',$root,'/temple/modules/',$x)),sm:octal-to-mode('0754')),
        sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$root,'/temple/modules/',$x)))
    )
};

local:setPermissions()

