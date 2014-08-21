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


let $statusCode := request:get-parameter('status','')
(:let $statusCodes :=('draft','update','review'):)



let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//thesaurus

let $result :=
      collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@statusCode=$statusCode]
   
let $count := count($result)
					
let $response :=

      <result current="{$count}" count="{$count}" statusCode="{$statusCode}">
      {
      for $concept in $result
      order by $concept/desc[@type='pref'][1]
      return
       <description id="{$concept/@id}" memberStatusCode="{$concept/@statusCode}" thesaurusId="{$concept/@thesaurusId}" type="pref" conceptId="{$concept/snomed/@conceptId}" fullName="{$concept/snomed/desc[@type='fsn']/text()}">{$concept/desc[@type='pref']/text()}</description>
      }
      </result>

return
$response
