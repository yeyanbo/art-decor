xquery version "1.0";
(:
	Copyright (C) 2012 Art Decor Expert group, www.art-decor.org
	
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

let $searchString :=util:unescape-uri(request:get-parameter('string',('sys bloo')),'UTF-8')
(:let $searchString :='11868-7':)
let $searchTerms := tokenize($searchString,'\s')

let $validSearch := if (matches($searchString,'^[a-z|0-9]') and string-length($searchString)>3 and string-length($searchString)<40) then
										xs:boolean('true')
										else if (matches($searchString,'^[A-Z]') and string-length($searchString)>1 and string-length($searchString)<40) then
										xs:boolean('true')
										else(xs:boolean('false'))
(:let $searchTerms := tokenize('ast','\s'):)
let $maxResults := xs:integer('50')
let $options := 
							<options>
								<filter-rewrite>yes</filter-rewrite>
							</options>
let $query := <query>
    						<bool>
    						{
    							for $term in $searchTerms
    							return
    							if (matches($term,'^[a-z|0-9]')) then
    							<wildcard occur="must">{concat($term,'*')}</wildcard>
    							else if (matches($term,'^[A-Z]')) then
    							<term occur="must">{lower-case($term)}</term>
    							else()
    						}
    					</bool>
  					</query>

let $result :=
   if ($validSearch and not(matches($searchString,'^[0-9]+-[0-9]'))) then 
		collection(concat($get:strTerminologyData,'/loinc-data/concepts'))//concept[ft:query(*,$query,$options)]
	else if ($validSearch and matches($searchString,'^[0-9]+-[0-9]')) then
	  collection(concat($get:strTerminologyData,'/loinc-data/concepts'))//concept[@loinc_num=$searchString]
	else(<result current="0" count="0"/>)
let $count := count($result)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
let $concepts := for $concept in $result
					order by xs:integer($concept/longName/@count),xs:integer($concept/longName/@length),$concept/longName
					return
					$concept
return
<result current="{$current}" count="{$count}">
{
subsequence($concepts,1,$maxResults)
}
</result>