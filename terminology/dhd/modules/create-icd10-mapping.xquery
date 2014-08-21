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


let $thesaurusId :=util:unescape-uri(request:get-parameter('thesaurusId',('')),'UTF-8')
let $code :=util:unescape-uri(request:get-parameter('code',('')),'UTF-8')
let $preceding :=util:unescape-uri(request:get-parameter('preceding',('')),'UTF-8')

(: get user for permission check:)
let $user := xmldb:get-current-user()
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $concept :=$thesaurus/concept[@thesaurusId=$thesaurusId]
let $project :=collection(concat($get:strTerminologyData,'/dhd-data/meta'))/project
let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $currentDate :=datetime:format-date(current-date(),"yyyy-MM-dd")

let $response :=
   (:check if user is authorized:)
   if ($edit) then
      let $precedingCode := $concept/icd10[@code=$preceding]
      let $priority :=
         if (string-length($preceding) gt 0) then
            $precedingCode/xs:integer(@priority)+1
         else(1)
      let $newCode :=
        <icd10 no="{dhd:getNextIcd10No()}" code="{$code}" codeStripped="{replace($code,'\.|/','')}" priority="{$priority}" effectiveDate="" expirationDate="" editDate="{$currentDate}" editCode="new" validationDate="" validated="false" statusCode="draft"/>
       return
       (
       if ($precedingCode) then
         for $followingCode in $concept/icd10[@priority gt $precedingCode/@priority]
         let $newPriority := $followingCode/xs:integer(@priority)+1
         return
         update value $followingCode/@priority with $newPriority
       else if (not($precedingCode) and $concept/icd10) then 
         for $existingCode in $concept/icd10
         let $newPriority := $existingCode/xs:integer(@priority)+1
         return
         update value $existingCode/@priority with $newPriority
       else(),
       update insert $newCode into $thesaurus/concept[@thesaurusId=$thesaurusId],
       update value $thesaurus/concept[@thesaurusId=$thesaurusId]/@editDate with  datetime:format-date(current-date(),"yyyy-MM-dd"),
       $newCode
       )
   else(<concept>NO PERMISSION</concept>)
return
$response