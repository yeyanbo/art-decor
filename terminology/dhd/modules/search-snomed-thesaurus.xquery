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

let $searchString :=util:unescape-uri(request:get-parameter('searchString',''),'UTF-8')
(:let $searchString :='endocar':)
let $searchTerms := tokenize($searchString,'\s')
(:let $searchType := request:get-parameter('type',('wildcard')):)
let $toplevels := tokenize(util:unescape-uri(request:get-parameter('toplevels',''),'UTF-8'),'\s')
let $refsets := tokenize(util:unescape-uri(request:get-parameter('refsets',''),'UTF-8'),'\s')
let $thesaurusOnly := if (util:unescape-uri(request:get-parameter('thesaurusOnly',('')),'UTF-8')='true') then xs:boolean('true') else(xs:boolean('false'))
let $statusCodes :=tokenize(util:unescape-uri(request:get-parameter('statusCodes',''),'UTF-8'),'\s')
(:let $toplevels :=  tokenize('49755003 71388002','\s') :)
(:let $toplevels :=  ''
let $refsets :=  '' 
let $thesaurusOnly := xs:boolean('true')
let $statusCodes := '':)

let $validSearch := 	
   if (matches($searchString,'^[a-z0-9].{1,48}$')) then
		xs:boolean('true') 
	else if (matches($searchString,'^[A-Z].{1,38}$')) then
		xs:boolean('true')
   else(xs:boolean('false'))
   
let $maxResults := xs:integer('50')
let $options := 
   <options>
   	<filter-rewrite>yes</filter-rewrite>
   	{
   	if ($thesaurusOnly) then
      <leading-wildcard>yes</leading-wildcard>
      else()
      }
   </options>
   
let $query := 
   <query>
      <bool>
      {
       for $term in $searchTerms
       return
          if (matches($term,'^[a-z|0-9]') and $thesaurusOnly) then
          <wildcard occur="must">{concat('*',$term,'*')}</wildcard>
          else if (matches($term,'^[a-z|0-9]') and not($thesaurusOnly)) then
          <wildcard occur="must">{concat($term,'*')}</wildcard>
          else if (matches($term,'^[A-Z]')) then
          <term occur="must">{lower-case($term)}</term>
          else()
      }
      </bool>
   </query>


let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//thesaurus

let $result :=
   if ($validSearch) then
      if ($thesaurusOnly) then
         if (not(matches($searchString,'^[0-9]+')) and string-length($statusCodes[1]) gt 0) then

               $thesaurus//desc[ft:query(.,$query,$options)][parent::concept/@statusCode=$statusCodes][parent::concept]
           
         else if (not(matches($searchString,'^[0-9]+')) and string-length($statusCodes[1]) = 0) then

               $thesaurus//desc[ft:query(.,$query,$options)][parent::concept]
          
         else if (matches($searchString,'^[0-9]+')) then
            (
            $thesaurus//concept[@thesaurusId=$searchString]/desc[@type='pref'],
            $thesaurus//concept[snomed/@conceptId=$searchString]/desc[@type='pref']
            )
         else()
      else(
         if (not(matches($searchString,'^[0-9]+'))) then
            if (string-length($toplevels[1])>0 and string-length($refsets[1])=0) then
               collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][../ancestors/id=$toplevels][@active][../@active]
            else if (string-length($refsets[1])>0 and string-length($toplevels[1])=0) then
               collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][..//*/@refsetId=$refsets][@active][../@active]
            else if (string-length($refsets[1])>0 and string-length($toplevels[1])>0) then
               collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][../ancestors/id=$toplevels][..//*/@refsetId=$refsets][@active][../@active]
            else(
               collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][@active][../@active]
            )
         else if (matches($searchString,'^[0-9]+')) then
            collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$searchString]/desc[@type='pref']
         else()
      )
   else(<result current="0" count="0"/>)
   
   
let $count := count($result)
let $current := if ($count>$maxResults) then
									$maxResults
									else($count)
let $concepts := for $concept in $result
					order by xs:integer($concept/@count),xs:integer($concept/@length)
					return
					$concept
					
let $response :=
   if ($thesaurusOnly) then
      <result current="{$current}" count="{$count}" statusCode="{string-length($statusCodes[1])}">
      {
       for $res in subsequence($concepts,1,$maxResults)
       let $concept := $res/parent::concept
       return
       <description id="{$concept/@id}" memberStatusCode="{$concept/@statusCode}" thesaurusId="{$concept/@thesaurusId}" type="{$res/@type}" conceptId="{$concept/snomed/@conceptId}" fullName="{$concept/snomed/desc[@type='fsn']/text()}">{$res/text()}</description>
      }
      </result>
   else (
      <result current="{$current}" count="{$count}">
      {
       for $res in subsequence($concepts,1,$maxResults)
       let $concept := $res/parent::concept
       let $dhdSnomed := $thesaurus//snomed[@conceptId=$concept/@conceptId]
       return
       <description id="{$dhdSnomed/parent::concept/@id}" memberStatusCode="{$dhdSnomed/parent::concept/@statusCode}" thesaurusId="{$dhdSnomed/parent::concept/@thesaurusId}" type="{$res/@type}" conceptId="{$concept/@conceptId}" fullName="{$concept/desc[@active][@type='fsn']/text()}">{$res/text()}</description>
      }
      </result>
      )
return
$response
