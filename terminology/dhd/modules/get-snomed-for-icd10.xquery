xquery version "1.0";
(:
	Copyright (C) 2011-2013 Art Decor Expert Group art-decor.org
	
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

let $icd10 := util:unescape-uri(request:get-parameter('code',''),'UTF-8')
(:let $icd10 := 'H32.8':)

let $maxResults := xs:integer('50')
let $result :=
   if (ends-with($icd10,'*')) then
      collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//map[starts-with(@mapTarget,substring-before($icd10,'*'))]/ancestor::concept/desc[@type='pref']
   else (collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//map[@mapTarget=$icd10]/ancestor::concept/desc[@type='pref'])

let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//thesaurus
   
let $count := count($result)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
let $concepts := for $concept in $result
					order by xs:integer($concept/@count),xs:integer($concept/@length)
					return
					$concept
					
let $response :=
      <result current="{$current}" count="{$count}">
      {
       for $res in subsequence($concepts,1,$maxResults)
       let $concept := $res/parent::concept
       let $dhdSnomed := $thesaurus//snomed[@conceptId=$concept/@conceptId]
       return
       <description id="{$dhdSnomed/parent::concept/@id}" memberStatusCode="{$dhdSnomed/parent::concept[@statusCode='active']/@statusCode}" thesaurusId="{$dhdSnomed/parent::concept[@statusCode='active']/@thesaurusId}" type="{$res/@type}" conceptId="{$concept/@conceptId}" fullName="{$concept/desc[@type='fsn']/text()}">{$res/text()}</description>
      }
      </result>
return
$response