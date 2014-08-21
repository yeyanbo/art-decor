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
import module namespace art ="http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";

let $release := request:get-data()/release


let $storedProject := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref='extension']
let $user :=xmldb:get-current-user()
(:check if user is admin:)
let $admin := xs:boolean($storedProject/author[@username=$user]/@admin)

let $collectionRemove :=
   if (xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($release/@effectiveTime,'yyyyMMdd'))) and $admin) then
      xmldb:remove(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($release/@effectiveTime,'yyyyMMdd')))
   else()
   
let $projectUpdate :=
   if ($admin) then
       let $update := update delete $storedProject/release[@effectiveTime=$release/@effectiveTime]
       return
       'OK'
   else('NO PERMISSION')


return
<data-safe>{if ($projectUpdate='OK') then 'true' else 'false'}</data-safe>