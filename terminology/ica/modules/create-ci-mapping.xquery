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

let $ciId :=util:unescape-uri(request:get-parameter('ciId',('')),'UTF-8')
let $type :=util:unescape-uri(request:get-parameter('type',('')),'UTF-8')
let $code :=util:unescape-uri(request:get-parameter('code',('')),'UTF-8')
let $desc :=util:unescape-uri(request:get-parameter('desc',('')),'UTF-8')
let $codeSystemName :=util:unescape-uri(request:get-parameter('codeSystemName',('')),'UTF-8')

(: get user for permission check:)
let $user := xmldb:get-current-user()
let $project :=collection(concat($get:strTerminologyData,'/ica-data/meta'))/project
let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $currentDate :=datetime:format-date(current-date(),"yyyy-MM-dd")

let $ci := collection(concat($get:strTerminologyData,'/ica-data/concepts'))//ci[@id=$ciId]
let $response :=
   (:check if user is authorized:)
   if ($edit) then
      let $newMapping :=
         if ($type='icpc') then
            <icpc id="{util:uuid()}" code="{$code}" effectiveDate="" expirationDate="" editDate="{$currentDate}" statusCode="draft"><desc>{$desc}</desc></icpc>
         else if ($type='icd9') then
            <icd-9 id="{util:uuid()}" code="{$code}" effectiveDate="" expirationDate="" editDate="{$currentDate}" statusCode="draft"><desc>{$desc}</desc></icd-9>
         else if ($type='icd10') then
            <icd-10 id="{util:uuid()}" code="{$code}" effectiveDate="" expirationDate="" editDate="{$currentDate}" statusCode="draft"><desc>{$desc}</desc></icd-10>
         else if ($type='snomed') then
            <snomed id="{util:uuid()}" code="{$code}" effectiveDate="" expirationDate="" editDate="{$currentDate}" statusCode="draft"><desc>{$desc}</desc></snomed>
         else if ($type='shb-ci') then
            <shb-ci id="{util:uuid()}" code="{$code}" effectiveDate="" expirationDate="" editDate="{$currentDate}" statusCode="draft"><desc>{$desc}</desc></shb-ci>
         else()
       return
       (
       update insert $newMapping into $ci,
       update value $ci/@editDate with  datetime:format-date(current-date(),"yyyy-MM-dd"),
       $newMapping
       )
   else(<concept>NO PERMISSION</concept>)
return
$response