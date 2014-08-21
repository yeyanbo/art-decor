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


declare function local:writeLogEntry ($statusChange as element(),$project as element(), $log as element()) as item()* {
      let $statusLog :=
         <statusChange object="{$statusChange/@object}" statusCode="{$statusChange/@statusCode}" effectiveTime="{current-dateTime()}" user="{$user}" username="{$project/author[@username=$user]}">
            {
            if ($statusChange/@object=('member','desc')) then
               attribute id {$statusChange/@ref}
            else if ($statusChange/@object='release') then
               attribute releaseEffectiveTime {$statusChange/@ref}
            else()
            }
         </statusChange>
      return
      update insert $statusLog into $log
};

declare function local:setMemberStatus ($statusChange as element(),$project as element(),$log as element(), $historyLog as item()) as item()* {
      let $refset          := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$statusChange/@refsetId]
      let $storedMember   := $refset//member[@id=$statusChange/@ref]
      let $lastStatusChange := <lastStatusChange authorId="{$user}" authorName="{$project/author[@username=$user]/text()}" effectiveDate="{current-date()}"/>
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
            if (string-length($storedMember/@effectiveDate) = 0) then
               update value $storedMember/@effectiveDate with datetime:format-date(current-date(),"yyyy-MM-dd")
            else(),
            update value $storedMember/@statusCode with 'active',
            update insert $storedMember into $historyLog
            )

            else if ($statusChange/@statusCode='retired') then
            update value $storedMember/@statusCode with 'retired'
            (:
            review
            :)
            else if ($statusChange/@statusCode='review') then
            (
            update value $storedMember/@statusCode with 'review'
            )
            (:
            rejected
            :)
            else if ($statusChange/@statusCode='rejected') then
            (
            update value $storedMember/@statusCode with 'rejected',
            update value $storedMember/@effectiveTime with ''
            )
         (:
            in all other cases only set statuscode
         :)
         else(update value $storedMember/@statusCode with $statusChange/@statusCode/string())
         ,
         <response>{$statusChange/@statusCode/string()}</response>,
         if ($storedMember/lastStatusChange) then
               update replace $storedMember/lastStatusChange with $lastStatusChange
         else (update insert $lastStatusChange into $storedMember),
         local:writeLogEntry($statusChange,$project,$log)
         )
    
};

declare function local:setDescriptionStatus ($statusChange as element(),$project as element(),$log as element()) as item()* {
      let $storedItem :=collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//desc[@interfaceId=$statusChange/@ref]
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
         update value $storedItem/@editDate with datetime:format-date(current-date(),"yyyy-MM-dd"),
         local:writeLogEntry($statusChange,$project,$log)
         )
};

declare function local:setReleaseStatus ($statusChange as element(),$project as element(),$log as element()) as item()* {
      let $storedRelease :=collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//release[@effectiveTime=$statusChange/@ref]
      return
         (     
         if ($statusChange/@statusCode='final') then
            (
            update value $storedRelease/@statusCode with $statusChange/@statusCode/string()
            ,
            for $previousRelease in collection(concat($get:strTerminologyData,'/snomed-extension/meta'))/project/release[xs:dateTime(@effectiveTime) lt xs:dateTime($storedRelease/@effectiveTime)]
            return
            update value $previousRelease/@statusCode with 'deprecated'
            )
         else()
         ,         
         <response>{$statusChange/@statusCode/string()}</response>,
         local:writeLogEntry($statusChange,$project,$log)
         )
};

let $statusChange := request:get-data()/statusChange
(:let $statusChange :=
<statusChange refsetId="41000146103" object="member" ref="78035d63-0d69-4fa5-8952-b6ab508cfd76" statusCode="retired"/>:)

let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$statusChange/@refsetId]
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
      if (not(doc(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName))//log[@ref=$statusChange/@refsetId])) then
         update insert <log ref="{$statusChange/@refsetId}"/> into doc(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName))/log
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
      if (not(doc(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName))//log[@ref=$statusChange/@refsetId])) then
         update insert <log ref="{$statusChange/@refsetId}"/> into doc(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName))/log
      else()
   )


let $log := doc(concat($get:strTerminologyData,'/snomed-extension/log/',$logFileName))//log[@ref=$statusChange/@refsetId]
let $historyLog := doc(concat($get:strTerminologyData,'/snomed-extension/history/',$logFileName))//log[@ref=$statusChange/@refsetId]

let $response :=
   (:check if user is authorized:)
   if (($statusChange/@statusCode='active' and $authorize) or ($statusChange/@statusCode!='active' and $edit)) then
      (
      if ($statusChange/@object='member') then
         local:setMemberStatus($statusChange,$project,$log,$historyLog)
      else if ($statusChange/@object='desc') then
         local:setDescriptionStatus($statusChange,$project,$log)
       else if ($statusChange/@object='release') then
         local:setReleaseStatus($statusChange,$project,$log)
      else()
      )
   else(<response>NO PERMISSION</response>)

return
$response

