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
          let $string := if ($rowColumn/@type='string') then concat('"',$rowColumn/text(),'"') else if (string-length($rowColumn)=0) then '' else $rowColumn/text()
          return
          $string
                   ,',')
         ,'&#13;&#10;')
       )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$collection),$fileName,string-join($file,''),'text/csv')
   
};

let $date := '20131226'
let $createColletion :=
   if (not(xmldb:collection-available(concat($get:strTerminologyData,'/dhd-data/releases/',$date)))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/dhd-data/releases'),$date)
   else()
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus

let $htThesaurus :=
   <HT_Thesaurus count="{count($thesaurus/concept[@statusCode='final'])}">
   {
      for $concept in $thesaurus/concept[@statusCode='final']
      let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($concept/@thesaurusId))),$concept/@thesaurusId)
      let $linkId := if (string-length($concept/@idLink) gt 0) then concat(substring('0000000000',1,(10 - string-length($concept/@idLink))),$concept/@idLink) else ''
      let $refTerm := if ($concept/desc[@type='pref']) then $concept/desc[@type='pref'] else $concept/desc[1]
      order by xs:integer($concept/@no)
      return
      <row>
         <ID_Thesaurus type="string">{$thesaurusId}</ID_Thesaurus>
         <ReferentieTerm type="string">{$refTerm/text()}</ReferentieTerm>
         <ID_Snomed type="string">{$concept/snomed/@conceptId/string()}</ID_Snomed>
         <Snomed_omschrijving type="string">{$concept/snomed/desc/text()}</Snomed_omschrijving>
         <Begindatum type="date">{replace($concept/@effectiveDate,'-','')}</Begindatum>
         <Einddatum type="date">{replace($concept/@expirationDate,'-','')}</Einddatum>
         <Mutatiedatum type="date">{replace($concept/@editDate,'-','')}</Mutatiedatum>
         <ID_Nieuw_concept type="string">{$linkId}</ID_Nieuw_concept>
      </row>
   }
   </HT_Thesaurus>
let $htInterface :=
   <HT_Interface count="{count($thesaurus//desc[@statusCode='final'])}">
   {
   for $desc in $thesaurus/concept/desc[@statusCode='final']
   let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($desc/parent::concept/@thesaurusId))),$desc/parent::concept/@thesaurusId)
   let $interfaceId := concat(substring('0000000000',1,(10 - string-length($desc/@interfaceId))),$desc/@interfaceId)
   order by xs:integer($desc/@no)
   return
   <row>
      <ID_Thesaurus>{$thesaurusId}</ID_Thesaurus>
      <ID_Interface>{$interfaceId}</ID_Interface>
      <InterfaceTerm>{$desc/text()}</InterfaceTerm>
      <Begindatum type="date">{replace($desc/@effectiveDate,'-','')}</Begindatum>
      <Einddatum type="date">{replace($desc/@expirationDate,'-','')}</Einddatum>
      <Mutatiedatum type="date">{replace($desc/@editDate,'-','')}</Mutatiedatum>
   </row>
   }
   </HT_Interface>
let $rtICD :=
   <RT_ICD10>
   {
   for $icd in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/icdReference/icd[@statusCode='final']
   order by xs:integer($icd/@no)
   return
   <row>
      <ICD10_Code>{$icd/@codeStripped/string()}</ICD10_Code>
      <ICD10_Code_Dotted>{$icd/@code/string()}</ICD10_Code_Dotted>
      <Diagnoseypering>{$icd/desc/text()}</Diagnoseypering>
      <Begindatum type="date">{replace($icd/@effectiveDate,'-','')}</Begindatum>
      <Einddatum type="date">{replace($icd/@expirationDate,'-','')}</Einddatum>
      <Mutatiedatum type="date">{replace($icd/@editDate,'-','')}</Mutatiedatum>
   </row>
   }
   </RT_ICD10>
   
let $ktICD :=
   <KT_ICD10 count="{count($thesaurus//icd10[@statusCode=('draft','final')])}">
   {
   for $icd in $thesaurus//icd10[@statusCode=('draft','final')]
   let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($icd/parent::concept/@thesaurusId))),$icd/parent::concept/@thesaurusId)
   order by xs:integer($icd/@no)
   return
   <row>
      <ID_Thesaurus>{$thesaurusId}</ID_Thesaurus>
      <ICD10_Code>{$icd/@codeStripped/string()}</ICD10_Code>
      <ICD10_Code_Dotted>{$icd/@code/string()}</ICD10_Code_Dotted>
      <Volgorde>{$icd/@priority/string()}</Volgorde>
      <Begindatum type="date">{replace($icd/@effectiveDate,'-','')}</Begindatum>
      <Einddatum type="date">{replace($icd/@expirationDate,'-','')}</Einddatum>
      <Mutatiedatum type="date">{replace($icd/@editDate,'-','')}</Mutatiedatum>
      <Validatiestatus>{$icd/@validated}</Validatiestatus>
      <Validatiedatum type="date">{replace($icd/@validationDate,'-','')}</Validatiedatum>
   </row>
   }
   </KT_ICD10>
   
let $rtDBC :=
   <RT_DBC_diagnose count="{count(collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/dbcReference/dbc[@statusCode=('draft','final')])}">
   {
   for $dbc in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/dbcReference/dbc[@statusCode='final']
   order by xs:integer($dbc/@no)
   return
   <row>
      <SpecialismeCode type="string">{$dbc/@specialismCode/string()}</SpecialismeCode>
      <DiagnoseTypering type="string">{$dbc/@code/string()}</DiagnoseTypering>
      <DiagnoseOms type="string">{$dbc/desc/text()}</DiagnoseOms>
      <DiagnoseOmsKort type="string">{$dbc/descShort/text()}</DiagnoseOmsKort>
      <Begindatum type="date">{replace($dbc/@effectiveDate,'-','')}</Begindatum>
      <Einddatum type="date">{replace($dbc/@expirationDate,'-','')}</Einddatum>
      <Mutatiedatum type="date">{replace($dbc/@editDate,'-','')}</Mutatiedatum>
   </row>
   }
   </RT_DBC_diagnose>
   
let $ktDBC :=
   <KT_DBC_diagnose count="{count($thesaurus//dbc[@statusCode=('draft','final')])}">
         {
   for $dbc in $thesaurus//dbc[@statusCode=('draft','final')]
   let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($dbc/parent::concept/@thesaurusId))),$dbc/parent::concept/@thesaurusId)
   order by xs:integer($dbc/@no)
   return
   <row>
      <ID_Thesaurus type="string">{$thesaurusId}</ID_Thesaurus>
      <SpecialismeCode type="string">{$dbc/@specialismCode/string()}</SpecialismeCode>
      <DiagnoseTypering type="string">{$dbc/@code/string()}</DiagnoseTypering>
      <Begindatum type="date">{replace($dbc/@effectiveDate,'-','')}</Begindatum>
      <Einddatum type="date">{replace($dbc/@expirationDate,'-','')}</Einddatum>
      <Mutatiedatum type="date">{replace($dbc/@editDate,'-','')}</Mutatiedatum>
      <Validatiestatus>{$dbc/@validated}</Validatiestatus>
      <Validatiedatum type="date">{replace($dbc/@validationDate,'-','')}</Validatiedatum>
   </row>
   }
   </KT_DBC_diagnose>

let $spec :=
   <RT_Specialisme>
   {
   for $spec in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/specialismReference/specialism
   order by xs:integer($spec/@no)
   return
   <row>
      <SpecialismeCode>{$spec/@specialismCode}</SpecialismeCode>
      <SpecialismeKort type="string">{$spec/descShort/text()}</SpecialismeKort>
      <Specialisme type="string">{$spec/desc/text()}</Specialisme>
   </row>
   }
   </RT_Specialisme>
   

return
(
local:save-as-csv($htThesaurus,$date),
local:save-as-csv($htInterface,$date),
local:save-as-csv($rtDBC,$date),
local:save-as-csv($rtICD,$date),
local:save-as-csv($ktDBC,$date),
local:save-as-csv($ktICD,$date),
local:save-as-csv($spec,$date)
)


