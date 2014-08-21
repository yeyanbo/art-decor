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

import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace aduser  = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";

let $request                := request:get-data()/issue

let $decor                  := $get:colDecorData//decor[project/@prefix=$request/@project]
let $prefix                 := $decor/project/@prefix
let $issueRoot              := $decor/ids/defaultBaseId[@type='IS']/@id/string()
let $issueIds               := 
    for $id in $decor/issues/issue/@id/string()
    return
        if (substring-after($id,concat($issueRoot,'.')) castable as xs:integer) then
            xs:integer(substring-after($id,concat($issueRoot,'.')))
        else()

(:let $maxId := max($decor/issues/issue/xs:integer(substring-after(@id,concat($issueRoot,'.')))):)
let $newId                  := 
    if (count($decor/issues/issue)>0) then
        concat($issueRoot,'.',max($issueIds)+1)
    else(concat($issueRoot,'.',1))
let $nowTracking            := datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")
let $nowAssignment          := datetime:format-dateTime(current-dateTime()+xs:dayTimeDuration('PT1S'),"yyyy-MM-dd'T'HH:mm:ss")
let $issueAuthorId          := $request/tracking/author/@id
let $issueAuthorUserName    := $decor/project/author[@id=$issueAuthorId]/@username
let $issueAssignedId        := $request/tracking/@to[string-length()>0]
let $issueAssignedUserName  := $decor/project/author[@id=$issueAssignedId]/@username
let $issueAssignedName      := $decor/project/author[@id=$issueAssignedId]/string()

let $newIssue               :=
    <issue id="{$newId}" priority="{$request/@priority}" displayName="{$request/@displayName}" type="{$request/@type}">
    {
        if ($request/object) then
            <object id="{$request/object/@id}" type="{$request/object/@type}">
            {
                if (string-length($request/object/@effectiveDate)>0) then ($request/object/@effectiveDate) else (),
                if (string-length($request/object/@name)>0) then ($request/object/@name) else ()
            }
            </object>
        else()
    }
        <tracking effectiveDate="{$nowTracking}" statusCode="open">
        {
            if (string-length($request/tracking/@labels)>0) then ($request/tracking/@labels) else ()
        }
            <author id="{$issueAuthorId}">{$request/tracking/author/text()}</author>
        {
            for $desc in $request/tracking/desc
            return
                art:parseNode($desc)
        }
        </tracking>
    {
        if ($issueAssignedId) then (
            <assignment to="{$issueAssignedId}" name="{$issueAssignedName}" effectiveDate="{$nowAssignment}">
            {
                if (string-length($request/tracking/@labels)>0) then ($request/tracking/@labels) else ()
            }
                <author id="{$issueAuthorId}">{$request/tracking/author/text()}</author>
            {
                <desc language="{($request/tracking/desc[1])/@language}"/>
            }
            </assignment>
        ) else ()
    }
    </issue>

return
<response>
{
    if (not($decor/issues)) then
        <insert>
        {
           update insert <issues/> into $decor,
           update insert $newIssue into $decor/issues
        }
        </insert>
    else (
        update insert $newIssue into $decor/issues
    )
    ,
    for $authorUserName in $decor/project/author/@username
    let $userAutoSubscribes := aduser:userHasIssueAutoSubscription($authorUserName, $prefix, $newId, $newIssue/object/@type, $issueAuthorUserName, $issueAssignedUserName)
    return
        if ($userAutoSubscribes) then
            aduser:setUserIssueSubscription($authorUserName, $newId)
        else ()
}
</response>