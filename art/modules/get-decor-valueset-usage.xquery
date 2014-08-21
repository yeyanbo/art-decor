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

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace vs  = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";

let $valueSetsAll           := if (request:exists()) then request:get-data() else ()
let $projectPrefix          := if (request:exists()) then request:get-parameter('prefix',()) else ()
let $id                     := if (request:exists()) then request:get-parameter('id',()) else ()
let $name                   := if (request:exists()) then request:get-parameter('name',()) else ()
let $effectiveDate          := if (request:exists()) then request:get-parameter('effectiveDate',()) else ()

let $valueSetsAll           :=
    if ($valueSetsAll) then
        $valueSetsAll
    else if ($id) then
        if ($projectPrefix) then
            vs:getValueSetById($id,(),$projectPrefix)
        else (
            vs:getValueSetById($id,())
        )
    
    else if ($name) then
        if ($projectPrefix) then
            vs:getValueSetByName($name,(),$projectPrefix,false())
        else (
            vs:getValueSetByName($name,(),false())
        )
    
    else ()

let $decor                  := $get:colDecorData/decor

let $allAssociations        :=
    $decor/terminology/terminologyAssociation[@valueSet=$valueSetsAll//valueSet/(@id|@ref)] |
    $decor/terminology/terminologyAssociation[@valueSet=$valueSetsAll//valueSet/@name][../valueSet/(@id|@ref)=$valueSetsAll//valueSet/(@id|@ref)]
    
let $staticAssociations     := $allAssociations[@flexibility=$valueSetsAll//valueSet/@effectiveDate]
let $dynamicAssociations    := $allAssociations[not(@flexibility)]|$allAssociations[@flexibility='dynamic']

let $allConcepts            := $decor/datasets/dataset//concept[not(ancestor::history)][not(parent::conceptList)]
let $originalConcepts       :=
    $allConcepts[valueDomain/conceptList/@id=$allAssociations/@conceptId] |
    $allConcepts[valueDomain/conceptList/@ref=$allAssociations/@conceptId]
let $inheritingConcepts     :=
    $allConcepts[inherit/@ref=$originalConcepts/@id][inherit/@effectiveDate=$originalConcepts/@effectiveDate]

let $inScopeConcepts        := $originalConcepts|$inheritingConcepts
    
let $templatesVocabulary    := 
    $decor/rules/template//vocabulary[@valueSet=$id] |
    $decor/rules/template//vocabulary[@valueSet=$name]

(: Check if valueset is the most recent version :)
let $mostRecent             := (empty($effectiveDate) or $effectiveDate=string(max($valueSetsAll//valueSet[@effectiveDate]/xs:dateTime(@effectiveDate))))

(: 
ALERT/FIXME: opportunistic approach towards finding the right set of associations. Official picture:
- An association points to "our value set" if it lives the same project
- An association points to "our value set" if it lives in a project that references our project AND valueSet/@ref

Now the problem is that we do not know if it references our project unless we check both buildingBlockRepository/@url AND @ident, 
but how do we know that @url points to "our server"? Opportunistically we now check @ident only, which could mean incorrect hits 
if there's project on another server by the same prefix.
Second thing is that we now do not check if the terminologyAssociation or vocabulary references a valueSet/@ref, hence if a project 
happens both a reference to "our project", and a value set by the same name, but which is not "our value set", it might give yet another
incorrect hit.

Both scenarios are somewhat unlikely but surely not impossible.
:)

return
<usage prefix="{$projectPrefix}" id="{$id}" name="{$name}" effectiveDate="{$effectiveDate}" mostRecent="{$mostRecent}">
{
    if ($mostRecent) then (
        for $concept in $inScopeConcepts[ancestor::decor/project/@prefix=$dynamicAssociations/ancestor::decor/project/@prefix]
        let $originalId     := $concept/@id
        let $baseId         := string-join(tokenize($originalId,'\.')[position()!=last()],'.')
        let $baseIdPrefix   := $get:colDecorData//baseId[@id=$baseId]/@prefix
        let $readableId     := if (empty($baseIdPrefix)) then $originalId else concat($baseIdPrefix,tokenize($originalId,'\.')[last()])
        
        let $fullConcept    :=
            if ($concept/inherit) then (
                let $inheritedConcept := art:getOriginalConcept($concept/inherit)
                return
                    $inheritedConcept//concept[parent::inherit][1]
            ) else (
                $concept
            )
        let $dynBindings    := $dynamicAssociations[@conceptId=$fullConcept/valueDomain/conceptList/(@id|@ref)]
        return
            if (exists($dynBindings)) then (
                <association id="{distinct-values($dynBindings/@conceptId)}" conceptId="{$readableId}" originalConceptId="{$originalId}" type="dynamic" 
                             datasetId="{$concept/ancestor::dataset/@id}" prefix="{$concept/ancestor::decor/project/@prefix}"
                             projectName="{$concept/ancestor::decor/project/name[1]}">
                {
                    $fullConcept/name
                }
                </association>
            ) else ()
    
    ) else ()
}
{
    for $concept in $inScopeConcepts[ancestor::decor/project/@prefix=$staticAssociations/ancestor::decor/project/@prefix]
    let $originalId     := $concept/@id
    let $baseId         := string-join(tokenize($originalId,'\.')[position()!=last()],'.')
    let $baseIdPrefix   := $get:colDecorData//baseId[@id=$baseId]/@prefix
    let $readableId     := if (empty($baseIdPrefix)) then $originalId else concat($baseIdPrefix,tokenize($originalId,'\.')[last()])
    
    let $fullConcept    :=
        if ($concept/inherit) then (
            let $inheritedConcept := art:getOriginalConcept($concept/inherit)
            return
                $inheritedConcept//concept[parent::inherit][1]
        ) else (
            $concept
        )
    let $statBindings   := $staticAssociations[@conceptId=$fullConcept/valueDomain/conceptList/(@id|@ref)]
    return
        if (exists($statBindings)) then (
            <association id="{distinct-values($statBindings/@conceptId)}" conceptId="{$readableId}" originalConceptId="{$originalId}" type="static" 
                     datasetId="{$concept/ancestor::dataset/@id}" prefix="{$concept/ancestor::decor/project/@prefix}"
                     projectName="{$concept/ancestor::decor/project/name[1]}">
            {
                $fullConcept/name
            }
            </association>
        ) else ()
}
{
    for $terminologyAssociation in $decor[project/@prefix=$projectPrefix]/terminology/terminologyAssociation
    let $code                   := $terminologyAssociation/@code
    let $codeSystem             := $terminologyAssociation/@codeSystem
    let $codeSystemVersion      := $terminologyAssociation/@codeSystemVersion
    let $inScope                := $valueSetsAll//*[@code=$code][@codeSystem=$codeSystem]
    return
        if ($inScope) then (
            let $originalConcept    := $decor//concept[@id=$terminologyAssociation/@conceptId][not(ancestor::history)]
            let $originalParent     := $originalConcept/ancestor::concept[1]
            let $projectConcepts    := $originalParent[ancestor::decor/project/@prefix=$projectPrefix] | $decor[project/@prefix=$projectPrefix]//concept[inherit/@ref=$originalParent/@id][inherit/@effectiveDate=$originalParent/@effectiveDate][not(ancestor::history)]
            return
                <terminologyAssociation>
                {
                    $terminologyAssociation/@*
                    ,
                    $originalConcept/name
                }
                {
                    for $concept in $projectConcepts
                    return
                        <concept id="{$concept/@id}" effectiveDate="{$concept/@effectiveDate}"/>
                }
                </terminologyAssociation>
        ) else ()
}
{
    if ($mostRecent) then
        for $template in ($templatesVocabulary[not(@flexibility)] | $templatesVocabulary[@flexibility='dynamic'])
        let $tr := $template[1]/ancestor::template
        group by $parent := concat($template/ancestor::template/@id,$template/ancestor::template/@ref,$template/ancestor::template/@effectiveDate,$template/ancestor::template/@flexibility)
        return
            <template id="{$tr/@id}" name="{$tr/@name}" displayName="{$tr/@displayName}" effectiveDate="{$tr/@effectiveDate}" 
                      type="dynamic" prefix="{$template/ancestor::decor/project/@prefix}" projectName="{$template/ancestor::decor/project/name[1]}"/>
    else (
        for $template in $templatesVocabulary[@flexibility=$effectiveDate]
        let $tr := $template[1]/ancestor::template
        group by $parent := concat($template/ancestor::template/@id,$template/ancestor::template/@ref,$template/ancestor::template/@effectiveDate,$template/ancestor::template/@flexibility)
        return
            <template id="{$tr/@id}" name="{$tr/@name}" displayName="{$tr/@displayName}" effectiveDate="{$tr/@effectiveDate}" 
                      type="static" prefix="{$template/ancestor::decor/project/@prefix}" projectName="{$template/ancestor::decor/project/name[1]}"/>
    )
}
</usage>

