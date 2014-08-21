xquery version "3.0";

(:
	Copyright (C) 2012 Art Decor Expert group, www.art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
(:declare option exist:serialize "method=xml media-type=text/xml";:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
(:let $language := request:get-parameter('lang','nl-NL'):)
(:let $language := 'nl-NL':)
let $project := collection(concat($get:strTerminologyData,'/ica-data/meta'))/project
let $ciList := collection(concat($get:strTerminologyData,'/ica-data/concepts'))/cics
return
<project>
   <concepts count="{count($ciList/ci)}" draft="{count($ciList/ci[@statusCode='draft'])}" update="{count($ciList/ci[@statusCode='update'])}" review="{count($ciList/ci[@statusCode='review'])}"/>
   {
   $project/author,
   for $release in $project/release
   order by xs:dateTime($release/@effectiveTime) descending
   return
   <release>
   {
   $release/@*,
   for $comment in $release/comment
   return
   art:serializeNode($comment)
   }
   </release>
   }
</project>
