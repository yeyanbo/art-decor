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

for $concept at $count in $thesaurus/concept[not(desc[@type='pref'])]
let $newDesc :=
   <desc no="{$currentMaxNo + $count}" interfaceId="{$currentMaxInterfaceId + $count}" type="pref"  count="{count(tokenize($concept/ref/text(),'\s'))}" length="{string-length($concept/ref/text())}" effectiveDate="{$concept/@effectiveDate}" expirationDate="{$concept/@expirationDate}" statusCode="{$concept/@statusCode}" editDate="" editCode="">{$concept/ref/text()}</desc>
return
update insert $newDesc into $concept
