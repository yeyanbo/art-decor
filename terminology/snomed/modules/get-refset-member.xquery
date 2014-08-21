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

let $conceptId := request:get-parameter('conceptId','')
let $refsetId := request:get-parameter('refsetId','')
(:
let $conceptId := '312999006'
let $refsetId := '41000146103':)


let $member := 
      if (count(collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]//concept[@conceptId=$conceptId]/parent::member) gt 1) then
         let $members :=collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]//concept[@conceptId=$conceptId]/parent::member
         let $maxDate := max($members/xs:date(@effectiveTime))
         return
         $members[@effectiveTime=$maxDate]
      else(collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]//concept[@conceptId=$conceptId]/parent::member)
      
return
if ($member) then $member else <member/>