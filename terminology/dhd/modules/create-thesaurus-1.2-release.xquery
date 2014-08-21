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
declare function local:save-HT_Thesaurus-as-csv($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_HT_Thesaurus.csv')
   let $file :=
      (
         concat('"ID_Thesaurus"',',','"ReferentieTerm"',',','"ID_Snomed"',',','"Snomed_omschrijving"',',','"Kenmerk"',',','"Begindatum"',',','"Einddatum"',',','"MutatieDatum"',',','"Mutatiecode"','&#13;&#10;')
         ,
         for $concept in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//concept[@statusCode=('pending','active','retired')]
      let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($concept/@thesaurusId))),$concept/@thesaurusId)
      let $refTerm := if ($concept/desc[@type='pref']) then $concept/desc[@type='pref'][1] else $concept/desc[1]
      let $editCode:= if (string-length($concept/@editCode) gt 0) then 'GEWIJZIGD' else()
      let $expirationDate := if(string-length($concept/@expirationDate)=0) then '20991231' else replace($concept/@expirationDate,'-','')
      order by xs:integer($concept/@thesaurusId)
         return
         concat('"',$thesaurusId,'"',',','"',$refTerm/text(),'"',',','"',$concept/snomed/@conceptId/string(),'"',',','"',$concept/snomed/desc/text(),'"',',','"','','"',',',replace($concept/@effectiveDate,'-',''),',',$expirationDate,',',replace($concept/@editDate,'-',''),',','"',$editCode,'"','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-HT_Interface-as-csv($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_HT_Interface.csv')
   let $file :=
      (
         concat('"ID_Thesaurus"',',','"ID_Interface"',',','"InterfaceTerm"',',','"Begindatum"',',','"Einddatum"',',','"MutatieDatum"',',','"Mutatiecode"','&#13;&#10;')
         ,
         for $desc in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//desc[@statusCode=('pending','active','retired')]
         let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($desc/parent::concept/@thesaurusId))),$desc/parent::concept/@thesaurusId)
         let $interfaceId := concat(substring('0000000000',1,(10 - string-length($desc/@interfaceId))),$desc/@interfaceId)
         let $editCode:= if (string-length($desc/@editCode) gt 0) then 'GEWIJZIGD' else()
         let $expirationDate := if(string-length($desc/@expirationDate)=0) then '20991231' else replace($desc/@expirationDate,'-','')
         order by xs:integer($desc/@interfaceId)
         return
         concat('"',$thesaurusId,'"',',','"',$interfaceId,'"',',','"',$desc/text(),'"',',',replace($desc/@effectiveDate,'-',''),',',$expirationDate,',',replace($desc/@editDate,'-',''),',','"',$editCode,'"','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-RT_ICD10-as-csv($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_RT_ICD10.csv')
   let $file :=
      (
         concat('"ICD10_Code"',',','"DiagnoseTypering"',',','"Begindatum"',',','"Einddatum"',',','"MutatieDatum"',',','"Mutatiecode"','&#13;&#10;')
         ,
         for $icd in collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[@statusCode=('pending','active','retired')]
         let $editCode:= if (string-length($icd/@editCode) gt 0) then 'GEWIJZIGD' else()
         let $expirationDate := if(string-length($icd/@expirationDate)=0) then '20991231' else replace($icd/@expirationDate,'-','')
         order by xs:integer($icd/@no)
         return
         concat('"',$icd/@codeStripped/string(),'"',',','"',$icd/desc/text(),'"',',',replace($icd/@effectiveDate,'-',''),',',$expirationDate,',',replace($icd/@editDate,'-',''),',','"',$editCode,'"','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-KT_ICD10-as-csv($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_KT_ICD10.csv')
   let $file :=
      (
         concat('"ID_Thesaurus"',',','"ICD10_Code"',',','"Volgorde"',',','"Koppelingstype"',',','"Status"',',','"Begindatum"',',','"Einddatum"',',','"MutatieDatum"',',','"Mutatiecode"','&#13;&#10;')
         ,
         for $icd in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//icd10[@statusCode=('pending','active','retired')]
         let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($icd/parent::concept/@thesaurusId))),$icd/parent::concept/@thesaurusId)
         let $editCode:= if (string-length($icd/@editCode) gt 0) then 'GEWIJZIGD' else()
         let $expirationDate := if(string-length($icd/@expirationDate)=0) then '20991231' else replace($icd/@expirationDate,'-','')
         order by xs:integer($icd/@no)
         return
         concat('"',$thesaurusId,'"',',','"',$icd/@code/string(),'"',',','"',$icd/@priority/string(),'"',',','""',',','"',if ($icd/@validated='true') then 'GEVALIDEERD' else 'CONCEPT','"',',',replace($icd/@effectiveDate,'-',''),',',$expirationDate,',',replace($icd/@editDate,'-',''),',','"',$editCode,'"','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-RT_DBC_diagnose-as-csv($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_RT_DBC_diagnose.csv')
   let $file :=
      (
         concat('"SpecialismeCode"',',','"DiagnoseTypering"',',','"DiagnoseOms"',',','"DiagnoseOmsKort"',',','"Begindatum"',',','"Einddatum"','&#13;&#10;')
         ,
         for $dbc in collection(concat($get:strTerminologyData,'/dhd-data/reference'))/dbcReference/dbc[@statusCode=('pending','active','retired')]
         let $expirationDate := if(string-length($dbc/@expirationDate)=0) then '20991231' else replace($dbc/@expirationDate,'-','')
         order by xs:integer($dbc/@no)
         return
         concat('"',$dbc/@specialismCode/string(),'"',',','"',$dbc/@code/string(),'"',',','"',$dbc/desc/text(),'"',',','"',$dbc/descShort/text(),'"',',',replace($dbc/@effectiveDate,'-',''),',',$expirationDate,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-KT_DBC_diagnose-as-csv($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_KT_DBC_diagnose.csv')
   let $file :=
      (
         concat('"ID_Thesaurus"',',','"SpecialismeCode"',',','"DiagnoseTypering"',',','"Koppelingstype"',',','"Status"',',','"Begindatum"',',','"Einddatum"',',','"MutatieDatum"',',','"Mutatiecode"','&#13;&#10;')
         ,
         for $dbc in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//dbc[@statusCode=('pending','active','retired')]
         let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($dbc/parent::concept/@thesaurusId))),$dbc/parent::concept/@thesaurusId)
         let $editCode:= if (string-length($dbc/@editCode) gt 0) then 'GEWIJZIGD' else()
         let $expirationDate := if(string-length($dbc/@expirationDate)=0) then '20991231' else replace($dbc/@expirationDate,'-','')
         order by xs:integer($dbc/@no)
         return
         concat('"',$thesaurusId,'"',',','"',$dbc/@specialismCode/string(),'"',',','"',$dbc/@code/string(),'"',',','""',',','"',if ($dbc/@validated='true') then 'GEVALIDEERD' else 'CONCEPT','"',',',replace($dbc/@effectiveDate,'-',''),',',$expirationDate,',',replace($dbc/@editDate,'-',''),',','"',$editCode,'"','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-KT_Domeinen-as-csv($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_KT_Domeinen.csv')
   let $file :=
      (
         concat('"ID_Thesaurus"',',','"SpecialismeCode"',',','"SubSpecialismeKort"',',','"Begindatum"',',','"Einddatum"',',','"MutatieDatum"',',','"Mutatiecode"','&#13;&#10;')
         ,
         for $specialism in collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//specialism[@statusCode=('draft','pending','active','retired')]
         let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($specialism/parent::concept/@thesaurusId))),$specialism/parent::concept/@thesaurusId)
         let $editCode:= if (string-length($specialism/@editCode) gt 0) then 'GEWIJZIGD' else()
         let $expirationDate := if(string-length($specialism/@expirationDate)=0) then '20991231' else replace($specialism/@expirationDate,'-','')
         order by xs:integer($specialism/@no)
         return
         concat('"',$thesaurusId,'"',',','"',$specialism/@specialismCode/string(),'"',',','"',$specialism/@subspecialismShort/string(),'"',',',replace($specialism/@effectiveDate,'-',''),',',$expirationDate,',',replace($specialism/@editDate,'-',''),',','"',$editCode,'"','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-RT_Specialisme-as-csv($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_RT_Specialisme.csv')
   let $file :=
      (
         concat('"SpecialismeCode"',',','"SpecialismeKort"',',','"Specialisme"',',','"SubSpecialismeKort"',',','"SubSpecialismeOms"','&#13;&#10;')
         ,
         for $specialism in collection(concat($get:strTerminologyData,'/dhd-data/legacy'))//specialism[@statusCode=('pending','active','retired')]
         let $expirationDate := if(string-length($specialism/@expirationDate)=0) then '20991231' else replace($specialism/@expirationDate,'-','')
         order by xs:integer($specialism/@no)
         return
         concat('"',$specialism/@specialismCode,'"',',','"',$specialism/descShort/text(),'"',',','"',$specialism/desc/text(),'"',',','"',$specialism/subDescShort/text(),'"',',','"',$specialism/subDesc/text(),'"','&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};



let $newRelease := request:get-data()/release
(:let $newRelease :=
<release effectiveTime="2014-01-18T17:07:59.111+01:00" statusCode="draft" label="test4">
</release>:)

let $dateTime := $newRelease/@effectiveTime
let $releasePrefix :=
   if ($dateTime castable as xs:dateTime) then
      concat(datetime:format-dateTime($dateTime,'yyyyMMdd_HHmmss'),'_versie1.2')
   else (concat(datetime:format-dateTime(current-dateTime(),'yyyyMMdd_HHmmss'),'_versie1.2'))
   
let $createColletion :=
   if (not(xmldb:collection-available(concat($get:strTerminologyData,'/dhd-data/releases/',$releasePrefix)))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/dhd-data/releases'),$releasePrefix)
   else()
 
return
<response>
{
(
   (:$htThesaurus:)
   local:save-HT_Thesaurus-as-csv($releasePrefix),
   local:save-HT_Interface-as-csv($releasePrefix),
   local:save-RT_ICD10-as-csv($releasePrefix),
   local:save-KT_ICD10-as-csv($releasePrefix),
   local:save-RT_DBC_diagnose-as-csv($releasePrefix),
   local:save-KT_DBC_diagnose-as-csv($releasePrefix),
   local:save-KT_Domeinen-as-csv($releasePrefix),
   local:save-RT_Specialisme-as-csv($releasePrefix)
)
}
</response>

