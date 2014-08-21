xquery version "1.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "xmldb:exist:///db/apps/art/modules/art-decor-settings.xqm";
(:import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";:)
(:import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../modules/art-decor-settings.xqm";:)
declare namespace expath="http://expath.org/ns/pkg";

(: all terminology data collections :)
let $collections := xmldb:get-child-collections($get:strTerminologyData)
let $classifications :=
   <classifications>
   {
      for $child in $collections
      let $titles := collection(concat($get:strTerminologyData,'/',$child))//ClaML/Title
      let $packageTitle :=concat(substring-before(collection(concat($get:strTerminologyData,'/',$child))//expath:package/expath:title/text(),' Data'),substring-before(collection(concat($get:strTerminologyData,'/',$child))//expath:package/expath:title/text(),' data'))
      let $name :=
         if (contains($packageTitle,'Data')) then 
         substring-before(collection(concat($get:strTerminologyData,'/',$child))//expath:package/expath:title/text(),' Data')
         else if (contains($packageTitle,'data')) then
         substring-before(collection(concat($get:strTerminologyData,'/',$child))//expath:package/expath:title/text(),' data')
         else ($packageTitle)
      order by $name
      return
      if ($titles) then
      <classification collection="{$child}" displayName="{$name}">
       {
       for $title in $titles
       return
       <Title language="{substring-after(substring-before(util:collection-name($title),'/claml'),concat($get:strTerminologyData,'/',$child,'/'))}">
       {
       $title/@*,
       $title/text()
       }
       </Title>
       }
      </classification>
      else()
   }
   </classifications>

let $refsets :=
   <refsets>
   {  
   for $refset in collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset
   let $project := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$refset/@id]
   order by $project/name[1]
   return
   <refset id="{$refset/@id}">
   {$project/name}
   </refset>
   }
   </refsets>
   
   let $packages :=
   <packages>
   {  for $child in $collections
      let $package :=collection(concat($get:strTerminologyData,'/',$child))//expath:package
      return
      <package abbrev="{$package/@abbrev}" version="{$package/@version}">
      {$package/expath:title/text()}
      </package>
   }
   </packages>
return
<terminology>
{$refsets,$classifications,$packages}
</terminology>