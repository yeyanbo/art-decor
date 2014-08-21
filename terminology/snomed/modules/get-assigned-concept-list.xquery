xquery version "1.0";
(:
	Copyright (C) 2011-2014 Art Decor Expert Group art-decor.org
	
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

let $refsetId :=request:get-parameter('refsetId','')
let $user := request:get-parameter('user','')
(:let $user := 'theo':)

let $refset       := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]


let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $project :=collection(concat($get:strTerminologyData,'/dhd-data/meta'))/project
let $issues :=collection(concat($get:strTerminologyData,'/dhd-data/meta'))//issue

let $userId := $project/author[@username=$user]/@id
(:get all issues, return linked concepts:)
let $result :=
      for $issue in $issues
      let $lastTracking    := $issue/tracking[@effectiveDate=max($issue/tracking/xs:dateTime(@effectiveDate))][last()]
      let $lastAssignment  := $issue/assignment[@effectiveDate=max($issue/assignment/xs:dateTime(@effectiveDate))][last()]
      let $lastEvent       := $issue/(tracking|assignment)[@effectiveDate=max($issue/(tracking|assignment)/xs:dateTime(@effectiveDate))][last()]
      let $lastIssueStatus := $lastTracking/@statusCode
      return
      if ($lastIssueStatus='open' and $lastAssignment/@to=$userId) then
         collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@thesaurusId=$issue/object/@id]
      else()
   
let $count := count($result)
					
let $response :=

      <result current="{$count}" count="{$count}" statusCode="">
      {
      for $concept in $result
      order by $concept/desc[@type='pref']
      return
       <description id="{$concept/@no}" memberStatusCode="{$concept/@statusCode}" thesaurusId="{$concept/@thesaurusId}" type="pref" conceptId="{$concept/snomed/@conceptId}" fullName="{$concept/snomed/desc[@type='fsn']/text()}">{$concept/desc[@type='pref']/text()}</description>
      }
      </result>

return
$response
