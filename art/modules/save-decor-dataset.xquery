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
import module namespace art = "http://art-decor.org/ns/art" at  "art-decor.xqm";

declare function local:storeTerminologyAssociation($terminologyAssociations as element()*, $decor as element()) as item()? {
   if (empty($terminologyAssociations)) then (
   )
   else if (not($decor/terminology)) then (
       update insert <terminology>{$terminologyAssociations}</terminology> following $decor/ids
   )
   else if ($decor/terminology/terminologyAssociation) then (
       update insert $terminologyAssociations following $decor/terminology/terminologyAssociation[count($decor/terminology/terminologyAssociation)]
   )
   else (
       update insert $terminologyAssociations preceding $decor/terminology/*[1]
   )
};

(: get dataset from request :)
let $editedDataset      := if (request:exists()) then (request:get-data()/dataset) else ()
(: dataset stored in DB :)
let $storedDataset      := $get:colDecorData//dataset[@id=$editedDataset/@id]
(: the whole decor resource:)
let $decor              := $storedDataset/ancestor::decor
(: project prefix :)
let $projectPrefix      := $decor/project/@prefix

(:
   start with deleting concepts:
   if statusCode=new     delete concept
   if statusCode!=new    set statusCode=deprecated
:)
let $deletes           :=
    for $concept in $editedDataset//concept[edit/@mode='delete']
    let $storedConcept := $storedDataset//concept[@id=$concept/@id][not(ancestor::history)]
    let $lock          := $get:colArtResources//conceptLock[@ref=$concept/conceptLock/@ref][@effectiveDate=$concept/conceptLock/@effectiveDate]
    return
        if ($editedDataset/@statusCode!='new') then
            if ($storedConcept/@statusCode='new' and $lock) then (
                update delete $storedConcept,
                update delete $lock
            )
            else if ($storedConcept/@statusCode!='new' and $lock) then (
                if ($concept/@type='item') then (
                    update replace $storedConcept with art:prepareItemForUpdate($concept,$storedConcept),
                    update delete $lock
                )
                else if ($concept/@type='group') then (
                    update replace $storedConcept with art:prepareGroupForUpdate($concept,$storedConcept),
                    update delete $lock
                ) else ()
            ) 
            else ()
        else (
            if ($lock) then (
                update delete $storedConcept,
                update delete $lock
            ) else ()
        )
(:
   move concepts
   - local move
      - delete stored concept
      - insert moved concept after editedDataset preceding-sibling or into parent concept
   - move to other dataset (unsupported!!)
      - 
   
:)
let $moves :=
    for $concept in $editedDataset//concept[move]
    let $storedConcept      := $storedDataset//concept[@id=$concept/@id][not(ancestor::history)]
    let $lock               := $get:colArtResources//conceptLock[@ref=$concept/conceptLock/@ref][@effectiveDate=$concept/conceptLock/@effectiveDate]
    let $preparedConcept    :=
        if ($concept/@type='item') then
            art:prepareItemForUpdate($concept,$storedConcept)
        else if ($concept/@type='group') then
            art:prepareGroupForUpdate($concept,$storedConcept)
        else (
            (:huh? ... :)
        )
    return
    if ($preparedConcept and $lock) then
        <update>
        {
            if ($concept/preceding-sibling::concept) then
                update insert $preparedConcept following $storedDataset//concept[@id=$concept/preceding-sibling::concept[1]/@id][not(ancestor::history)]
            
            (: note that we need to check whether or not there is a next node that already is in the right place
               otherwise we just place ourselves back into the group we came from based on the location of the 
               first next element which was not moved yet -- Sourceforge ticket 84
            :)
            else if ($concept/following-sibling::concept[not(move)]) then
                update insert $preparedConcept preceding $storedDataset//concept[@id=$concept/following-sibling::concept[not(move)][1]/@id][not(ancestor::history)]
            
            else if ($concept/following-sibling::history) then
                update insert $preparedConcept preceding $storedDataset//concept[@id=$concept/parent::concept/@id][not(ancestor::history)]/history[1]
            
            else (
                update insert $preparedConcept into $storedDataset//concept[@id=$concept/parent::concept/@id][not(ancestor::history)]
            )
            ,
            update delete $storedConcept,
            update delete $lock
        }
        </update>
    else()

let $updates :=
    for $concept in $editedDataset//concept[edit/@mode='edit'][not(move)]
    let $storedConcept      := $storedDataset//concept[@id=$concept/@id][not(ancestor::history)]
    let $lock               := $get:colArtResources//conceptLock[@ref=$concept/conceptLock/@ref][@effectiveDate=$concept/conceptLock/@effectiveDate]
    let $preparedConcept    :=
        if ($concept/@type='item') then
            art:prepareItemForUpdate($concept,$storedConcept)
        else if ($concept/@type='group') then
            art:prepareGroupForUpdate($concept,$storedConcept)
        else (
            (:huh? ... :)
        )
    return
    if ($preparedConcept and $lock) then
        <update>
        {
            update replace $storedConcept with $preparedConcept,
            update delete $lock
        }
        </update>
    else ()

let $datasetNameUpdate :=
    for $name in $editedDataset/name
    return
        art:parseNode($name)
let $datasetDescUpdate :=
    for $desc in $editedDataset/desc
    return
        art:parseNode($desc)
let $datasetUpdate :=
    (
        update delete $storedDataset/(name|desc),
        if ($storedDataset[*]) then
            update insert ($datasetNameUpdate|$datasetDescUpdate) preceding $storedDataset/*[1]
        else (
            update insert ($datasetNameUpdate|$datasetDescUpdate) into $storedDataset
        )
        ,
        update value $storedDataset/@statusCode with $editedDataset/@statusCode,
        if ($editedDataset/@versionLabel[string-length(normalize-space())>0]) then (
            if ($storedDataset/@versionLabel) then 
                update value $storedDataset/@versionLabel with $editedDataset/@versionLabel
            else (
                update insert attribute versionLabel {$editedDataset/@versionLabel} into $storedDataset
            )
        ) else (
            update delete $storedDataset/@versionLabel
        )
    )

(:store any terminologyAssociations that were saved in the dataset after deInherit
    only store stuff where the concept(List) still exists
:)
let $terminologyAssociationUpdates :=
        local:storeTerminologyAssociation($editedDataset//terminologyAssociation[@conceptId=$editedDataset//@id],$decor)

return
<data-safe>true</data-safe>
