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


let $statusCode := request:get-parameter('status','')
(:let $statusCode :='draft':)


let $result :=
      collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept[@statusCode=$statusCode]
   
let $count := count($result)
					
let $response :=
      <result current="{$count}" count="{$count}" statusCode="{$statusCode}">
      {
      for $concept in $result
      order by $concept/desc[@type='fsn'][1]
      return
       <description conceptStatusCode="{$concept/@statusCode}" type="fsn" conceptUuid="{$concept/@uuid}" conceptId="{$concept/@conceptId}" fullName="{$concept/desc[@type='fsn']/text()}">{$concept/desc[@type='pref']/text()}</description>
      }
      </result>

return
$response
