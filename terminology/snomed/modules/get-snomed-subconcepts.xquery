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

let $conceptId := request:get-parameter('id','138875005')
let $refsetId :=util:unescape-uri(request:get-parameter('refsetId',('')),'UTF-8')
(:let $conceptId := '138875005':)
(:let $conceptId := '38102005':)
let $concept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$conceptId]

let $response :=
   if (string-length($refsetId) gt 0) then
      let $refset := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
      return
      for $dest in $concept/dest[@active]
      let $subconcept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$dest/@sourceId]
      let $refsetSubConcept :=$refset//concept[@conceptId=$subconcept/@conceptId]
      order by $subconcept/desc[@type='pref']
      return
      <concept memberStatusCode="{$refsetSubConcept/parent::member/@statusCode}">
      {
      $subconcept/@*,
      $subconcept/desc,
      $subconcept/dest
(:      for $dest in $subconcept/dest
      return
      <dest memberStatusCode="{$refset//concept[@conceptId=$dest/@sourceId]/parent::member/@statusCode}">
      {$dest/@*,$dest/text()}
      </dest>:)
      }
      </concept>
   else(
      for $dest in $concept/dest[@active]
      let $subconcept := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$dest/@sourceId]
      order by $subconcept/desc[@type='pref']
      return
      $subconcept
   )
return
<subConcepts>
{
$response
}
</subConcepts>