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

let $memberId := request:get-parameter('memberId','')
let $refsetId :=util:unescape-uri(request:get-parameter('refsetId',('')),'UTF-8')
let $language := request:get-parameter('language','en')
let $moduleId:= '11000146104'

(:let $memberId := '96a0d424-dafa-480e-bf91-b552923f4f0e'
let $refsetId :='2.16.840.1.113883.2.4.3.11.26.1'
let $refsetEffectiveDate :='2012-12-03'
let $language := 'nl-NL':)

let $languageCode := if (string-length($language)=2) then $language else substring($language,1,2)

let $user         := xmldb:get-current-user()
let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$refsetId]
let $refset       := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
let $member       := $refset/member[@id=$memberId]
let $edit         := xs:boolean($project/author[@username=$user]/@edit)


let $response :=
   (:check if user is authorized:)
   if ($edit) then
      let $uuid := util:uuid()
      let $newDesc :=
         <desc statusCode="draft" type="syn" id="" uuid="{$uuid}" count="" length="" effectiveTime="" moduleId="{$moduleId}" languageCode="{$languageCode}" typeId="900000000000013009" caseSignificanceId="900000000000020002"></desc>
      let $newDescription :=
            <description  uuid="{$uuid}"  id="" effectiveTime="" statusCode="draft" type="syn" count="" length="" active="0" moduleId="$moduleId" conceptId="{$member/concept/@conceptId}" languageCode="{$languageCode}" typeId="900000000000013009" caseSignificanceId="900000000000020002">
               <desc></desc>
               <languageRefset  id="{$uuid}" effectiveTime="" active="0" moduleId="{$moduleId}" languageRefsetId="31000146106" acceptabilityId="900000000000549004"/>
            </description>
       return
       (
       update insert $newDesc into $member/concept,
       update insert $newDescription into collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))/descriptions,
       $newDesc
       )
   else(<member>NO PERMISSION</member>)
return
$response