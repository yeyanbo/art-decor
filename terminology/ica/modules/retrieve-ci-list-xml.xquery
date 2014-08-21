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

let $release := util:unescape-uri(request:get-parameter('release',('')),'UTF-8')
(:let $release := '20140331_135546':)
let $releases := collection(concat($get:strTerminologyData,'/ica-data/meta'))//release

let $xml :=
   if (string-length($release) gt 0 and doc-available(concat($get:strTerminologyData,'/ica-data/releases/',$release,'.xml'))) then
      doc(concat($get:strTerminologyData,'/ica-data/releases/',$release,'.xml'))
    else if (string-length($release) = 0 and $releases) then
      let $latestRelease := max($releases/xs:dateTime(@effectiveTime))
      return
      doc(concat($get:strTerminologyData,'/ica-data/releases/',datetime:format-dateTime($latestRelease,'yyyyMMdd_HHmmss'),'.xml'))
    else(<cics/>)


return
<cics>
{
 for $ci in $xml/cics/ci
 order by lower-case($ci/text)
 return
 $ci
}
</cics>