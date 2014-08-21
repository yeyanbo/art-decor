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

import module namespace get    = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace aduser = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";
declare namespace sm           = "http://exist-db.org/xquery/securitymanager";
declare namespace request      = "http://exist-db.org/xquery/request";
declare namespace response     = "http://exist-db.org/xquery/response";


let $test   := request:get-data()
let $user   := 
    if ($test//username/text()) then
        $test//username/text()
    else ('guest')
    
let $pwd    := 
    if ($test//password/text()) then
        $test//password/text()
    else('guest')
let $create := session:create()

return
if (xmldb:authenticate('/db',$user,$pwd)) then
    let $login            := xmldb:login('/db',$user,$pwd,xs:boolean('true'))
    let $username         := xmldb:get-current-user()
    let $userLanguage     := aduser:getUserLanguage($username)
    let $userDisplayName  := aduser:getUserDisplayName($username)
    let $groups           := sm:get-user-groups($username)
    return
        <user>
            <username>{$username}</username>
            <defaultLanguage>{$userLanguage}</defaultLanguage>
            <displayName>{$userDisplayName}</displayName>
            <groups>{$groups}</groups>
            <password>{$pwd}</password>
            <logged-in>true</logged-in>
        </user>
else (
    let $logout   := session:invalidate()
    (:let $username := xmldb:get-current-user():)
    (:let $groups   := sm:get-user-groups($user):)
    return
        <user>
            <username>{$user}</username>
            <defaultLanguage>{$get:strArtLanguage}</defaultLanguage>
            <displayName></displayName>
            <groups></groups>
            <password></password>
            <logged-in>false</logged-in>
        </user>
)

