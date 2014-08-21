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

let $editedMapping := request:get-data()/*

let $storedMapping:= collection(concat($get:strTerminologyData,'/ica-data/concepts'))//ci/*[@id=$editedMapping/@id]

(: get user for permission check:)
let $user := xmldb:get-current-user()
let $project :=collection(concat($get:strTerminologyData,'/ica-data/meta'))/project
let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $okForEdit := $storedMapping[@statusCode=('draft','update') or name()='cic']
let $response :=
   (:check if user is authorized:)
   if ($edit and $okForEdit) then
       (
       if ($storedMapping/@code != $editedMapping/@code or $storedMapping/text() != $editedMapping/text() or empty($storedMapping/text())) then
          (
          update replace $storedMapping with $editedMapping,
          update value $storedMapping/@editDate with  datetime:format-date(current-date(),"yyyy-MM-dd"),
          update value $storedMapping/parent::ci/@editDate with  datetime:format-date(current-date(),"yyyy-MM-dd")
          )
       else(),
       <response>OK</response>
       )
   else(<member>NO PERMISSION</member>)
return
$response