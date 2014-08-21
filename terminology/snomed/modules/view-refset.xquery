xquery version "1.0";
(:
	Copyright (C) 2011-2014 Art Decor Expert Group art-decor.org
	
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
(:declare option exist:serialize "method=text media-type=text/xml charset=utf-8";:)
let $refsetId:= request:get-parameter('id','')
(:let $refsetId:= '41000146103':)
let $refset := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
let $project :=collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$refsetId]
return
<refset>
   {
   $refset/@*
   
   }
   <project>
   {
   $project/@*,
   $project/name
   }
   </project>
   <members>
      {
         for $member in $refset/member
         return
         <member>
         {
         $member/@*
         }
         <concept>
         {
         $member/concept/@*,
         $member/concept/desc
         }
         </concept>
         </member>
      }
   </members>
</refset>
