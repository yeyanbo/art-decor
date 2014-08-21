xquery version "3.0";

(:
	Copyright (C) 2014 Art Decor Expert group, www.art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
(:declare option exist:serialize "method=xml media-type=text/xml";:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";

let $id := request:get-parameter('id','')
let $language := 'nl-NL'
let $ci := collection(concat($get:strTerminologyData,'/ica-data/concepts'))//ci[@id=$id]
let $response :=
   if ($ci) then
      let $history := count(collection(concat($get:strTerminologyData,'/ica-data/history'))//ci[@id=$id])
      return
      <ci history="{$history}">
      {
      $ci/@*,
      for $desc in $ci/description
      return
      art:serializeNode($desc)
      ,
      for $rationale in $ci/rationale
      return
      art:serializeNode($rationale)
      ,
      $ci/text,
      $ci/cic,
      for $icpc in  $ci/icpc
      order by $icpc/@code
      return
      $icpc
      ,
      for $icd9 in $ci/icd-9
      order by $icd9/@code
      return
      $icd9
      ,
      for $icd10 in $ci/icd-10
      order by $icd10/@code
      return
      $icd10
      ,
      for $snomed in $ci/snomed
      order by $snomed/@code
      return
      $snomed,
      for $shb-ci in $ci/shb-ci
      order by $shb-ci/@code
      return
      $shb-ci
      }
   </ci>
   else (<ci/>)

return
$response