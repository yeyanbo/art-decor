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

let $thesaurusId := request:get-parameter('thesaurusId','')
(:let $thesaurusId := '40230':)
(: get user for permission check:)
let $user := xmldb:get-current-user()
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $project :=collection(concat($get:strTerminologyData,'/dhd-data/meta'))/project
let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $concept := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@thesaurusId=$thesaurusId]
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
         let $newThesaurusId := dhd:getNextThesaurusId()
         let $newConcept :=
            <concept  no="{dhd:getNextConceptNo()}" thesaurusId="{$newThesaurusId}" statusCode="draft" effectiveDate="" idLink="" expirationDate="" editDate="{$currentDate}" editCode="new">
               <snomed conceptId="" validationDate="" validated="">
                  <desc type="fsn"></desc>
               </snomed>
               {
               for $desc at $pos in $concept/desc
               return
               <desc no="{dhd:getNextDescNo()}" interfaceId="{dhd:getNextInterfaceId()}" type="{$desc/@type}" count="{$desc/@count}" length="{$desc/@length}" effectiveDate="" expirationDate="" statusCode="draft" editDate="{$currentDate}" editCode="new">{$desc/text()}</desc>
               ,
               for $icd10 in $concept/icd10
               return
               <icd10 no="{dhd:getNextIcd10No()}" code="{$icd10/@code}" codeStripped="{$icd10/@codeStripped}" priority="{$icd10/@priority}" effectiveDate="" expirationDate="" editDate="{$currentDate}" editCode="new" validationDate="" validated="false" statusCode="draft"/>
               ,
               for $dbc in $concept/dbc
               return
               <dbc no="{dhd:getNextDbcNo()}" code="{$dbc/@code}" effectiveDate="" expirationDate="" editDate="{$currentDate}" editCode="new" validationDate="" validated="false" statusCode="draft" agbCode="{$dbc/@agbCode}"/>
               ,
               for $domain in $concept/specialism
               return
               <specialism no="{dhd:getNextDomainNo()}" specialismCode="{$domain/@specialismCode}" specialism="{$domain/@specialism}" specialismShort="{$domain/@specialismShort}" agbCode="{$domain/@agbCode}" vektis="{$domain/@vektis}" subspecialism="{$domain/@subspecialism}" subspecialismShort="{$domain/@subspecialismShort}" effectiveDate="" expirationDate="" editDate="{$currentDate}" editCode="new" statusCode="draft"/>
               }
            </concept>
         return
         (
         update insert $newConcept into doc(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName))/thesaurus,
         update value $concept/@idLink with $newThesaurusId,
         $newConcept
         )

   else(<concept>NO PERMISSION</concept>)
 
return
<concept>
{$response/@*}
<replaces thesaurusId="{$concept/@thesaurusId}">{$concept/desc[@type='pref']/text()}</replaces>
{$response/*}
</concept>