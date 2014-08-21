xquery version "3.0";
(:
	Copyright (C) 2011-2014 Art-Decor Expert Group
	
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

declare function local:save-as-xml($element as element(), $collection as xs:string) as xs:string {
   let $fileName := concat($collection,'_',$element/name(),'.xml')
   return
   xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases/',$collection),$fileName,$element)
};

(:
Function for creating all collections for release files
Input:
   $releasePrefix = YYYMMDD string for release
:)
declare function local:createReleaseCollections($releasePrefix as xs:string) {

   (
   if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix)))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases'),$releasePrefix)
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix),'Full')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full/Refset')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full'),'Refset')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full/Refset/Content')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full/Refset'),'Content')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full/Refset/Language')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full/Refset'),'Language')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full/Refset/Metadata')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full/Refset'),'Metadata')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full/Terminology')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Full'),'Terminology')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix),'Snapshot')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot/Refset')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot'),'Refset')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot/Refset/Content')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot/Refset'),'Content')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot/Refset/Language')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot/Refset'),'Language')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot/Refset/Metadata')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot/Refset'),'Metadata')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot/Terminology')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Snapshot'),'Terminology')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix),'Delta')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta/Refset')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta'),'Refset')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta/Refset/Content')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta/Refset'),'Content')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta/Refset/Language')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta/Refset'),'Language')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta/Refset/Metadata')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta/Refset'),'Metadata')
   else(),
      if (not(xmldb:collection-available(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta/Terminology')))) then
      xmldb:create-collection(concat($get:strTerminologyData,'/snomed-extension/releases/',$releasePrefix,'/Delta'),'Terminology')
   else()
   )

};
(:
Functions for saving RF2 ASCII TXT files
Input:
   $releaseDate         = xs:date of release
   $previousReleaseDate = xs:date of previous release
   $moduleId            =  Snomed moduleId 
   $mode                = full, snapshot or delta
:)
declare function local:save-refset-content-as-text($releaseDate as xs:date,$previousReleaseDate as xs:date,$moduleId as xs:string, $mode as xs:string) as xs:string {
      let $header := concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','refsetId','&#9;','referencedComponentId','&#13;&#10;')
      let $fileName := 
            if ($mode='full') then
               concat('der2_Refset_SimpleFull_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='snapshot') then
               concat('der2_Refset_SimpleSnapshot_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='delta') then 
               concat('der2_Refset_SimpleDelta_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else()
      let $file :=
         (
         $header,
         for $refset in collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset
         let $refsetId := $refset/@id
         let $members :=
            if ($mode=('full','snapshot')) then
               $refset/member[@statusCode=('active','retired')]
            else if ($mode='delta') then
               $refset/member[@statusCode=('active','retired')][@effectiveTime castable as xs:date][xs:date(@effectiveTime) gt $previousReleaseDate]
            else()
         return
             for $member in $members
             let $effectiveTime := concat(substring($member/@effectiveTime,1,4),substring($member/@effectiveTime,6,2),substring($member/@effectiveTime,9,2))
             let $active := if ($member/@statusCode='active') then '1' else ('0')
            return
            concat($member/@id,'&#9;',$effectiveTime,'&#9;',$active,'&#9;',$moduleId,'&#9;',$refsetId,'&#9;',$member/concept/@conceptId,'&#13;&#10;')
         )
   return
   if ($mode='full') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Full/Refset/Content'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='snapshot') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Snapshot/Refset/Content'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='delta') then 
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Delta/Refset/Content'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else('INVALID MODE')
};

declare function local:save-refset-language-as-text($releaseDate as xs:date,$previousReleaseDate as xs:date,$moduleId as xs:string,$languageRefsetId as xs:string, $mode as xs:string) as xs:string {
      let $header := concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','refsetId','&#9;','referencedComponentId','&#9;','acceptabilityId','&#13;&#10;')
      let $fileName := 
            if ($mode='full') then
               concat('der2_cRefset_LanguageFull_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='snapshot') then
               concat('der2_cRefset_LanguageSnapshot_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='delta') then 
               concat('der2_cRefset_LanguageDelta_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else()
      let $file :=
         (
         $header,
         let $descriptions :=
            if ($mode=('full','snapshot')) then
               collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))//description[@statusCode=('active','retired')]
            else if ($mode='delta') then
               collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))//description[@statusCode=('active','retired')][@effectiveTime castable as xs:date][xs:date(@effectiveTime) gt $previousReleaseDate]
            else()
         return
             for $desc in $descriptions
             return
             for $language in $desc/languageRefset
             let $effectiveTime := concat(substring($desc/@effectiveTime,1,4),substring($desc/@effectiveTime,6,2),substring($desc/@effectiveTime,9,2))
             let $active := 
               if ($desc/@statusCode='active') then 
                  '1'
               else('0')
            return
            concat($language/@id,'&#9;',$effectiveTime,'&#9;',$active,'&#9;',$language/@moduleId,'&#9;',$language/@languageRefsetId,'&#9;',$desc/@id,'&#9;',$language/@acceptabilityId,'&#13;&#10;')
         )
   return
   if ($mode='full') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Full/Refset/Language'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='snapshot') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Snapshot/Refset/Language'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='delta') then 
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Delta/Refset/Language'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else('INVALID MODE')
};

declare function local:save-refset-descriptor-as-text($releaseDate as xs:date,$previousReleaseDate as xs:date,$moduleId as xs:string, $mode as xs:string) as xs:string {
      let $fileName := 
            if ($mode='full') then
               concat('der2_cciRefset_RefsetDescriptorFull_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='snapshot') then
               concat('der2_cciRefset_RefsetDescriptorSnapshot_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='delta') then 
               concat('der2_cciRefset_RefsetDescriptorDelta_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else()
      let $refsetDescriptors :=
         if ($mode=('full','snapshot')) then
            collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project/refsetDescriptor
         else if ($mode='delta') then
            collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project/refsetDescriptor[@effectiveTime castable as xs:date][xs:date(@effectiveTime) gt $previousReleaseDate]
         else()
      let $file :=
         (
         concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','refsetId','&#9;','referencedComponentId','&#9;','attributeDescription','&#9;','attributeType','&#9;','attributeOrder','&#13;&#10;'),
         for $refsetDescriptor in $refsetDescriptors
         let $effectiveTime := concat(substring($refsetDescriptor/@effectiveTime,1,4),substring($refsetDescriptor/@effectiveTime,6,2),substring($refsetDescriptor/@effectiveTime,9,2))
         return
         concat($refsetDescriptor/@id,'&#9;',$effectiveTime,'&#9;',$refsetDescriptor/@active,'&#9;',$refsetDescriptor/@moduleId,'&#9;',$refsetDescriptor/@refsetId,'&#9;',$refsetDescriptor/@referencedComponentId,'&#9;',$refsetDescriptor/@attributeDescription,'&#9;',$refsetDescriptor/@attributeType,'&#9;',$refsetDescriptor/@attributeOrder,'&#13;&#10;')
         )
   return
   if ($mode='full') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Full/Refset/Metadata'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='snapshot') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Snapshot/Refset/Metadata'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='delta') then 
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Delta/Refset/Metadata'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else('INVALID MODE')
};

declare function local:save-refset-module-dependency-as-text($releaseDate as xs:date,$previousReleaseDate as xs:date,$moduleId as xs:string, $mode as xs:string) as xs:string {
      let $fileName := 
            if ($mode='full') then
               concat('der2_ssRefset_ModuleDependencyFull_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='snapshot') then
               concat('der2_ssRefset_ModuleDependencySnapshot_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='delta') then 
               concat('der2_ssRefset_ModuleDependencyDelta_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else()
      let $moduleDependencies :=
         if ($mode=('full','snapshot')) then
            collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project/moduleDependency
         else if ($mode='delta') then
            collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project/moduleDependency[@effectiveTime castable as xs:date][xs:date(@effectiveTime) gt $previousReleaseDate]
         else()
      let $file :=
         (
         concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','refsetId','&#9;','referencedComponentId','&#9;','sourceEffectiveTime','&#9;','targetEffectiveTime','&#13;&#10;'),
          for $moduleDependency in $moduleDependencies
          let $effectiveTime := concat(substring($moduleDependency/@effectiveTime,1,4),substring($moduleDependency/@effectiveTime,6,2),substring($moduleDependency/@effectiveTime,9,2))
         return
         concat($moduleDependency/@id,'&#9;',$effectiveTime,'&#9;',$moduleDependency/@active,'&#9;',$moduleDependency/@moduleId,'&#9;',$moduleDependency/@refsetId,'&#9;',$moduleDependency/@referencedComponentId,'&#9;',$moduleDependency/@sourceEffectiveTime,'&#9;',$moduleDependency/@targetEffectiveTime,'&#13;&#10;')
         )
   return
   if ($mode='full') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Full/Refset/Metadata'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='snapshot') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Snapshot/Refset/Metadata'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='delta') then 
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Delta/Refset/Metadata'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else('INVALID MODE')
};

declare function local:save-terminology-concepts-as-text($releaseDate as xs:date,$previousReleaseDate as xs:date,$moduleId as xs:string, $mode as xs:string) as xs:string {
      let $fileName := 
            if ($mode='full') then
               concat('sct2_Concept_Full_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='snapshot') then
               concat('sct2_Concept_Snapshot_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='delta') then 
               concat('sct2_Concept_Delta_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else()
      let $concepts :=
         if ($mode=('full','snapshot')) then
            collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept[@statusCode=('active','retired')]
         else if ($mode='delta') then
            collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept[@statusCode=('active','retired')][@effectiveTime castable as xs:date][xs:date(@effectiveTime) gt $previousReleaseDate]
         else()
      let $file :=
         (
         concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','definitionStatusId','&#13;&#10;'),
          for $concept in $concepts
          let $effectiveTime := concat(substring($concept/@effectiveTime,1,4),substring($concept/@effectiveTime,6,2),substring($concept/@effectiveTime,9,2))
          let $active := if ($concept/@statusCode='active') then '1' else ('0')
            return
            concat($concept/@conceptId,'&#9;',$effectiveTime,'&#9;',$active,'&#9;',$moduleId,'&#9;',$concept/@definitionStatusId,'&#13;&#10;')
         )
   return
   if ($mode='full') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Full/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='snapshot') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Snapshot/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='delta') then 
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Delta/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else('INVALID MODE')
};

declare function local:save-terminology-descriptions-as-text($releaseDate as xs:date,$previousReleaseDate as xs:date,$moduleId as xs:string, $mode as xs:string) as xs:string {
      let $fileName := 
            if ($mode='full') then
               concat('sct2_Description_Full_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='snapshot') then
               concat('sct2_Description_Snapshot_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='delta') then 
               concat('sct2_Description_Delta_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else()
      let $file :=
            (
               concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','conceptId','&#9;','languageCode','&#9;','typeId','&#9;','term','&#9;','caseSignificanceId','&#13;&#10;'),
               let $descriptions :=
                  if ($mode=('full','snapshot')) then
                     collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))//description[@statusCode=('active','retired')]
                  else if ($mode='delta') then
                     collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))//description[@statusCode=('active','retired')][@effectiveTime castable as xs:date][xs:date(@effectiveTime) gt $previousReleaseDate]
                  else()
               return
               for $desc in $descriptions
                  let $effectiveTime := concat(substring($desc/@effectiveTime,1,4),substring($desc/@effectiveTime,6,2),substring($desc/@effectiveTime,9,2))
               return
               concat($desc/@id,'&#9;',$effectiveTime,'&#9;',$desc/@active,'&#9;',$moduleId,'&#9;',$desc/@conceptId,'&#9;',$desc/@languageCode,'&#9;',$desc/@typeId,'&#9;',$desc/desc/text(),'&#9;',$desc/@caseSignificanceId,'&#13;&#10;')
            )
   return
   if ($mode='full') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Full/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='snapshot') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Snapshot/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='delta') then 
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Delta/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else('INVALID MODE')
};

declare function local:save-terminology-relationships-as-text($releaseDate as xs:date,$previousReleaseDate as xs:date,$moduleId as xs:string, $mode as xs:string) as xs:string {
      let $fileName := 
            if ($mode='full') then
               concat('sct2_Relationship_Full_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='snapshot') then
               concat('sct2_Relationship_Snapshot_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else if ($mode='delta') then 
               concat('sct2_Relationship_Delta_NL_',datetime:format-date($releaseDate,'yyyyMMdd'),'.txt')
            else()
      let $relationships :=
         if ($mode=('full','snapshot')) then
            collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//src[@statusCode=('active','retired')]
         else if ($mode='delta') then
            collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//src[@statusCode=('active','retired')][@effectiveTime castable as xs:date][xs:date(@effectiveTime) gt $previousReleaseDate]
         else()
      let $file :=
         (
          concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','sourceId','&#9;','destinationId','&#9;','relationshipGroup','&#9;','typeId','&#9;','characteristicTypeId','&#9;','modifierId','&#13;&#10;'),
          for $relationship in $relationships
          let $effectiveTime := concat(substring($relationship/@effectiveTime,1,4),substring($relationship/@effectiveTime,6,2),substring($relationship/@effectiveTime,9,2))
          return
          concat($relationship/@id,'&#9;',$effectiveTime,'&#9;',$relationship/@active,'&#9;',$moduleId,'&#9;',$relationship/@sourceId,'&#9;',$relationship/@destinationId,'&#9;',$relationship/@relationshipGroup,'&#9;',$relationship/@typeId,'&#9;','900000000000011006','&#9;',$relationship/@modifierId,'&#13;&#10;')
         )
   return
   if ($mode='full') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Full/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='snapshot') then
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Snapshot/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else if ($mode='delta') then 
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/releases/',datetime:format-date($releaseDate,'yyyyMMdd'),'/Delta/Terminology'),$fileName,util:string-to-binary(string-join($file,'')),'text/csv')
   else('INVALID MODE')
};


let $newRelease := request:get-data()/release
(:let $newRelease :=
<release effectiveTime="2014-06-30" statusCode="draft" label="juli">
   <comment>Release comment</comment>
</release>:)

let $date := $newRelease/@effectiveTime
let $releaseDate :=
   if ($date castable as xs:date) then
      xs:date($date)
   else (current-date())

let $previousReleases := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//release[xs:date(@effectiveTime) lt xs:date($releaseDate)]
let $previousReleaseDate := max($previousReleases/xs:date(@effectiveTime))


let $createCollections := local:createReleaseCollections(datetime:format-date($releaseDate,'yyyyMMdd'))

let $moduleId:= '11000146104'
let $languageRefsetId :='31000146106'
let $modes := ('full','snapshot','delta')
return
<response>
   {
   for $mode in $modes
   return
   (
   local:save-refset-content-as-text($releaseDate,$previousReleaseDate,$moduleId,$mode),
   local:save-refset-language-as-text($releaseDate,$previousReleaseDate,$moduleId,$languageRefsetId,$mode),
   local:save-refset-descriptor-as-text($releaseDate,$previousReleaseDate,$moduleId,$mode),
   local:save-refset-module-dependency-as-text($releaseDate,$previousReleaseDate,$moduleId,$mode),
   local:save-terminology-concepts-as-text($releaseDate,$previousReleaseDate,$moduleId,$mode),
   local:save-terminology-descriptions-as-text($releaseDate,$previousReleaseDate,$moduleId,$mode),
   local:save-terminology-relationships-as-text($releaseDate,$previousReleaseDate,$moduleId,$mode)
   )
   }
</response>


