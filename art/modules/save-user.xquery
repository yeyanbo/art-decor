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

declare namespace sm           = "http://exist-db.org/xquery/securitymanager";

let $propDescription      := xs:anyURI('http://exist-db.org/security/description')
let $userInfo             := if (request:exists()) then (request:get-data()/user) else ()
(:let $userInfo :=
    <user name="test" active="true" newpwd="" newpwd-confirm="">
        <!-- account-info -->
        <groups>guest</groups>
        <primarygroup>guest</primarygroup>
        <description>test</description>
        
        <!-- user-info -->
        <defaultLanguage>{$get:strArtLanguage}</defaultLanguage>
        <displayName>Test user</displayName>
        <email></email>
        <organization>Test organization</organization>
    </user>:)
    
let $userName            := $userInfo[string-length(@name)>0]/@name/string()
let $userPwd             := $userInfo[string-length(@newpwd)>0][@newpwd=@newpwd-confirm]/@newpwd/string()

let $userIsActive        := if ($userInfo/@active castable as xs:boolean) then (xs:boolean($userInfo/@active)) else true()
let $userGroups          := tokenize($userInfo/groups,'\s')
(: Note the primary group you set should exist. If it does not exist, the primary group will default
   to the first group that the user happens to be in based on the request :)
let $userPrimaryGroup    := $userInfo/primarygroup[string-length()>0]/text()
let $userDescription     := if ($userInfo/description[string-length()>0]) then $userInfo/description/text() else ('')

(: user-info Initially set by the admin that creates the account, but also user editable from there on :)
let $userLanguage        := $userInfo/defaultLanguage[string-length()>0]/text()
let $userDisplayName     := $userInfo/displayName[string-length()>0]/text()
let $userEmail           := $userInfo/email[string-length()>0]/text()
let $userOrganization    := $userInfo/organization[string-length()>0]/text()

(: Save user details for all users except SYSTEM :)
let $userSaved           :=
    if (not(sm:user-exists($userName)) and not($userName='SYSTEM') and exists($userName) and exists($userPwd)) then (
        (:new user:)
        let $actionCreate        := sm:create-account($userName,$userPwd,$userGroups)
        let $actionPrimaryGroup  := if (exists($userPrimaryGroup)) then (sm:set-user-primary-group($userName,$userPrimaryGroup)) else ()
        let $actionDescription   := sm:set-account-metadata($userName,$propDescription,$userDescription)
        
        let $actionActivate      := sm:set-account-enabled($userName,$userIsActive)
        
        (: Cannot add user-info before the user exists, so make this last step :)
        let $updatedExtraInfo    := aduser:setUserInfo($userName, $userLanguage, $userDisplayName, $userEmail, $userOrganization)
        
        return true()
    ) 
    else if (sm:user-exists($userName) and not($userName='SYSTEM') and exists($userName)) then (
        (:updated user:)
        let $currentGroups       := sm:get-user-groups($userName)
        
        let $actionAddGroups     := 
            for $group in $userGroups[not(.=$currentGroups)]
            return
                sm:add-group-member($group,$userName)
        
        let $actionRemoveGroups  := 
            for $group in $currentGroups[not(.=$userGroups)]
            return
                sm:remove-group-member($group,$userName)
        
        let $actionPrimaryGroup  := if (exists($userPrimaryGroup)) then (sm:set-user-primary-group($userName,$userPrimaryGroup)) else ()
        let $actionDescription   := sm:set-account-metadata($userName,$propDescription,$userDescription)
        
        let $actionActivate      := sm:set-account-enabled($userName,$userIsActive)
        let $actionPwdUpdate     := if (exists($userPwd)) then (sm:passwd($userName,$userPwd)) else ()
        
        (: Update user-info :)
        let $updatedExtraInfo    := aduser:setUserInfo($userName, $userLanguage, $userDisplayName, $userEmail, $userOrganization)
        
        return true()
    ) 
    else (
        false()
    )

return
    <data-safe>{$userSaved}</data-safe>