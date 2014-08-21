xquery version "3.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace xmldb      = "http://exist-db.org/xquery/xmldb";
declare namespace util       = "http://exist-db.org/xquery/util";
declare namespace validation = "http://exist-db.org/xquery/validation";
declare namespace soap       = "http://schemas.xmlsoap.org/soap/envelope/";
declare namespace xsi        = "http://www.w3.org/2001/XMLSchema-instance";
declare namespace xs         = "http://www.w3.org/2001/XMLSchema";
declare namespace hl7        = "urn:hl7-org:v3";
declare namespace xis        = "http://art-decor.org/ns/xis";
declare namespace de         = "http://art-decor.org/ns/error";

declare function local:getHL7Name ($name as element()?) as xs:string* {
    let $r :=
        for $namePart in $name//text()
        return (
            if ($namePart[normalize-space()='']) then (
            ) else if ($namePart[parent::hl7:given] and $namePart[parent::hl7:*[following-sibling::node()[normalize-space()!='']]]) then (
                concat(normalize-space($namePart),' ')
            ) else (
                normalize-space($namePart)
            )
        )
        
    (:let $r := string-join($name//text(),' '):)
    return
        $r
};

(: Log debug messages? :)
let $debug             := true()

(: server path:)
let $account           := if (request:exists()) then request:get-parameter('account','') else ('rivmsp-medischegegevensnl')

let $g := if ($debug) then (util:log('DEBUG', concat('============ Supplied parameters: account=',$account))) else ()

(:let $account       :='art-decor':)
let $instancesPath     := concat($get:strXisAccounts, '/',$account,'/messages')
let $interactionFile   := concat($get:strXisResources, '/vocab/2.16.840.1.113883.1.6.xml')
let $messages          := collection($instancesPath)//*[
    hl7:interactionId or 
    self::hl7:ClinicalDocument[not(hl7:text)] or 
    (@representation/string()='B64' and not(@mediaType/lower-case(.)=('application/pdf'))) or 
    @xsi:type/string()='xs:base64Binary']
let $configuration     := doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:xis
let $applications      := doc(concat($get:strXisHelperConfig, '/applications.xml'))//xis:application
let $patients          := 
    for $patient in collection($get:strXisHelperConfig)//hl7:Patient
    order by $patient/hl7:Person/hl7:name/hl7:family[1]
    return
        $patient

(:let $patientSearch := '999910280':)
return
<messages>
{
    for $message in $messages
    let $fileName       := xmldb:decode(util:document-name($message))
    let $fileCollection := tokenize($fileName,'/')[last()]
    let $fileCreation   := xmldb:created(util:collection-name($message),util:document-name($message))
    
    let $messageXpath   := util:node-xpath($message)
    let $message        :=
        try {
            if ($message[@representation/string()='B64' or @xsi:type/string()='xs:base64Binary']) then (
                util:parse(util:base64-decode($message))/*
            ) else (
                $message
            )
        }
        catch * {
            <de:error xmlns:de="http://art-decor.org/ns/error" file="{$fileName}" fileCreation="{$fileCreation}" xpath="{$messageXpath}">{concat('ERROR ', $err:code, ' while getting message instance: ', $err:description, ', module: ', $err:module, '(', $err:line-number, ',', $err:column-number, ') file: (', util:document-name($message),')')}</de:error>
        }
    let $report := doc(concat($get:strXisAccounts, '/',$account,'/reports/', encode-for-uri($fileName)))
    let $schemaValid := 
        if (not($report)) 
        then 'empty'
        else if ($report//error) 
        then 'invalid'
        else if ($report[not(.//error)]//warning) 
        then 'warning-only'
        else 'valid'
       
    order by $fileCreation descending
    return
        if (not($message/self::de:error))
        then (
            (: get message meta details :)
            let $messageRoot    :=
                if ($message[hl7:interactionId]) then (
                    ($message[hl7:interactionId])[1]/hl7:interactionId/@extension
                    
                ) else (
                    $message/local-name()
                )
            let $messageName    :=
                if (doc($interactionFile)//hl7:code[@code=$messageRoot]) then (
                    doc($interactionFile)//hl7:code[@code=$messageRoot]/@displayName
                    
                ) else if ($message[self::hl7:ClinicalDocument]/hl7:title) then (
                    $message/hl7:title
                    
                ) else if ($message[self::hl7:ClinicalDocument]/hl7:code[@displayName]) then (
                    ($message/hl7:code)[1]/@displayName
                    
                ) else if ($message[self::hl7:ClinicalDocument]/hl7:code[@code]) then (
                    ($message/hl7:code)[1]/@code
                    
                ) else (
                    $message/local-name()
                )
            
            let $dateString     := 
                if ($message[hl7:interactionId]/hl7:creationTime) then (
                    ($message[hl7:interactionId])[1]/hl7:creationTime/@value
                    
                ) else if ($message[self::hl7:ClinicalDocument]) then (
                    $message/hl7:effectiveTime/@value
                    
                ) else ()
            let $date           := 
                if ($dateString) then (
                    try {
                        xs:date(concat(substring($dateString,1,4),'-',substring($dateString,5,2),'-',substring($dateString,7,2)))
                    }
                    catch * {()}
                ) else ()
            let $time           := 
                if ($dateString) then (
                    try {
                        if (matches($dateString,'\+[0-9]{4}|-[0-9]{4}')) then (
                            xs:time(concat(substring($dateString,9,2),':',substring($dateString,11,2),':',substring($dateString,13,string-length($dateString)-17)))
                            (:xs:time(concat('12',':','59',':',substring($dateString,13,2))):)
                        ) else (
                            xs:time(concat(substring($dateString,9,2),':',substring($dateString,11,2),':',substring($dateString,13,string-length($dateString)-12)))
                        )
                    }
                    catch * {()}
                ) else ()
            
            (: get sender details :)
            let $sender         := 
                if ($message/hl7:sender/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']) then (
                    $message/hl7:sender/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension
                    
                ) else if ($message/hl7:sender/hl7:device/hl7:id) then (
                    ($message/hl7:sender/hl7:device/hl7:id)[1]/@extension
                    
                ) else if ($message[self::hl7:ClinicalDocument]/hl7:custodian) then (
                    ($message[self::hl7:ClinicalDocument]/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:id)[1]/@extension
                    
                ) else ()
            let $senderName     :=
                if ($applications[@id=$sender][xis:name]) then (
                    $applications[@id=$sender]/xis:name
                    
                ) else if ($message/hl7:sender/hl7:device[.//hl7:name]) then (
                    (:replace(string-join(($message/hl7:sender/hl7:device//hl7:name)[1]//text(),' '),'\s+',' '):)
                    local:getHL7Name(($message/hl7:sender/hl7:device//hl7:name)[1])
                    
                ) else if ($message[self::hl7:ClinicalDocument]/hl7:custodian) then (
                    (:replace(string-join(($message/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:name)[1]//text(),' '),'\s+',' '):)
                    local:getHL7Name(($message/hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization/hl7:name)[1])
                    
                ) else ()
            
            (: get receiver details :)
            let $receiver       := 
                if ($message/hl7:receiver/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']) then (
                    $message/hl7:receiver/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension
                    
                ) else if ($message/hl7:receiver/hl7:device/hl7:id) then (
                    ($message/hl7:receiver/hl7:device/hl7:id)[1]/@extension
                    
                ) else if ($message[self::hl7:ClinicalDocument]/hl7:informationRecipient) then (
                    ($message/hl7:informationRecipient/hl7:intendedRecipient/hl7:id)[1]/@extension
                    
                ) else ()
            let $receiverName     :=
                if ($applications[@id=$receiver][xis:name]) then (
                    $applications[@id=$receiver]/xis:name
                    
                ) else if ($message/hl7:receiver/hl7:device[.//hl7:name]) then (
                    (:replace(string-join(($message/hl7:receiver/hl7:device//hl7:name)[1]/text(),' '),'\s+',' '):)
                    local:getHL7Name(($message/hl7:receiver/hl7:device//hl7:name)[1])
                    
                ) else if ($message[self::hl7:ClinicalDocument]/hl7:informationRecipient) then (
                    (:replace(string-join(($message/hl7:informationRecipient/hl7:intendedRecipient//hl7:name)[1]//text(),' '),'\s+',' '):)
                    local:getHL7Name(($message/hl7:informationRecipient/hl7:intendedRecipient//hl7:name)[1])
                    
                ) else ()
                
            (:get patient details :)
            let $patientId      := 
                if ($message/hl7:ControlActProcess/hl7:queryByParameter) then (
                    $message/hl7:ControlActProcess/hl7:queryByParameter/hl7:*/hl7:value[@root='2.16.840.1.113883.2.4.6.3']/@extension
                    
                ) else if ($message/hl7:ControlActProcess/hl7:subject//(hl7:subject|hl7:recordTarget)/(hl7:Patient|hl7:patient)/hl7:id[@root='2.16.840.1.113883.2.4.6.3']) then (
                    ($message/hl7:ControlActProcess/hl7:subject//(hl7:subject|hl7:recordTarget)/(hl7:Patient|hl7:patient)/hl7:id[@root='2.16.840.1.113883.2.4.6.3'])[1]/@extension
                    
                ) else if ($message[self::hl7:ClinicalDocument]) then (
                    ($message/hl7:recordTarget/hl7:patientRole/hl7:id[@root='2.16.840.1.113883.2.4.6.3'])[1]/@extension
                ) else ()
            let $patientName    :=
                if ($patients[hl7:id[@root='2.16.840.1.113883.2.4.6.3'][@extension=$patientId]][hl7:Person/hl7:name]) then (
                    (:replace(string-join($patients[hl7:id[@root='2.16.840.1.113883.2.4.6.3'][@extension=$patientId]]/hl7:Person/hl7:name//text(),' '),'\s+',' '):)
                    local:getHL7Name($patients[hl7:id[@root='2.16.840.1.113883.2.4.6.3'][@extension=$patientId]]/hl7:Person/hl7:name)
                ) else if ($message[.//(hl7:recordTarget|hl7:subject)/(hl7:Patient|hl7:patient)]) then (
                    (:replace(string-join(($message//(hl7:recordTarget|hl7:subject)/(hl7:Patient|hl7:patient)//hl7:name)[1]//text(),' '),'\s+',' '):)
                    local:getHL7Name(($message//(hl7:recordTarget|hl7:subject)/(hl7:Patient|hl7:patient)//hl7:name)[1])
                ) else ()
                
            (:get related messages info:)
            let $related        := 
                if ($message//hl7:queryByParameter) then (
                    $message/hl7:ControlActProcess/hl7:queryByParameter
                    
                ) else if ($message/hl7:acceptAckCode/@code='ALX') then (
                    <acknowledgement>{
                        for $response in $messages[hl7:acknowledgement/hl7:targetMessage/hl7:id[@root=$message/hl7:id/@root][@extension=$message/hl7:id/@extension]]
                        let $responseSender     :=
                            if ($response/hl7:sender/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']) then (
                                $response/hl7:sender/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension
                            ) else (
                                 ($response/hl7:sender/hl7:device/hl7:id)[1]/@extension
                            )
                        let $responseSenderName :=
                            if ($applications[@id=$responseSender][xis:name]) then (
                                $applications[@id=$responseSender]/xis:name
                            ) else (
                                (:replace(string-join(($response/hl7:sender/hl7:device//hl7:name)[1]//text(),' '),'\s+',' '):)
                                local:getHL7Name(($response/hl7:sender/hl7:device//hl7:name)[1])
                            )
                      return
                          $response/hl7:acknowledgement|<sender id="{$responseSender}" name="{$responseSenderName}"/>
                    }</acknowledgement>
                ) else if ($message//hl7:queryAck) then (
                    let $controlActAuthorId := $message/hl7:ControlActProcess/hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice/hl7:id[@root='2.16.528.1.1007.3.2']/@extension
                    return
                        <controlActAuthor id="{$controlActAuthorId}">{$applications[@systemId=$controlActAuthorId][1]}</controlActAuthor>
                ) else ()
            return
                <message file="{$fileName}" fileCreation="{$fileCreation}" xpath="{$messageXpath}" rootName="{$messageRoot}" messageName="{$messageName}" validationStatus="{$schemaValid}">
                    <sender id="{$sender}" name="{$senderName}"/>
                    <receiver id="{$receiver}" name="{$receiverName}"/>
                    <patient id="{$patientId}" name="{$patientName}"/>
                    {
                    $message/hl7:id|
                    $message/hl7:creationTime|
                    $related
                    }
                    <creationTime date="{$date}" time="{$time}"/>
                    <collection>{$fileCollection}</collection>
                </message>
        )
        else ()
    }
</messages>

(:<file name="{$file}" dateTime="{xmldb:created($collectionPath,$file)}" rootName="{doc(concat($collectionPath,'/',$file))/*/local-name()}"/>:)
