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
	
	
	Creates list of refsets for use by search filter.
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";

let $refsets := distinct-values(collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//refset/@refsetId)
let $maps := distinct-values(collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//map/@refsetId)
let $concepts:= collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept
return
<refsets>
{
for $set in $refsets
return
<refset id="{$set}">{$concepts[@conceptId=$set]/desc[@type='pref']/text()}</refset>
,
for $set in $maps
return
<refset id="{$set}">{$concepts[@conceptId=$set]/desc[@type='pref']/text()}</refset>

}
</refsets>