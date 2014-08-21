xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "xmldb:exist:///db/apps/art/modules/art-decor-settings.xqm";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xforms="http://www.w3.org/2002/xforms";

declare namespace request = "http://exist-db.org/xquery/request";

let $registryName := if (request:exists()) then request:get-parameter('registry', ()) else ()
(:let $registry := 'nictiz':)

let $lookupFiles  := 
    for $oids in collection($get:strOidsData)//myoidregistry[not($registryName) or @name=$registryName]//oid
    let $lookupContent :=
        <oidList>
        {
            for $oid in $oids
            return
            <oid oid="{$oid/dotNotation/@value}">
            {
                for $desc in $oid/description
                return
                    <name language="{$desc/@language}">{
                        if ($desc/thumbnail[@value]) then 
                            $desc/thumbnail/@value/string() 
                        else (
                            substring($desc/@value/string(),1,200),
                            if (string-length($desc/@value/string())>200) then '...' else()
                        )
                    }</name>
                (:,
                for $lang in ('nl-NL','de-DE','en-US')[not(.=$oid/description/@language)]
                return
                    <name language="{$lang}">{
                        if ($oid/description[1]/thumbnail[@value]) then 
                            $oid/description[1]/thumbnail/@value/string() 
                        else (
                            substring($oid/description[1]/@value/string(),1,200),
                            if (string-length($oid/description[1]/@value/string())>200) then '...' else()
                        )
                    }</name>:)
            }
            {
                for $desc in $oid/description
                return
                    <desc language="{$desc/@language}">{$desc/@value/string()}</desc>
                (:,
                for $lang in ('nl-NL','de-DE','en-US')[not(.=$oid/description/@language)]
                return
                    <desc language="{$lang}">{$oid/description[1]/@value/string()}</desc>:)
            }
            </oid>
        }
        </oidList>
    group by $regName  := $oids/ancestor::myoidregistry/@name
    return
        <registry name="{$regName}">{xmldb:store(concat($get:strOidsData,'/'), concat($regName, 'oids-lookup.xml'), $lookupContent)}</registry>

return
<result>{$lookupFiles}</result>
