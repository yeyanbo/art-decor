xquery version "3.0";
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
import module namespace snomed ="http://art-decor.org/ns/terminology/snomed" at "../api/api-snomed.xqm";

let $refset := request:get-data()/refset
(:let $refset :=
<refset defaultLanguage="nl-NL">
<name language="nl-NL">test</name>
<synonym>test</synonym>
<fsn>test (foundation metadata concept)</fsn>
</refset>:)

let $extensionProject := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref='extension']
let $user           := xmldb:get-current-user()
let $admin         := xs:boolean($extensionProject/author[@username=$user]/@admin)
let $author :=$extensionProject/author[@username=$user]
let $moduleId :='11000146104'

let $newRefset :=
   if ($admin) then
       (:create required id's:)
       let $conceptId := snomed:generateSCTID(xs:integer('1000146'),xs:integer('10'))
       let $conceptUuid :=util:uuid()
       let $descSynId := snomed:generateSCTID(xs:integer('1000146'),xs:integer('11'))
       let $descFsnId := snomed:generateSCTID(xs:integer('1000146'),xs:integer('11'))
       let $relationId := snomed:generateSCTID(xs:integer('1000146'),xs:integer('12'))
       let $effectiveTime :=datetime:format-date(current-date(),"yyyy-MM-dd")
       (:create refset project with current user as admin:)
       let $project :=
          <project ref="{$conceptId}" defaultLanguage="{$refset/@defaultLanguage}">
              <logo href=""></logo>
              <name language="{$refset/name/@language}">{$refset/name/text()}</name>
              <desc language="{$refset/@defaultLanguage}"/>
              {$author}
              <refsetDescriptor id="{util:uuid()}"	effectiveTime="{$effectiveTime}"	active="1"	moduleId="{$moduleId}"	refsetId="900000000000456007"	referencedComponentId="{$conceptId}"	attributeDescription="449608002"	attributeType="900000000000461009"	attributeOrder="0"/>
          </project>
       (:create refset file:)
      let $refsetFile :=
         <refset id="{$conceptId}" moduleId="{$moduleId}" effectiveDate="{datetime:format-date(current-date(),"yyyy-MM-dd")}"/>
       (:create refset concept with descriptions and refset membership:)
       let $concept :=
         <concept uuid="{$conceptUuid}" conceptId="{$conceptId}" statusCode="active" effectiveTime="{$effectiveTime}" active="1" moduleId="11000146104" definitionStatusId="900000000000074008">
            <desc uuid="{util:uuid()}" type="syn" statusCode="active" count="{count(tokenize($refset/synonym,'\s'))}" length="{string-length($refset/synonym)}" id="{$descSynId}" effectiveTime="{$effectiveTime}" active="1" moduleId="11000146104" conceptId="{$conceptId}" languageCode="en" typeId="900000000000013009" term="{$refset/synonym/text()}" caseSignificanceId="900000000000017005">{$refset/synonym/text()}</desc>
            <desc uuid="{util:uuid()}" type="fsn" statusCode="active" count="{count(tokenize($refset/fsn,'\s'))}" length="{string-length($refset/fsn)}" id="{$descFsnId}" effectiveTime="{$effectiveTime}" active="1" moduleId="11000146104" conceptId="{$conceptId}" languageCode="en" typeId="900000000000003001" term="{$refset/fsn/text()}" caseSignificanceId="900000000000017005">{$refset/fsn/text()}</desc>
            <src uuid="{util:uuid()}" type="Is a" statusCode="active" id="{$relationId}" effectiveTime="{$effectiveTime}" active="1" moduleId="11000146104" sourceId="{$conceptId}" destinationId="446609009" relationshipGroup="0" typeId="116680003" characteristicTypeId="900000000000011007" modifierId="900000000000451002">Simple type reference set</src>
            <refset uuid="{$conceptUuid}" effectiveTime="{$effectiveTime}" active="1"	 moduleId="11000146104"	refsetId="900000000000456007" refset="RefsetDescriptorDutchExtension"	referencedComponentId="{$conceptId}"	attributeDescription="449608002"	attributeType="900000000000461009"	attributeOrder="0"/>
         </concept>
       let $stores :=
         (
         update insert $project into collection(concat($get:strTerminologyData,'/snomed-extension/meta'))/projects,
         update insert $concept into collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))/concepts,
         for $desc in $concept//desc
          let $active := if ($desc/@statusCode='active') then '1' else '0'
          let $acceptability := if ($desc/@type='pref') then '900000000000548007' else '900000000000549004'
          let $languageRefsetId:= if ($desc/@languageCode='en') then '900000000000509007' else '31000146106'
          let $description :=
            <description  uuid="{$desc/@uuid}"  id="{$desc/@id}" soId="{$desc/@soId}" effectiveTime="{$effectiveTime}" statusCode="{$desc/@statusCode}" type="{$desc/@type}" count="{$desc/@count}" length="{$desc/@length}" active="{$desc/@active}" moduleId="{$desc/@moduleId}" conceptId="{$desc/parent::concept/@conceptId}" languageCode="{$desc/@languageCode}" typeId="{$desc/@typeId}" caseSignificanceId="{$desc/@caseSignificanceId}">
               <desc>{$desc/text()}</desc>
               <languageRefset  id="{$desc/@uuid}" effectiveTime="{$effectiveTime}" active="{$active}" moduleId="{$moduleId}" languageRefsetId="{$languageRefsetId}" acceptabilityId="{$acceptability}"/>
            </description>
         return
         update insert $description into collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))/descriptions
         ,
         xmldb:store(concat($get:strTerminologyData,'/snomed-extension/refsets'),concat(xs:string($conceptId),'.xml'),$refsetFile)
         )
       return
      $concept
   else('NO PERMISSION')


return
$newRefset