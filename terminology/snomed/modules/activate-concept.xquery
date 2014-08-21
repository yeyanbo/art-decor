xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR Expert Group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
(:
   Xquery for setting statusCode of refset object
   Input: post of statusChange element:
   <statusChange refsetId="" refsetEffectiveDate="2013-09-24T14:32:15" ref="2.16.840.1.113883.3.1937.99.62.3.11.6" statusCode="final" versionLabel="Test"/>
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
declare variable $user := xmldb:get-current-user();
declare variable $logFileName := concat('transactions-',datetime:format-date(current-date(),"yyyy"),'.xml');
import module namespace snomed ="http://art-decor.org/ns/terminology/snomed" at "../api/api-snomed.xqm";
import module namespace dhd = "http://art-decor.org/ns/terminology/dhd" at "../../dhd/api/api-dhd.xqm";


declare function local:writeLogEntry ($statusChange as element(),$project as element(), $log as element()) as item()* {
      let $statusLog :=
         <statusChange object="{$statusChange/@object}" statusCode="{$statusChange/@statusCode}" effectiveTime="{current-dateTime()}" user="{$user}" username="{$project/author[@username=$user]}">
            {
            if ($statusChange/@object=('relation','concept','member','desc')) then
               attribute id {$statusChange/@ref}
            else if ($statusChange/@object='release') then
               attribute releaseEffectiveTime {$statusChange/@ref}
            else()
            }
         </statusChange>
      return
      update insert $statusLog into $log
};

declare function local:activateConcept ($concept as element(),$project as element(),$log as element(), $historyLog as item()) as item()* {
      let $storedConcept   := collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept[@uuid=$concept/@uuid]
      return
      (
         (:only set effectiveDate if empty:)
         if (string-length($storedConcept/@effectiveTime) = 0) then
            update value $storedConcept/@effectiveTime with datetime:format-date(current-date(),"yyyy-MM-dd")
         else(),
         (:generate SCTID if empty:)
         if (string-length($storedConcept/@conceptId) = 0) then
            let $conceptId := snomed:generateSCTID(xs:integer('1000146'),xs:integer('10'))
            return
            (
            update value $storedConcept/@conceptId with $conceptId,
            (:check for relations with current concept as destination,
            replace destinationId with new conceptId:)
            for $destination in collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept/src[@destinationId=$storedConcept/@soId]
            return
            update value $destination/@destinationId with $conceptId
            )
         else(),
         (:set statusCode to 'active':)
         update value $storedConcept/@statusCode with 'active',
         (:activate all descriptions with status draft or review:)
         for $desc in $storedConcept/desc[@statusCode=('draft','review')] 
            let $description      := collection(concat($get:strTerminologyData,'/snomed-extension/descriptions'))//description[@uuid=$desc/@uuid]
            return
            (
            if (string-length($desc/@effectiveTime) = 0) then
               (
               update value $desc/@effectiveTime with datetime:format-date(current-date(),"yyyy-MM-dd"),
               update value $description/@effectiveTime with datetime:format-date(current-date(),"yyyy-MM-dd")
               )
            else(),
            if (string-length($desc/@id) = 0) then
               let $descId := snomed:generateSCTID(xs:integer('1000146'),xs:integer('11'))
               return
               (
               update value $desc/@id with $descId,
               update value $desc/@conceptId with $desc/parent::concept/@conceptId,
               update value $description/@id with $descId,
               update value $description/@conceptId with $desc/parent::concept/@conceptId
               )
            else(),
            update value $desc/@statusCode with 'active',
            update value $desc/@active with '1',
            update value $description/@statusCode with 'active',
            update value $description/@active with '1',
            local:writeLogEntry(<statusChange object="desc" ref="{$desc/@id}" statusCode="active"/>,$project,$log)
            ),
         (:activate all relations with status draft or review:)
         for $src in $storedConcept/src[@statusCode=('draft','review')] 
            return
            (
            if (string-length($src/@effectiveTime) = 0) then
               update value $src/@effectiveTime with datetime:format-date(current-date(),"yyyy-MM-dd")
            else(),
            if (string-length($src/@id) = 0) then
               let $srcId := snomed:generateSCTID(xs:integer('1000146'),xs:integer('12'))
               return
               (
               update value $src/@id with $srcId,
               update value $src/@sourceId with $src/parent::concept/@conceptId
               )
            else(),
            update value $src/@statusCode with 'active',
            local:writeLogEntry(<statusChange object="relation" ref="{$src/@id}" statusCode="active"/>,$project,$log)
            ),
         (:add to specified refsets:)
         for $refsetId in tokenize($concept/refsets,'\s')
            let $refset       := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
                  let $newMember :=
            <member id="{util:uuid()}" statusCode="draft" effectiveTime="{datetime:format-date(current-date(),"yyyy-MM-dd")}">
               <lastStatusChange authorId="{$user}" authorName="{$project/author[@username=$user]/text()}" effectiveDate="{current-date()}"/>
               <concept>
               {
               $storedConcept/@*,
               $storedConcept/desc,
               $storedConcept/ancestors,
               $storedConcept/dest,
               <refsets>
                  {
                  for $ref in $storedConcept/refsets/refset
                  return
                  <refset refsetId="{$ref/@refsetId}"/>
                  }
               </refsets>,
               <maps>
                  {
                  for $map in $storedConcept/maps/map
                  return
                  <map refsetId="{$map/@refsetId}"/>
                  }
               </maps>
               }
               </concept>
            </member>
            return
            
       update insert $newMember into $refset
       ,
         (:add to DHD thesaurus if specified:)
         if ($concept/dhd='true') then
            let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
            let $thesaurusFileName :=concat('thesaurus-',datetime:format-date(current-date(),"yyyy"),'.xml')
            let $currentDate :=datetime:format-date(current-date(),"yyyy-MM-dd")
            return
            (:check if Snomed concept already in thesaurus:)
            if ($thesaurus/concept[snomed/@conceptId!=$storedConcept/@conceptId]) then
               let $icd10Maps :=$storedConcept/maps/map[@refsetId='447562003']
               let $distinctCodes :=
                     for $target in distinct-values($icd10Maps/@mapTarget)
                     let $priority := min($icd10Maps[@mapTarget=$target]/xs:integer(@priority))
                     return
                     <code priority="{$priority}">{$target}</code>
               let $newConcept :=
                  <concept  no="{dhd:getNextConceptNo()}" thesaurusId="{dhd:getNextThesaurusId()}" statusCode="draft" effectiveDate="" idLink="" expirationDate="" editDate="{$currentDate}" editCode="new">
                     <snomed conceptId="{$storedConcept/@conceptId}" validationDate="" validated="">
                        <desc type="fsn">{$storedConcept/desc[@type='fsn']/text()}</desc>
                     </snomed>
                     <desc no="{dhd:getNextDescNo()}" interfaceId="{dhd:getNextInterfaceId()}" type="pref" count="0" length="0" effectiveDate="" expirationDate="" statusCode="draft" editDate="{$currentDate}" editCode="new"></desc>
                     {
                     for $code at $pos in $distinctCodes
                     let $icd10 := collection(concat($get:strTerminologyData,'/dhd-data/reference'))//icd[@code=$code]
                     order by $code/@priority
                     return
                     <icd10 no="{dhd:getNextIcd10No()}" code="{$icd10/@code}" codeStripped="{$icd10/@codeStripped}" priority="{$pos}" effectiveDate="" expirationDate="" editDate="{$currentDate}" editCode="new" validationDate="" validated="false" statusCode="draft"/>
                     }
                  </concept>
               return
               (
               update insert $newConcept into doc(concat($get:strTerminologyData,'/dhd-data/thesaurus/',$thesaurusFileName))/thesaurus
               )
            else()
         else()
         ,
         <response>OK</response>,
         update insert $storedConcept into $historyLog,
         local:writeLogEntry(<statusChange object="concept" ref="{$storedConcept/@conceptId}" statusCode="active"/>,$project,$log)
         )
    
};


let $concept := request:get-data()/concept

let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref='extension']
let $edit          := xs:boolean($project/author[@username=$user]/@edit)
let $authorize := xs:boolean($project/author[@username=$user]/@authorize)

let $checkLog :=
   if (not(doc-available(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName)))) then
      (
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/log/'), $logFileName, <log/>),
      sm:chown(xs:anyURI(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName)),'admin'),
      sm:chgrp(xs:anyURI(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName)),'terminology'),
      sm:chmod(xs:anyURI(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName)))
      )
   else(
      if (not(doc(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName))//log[@ref='extension'])) then
         update insert <log ref="extension"/> into doc(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName))/log
      else()
   )

      
let $checkHistoryLog :=
   if (not(doc-available(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName)))) then
      (
      xmldb:store(concat($get:strTerminologyData,'/snomed-extension/history/'), $logFileName, <log/>),
      sm:chown(xs:anyURI(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName)),'admin'),
      sm:chgrp(xs:anyURI(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName)),'terminology'),
      sm:chmod(xs:anyURI(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName)))
      )
   else(
      if (not(doc(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName))//log[@ref='extension'])) then
         update insert <log ref="extension"/> into doc(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName))/log
      else()
   )


let $log := doc(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName))//log[@ref='extension']
let $historyLog := doc(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName))//log[@ref='extension']

let $response :=
   (:check if user is authorized:)
   if ($authorize) then
      (
      local:activateConcept($concept,$project,$log,$historyLog)
      )
   else(<response>NO PERMISSION</response>)

return
$response