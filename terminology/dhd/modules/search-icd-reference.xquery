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
(:let $searchString :='as':)
let $searchTerms := tokenize($searchString,'\s')
let $validSearch := if (matches($searchString,'^[a-z|0-9]') and string-length($searchString)>2 and string-length($searchString)<40) then
										xs:boolean('true')
										else if (matches($searchString,'^[A-Z]') and string-length($searchString)>2 and string-length($searchString)<40) then
										xs:boolean('true')
										else(xs:boolean('false'))

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

let $codeSearch :=matches($searchString,'^[A-Z]?[0-9|\.|/]*$')

let $result := if ($validSearch) then
                  if ($codeSearch) then
                     collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[starts-with(@code,$searchString)]
						else(
                     if (string-length($statusCodes[1]) gt 0) then
   								collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[ft:query(desc,$query,$options)][@statusCode=$statusCodes]
   						else(collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[ft:query(desc,$query,$options)])
						)
					else(<result current="0" count="0"/>)
let $count := count($result)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
let $icdList :=
            if ($codeSearch) then
              for $icd in $result
               let $thesaurusConcepts := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//icd10[@code=$icd/@code]/parent::concept
               let $snomedCount := count(collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//map[@mapTarget=$icd/@code])
					order by $icd/@code
					return
            	<icd code="{$icd/@code}" codeStripped="{$icd/@codeStripped}" effectiveDate="{$icd/@effectiveDate}" expirationDate="{$icd/@expirationDate}" statusCode="{$icd/@statusCode}" concepts="{count($thesaurusConcepts)}" snomedCount="{$snomedCount}">
                 <desc>{$icd/desc/text()}</desc>
                    {
                    for $concept in $thesaurusConcepts
                    return
                    <concept thesaurusId="{$concept/@thesaurusId}" conceptId="{$concept/snomed/@conceptId}" effectiveDate="{$concept/@effectiveDate}" expirationDate="{$concept/@expirationDate}" statusCode="{$concept/@statusCode}">{$concept/desc[@type='pref']/text()}</concept>
                    }
                </icd>
            else(
              for $icd in $result
               let $thesaurusConcepts := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//icd10[@code=$icd/@code]/parent::concept
               let $snomedCount := count(collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//map[@mapTarget=$icd/@code])
					order by $icd/desc
					return
            	<icd code="{$icd/@code}" codeStripped="{$icd/@codeStripped}" effectiveDate="{$icd/@effectiveDate}" expirationDate="{$icd/@expirationDate}" statusCode="{$icd/@statusCode}" concepts="{count($thesaurusConcepts)}" snomedCount="{$snomedCount}">
                 <desc>{$icd/desc/text()}</desc>
                    {
                    for $concept in $thesaurusConcepts
                    return
                    <concept thesaurusId="{$concept/@thesaurusId}" conceptId="{$concept/snomed/@conceptId}" effectiveDate="{$concept/@effectiveDate}" expirationDate="{$concept/@expirationDate}" statusCode="{$concept/@statusCode}">{$concept/desc[@type='pref']/text()}</concept>
                    }
                </icd>
            )
return
<result current="{$current}" count="{$count}">
{
subsequence($icdList,1,$maxResults)
}
</result>