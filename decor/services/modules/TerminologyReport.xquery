(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket
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
:
:)
import module namespace msg       = "urn:decor:REST:v1" at "get-message.xquery";
import module namespace get       = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art       = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace vs        = "http://art-decor.org/ns/decor/valueset" at "../../../art/api/api-decor-valueset.xqm";
import module namespace adserver  = "http://art-decor.org/ns/art-decor-server" at "../../../art/api/api-server-settings.xqm";
import module namespace aduser    = "http://art-decor.org/ns/art-decor-users" at "../../../art/api/api-user-settings.xqm";

declare variable $artDeepLink           := adserver:getServerURLArt();
declare variable $artDeepLinkTerminology:= concat($artDeepLink,'../terminology/');
declare variable $artDeepLinkServices   := adserver:getServerURLServices();

declare variable $codeSystemSNOMED      := '2.16.840.1.113883.6.96';
declare variable $codeSystemLOINC       := '2.16.840.1.113883.6.1';
declare variable $codeSystemsCLAML      := collection($get:strTerminologyData)//ClaML/Identifier/@uid;

declare variable $useLocalAssets        := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath          := if ($useLocalAssets = 'true') then ('../assets') else ('resources');

declare variable $codeSystemFilter      := if (request:exists()) then tokenize(request:get-parameter('csfilter',($codeSystemSNOMED))[string-length()>0],'\s') else ();

declare function local:getDisplayNameFromCodesystem($code as xs:string, $codeSystem as xs:string) as xs:string* {
    if ($codeSystem=$codeSystemSNOMED) then
        doc(concat($artDeepLinkTerminology,'snomed/getConcept/',encode-for-uri($code)))//concept[@conceptId=$code]/desc[@type='fsn'][@active]
    else if ($codeSystem=$codeSystemLOINC) then
        doc(concat($artDeepLinkTerminology,'loinc/searchLOINC/',encode-for-uri($code)))//concept[@loinc_num=$code]/longName
    else
        doc(concat($artDeepLinkTerminology,'claml/RetrieveClass?classificationId=',$codeSystem,'&amp;code=',encode-for-uri($code)))/Class[@code=$code][@classificationId=$codeSystem]/Rubric[@kind='preferred']/Label[1]
};

declare function local:getDisplayNameAndStatus($code as xs:string, $codeSystem as xs:string) as element() {
    if ($codeSystem=$codeSystemSNOMED) then
        let $concept        := doc(concat($artDeepLinkTerminology,'snomed/getConcept/',encode-for-uri($code)))//concept[@conceptId=$code]
        let $displayNames   := $concept/desc[@active]
        let $statusCode     := if ($concept/@active='1') then 'active' else if ($concept) then 'deprecated' else ('')
        let $statusText     := $statusCode
        return
            <codeSystem originalStatusCode="{$statusCode}" originalStatusText="{$statusText}">
            {
                for $displayName in $displayNames
                return
                    <desc originalDisplayName="{$displayName}" type="{$displayName/@type}"/>
            }
            </codeSystem>
    else if ($codeSystem=$codeSystemLOINC) then
        let $concept        := doc(concat($artDeepLinkTerminology,'loinc/searchLOINC/',encode-for-uri($code)))//concept[@loinc_num=$code]
        let $displayName    := $concept/longName
        let $statusText     := $concept/@status
        let $statusCode     := if (lower-case($statusText)='active') then 'active' else if (lower-case($statusText)='trial') then ('pending') else if (lower-case($statusText)=('deprecated','discouraged')) then ('deprecated') else (lower-case($statusText))
        return
            <codeSystem originalDisplayName="{$displayName}" originalStatusCode="{$statusCode}" originalStatusText="{$statusText}"/>
    else
        let $concept        := doc(concat($artDeepLinkTerminology,'claml/RetrieveClass?classificationId=',$codeSystem,'&amp;code=',encode-for-uri($code)))/Class[@code=$code][@classificationId=$codeSystem]
        let $displayName    := $concept/Rubric[@kind='preferred']/Label[1]
        let $statusCode     := ()
        let $statusText     := ()
        return
            <codeSystem originalDisplayName="{$displayName}" originalStatusCode="{$statusCode}" originalStatusText="{$statusText}"/>
};

(: support concept and conceptList/concept :)
declare function local:getOrginalConceptName($id as xs:string) as element(conceptName)* {
    let $concept            := $get:colDecorData//concept[@id=$id][not(ancestor::history)]
    return
    if ($concept/name) then (
        for $name in $concept/name
        return <conceptName>{$name/@*, $name/node()}</conceptName>
    )
    else if ($concept/inherit/@ref) then (
        local:getOrginalConceptName($concept/inherit/@ref)
    )
    else (
    )
};

declare function local:handleTerminologyAssociations($association as element(terminologyAssociation), $project as element(decor)) as element()* {
    let $prefix         := $project/project/@prefix
    
    let $conceptIds     := $get:colDecorData//concept[@id=$association/@conceptId][not(ancestor::history)][not(parent::conceptList)]/@id
    let $conceptListIds := $get:colDecorData//concept[@id=$association/@conceptId][not(ancestor::history)]/parent::conceptList[1]/@id
    let $valueSets      := ()
    
    let $matchingCodes  := 
        if ($conceptIds) then 
    (:if it is a normal concept, get from codesystem.:)
            local:getDisplayNameAndStatus($association/@code,$association/@codeSystem)
        else (
    (:if it is a conceptList/concept, check valueSets that the conceptList is bound to:)
            let $vsTermAssocs   := $project//terminologyAssociation[@conceptId=$conceptListIds]
            let $valueSets      := for $vsta in $vsTermAssocs return vs:getExpandedValueSetByRef($vsta/@valueSet, if ($vsta/@flexibility) then $vsta/@flexibility else ('dynamic'), $prefix)//valueSet[@id]
            
            return
            distinct-values($valueSets//concept[@code=$association/@code][@codeSystem=$association/@codeSystem]/@displayName |
                            $valueSets//exception[@code=$association/@code][@codeSystem=$association/@codeSystem]/@displayName)
       )
    
    let $matchingCodes  := 
        if (count($matchingCodes)=0 and $conceptIds) then 
    (: if we still don't have a displayName and it is a normal concept try all project valueSets as it might be a locally defined code:)
            distinct-values($project//valueSet/*/concept[@code=$association/@code][@codeSystem=$association/@codeSystem]/@displayName) 
        else if (count($matchingCodes)=0 and $conceptListIds and empty($valueSets)) then 
    (: if we still don't have a displayName and it is a conceptList/concept and there was no valueSet binding at conceptList level, then try all project valueSets:)
            distinct-values($project//valueSet/*/concept[@code=$association/@code][@codeSystem=$association/@codeSystem]/@displayName |
                            $project//valueSet/*/exception[@code=$association/@code][@codeSystem=$association/@codeSystem]/@displayName)
        else 
            $matchingCodes
    
    let $matchingCodes  :=
        for $matchingCode in $matchingCodes
        return
            if ($matchingCode instance of element()) then
                $matchingCode
            else (
                <codeSystem originalStatusCode="active" originalStatusText="active">
                    <desc originalDisplayName="{$matchingCode}" type="fsn"/>
                </codeSystem>
            )
    
    return
        if ($matchingCodes//@originalDisplayName[lower-case(.)=$association/lower-case(@displayName)]) then (
            <terminologyAssociation>
            {
                $association/@*,
                attribute conceptType {if ($conceptIds) then 'concept' else if ($conceptListIds) then 'conceptListConcept' else ()},
                local:getOrginalConceptName($association/@conceptId)
            }
            </terminologyAssociation>
        ) else (
            (:update delete $association/@displayName
            ,
            update insert attribute displayName {$matchingCodes} into $association
            ,:)
            <terminologyAssociation>
            {
                $association/@*,
                attribute conceptType {if ($conceptIds) then 'concept' else if ($conceptListIds) then 'conceptListConcept' else ()},
                for $matchingCode in $matchingCodes
                let $displayName            := $matchingCode//@originalDisplayName
                let $preferredDisplayName   := 
                    if ($matchingCode//@type='fsn') then ($matchingCode//*[@type='fsn']/@originalDisplayName) else ($displayName[1])
                let $statusCode             := $matchingCode/@originalStatusCode[string-length()>0]
                let $statusText             := $matchingCode/@originalStatusText
                return <originalDisplayName originalStatusCode="{$statusCode}" originalStatusText="{$statusText}">{$preferredDisplayName/string()}</originalDisplayName>
                ,
                (:$matchingCodes,:)
                (:local:getDisplayNameAndStatus($association/@code,$association/@codeSystem),:)
                for $conceptName in local:getOrginalConceptName($association/@conceptId)
                group by $name := $conceptName/text()
                return $conceptName[1]
            }
            </terminologyAssociation>
        )
};

declare function local:handleValuesets($valueSet as element(valueSet),$terminologyAssociations as element(terminologyAssociation)*) as element()* {
    <valueSet>
    {
        $valueSet/@*,
        $valueSet/(* except conceptList)
    }
    {
        if ($valueSet/conceptList) then
            <conceptList>
            {
                for $node in $valueSet/conceptList/*
                return
                    if ($node/self::include or $node[not(@code and @codeSystem)]) then $node else (
                        let $displayNameAndStatus   := local:getDisplayNameAndStatus($node/@code,$node/@codeSystem)
                        let $displayName            := $displayNameAndStatus//@originalDisplayName
                        let $lowerCasedDisplayName  := for $d in $displayName return lower-case($d)
                        let $preferredDisplayName   := 
                            if ($displayNameAndStatus//@type='fsn') then ($displayNameAndStatus//*[@type='fsn']/@originalDisplayName) else ($displayName[1])
                        let $statusCode             := $displayNameAndStatus/@originalStatusCode[string-length()>0]
                        let $statusText             := $displayNameAndStatus/@originalStatusText
                        return
                        element {$node/name()} {
                            $node/@*,
                            if ($lowerCasedDisplayName=lower-case($node/@displayName) and (empty($statusCode) or $statusCode='active'))
                            then () 
                            else if (string-length($preferredDisplayName)>0) 
                            then (attribute originalDisplayName {$preferredDisplayName}, $statusCode[string-length()>0], $statusText[string-length()>0])
                            else if ($node/@codeSystem=($codeSystemSNOMED, $codeSystemLOINC) or $node/@codeSystem=$codeSystemsCLAML) 
                            then (attribute originalDisplayName {$preferredDisplayName}, $statusCode[string-length()>0], $statusText[string-length()>0])
                            else (),
                            $node/node(),
                            let $conceptNames       :=
                                for $terminologyAssociation in $terminologyAssociations[@code=$node/@code][@codeSystem=$node/@codeSystem]
                                return local:getOrginalConceptName($terminologyAssociation/@conceptId)
                            for $conceptName in $conceptNames
                            group by $name := $conceptName/text()
                            return $conceptName[1]
                        }
                    )
            }
            </conceptList>
        else ()
    }
    </valueSet>
};

declare function local:doReport($decorproject as element(), $reporttype as xs:string, $now as xs:string) {
    <decor>
    {
        (: hack alert. This forces the serializer to write our 'foreign' namespace declarations. Reported on the exist list :)
        for $ns-prefix at $i in in-scope-prefixes($decorproject)[not(.=('xml','xsi'))]
        let $ns-uri := namespace-uri-for-prefix($ns-prefix, $decorproject)
        return
            attribute {QName($ns-uri,concat($ns-prefix,':dummy-',$i))} {$ns-uri}
        ,
        $decorproject/@*,
        '&#10;',
        comment {
            '&#10;',
            'This is a report version of a DECOR based project. Report date: ', $now ,'&#10;',
            'PLEASE NOTE THAT ITS ONLY PURPOSE IS TO REPORT INFORMATION. HENCE THIS IS A ONE OFF FILE UNSUITED FOR ANY OTHER PURPOSE','&#10;'
        },
        for $node in $decorproject/node()
        return
            if ($node/name()='project') then (
                $node
            ) else if ($node/name()='datasets') then (
                $node
            ) else if ($node/name()='scenarios') then (
                $node 
            ) else if ($node/name()='terminology') then (
                <terminology>
                {
                    for $subnode in $node/node()
                    return
                        if ($reporttype=('overview','terminologyassociations') and $subnode[name()='terminologyAssociation'][@code][@codeSystem]) then
                            local:handleTerminologyAssociations($subnode,$decorproject)
                        else if ($reporttype='overview' and $subnode[name()='valueSet']) then (
                            local:handleValuesets($subnode,$node/terminologyAssociation)
                        )
                        else if ($reporttype='valuesets' and $subnode[name()='valueSet'][@statusCode=('new','draft','final')]) then (
                            local:handleValuesets($subnode,$node/terminologyAssociation)
                        )
                        else (
                            $subnode
                        )
                }
                </terminology>
            ) else if ($node/name()='ids') then (
                $node
            ) else if ($node/name()='rules') then (
                $node 
            ) else (
                $node
            )
    }
    </decor>
};

declare function local:projectTerminology2html($decorproject as element(), $language as xs:string, $mode as xs:string) as item()* {
    let $errorimg           := <img src="{$artDeepLink}img/error.png" alt="" title="{msg:getMessage('trConceptNotFoundOrMismatch',$language)}" style="padding:0 8px 0 0; vertical-align: middle;"/>
    let $okimg              := <img src="{$artDeepLink}img/IssueStatusCodeLifeCycle_closed.png" alt="" title="{msg:getMessage('trNoProblemsFound',$language)}" style="padding:0 8px 0 0; vertical-align: middle;"/>
    let $language           := $decorproject/project/@defaultLanguage
    let $associations       := 
        if ($mode='overview') then (
            if (empty($codeSystemFilter)) then 
                $decorproject/terminology/terminologyAssociation[@code]
            else 
                $decorproject/terminology/terminologyAssociation[@code][@codeSystem=$codeSystemFilter]
        ) else (
            if (empty($codeSystemFilter)) then 
                $decorproject/terminology/terminologyAssociation[@code][@codeSystem=$codeSystemFilter][originalDisplayName]
            else 
                $decorproject/terminology/terminologyAssociation[@code][originalDisplayName]
        )
    let $valueSets          :=
        if ($mode='overview') then (
            if (empty($codeSystemFilter)) then
                $decorproject/terminology/valueSet
            else 
                $decorproject/terminology/valueSet[conceptList//@codeSystem=$codeSystemFilter]
        ) else (
            if (empty($codeSystemFilter)) then
                $decorproject/terminology/valueSet[.//@originalDisplayName or .//@originalStatusCode[string-length()>0]]
            else 
                $decorproject/terminology/valueSet[.//@originalDisplayName or .//@originalStatusCode[string-length()>0]][conceptList//@codeSystem=$codeSystemFilter]
        )
    let $diffCountValueSets := count($decorproject/terminology/valueSet//@originalDisplayName | $decorproject/terminology/valueSet//@originalStatusCode[string-length()>0])
    let $r := 
    <body>
        {if ($associations) then ( 
            <h2>{msg:getMessage('trAssociationFoundCountTitle',$language,string(count($associations[originalDisplayName])))}</h2>,
            <table width="100%" class="zebra-table">
                <tr>
                    <th>{msg:getMessage('columnConceptId',$language)}</th>
                    <!--<td class="item-label-var">Valueset / Flexibility</th>-->
                    <th>{msg:getMessage('columnCode',$language)}</th>
                    <th>{msg:getMessage('columnCodeSystem',$language)}</th>
                    <th>{msg:getMessage('columnDisplayName',$language)}</th>
                    <th>{msg:getMessage('columnConceptName',$language)}</th>
                    <th>{msg:getMessage('columnOriginalData',$language)}</th>
                </tr>
            {
                for $association at $pos in $associations
                let $deeplinktocode := 
                    if ($association/@codeSystem=$codeSystemSNOMED) then
                        concat($artDeepLink,'snomed-ct?conceptId=',encode-for-uri($association/@code))
                    else if ($association/@codeSystem=$codeSystemLOINC) then
                        concat($artDeepLink,'loinc?conceptId=',encode-for-uri($association/@code))
                    else if ($association/@codeSystem=$codeSystemsCLAML) then
                        concat($artDeepLink,'claml?classificationId=',encode-for-uri($association/@codeSystem),'&amp;conceptId=',encode-for-uri($association/@code))
                    else ()
                return (
                <tr class="zebra-row-{if ($pos mod 2 = 0) then 'even' else 'odd'}">
                    <td>{$association/@conceptId/string()}</td>
                    <!--<td>{$association/@valueSet / $association/@flexibility}</td>-->
                    <td>
                    {
                        if ($deeplinktocode) then 
                            <a href="{$deeplinktocode}">{$association/@code/string()}</a>
                        else
                            $association/@code/string()
                    }
                    </td>
                    <td>{$association/@codeSystem/string(), if ($association/@codeSystemVersion) then concat(' version ',$association/@codeSystemVersion/string()) else ()}</td>
                    <td>{$association/@displayName/string()}</td>
                    <td>
                    {
                        for $conceptName in $association/conceptName
                        return <div>({$conceptName/@language/string()}) {data($conceptName)}</div>
                    }
                    </td>
                    <td>
                        {if ($association[not(originalDisplayName)]) then ($okimg) else 
                        <div style="float: left;">
                            <img src="{$errorimg/@src}" alt="{$errorimg/@alt}" title="{
                            if ($association/@conceptType='concept') then
                                msg:getMessage('trConceptNotFoundOrMismatchName',$language)
                            else if ($association/@conceptType='conceptListConcept') then
                                msg:getMessage('trConceptNotInValueSetOrMismatchName',$language)
                            else (
                                msg:getMessage('trConceptTypeUnknownOrMismatchName',$language)
                            )
                            }" style="{$errorimg/@style}"/>
                        </div>
                        }
                        <div style="float: left;">
                        {
                            for $originalDisplayName at $pos in $association/originalDisplayName
                            return
                                if ($originalDisplayName/@originalStatusCode) then
                                    <div><span class="node-s{$originalDisplayName/@originalStatusCode}" title="{$originalDisplayName/@originalStatusText}">{$originalDisplayName/string()}</span></div>
                                else
                                    <div>{$originalDisplayName/string()}</div>
                        }
                        </div>
                    </td>
                </tr>
                )
            }
            </table>
            
        ) else ()
        }
        {if ($valueSets) then (
            <h2>{msg:getMessage('trValuesetsFoundCountTitle',$language,$diffCountValueSets,string(count($valueSets)))}</h2>,
            for $valueSet in $valueSets
            order by $valueSet/lower-case(@name)
            return
                <div class="content">
                    <h3><span class="node-s{$valueSet/@statusCode}" title="{$valueSet/@statusCode}">{if ($valueSet/@displayName) then $valueSet/@displayName/string() else ($valueSet/@name/string()), ' - ',lower-case(msg:getMessage('effectiveTime',$language)),' ', $valueSet/@effectiveDate/string(), if ($valueSet/@versionLabel) then concat(' - (', $valueSet/@versionLabel/string(),')') else ()} - {$valueSet/@id/string()}</span></h3>
                    {if ($valueSet/desc[@language=$language]) then (
                        $valueSet/desc[@language=$language]/node()
                    ) else ()
                    }
                    {if ($valueSet[sourceCodeSystem]) then (
                            <table width="100%" class="zebra-table">
                                <tr>
                                    <th align="right">{msg:getMessage('xSourceCodeSystem',$language)}</th>
                                    <td>
                                    {
                                        for $sourceCodeSystem at $pos in $valueSet/sourceCodeSystem
                                        return
                                            <div class="zebra-row-{if ($pos mod 2 = 0) then 'even' else 'odd'}">
                                                &quot;
                                                <a href="CodeSystemIndex?id={$sourceCodeSystem/@id/string()}">{$sourceCodeSystem/@id/string()}&quot;&#160; ({$sourceCodeSystem/@identifierName/string()})</a>
                                            </div>
                                    }
                                    </td>
                                </tr>
                            </table>
                        ) else ()}
                    <p/>
                    {if (count($valueSet/completeCodeSystem)=1) then (
                            <p><b>{msg:getMessage('xCompleteCodeSystem',$language)}</b></p>
                        ) else if (count($valueSet/completeCodeSystem)>1) then (
                            <p><b>{msg:getMessage('xCompleteCodeSystems',$language,string(count($valueSet/completeCodeSystem)))}</b></p>
                        ) else ()}
                    {if ($valueSet[completeCodeSystem]) then (
                        <table class="values zebra-table" cellpadding="5px">
                              <thead>
                                  <tr>
                                      <th>{msg:getMessage('columnCodeSystemName',$language)}</th>
                                      <th>{msg:getMessage('columnCodeSystemID',$language)}</th>
                                      <th>{msg:getMessage('columnCodeSystemVersion',$language)}</th>
                                      <th>{msg:getMessage('columnFlexibility',$language)}</th>
                                  </tr>
                              </thead>
                              <tbody>
                              {for $completeCodeSystem at $pos in ($valueSet/completeCodeSystem)
                               return
                                  <tr class="zebra-row-{if ($pos mod 2 = 0) then 'even' else 'odd'}">
                                        <td>{data($completeCodeSystem/@codeSystemName)}</td>
                                        <td>{data($completeCodeSystem/@codeSystem)}</td>
                                        <td>{data($completeCodeSystem/@codeSystemVersion)}</td>
                                        {if ($completeCodeSystem/@flexibility='dynamic' or not($completeCodeSystem[@flexibility])) then (
                                            <td>{msg:getMessage('flexibilityDynamic',$language)}</td>
                                        ) else (
                                            <td>{data($completeCodeSystem/@flexibility)}</td>
                                        )}
                                  </tr>
                               }
                              </tbody>
                          </table>
                    ) else ()}
                    {if ($valueSet[completeCodeSystem and conceptList/*]) then (
                            <p><b>{msg:getMessage('orOneOfTheFollowing',$language)}</b></p>
                        ) else ()}
                    {if ($valueSet[conceptList/*]) then (
                          <table width="100%" class="zebra-table" cellpadding="5px">
                              <thead>
                              <tr>
                                  <th width="5%">{msg:getMessage('columnLevelSlashType',$language)}</th>
                                  <th width="5%">{msg:getMessage('columnCode',$language)}</th>
                                  <th width="10%">{msg:getMessage('columnCodeSystem',$language)}</th>
                                  {if ($valueSet/conceptList/*[@codeSystemVersion]) then (<th>{msg:getMessage('columnCodeSystemVersion',$language)}</th>) else ()}
                                  <th width="15%">{msg:getMessage('columnDisplayName',$language)}</th>
                                  <th width="15%">{msg:getMessage('columnConceptName',$language)}</th>
                                  <th width="15%">{msg:getMessage('columnOriginalData',$language)}</th>
                                  <th>{msg:getMessage('columnDescription',$language)}</th>
                              </tr>
                              </thead>
                              <tbody>
                                {for $concept at $pos in ($valueSet/conceptList/concept)
                                    let $levelNumber := if (data($concept/@level)) then (xs:integer(data($concept/@level))) else (0)
                                    let $typeString := if (data($concept/@type)) then (data($concept/@type)) else ('L')
                                    let $levelType := if (string($levelNumber)!='' or $typeString!='') then (concat($levelNumber,'-',$typeString)) else ('')
                                    let $deeplinktocode := 
                                        if ($concept/@codeSystem=$codeSystemSNOMED) then
                                            concat($artDeepLink,'snomed-ct?conceptId=',encode-for-uri($concept/@code))
                                        else if ($concept/@codeSystem=$codeSystemLOINC) then
                                            concat($artDeepLink,'loinc?conceptId=',encode-for-uri($concept/@code))
                                        else if ($concept/@codeSystem=$codeSystemsCLAML) then
                                            concat($artDeepLink,'claml?classificationId=',encode-for-uri($concept/@codeSystem),'&amp;conceptId=',encode-for-uri($concept/@code))
                                        else ()
                                 return
                                    <tr class="zebra-row-{if ($pos mod 2 = 0) then 'even' else 'odd'}">
                                        <td>{$levelType}</td>
                                        <td>
                                            {for $i in 1 to $levelNumber return '&#160;&#160;&#160;'}
                                        {
                                            if ($deeplinktocode) then 
                                                <a href="{$deeplinktocode}">{$concept/@code/string()}</a>
                                            else
                                                $concept/@code/string()
                                        }
                                        </td>
                                        <td>{if ($concept/@codeSystemName) then ($concept/@codeSystemName/string()) else <i>{$concept/@codeSystem/string()}</i>}</td>
                                        {if ($valueSet/conceptList/*[@codeSystemVersion]) then (<td>{$concept/@codeSystemVersion/string()}</td>) else ()}
                                        <td>{$concept/@displayName/string()}</td>
                                        <td>
                                        {
                                            for $conceptName in $concept/conceptName
                                            return <div>({$conceptName/@language/string()}) {data($conceptName)}</div>
                                        }
                                        </td>
                                        <td>{if ($concept[@originalDisplayName or @originalStatusCode[string-length()>0]]) then $errorimg else ($okimg)}
                                        {
                                            if ($concept/@originalStatusCode) then
                                                <span class="node-s{$concept/@originalStatusCode}" title="{$concept/@originalStatusText}">{$concept/@originalDisplayName/string()}</span>
                                            else
                                                $concept/@originalDisplayName/string()
                                        }
                                        </td>
                                        <td>{$concept/desc[@language=$language or $language=''][1]/string()}</td>
                                    </tr>
                                 }
                                 {if ($valueSet[conceptList/concept and conceptList/exception]) then (
                                 <tr>
                                    <td colspan="7"><hr/></td>
                                 </tr>) else ()}
                                 {for $concept at $pos in ($valueSet/conceptList/exception)
                                    let $levelNumber    := if ($concept[@level]) then (xs:integer($concept/@level/string())) else ('')
                                    let $typeString     := if ($concept[@type]) then ($concept/@type/string()) else ('')
                                    let $levelType      := if (string($levelNumber)!='' or $typeString!='') then (concat($levelNumber,'-',$typeString)) else ('')
                                    let $deeplinktocode := 
                                        if ($concept/@codeSystem=$codeSystemSNOMED) then
                                            concat($artDeepLink,'snomed-ct?conceptId=',encode-for-uri($concept/@code))
                                        else if ($concept/@codeSystem=$codeSystemLOINC) then
                                            concat($artDeepLink,'loinc?conceptId=',encode-for-uri($concept/@code))
                                        else if ($concept/@codeSystem=$codeSystemsCLAML) then
                                            concat($artDeepLink,'claml?classificationId=',encode-for-uri($concept/@codeSystem),'&amp;conceptId=',encode-for-uri($concept/@code))
                                        else ('#')
                                 return
                                    <tr class="zebra-row-{if ($pos mod 2 = 0) then 'even' else 'odd'}">
                                        <td>{$levelType}</td>
                                        <td>
                                            {for $i in 1 to $levelNumber return '&#160;&#160;&#160;'}
                                        {
                                            if ($deeplinktocode) then 
                                                <a href="{$deeplinktocode}"><span style="color: grey;"><i>{$concept/@code/string()}</i></span></a>
                                            else
                                                <span style="color: grey;"><i>{$concept/@code/string()}</i></span>
                                        }
                                        </td>
                                        <td>{if ($concept/@codeSystemName) then ($concept/@codeSystemName/string()) else <i>{$concept/@codeSystem/string()}</i>}</td>
                                        {if ($valueSet/conceptList/*[@codeSystemVersion]) then (<td>{$concept/@codeSystemVersion/string()}</td>) else ()} 
                                        <td><span style="color: grey;"><i>{$concept/@displayName/string()}</i></span></td>
                                        <td>
                                        {
                                            for $conceptName in $concept/conceptName
                                            return <div>({$conceptName/@language/string()}) {data($conceptName)}</div>
                                        }
                                        </td>
                                        <td>{if ($concept[@originalDisplayName]) then $errorimg else ($okimg)}
                                        {
                                            if ($concept/@originalStatusCode) then
                                                <span class="node-s{$concept/@originalStatusCode}" title="{$concept/@originalStatusText}">{$concept/@originalDisplayName/string()}</span>
                                            else
                                                $concept/@originalDisplayName/string()
                                        }
                                        </td>
                                        <td>{$concept/desc[@language=$language or $language=''][1]/string()}</td>
                                    </tr>
                                 }
                                 <!--<tr>
                                    <td colspan="6">&#160;</td>
                                 </tr>-->
                                 <!--<tr style="background-color : #FAFAD2;">
                                    <td colspan="6">{msg:getMessage('CodeSystemLegendaLine',$language)}</td>
                                 </tr>-->
                              </tbody>
                          </table>
                    ) else ()}
                </div>
            
        ) else ()
        }
    </body>
    
    return $r/node()
};

declare function local:getStyles() as element() {
    <style type="text/css">
        .zebra-table { '{ border-collapse: collapse; border: 1px solid gray; }' }
        .zebra-table td { '{ padding: 6px; }' }
        .zebra-row-even { '{ background-color: #eee; }' }
        .zebra-row-odd { '{ background-color: #fff; }' }
        .node-sdraft, .node-spending, .node-sreview, .node-srejected, .node-snew,
        .node-sopen, .node-sclosed, .node-scancelled, .node-sdeprecated, .node-sretired,
        .node-sfinal, .node-sactive, .node-sinactive, .node-supdate, .node-s {
            '{ background-repeat:no-repeat;
            padding:0 0 0 18px;
            vertical-align: middle;
            line-height:18px; }'
        }
        .node-sdraft      { concat('{ background-image:url(''',$artDeepLink,'img/node-sdraft.png'') }') }
        .node-spending    { concat('{ background-image:url(''',$artDeepLink,'img/node-spending.png'') }') }
        .node-sreview     { concat('{ background-image:url(''',$artDeepLink,'img/node-sreview.png'') }') }
        .node-srejected   { concat('{ background-image:url(''',$artDeepLink,'img/node-srejected.png'') }') }
        .node-snew        { concat('{ background-image:url(''',$artDeepLink,'img/node-snew.png'') }') }
        .node-sopen       { concat('{ background-image:url(''',$artDeepLink,'img/node-sopen.png'') }') }
        .node-sclosed     { concat('{ background-image:url(''',$artDeepLink,'img/node-sclosed.png'') }') }
        .node-scancelled  { concat('{ background-image:url(''',$artDeepLink,'img/node-scancelled.png'') }') }
        .node-sdeprecated { concat('{ background-image:url(''',$artDeepLink,'img/node-sdeprecated.png'') }') }
        .node-sretired    { concat('{ background-image:url(''',$artDeepLink,'img/node-sretired.png'') }') }
        .node-sfinal      { concat('{ background-image:url(''',$artDeepLink,'img/node-sfinal.png'') }') }
        .node-sactive     { concat('{ background-image:url(''',$artDeepLink,'img/node-sactive.png'') }') }
        .node-sinactive   { concat('{ background-image:url(''',$artDeepLink,'img/node-sinactive.png'') }') }
        .node-supdate     { concat('{ background-image:url(''',$artDeepLink,'img/node-supdate.png'') }') }
        .node-s           { concat('{ background-image:url(''',$artDeepLink,'img/node-s.png'') }') }
    </style>
};

(:currently support HTML only to avoid travelling copies of the project:)
let $format           := if (request:exists()) then request:get-parameter('format','html')[1] else ()
let $format           := 'html'
(:currently do not support verbatim to avoid travelling copies of the project:)
let $mode             := if (request:exists()) then request:get-parameter('mode','valuesets')[1] else ()
let $mode             := if ($mode=('overview','valuesets','terminologyassociations')) then ($mode) else ('valuesets')
let $projectPrefix    := if (request:exists()) then request:get-parameter('prefix',())[1] else ()

let $download         := if (request:exists()) then request:get-parameter('download','false') else ('false')

let $decorproject     := 
    if (not(empty($projectPrefix))) then 
        collection($get:strDecorData)//decor[project[@prefix=$projectPrefix]]
    else ()

let $now              := datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")
let $language         := if ($decorproject) then $decorproject/project/@defaultLanguage else (aduser:getUserLanguage(xmldb:get-current-user()))
let $filenameverbatim := if (count($decorproject)=1) then concat(string-join(tokenize(util:document-name($decorproject),'\.')[position()!=last()],'.'),'-',replace($now,':',''),'.',$format) else ()
let $filenamecompiled := if (count($decorproject)=1) then concat(string-join(tokenize(util:document-name($decorproject),'\.')[position()!=last()],'.'),'-',replace($now,':',''),'-report.',$format) else ()

return 
    if (empty($decorproject)) then (
        (:response:set-status-code(404), <error>{msg:getMessage('errorRetrieveProjectNoResults',$language),' ',if (request:exists()) then request:get-query-string() else()}</error>:)
        response:set-header('Content-Type','text/html; charset=utf-8'),
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>TerminologyReport</title>
                <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
                <h1>TerminologyReport</h1>
                <div class="content">
                <form name="input">
                    <input type="hidden" name="language" value="{$language}"/>
                    <input type="hidden" name="mode" value="{$mode}"/>
                    <table border="0">
                        <tr>
                            <td width="20%">{msg:getMessage('Project',$language)}:</td>
                            <td>
                                <select name="prefix" style="width: 300px;">
                                {
                                    for $p in $get:colDecorData//decor/project
                                    order by lower-case($p/name[1])
                                    return
                                        <option value="{$p/@prefix}">{$p/name[1],' (',$p/@defaultLanguage/string(),')'}</option>
                                }
                                </select> (*)
                            </td>
                            <td/>
                        </tr>
                        <tr>
                            <td>{msg:getMessage('ReportType',$language)}:</td>
                            <td>
                                <select name="mode" style="width: 300px;">
                                    <!--option value="verbatim">verbatim</option-->
                                    <option value="overview">overview</option>
                                    <option value="valuesets" selected="true">valuesets</option>
                                    <option value="terminologyassociations">terminologyassociations</option>
                                </select> (*)
                            </td>
                            <td>
                                <!--div><i>verbatim</i> will give you the project as-is, no modification</div-->
                                <ul><li><i>overview</i> will you both valuesets and terminology associations as described below</li>
                                <li><i>valuesets</i> will give you, as much as possible, differences between display names in the value set and the original display name from the codesystem. Look for @originalDisplayName in the result.</li>
                                <li><i>terminologyassociations</i> will give you, as much as possible, differences between display names in the terminology associations and the display name in the value set (if it links to a dataset conceptList/concept and the conceptList binds to a value set) or codesystem (if it links to a dataset concept). This option gives you best results when the valueSets are correct.</li></ul>
                            </td>
                        </tr>
                        <tr>
                            <td>{msg:getMessage('Filter',$language)}:</td>
                            <td>
                                <input name="csfilter" style="width: 300px;"/> (*)
                            </td>
                            <td>
                                Allows filtering the returned HTML based on 1 or more code systems. Separate with a space in between. Examples <ul><li>(SNOMED-CT): 2.16.840.1.113883.6.96</li><li>(SNOMED-CT and LOINC): 2.16.840.1.113883.6.96 2.16.840.1.113883.6.1</li></ul>
                            </td>
                        </tr>
                        <!--tr>
                            <td>Output format:</td>
                            <td>HTML <option value="html" type="hidden">HTML</option>
                            </td>
                            <td></td>
                        </tr-->
                        <tr>
                            <td>Download to disk or show in browser:</td>
                            <td>
                                <select name="download" style="width: 300px;">
                                    <option value="true">Download</option>
                                    <option value="false" selected="true">Show</option>
                                </select>
                            </td>
                            <td/>
                        </tr>
                        <tr>
                            <td></td>
                            <td align="right">
                                <!--input type="submit" value="Send" style="color: black;"/-->
                                <input type="submit" value="{msg:getMessage('Send',$language)}" onclick="location.href=window.location.pathname+'?language={$language}"/>
                            </td>
                            <td/>
                        </tr>
                    </table>
                </form>
                </div>
            </body>
        </html>
    )
    else if (count($decorproject) != 1) then (
        response:set-status-code(404), <error>{msg:getMessage('errorRetrieveProjectNoSingleResult',$language),' ',if (request:exists()) then request:get-query-string() else()}</error>
    )
    else if ($format = 'xml') then (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        if ($download='true') then (
            response:set-header('Content-Disposition', concat('attachment; filename=',$filenamecompiled)),
            processing-instruction {'xml-stylesheet'} {' type="text/xsl" href="http://art-decor.org/ADAR/rv/DECOR2schematron.xsl"'}
        ) else (),
        processing-instruction {'xml-model'} {' href="http://art-decor.org/ADAR/rv/DECOR.xsd" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"'},
        local:doReport($decorproject, $mode, $now)
    )
    else (
        response:set-header('Content-Type','text/html; charset=utf-8'),
        if ($download='true') then (
            response:set-header('Content-Disposition', concat('attachment; filename=',$filenameverbatim))
        ) else (),
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>{$get:colDecorData//decor/project[@prefix=$projectPrefix]/name[@language=$language]/string()} report for {$mode}</title>
                {if ($download='true') then
                    <link href="{$artDeepLinkServices}resources/css/default.css" rel="stylesheet" type="text/css"/>
                 else
                    <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
                }
                {
                    local:getStyles()
                }
            </head>
            <body>
                <h1>{$get:colDecorData//decor/project[@prefix=$projectPrefix]/name[@language=$language]/string()} report for {$mode} ({$now})
                    <a href="#" onclick="javascript:location.href=window.location.pathname" style="float:right; font-size: 12px;">Form</a>
                </h1>
            {
                if (empty($codeSystemFilter)) then 
                    <p><b>No filtering applied</b></p> 
                else if (count($codeSystemFilter)=1) then 
                    <p><b>Only for code system: {for $cs in $codeSystemFilter return concat($cs, ' (',art:getNameForOID($cs,$language,()),')')}</b></p>
                else 
                    <p><b>Only for code systems: {for $cs in $codeSystemFilter return concat($cs, ' (',art:getNameForOID($cs,$language,()),')')}</b></p>
            }
            {
                local:projectTerminology2html(local:doReport($decorproject, $mode, $now),$language,$mode)
            }
            </body>
        </html>
    )