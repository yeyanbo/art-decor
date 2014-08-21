xquery version "3.0";
(:
    Copyright (C) 2013 Art Decor Expert Group art-decor.org
    
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
   Xquery for setting statusCode of thesaurus object
   Input: post of statusChange element
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
declare variable $user := xmldb:get-current-user();
declare variable $ciList := collection(concat($get:strTerminologyData,'/ica-data/concepts'))/cics;
declare variable $project :=collection(concat($get:strTerminologyData,'/ica-data/meta'))/project;
declare variable $logFileName := concat('transactions-',datetime:format-date(current-date(),"yyyy"),'.xml');

declare function local:writeLogEntry ($statusChange as element()) as item()* {
      let $logFile := doc(concat($get:strTerminologyData,'/ica-data/log/',$logFileName))
      let $statusLog :=
         <statusChange object="{$statusChange/@object}" statusCode="{$statusChange/@statusCode}" effectiveTime="{current-dateTime()}" user="{$user}" username="{$project/author[@username=$user]}">
            {
            if ($statusChange/@object='ci') then
               attribute id {$statusChange/@ref}
            else if ($statusChange/@object='mapping') then
               attribute id {$statusChange/@ref}
            else if ($statusChange/@object='release') then
               attribute releaseEffectiveTime {$statusChange/@ref}
            else()
            }
         </statusChange>
      return
      update insert $statusLog into $logFile/log
};

declare function local:setCiStatus ($statusChange as element(), $historyLog as item()) as item()* {
      let $storedConcept :=collection(concat($get:strTerminologyData,'/ica-data/concepts'))//ci[@id=$statusChange/@ref]
      return
      (
         (:
            if 'active' check existing effectiveDate
            - if existing date: do not update effectiveDate, set status to active
            - if no existing effectiveDate
               - if no request effectiveDate: set effectiveDate to current, set status to active
               - if request effectiveDate in future: set date, set status to pending
               - if effectiveDate in past or current: set date, set status to active
         :)
         if ($statusChange/@statusCode='active') then
            (
            if (string-length($storedConcept/@effectiveDate) = 0) then
               if (string-length($statusChange/@effectiveDate) =0) then
                  (
                  update value $storedConcept/@effectiveDate with datetime:format-date(current-date(),"yyyy-MM-dd"),
                  update value $storedConcept/@statusCode with 'active'
                  )
               else
                  (
                  if (xs:date($statusChange/@effectiveDate) gt current-date()) then
                     (
                     update value $storedConcept/@effectiveDate with $statusChange/@effectiveDate,
                     update value $storedConcept/@statusCode with 'pending'
                     )
                  else
                     (
                     update value $storedConcept/@effectiveDate with $statusChange/@effectiveDate,
                     update value $storedConcept/@statusCode with 'active'
                     )
                  )
            else(update value $storedConcept/@statusCode with 'active')
            ,
            if (string-length($statusChange/@expirationDate) gt 0) then
               update value $storedConcept/@expirationDate with $statusChange/@expirationDate
            else()
            ,
            for $mapping in $storedConcept/*[name()=('icpc','icd-9','icd-10','snomed','shb-ci')][@statusCode='review']
            let $itemStatusChange :=
               <statusChange object="mapping" ref="{$mapping/@id}">
                  {$statusChange/@*[not(name()=('object','ref'))]}
               </statusChange>
            return
            local:setMappingStatus($itemStatusChange)
            ,
            update insert $storedConcept into $historyLog/log
            )
         (:
            if 'retired' check request expirationDate
            - if request date in future: set date, set status to active
            - if request date is empty or current and stored expirationDate is empty: set date to current, set status to retired
            - if request date is empty or current and stored expirationDate is present: set date to current, set status to retired
            - 
         
         :)
         else if ($statusChange/@statusCode='retired') then
            (
            if (string-length($statusChange/@expirationDate) = 0) then
               (
               update value $storedConcept/@expirationDate with datetime:format-date(current-date(),"yyyy-MM-dd"),
               update value $storedConcept/@statusCode with 'retired'
               )
               
            else
               (
               if (xs:date($statusChange/@expirationDate) gt current-date()) then
                  update value $storedConcept/@expirationDate with $statusChange/@expirationDate
               else
                  (
                  update value $storedConcept/@expirationDate with $statusChange/@expirationDate,
                  update value $storedConcept/@statusCode with 'retired'
                  )
               )
            ,
            for $mapping in $storedConcept/*[name()=('icpc','icd-9','icd-10','snomed','shb-ci')]
            let $itemStatusChange :=
               <statusChange object="mapping" ref="{$mapping/@id}">
                  {$statusChange/@*[not(name()=('object','ref'))]}
               </statusChange>
            return
            local:setMappingStatus($itemStatusChange)
            )
            (:
            review
            :)
            else if ($statusChange/@statusCode='review') then
            (
            update value $storedConcept/@statusCode with 'review'
            ,
            for $mapping in $storedConcept/*[name()=('icpc','icd-9','icd-10','snomed','shb-ci')][@statusCode=('draft','update','pending')]
            let $itemStatusChange :=
               <statusChange object="mapping" ref="{$mapping/@id}">
                  {$statusChange/@*[not(name()=('object','ref'))]}
               </statusChange>
            return
            local:setMappingStatus($itemStatusChange)
            )
            (:
            rejected
            :)
            else if ($statusChange/@statusCode='rejected') then
            (
            update value $storedConcept/@statusCode with 'rejected',
            update value $storedConcept/@expirationDate with '',
            update value $storedConcept/@effectiveDate with ''
            ,
            for $mapping in $storedConcept/*[name()=('icpc','icd-9','icd-10','snomed','shb-ci')]
            let $itemStatusChange :=
               <statusChange object="mapping" ref="{$mapping/@id}">
                  {$statusChange/@*[not(name()=('object','ref'))]}
               </statusChange>
            return
            local:setMappingStatus($itemStatusChange)
            )
         (:
            in all other cases only set statuscode
         :)
         else(update value $storedConcept/@statusCode with $statusChange/@statusCode/string())
         ,
         <response>{$statusChange/@statusCode/string()}</response>,
         if ($statusChange/@statusCode!='review') then
         update value $storedConcept/@editDate with datetime:format-date(current-date(),"yyyy-MM-dd")
         else(),
         local:writeLogEntry($statusChange)
         )
    
};

declare function local:setMappingStatus ($statusChange as element()) as item()* {
      let $storedItem :=collection(concat($get:strTerminologyData,'/ica-data/concepts'))//*[@id=$statusChange/@ref]
      return
         (
         (:
            if 'active' check existing effectiveDate
            - if existing date: do not update effectiveDate, set status to active
            - if no existing effectiveDate
               - if no request effectiveDate: set effectiveDate to current, set status to active
               - if request effectiveDate in future: set date, set status to pending
               - if effectiveDate in past or current: set date, set status to active
         :)
         if ($statusChange/@statusCode='active') then
            (
            if (string-length($storedItem/@effectiveDate) = 0) then
               if (string-length($statusChange/@effectiveDate) =0) then
                  (
                  update value $storedItem/@effectiveDate with datetime:format-date(current-date(),"yyyy-MM-dd"),
                  update value $storedItem/@statusCode with 'active'
                  )
               else
                  (
                  if (xs:date($statusChange/@effectiveDate) gt current-date()) then
                     (
                     update value $storedItem/@effectiveDate with $statusChange/@effectiveDate,
                     update value $storedItem/@statusCode with 'pending'
                     )
                  else
                     (
                     update value $storedItem/@effectiveDate with $statusChange/@effectiveDate,
                     update value $storedItem/@statusCode with 'active'
                     )
                  )
            else(update value $storedItem/@statusCode with 'active')
            ,
            if (string-length($statusChange/@expirationDate) gt 0) then
               update value $storedItem/@expirationDate with $statusChange/@expirationDate
            else()
            )
         (:
            if 'retired' check request expirationDate
            - if request date in future: set date, set status to active
            - if request date is empty or current and stored expirationDate is empty: set date to current, set status to retired
            - if request date is empty or current and stored expirationDate is present: set date to current, set status to retired
            - 
         
         :)
         else if ($statusChange/@statusCode='retired') then
            if (string-length($statusChange/@expirationDate) = 0) then
               (
               update value $storedItem/@expirationDate with datetime:format-date(current-date(),"yyyy-MM-dd"),
               update value $storedItem/@statusCode with 'retired'
               )
               
            else
               (
               if (xs:date($statusChange/@expirationDate) gt current-date()) then
                  update value $storedItem/@expirationDate with $statusChange/@expirationDate
               else
                  (
                  update value $storedItem/@expirationDate with $statusChange/@expirationDate,
                  update value $storedItem/@statusCode with 'retired'
                  )
               )
         else if ($statusChange/@statusCode='rejected') then
               (
               update value $storedItem/@effectiveDate with '',
               update value $storedItem/@expirationDate with '',
               update value $storedItem/@statusCode with 'rejected'
               )
         (:
            in all other cases only set statuscode
         :)
         else(update value $storedItem/@statusCode with $statusChange/@statusCode/string())
         ,
         <response>{$statusChange/@statusCode/string()}</response>,
         if ($statusChange/@statusCode!='review') then
         update value $storedItem/@editDate with datetime:format-date(current-date(),"yyyy-MM-dd")
         else(),
         local:writeLogEntry($statusChange)
         )
};


declare function local:setReleaseStatus ($statusChange as element()) as item()* {
      let $storedRelease :=collection(concat($get:strTerminologyData,'/ica-data/meta'))//release[@effectiveTime=$statusChange/@ref]
      return
         (     
         if ($statusChange/@statusCode='final') then
            (
            update value $storedRelease/@statusCode with $statusChange/@statusCode/string()
            ,
            for $previousRelease in collection(concat($get:strTerminologyData,'/ica-data/meta'))/project/release[xs:dateTime(@effectiveTime) lt xs:dateTime($storedRelease/@effectiveTime)]
            return
            update value $previousRelease/@statusCode with 'deprecated'
            )
         else()
         ,         
         <response>{$statusChange/@statusCode/string()}</response>,
         local:writeLogEntry($statusChange)
         )
};


let $statusChange := request:get-data()/statusChange
(:let $statusChange := <statusChange object="desc" refsetId="" refsetEffectiveDate="" ref="1952831274" statusCode="active" versionLabel=""/>:)
(: get user for permission check:)

let $edit := xs:boolean($project/author[@username=$user]/@edit)
let $authorize := xs:boolean($project/author[@username=$user]/@authorize)
(:check for existing log file:)

let $checkLog :=
   if (not(doc-available(concat($get:strTerminologyData,'/ica-data/log/',$logFileName)))) then
      (
      xmldb:store(concat($get:strTerminologyData,'/ica-data/log/'), $logFileName, <log/>),
      sm:chown(xs:anyURI(concat($get:strTerminologyData,'/ica-data/log/',$logFileName)),'admin'),
      sm:chgrp(xs:anyURI(concat($get:strTerminologyData,'/ica-data/log/',$logFileName)),'terminology'),
      sm:chmod(xs:anyURI(concat($get:strTerminologyData,'/ica-data/log/',$logFileName)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat($get:strTerminologyData,'/ica-data/log/',$logFileName)))
      )
   else()

let $checkHistoryLog :=
   if (not(doc-available(concat($get:strTerminologyData,'/ica-data/history/',$logFileName)))) then
      (
      xmldb:store(concat($get:strTerminologyData,'/ica-data/history/'), $logFileName, <log/>),
      sm:chown(xs:anyURI(concat($get:strTerminologyData,'/ica-data/history/',$logFileName)),'admin'),
      sm:chgrp(xs:anyURI(concat($get:strTerminologyData,'/ica-data/history/',$logFileName)),'terminology'),
      sm:chmod(xs:anyURI(concat($get:strTerminologyData,'/ica-data/history/',$logFileName)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat($get:strTerminologyData,'/ica-data/history/',$logFileName)))
      )
   else()

(:let $logFile := doc(concat($get:strTerminologyData,'/ica-data/log/',$logFileName)):)
let $historyLog := doc(concat($get:strTerminologyData,'/ica-data/history/',$logFileName))
let $response :=
   (:check if user is authorized:)
   if (($statusChange/@statusCode='active' and $authorize) or ($statusChange/@statusCode!='active' and $edit)) then
      (
      if ($statusChange/@object='ci') then
         local:setCiStatus($statusChange,$historyLog)
      else if ($statusChange/@object='mapping') then
         local:setMappingStatus($statusChange)
       else if ($statusChange/@object='release') then
         local:setReleaseStatus($statusChange)
      else()
      )
   else(<response>NO PERMISSION</response>)
return
<response>{$response}</response>

