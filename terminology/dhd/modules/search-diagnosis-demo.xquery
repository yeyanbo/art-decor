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
(:let $searchString :='ast':)
let $searchTerms := tokenize($searchString,'\s')
(:let $searchType := request:get-parameter('type',('wildcard')):)
let $toplevels := tokenize(util:unescape-uri(request:get-parameter('toplevels',''),'UTF-8'),'\s')
let $refsets := tokenize(util:unescape-uri(request:get-parameter('refsets',''),'UTF-8'),'\s')
let $specialism :=util:unescape-uri(request:get-parameter('specialism',''),'UTF-8')
let $mode := request:get-parameter('mode',(''))
(:let $toplevels :=  tokenize('49755003 71388002','\s') :)
(:let $toplevels :=  ''
let $refsets :=  '' 
let $mode := 'thesaurus'
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
   	if ($mode=('specialism','thesaurus')) then
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
          if (matches($term,'^[a-z|0-9]') and $mode=('specialism','thesaurus')) then
          <wildcard occur="must">{concat('*',$term,'*')}</wildcard>
          else if (matches($term,'^[a-z|0-9]') and not($mode=('specialism','thesaurus'))) then
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
      if ($mode='specialism') then
         $thesaurus//desc[ft:query(.,$query,$options)][parent::concept/dbc[@agbCode=$specialism]][parent::concept/@statusCode='active'][parent::concept]
      else if ($mode='thesaurus') then
         $thesaurus//desc[ft:query(.,$query,$options)][parent::concept/@statusCode='active'][parent::concept]
      else(
         if (string-length($toplevels[1])>0 and string-length($refsets[1])=0) then
            collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][../ancestors/id=$toplevels][@active][../@active]
         else if (string-length($refsets[1])>0 and string-length($toplevels[1])=0) then
            collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][..//*/@refsetId=$refsets][@active][../@active]
         else if (string-length($refsets[1])>0 and string-length($toplevels[1])>0) then
            collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][../ancestors/id=$toplevels][..//*/@refsetId=$refsets][@active][../@active]
         else(
            collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][@active][../@active]
         )
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
   if ($mode=('specialism','thesaurus')) then
      <result current="{$current}" count="{$count}">
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
       <description id="{$dhdSnomed/parent::concept/@id}" memberStatusCode="{$dhdSnomed/parent::concept/@statusCode}" thesaurusId="{$dhdSnomed/parent::concept/@thesaurusId}" type="{$res/@type}" conceptId="{$concept/@conceptId}" fullName="{$concept/desc[@type='fsn']/text()}">{$res/text()}</description>
      }
      </result>
      )
return
$response
