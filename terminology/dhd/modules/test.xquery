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
declare namespace compression="http://exist-db.org/xquery/compression";
declare variable $root := repo:get-root();
(:let $release := xs:dateTime('2014-01-19T16:01:03.197+01:00')

let $previousReleases := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//release[xs:dateTime(@effectiveTime) lt xs:dateTime($release)]
let $previousRelease := max(xs:dateTime($previousReleases/@effectiveTime))
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//thesaurus
let $conceptActivations :=
   collection(concat($get:strTerminologyData,'/dhd-data/log'))//statusChange[@statusCode='active'][@object='concept'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt $release]

let $conceptUpdates :=
   collection(concat($get:strTerminologyData,'/dhd-data/log'))//statusChange[@statusCode='update'][@object='concept'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt $release]

let $conceptRetirements :=
   collection(concat($get:strTerminologyData,'/dhd-data/log'))//statusChange[@statusCode='retired'][@object='concept'][xs:dateTime(@effectiveTime) gt $previousRelease][xs:dateTime(@effectiveTime) lt $release]

let $newConcepts :=
   $thesaurus/concept[@thesaurusId=$conceptActivations/@thesaurusId][@statusCode='active'][xs:date(@effectiveDate) gt xs:date($previousRelease)]

let $updatedConcepts :=
   $thesaurus/concept[@thesaurusId=$conceptActivations/@thesaurusId][@thesaurusId=$conceptUpdates][@statusCode='active']

let $retiredConcepts :=
   $thesaurus/concept[@thesaurusId=$conceptRetirements/@thesaurusId]:)
   
(:for $link in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[string-length(@idLink) gt 0]
let $update := xs:integer($link/@idLink)
return
update value $link/@idLink with $update:)

(:for $domain in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//specialism
let $statusCode :=
   if (xs:date($domain/@expirationDate) lt current-date()) then
      'retired'
   else 'active'
return
update value $domain/@statusCode with $statusCode:)
(:$statusCode:)
 declare function local:setDHDQueryPermissions() {
   for $query in xmldb:get-child-resources(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/dhd/modules')))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/dhd/modules/',$query)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/dhd/modules/',$query)),'terminology'),
   if (starts-with($query,('add','create','delete','save','update'))) then
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/dhd/modules/',$query)),sm:octal-to-mode('0754'))
   else(sm:chmod(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/dhd/modules/',$query)),sm:octal-to-mode('0755')))
   ,
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/dhd/modules/',$query)))
   )
};
let $test :=local:setDHDQueryPermissions()
return
$test