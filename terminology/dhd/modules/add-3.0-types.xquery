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



let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus

let $currentDate :=datetime:format-date(current-date(),"yyyy-MM-dd")
let $currentMaxNo :=max($thesaurus//desc/xs:integer(@no))
let $currentMaxInterfaceId := max($thesaurus//desc/xs:integer(@interfaceId))

for $concept in $thesaurus/concept
return
   (
   if (not($concept/@complication)) then
   update insert attribute complication {'false'} into $concept
   else()
   ,
   if (not($concept/@implant)) then
   update insert attribute implant {'false'} into $concept
   else()
   ,
   if (not($concept/@laterality)) then
   update insert attribute laterality {'false'} into $concept
   else()
   ,
   if (not($concept/@type)) then
   update insert attribute type {'Diagnose'} into $concept
   else()
   ,
   if (not($concept/@severity)) then
   update insert attribute severity {'false'} into $concept
   else()
   ,
   for $desc in $concept/desc
   return
      if (not($desc/@languageCode)) then
      update insert attribute languageCode {'nl-NL'} into $desc
      else()
   )
