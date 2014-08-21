xquery version "1.0";

(:
	Copyright (C) 2012 Art Decor Expert group, www.art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace art ="http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
(:let $language := request:get-parameter('lang','nl-NL'):)
(:let $language := 'nl-NL':)
let $icaMapping := collection(concat($get:strTerminologyData,'/ica-data/concepts'))//cics

let $updatedMapping := 
<cics>
{
for $ci in $icaMapping/ci
   return
   <ci id="{$ci/@id}" statusCode="{if ($ci/@statusCode='deprecated') then 'retired' else $ci/@statusCode}" effectiveDate="" expirationDate="" editDate="">
      {
      $ci/text,
      $ci/description,
      $ci/rationale
      ,
      for $cic in $ci/cic
      return
      <cic id="{util:uuid()}" code="{$cic/@code}" statusCode="draft" effectiveDate="" expirationDate="" editDate="">
         <desc>{$cic/text()}</desc>
      </cic>
      ,
      for $icpc in $ci/icpc
      return
      <icpc id="{util:uuid()}" code="{$icpc/@code}" statusCode="draft" effectiveDate="" expirationDate="" editDate="">
         <desc>{$icpc/text()}</desc>
      </icpc>
            ,
      for $icd-9 in $ci/icd-9
      return
      <icd-9 id="{util:uuid()}" code="{$icd-9/@code}" statusCode="draft" effectiveDate="" expirationDate="" editDate="">
         <desc>{$icd-9/text()}</desc>
      </icd-9>
            ,
      for $icd-10 in $ci/icd-10
      return
      <icd-10 id="{util:uuid()}" code="{$icd-10/@code}" statusCode="draft" effectiveDate="" expirationDate="" editDate="">
         <desc>{$icd-10/text()}</desc>
      </icd-10>
      ,
      for $snomed in $ci/snomed
      return
      <snomed id="{util:uuid()}" code="{$snomed/@code}" statusCode="draft" effectiveDate="" expirationDate="" editDate="">
         <desc>{$snomed/text()}</desc>
      </snomed>
      ,
      for $other in $ci/other
      return
      <shb-ci id="{util:uuid()}" code="{$other/@code}" statusCode="draft" effectiveDate="" expirationDate="" editDate="">
         <desc>{$other/text()}</desc>
      </shb-ci>
      }
   </ci>
}
</cics>
return
$updatedMapping