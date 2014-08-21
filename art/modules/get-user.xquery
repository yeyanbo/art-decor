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

let $propDescription      := xs:anyURI('http://exist-db.org/security/description')
let $userName             := if (request:exists()) then (request:get-parameter('user',xmldb:get-current-user())[1]) else (xmldb:get-current-user())

return
    if (sm:is-authenticated() and sm:user-exists($userName) and not($userName='SYSTEM')) then (
        (: Return user details for all users except SYSTEM :)
        let $userIsActive         := sm:is-account-enabled($userName)
        
        let $userDisplayName      := aduser:getUserDisplayName($userName)
        let $userEmail            := aduser:getUserEmail($userName)
        let $userOrganization     := aduser:getUserOrganization($userName)
        let $userLanguage         := aduser:getUserLanguage($userName, false())
        let $userCreationDate     := aduser:getUserCreationDate($userName)
        let $userLastLogin        := aduser:getUserLastLoginTime($userName)
        let $userLastIssueNotify  := aduser:getUserLastIssueNotify($userName)
        
        return
        <user name="{$userName}" active="{$userIsActive}" newpwd="" newpwd-confirm="">
            {
                if (sm:is-dba(xmldb:get-current-user())) then (
                    <!-- account-info -->,
                    <groups>{string-join(sm:get-user-groups($userName),' ')}</groups>,
                    <primarygroup>{sm:get-user-primary-group($userName)}</primarygroup>,
                    <description>{sm:get-account-metadata($userName,$propDescription)}</description>
                ) else ()
            }
            <!-- user-info -->
            <defaultLanguage>{$userLanguage}</defaultLanguage>
            <displayName>{$userDisplayName}</displayName>
            <email>{$userEmail}</email>
            <organization>{$userOrganization}</organization>
            <creationdate>{$userCreationDate}</creationdate>
            <lastlogin>{$userLastLogin}</lastlogin>
            <lastissuenotify>{$userLastIssueNotify}</lastissuenotify>
            <projects>
            {
                for $project in $get:colDecorData//decor/project[author/@username=$userName]
                let $projectName     := 
                    if (exists($project/name[@language=$userLanguage])) then (
                        $project/name[@language=$userLanguage][1]
                    ) else (
                        $project/name[@language=$project/@defaultLanguage][1]
                    )
                let $authorEmail     := $project/author[@username=$userName]/@email/string()
                let $authorNotifier  := $project/author[@username=$userName]/@notifier/string()
                order by $projectName
                return
                    <project prefix="{$project/@prefix/string()}" name="{$projectName}" email="{$authorEmail}" notifier="{$authorNotifier}"/>
            }
            </projects>
        </user>
    ) else ()