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

import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace aduser  = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";

let $request                := request:get-data()/issue
let $action                 := request:get-parameter('action',())

(:let $request :=
        <issue id="2.16.840.1.113883.2.4.6.99.1.77.6.5" priority="N" displayName="test" type="RFC">
            <object id="2.16.840.1.113883.2.4.6.99.1.77.2.20000" type="DE" effectiveDate="2010-09-24"/>
            <tracking effectiveDate="2012-01-19T13:36:40.291+01:00" statusCode="open">
                <author id="2">Gerrit Boers</author>
                <desc language="nl-NL">dfbsdfg<b>sadfgdsfg</b>
                    <sub>d</sub>
                </desc>
            </tracking>
        </issue>:)
let $issueId                := $request/@id
let $existingIssue          := $get:colDecorData//issue[@id=$issueId]
let $decor                  := $existingIssue/ancestor::decor
let $prefix                 := $decor/project/@prefix

let $issueAuthorId          := $request/tracking[@effectiveDate=min($request/tracking/xs:dateTime(@effectiveDate))]/author/@id
let $issueAuthorUserName    := $decor/project/author[@id=$issueAuthorId]/@username
let $issueAssignedId        := $request/assignment[@effectiveDate=max($request/assignment/xs:dateTime(@effectiveDate))]/@to
let $issueAssignedUserName  := $decor/project/author[@id=$issueAssignedId]/@username

let $newIssue       :=
    <issue id="{$request/@id}" priority="{$request/@priority}" displayName="{$request/@displayName}" type="{$request/@type}">
    {
        for $object in $request/object
        return
            <object id="{$object/@id}" type="{$object/@type}">
            {
                if (string-length($object/@effectiveDate)>0) then ($object/@effectiveDate) else (),
                if (string-length($object/@name)>0) then ($object/@name) else ()
            }
            </object>,
        for $event in $request/tracking|$request/assignment
        order by xs:dateTime($event/@effectiveDate) ascending
        return
            if (name($event)='tracking') then
                <tracking effectiveDate="{$event/@effectiveDate}" statusCode="{$event/@statusCode}">
                {
                    if (string-length($event/@labels)>0) then ($event/@labels) else (), 
                    $event/author
                }
                {
                    for $desc in $event/desc
                    return
                        art:parseNode($desc)
                }
                </tracking>
            else if (name($event)='assignment') then
                <assignment to="{$event/@to}" name="{$event/@name}" effectiveDate="{$event/@effectiveDate}">
                {
                    if (string-length($event/@labels)>0) then ($event/@labels) else (),
                    $event/author
                }
                {
                    for $desc in $event/desc
                    return
                        art:parseNode($desc)
                }
                </assignment>
            else ()
    }
    </issue>
return
<response>
{
    if ($action='update-displayname') then (
        update value $existingIssue/@displayName with $newIssue/@displayName
    ) else (
        update replace $existingIssue with $newIssue
        ,
        for $authorUserName in $decor/project/author/@username
        let $userAutoSubscribes := aduser:userHasIssueAutoSubscription($authorUserName, $prefix, $issueId, $newIssue/object/@type, $issueAuthorUserName, $issueAuthorUserName)
        return
            if ($userAutoSubscribes) then
                aduser:setUserIssueSubscription($authorUserName, $issueId)
            else ()
    )
}
</response>