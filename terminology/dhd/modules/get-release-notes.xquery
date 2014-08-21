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


let $release := xs:dateTime(request:get-data()/release/@effectiveTime)
(:let $release := xs:dateTime('2014-01-19T16:01:03.197+01:00'):)

let $previousReleases := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//release[xs:dateTime(@effectiveTime) lt xs:dateTime($release)]
let $previousRelease := max($previousReleases/xs:dateTime(@effectiveTime))
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//thesaurus

let $conceptActivations :=
   collection(concat($get:strTerminologyData,'/dhd-data/log'))//statusChange[@statusCode='active'][@object='concept'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt $release]


let $conceptUpdates :=
   collection(concat($get:strTerminologyData,'/dhd-data/log'))//statusChange[@statusCode='update'][@object='concept'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt $release]

let $conceptRetirements :=
   collection(concat($get:strTerminologyData,'/dhd-data/log'))//statusChange[@statusCode='retired'][@object='concept'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt $release]
   
let $newConcepts :=
   $thesaurus/concept[@thesaurusId=$conceptActivations/@thesaurusId][not(@thesaurusId=$conceptUpdates/@thesaurusId)][@statusCode='active']

let $updatedConcepts :=
   $thesaurus/concept[@thesaurusId=$conceptActivations/@thesaurusId][@thesaurusId=$conceptUpdates/@thesaurusId][@statusCode='active']

let $retiredConcepts :=
   $thesaurus/concept[@thesaurusId=$conceptRetirements/@thesaurusId]
   
let $resolvedIssues :=
      collection(concat($get:strTerminologyData,'/dhd-data/meta'))//issue[max(tracking[@statusCode='closed']/xs:dateTime(@effectiveDate)) gt $previousRelease][max(tracking[@statusCode='closed']/xs:dateTime(@effectiveDate)) lt $release]

let $newIssues :=
      collection(concat($get:strTerminologyData,'/dhd-data/meta'))//issue[min(tracking[@statusCode='open']/xs:dateTime(@effectiveDate)) gt $previousRelease][min(tracking[@statusCode='open']/xs:dateTime(@effectiveDate)) lt $release][not(tracking[@statusCode='closed'])]


return
<releaseNotes>
{
   if ($previousReleases) then
   (
   <issues>
      <new>
      {
         for $issue in $newIssues
         return
         <issue id="{$issue/@id}">{$issue/@displayName/string()}</issue>
      }
      </new>
      <resolved>
      {
         for $issue in $resolvedIssues
         return
         <issue id="{$issue/@id}">{$issue/@displayName/string()}</issue>
      }
      </resolved>
   </issues>,
   <concepts>
      <new>
      {
         for $concept in $newConcepts
         return
         <concept thesaurusId="{$concept/@thesaurusId}">{$concept/desc[@type='pref']/text()}</concept>
      }
      </new>
      <updated>
            {
         for $concept in $updatedConcepts
         return
         <concept thesaurusId="{$concept/@thesaurusId}">{$concept/desc[@type='pref']/text()}</concept>
      }
      </updated>
      <retired>
      {
         for $concept in $retiredConcepts
         return
         <concept thesaurusId="{$concept/@thesaurusId}">{$concept/desc[@type='pref']/text()}</concept>
      }
      </retired>
   </concepts>
   )
   else()
}
</releaseNotes>
