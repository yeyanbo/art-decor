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
import module namespace art ="http://art-decor.org/ns/art" at "xmldb:exist:///db/apps/art/modules/art-decor.xqm";
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "xmldb:exist:///db/apps/art/modules/art-decor-settings.xqm";

(:let $refsetId:= request:get-parameter('id',''):)
let $refsetId:= '2.16.840.1.113883.2.4.3.11.26.1'
let $refset := collection(concat($get:strTerminologyData,'/snomed-refsets/data'))//refsetProject[@id=$refsetId]

return
<refset>
{$refset/@*}
   <project>
   {
   $refset/project/@*,
   $refset/project/name,
   for $desc in $refset/project/desc
	return
	art:serializeNode($desc)
	,
   $refset/project/author
   }
   </project>
{$refset/moduleDependency}
<members>
{
for $member in $refset/refsetVersions/refset/member
order by lower-case($member//desc[@type='fsn'])
return
$member
}
</members>
</refset>