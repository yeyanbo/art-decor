xquery version "1.0";
(:
	Copyright (C) 2011-2013 Art-Decor Expert Group
	
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
import module namespace snomed ="http://art-decor.org/ns/terminology/snomed" at "../api/api-snomed.xqm";

let $translation := request:get-data()/desc


let $storedDesc      := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//desc[@uuid=$translation/@uuid]
let $storedDescription      := collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))//description[@uuid=$translation/@uuid]
let $refset          := $storedDesc/ancestor::refset

let $user         := xmldb:get-current-user()
let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$refset/@id]
let $edit         := xs:boolean($project/author[@username=$user]/@edit)

let $response :=
 
   (:check if user is authorized:)
   if ($edit) then
      let $descId :=
      (:check if a Snomed ID should be generated:)
      if (string-length($translation/@id)=0) then
         snomed:generateSCTID(xs:integer('1000146'),xs:integer('11'))
      else($translation/@id)
      let $effectiveTime := datetime:format-date(current-date(),"yyyy-MM-dd")
      let $preparedDesc :=
         <desc id="{$descId}" effectiveTime="{$effectiveTime}" statusCode="active" count="{count(tokenize($translation/text(),'\s'))}" length="{string-length($translation/text())}">
         {
         $translation/@*[not(name()=('count','length','statusCode','id','effectiveTime'))],
         $translation/text()
         }
         </desc>
       return
       (
       update replace $storedDesc with $preparedDesc,
       update value $storedDescription/@id with $descId,
       update value $storedDescription/@effectiveTime with $effectiveTime,
       update value $storedDescription/@statusCode with 'active',
       update value $storedDescription//@active with '1',
       <response>OK</response>
       )
   else(<member>NO PERMISSION</member>)
return
$response