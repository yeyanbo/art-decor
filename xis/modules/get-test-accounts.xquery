xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace sm  = "http://exist-db.org/xquery/securitymanager";
declare namespace xis = "http://art-decor.org/ns/xis";
declare namespace xs  = "http://www.w3.org/2001/XMLSchema";

let $testAccounts := doc($get:strTestAccounts)
let $dummy        := 
    if (sm:has-access(xs:anyURI($get:strTestAccounts),'rwx')) then
        for $xisCfg in $testAccounts//xis:xis
        let $dummy := 
            if (not($xisCfg/xis:xmlValidation)) then 
                update insert element {QName('http://art-decor.org/ns/xis','xmlValidation')} {true()} following $xisCfg/*[last()] 
            else ()
        let $dummy := 
            if (not($xisCfg/xis:getMessageXml)) then
                update insert element {QName('http://art-decor.org/ns/xis','getMessageXml')} {true()} following $xisCfg/*[last()]
            else ()
        let $dummy :=
            for $node in $xisCfg/../xis:application[not(@organizationRegisterId)]
            return
                update insert attribute organizationRegisterId {''} into $node
        return ()
    else ()

return
    $testAccounts