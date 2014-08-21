xquery version "1.0";
(:
	Copyright (C) 2011 Art-Decor expert group
	
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

let $classificationId := request:get-parameter('classificationId','')
let $code := request:get-parameter('code','')
let $language :='nl-NL'


let $classificationIndex := doc(concat($get:strTerminology,'/claml/classification-index.xml'))/classificationIndex

let $classification :=$classificationIndex//classification[@id=$classificationId]


let $collection := 
   if (count($classification)>1) then
      if ($classification/@language=$language) then
         concat($classification[@language=$language]/@collection,'/denormalized')
      else(concat($classification[1]/@collection,'/denormalized'))
   else(concat($classification/@collection,'/denormalized'))

let $allClasses :=collection($collection)//ClaML-denormalized[Identifier/@uid=$classificationId]


let $classes:= 
   if (string-length($code)=0) then
      $allClasses//Class[not(SuperClass)][@code!='rootClass']
   else(
      $allClasses//Class[SuperClass/@code=$code]
   )

return
<result>
   {
   $classes
   }
</result>