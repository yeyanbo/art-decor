xquery version "1.0";
(:
	Copyright (C) 2012 Art-Decor Expert Group
	
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
declare namespace expath="http://expath.org/ns/pkg";

let $collections := xmldb:get-child-collections($get:strTerminologyData)
let $classifications :=
   <classifications>
   {
      for $child in $collections
      let $languageCollections := xmldb:get-child-collections(concat($get:strTerminologyData,'/',$child))
      let $clamlCount := 
         for $languageCollection in $languageCollections
         return
         count(collection(concat($get:strTerminologyData,'/',$child,'/',$languageCollection))//ClaML)
      let $clamls := collection(concat($get:strTerminologyData,'/',$child))//ClaML
      let $packageTitle := collection(concat($get:strTerminologyData,'/',$child))//expath:package/expath:title/text()
      let $name :=
         if (contains($packageTitle,'Data')) then 
         substring-before(collection(concat($get:strTerminologyData,'/',$child))//expath:package/expath:title/text(),' Data')
         else if (contains($packageTitle,'data')) then
         substring-before(collection(concat($get:strTerminologyData,'/',$child))//expath:package/expath:title/text(),' data')
         else ($packageTitle)
      order by $name
      return
      if ($clamls) then
      <classification collection="{$child}" name="{$name}" isGroup="{every $count in $clamlCount satisfies $count>1}">
      {
       for $claml in $clamls
       return
             <Title id="{$claml/Identifier[1]/@uid}" language="{substring-after(substring-before(util:collection-name($claml),'/claml'),concat($get:strTerminologyData,'/',$child,'/'))}">
       {

       $claml/Title/@*,
       $claml/Title/text()
       }
       </Title>
       }
      </classification>
      else()
   }
   </classifications>

return
$classifications