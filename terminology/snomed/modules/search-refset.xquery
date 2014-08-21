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

let $searchString :=util:unescape-uri(request:get-parameter('string',('')),'UTF-8')
let $refsetId :=util:unescape-uri(request:get-parameter('refsetId',('')),'UTF-8')
(:let $searchString :='kle'
let $refsetId :='12345':)
let $searchTerms := tokenize($searchString,'\s')
(:let $searchType := request:get-parameter('type',('wildcard')):)
let $searchType :='wildcard'

let $validSearch := if (matches($searchString,'^[a-z|0-9]') and string-length($searchString)>1 and string-length($searchString)<40) then
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
    							if ($searchType='fuzzy') then
    							<fuzzy occur="must">{concat($term,'~')}</fuzzy>
    							else if ($searchType!='fuzzy' and matches($term,'^[a-z|0-9]')) then
    							<wildcard occur="must">{concat($term,'*')}</wildcard>
    							else if ($searchType!='fuzzy' and matches($term,'^[A-Z]')) then
    							<term occur="must">{lower-case($term)}</term>
    							else()
    						}
    					</bool>
  					</query>

let $result :=
   if ($validSearch and not(matches($searchString,'^[0-9]+'))) then
      let $refset := collection(concat($get:strTerminologyData,'/snomed-refsets/data'))//refset[@id=$refsetId]
      return
   	$refset//member[ft:query(referencedComponent/description,$query,$options)]|$refset//member[ft:query(translation,$query,$options)]
   else if ($validSearch and matches($searchString,'^[0-9]+')) then
      let $refset := collection(concat($get:strTerminologyData,'/snomed-refsets/data'))//refset[@id=$refsetId]
      return
   	$refset//member[referencedComponent/@id=$searchString]
   else(<result current="0" count="0"/>)
let $count := count($result)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
let $concepts := for $concept in $result
					order by lower-case($concept/originalText)
					return
					$concept
return
<result current="{$current}" count="{$count}">
{
subsequence($concepts,1,$maxResults)
}
</result>