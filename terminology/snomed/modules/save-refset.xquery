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

let $editedRefset := request:get-data()/refset
let $storedRefset := collection(concat($get:strTerminologyData,'/snomed-refsets/data'))//refset[@id=$editedRefset/@id]

let $preparedProject :=
   <project>
   {
   $editedRefset/project/@*,
   $editedRefset/project/name,
   for $desc in $editedRefset/project/desc
   return
   art:parseNode($desc)
   ,
   $editedRefset/project/copyright,
   $editedRefset/project/author
   }
   </project>

let $projectUpdate :=
   update replace $storedRefset/project with $preparedProject

let $membersUpdate :=
   for $member in $editedRefset/members/member[edit]
   let $statusCode :=
          if ($member/@statusCode='new' and $member/referencedComponent/description) then
            'draft'
         else($member/@statusCode/string())
   let $id :=
        if ($member/@statusCode='new' and not(contains($member/@id,'-'))) then
           util:uuid()
         else($member/@id)
   let $preparedMember :=
      <member id="{$id}" statusCode="{$statusCode}" effectiveTime="{$member/@effectiveTime}">
         {
         $member/originalText,
         $member/translation,
         $member/lastStatusChange,
         $member/referencedComponent
         }
      </member>
   return
   if ($member[edit/@mode='edit']) then
      update replace $storedRefset//member[@id=$member/@id] with $preparedMember
   else if ($member[edit/@mode='new']) then
      update insert $preparedMember into $storedRefset/members
   else()

return
<data-safe>true</data-safe>