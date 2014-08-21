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
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace dhd = "http://art-decor.org/ns/terminology/dhd" at "../api/api-dhd.xqm";

let $conceptSelection := request:get-data()/concepts

(: get user for permission check:)
let $user := xmldb:get-current-user()
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $project :=collection(concat($get:strTerminologyData,'/dhd-data/meta'))/project
let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $currentDate :=datetime:format-date(current-date(),"yyyy-MM-dd")

(:check for current thesaurus file:)
let $thesaurusFileName :=concat('thesaurus-',datetime:format-date(current-date(),"yyyy"),'.xml')
let $checkFile :=
   if (not(doc-available(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName)))) then
      (
      xmldb:store(concat($get:strTerminologyData,'/dhd-data/thesaurus/'), $thesaurusFileName, <thesaurus/>),
      sm:chown(xs:anyURI(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName)),'admin'),
      sm:chgrp(xs:anyURI(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName)),'terminology'),
      sm:chmod(xs:anyURI(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName)))
      )
   else()

let $response :=
   (:check if user is authorized:)
   if ($edit) then
      (:loop through selected concepts and add:) 
        for $selectedConcept in $conceptSelection//concept[@selected]
        let $concept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$selectedConcept/@conceptId]
        return
         (:check if Snomed concept already in thesaurus, if so just return existing thesaurus concept:)
         if ($thesaurus/concept[snomed/@conceptId=$selectedConcept/@conceptId]) then
            $thesaurus/concept[snomed/@conceptId=$selectedConcept/@conceptId]
         else
         ( 
         let $icd10Maps :=$concept/maps/map[@refsetId='447562003']
         let $distinctCodes :=
               for $target in distinct-values($icd10Maps/@mapTarget)
               let $priority := min($icd10Maps[@mapTarget=$target]/xs:integer(@priority))
               return
               <code priority="{$priority}">{$target}</code>
         let $newConcept :=
            <concept  no="{dhd:getNextConceptNo()}" thesaurusId="{dhd:getNextThesaurusId()}" statusCode="draft" effectiveDate="" idLink="" expirationDate="" editDate="{$currentDate}" editCode="new">
               <snomed conceptId="{$concept/@conceptId}" validationDate="" validated="">
                  <desc type="fsn">{$concept/desc[@type='fsn']/text()}</desc>
               </snomed>
               <desc no="{dhd:getNextDescNo()}" interfaceId="{dhd:getNextInterfaceId()}" type="pref" count="0" length="0" effectiveDate="" expirationDate="" statusCode="draft" editDate="{$currentDate}" editCode="new"></desc>
               {
               for $code at $pos in $distinctCodes
               let $icd10 := collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[@code=$code]
               order by $code/@priority
               return
               <icd10 no="{dhd:getNextIcd10No()}" code="{$icd10/@code}" codeStripped="{$icd10/@codeStripped}" priority="{$pos}" effectiveDate="" expirationDate="" editDate="{$currentDate}" editCode="new" validationDate="" validated="false" statusCode="draft"/>
               }
            </concept>
         return
         (
         update insert $newConcept into doc(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName))/thesaurus,
         <concept>OK</concept>
         )
         )
   else(<concept>NO PERMISSION</concept>)
 
return
<concept>{$response}</concept>