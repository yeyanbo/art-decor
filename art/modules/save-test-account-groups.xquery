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
import module namespace get    = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace aduser = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";

declare namespace sm  = "http://exist-db.org/xquery/securitymanager";
declare namespace xis = "http://art-decor.org/ns/xis";

let $accounts       := doc($get:strTestAccounts)/xis:testAccounts
(: create collections and groups if needed :)
let $groups :=
    for $account in $accounts/xis:testAccount
    let $accountName    := $account/@name/string()
    let $accountMembers := sm:get-group-members($accountName)
    let $memberList     :=
        <members xmlns="http://art-decor.org/ns/xis">
        {
            for $member in $accountMembers
            let $memberName := aduser:getUserDisplayName($member)
            order by $member
            return
                <user id="{$member}">{if (empty($memberName)) then $member else ($memberName)}</user>
        }
        </members>
    return
        update replace $account/xis:members with $memberList
        
return
    <data-safe>true</data-safe>
