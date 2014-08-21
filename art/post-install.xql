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
import module namespace xmldb       = "http://exist-db.org/xquery/xmldb";
import module namespace sm          = "http://exist-db.org/xquery/securitymanager";
import module namespace repo        = "http://exist-db.org/xquery/repo";
import module namespace adserver    = "http://art-decor.org/ns/art-decor-server" at "api/api-server-settings.xqm";
import module namespace adpfix      = "http://art-decor.org/ns/art-decor-permissions" at "api/api-permissions.xqm";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
(:install path for art (/db, /db/apps), no trailing slash :)
declare variable $root := repo:get-root();

declare function local:copy($source as xs:string, $target as xs:string, $base as xs:boolean) {
    let $dirName       := tokenize($source,'/')[last()]
    let $targetDirName := if ($base) then $target else (concat($target,'/',$dirName))
    let $createDir     := 
        if (not(xmldb:collection-available($targetDirName))) then
            xmldb:create-collection(string-join(tokenize($targetDirName,'/')[not(position()=last())],'/'),tokenize($targetDirName,'/')[last()])
        else ()
    let $copyResources :=
        for $r in xmldb:get-child-resources($source)
        return
            if (not($r=xmldb:get-child-resources($targetDirName))) then
                xmldb:copy($source,$targetDirName,$r)
            else ()
    let $copyCollections :=
        for $c in xmldb:get-child-collections($source)
        return
            local:copy(concat($source,'/',$c),$targetDirName, false())
    
    return ()
};

declare function local:storeSettings() {
    let $source          := concat($root,'art/install-data')
    let $targetDirName   := concat($root,'art-data')
    let $copyResources   :=
        for $r in xmldb:get-child-resources($source)
        return
            if (not($r=xmldb:get-child-resources($targetDirName))) then
                xmldb:copy($source,$targetDirName,$r)
            else ()
    let $copyCollections :=
        for $c in xmldb:get-child-collections($source)
        return
            local:copy(concat($source,'/',$c),$targetDirName,false())
    
    return ()
};

(: check if message collection exists, if not then create and set permissions :)
local:copy(concat($root,'art/install-data'),concat($root,'art-data'), true()),
adpfix:setArtPermissions(),
adpfix:setDecorPermissions(),
adserver:mergeServerSettings()
