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

let $conceptId := request:get-parameter('id','')
let $refsetId :=util:unescape-uri(request:get-parameter('refsetId',('')),'UTF-8')
(:let $conceptId := '91357005'
let $refsetId :='2.16.840.1.113883.2.4.3.11.26.1':)
(:let $refsetEffectiveDate :='2012-12-03':)
(:let $conceptId := '38102005':)

let $response :=
   if (string-length($conceptId) gt 0) then
      let $concept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$conceptId]|collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept[@conceptId=$conceptId]
      return
      if (string-length($refsetId) gt 0) then
         let $refset := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
         let $refsetConcept := $refset//concept[@conceptId=$concept/@conceptId]
         return
         <concept memberStatusCode="{$refsetConcept/parent::member/@statusCode}">
         {
         $concept/@*,
         $concept/*[not(name()=('dest','maps'))],
         <simpleMaps>
            {
            for $map in $concept/maps/map[not(@mapGroup)]
            return
            $map
            }
         </simpleMaps>
         ,
         <complexMaps>
            {
            for $map in $concept/maps/map[@mapGroup]
            group by $mapping := $map/@refsetId 
            return
            <map refsetId="{$mapping}" refset="{$map[1]/@refset}">
               {
               for $group in $map
               group by $grp := $group/@mapGroup
               order by $grp
               return
               <group>
                  {
                  for $item in $group
                  order by $item/@mapPriority
                  return
                  $item
                  }
               </group>
               }
            </map>
            }
         </complexMaps>
         ,
         for $dest in $concept/dest
         let $refsetSubConcept :=$refset//concept[@conceptId=$dest/@sourceId]
         return
         <dest memberStatusCode="{$refsetSubConcept/parent::member/@statusCode}">
         {$dest/@*,$dest/text()}
         </dest>
         }
         </concept>
      else
      (
         <concept>
         {
         $concept[1]/@*,
         $concept[1]/*[not(name()='maps')],
         <simpleMaps>
            {
            for $map in $concept[1]/maps/map[not(@mapGroup)]
            return
            $map
            }
         </simpleMaps>
         ,
         <complexMaps>
            {
            for $map in $concept[1]/maps/map[@mapGroup]
            group by $mapping := $map/@refsetId 
            return
            <map refsetId="{$mapping}" refset="{$map[1]/@refset}">
               {
               for $group in $map
               group by $grp := $group/@mapGroup
               order by $grp
               return
               <group>
                  {
                  for $item in $group
                  order by $item/@mapPriority
                  return
                  $item
                  }
               </group>
               }
            </map>
            }
         </complexMaps>
         }</concept>
      )
   else ('MISSING REQUIRED PARAMETER')
return
<concepts>{$response}</concepts>