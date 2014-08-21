xquery version "3.0";
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
declare namespace compression="http://exist-db.org/xquery/compression";
(:declare option exist:serialize "method=text media-type=text/csv charset=utf-8";:)

declare function local:save-as-csv($element as element(), $collection as xs:string) as xs:string {
   let $fileName := concat($collection,'_',$element/name(),'.csv')
   let $file :=
      (
      concat(
         string-join(
            for $column in $element/row[1]/*
            return
            concat('"',$column/name(),'"')
         ,',')
         ,'&#13;&#10;')
       ,
       for $row in $element/row
       return
         concat(
         string-join(
          for $rowColumn in $row/*
          let $string := if ($rowColumn/@type='string') then concat('"',$rowColumn/text(),'"') else $rowColumn/text()
          return
          $string
                   ,',')
         ,'&#13;&#10;')
       )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$collection),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-as-xml($element as element(), $collection as xs:string) as xs:string {
   let $fileName := concat($collection,'_',$element/name(),'.xml')
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$collection),$fileName,$element)
};

declare function local:save-ThesaurusConcept-as-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_ThesaurusConcept.txt')
   let $file :=
      (
         concat('Complicatie','&#9;','GebruiktImplantaat','&#9;','Lateraliteit','&#9;','Begindatum','&#9;','Mutatiedatum','&#9;','Einddatum','&#9;','ConceptID','&#9;','TypeConcept','&#9;','Gradatie','&#13;&#10;')
         ,
         for $concept in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@statusCode=('pending','active','retired')][string-length(snomed/@conceptId) gt 0]
         let $linkId := if (string-length($concept/@idLink) gt 0) then concat(substring('0000000000',1,(10 - string-length($concept/@idLink))),$concept/@idLink) else ''
         let $expirationDate := if(string-length($concept/@expirationDate)=0) then '20991231' else datetime:format-date($concept/@expirationDate,'yyyyMMdd')
         return
         concat(if ($concept/@complication='true') then '1' else '0','&#9;',if ($concept/@implant='true') then '1' else '0','&#9;',if ($concept/@laterality='true') then '1' else '0','&#9;',datetime:format-date($concept/@effectiveDate,'yyyyMMdd'),'&#9;',datetime:format-date($concept/@editDate,'yyyyMMdd'),'&#9;',$expirationDate,'&#9;',$concept/snomed/@conceptId/string(),'&#9;',$concept/@type,'&#9;',if ($concept/@severity='true') then '1' else '0','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};

declare function local:save-ConceptRelaties-as-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_ConceptRelaties.txt')
   let $file :=
      (
         concat('ConceptID1','&#9;','ConceptID2','&#9;','TypeRelatie','&#13;&#10;')
         ,
         for $concept in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@statusCode=('pending','active','retired')][string-length(snomed/@conceptId) gt 0][string-length(@idLink) gt 0]
         let $linkedConceptId := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@thesaurusId=$concept/@idLink]/snomed/@conceptId
         return
         concat($concept/snomed/@conceptId,'&#9;',$linkedConceptId,'&#9;','vervanging','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};

declare function local:save-Afleiding-as-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_Afleiding.txt')
   let $file :=
      (
         concat('Advies','&#9;','Logica','&#9;','Begindatum','&#9;','Mutatiedatum','&#9;','Einddatum','&#9;','AutorisatieBegindatum','&#9;','AutorisatieEinddatum','&#9;','SpecialismeCode','&#9;','AfleidingID','&#9;','ConceptID','&#13;&#10;')
         ,
         for $mapping in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//icd10[@statusCode=('pending','active','retired')][string-length(parent::concept/snomed/@conceptId) gt 0]
         let $expirationDate := if(string-length($mapping/@expirationDate)=0) then '20991231' else datetime:format-date($mapping/@expirationDate,'yyyyMMdd')
         return
         concat($mapping/advice/text(),'&#9;',$mapping/rule/text(),'&#9;',datetime:format-date($mapping/@effectiveDate,'yyyyMMdd'),'&#9;',if ($mapping/@editDate castable as xs:date) then datetime:format-date($mapping/@editDate,'yyyyMMdd') else '','&#9;',
         $expirationDate,'&#9;',if ($mapping/@validationDate castable as xs:date) then datetime:format-date($mapping/@validationDate,'yyyyMMdd') else '','&#9;',
         if ($mapping/@validationEndDate castable as xs:date) then datetime:format-date($mapping/@validationEndDate,'yyyyMMdd') else '','&#9;',$mapping/@agbCode,'&#9;',$mapping/@no,'&#9;',$mapping/parent::concept/snomed/@conceptId/string(),'&#13;&#10;')
         ,
         for $mapping in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//dbc[@statusCode=('pending','active','retired')][string-length(parent::concept/snomed/@conceptId) gt 0]
         let $expirationDate := if(string-length($mapping/@expirationDate)=0) then '20991231' else datetime:format-date($mapping/@expirationDate,'yyyyMMdd')
         return
         concat($mapping/advice/text(),'&#9;',$mapping/rule/text(),'&#9;',datetime:format-date($mapping/@effectiveDate,'yyyyMMdd'),'&#9;',if ($mapping/@editDate castable as xs:date) then datetime:format-date($mapping/@editDate,'yyyyMMdd') else '','&#9;',
         $expirationDate,'&#9;',if ($mapping/@validationDate castable as xs:date) then datetime:format-date($mapping/@validationDate,'yyyyMMdd') else '','&#9;',
         if ($mapping/@validationEndDate castable as xs:date) then datetime:format-date($mapping/@validationEndDate,'yyyyMMdd') else '','&#9;',$mapping/@agbCode,'&#9;',$mapping/@no,'&#9;',$mapping/parent::concept/snomed/@conceptId/string(),'&#13;&#10;')
        )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};

declare function local:save-KoppelTabel-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_KoppelTabel.txt')
   let $file :=
      (
         concat('AfleidingID','&#9;','BronConceptID','&#13;&#10;')
         ,
         for $mapping in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//icd10[@statusCode=('pending','active','retired')][string-length(parent::concept/snomed/@conceptId) gt 0]
         return
         concat($mapping/@no,'&#9;',$mapping/@code,'&#13;&#10;')
         ,
         for $mapping in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//dbc[@statusCode=('pending','active','retired')][string-length(parent::concept/snomed/@conceptId) gt 0]
         return
         concat($mapping/@no,'&#9;',concat($mapping/@agbCode,$mapping/@code),'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};


declare function local:save-Term-as-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_Term.txt')
   let $file :=
      (
         concat('Omschrijving','&#9;','Begindatum','&#9;','Mutatiedatum','&#9;','Einddatum','&#9;','TermID','&#9;','ConceptID','&#9;','TaalCode','&#9;','TypeTerm','&#9;','&#13;&#10;')
         ,
         for $desc in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//desc[@statusCode=('pending','active','retired')][string-length(parent::concept/snomed/@conceptId) gt 0]
         let $expirationDate := if(string-length($desc/@expirationDate)=0) then '20991231' else datetime:format-date($desc/@expirationDate,'yyyyMMdd')
         let $type := if ($desc/@type='pref') then 'voorkeursterm'  else if ($desc/@type='fsn') then 'fsn' else 'synoniem'
         order by xs:integer($desc/@interfaceId)
         return
         concat($desc/text(),'&#9;',datetime:format-date($desc/@effectiveDate,'yyyyMMdd'),'&#9;',if ($desc/@editDate castable as xs:date) then datetime:format-date($desc/@editDate,'yyyyMMdd') else '','&#9;',$expirationDate,'&#9;',$desc/@interfaceId,'&#9;',$desc/parent::concept/snomed/@conceptId/string(),'&#9;',$desc/@languageCode,'&#9;',$type,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};

declare function local:save-BronConcept-as-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_BronConcept.txt')
   let $file :=
      (
         concat('Omschrijving','&#9;','BronConceptID','&#9;','BronStelselID','&#9;','BronVersieID','&#9;','&#13;&#10;')
         ,
         for $mapping in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//icd10[@statusCode=('pending','active','retired')][string-length(parent::concept/snomed/@conceptId) gt 0]
         let $sourceConcept := collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[@code=$mapping/@code]
         return
         concat($sourceConcept/desc/text(),'&#9;',$mapping/@code,'&#9;','oid','&#9;','versie','&#13;&#10;')
         ,
         for $mapping in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//dbc[@statusCode=('pending','active','retired')][string-length(parent::concept/snomed/@conceptId) gt 0]
         let $sourceConcept := collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc[@code=$mapping/@code][@agbCode=$mapping/@agbCode]
         return
         concat($sourceConcept/desc/text(),'&#9;',concat($mapping/@agbCode,$mapping/@code),'&#9;','oid','&#9;','versie','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};



declare function local:save-Specialisme-as-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_Specialisme.txt')
   let $file :=
      (
         concat('SpecialismeOmschrijving','&#9;','SpecialismeCode','&#13;&#10;')
         ,
         for $specialism in collection(concat($get:strTerminologyData,'/dhd-data/reference'))//specialism[@statusCode=('pending','active','retired')]
         let $expirationDate := if(string-length($specialism/@expirationDate)=0) then '20991231' else replace($specialism/@expirationDate,'-','')
         order by xs:integer($specialism/@agbCode)
         return
         concat($specialism/desc/text(),'&#9;',$specialism/@agbCode,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
};

declare function local:save-TypeConcept-as-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_TypeConcept.txt')
   let $file :=
      (
         concat('TypeConceptOmschrijving','&#9;','TypeConceptCode','&#13;&#10;')
         ,
         for $type in ('Diagnose','Zorgbehoefte','@DBC','Verrichting','@ZA')
         return
         concat($type,'&#9;',$type,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
};

declare function local:save-TypeTerm-as-tabDelimited($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_TypeTerm.txt')
   let $file :=
      (
         concat('TypeTermOmschrijving','&#9;','TypeTermCode','&#13;&#10;')
         ,
         for $type in ('voorkeursterm','synoniem','lekenterm','fsn')
         return
         concat($type,'&#9;',$type,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
};

let $newRelease := request:get-data()/release
(:let $newRelease :=
<release effectiveTime="2014-07-28T13:07:59.111+01:00" statusCode="draft" label="test4">
</release>:)
let $dateTime := $newRelease/@effectiveTime
let $releasePrefix :=
   if ($dateTime castable as xs:dateTime) then
      concat(datetime:format-dateTime($dateTime,'yyyyMMdd_HHmmss'),'_versie3.0')
   else (concat(datetime:format-dateTime(current-dateTime(),'yyyyMMdd_HHmmss'),'_versie3.0'))
   
let $createCollection :=
   if (not(xmldb:collection-available(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix)))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/dhd-data/releases'),$releasePrefix)
   else()
   
return
<response>
{
(
local:save-ThesaurusConcept-as-tabDelimited($releasePrefix),
local:save-ConceptRelaties-as-tabDelimited($releasePrefix),
local:save-Term-as-tabDelimited($releasePrefix),
local:save-Afleiding-as-tabDelimited($releasePrefix),
local:save-KoppelTabel-tabDelimited($releasePrefix),
local:save-BronConcept-as-tabDelimited($releasePrefix),
local:save-Specialisme-as-tabDelimited($releasePrefix),
local:save-TypeConcept-as-tabDelimited($releasePrefix),
local:save-TypeTerm-as-tabDelimited($releasePrefix)
)
}
</response>


