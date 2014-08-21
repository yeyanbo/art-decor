xquery version "3.0";
(:
	Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
	
	Author: Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

(:~
:   Physically copies a dataset with attached terminologyAssociations/valueSets to a repository
:   - checks whether or not the source project equals the target project. It should not.
:   - checks whether or not the target project is actually a repository. It should.
:   - checks whether or not the supplied dataset id exists in the source project. It should.
:   - does a full dataset copy and then does the following in the target
:       - remove all history elements
:       - replace the source project id in all @id|@ref with the target project id
:       - replace the dataset id with the first available dataset id in the target
:       - set the dataset status to 'final'
:   - copies all terminologyAssociations that bind into the dataset being copied regardless of type
:       - replace the source project id in all @conceptId with the target project id
:   - copies all valueSets that are bound through the copied terminologyAssociations
:       - replace the source project id in all @id with the target project id
:       - set the valueSet status to 'final'
:
:   Known issues:
:   - If the source is inconsistent, the target will be too. It's the way it is
:   - The source may have a different branching strategy for numbering datasets/concepts/concept lists than the target. It's the way it is
:       - conceptList may be .8 in source, and ."conceptId".0 in the other
:   - There's no check on uniqueness after replace replacing the source project id with the target project id on @id|@ref
:       - this should be looked into at some point
:   - Contrary to what the name of this xquery suggests it currently only does copy, instead of move
:       - once the copy procedure is ironed out a little more and tested, this should be on the wish list. The procedure is listed below:
:
:   What you need to do in the source project:
:   - remove the dataset you have just copied
:   - use ART to inherit the dataset from the new repository 
:       - this creates new ids, nicer would be to retain the current final part of all items and groups as they might be known to third parties 
:   - update terminologyAssociation/@conceptId
:       - for terminologyAssociations with concept item/group you need to look up the new id
:       - for terminologyAssociations with (concepts in a) concept list you ncan just replace the source project id with the target project id
:   - update valueSets
:       - replace all copied valueSets with a <valueSet ref="repository id" name="original @name" displayName="original displayName"/>
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

declare function local:move-dataset($sourcePrefix as xs:string, $targetPrefix as xs:string, $sourceDatasetId as xs:string) as element() {
    let $sourceProjectId                := $get:colDecorData//decor/project[@prefix=$sourcePrefix]/@id/string()
    let $targetProjectId                := $get:colDecorData//decor/project[@prefix=$targetPrefix]/@id/string()
    let $targetDefaultDatasetBaseId     := $get:colDecorData//decor[project/@prefix=$targetPrefix]/ids/defaultBaseId[@type='DS']/@id/string()
    let $targetDefaultConceptBaseId     := $get:colDecorData//decor[project/@prefix=$targetPrefix]/ids/defaultBaseId[@type='DE']/@id/string()
    (:let $targetDefaultConceptListBaseId := $get:colDecorData//decor[project/@prefix=$targetPrefix]/ids/defaultBaseId[@type='CL']/@id/string():)
    let $targetDatasetId                := 
        if ($get:colDecorData/decor[project/@prefix=$targetPrefix]/datasets/dataset) then (
            string(max($get:colDecorData/decor[project/@prefix=$targetPrefix]/datasets/dataset/number(tokenize(@id,'\.')[last()]))+1)
        ) else (
            '1'
        )
    let $sourceDataset  := $get:colDecorData/decor[project/@prefix=$sourcePrefix]/datasets/dataset[@id=$sourceDatasetId]
    
    let $storeTarget    := 
        if (not(exists($get:colDecorData/decor[project/@prefix=$targetPrefix]/datasets))) then (
            update insert <datasets/> following $get:colDecorData/decor/project[@prefix=$targetPrefix][1]
        ) else ()
    let $storeTarget    := update insert $sourceDataset into $get:colDecorData/decor[project[@prefix=$targetPrefix]]/datasets
    
    let $targetDataset  := $get:colDecorData/decor[project/@prefix=$targetPrefix]/datasets/dataset[@id=$sourceDatasetId]
    
    (:remove history elements:)
    let $updateTarget   := update delete $targetDataset//history
    (:update ids that start with the source project id, by placing the source project id with the target project id:)
    (:TODO: with this methodology we could get duplicate ids, need more complex logic:)
    let $updateTarget   :=
        for $id in $targetDataset//*/(@id|@ref)[starts-with(.,$sourceProjectId)]
        let $newid := replace($id/string(),$sourceProjectId,$targetProjectId)
        return
            update replace $id with $newid
    (:update dataset id:)
    let $updateTarget   := update replace $targetDataset/@id with concat($targetDefaultDatasetBaseId,'.',$targetDatasetId)
    (:update dataset statusCode:)
    let $updateTarget   := update replace $targetDataset//@statusCode with 'final'
    
    return
        <data-safe>true</data-safe>
    
};

declare function local:move-valueset($sourcePrefix as xs:string, $targetPrefix as xs:string, $sourceDatasetId as xs:string) as element() {
    let $sourceProjectId                := $get:colDecorData//decor/project[@prefix=$sourcePrefix]/@id/string()
    let $targetProjectId                := $get:colDecorData//decor/project[@prefix=$targetPrefix]/@id/string()
    let $targetDefaultValuesetBaseId    := $get:colDecorData//decor[project/@prefix=$targetPrefix]/ids/defaultBaseId[@type='VS']/@id/string()
    let $targetValueSetId               := 
        if ($get:colDecorData/decor[project/@prefix=$targetPrefix]/terminology/valueSet) then (
            string(max($get:colDecorData/decor[project/@prefix=$targetPrefix]/terminology/valueSet[@id]/number(tokenize(@id,'\.')[last()]))+1)
        ) else (
            '1'
        )
    let $sourceTermAssocs  := $get:colDecorData/decor[project/@prefix=$sourcePrefix]/terminology/terminologyAssociation[@conceptId=ancestor::decor/datasets/dataset[@id=$sourceDatasetId]//(concept|conceptList)[not(ancestor::history)]/@id]
    let $sourceValueSets   := 
        for $valueSet in $get:colDecorData/decor[project/@prefix=$sourcePrefix]/terminology/valueSet[(@id|@ref|@name)=$sourceTermAssocs/@valueSet]
        let $inScopeTermAssocs := $sourceTermAssocs[@valueSet=$valueSet/(@id|@ref|@name)]
        let $isLatest          := $valueSet[not(@effectiveDate) or @effectiveDate=string(max($get:colDecorData/decor[project/@prefix=$sourcePrefix]/terminology/valueSet[@id=$valueSet/@id or @name=$valueSet[@id]/@name]/xs:dateTime(@effectiveDate)))]
        return
            if ($valueSet/@ref or $valueSet/@effectiveDate=$inScopeTermAssocs/@flexibility or ($isLatest and $inScopeTermAssocs[not(@flexibility) or @flexibility='dynamic'])) then
                $valueSet
            else (
                (:<valueSetSkipped id="{$valueSet/@id}" effectiveDate="{$valueSet/@effectiveDate}"/>:)
            )
    
    let $update           :=
        if (exists($sourceTermAssocs or $sourceValueSets)) then
            let $storeTarget      := 
                if (not(exists($get:colDecorData/decor[project/@prefix=$targetPrefix]/terminology))) then (
                    update insert <terminology/> following $get:colDecorData/decor[project[@prefix=$targetPrefix]]/ids
                ) else ()
            let $storeTarget      := 
                if (exists($sourceTermAssocs)) then 
                    update insert $sourceTermAssocs into $get:colDecorData/decor[project[@prefix=$targetPrefix]]/terminology
                else ()
            let $storeTarget      := 
                if (exists($sourceValueSets)) then
                    update insert $sourceValueSets into $get:colDecorData/decor[project[@prefix=$targetPrefix]]/terminology
                else ()
            
            let $updateTarget     :=
                for $valueSet in $get:colDecorData/decor[project[@prefix=$targetPrefix]]/terminology/valueSet[@id[starts-with(.,$sourceProjectId)]]
                let $newid          := replace($valueSet/@id/string(),$sourceProjectId,$targetProjectId)
                let $updateTarget   := update replace $valueSet/@id with $newid
                let $updateTarget   := update replace $valueSet/@statusCode with 'final'
                return ()
            
            let $updateTarget     :=
                for $id in $get:colDecorData/decor[project[@prefix=$targetPrefix]]/terminology/terminologyAssociation[@conceptId[starts-with(.,$sourceProjectId)]]
                let $newconceptid   := replace($id/@conceptId/string(),$sourceProjectId,$targetProjectId)
                let $newvaluesetref := replace($id/@valueSet/string(),$sourceProjectId,$targetProjectId)
                let $updatecpt      := update replace $id/@conceptId with $newconceptid
                let $updatecpt      := update replace $id/@valueSet with $newvaluesetref
                return ()
            
            return ()
         else ()
    
    return
        <data-safe>true</data-safe>
    
};

let $sourcePrefix       := if (request:exists()) then request:get-parameter('prefix-from',()) else ('hwg-')
let $targetPrefix       := if (request:exists()) then request:get-parameter('prefix-to',()) else ('kz-')

let $sourceDatasetId    := if (request:exists()) then request:get-parameter('dataset-id',()) else ('2.16.840.1.113883.2.4.3.11.60.70.77.1.2')

let $sourceEqualsTarget := $sourcePrefix=$targetPrefix
let $sourceHasDataset   := exists($get:colDecorData//decor[project/@prefix=$sourcePrefix][datasets/dataset[@id=$sourceDatasetId]])
let $targetIsRepo       := exists($get:colDecorData//decor[project/@prefix=$targetPrefix][@repository='true'])

return
    if ($sourceEqualsTarget) then (
        response:set-status-code(500), 
        response:set-header('Content-Type','text/xml; charset=utf-8'), 
        <data-safe error="Source project prefix cannot be equal to project target prefix. '{$sourcePrefix}'='{$targetPrefix}'">false</data-safe>
    ) else if ($sourceHasDataset=false()) then (
        response:set-status-code(500), 
        response:set-header('Content-Type','text/xml; charset=utf-8'), 
        <data-safe error="Dataset does not exist in the project with the supplied prefix. Dataset '{$sourceDatasetId}', project '{$sourcePrefix}'">false</data-safe>
    ) else if ($targetIsRepo=false()) then (
        response:set-status-code(500), 
        response:set-header('Content-Type','text/xml; charset=utf-8'), 
        <data-safe error="Target project is not a repository. Project '{$targetPrefix}'">false</data-safe>
    ) else (
        let $move :=
            try {
                local:move-dataset($sourcePrefix, $targetPrefix, $sourceDatasetId)
            }
            catch * {
                <data-safe error="ERROR {$err:code} in moving the data set: {$err:description} module: {$err:module} [line {$err:line-number}: col {$err:column-number}]">false</data-safe>
            }
            
        let $move :=
            if ($move/string()='false') then (
                $move
            ) else (
                try {
                    local:move-valueset($sourcePrefix, $targetPrefix, $sourceDatasetId)
                }
                catch * {
                    <data-safe error="ERROR {$err:code} in moving the value sets: {$err:description} module: {$err:module} [line {$err:line-number}: col {$err:column-number}]">false</data-safe>
                }
            )
                
        return $move
    )