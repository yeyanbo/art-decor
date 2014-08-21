xquery version "3.0";
(:
	Copyright (C) 2011-2013 Art-Decor Expert Group
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
	

	
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";

let $concepts := collection(concat($get:strTerminologyData,'/snomed-extension/import'))//concept
let $descriptions := collection(concat($get:strTerminologyData,'/snomed-extension/import'))//description
let $statedRelations := collection(concat($get:strTerminologyData,'/snomed-extension/import'))//relation
let $language := collection(concat($get:strTerminologyData,'/snomed-extension/import'))//language
let $snomed :=collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept
let $extension :=collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept
let $extensionModuleId := '11000146104'

let $mode := 'import'
(:let $mode := 'report':)

let $newConcepts :=
      for $concept in $concepts[not(@id=$extension/@soId)][string-length(@id) gt 0]
      let $descs := $descriptions[@conceptId=$concept/@id]
      let $relations := $statedRelations[@sourceId=$concept/@id]
      let $destinations := $statedRelations[@destinationId=$concept/@id]
      let $effectiveTime :=
         if (lower-case($concept/@effectiveTime)='unpublished') then
            ''
         else(datetime:format-date(xs:date(concat(substring($concept/@effectiveTime,1,4),'-',substring($concept/@effectiveTime,5,2),'-',substring($concept/@effectiveTime,7,2))),"yyyy-MM-dd"))
      let $moduleId:= if($concept/@moduleId='636635721000154103') then $extensionModuleId else $concept/@moduleId
      let $newConcept :=
               <concept uuid="{util:uuid()}" soId="{$concept/@id}"  moduleId="{$moduleId}" conceptId="" effectiveTime="{$effectiveTime}" statusCode="draft">
         {
            $concept/@*[not(name()=('effectiveTime','moduleId'))],
            for $desc in $descs[@active='1']
            let $lang := $language[@referencedComponentId=$desc/@id]
            let $type:=
               if($desc/@typeId='900000000000003001') then
                  'fsn'
               else
               (
                  if ($lang/@acceptabilityId='900000000000548007') then
                     'pref'
                  else('syn')
               )
             let $descEffectiveTime :=
               if (lower-case($desc/@effectiveTime)='unpublished') then
                  ''
               else(datetime:format-date(xs:date(concat(substring($desc/@effectiveTime,1,4),'-',substring($desc/@effectiveTime,5,2),'-',substring($desc/@effectiveTime,7,2))),"yyyy-MM-dd"))
            return
            <desc uuid="{util:uuid()}" soId="{$desc/@id}" id="" effectiveTime="{$descEffectiveTime}"  moduleId="{$moduleId}" statusCode="draft" type="{$type}" count="{count(tokenize($desc/@term,'\s'))}" length="{string-length($desc/@term)}">
               {
               $desc/@*[not(name()=('effectiveTime','id','moduleId'))],
               $desc/@term/string()
               }
            </desc>
            ,
            for $relation in $relations[@active='1']
            let $relType := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$relation/@typeId]
            let $dest :=
               if ($descriptions[@conceptId=$relation/@destinationId]) then
                  $descriptions[@conceptId=$relation/@destinationId][1]/@term/string()
               else(collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$relation/@destinationId]/desc[@type='pref']/text())
            let $relationEffectiveTime :=
               if (lower-case($relation/@effectiveTime)='unpublished') then
                  ''
               else(datetime:format-date(xs:date(concat(substring($relation/@effectiveTime,1,4),'-',substring($relation/@effectiveTime,5,2),'-',substring($relation/@effectiveTime,7,2))),"yyyy-MM-dd"))
            return
            <src uuid="{util:uuid()}" soId="{$relation/@id}" id="" moduleId="{$moduleId}" effectiveTime="{$relationEffectiveTime}" statusCode="draft" type="{$relType/desc[@type='pref']}">
            {
            $relation/@*[not(name()=('effectiveTime','id','moduleId'))],
            $dest
            }
            </src>
            ,
            for $relation in $destinations[@active='1'][@typeId='116680003']
            let $relType := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$relation/@typeId]
            let $src :=
               if ($descriptions[@conceptId=$relation/@sourceId]) then
                  $descriptions[@conceptId=$relation/@sourceId][1]/@term/string()
               else(collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$relation/@sourceId]/desc[@type='pref']/text())
            let $relationEffectiveTime :=
               if (lower-case($relation/@effectiveTime)='unpublished') then
                  ''
               else(datetime:format-date(xs:date(concat(substring($relation/@effectiveTime,1,4),'-',substring($relation/@effectiveTime,5,2),'-',substring($relation/@effectiveTime,7,2))),"yyyy-MM-dd"))
            return
            <dest uuid="{util:uuid()}" soId="{$relation/@id}" id="" moduleId="{$moduleId}" effectiveTime="{$relationEffectiveTime}" statusCode="draft" type="{$relType/desc[@type='pref']}">
            {
            $relation/@*[not(name()=('effectiveTime','id','moduleId'))],
            $src
            }
            </dest>
         }
         </concept>
      return
      $newConcept

let $newDescriptions :=
   for $desc in $newConcepts//desc
       let $effectiveTime :=
      if ($desc/@effectiveTime castable as xs:date) then
         datetime:format-date(xs:date($desc/@effectiveTime),"yyyy-MM-dd")
      else($desc/@effectiveTime)
    let $active := if ($desc/@statusCode='active') then '1' else '0'
    let $acceptability := if ($desc/@type='pref') then '900000000000548007' else '900000000000549004'
    let $languageRefsetId:= if ($desc/@languageCode='en') then '900000000000509007' else '31000146106'
   return
   <description  uuid="{$desc/@uuid}"  id="{$desc/@id}" soId="{$desc/@soId}" effectiveTime="{$effectiveTime}" statusCode="{$desc/@statusCode}" type="{$desc/@type}" count="{$desc/@count}" length="{$desc/@length}" active="{$desc/@active}" moduleId="{$desc/@moduleId}" conceptId="{$desc/parent::concept/@soId}" languageCode="{$desc/@languageCode}" typeId="{$desc/@typeId}" caseSignificanceId="{$desc/@caseSignificanceId}">
      <desc>{$desc/text()}</desc>
      <languageRefset  id="{$desc/@uuid}" effectiveTime="{$effectiveTime}" active="{$active}" moduleId="{$extensionModuleId}" languageRefsetId="{$languageRefsetId}" acceptabilityId="{$acceptability}"/>
   </description>

return
(
   (:update existing concepts:)
   for $concept in $concepts[@id=$extension/@soId][string-length(@id) gt 0]
   let $existingConcept := $extension[@soId=$concept/@id]
   let $effectiveTime := datetime:format-date(xs:date(concat(substring($concept/@effectiveTime,1,4),'-',substring($concept/@effectiveTime,5,2),'-',substring($concept/@effectiveTime,7,2))),"yyyy-MM-dd")
   return
   (
   $concept,
   if ($mode='import') then
      (
      update value $existingConcept/@effectiveTime with $effectiveTime,
      update value $existingConcept/@active with $concept/@active,
      update value $existingConcept/@definitionStatusId with $concept/@definitionStatusId
      )
   else()
   )
,
   (:update existing descriptions:)
   for $desc in $descriptions[@id=$extension//desc/@soId][string-length(@id) gt 0]
   let $existingDesc := $extension//desc[@soId=$desc/@id]
   let $effectiveTime := datetime:format-date(xs:date(concat(substring($desc/@effectiveTime,1,4),'-',substring($desc/@effectiveTime,5,2),'-',substring($desc/@effectiveTime,7,2))),"yyyy-MM-dd")
   return
   (
   $desc,
   if ($mode='import') then
      (
      update value $existingDesc/@effectiveTime with $effectiveTime,
      update value $existingDesc/@active with $desc/@active,
      update value $existingDesc/text() with $desc/@term,
      update value $existingDesc/@caseSignificanceId with $desc/@caseSignificanceId
      )
   else()
   )
,   
   (:update existing relationships:)
   for $relation in $statedRelations[@id=$extension//src/@soId][string-length(@id) gt 0]
   let $existingRelation := $extension//src[@soId=$relation/@id]
   let $effectiveTime := datetime:format-date(xs:date(concat(substring($relation/@effectiveTime,1,4),'-',substring($relation/@effectiveTime,5,2),'-',substring($relation/@effectiveTime,7,2))),"yyyy-MM-dd")
   return
   (
   $existingRelation,
   if ($mode='import') then
      (
      update value $existingRelation/@effectiveTime with $effectiveTime,
      update value $existingRelation/@active with $relation/@active
      )
   else()
   )
   ,
   (:insert new descriptions:)
   
   (:insert new source relationships:)
   for $relation in $statedRelations[not(@id=$extension//src/@soId)][string-length(@id) gt 0][@active='1']
   let $relType := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$relation/@typeId]
   let $moduleId:= if($relation/@moduleId='636635721000154103') then $extensionModuleId else $relation/@moduleId
   let $dest :=
      if ($descriptions[@conceptId=$relation/@destinationId]) then
         $descriptions[@conceptId=$relation/@destinationId][1]/@term/string()
      else(collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$relation/@destinationId]/desc[@type='pref']/text())
   let $relationEffectiveTime :=
      if (lower-case($relation/@effectiveTime)='unpublished') then
         ''
      else(datetime:format-date(xs:date(concat(substring($relation/@effectiveTime,1,4),'-',substring($relation/@effectiveTime,5,2),'-',substring($relation/@effectiveTime,7,2))),"yyyy-MM-dd"))
   let $newRelation :=   
      <src uuid="{util:uuid()}" soId="{$relation/@id}" id="" moduleId="{$moduleId}" effectiveTime="{$relationEffectiveTime}" statusCode="draft" type="{$relType/desc[@type='pref']}">
      {
      $relation/@*[not(name()=('effectiveTime','id','moduleId'))],
      $dest
      }
      </src>
   return
      (
   $newRelation,
   if ($mode='import') then
      (
      update insert $newRelation into $extension[@soId=$relation/@sourceId]
      )
   else()
   )
   ,
   (:insert new destination relationships:)
   for $relation in $statedRelations[not(@id=$extension//dest/@soId)][string-length(@id) gt 0][@typeId='116680003'][@active='1']
   let $relType := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$relation/@typeId]
   let $moduleId:= if($relation/@moduleId='636635721000154103') then $extensionModuleId else $relation/@moduleId
   let $dest :=
      if ($descriptions[@conceptId=$relation/@destinationId]) then
         $descriptions[@conceptId=$relation/@destinationId][1]/@term/string()
      else(collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$relation/@destinationId]/desc[@type='pref']/text())
   let $relationEffectiveTime :=
      if (lower-case($relation/@effectiveTime)='unpublished') then
         ''
      else(datetime:format-date(xs:date(concat(substring($relation/@effectiveTime,1,4),'-',substring($relation/@effectiveTime,5,2),'-',substring($relation/@effectiveTime,7,2))),"yyyy-MM-dd"))
   let $newRelation :=   
      <dest uuid="{util:uuid()}" soId="{$relation/@id}" id="" moduleId="{$moduleId}" effectiveTime="{$relationEffectiveTime}" statusCode="draft" type="{$relType/desc[@type='pref']}">
      {
      $relation/@*[not(name()=('effectiveTime','id','moduleId'))],
      $dest
      }
      </dest>
   return
   (
   $newRelation,
   if ($mode='import') then
      (
      update insert $newRelation into $extension[@soId=$relation/@destinationId]
      )
   else()
   )
,
$newConcepts
,
if ($mode='import') then
(
   for $newConcept in $newConcepts
   return
   update insert $newConcept into collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))/concepts
   ,
   for $newDesc in $newDescriptions
   return
   update insert $newDesc into collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))/descriptions
)
else()
)