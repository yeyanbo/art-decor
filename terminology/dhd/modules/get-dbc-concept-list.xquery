
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

let $agb :=util:unescape-uri(request:get-parameter('agb',('')),'UTF-8')
let $code :=util:unescape-uri(request:get-parameter('code',''),'UTF-8')

(:let $agb :='0313'
let $code :='499':)

let $thesaurusConcepts := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//dbc[@code=$code][@agbCode=$agb]/parent::concept

return
<concepts>
{
  for $concept in $thesaurusConcepts
  order by $concept/desc[@type='pref'][1]
  return
  <concept thesaurusId="{$concept/@thesaurusId}" conceptId="{$concept/snomed/@conceptId}" effectiveDate="{$concept/@effectiveDate}" expirationDate="{$concept/@expirationDate}" statusCode="{$concept/@statusCode}">{$concept/desc[@type='pref']/text()}</concept>
}             
</concepts>