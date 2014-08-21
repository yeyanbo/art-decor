xquery version "3.0";
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

let $moduleId:= '11000146104'
let $descriptions:=
<descriptions>
{
for $refset in collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset
let $refsetId := $refset/@id
return
    for $desc in $refset//desc[@statusCode]
    let $effectiveTime :=
      if ($desc/@effectiveTime castable as xs:date) then
         datetime:format-date(xs:date($desc/@effectiveTime),"yyyy-MM-dd")
      else($desc/@effectiveTime)
    let $active := if ($desc/@statusCode='active') then '1' else '0'
    let $acceptability := if ($desc/@type='pref') then '900000000000548007' else '900000000000549004'
    let $languageRefsetId:= if ($desc/@languageCode='en') then '900000000000509007' else '31000146106'
   return
   <description  uuid="{$desc/@uuid}"  id="{$desc/@id}" soId="{$desc/@soId}" effectiveTime="{$effectiveTime}" statusCode="{$desc/@statusCode}" type="{$desc/@type}" count="{$desc/@count}" length="{$desc/@length}" active="{$desc/@active}" moduleId="{$desc/@moduleId}" conceptId="{$desc/parent::concept/@conceptId}" languageCode="{$desc/@languageCode}" typeId="{$desc/@typeId}" caseSignificanceId="{$desc/@caseSignificanceId}">
      <desc>{$desc/text()}</desc>
      <languageRefset  id="{$desc/@uuid}" effectiveTime="{$effectiveTime}" active="{$active}" moduleId="{$moduleId}" languageRefsetId="{$languageRefsetId}" acceptabilityId="{$acceptability}"/>
   </description>
   ,
for $concept in collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept
return
    for $desc in $concept//desc
    let $effectiveTime :=
      if ($desc/@effectiveTime castable as xs:date) then
         datetime:format-date(xs:date($desc/@effectiveTime),"yyyy-MM-dd")
      else($desc/@effectiveTime)
    let $active := if ($desc/@statusCode='active') then '1' else '0'
    let $acceptability := if ($desc/@type='pref') then '900000000000548007' else '900000000000549004'
    let $languageRefsetId:= if ($desc/@languageCode='en') then '900000000000509007' else '31000146106'
   return
   <description  uuid="{$desc/@uuid}"  id="{$desc/@id}" soId="{$desc/@soId}" effectiveTime="{$effectiveTime}" statusCode="{$desc/@statusCode}" type="{$desc/@type}" count="{$desc/@count}" length="{$desc/@length}" active="{$desc/@active}" moduleId="{$desc/@moduleId}" conceptId="{$desc/parent::concept/@conceptId}" languageCode="{$desc/@languageCode}" typeId="{$desc/@typeId}" caseSignificanceId="{$desc/@caseSignificanceId}">
      <desc>{$desc/text()}</desc>
      <languageRefset  id="{$desc/@uuid}" effectiveTime="{$effectiveTime}" active="{$active}" moduleId="{$moduleId}" languageRefsetId="{$languageRefsetId}" acceptabilityId="{$acceptability}"/>
   </description>
}
</descriptions>
let $counts := <counts desc="{count($descriptions/description)}" distinct="{count(distinct-values($descriptions/description/@uuid))}"/>
return
for $id in distinct-values($descriptions/description/@uuid)
return
$descriptions/description[@uuid=$id][1]