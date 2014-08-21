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
let $dbcCode :=request:get-parameter('dbcCode','')
let $agbCode :=request:get-parameter('agbCode','')
(:let $conceptId :='304527002':)

(:check mode, add Snomed or DBC:)
let $addSnomed := string-length($conceptId) gt 0
let $addDBC := string-length($dbcCode) gt 0   and string-length($agbCode) gt 0 and  string-length($conceptId) = 0
let $addEmpty := string-length($dbcCode) = 0   and string-length($agbCode) = 0 and  string-length($conceptId) = 0


(: get user for permission check:)
let $user := xmldb:get-current-user()
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $project :=collection(concat($get:strTerminologyData,'/dhd-data/meta'))/project
let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $concept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$conceptId]
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
      (:check if new concept is based on Snomed on DBC or is empty:)   
      if ($addSnomed) then
         (:check if Snomed concept already in thesaurus, if so just return existing thesaurus concept:)
         if ($thesaurus/concept[snomed/@conceptId=$conceptId]) then
            $thesaurus/concept[snomed/@conceptId=$conceptId]
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
         $newConcept
         )
         )
       else if ($addDBC) then
         let $newConcept :=
            <concept  no="{dhd:getNextConceptNo()}" thesaurusId="{dhd:getNextThesaurusId()}" statusCode="draft" effectiveDate="" idLink="" expirationDate="" editDate="{$currentDate}" editCode="new">
               <snomed conceptId="" validationDate="" validated="">
                  <desc type="fsn"></desc>
               </snomed>
               <desc no="{dhd:getNextDescNo()}" interfaceId="{dhd:getNextInterfaceId()}" type="pref" count="0" length="0" effectiveDate="" expirationDate="" statusCode="draft" editDate="{$currentDate}" editCode="new"></desc>
               <dbc no="{dhd:getNextDbcNo()}" code="{$dbcCode}" effectiveDate="" expirationDate="" editDate="{$currentDate}" editCode="new" validationDate="" validated="false" statusCode="draft" agbCode="{$agbCode}"/>
            </concept>
         return
         (
         update insert $newConcept into doc(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName))/thesaurus,
         $newConcept
         )
       else if ($addEmpty) then 
         let $newConcept :=
            <concept  no="{dhd:getNextConceptNo()}" thesaurusId="{dhd:getNextThesaurusId()}" statusCode="draft" effectiveDate="" idLink="" expirationDate="" editDate="{$currentDate}" editCode="new">
               <snomed conceptId="" validationDate="" validated="">
                  <desc type="fsn"></desc>
               </snomed>
               <desc no="{dhd:getNextDescNo()}" interfaceId="{dhd:getNextInterfaceId()}" type="pref" count="0" length="0" effectiveDate="" expirationDate="" statusCode="draft" editDate="{$currentDate}" editCode="new"></desc>
            </concept>
         return
         (
         update insert $newConcept into doc(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName))/thesaurus,
         $newConcept
         )
      else(<concept>UNSUPPORTED MODE</concept>)
   else(<concept>NO PERMISSION</concept>)
 
return
$response