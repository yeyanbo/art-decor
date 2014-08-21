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

let $translation := request:get-data()/desc
(:let $translation :=
<desc count="1" length="14" statusCode="draft" type="syn" id="2b301b2d-d2cf-4698-a82b-40eb5f6d544b" effectiveTime="2013-10-28+01:00" moduleId="900000000000207008" languageCode="nl" typeId="900000000000013009" caseSignificanceId="900000000000020002">pupilafwijking</desc>:)

let $storedDesc:= collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//desc[@id=$translation/@id][1]
let $conceptId := $storedDesc/../concept/@conceptId

let $options := 
   <options>
   	<filter-rewrite>yes</filter-rewrite>
   </options>
let $query := 
   <query>
      <bool>
      {
       for $term in tokenize($translation,'\s')
       return
          <term occur="must">{lower-case($term)}</term>
      }
      </bool>
   </query>

let $existingDesc :=
  collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//desc[ft:query(.,$query,$options)][@count=$translation/@count]|
  collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//desc[ft:query(.,$query,$options)][@count=$translation/@count][@memberId]

let $duplicateDesc :=
   for $desc in $existingDesc[matches(@id,'^[0-9]+$')][text()=$translation/text()]
   let $concept :=
      $desc/concept|$desc/../concept
   where $concept/@conceptId=$conceptId
   return
   <desc conceptId="{$concept/@conceptId}" conceptFsn="{$concept/desc[@type='fsn']}" refset="{$desc/ancestor::refsetProject/project/name[1]}">
   {$desc/@*,$desc/text()}
   </desc>

return
<duplicates>
{$duplicateDesc}
</duplicates>