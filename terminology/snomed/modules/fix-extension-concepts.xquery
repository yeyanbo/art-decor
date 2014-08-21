xquery version "3.0";
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

let $extensionModuleId:= '11000146104'
return
<fix>
{
for $concept in collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept
return
(
   for $desc in $concept/desc[not(@conceptId=parent::concept/@conceptId)]
   return
   (
   $desc,
   update value $desc/@conceptId with $desc/parent::concept/@conceptId
   )
   ,
   for $src in $concept/src[@sourceId=parent::concept/@soId]
   return
   (
   $src,
   update value $src/@sourceId with $src/parent::concept/@conceptId 
   )
   ,
   for $destination in $concept/src[@destinationId=collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept/@soId]
   let $destinationId := collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept[@soId=$destination/@destinationId]/@conceptId
   return
   (
   $destination,
   update value $destination/@destinationId with $destinationId
   )
   ,
   for $date in $concept//@effectiveTime[string-length()=8]
   let $newDate := xs:date(concat(substring($date,1,4),'-',substring($date,5,2),'-',substring($date,7,2)))
   return
   (
   $date/string(),
   update value $date with $newDate
   )
   ,
   for $moduleId in $concept//@moduleId[.='636635721000154103']
   return
   (
   $moduleId/string(),
   update value $moduleId with $extensionModuleId
   )
   )
}
</fix>