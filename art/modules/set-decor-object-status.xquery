xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
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
   Xquery for setting statusCode of decor object
   Input: post of statusChange element:
   <statusChange ref="2.16.840.1.113883.3.1937.99.62.3.11.6" effectiveDate="2013-09-24T14:32:15" statusCode="final" versionLabel="Test" expirationDate="2013-10-31" actionText="Status op 'Definitief' zetten"/>
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";

(:
:   The UI has dealt with whether or not this status transition is allowable, e.g. don't go from deprecated to draft.
:   We get these properties to set:
:   <statusChange ref="object-id" effectiveDate="object-effectiveDate?" statusCode="xs:string" versionLabel="xs:sting?" expirationDate="xs:dateTime?" recurse="true|false"/>
:
:   Step 1: find object
:           if not: <response>NOT FOUND</response>
:   Step 2: check if user is author in object project
:           if not: <response>NO PERMISSION</response>
:   Step 3: check if object has lock set and if @recurse='true' check all underlying objects
:           recursion if only applicable to dataset|concept|scenario|transaction
:           if lock: <response>{first-lock}</response>
:   Step 4: apply status/versionLabel/expirationDate
:           statusCode is added/updated (assumed to be valued)
:           versionLabel/expirationDate is added/updated if valued, or deleted otherwise
:           recursion is applied if @recurse='true', but only if the child object 
:           (concept|transaction) matches the statusCode of the main object
:
:   So if the main object was draft, then recursion stops when the first @statusCode!=draft 
:   is encounted. This is not considered an error so the user needs to check before/after 
:   calling this function
:)

declare function local:applyStatusProperties($object as element(), $originalStatus as xs:string?, $newStatus as xs:string?, $newExpirationDate as xs:string?, $newVersionLabel as xs:string?, $recurse as xs:boolean) as element()*{
    if ($object/@statusCode) then
        update value $object/@statusCode with $newStatus
    else (
        update insert attribute statusCode {$newStatus} into $object
    ),
    if ($newVersionLabel) then
        if ($object/@versionLabel) then
            update value $object/@versionLabel with $newVersionLabel
        else(
            update insert attribute versionLabel {$newVersionLabel} into $object
        )
    else (
        update delete $object/@versionLabel
    ),
    if ($newExpirationDate) then
        if ($object/@expirationDate) then
            update value $object/@expirationDate with $newExpirationDate
        else (
            update insert attribute expirationDate {$newExpirationDate} into $object
        )
    else(
        $object/@expirationDate
    )
    ,
    if ($object/self::transaction[not(@effectiveDate)]) then
        update insert attribute effectiveDate {($object/ancestor-or-self::*[@effectiveDate]/@effectiveDate)[last()]} into $object
    else ()
    ,
    (:do recursion, but stop as soon we get to an artifact with a different status than our main artifact to respect the status machine:)
    if ($recurse) then (
        if ($object[name()=('dataset','concept')]) then
            for $child in $object/concept[@statusCode=$originalStatus]
            return local:applyStatusProperties($child,$originalStatus,$newStatus,$newExpirationDate,$newVersionLabel,$recurse)
        else if ($object[name()=('scenario','transaction')]) then
            for $child in $object/transaction[@statusCode=$originalStatus]
            return local:applyStatusProperties($child,$originalStatus,$newStatus,$newExpirationDate,$newVersionLabel,$recurse)
        else ()
    ) else ()
    ,
    <object>{$object/@*}</object>
};

declare function local:checkLock($object as element()?, $recurse as xs:boolean) as element()* {
    if ($object/@effectiveDate[string-length()>0]) then
        ($get:colArtResources//conceptLock[@ref=$object/@id][@effectiveDate=$object/@effectiveDate] |
         $get:colArtResources//valuesetLock[@ref=$object/@id][@effectiveDate=$object/@effectiveDate] |
         $get:colArtResources//lock[@ref=$object/@id][@effectiveDate=$object/@effectiveDate])
    else (
        ($get:colArtResources//conceptLock[@ref=$object/@id] |
         $get:colArtResources//valuesetLock[@ref=$object/@id] |
         $get:colArtResources//lock[@ref=$object/@id])
    )
    ,
    if ($recurse) then (
        if ($object[name()=('dataset','concept')]) then
            for $child in $object/concept
            return local:checkLock($child,$recurse)
        else if ($object[name()=('scenario','transaction')]) then
            for $child in $object/transaction
            return local:checkLock($child,$recurse)
        else ()
    ) else ()
};

let $statusChange   := if (request:exists()) then request:get-data()/statusChange else ()

(:get object for reference:)
let $object         :=
    if ($statusChange/@effectiveDate[string-length()>0]) then
        $get:colDecorData//*[@id=$statusChange/@ref][@effectiveDate=$statusChange/@effectiveDate][not(ancestor::history)]
    else (
        $get:colDecorData//*[@id=$statusChange/@ref][self::transaction[not(@effectiveDate)]][not(ancestor::history)]
    )
(:get decor file containing object for permission check:)
let $decor          := $object/ancestor::decor
(: get user for permission check:)
let $user           := xmldb:get-current-user()

let $recurse        := if ($statusChange/@recurse castable as xs:boolean) then xs:boolean($statusChange/@recurse) else (false())
let $statusCode     := if (string-length($statusChange/@statusCode)>0) then $statusChange/@statusCode else ()
let $versionLabel   := if (string-length($statusChange/@versionLabel)>0) then $statusChange/@versionLabel else ()
let $expirationDate := 
    if ($statusChange/@expirationDate castable as xs:dateTime) 
    then $statusChange/@expirationDate
    else if ($statusChange/@expirationDate castable as xs:date)
    then concat($statusChange/@expirationDate,'T00:00:00')
    else ()
let $locks          := local:checkLock($object,$recurse)

let $statusUpdate   :=
    if ($object) then
        if ($user=$decor/project/author/@username) then (
            if ($locks) then (
                <response>{$locks}</response>
            ) else (
                let $x  := local:applyStatusProperties($object,$object/@statusCode,$statusCode,$expirationDate,$versionLabel,$recurse)
                return
                <response>OK</response>
            )
        )
        else(<response>NO PERMISSION</response>)
    else(<response>NOT FOUND</response>)

return
$statusUpdate