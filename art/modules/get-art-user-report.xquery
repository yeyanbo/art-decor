xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai Heitmann, Alexander Henket

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

declare variable $art-languages  := art:getArtLanguages();
(: issue mailing :)
(:
import module namespace im ="http://art-decor.org/ns/artxtra" at "/mailsignal-issues.xqm";
:)

declare function local:copyMultiLanguageNode($textWithMarkupNodeSet as node()*) as node()* {
    if (empty($textWithMarkupNodeSet)) then () 
    else (
        let $nodeName := name(($textWithMarkupNodeSet/.)[1])
        let $result := 
            <r>
            {
                for $language in $art-languages
                return
                    <x language="{$language}">
                    {
                        if (($textWithMarkupNodeSet/.)[@language=$language]) then (
                            ($textWithMarkupNodeSet/.)[@language=$language])/node() 
                        else (
                            ($textWithMarkupNodeSet/.)[1]/node()
                        )
                    }
                    </x>
            }
            </r>
           
        return
            for $n in $result/x
            return
                element {$nodeName} {
                    attribute language {$n/@language},
                    util:serialize($n/node(), 'method=xhtml encoding=UTF-8')
                }
    )
};

declare function local:getIssueInfo ($issue as element()) as element()* {

    <wrap>
    {
        for $object in $issue/object
            let $objectEffDate :=
                if ($object/@effectiveDate != '') then (
                    $object/@effectiveDate/string()
                ) else ()
            
            (: optimization. if we let it search without being specific, then performance decreases drastically :)
            let $objectContent := 
                if ($object/@type='VS') then (
                    (:get valueset:)
                    ($issue/ancestor::decor/terminology/valueSet[@id=$object/@id][@effectiveDate=$objectEffDate])[1]
                ) else if ($object/@type='DE') then (
                    (:get data element (dataset concept):)
                    ($issue/ancestor::decor/datasets//concept[@id=$object/@id][@effectiveDate=$objectEffDate][not(ancestor::history)])[1]
                ) else if ($object/@type='TM') then (
                    (:get template:)
                    ($issue/ancestor::decor/rules/template[@id=$object/@id][@effectiveDate=$objectEffDate])[1]
                ) else if ($object/@type='EL') then (
                    (:get template element:)
                    ($issue/ancestor::decor/rules/template//element[@id=$object/@id])[1]
                ) else if ($object/@type='TR' and empty($objectEffDate)) then (
                    (:get transaction:)
                    ($issue/ancestor::decor/scenarios//transaction[@id=$object/@id])[1]
                ) else if ($object/@type='TR') then (
                    (:get transaction:)
                    ($issue/ancestor::decor/scenarios//transaction[@id=$object/@id][@effectiveDate=$objectEffDate])[1]
                ) else if ($object/@type='DS') then (
                    (:get dataset:)
                    ($issue/ancestor::decor/datasets/dataset[@id=$object/@id][@effectiveDate=$objectEffDate])[1]
                ) else if ($object/@type='SC') then (
                    (:get scenario:)
                    ($issue/ancestor::decor/scenarios/scenario[@id=$object/@id][@effectiveDate=$objectEffDate])[1]
                ) else if ($object/@type='IS') then (
                    (:get issue:)
                    ($issue/ancestor::decor/issues/issue[@id=$object/@id][@effectiveDate=$objectEffDate])[1]
                ) else if (empty($objectEffDate)) then (
                    (:get any -- performance hit!:)
                    ($issue/ancestor::decor//*[@id=$object/@id][not(ancestor::history or self::object)])[1]
                ) else (
                    (:get any -- performance hit!:)
                    ($issue/ancestor::decor//*[@id=$object/@id][@effectiveDate=$objectEffDate][not(ancestor::history or self::object)])[1]
                )
         return
            <object>
            {
                $object/@*
                ,
                if ($object/@type='DE') then
                    let $concept := $objectContent
                    return
                    <dataset>
                    {
                        $concept/ancestor::dataset/@id,
                        $concept/ancestor::dataset/name
                    }
                    </dataset>
                else (
                    $objectContent/name
                )
            }
            </object>
    }
    {
        for $event in $issue/*[not(name()='object')]
        order by $event/xs:dateTime(@effectiveDate)
        return
            $event
    
    }
    </wrap>
};

let $user            := if (request:exists()) then (request:get-parameter('user',())[1]) else ()
let $user            := 
    if (string-length($user)>0) then 
        $user 
    else if (string-length(xmldb:get-current-user())>0) then 
        xmldb:get-current-user() 
    else (
        'guest'
    )
let $comefrom        := if (request:exists()) then (request:get-parameter('comefrom',())) else ()

let $now             := current-dateTime()
let $userLastlogin   := if ($user != 'guest') then aduser:getUserLastLoginTime($user) else ()
let $userDisplayName := aduser:getUserDisplayName($user)

return
<report>
{
(: --------- user id test --------- :)
    <userid>{$user}</userid>,
    <displayName>{if (string-length($userDisplayName)=0) then $user else $userDisplayName}</displayName>
}
{
    <userupdate comefrom="{$comefrom}">
    {
        (: we come from login, add last login record :)
        if ($comefrom='login' and $user != 'guest') then (
            aduser:setUserLastLoginTime($now)
        ) else ()
    }
    </userupdate>
}
{
    (: --------- last login --------- :)
    <lastlogin>{$userLastlogin}</lastlogin>
}
{
    if ($user != 'guest') then
        (: --------- email test --------- :)
        (:
        try {
        if ( mail:send-email($message, 'localhost', ()) ) then
            <email>Sent Message OK :-)</email>
        else
            <email>Could not Send Message :-(</email>
        } catch * {
            <error>Caught error {$err:code}: {$err:description}</error>
        }
        :)
        <email>verified</email>
    else ()
}
{
    if ($user='guest') then () else (
        (:list of decor projects where user is author:)
        for $decor in $get:colDecorData//decor[project/author/@username=$user]
        let $projectId      := $decor/project/@id
        let $projectPrefix  := $decor/project/@prefix
        let $projectLang    := $decor/project/@defaultLanguage
        (: get author info for this project - note that user guest may lead to multiple authors... :)
        let $authorId       := $decor/project/author[@username=$user]/@id
        let $authorUsername := $user
        let $authorEmail    := $decor/project/author[@username=$user]/@email
        let $lastVersion    := max($decor/project/(release|version)/xs:dateTime(@date))
        order by $decor/project/name[1]
        return
        <project prefix="{$projectPrefix}" defaultLanguage="{$projectLang}" authorid="{$authorId}" authorUsername="{$authorUsername}" authoremail="{$authorEmail}" lastVersion="{$lastVersion}">
        {
            local:copyMultiLanguageNode($decor/project/name),
      
            (: --------- community collections --------- :)
            for $c in $get:colDecorData//community[@projectId=$projectId][access/author/@username=$authorUsername]
            return
                <community>
                {
                    $c/@*,
                    for $data in $c/desc
                    return
                        art:serializeNode($data),
                    $c/access
                }
                </community>,
    
            for $issue in $decor//issue
            let $firstTracking          := ($issue/tracking[@effectiveDate=min($issue/tracking/xs:dateTime(@effectiveDate))])[1]
            let $lastAssignment         := ($issue/assignment[@effectiveDate=max($issue/assignment/xs:dateTime(@effectiveDate))])[1]
            let $lastTracking           := ($issue/tracking[@effectiveDate=max($issue/tracking/xs:dateTime(@effectiveDate))])[1]
            let $lastEvent              := ($issue/(tracking|assignment)[@effectiveDate=max($issue/(tracking|assignment)/xs:dateTime(@effectiveDate))])[1]
            
            let $lastEventAuthorId      := $lastEvent/author/@id
            let $lastEventAuthorName    := 
                if ($decor/project/author[@id=$lastEventAuthorId]) then
                    $decor/project/author[@id=$lastEventAuthorId]/text()
                else
                    $lastEvent/author/text()
            
            let $currentType            := $issue/@type
            let $currentPriority        := if (string-length($issue/@priority)>0) then ($issue/@priority/string()) else ('N')
            let $currentStatus          := $lastTracking/@statusCode
            let $currentLabels          := $lastEvent/@labels
            
            let $issueAuthorId          := $firstTracking/author/@id
            let $issueAuthorUserName    := $decor/project/author[@id=$issueAuthorId]/@username
            let $issueAssignedId        := $lastAssignment/@to
            let $issueAssignedUserName  := $decor/project/author[@id=$issueAssignedId]/@username
            let $issueAssignedName      := 
                if ($decor/project/author[@id=$issueAssignedId]) then
                    $decor/project/author[@id=$issueAssignedId]/text()
                else
                    $lastAssignment/@name
                    
            let $userIsSubscribed       := aduser:userHasIssueSubscription($issue/@id)
            let $userAutoSubscribes     := aduser:userHasIssueAutoSubscription($projectPrefix, $issue/@id, $issue/object/@type, $issueAuthorUserName, $issueAuthorUserName)
            
            return
                (:do not list cancelled, closed, rejected:)
                if (not($lastTracking[@statusCode='cancelled'] | $lastTracking[@statusCode='closed'] | $lastTracking[@statusCode='rejected'])) then 
                    if ($lastAssignment/@to=$authorId) then
                        <assignedIssue id="{$issue/@id}" 
                            priority="{$currentPriority}" 
                            displayName="{$issue/@displayName}" 
                            type="{$currentType}" 
                            currentStatusCode="{$currentStatus}"
                            currentLabels="{$currentLabels}" 
                            lastDate="{$lastEvent/@effectiveDate}" 
                            lastAuthorId="{$lastEventAuthorId}"
                            lastAuthor="{$lastEventAuthorName}" 
                            lastAssignmentId="{$issueAssignedId}"
                            lastAssignment="{$issueAssignedName}"
                            currentUserIsSubscribed="{$userIsSubscribed}"
                            currentUserAutoSubscribes="{$userAutoSubscribes}">
                            
                        {   
                            local:getIssueInfo($issue)/node()
                        }
                        </assignedIssue>
                    else if ($firstTracking/author/@id=$authorId) then
                        <createdIssue id="{$issue/@id}" 
                            priority="{$currentPriority}" 
                            displayName="{$issue/@displayName}" 
                            type="{$currentType}" 
                            currentStatusCode="{$currentStatus}"
                            currentLabels="{$currentLabels}" 
                            lastDate="{$lastEvent/@effectiveDate}" 
                            lastAuthorId="{$lastEventAuthorId}"
                            lastAuthor="{$lastEventAuthorName}" 
                            lastAssignmentId="{$issueAssignedId}"
                            lastAssignment="{$issueAssignedName}"
                            currentUserIsSubscribed="{$userIsSubscribed}"
                            currentUserAutoSubscribes="{$userAutoSubscribes}">
                        {   
                            local:getIssueInfo($issue)/node()
                        }
                        </createdIssue>
                    else ()
                else ()
        }
        </project>
    )
}
</report>