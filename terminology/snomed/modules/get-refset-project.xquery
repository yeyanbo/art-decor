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

let $refsetId:= request:get-parameter('id','')
(:let $refsetId:= '41000146103':)
let $project := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$refsetId]
let $refset :=collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
return
<project>
   {
   $project/@*,
   $project/name,
   for $desc in $project/desc
   return
      art:serializeNode($desc)
   ,
   $project/author,
   <concepts draft="{count($refset/member[@statusCode='draft'])}" review="{count($refset/member[@statusCode='review'])}" update="{count($refset/member[@statusCode='update'])}"/>
   }
</project>