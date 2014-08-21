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

let $memberId :=util:unescape-uri(request:get-parameter('id',('')),'UTF-8')
let $refsetId :=util:unescape-uri(request:get-parameter('refsetId',('')),'UTF-8')



let $user         := xmldb:get-current-user()
let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$refsetId]
let $refset       := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
let $edit         := xs:boolean($project/author[@username=$user]/@edit)

let $response :=
   (:check if user is authorized and concept is 'draft':)
   if ($edit) then
      let $member := $refset/member[@id=$memberId][@statusCode='draft']
       return
       (
       update delete $member,
       <response>OK</response>
       )
   else(<member>NO PERMISSION</member>)
return
$response