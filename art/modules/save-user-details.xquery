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

let $userInfo             := if (request:exists()) then (request:get-data()/user) else ()
(:let $userInfo :=
    <user name="test" active="true">
        <!-- user-info -->
        <defaultLanguage>{$get:strArtLanguage}</defaultLanguage>
        <displayName>Test user</displayName>
        <email></email>
        <organization>Test organization</organization>
        <projects>
            <project prefix="sandbox-" name="Sandbox" email="xxx@yyy.nl"/>
        </projects>
    </user>:)
    
let $userName            := $userInfo[string-length(@name)>0]/@name/string()

(: user-info Initially set by the admin that creates the account, but also user editable from there on :)
let $userLanguage        := $userInfo/defaultLanguage[string-length()>0]/text()
let $userDisplayName     := $userInfo/displayName[string-length()>0]/text()
let $userEmail           := $userInfo/email[string-length()>0]/text()
let $userOrganization    := $userInfo/organization[string-length()>0]/text()

(: Save user details for all users except SYSTEM :)
let $userSaved           :=
    if (sm:user-exists($userName) and not($userName='SYSTEM') and exists($userName)) then (
        (: Update user-info :)
        let $updatedExtraInfo    := aduser:setUserInfo($userName, $userLanguage, $userDisplayName, $userEmail, $userOrganization)
        
        let $updatedProjects     :=
            for $project in $userInfo/projects/project
            let $matchingAuthor  := $get:colDecorData//project[@prefix=$project/@prefix]/author[@username=$userName]
            let $emailUpdate     :=
                if (exists($project/@email[string-length()>0])) then (
                    if (exists($matchingAuthor/@email)) then ( 
                        update value $matchingAuthor/@email with $project/@email
                    ) else (
                        update insert attribute email {$project/@email} into $matchingAuthor
                    )
                ) else if (exists($matchingAuthor/@email)) then (
                    update delete $matchingAuthor/@email
                ) else (
                    (:nothing to do:)
                )
            let $notifierUpdate  :=
                if (exists($project/@notifier[string-length()>0])) then (
                    if (exists($matchingAuthor/@notifier)) then ( 
                        update value $matchingAuthor/@notifier with $project/@notifier
                    ) else (
                        update insert attribute notifier {$project/@notifier} into $matchingAuthor
                    )
                ) else if (exists($matchingAuthor/@notifier)) then (
                    update delete $matchingAuthor/@notifier
                ) else (
                    (:nothing to do:)
                )
            return ()
        
        return true()
    ) 
    else (
        false()
    )

return
    <data-safe>{$userSaved}</data-safe>