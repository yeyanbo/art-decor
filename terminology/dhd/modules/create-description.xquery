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

(: get user for permission check:)
let $user := xmldb:get-current-user()
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $project :=collection(concat($get:strTerminologyData,'/dhd-data/meta'))/project
let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $currentDate :=datetime:format-date(current-date(),"yyyy-MM-dd")

let $response :=
   (:check if user is authorized:)
   if ($edit) then
      let $newDesc :=
         <desc no="{dhd:getNextDescNo()}" interfaceId="{dhd:getNextInterfaceId()}" type="syn" count="0" length="0" effectiveDate="" expirationDate="" statusCode="draft" editDate="{$currentDate}" editCode="new"></desc>
       return
       (
       update insert $newDesc into $thesaurus/concept[@thesaurusId=$thesaurusId],
       $newDesc
       )
   else(<concept>NO PERMISSION</concept>)
return
$response