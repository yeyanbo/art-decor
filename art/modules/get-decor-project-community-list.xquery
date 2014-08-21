xquery version "1.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";


let $prefix := request:get-parameter('prefix','')
(:let $prefix := 'peri20-':)
let $projectId := request:get-parameter('id','')
(:let $projectId :='':)

let $decorProject :=
		if (string-length($prefix)>0) then
				$get:colDecorData//project[@prefix=$prefix]
		else if (string-length($projectId)>0) then
				$get:colDecorData//project[@id=$projectId]
		else()
return
<communities>
{
for $community in $get:colDecorData//community[@projectId=$decorProject/@id]
return
<community>
{
   $community/@*,
   for $desc in $community/desc
   return
   art:serializeNode($desc)
}
</community>
}
</communities>
