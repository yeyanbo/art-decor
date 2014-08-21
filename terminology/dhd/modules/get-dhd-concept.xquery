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

let $thesaurusId := request:get-parameter('thesaurusId','')
(:let $thesaurusId := '40194':)

let $thesaurusConcept := 
         if ($thesaurusId castable as xs:integer) then
            collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@thesaurusId=$thesaurusId]
         else()

      let $historyCount := count(collection(concat($get:strTerminologyData,'/dhd-data/history'))//concept[@thesaurusId=$thesaurusId])
      let $replaces := if (string-length($thesaurusId) gt 0 ) then  collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@idLink=$thesaurusId] else()
      let $replacedBy := if (string-length($thesaurusConcept/@idLink) gt 0 ) then collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@thesaurusId=$thesaurusConcept/@idLink] else()

let $log :=collection(concat($get:strTerminologyData,'/dhd-data/log'))/log
let $response :=
   if ($thesaurusConcept) then

       <concept history="{$historyCount}">
       {$thesaurusConcept/@*,
       <log>
       {
         for $entry in $log//statusChange[@thesaurusId=$thesaurusId]
        order by $entry/xs:dateTime(@effectiveTime) descending
        return
        $entry
        }
       </log>
       ,
       if ($replaces) then
         <replaces thesaurusId="{$replaces/@thesaurusId}">{$replaces/desc[@type='pref']/text()}</replaces>
       else(),
       if ($replacedBy) then 
         <replacedBy thesaurusId="{$thesaurusConcept/@idLink}">{$replacedBy/desc[@type='pref']/text()}</replacedBy>
       else()
       ,
       $thesaurusConcept/snomed,
       $thesaurusConcept/desc[@type='pref'],
       $thesaurusConcept/desc[@type='syn'],
       for $icd10 in $thesaurusConcept/icd10
       let $icd10Ref := collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[@code=$icd10/@code]
       let $term := $icd10Ref/desc/text()
       order by $icd10/@priority
       return
       <icd10 term="{$term}" maxEffectiveDate="{$icd10Ref/@effectiveDate}" minExpirationDate="{$icd10Ref/@expirationDate}">
            {
            $icd10/@*
            }
       </icd10>
       ,
       for $dbc in $thesaurusConcept/dbc
       let $dbcbcRef := collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[@code=$dbc/@code][@agbCode=$dbc/@agbCode]
       let $term :=$dbcbcRef/desc/text()
       let $specialism :=collection(concat($get:strTerminologyData,'/dhd-data/reference'))//specialism[@agbCode=$dbc/@agbCode][1]/desc/text()
       order by $dbc/@agbCode,$term
       return
       <dbc desc="{$term}" specialism="{$specialism}" maxEffectiveDate="{$dbcbcRef/@effectiveDate}" minExpirationDate="{$dbcbcRef/@expirationDate}">
            {
            $dbc/@*
            }
       </dbc>
       }
    </concept>
 else()



return
if ($response) then
   let $effectiveDates := ($response/icd10/xs:date(@maxEffectiveDate[string-length() gt 0]),$response/icd10/xs:date(@maxEffectiveDate[string-length() gt 0]))
   let $expirationDates := ($response/dbc/xs:date(@minExpirationDate[string-length() gt 0]),$response/dbc/xs:date(@minExpirationDate[string-length() gt 0]))
   return
   <concept maxEffectiveDate="{max($effectiveDates)}" minExpirationDate="{min($expirationDates)}">
      {
      $response/@*,
      $response/*
      }
   </concept>
else(<concept/>)