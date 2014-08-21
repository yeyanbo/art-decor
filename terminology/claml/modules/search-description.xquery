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
let $classificationId := request:get-parameter('classificationId','')
let $searchString :=util:unescape-uri(request:get-parameter('string',''),'UTF-8')
let $language :='nl-NL'
(:let $classification :='':)
(:let $searchString :='ana eig':)
let $searchTerms := tokenize($searchString,'\s')
(:let $searchType := request:get-parameter('type',('wildcard')):)
let $searchType :='wildcard'

let $classifications :=
   <classifications>
   {
      for $child in xmldb:get-child-collections($get:strTerminologyData)
      let $clamls := collection(concat($get:strTerminologyData,'/',$child))//ClaML
      return
      if ($clamls) then
      <classification collection="{$child}">
      {
       for $claml in $clamls
       return
       <Title language="{substring-after(substring-before(util:collection-name($claml),'/claml'),concat($get:strTerminologyData,'/',$child,'/'))}">
       {
       $claml/Title/@*,
       $claml/Identifier
       }
       </Title>
      }
      </classification>
      else()
   }
   </classifications>

let $classification :=$classifications/classification[Title/Identifier/@uid=$classificationId]


let $collection := 
   if (count($classification/Title[Identifier/@uid=$classificationId])>1) then
      if ($classification/Title[Identifier/@uid=$classificationId]/@language=$language) then
         concat($get:strTerminologyData,'/',$classification/@collection,'/',$language,'/descriptions')
      else(concat($get:strTerminologyData,'/',$classification/@collection,'/',$classification/Title[Identifier/@uid=$classificationId][1]/@language,'/descriptions'))
   else(concat($get:strTerminologyData,'/',$classification/@collection,'/',$classification/Title[Identifier/@uid=$classificationId]/@language,'/descriptions'))



let $validSearch := if (matches($searchString,'^[a-z|0-9]') and string-length($searchString)>2 and string-length($searchString)<40) then
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
   if ($validSearch) then 
   	collection($collection)//description[ft:query(.,$query,$options)]
   else(<result current="0" count="0"/>)
   
let $count := count($result)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
let $concepts := for $concept in $result
					order by xs:integer($concept/@count),xs:integer($concept/@length)
					return
					$concept
return
<result current="{$current}" count="{$count}">
{
subsequence($concepts,1,$maxResults)
}
</result>