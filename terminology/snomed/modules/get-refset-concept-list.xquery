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
let $statusCode := request:get-parameter('status','')
(:let $statusCodes :=('draft','update','review'):)


let $refset       := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]

let $result :=
      $refset/member[@statusCode=$statusCode]
   
let $count := count($result)
					
let $response :=
      <result current="{$count}" count="{$count}" statusCode="{$statusCode}">
      {
      for $member in $result
      let $concept := $member/concept
      order by $concept/desc[@type='pref'][1]
      return
       <description memberStatusCode="{$member/@statusCode}" type="pref" conceptId="{$concept/@conceptId}" fullName="{$concept/desc[@type='fsn']/text()}">{$concept/desc[@type='pref']/text()}</description>
      }
      </result>

return
$response
