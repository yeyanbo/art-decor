xquery version "3.0";
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
(:let $searchString :='endo':)
let $searchTerms := tokenize($searchString,'\s')

let $toplevels := tokenize(util:unescape-uri(request:get-parameter('toplevels',''),'UTF-8'),'\s')
let $refsets := tokenize(util:unescape-uri(request:get-parameter('refsets',''),'UTF-8'),'\s')

(:let $toplevels :=  ''
let $refsets :=  '' :)

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
   
let $query := 
   <query>
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
(:raw query result:)
let $result :=
   if ($validSearch and not(matches($searchString,'^[0-9]+'))) then
      if (string-length($toplevels[1])>0 and string-length($refsets[1])=0) then
         collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][../ancestors/id=$toplevels][@active][../@active]
      else if (string-length($refsets[1])>0 and string-length($toplevels[1])=0) then
         collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][..//*/@refsetId=$refsets][@active][../@active]
      else if (string-length($refsets[1])>0 and string-length($toplevels[1])>0) then
         collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][../ancestors/id=$toplevels][..//*/@refsetId=$refsets][@active][../@active]
      else(
         collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][@active][../@active]
      )
   else if ($validSearch and matches($searchString,'^[0-9]+')) then
      collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$searchString]/desc[@type='pref']
   else(<result current="0" count="0"/>)

(:order result by count and length:)
let $descriptions := for $description in $result
					order by xs:integer($description/@count),xs:integer($description/@length)
					return
					$description
(:group result by conceptId and only return first hit:)
let $grouped :=
   for $desc in $descriptions
   group by $cc := $desc/parent::concept/@conceptId
   order by xs:integer($desc[1]/@count),xs:integer($desc[1]/@length)
   return
   <desc conceptId="{$cc}">{$desc[1]/@*,$desc[1]/text()}</desc>
  
let $count := count($grouped)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
return
<result current="{$current}" count="{$count}">
{
 for $res in subsequence($grouped,1,$maxResults)
 let $fsn := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$res/@conceptId]/desc[@active][@type='fsn']/text()

 return
 <description type="{$res/@type}" conceptId="{$res/@conceptId}" fullName="{$fsn}">{$res/text()}</description>
}
</result>