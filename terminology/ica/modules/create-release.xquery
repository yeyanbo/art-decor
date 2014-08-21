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



declare function local:save-SHB-CI-as-txt($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_SHB-CI.txt')
   let $file :=
      (
         concat('Id','&#9;','CiCode','&#9;','CiTekst','&#9;','SHBCi_Code','&#9;','SHBCiTekst','&#9;','Begindatum','&#9;','Einddatum','&#9;','Mutatiedatum','&#13;&#10;')
         ,
         for $shb-ci in collection(concat($get:strTerminologyData,'/ica-data/concepts'))//shb-ci[@statusCode=('pending','active','retired')]
         let $expirationDate := if(string-length($shb-ci/@expirationDate)=0) then '2099-12-31' else $shb-ci/@expirationDate
         return
         concat($shb-ci/@id,'&#9;',$shb-ci/parent::ci/cic/@code,'&#9;',$shb-ci/parent::ci/cic/desc,'&#9;',$shb-ci/@code,'&#9;',$shb-ci/desc,'&#9;',$shb-ci/@effectiveDate,'&#9;',$expirationDate,'&#9;',$shb-ci/@editDate,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/ica-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};

declare function local:save-ICPC-as-txt($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_ICPC.txt')
   let $file :=
      (
         concat('Id','&#9;','CiCode','&#9;','CiTekst','&#9;','ICPCCode','&#9;','ICPCTekst','&#9;','Begindatum','&#9;','Einddatum','&#9;','Mutatiedatum','&#13;&#10;')
         ,
         for $icpc in collection(concat($get:strTerminologyData,'/ica-data/concepts'))//icpc[@statusCode=('pending','active','retired')]
         let $expirationDate := if(string-length($icpc/@expirationDate)=0) then '2099-12-31' else $icpc/@expirationDate
         return
         concat($icpc/@id,'&#9;',$icpc/parent::ci/cic/@code,'&#9;',$icpc/parent::ci/cic/desc,'&#9;',$icpc/@code,'&#9;',$icpc/desc,'&#9;',$icpc/@effectiveDate,'&#9;',$expirationDate,'&#9;',$icpc/@editDate,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/ica-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};

declare function local:save-ICD9-as-txt($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_ICD9.txt')
   let $file :=
      (
         concat('Id','&#9;','CiCode','&#9;','CiTekst','&#9;','ICD9Code','&#9;','ICD9Tekst','&#9;','Begindatum','&#9;','Einddatum','&#9;','Mutatiedatum','&#13;&#10;')
         ,
         for $icd9 in collection(concat($get:strTerminologyData,'/ica-data/concepts'))//icd-9[@statusCode=('pending','active','retired')]
         let $expirationDate := if(string-length($icd9/@expirationDate)=0) then '2099-12-31' else $icd9/@expirationDate
         return
         concat($icd9/@id,'&#9;',$icd9/parent::ci/cic/@code,'&#9;',$icd9/parent::ci/cic/desc,'&#9;',$icd9/@code,'&#9;',$icd9/desc,'&#9;',$icd9/@effectiveDate,'&#9;',$expirationDate,'&#9;',$icd9/@editDate,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/ica-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};

declare function local:save-ICD10-as-txt($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_ICD10.txt')
   let $file :=
      (
         concat('Id','&#9;','CiCode','&#9;','CiTekst','&#9;','ICD10Code','&#9;','ICD10Tekst','&#9;','Begindatum','&#9;','Einddatum','&#9;','Mutatiedatum','&#13;&#10;')
         ,
         for $icd10 in collection(concat($get:strTerminologyData,'/ica-data/concepts'))//icd-10[@statusCode=('pending','active','retired')]
         let $expirationDate := if(string-length($icd10/@expirationDate)=0) then '2099-12-31' else $icd10/@expirationDate
         return
         concat($icd10/@id,'&#9;',$icd10/parent::ci/cic/@code,'&#9;',$icd10/parent::ci/cic/desc,'&#9;',$icd10/@code,'&#9;',$icd10/desc,'&#9;',$icd10/@effectiveDate,'&#9;',$expirationDate,'&#9;',$icd10/@editDate,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/ica-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-SNOMED-CT-as-txt($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'_SNOMED-CT.txt')
   let $file :=
      (
         concat('Id','&#9;','CiCode','&#9;','CiTekst','&#9;','SNOMED-CTCode','&#9;','SNOMED-CTTekst','&#9;','Begindatum','&#9;','Einddatum','&#9;','Mutatiedatum','&#13;&#10;')
         ,
         for $snomed in collection(concat($get:strTerminologyData,'/ica-data/concepts'))//snomed[@statusCode=('pending','active','retired')]
         let $expirationDate := if(string-length($snomed/@expirationDate)=0) then '2099-12-31' else $snomed/@expirationDate
         return
         concat($snomed/@id,'&#9;',$snomed/parent::ci/cic/@code,'&#9;',$snomed/parent::ci/cic/desc,'&#9;',$snomed/@code,'&#9;',$snomed/desc,'&#9;',$snomed/@effectiveDate,'&#9;',$expirationDate,'&#9;',$snomed/@editDate,'&#13;&#10;')
         )
   return
   xmldb:store(concat($get:strTerminologyData,'/ica-data/releases/',$releasePrefix),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   
};
declare function local:save-XML($releasePrefix as xs:string) as xs:string {
   let $fileName := concat($releasePrefix,'.xml')
   let $file :=
         <cics>
         {
         for $ci in collection(concat($get:strTerminologyData,'/ica-data/concepts'))//ci[@statusCode=('pending','active','retired')]
         return
         $ci
         }
         </cics>
   return
   xmldb:store(concat($get:strTerminologyData,'/ica-data/releases'),$fileName,$file)
   
};


let $newRelease := request:get-data()/release
(:let $newRelease :=
<release effectiveTime="2014-01-18T17:07:59.111+01:00" statusCode="draft" label="test4">
</release>:)

let $dateTime := $newRelease/@effectiveTime
let $releasePrefix :=
   if ($dateTime castable as xs:dateTime) then
      datetime:format-dateTime($dateTime,'yyyyMMdd_HHmmss')
   else (datetime:format-dateTime(current-dateTime(),'yyyyMMdd_HHmmss'))
   
let $createColletion :=
   if (not(xmldb:collection-available(concat($get:strTerminologyData,'/ica-data/releases/',$releasePrefix)))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/ica-data/releases'),$releasePrefix)
   else()
 
return
<response>
{
(
   (:$htThesaurus:)
   local:save-SHB-CI-as-txt($releasePrefix),
   local:save-ICPC-as-txt($releasePrefix),
   local:save-ICD9-as-txt($releasePrefix),
   local:save-ICD10-as-txt($releasePrefix),
   local:save-SNOMED-CT-as-txt($releasePrefix),
   local:save-XML($releasePrefix)
)
}
</response>

