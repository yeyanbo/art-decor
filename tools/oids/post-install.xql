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
import module namespace sm      = "http://exist-db.org/xquery/securitymanager";
import module namespace xmldb   = "http://exist-db.org/xquery/xmldb";
import module namespace repo    = "http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
declare variable $root := repo:get-root();

declare function local:buildLookupFiles() {
let $strOidsData        := concat($root,'tools/oids-data')
let $registryCollection := collection($strOidsData)/myoidregistry

let $handleLookup       :=
    for $registry in $registryCollection
    let $lookupResourceName  := concat($registry/@name/string(), 'oids-lookup.xml')
    let $lookupContent       :=
        <oidList name="{$registry/@name/string()}">
        {
            for $oid in $registry//oid
            return
            <oid oid="{$oid/dotNotation/@value}">
            {
                for $desc in $oid/description
                return (
                    <name language="{$desc/@language}">{
                        if ($desc/thumbnail[@value]) then 
                            $desc/thumbnail/@value/string() 
                        else (
                            substring($desc/@value/string(),1,200),
                            if (string-length($desc/@value/string())>200) then '...' else()
                        )
                    }</name>,
                    <desc language="{$desc/@language}">{$desc/@value/string()}</desc>
                )
            }
            </oid>
        }
        </oidList>
    let $removeCurrentLookup := 
        if (doc-available(concat($strOidsData,'/',$lookupResourceName))) then 
            xmldb:remove($strOidsData,$lookupResourceName)
        else ()
    return
        xmldb:store($strOidsData,$lookupResourceName,$lookupContent)

return ()
};

local:buildLookupFiles()


