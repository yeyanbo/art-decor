xquery version "1.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
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
import module namespace art    = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace aduser = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";

let $projectId        := request:get-parameter('projectId','')
(:let $projectId        := '2.16.840.1.113883.2.4.3.11.60.90':)
let $communityName    := request:get-parameter('name','')
let $breakLock        := request:get-parameter('breakLock','false')
(:let $communityName    := 'prn':)

(: username and user info for use in conceptLock:)
let $username         := xmldb:get-current-user()
let $userDisplayName  := aduser:getUserDisplayName($username)

(: check if community is locked :)
let $lock      := $get:colArtResources//communityLock[@ref=$communityName][@projectId=$projectId]
let $community := $get:colDecorData//community[@projectId=$projectId][@name=$communityName][access/author/@username=$username]
let $response  :=
    if (empty($lock) or $lock/@user=$username or $breakLock='true') then
        let $newLock    := <communityLock ref="{$communityName}" projectId="{$projectId}" user="{$username}" userName="{$userDisplayName}" since="{current-dateTime()}"/>
        let $deleteLock := if ($lock) then update delete $lock else ()
        let $insertLock := update insert $newLock into $get:colArtResources//decorLocks
        
        return
        <community>
        {
            $community/@*,
            if (not($community/@displayName)) then
                attribute displayName {''}
            else()
        }
            <edit/>
        {
            $newLock,
            for $data in $community/desc
            return
                art:serializeNode($data),
            $community/access
        }
            <prototype>
            {
                for $data in $community/prototype/data
                return
                    <data>
                    {
                        $data/@*,
                        if($community//association/data[@type=$data/@type]) then
                            <used/>
                        else(),
                        for $desc in $data/desc
                        return
                            art:serializeNode($desc)
                    }
                    </data>
            }
            </prototype>
            <associations>
            {
                for $association in $community/associations/association
                return
                    <association>
                    {
                        $association/object,
                        for $data in $association/data
                        return
                            art:serializeNode($data)
                    }
                    </association>
            }
            </associations>
        </community>
    else (
        <community>{$lock}</community>
    )

return
$response