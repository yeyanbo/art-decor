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

(:let $refsetId := request:get-parameter('refsetId','')
let $refsetEffectiveDate :=util:unescape-uri(request:get-parameter('refsetEffectiveDate',('')),'UTF-8'):)

let $refsetId := '41000146103'
let $refsetEffectiveDate := '2012-12-03'

(:let $statusCode := request:get-parameter('statusCode',''):)
let $statusCodes :=('draft','update','review')

let $refset :=collection(concat($get:strTerminologyData,'/snomed-refsets/data'))//refset[@id=$refsetId][@effectiveDate=$refsetEffectiveDate]


let $result := $refset//member[desc/@statusCode='draft']
   
let $count := count($result)
					
let $response :=

      <result current="{$count}" count="{$count}" statusCode="{$statusCodes}">
      {
      for $member in $result
      order by $member/desc[@type='pref'][1]
      return
     <description memberStatusCode="{$member/@statusCode}" type="pref" conceptId="{$member/concept/@conceptId}" fullName="{$member/concept/desc[@type='fsn']/text()}">{$member/desc[@type='pref']/text()}</description>
      }
      </result>

return
$response
