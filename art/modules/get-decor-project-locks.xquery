xquery version "3.0";
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

(:
   Query for retrieving decor locks for specific project
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
let $project:=request:get-parameter('prefix','')
(:let $project:='demo1-':)
let $projectId:=$get:colDecorData//project[@prefix=$project]/@id
let $conceptLocks :=  
   for $lock in $get:colArtResources/decorLocks/conceptLock
   let $concept := $get:colDecorData//concept[@id=$lock/@ref][@effectiveDate=$lock/@effectiveDate]
   where $concept/ancestor::decor/project/@prefix=$project
   return
   <concept>
     {
     $concept/name,
     $lock
     }
   </concept>
let $valuesetLocks :=  
   for $lock in $get:colArtResources/decorLocks/lock[@type='VS']
   let $valueset := $get:colDecorData//valueSet[@id=$lock/@ref][@effectiveDate=$lock/@effectiveDate]
   where $valueset/ancestor::decor/project/@prefix=$project
   return
   <valueSet>
     {
     if (string-length($valueset/@displayName)>0) then
      <name>{$valueset/@displayName/string()}</name>
     else(<name>{$valueset/@name/string()}</name>)
     ,
     $lock
     }
   </valueSet>
 let $communityLocks :=  
   for $lock in $get:colArtResources/decorLocks/communityLock[@projectId=$projectId]
   let $community := $get:colDecorData//community[@name=$lock/@ref][@projectId=$lock/@projectId]
   return
   <community>
     {
     if (string-length($community/@displayName)>0) then
      <name>{$community/@displayName/string()}</name>
     else(<name>{$community/@name/string()}</name>)
     ,
     $lock
     }
   </community>
let $templateLocks :=  
   for $lock in $get:colArtResources/decorLocks/lock[@type='TM']
   let $template := $get:colDecorData//template[@id=$lock/@ref][@effectiveDate=$lock/@effectiveDate]
   where $template/ancestor::decor/project/@prefix=$project
   return
   <template>
     {
     if (string-length($template/@displayName)>0) then
      <name>{$template/@displayName/string()}</name>
     else(<name>{$template/@name/string()}</name>)
     ,
     $lock
     }
   </template>
return
<locks>
<concepts>
{$conceptLocks}
</concepts>
<valuesets>
{$valuesetLocks}
</valuesets>
<communities>
{$communityLocks}
</communities>
<templates>
{$templateLocks}
</templates>
</locks>

