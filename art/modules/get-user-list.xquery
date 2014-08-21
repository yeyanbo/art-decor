xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai U. Heitmann, Alexander Henket

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
declare namespace sm           = "http://exist-db.org/xquery/securitymanager";
declare namespace config       = "http://exist-db.org/Configuration";

let $accounts      := sm:list-users()

(: Return user details for all users except SYSTEM :)

return
<users>
{
    for $account in $accounts[not(.='SYSTEM')]
    let $userDisplayName      := 
        if (aduser:getUserDisplayName($account)[string-length()>0]) 
        then (aduser:getUserDisplayName($account)) 
        else ($account)
    let $userEmail            := aduser:getUserEmail($account)
    order by $userDisplayName
    return
    <user name="{$account}">
        <displayName>{$userDisplayName}</displayName>
        <email>{$userEmail}</email>
    </user>
}
</users>


