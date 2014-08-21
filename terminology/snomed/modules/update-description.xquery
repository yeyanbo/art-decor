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

let $editedDesc := request:get-data()/desc

let $storedDesc      := collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//desc[@uuid=$editedDesc/@uuid]
let $storedDescription      := collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))//description[@uuid=$editedDesc/@uuid]

let $user         := xmldb:get-current-user()
let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref='extension']
let $edit         := xs:boolean($project/author[@username=$user]/@edit)

let $preparedDesc :=
         <desc count="{count(tokenize($editedDesc/text(),'\s'))}" length="{string-length($editedDesc/text())}">
         {
         $editedDesc/@*[not(name()=('count','length'))],
         $editedDesc/text()
         }
         </desc>


let $response :=
   (:check if user is authorized:)
   if ($edit) then
       (
       update replace $storedDesc[@statusCode='draft'] with $preparedDesc,
       update value $storedDescription[@statusCode='draft']/@count with $preparedDesc/@count,
       update value $storedDescription[@statusCode='draft']/@length with $preparedDesc/@length,
       update value $storedDescription[@statusCode='draft']/desc with $preparedDesc/text(),
       <response>OK</response>
       )
   else(<member>NO PERMISSION</member>)
return
$response