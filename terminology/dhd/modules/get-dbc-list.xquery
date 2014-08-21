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


let $specialism :=util:unescape-uri(request:get-parameter('specialism',''),'UTF-8')
(:let $specialism :='0326':)
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//thesaurus
let $maxResults := xs:integer('50')

let $result :=
   for $dbc in collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[@statusCode='active'][@agbCode=$specialism]
   let $concept := $thesaurus//dbc[@code=$dbc/@code][@agbCode=$dbc/@agbCode]
   where not($concept)
   return
   $dbc

let $count := count($result)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
let $dbcList := for $dbc in $result
					order by $dbc/@agbCode,$dbc/@code
					return
					 <dbc code="{$dbc/@code}" agbCode="{$dbc/@agbCode}" effectiveDate="{$dbc/@effectiveDate}" expirationDate="{$dbc/@expirationDate}" statusCode="{$dbc/@statusCode}" concepts="0">
                    <desc>{$dbc/desc/text()}</desc>
                </dbc>
return
<result current="{$current}" count="{$count}">
{
subsequence($dbcList,1,$maxResults)
}
</result>
