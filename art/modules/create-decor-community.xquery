xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at  "art-decor.xqm";

declare function local:preparePrototype($prototype as element()) as element() {
	<prototype>
   	{
      	for $data in $prototype/data
      	return
      	<data>
      	{
      	$data/@*,
      	for $desc in $data/desc
      	return
      	art:parseNode($desc)
      	}
      	</data>
   	}
	</prototype>
};

(: get community from request :)
let $newCommunity := request:get-data()/community

(: get project parent collection  :)
let $parentCollection := util:collection-name($get:colDecorData//decor[project/@id=$newCommunity/@projectId])

let $community :=
   <community>
   {
   $newCommunity/@name,
   $newCommunity/@projectId,
   if (string-length($newCommunity/@displayName)=0) then
      attribute displayName{$newCommunity/@name}
   else ($newCommunity/@displayName),
   for $desc in $newCommunity/desc
   return
   art:parseNode($desc)
   ,
   $newCommunity/access
   ,
   local:preparePrototype($newCommunity/prototype)
   }
   </community>


   return
<result>
{xmldb:store($parentCollection,concat('community-',$newCommunity/@name,'.xml'),$community)}
</result>