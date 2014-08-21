xquery version "1.0";
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
	
	http://exist-db.org/exist/apps/doc/update_ext.xml
	
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace dhd = "http://art-decor.org/ns/terminology/dhd" at "../api/api-dhd.xqm";

let $conceptId := request:get-parameter('conceptId','')
let $thesaurusId :=request:get-parameter('thesaurusId','')

(:let $conceptId :='304527002':)
(: get user for permission check:)
let $user := xmldb:get-current-user()
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $project :=collection(concat($get:strTerminologyData,'/dhd-data/meta'))/project
let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $concept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$conceptId]
let $thesaurusConcept := $thesaurus/concept[@thesaurusId=$thesaurusId]
let $currentDate :=datetime:format-date(current-date(),"yyyy-MM-dd")
let $response :=
   (:check if user is authorized:)
   if ($edit) then
      let $icd10Maps :=$concept/maps/map[@refsetId='447562003']
      let $currentMaxPriority := 
         if ($thesaurusConcept/icd10) then
            max($thesaurusConcept/icd10/xs:integer(@priority))
         else (0)
      let $distinctCodes :=
               for $target in distinct-values($icd10Maps/@mapTarget)
               let $priority := min($icd10Maps[@mapTarget=$target]/xs:integer(@priority))
               return
               <code priority="{$priority}">{$target}</code>
      let $newIcd10 :=
               for $code at $pos in $distinctCodes[not(.=$thesaurusConcept/icd10/@code)]
               let $icd10 := collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[@code=$code]
               order by $code/@priority
               return
               <icd10 no="{dhd:getNextIcd10No()}" code="{$icd10/@code}" codeStripped="{$icd10/@codeStripped}" priority="{$pos + $currentMaxPriority}" effectiveDate="" expirationDate="" editDate="{$currentDate}" editCode="new" validationDate="" validated="false" statusCode="draft"/>
       let $newSnomed :=
               <snomed conceptId="{$concept/@conceptId}" validationDate="" validated="">
                  <desc type="fsn">{$concept/desc[@type='fsn']/text()}</desc>
               </snomed>
       return
       (
       update replace $thesaurusConcept/snomed with $newSnomed,
       if ($newIcd10) then
         update insert $newIcd10 into $thesaurusConcept
       else()
       ,
       $newSnomed
       )
   else(<concept>NO PERMISSION</concept>)

return
$response