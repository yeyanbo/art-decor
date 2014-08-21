xquery version "3.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket, Kai U. Heitmann
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

module namespace iss             = "http://art-decor.org/ns/decor/issue";

import module namespace adsearch = "http://art-decor.org/ns/decor/search" at "api-decor-search.xqm";
import module namespace aduser   = "http://art-decor.org/ns/art-decor-users" at "api-user-settings.xqm";
import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "../modules/art-decor.xqm";
import module namespace templ    = "http://art-decor.org/ns/decor/template" at "../api/api-decor-template.xqm";
import module namespace vs       = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";

declare namespace error          = "http://art-decor.org/ns/decor/issue/error";
declare namespace xs             = "http://www.w3.org/2001/XMLSchema";

(:~
:   Return zero or more issues as-is
:   
:   @param $id           - required. Identifier of the issue to retrieve
:   @return Matching issues
:   @author Alexander Henket
:   @since 2014-07-09
:)
declare function iss:getIssueById ($id as xs:string) as element(issue)* {
    $get:colDecorData//issue[@id=$id]
};

(:~
:   Return zero or more issues as-is
:   
:   @param $id            - required. Identifier of the object to retrieve the issue for
:   @param $effectiveDate - optional. Effective date of the object to retrieve the issue for
:   @return Matching issues
:   @author Alexander Henket
:   @since 2014-07-09
:)
declare function iss:getIssueByObject ($id as xs:string, $effectiveDate as xs:string?) as element(issue)* {
    if (string-length($effectiveDate)=0) then
        $get:colDecorData//object[@id=$id]/parent::issue
    else (
        $get:colDecorData//object[@id=$id][@effectiveDate=$effectiveDate]/parent::issue
    )
};

(:~
:   Return zero or more expanded issue metadata wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   server local repositories that aren't private and either refer to or define the requested template(s).
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $id           - optional. Identifier of the template to retrieve
:   @return Matching issues in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-07-09
:)
declare function iss:getIssueMetaById ($id as xs:string) as element(issue)* {
let $issues                 := iss:getIssueById($id)

for $issue in $issues
return
    iss:getIssueMeta($issue)
};

(:~
:   Return zero or more expanded issue metadata wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   server local repositories that aren't private and either refer to or define the requested template(s).
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $issue - required. The original issue
:   @return Issue with metadata as attributes and objects as-is
:   @author Alexander Henket
:   @since 2014-07-09
:)
declare function iss:getIssueMeta ($issue as element(issue)) as element(issue) {
let $decor                  := $issue/ancestor::decor
let $projectPrefix          := $decor/project/@prefix

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
    <issue  id="{$issue/@id}" 
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
        $issue/object
    }
    </issue>
};

(:~
:   Return zero or more expanded issue metadata wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   server local repositories that aren't private and either refer to or define the requested template(s).
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $id           - optional. Identifier of the template to retrieve
:   @return Matching issues in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-07-09
:)
declare function iss:getIssueList ($prefix as xs:string, $searchTerms as xs:string*, $types as xs:string*, $priorities as xs:string*, $statuscodes as xs:string*, $lastassignedids as xs:string*, $labels as xs:string*) as element(return) {
let $issues     := $get:colDecorData//decor[project/@prefix=$prefix]/issues/issue
let $allcnt     := count($issues)
let $issues     := 
    if (empty($types) or not(empty($searchTerms))) then
        $issues
    else
        $issues[@type=$types]
let $issues     :=
    if (empty($priorities) or not(empty($searchTerms))) then
        $issues
    else
        $issues[@priority=$priorities]
let $issues     := 
    if (empty($searchTerms)) then
        $issues
    else (
        let $luceneQuery    := adsearch:getSimpleLuceneQuery($searchTerms)
        let $luceneOptions  := adsearch:getSimpleLuceneOptions()
        return
        if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then
            $issues[ends-with(@id,concat('.',$searchTerms[1]))]
        else (
            $issues[ft:query(@displayName,$luceneQuery,$luceneOptions) or ft:query(*/desc,$luceneQuery,$luceneOptions)]
        )
    )

return
<return all="{$allcnt}">
{
    for $issue in $issues
    let $issuemeta  := iss:getIssueMeta($issue)
    let $return     := if (empty($statuscodes) or not(empty($searchTerms)))     then $issuemeta else $issuemeta[@currentStatusCode=$statuscodes]
    let $return     := if (empty($lastassignedids) or not(empty($searchTerms))) then $return    else if ($lastassignedids='#UNASSIGNED#') then $return[@lastAssignmentId=''] else $return[@lastAssignmentId=$lastassignedids]
    let $return     := if (empty($labels) or not(empty($searchTerms)))          then $return    else $return[@currentLabels=$labels]
    return
        $return
}
</return>
};

(:~
:   Return zero or more expanded issues wrapped in a &lt;return/&gt; element
:   
:   @param $id           - optional. Identifier of the template to retrieve
:   @return Matching issues in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-07-09
:)
declare function iss:getExpandedIssuesById ($id as xs:string, $skipObjects as xs:boolean) as element(return) {
let $issues                 := iss:getIssueById($id)

return
    <return>
    {
        for $issue in $issues
        let $decor                  := $issue/ancestor::decor
        let $projectPrefix          := $decor/project/@prefix
        let $language               := $decor/project/@defaultLanguage
        
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
            <issue  id="{$issue/@id}" 
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
                for $object in $issue/object[not($skipObjects)]
                let $type           := $object/@type
                let $objectEffDate  := $object/@effectiveDate
                let $objectContent := 
                    if ($type='DS') then
                        ($decor/datasets/dataset[@id=$object/@id][@effectiveDate=$objectEffDate])[1]
                    else if ($type='DE') then
                        ($decor/datasets//concept[@id=$object/@id][@effectiveDate=$objectEffDate][not(ancestor::history)])[1]
                    else if ($type='TM') then
                        let $templates  := templ:getTemplateList($object/@id,(),$object/@effectiveDate,$object/ancestor::decor/project/@prefix,$object/ancestor::decor/@versionDate)//template
                        return 
                            if ($templates/template[@id]) then ($templates/template[@id][1]) else ($templates/template[1])
                    else if ($type='VS') then
                        let $valueSet   := vs:getValueSetById($object/@id,$object/@effectiveDate,$object/ancestor::decor/project/@prefix,$object/ancestor::decor/@versionDate)/*/valueSet
                        return 
                            if ($valueSet[@id]) then (<valueSet>{$valueSet[@id][1]/(@* except (@url|@ident)), $valueSet[@id][1]/parent::*/(@url|@ident), $valueSet[@id][1]/node()}</valueSet>) else ($valueSet[1])
                    else if ($type='IS') then
                        (iss:getIssueById($object/@id))[1]
                    else if (string-length($objectEffDate)>0) then
                       ($decor//*[@id=$object/@id][@effectiveDate=$objectEffDate][not(self::object)])[1]
                    else (
                       ($decor//*[@id=$object/@id][not(self::object)])[1]
                    )
                
                order by $type
                return
                    if ($type='DE') then (
                        let $datasetContent := $get:colDecorData//concept[@id=$object/@id][@effectiveDate=$object/@effectiveDate][1]/ancestor::dataset
                        return
                        if ($objectContent/inherit) then (
                            let $inheritedConcept := (art:getOriginalConcept(<inherit>{$objectContent/inherit/@*}</inherit>)//concept)[1]
                            let $iddisplay        := art:getNameForOID($object/@id,$language,$projectPrefix)
                            return
                            <object id="{$object/@id}" 
                                    iddisplay="{$iddisplay}"
                                    name="{if ($inheritedConcept/name[@language=$language][1]) then $inheritedConcept/name[@language=$language][1] else $inheritedConcept/name[1]}" 
                                    type="{$type}" 
                                    statusCode="{$objectContent/@statusCode}" 
                                    effectiveDate="{$object/@effectiveDate}" 
                                    versionLabel="{$objectContent/@versionLabel}" 
                                    expirationDate="{$objectContent/@expirationDate}">
                                {
                                    attribute { 'linkedartefactmissing' } { if (string-length($objectContent/@id)=0) then ('true') else ('false') }
                                }
                                {
                                element {'dataset'} {
                                    $datasetContent/@*,
                                    attribute iddisplay {art:getNameForOID($datasetContent/@id,$language,$projectPrefix)},
                                    $datasetContent/name,
                                    <path>
                                    {
                                    for $ancestor in $datasetContent//concept[@id=$object/@id][@effectiveDate=$object/@effectiveDate][1]/ancestor::concept
                                    return
                                        concat(iss:getOriginalConcept($ancestor/@id, $ancestor/@effectiveDate)/name[@language=$language][1]/text(), ' / ')
                                    }
                                    </path>
                                }
                                ,
                                <inherit>
                                {
                                    $objectContent/inherit/@*
                                    ,
                                    $inheritedConcept/parent::*/@prefix
                                    ,
                                    $inheritedConcept/parent::*/@datasetId,
                                    attribute iType {$inheritedConcept/@type}, 
                                    attribute iStatusCode {$inheritedConcept/@statusCode},
                                    attribute iExpirationDate {$inheritedConcept/@expirationDate},
                                    attribute iVersionLabel {$inheritedConcept/@versionLabel},
                                    attribute iddisplay {$iddisplay}
                                }
                                </inherit>,
                                for $name in $inheritedConcept/name
                                return
                                <inheritedName language="{$name/@language}">{$name/text()}</inheritedName>
                                ,
                                for $desc in $inheritedConcept/desc
                                return
                                <inheritedDesc language="{$desc/@language}">{$desc/text()}</inheritedDesc>
                                ,
                                for $source in $inheritedConcept/source
                                return
                                <inheritedSource language="{$source/@language}">{$source/text()}</inheritedSource>
                                ,
                                for $rationale in $inheritedConcept/rationale
                                return
                                <inheritedRationale language="{$rationale/@language}">{$rationale/text()}</inheritedRationale>
                                ,
                                for $comment in $inheritedConcept/comment
                                return
                                <inheritedComment language="{$comment/@language}">{$comment/text()}</inheritedComment>
                                ,
                                for $operationalization in $inheritedConcept/operationalization
                                return
                                <inheritedOperationalization language="{$operationalization/@language}">{$operationalization/text()}</inheritedOperationalization>
                                ,
                                for $valueDomain in $inheritedConcept/valueDomain
                                return
                                <inheritedValueDomain>
                                {
                                   $valueDomain/@*,
                                   $valueDomain/property,
                                   art:getOriginalConceptList($valueDomain/conceptList),
                                   $valueDomain/example
                                }
                                </inheritedValueDomain>
                                ,
                                for $inhC in $inheritedConcept/concept
                                return
                                <inheritedConcept id="{$inhC/@id}" type="{$inhC/@type}" statusCode="{$inhC/@statusCode}" effectiveDate="{$inhC/@effectiveDate}" versionLabel="{$inhC/@versionLabel}" expirationDate="{$inhC/@expirationDate}">
                                {$inhC/*}
                                </inheritedConcept>
                            }
                            </object>
                        )
                        else (
                            <object id="{$object/@id}" 
                                    iddisplay="{art:getNameForOID($object/@id,$language,$projectPrefix)}"
                                    name="{if ($objectContent/name[@language=$language][1]) then $objectContent/name[@language=$language][1] else $objectContent/name[1]}" 
                                    type="{$type}" 
                                    statusCode="{$objectContent/@statusCode/string()}" 
                                    effectiveDate="{$object/@effectiveDate}">
                                {
                                    attribute { 'linkedartefactmissing' } { if (string-length($objectContent/@id)=0) then ('true') else ('false') }
                                }
                                {
                                element {'dataset'} {
                                    $datasetContent/@*,
                                    attribute iddisplay {art:getNameForOID($datasetContent/@id,$language,$projectPrefix)},
                                    $datasetContent/name,
                                    <path>
                                    {
                                    for $ancestor in $datasetContent//concept[@id=$object/@id][@effectiveDate=$object/@effectiveDate][1]/ancestor::concept
                                    return
                                        concat(iss:getOriginalConcept($ancestor/@id, $ancestor/@effectiveDate)/name[@language=$language][1]/text(), ' / ')
                                    }
                                    </path>
                                },
                                for $desc in $objectContent/desc
                                return
                                art:serializeNode($desc)
                                ,
                                for $source in $objectContent/source
                                return
                                art:serializeNode($source)
                                ,
                                for $rationale in $objectContent/rationale
                                return
                                art:serializeNode($rationale)
                                ,
                                for $comment in $objectContent/comment
                                return
                                art:serializeNode($comment)
                                ,
                                for $operationalization in $objectContent/operationalization
                                return
                                art:serializeNode($operationalization)
                                ,
                                for $valueDomain in $objectContent/valueDomain
                                return
                                <valueDomain>
                                {
                                   $valueDomain/@*,
                                   $valueDomain/property,
                                   art:getOriginalConceptList($valueDomain/conceptList),
                                   $valueDomain/example
                                }
                                </valueDomain>
                                ,
                                for $concept in $objectContent/concept
                                return
                                <concept>
                                {$concept/name}
                                </concept>
                            }
                            </object>
                        )
                    )
                    else if ($type='VS') then
                        <object id="{$object/@id}" 
                                iddisplay="{art:getNameForOID($object/@id,$language,$projectPrefix)}"
                                name="{$objectContent/@name}" 
                                displayName="{$objectContent/@displayName}" 
                                type="{$type}" 
                                statusCode="{$objectContent/@statusCode/string()}" 
                                effectiveDate="{$objectEffDate}" 
                                versionLabel="{$objectContent/@versionLabel}">
                            {
                                attribute { 'linkedartefactmissing' } { if (string-length($objectContent/@id)=0) then ('true') else ('false') }
                            }
                            {
                            for $completeCodeSystem in $objectContent/completeCodeSystem
                            let $codeSystemName := 
                                if ($completeCodeSystem[@codeSystemName]) then (
                                    (:carries its own name:)
                                    $completeCodeSystem/@codeSystemName
                                ) else (
                                    art:getNameForOID($completeCodeSystem/@codeSystem,$language,$issue/ancestor::decor/project/@prefix)
                                )
                            return
                            <completeCodeSystem codeSystem="{$completeCodeSystem/@codeSystem}" codeSystemName="{$codeSystemName}" codeSystemVersion="{$completeCodeSystem/@codeSystemVersion}" flexibility="{if ($completeCodeSystem[matches(@flexibility,'^\d{4}')]) then ($completeCodeSystem/@flexibility) else ('dynamic')}"/>
                        }
                        {
                            for $sourceCodeSystem in distinct-values($objectContent/conceptList/(concept|exception)/@codeSystem)
                            let $codeSystemName := art:getNameForOID($sourceCodeSystem,$language,$issue/ancestor::decor/project/@prefix)
                            return
                            <sourceCodeSystem id="{$sourceCodeSystem}" identifierName="{$codeSystemName}"/>
                        }
                        {
                            for $desc in $objectContent/desc
                            return
                            <desc language="{$desc/@language}">{util:serialize($desc/node(),'method=xhtml encoding=UTF-8')}</desc>
                        }
                            <conceptList>
                            {
                            for $concept in $objectContent/conceptList/concept
                            return
                            <concept code="{$concept/@code}" codeSystem="{$concept/@codeSystem}" codeSystemVersion="{$concept/@codeSystemVersion}" displayName="{$concept/@displayName}" level="{$concept/@level}" type="{$concept/@type}"/>
                            }
                            {
                            for $exception in $objectContent/conceptList/exception
                            return
                            <exception code="{$exception/@code}" codeSystem="{$exception/@codeSystem}" codeSystemVersion="{$exception/@codeSystemVersion}" displayName="{$exception/@displayName}" level="{$exception/@level}" type="{$exception/@type}"/>
                            }
                            </conceptList>
                        </object>
                    else if ($type='TM') then (
                        <object id="{$object/@id}" 
                                iddisplay="{art:getNameForOID($object/@id,$language,$projectPrefix)}"
                                name="{$objectContent/@name}" 
                                displayName="{$objectContent/@displayName}" 
                                type="{$type}" 
                                statusCode="{$objectContent/@statusCode/string()}" 
                                effectiveDate="{$objectEffDate}" 
                                versionLabel="{$objectContent/@versionLabel}">
                        {
                            attribute { 'linkedartefactmissing' } { if (string-length($objectContent/(@id|@ref))=0) then ('true') else ('false') }
                        }
                        {
                            $objectContent
                        }
                        </object>
                    ) else if ($type='TR') then (
                        let $templateEd := 
                            if (matches($objectContent/representingTemplate/@flexibility,'^\d{4}')) then (
                                $objectContent/representingTemplate/@flexibility
                            ) else (
                                string(max($decor//rules/template[@id=$objectContent/representingTemplate/@ref]/xs:dateTime(@effectiveDate)))
                            )
                        return
                        <object id="{$object/@id}" 
                                iddisplay="{art:getNameForOID($object/@id,$language,$projectPrefix)}"
                                name="{$objectContent/@displayName}" 
                                displayName="{$objectContent/@displayName}" 
                                type="{$type}" 
                                statusCode="{$objectContent/@statusCode/string()}" 
                                effectiveDate="{$objectEffDate}" 
                                versionLabel="{$objectContent/@versionLabel}" 
                                label="{$objectContent/@label}" 
                                model="{$objectContent/@model}">
                            {
                                attribute { 'linkedartefactmissing' } { if (string-length($objectContent/@id)=0) then ('true') else ('false') }
                            }
                            {
                            $objectContent/name,
                            $objectContent/desc,
                            $objectContent/trigger,
                            $objectContent/condition,
                            $objectContent/dependencies,
                            $objectContent/actors,
                            <representingTemplate>
                            {
                                $objectContent/representingTemplate/@*,
                                attribute {'templateName'} {$decor//rules/template[@id=$objectContent/representingTemplate/@ref][@effectiveDate=$templateEd]/@name},
                                attribute {'datasetName'} {data($decor//dataset[@id=$objectContent/representingTemplate/@sourceDataset]/name[@language=$language]/text())}
                            }
                            </representingTemplate>,
                            $objectContent/transaction
                        }
                        </object>
                     ) else (
                        <object id="{$object/@id}" 
                                iddisplay="{art:getNameForOID($object/@id,$language,$projectPrefix)}"
                                name="{$objectContent/@name}" 
                                displayName="{$objectContent/@displayName}" 
                                type="{$type}" 
                                statusCode="{$objectContent/@statusCode | $objectContent//tracking[@effectiveDate=max($objectContent//tracking/xs:dateTime(@effectiveDate))][1]/@statusCode}" 
                                effectiveDate="{$objectEffDate}" 
                                versionLabel="{$objectContent/@versionLabel}">
                            {
                                attribute { 'linkedartefactmissing' } { if (string-length($objectContent/@id)=0) then ('true') else ('false') },
                                if (string-length($objectContent/@label)) then $objectContent/@label else (),
                                if (string-length($objectContent/@model)) then $objectContent/@model else (),
                                if ($objectContent/name) then ($objectContent/name) else (),
                                if ($objectContent/desc) then ($objectContent/desc) else ()
                            }
                        </object>
                    )
            }
            {
                for $event in $issue/tracking|$issue/assignment
                order by xs:dateTime($event/@effectiveDate) descending
                return
                if (name($event)='tracking') then
                    <tracking effectiveDate="{$event/@effectiveDate}" statusCode="{$event/@statusCode}">
                    {
                        if (string-length($event/@labels)>0) then ($event/@labels) else (),
                        <author>
                        {
                            $event/author/@*[string-length(.)>0],
                            if (string-length(string-join($event/author/text(),''))>0) then (
                                $event/author/text()
                            ) else (
                                $decor//project/author[@id=$event/author/@id]/text()
                            )
                        }
                        </author>
                    }
                    {
                        for $desc in $event/desc
                        return
                        art:serializeNode($desc)
                    }
                    </tracking>
                else if (name($event)='assignment') then
                    <assignment to="{$event/@to}" name="{$event/@name}" effectiveDate="{$event/@effectiveDate}">
                    {
                        if (string-length($event/@labels)>0) then ($event/@labels) else (),
                        <author>
                        {
                            $event/author/@*[string-length(.)>0],
                            if (string-length(string-join($event/author/text(),''))>0) then (
                                $event/author/text()
                            ) else (
                                $decor//project/author[@id=$event/author/@id]/text()
                            )
                        }
                        </author>
                    }
                    {
                        for $desc in $event/desc
                        return
                        art:serializeNode($desc)
                    }
                    </assignment>
                else()
            }
            </issue>
    }
    </return>
};

(:~
:   Return zero or more expanded issues wrapped in a &lt;return/&gt; element
:   
:   @param $id            - required. Identifier of the object to retrieve the issue for
:   @param $effectiveDate - optional. Effective date of the object to retrieve the issue for
:   @return Matching issues
:   @author Alexander Henket
:   @since 2014-07-09
:)
declare function iss:getExpandedIssuesByObject ($id as xs:string, $effectiveDate as xs:string?) as element(return) {
<return>
{
    for $issue in iss:getIssueByObject($id,$effectiveDate)
    return
        iss:getExpandedIssuesById($issue/@id, true())/issue
}
</return>
};

(:
:   recursion alert
:)
declare function iss:getOriginalConcept($conceptId as xs:string, $effectiveDate as xs:string) as element()* {
    let $concept := $get:colDecorData//concept[@id=$conceptId][@effectiveDate=$effectiveDate][not(ancestor::history)][1]
    return
    if ($concept/inherit) then (
        (art:getOriginalConcept($concept/inherit)//concept)[1]
    ) else (
        $concept
    )
};