xquery version "1.0";
(:
	Copyright (C) 2011-2014 Art-Decor Expert Group
	
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

let $conceptSelection := request:get-data()/concepts

let $user         := xmldb:get-current-user()
let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$conceptSelection/@refsetId]
let $refset       := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$conceptSelection/@refsetId]
let $edit          := xs:boolean($project/author[@username=$user]/@edit)



let $response :=
   (:check if user is authorized:)
   if ($edit) then
      let $insert :=
      <insert>
         {
         for $selectedConcept in $conceptSelection//concept[@selected]
            let $concept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$selectedConcept/@conceptId]
            return
            (:check if concept already added:)
            if (not($refset/member[concept/@conceptId=$selectedConcept/@conceptId])) then
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
            else
            ()
           }
        </insert>
        return
        (
        update insert $insert/* into $refset
        ,
         <member>OK</member>
         )
   else(<member>NO PERMISSION</member>)
return
$response