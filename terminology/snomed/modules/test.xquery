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
	
	System ID: /Volumes/Data/SNOMED Releases/2014-01-31_test/SnomedCT_Release_INT_20140131/XML/RF2Release/Snapshot/Terminology/relations.xml
Description: 900000000000227009

:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace compression="http://exist-db.org/xquery/compression";
declare variable $root := repo:get-root();


let $newRelease :=
<release effectiveTime="2014-06-30" statusCode="draft" label="juli">
   <comment>Release comment</comment>
</release>

let $date := $newRelease/@effectiveTime
let $releaseDate :=
   if ($date castable as xs:date) then
      xs:date($date)
   else (current-date())

let $previousReleases := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//release[xs:date(@effectiveTime) lt xs:date($releaseDate)]
let $previousReleaseDate := max($previousReleases/xs:date(@effectiveTime))

let $descMemberIdCount := count(collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//desc[@memberId])
let $descuuIdCount := count(collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//desc[@uuid])
let $descStatusCount := count(collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//desc[@statusCode])
return
<report>
{
for $refset in collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset
let $project := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$refset/@id]

return
(
<refset id="{$refset/@id}" name="{$project/name[1]}" members="{count($refset/member)}" distinct-concepts="{count(distinct-values($refset//concept/@conceptId))}" draft="{count($refset/member[@statusCode='draft'])}" rejected="{count($refset/member[@statusCode='rejected'])}" update="{count($refset/member[@statusCode='update'])}"  review="{count($refset/member[@statusCode='review'])}" active="{count($refset/member[@statusCode='active'])}" retired="{count($refset/member[@statusCode='retired'])}"/>
,
$refset/member[not(@statusCode=('draft','rejected','review','update','active','retired'))]
)
}
<count member="{$descMemberIdCount}" uuid="{$descuuIdCount}" status="{$descStatusCount}"/>
</report>
            