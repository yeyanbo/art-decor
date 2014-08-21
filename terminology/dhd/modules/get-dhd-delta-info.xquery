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


let $deltaConcepts := collection(concat($get:strTerminologyData,'/snomed-data/Delta/Terminology'))//concept
let $refset := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus

let $retiredConcepts :=
   for $concept in $deltaConcepts[@active='0']
   
   let $associatedConcepts := collection(concat($get:strTerminologyData,'/snomed-data/Delta/Refset/Content'))//assocationReference[@referencedComponentId=$concept/@id]
   let $dhdConcepts :=$refset//snomed[@conceptId=$concept/@id]/parent::concept
   return
   for $dhd in $dhdConcepts[@statusCode='active']
   
   return
      <concept thesaurusId="{$dhd/@thesaurusId}" referenceTerm="{$dhd/desc[@type='pref']/text()}" conceptId="{$concept/@id}" fsn="{$dhd/snomed/desc/text()}">
         {
         for $association in $associatedConcepts
         let $type:=collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$association/@refsetId]
         let $target:=collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$association/@targetComponentId]
         return
         <associationReference refset="{$type/desc[@type='pref']}" targetComponent="{$target/desc[@type='fsn']}" targetComponentId="{$association/@targetComponentId}">
         </associationReference>
         }
         
      </concept>
return
<retired>
{
for $concept in $retiredConcepts
order by lower-case($concept/@referenceTerm)
return
$concept
}
</retired>