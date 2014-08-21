xquery version "1.0";
(:
	Copyright (C) 2013
	
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
let $statusCodes :=tokenize(util:unescape-uri(request:get-parameter('statusCodes',''),'UTF-8'),'\s')
let $specialism :=util:unescape-uri(request:get-parameter('specialism',''),'UTF-8')
(:let $searchString :=''
let $specialism :='0307'
let $statusCodes :=tokenize('active draft','\s'):)

let $searchTerms := tokenize($searchString,'\s')
let $validSearch := if (string-length($searchString)<40 and (string-length($searchString) gt 1 or string-length($specialism) gt 0)) then xs:boolean('true') else(xs:boolean('false'))

let $maxResults := xs:integer('750')
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

let $result := if ($validSearch) then
                  if (matches($searchString,'^[A-Z|0-9]?[0-9]*$')) then
   						if (string-length($statusCodes[1]) gt 0 and string-length($specialism) = 0) then
   							collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[starts-with(@code,$searchString)][@statusCode=$statusCodes]
   					   else if (string-length($statusCodes[1]) = 0 and string-length($specialism) gt 0) then
   					      collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[starts-with(@code,$searchString)][@agbCode=$specialism]
   					   else if (string-length($statusCodes[1]) gt 0 and string-length($specialism) gt 0) then
   					    collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[starts-with(@code,$searchString)][@statusCode=$statusCodes][@agbCode=$specialism]
   						else(collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[starts-with(@code,$searchString)])
						else(
   						if (string-length($statusCodes[1]) gt 0 and string-length($specialism) = 0) then
   								collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[ft:query(desc,$query,$options)][@statusCode=$statusCodes]
   					   else if (string-length($statusCodes[1]) = 0 and string-length($specialism) gt 0) then
   					    collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[ft:query(desc,$query,$options)][@agbCode=$specialism]
   					   else if (string-length($statusCodes[1]) gt 0 and string-length($specialism) gt 0) then
   					    collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[ft:query(desc,$query,$options)][@statusCode=$statusCodes][@agbCode=$specialism]
   						else(collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[ft:query(desc,$query,$options)])
						)
					else(<result current="0" count="0"/>)
let $count := count($result)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
let $dbcList := for $dbc in $result
               let $thesaurusConcepts := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//dbc[@code=$dbc/@code][@agbCode=$dbc/@agbCode]/parent::concept
					order by $dbc/@agbCode,$dbc/@code
					return
					 <dbc code="{$dbc/@code}" agbCode="{$dbc/@agbCode}" effectiveDate="{$dbc/@effectiveDate}" expirationDate="{$dbc/@expirationDate}" statusCode="{$dbc/@statusCode}" concepts="{count($thesaurusConcepts)}">
                    <desc>{$dbc/desc/text()}</desc>
                </dbc>
return
<result current="{$current}" count="{$count}">
{
subsequence($dbcList,1,$maxResults)
}
</result>