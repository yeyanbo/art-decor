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

(:
   Xquery for retrieving the concept for read-only purposes.
   Requires id  and effectiveDate as request parameters
   Returns the concept without subconcepts, inherit is resolved, textWithMarkup is serialized.

:)
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace request   = "http://exist-db.org/xquery/request";

let $id            := if (request:exists()) then request:get-parameter('id',()) else ('2.16.840.1.113883.2.4.3.11.60.90.77.2.4.20290')
let $effectiveDate := if (request:exists()) then request:get-parameter('effectiveDate',()) else ('2012-08-06T00:00:00')
let $concept       := $get:colDecorData//concept[@id=$id][@effectiveDate=$effectiveDate][not(ancestor::history)]

let $username      := xmldb:get-current-user()
let $communityInfo := $get:colDecorData//community[@projectId=$concept/ancestor::decor/project/@id][access/author[@username=($username,'guest')][contains(@rights,'r')]]//association[object[@ref=$id][@type='DE']]

return
    if ($concept/inherit) then
        let $inheritedConcept := art:getOriginalConcept($concept/inherit)
        let $originalConcept  := ($inheritedConcept//concept)[1]
        let $baseId           := string-join(tokenize($originalConcept/@id,'\.')[position()!=last()],'.')
        let $prefix           := $get:colDecorData//baseId[@id=$baseId]/@prefix
        let $communityInfo    := (
            $communityInfo | $get:colDecorData//community[@projectId=$concept/ancestor::decor/project/@id][access/author[@username=$username][contains(@rights,'r')]]//association[object[@ref=$inheritedConcept/@id][@type='DE']]
        )
        
        return
        <concept id="{$id}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}" type="{$originalConcept/@type}"
                 expirationDate="{$concept/@expirationDate}" officialReleaseDate="{$concept/@officialReleaseDate}"
                 versionLabel="{$concept/@versionLabel}">
        {
            <inherit>
            {
                $concept/inherit/(@ref|@effectiveDate),
                $originalConcept/parent::inherit/@prefix,
                $originalConcept/parent::inherit/@datasetId,
                attribute iType {$originalConcept/@type}, 
                attribute iStatusCode {$originalConcept/@statusCode}, 
                attribute iEffectiveDate {$originalConcept/@effectiveDate},
                attribute iExpirationDate {$originalConcept/@expirationDate},
                attribute iVersionLabel {$originalConcept/@versionLabel},
                attribute iddisplay {art:getNameForOID($concept/inherit/@ref,$concept/ancestor::decor/project/@defaultLanguage,$originalConcept/parent::inherit/@prefix)}
            }
            </inherit>,
            for $name in $originalConcept/name
            return
            art:serializeNode($name)
            ,
            for $desc in $originalConcept/desc
            return
            art:serializeNode($desc)
            ,
            for $source in $originalConcept/source
            return
            art:serializeNode($source)
            ,
            for $rationale in $originalConcept/rationale
            return
            art:serializeNode($rationale)
            ,
            for $comment in $inheritedConcept//comment[not(ancestor::history)][count(ancestor::concept)<=1]
            return
            <inheritedComment language="{$comment/@language}">{$comment/text()}</inheritedComment>
            ,
            for $comment in $concept/comment
            return
            art:serializeNode($comment)
            ,
            for $operationalization in $originalConcept/operationalization
            return
            art:serializeNode($operationalization)
            ,
            for $valueDomain in $originalConcept/valueDomain
            return
                <valueDomain>
                {
                    $valueDomain/@*,
                    $valueDomain/property[@*[string-length()>0]],
                    for $conceptList in $valueDomain/conceptList 
                    let $originalConceptList := art:getOriginalConceptList($conceptList)
                    return
                        <conceptList>
                        {
                            (:note that this will retain conceptList[@ref] if applicable:)
                            $conceptList/@*,
                            $originalConceptList/*
                        }
                        </conceptList>
                    ,
                    $valueDomain/example
                }
                </valueDomain>
            ,
            for $associations in $communityInfo
            group by $communityPrefix := $associations/ancestor::community/@name
            return
                <community name="{$communityPrefix}">
                {
                    $associations[1]/ancestor::community/@displayName,
                    $associations[1]/ancestor::community/desc,
                    <prototype>
                    {
                        $associations[1]/ancestor::community/prototype/data[@type=$associations//data/@type]
                    }
                    </prototype>,
                    <associations>
                    {
                        for $association in $associations
                        return
                            <association>
                            {
                                $association/@*,
                                for $data in $association/data
                                return
                                art:serializeNode($data)
                            }
                            </association>
                    }
                    </associations>
                }
                </community>
            ,
            $concept/history
        }
        </concept>
    else (
        <concept id="{$id}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}" 
                 expirationDate="{$concept/@expirationDate}" officialReleaseDate="{$concept/@officialReleaseDate}" type="{$concept/@type}"
                 versionLabel="{$concept/@versionLabel}" >
        {
            for $name in $concept/name
            return
            art:serializeNode($name)
            ,
            for $desc in $concept/desc
            return
            art:serializeNode($desc)
            ,
            for $source in $concept/source
            return
            art:serializeNode($source)
            ,
            for $rationale in $concept/rationale
            return
            art:serializeNode($rationale)
            ,
            for $comment in $concept/comment
            return
            art:serializeNode($comment)
            ,
            for $operationalization in $concept/operationalization
            return
            art:serializeNode($operationalization)
            ,
            for $valueDomain in $concept/valueDomain
            return
             <valueDomain>
             {
                 $valueDomain/@*,
                 $valueDomain/property[@*[string-length()>0]],
                 for $conceptList in $valueDomain/conceptList 
                 let $originalConceptList := art:getOriginalConceptList($conceptList)
                 return
                    <conceptList>
                    {
                        (:note that this will retain conceptList[@ref] if applicable:)
                        $conceptList/@*,
                        $originalConceptList/*
                    }
                    </conceptList>
                 ,
                 $valueDomain/example
             }
             </valueDomain>
            ,
            for $associations in $communityInfo
            group by $communityPrefix := $associations/ancestor::community/@name
            return
                <community name="{$communityPrefix}">
                {
                    $associations[1]/ancestor::community/@displayName,
                    $associations[1]/ancestor::community/desc,
                    <prototype>
                    {
                        $associations[1]/ancestor::community/prototype/data[@type=$associations//data/@type]
                    }
                    </prototype>,
                    <associations>
                    {
                        for $association in $associations
                        return
                            <association>
                            {
                                $association/@*,
                                for $data in $association/data
                                return
                                art:serializeNode($data)
                            }
                            </association>
                    }
                    </associations>
                }
                </community>
            ,
            $concept/history
        }
        </concept>
    )

