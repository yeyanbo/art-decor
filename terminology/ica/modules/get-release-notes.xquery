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

let $release := 
      if(count(tokenize(util:unescape-uri(request:get-parameter('effectiveTime',''),'UTF-8'),'\s')) gt 1) then
         string-join(tokenize(util:unescape-uri(request:get-parameter('effectiveTime',''),'UTF-8'),'\s'),'+')
      else(util:unescape-uri(request:get-parameter('effectiveTime',''),'UTF-8'))
(:let $release := xs:dateTime('2014-03-03T13:40:48.552+01:00'):)

return
<releaseNotes>
{
   if ($release castable as xs:dateTime) then
   let $previousReleases := collection(concat($get:strTerminologyData,'/ica-data/meta'))//release[xs:dateTime(@effectiveTime) lt xs:dateTime($release)]
   let $previousRelease := max($previousReleases/xs:dateTime(@effectiveTime))
   let $ciList := collection(concat($get:strTerminologyData,'/ica-data/concepts'))//cics
   
   let $conceptActivations :=
      collection(concat($get:strTerminologyData,'/ica-data/log'))//statusChange[@statusCode='active'][@object='ci'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt xs:dateTime($release)]
   
   
   let $conceptUpdates :=
      collection(concat($get:strTerminologyData,'/ica-data/log'))//statusChange[@statusCode='update'][@object='ci'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt xs:dateTime($release)]
   
   let $conceptRetirements :=
      collection(concat($get:strTerminologyData,'/ica-data/log'))//statusChange[@statusCode='retired'][@object='ci'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt xs:dateTime($release)]
      
   let $newConcepts :=
      $ciList/ci[@id=$conceptActivations/@id][not(@id=$conceptUpdates/@id)][@statusCode='active']
   
   let $updatedConcepts :=
      $ciList/ci[@id=$conceptActivations/@id][@id=$conceptUpdates/@id][@statusCode='active']
   
   let $retiredConcepts :=
      $ciList/ci[@id=$conceptRetirements/@id]
      
   let $resolvedIssues :=
         collection(concat($get:strTerminologyData,'/ica-data/meta'))//issue[max(tracking[@statusCode='closed']/xs:dateTime(@effectiveDate)) gt $previousRelease][max(tracking[@statusCode='closed']/xs:dateTime(@effectiveDate)) lt xs:dateTime($release)]
   
   let $newIssues :=
         collection(concat($get:strTerminologyData,'/ica-data/meta'))//issue[min(tracking[@statusCode='open']/xs:dateTime(@effectiveDate)) gt $previousRelease][min(tracking[@statusCode='open']/xs:dateTime(@effectiveDate)) lt xs:dateTime($release)][not(tracking[@statusCode='closed'])]
      
   return
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
         <concept id="{$concept/@id}">{$concept/text/text()}</concept>
      }
      </new>
      <updated>
            {
         for $concept in $updatedConcepts
         return
         <concept id="{$concept/@id}">{$concept/text/text()}</concept>
      }
      </updated>
      <retired>
      {
         for $concept in $retiredConcepts
         return
         <concept id="{$concept/@id}">{$concept/text/text()}</concept>
      }
      </retired>
   </concepts>
   )
   else()
   else()
}
</releaseNotes>
