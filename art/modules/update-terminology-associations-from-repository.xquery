xquery version "3.0";
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

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";

(: are we just testing what would happening (false), 
   or actually doing it too (true) :)
declare variable $testMode   := if (request:exists()) then request:get-parameter('test','false') else ('true');
(: do we replace all associations tied into the original concept / conceptList / conceptList/concept ('replace'), 
   or do we only add what we don't already have ('add') :)
declare variable $runMode    := if (request:exists()) then request:get-parameter('mode','add') else ('add');

declare function local:addValueSetRef($decor as element(), $repoPrefix as xs:string, $association as element()) as item()* {
    let $repoDecor          := $get:colDecorData//decor[project/@prefix=$repoPrefix]
    
    let $repoVs             := $repoDecor/terminology/valueSet[(@id|@ref|@name)=$association/@valueSet][1]
    let $projectVs          := $decor/terminology/valueSet[(@id|@ref|@name)=$association/@valueSet][1]
    
    let $valueSetRefElm     := <valueSet ref="{$repoVs/(@id|@ref)}" name="{$repoVs/@name}">{$repoVs/@displayName}</valueSet>
    
    (: request:get-hostname() will give 127.0.0.1 :)
    let $hostNameAndPort    := if (request:exists()) then replace(request:get-url(),'^https?://?([^/]+).*','$1') else ('localhost:8877')
    let $buildingBlockElm   := <buildingBlockRepository url="http://{$hostNameAndPort}/decor/services/" ident="{$repoPrefix}"/>
    
    let $addValueSetRef     :=
        if (empty($projectVs) or $projectVs/(@id|@ref) != $repoVs/(@id|@ref)) then (
            let $dummy1 := update insert $valueSetRefElm following $decor/terminology/*[last()]
            let $dummy2 := 
                if (not($decor/project/buildingBlockRepository[@url=$buildingBlockElm/@url][@ident=$buildingBlockElm/@ident])) then (
                    let $dummy3 := update insert $buildingBlockElm following $decor/project/(author|reference|restURI|defaultElementNamespace|contact)[last()]
                    return 'true'
                ) else ('false')
            
            return if ($dummy2='true') then 'ref-and-bbr' else 'ref'
        ) 
        else ()
    
    return
        if ($addValueSetRef='ref-and-bbr') then
            <info>The terminology association points to value set {$valueSetRefElm/@name/string()} ({$valueSetRefElm/@ref/string()}) that did not exist yet, so a value set reference was created. A building 
                block repository link with url {$buildingBlockElm/@url/string()} and ident {$buildingBlockElm/@ident/string()} was also created to make this reference work.</info>
        else if ($addValueSetRef='ref') then
            <info>The terminology association points to value set {$valueSetRefElm/@name/string()} ({$valueSetRefElm/@ref/string()}) that did not exist yet, so a value set was created. The building 
                block repository link required to make this reference work already existed so it was not created.</info>
        else ()
};

declare function local:rewriteAssociations($prefix as xs:string, $associations as element()*) as element()* {
    let $projectTerminology := $get:colDecorData//decor[project/@prefix=$prefix]/terminology
    let $language           := $projectTerminology/ancestor::decor/project/@defaultLanguage/string()
    
    for $association in $associations
    let $codeSystemName := 
        if (string-length($association/@codeSystem)>0 and string-length($association/@codeSystemName)=0) then
            try {
                let $nm := art:getNameForOID($association/@codeSystem,$language,$prefix)
                return
                if (string-length($nm)>0) then $nm else ($association/@codeSystem)
            } 
            catch * {
                <description>ERROR {$err:code} : {$err:description, "', module: ",
                $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</description>
            }
        else ()
      
    (:let $codeSystemName := $association/@codeSystemName:)
    let $valueSetName   :=
        if (string-length($association/@valueSet)>0) then
            if (not(matches($association/@valueSet,'^[\d\.]+$'))) then (
                $association/@valueSet
            ) else if (matches($association/@flexibility,'^\d{4}')) then (
                $projectTerminology/valueSet[(@id|@ref)=$association/@valueSet][not(@effectiveDate) or @effectiveDate=$association/@flexibility]/@name
            ) else (
                $projectTerminology/valueSet[(@id|@ref)=$association/@valueSet][not(@effectiveDate) or @effectiveDate=string(max($projectTerminology/valueSet[@id=$association/@valueSet]/xs:dateTime(@effectiveDate)))]/@name
            )
        else ()
    return
    <terminologyAssociation conceptId="{$association/@conceptId}" 
        code="{$association/@code}" codeSystem="{$association/@codeSystem}" codeSystemName="{$codeSystemName}" displayName="{$association/@displayName}" 
        valueSet="{$association/@valueSet}" valueSetName="{$valueSetName}" flexibility="{$association/@flexibility}" 
        effectiveDate="{$association/@effectiveDate}" expirationDate="{$association/@expirationDate}"
        versionLabel="{$association/@versionLabel}"/>
};

declare function local:getAssociations($prefix as xs:string, $ids as item()*) as element()* {
    $get:colDecorData//decor[project/@prefix=$prefix]//terminologyAssociation[@conceptId=$ids]
};

declare function local:resetAssociationsFromRepository($concept as element()) as element() {
    let $decor                          := $concept/ancestor::decor
    let $conceptPrefix                  := $decor/project/@prefix
    let $originalConcept                := art:getOriginalConcept($concept/inherit)
    let $originalConceptPrefix          := $originalConcept//concept[1]/parent::*/@prefix
    let $originalConceptId              := $originalConcept//concept[1]/@id
    let $originalConceptListIds         := $originalConcept//valueDomain/conceptList/(@id|@ref)
    let $originalConceptListConceptIds  :=
        for $conceptList in $originalConcept//valueDomain/conceptList
        return
            if ($conceptList[@ref]) then (
                $get:colDecorData//decor[project/@prefix=$conceptPrefix]//dataset//conceptList[@id=$conceptList][not(ancestor::history)]/concept/@id
            ) else (
                $conceptList/concept/@id
            )
    
    (: note that we do not kill any associations for the $concept/@id, only those tied to the original concept :)
    let $projectAssociations    := local:getAssociations($conceptPrefix,        ($originalConceptId|$originalConceptListIds|$originalConceptListConceptIds))
    let $repositoryAssociations := local:getAssociations($originalConceptPrefix,($originalConceptId|$originalConceptListIds|$originalConceptListConceptIds))
    
    (: radical solution: delete first, insert later, might be too harsh :)
    return
    <result testing-mode="{$testMode}" run-mode="{$runMode}" concept="{$concept/@id}">
    {
        if ($runMode='replace') then (
            let $delete         := 
                if ($testMode='false') then
                    for $association in $projectAssociations return (update delete $association)
                else ()
            let $insert         := 
                if ($testMode='false') then (
                    update insert $repositoryAssociations preceding $decor//terminology/node()[1]
                    ,
                    for $repositoryAssociation in $repositoryAssociations[string-length(@valueSet)>0]
                    return local:addValueSetRef($decor,$originalConceptPrefix,$repositoryAssociation)
                )
                else ()
            let $insertwithref  := 
                for $repositoryAssociation in $repositoryAssociations[string-length(@valueSet)>0]
                let $refbbr := local:addValueSetRef($decor,$originalConceptPrefix,$repositoryAssociation)
                return 
                    <insert>
                    {
                        if ($refbbr instance of element(info)) then
                            attribute info {$refbbr}
                        else ()
                        ,
                        $repositoryAssociation
                    }
                    </insert>
                
            return (
                <delete>{$projectAssociations}</delete>,
                $insertwithref
            )
        )
        else if ($runMode='add') then (
            for $repositoryAssociation in $repositoryAssociations
            let $s_cid                  := $repositoryAssociation/@conceptId[string-length()>0]
            let $s_code                 := $repositoryAssociation/@code[string-length()>0]
            let $s_codeSystem           := $repositoryAssociation/@codeSystem[string-length()>0]
            let $s_valueSet             := $repositoryAssociation/@valueSet[string-length()>0]
            return
                if (not($projectAssociations[@conceptId=$s_cid][empty($s_valueSet) or @valueSet=$s_valueSet][empty($s_code) or (@code=$s_code and @codeSystem=$s_codeSystem)])) then (
                    if ($testMode='false') then (
                        update insert $repositoryAssociation preceding $decor//terminology/node()[1]
                        ,
                        for $repositoryAssociation in $repositoryAssociations[string-length(@valueSet)>0] 
                        let $refbbr := local:addValueSetRef($decor,$originalConceptPrefix,$repositoryAssociation)
                        return
                            <add>
                            {
                                if ($refbbr instance of element(info)) then
                                    attribute info {$refbbr}
                                else ()
                                ,
                                $repositoryAssociation
                            }
                            </add>
                    )
                    else (),
                    <add>{local:rewriteAssociations($originalConceptPrefix, $repositoryAssociation)}</add>
                )
                else ()
            
        )
        else (
            <error>Unknown value for parameter mode {$runMode}</error>
        )
        ,
        <repository prefix="{$originalConceptPrefix}">{$repositoryAssociations}</repository>
    }
    </result>
};

let $conceptId          := if (request:exists()) then request:get-parameter('id',()) else ('2.16.840.1.113883.2.4.3.11.60.104.2.110')
let $concept            := $get:colDecorData//dataset//concept[@id=$conceptId][not(ancestor::history)][1]

return
    if (empty($concept) or $concept[not(inherit)]) then
        <result testing-mode="{$testMode}" run-mode="{$runMode}" concept="{$conceptId}"/>
    else (
        local:resetAssociationsFromRepository($concept)
    )
