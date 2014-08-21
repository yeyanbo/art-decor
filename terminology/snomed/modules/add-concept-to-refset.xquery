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

let $conceptId := request:get-parameter('conceptId','')
let $refsetId :=util:unescape-uri(request:get-parameter('refsetId',('')),'UTF-8')
(:let $conceptId := '302619004':)
(:let $refsetId :='2.16.840.1.113883.2.4.3.11.26.1':)
(:let $conceptId := '38102005':)

let $user         := xmldb:get-current-user()
let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$refsetId]
let $refset       := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
let $edit          := xs:boolean($project/author[@username=$user]/@edit)


let $concept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$conceptId]



let $response :=
   (:check if concept already added:)
   if ($refset/member[concept/@conceptId=$conceptId]) then
      $refset/member[concept/@conceptId=$conceptId]
   else
   (   
   (:check if user is authorized:)
   if ($edit) then
      let $newMember :=
            <member id="{util:uuid()}" statusCode="draft" effectiveTime="{datetime:format-date(current-date(),"yyyy-MM-dd")}">
               <lastStatusChange authorId="{$user}" authorName="{$project/author[@username=$user]/text()}" effectiveDate="{current-date()}"/>
               <concept>
               {
               $concept/@*,
               $concept/desc,
               $concept/ancestors,
               $concept/dest,
               <refsets>
                  {
                  for $ref in $concept/refsets/refset
                  return
                  <refset refsetId="{$ref/@refsetId}"/>
                  }
               </refsets>,
               <maps>
                  {
                  for $map in $concept/maps/map
                  return
                  <map refsetId="{$map/@refsetId}"/>
                  }
               </maps>
               }
               </concept>
            </member>
       return
       (
       update insert $newMember into $refset,
       $newMember
       )
   else(<member>NO PERMISSION</member>)
   )
return
$response