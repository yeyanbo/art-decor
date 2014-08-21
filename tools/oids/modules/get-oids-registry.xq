xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Alexander Henket, Kai Heitmann
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
declare namespace xs        = "http://www.w3.org/2001/XMLSchema";
declare namespace xforms    = "http://www.w3.org/2002/xforms";
declare namespace request   = "http://exist-db.org/xquery/request";
declare option exist:serialize "method=xml media-type=text/xml";

let $registry           := if (request:exists()) then request:get-parameter('registry', ()) else ()
let $registry           := if (count($registry)>1) then () else $registry
let $registrycollection := collection($get:strOidsData)//myoidregistry[@name=$registry]

let $theregistry        := 
    if (exists($registrycollection)) then (
        <registry total="{count($registrycollection/registry/oid)}">
        {
            $registrycollection/registry/@*,
            $registrycollection/registry/*[not(name()='oid')]
        }
        {
            for $oiddata in subsequence($registrycollection/registry/oid,1,100)
            return
                <oid status="{$oiddata/status[1]/@code/string()}" dotNotation="{$oiddata/dotNotation[1]/@value/string()}">
                {
                    $oiddata/description
                }
                </oid>
        }
        </registry>
    )
    else (
        <registry/>
    )

return
    $theregistry