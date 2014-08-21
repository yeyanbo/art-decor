xquery version "3.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace vs  = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";
declare namespace xs        = "http://www.w3.org/2001/XMLSchema";

(:acquire lock. new if we are a project author AND (the owner of the current OR if there is no lock yet), don't create lock otherwise:)
declare function local:acquireLock($decor as element(), $username as xs:string, $id as xs:string, $effectiveDate as xs:string) as element() {
    let $lock       := $get:colArtResources//lock[@type='VS'][@ref=$id][@effectiveDate=$effectiveDate]
    
    return
        if (not($decor/project/author[@username=$username])) then
            <false/>
        else if (empty($lock) or $lock/@user=$username) then
            let $newLock    := <lock type="VS" ref="{$id}" effectiveDate="{$effectiveDate}" user="{$username}" userName="{$decor/project/author[@username=$username]/text()}" since="{current-dateTime()}"/>
            let $deleteLock := if ($lock) then update delete $lock else ()
            let $insertLock := update insert $newLock into $get:colArtResources//decorLocks
            
            return <true>{$newLock}</true>
        else (
            <false>{$lock}</false>
        )
};

let $projectPrefix  := if (request:exists()) then request:get-parameter('project',()) else ()
let $id             := if (request:exists()) then request:get-parameter('id',()) else ()
let $effectiveDate  := if (request:exists()) then request:get-parameter('effectiveDate',()) else ()
let $mode           := if (request:exists()) then request:get-parameter('mode',()) else ('new')

let $decor          := $get:colDecorData//decor[project/@prefix=$projectPrefix]
let $language       := if (request:exists()) then request:get-parameter('language',$decor/project/@defaultLanguage) else ($decor/project/@defaultLanguage)

(: username for permission check and use in lock:)
let $username       := xmldb:get-current-user()

let $valueset       := (vs:getValueSetById($id,$effectiveDate,$projectPrefix)//valueSet[@id][@effectiveDate])[1]
let $lockAcquired   := if ($mode='edit') then local:acquireLock($decor, $username, $id, $effectiveDate) else (<true/>)

let $response :=
    (:check if user is author:)
    if ($lockAcquired/self::false) then
        <valueSet>{if ($lockAcquired/*) then $lockAcquired/* else 'NO PERMISSION'}</valueSet>
    else if (not($mode=('edit','new','version','adapt'))) then
        <valueSet>{'MODE ''',$mode,''' UNSUPPORTED'}</valueSet>
    else (
        <valueSet projectPrefix="{$projectPrefix}" baseId="{$decor/ids/baseId[@type='VS']/@id}">
        {
            attribute statusCode {if ($mode='edit') then $valueset/@statusCode else 'new'},
            $valueset/(@* except (@projectPrefix|@baseId|@statusCode)),
            for $att in ('displayName','versionLabel')
            return
                if (not($valueset/@*[name()=$att])) then
                    attribute {$att} {''}
                else()
        }
        <edit edit="edit"/>
        {
            $lockAcquired/*
        }
        {
            for $sourceCodeSystem in (distinct-values($valueset/conceptList/concept/@codeSystem),distinct-values($valueset/conceptList/exception/@codeSystem))
            let $codeSystemName := art:getNameForOID($sourceCodeSystem,$language,$projectPrefix)
            return
                <sourceCodeSystem id="{$sourceCodeSystem}" identifierName="{$codeSystemName}"/>
        }
        {
            for $desc in $valueset/desc
            return
                art:serializeNode($desc)
        }
        {
            if (not($valueset/desc)) then (<desc language="{$language}"/>) else ()
        }
        {
            if ($valueset/publishingAuthority) then $valueset/publishingAuthority else (
                <publishingAuthority id="" name="">
                    <addrLine type=""/>
                </publishingAuthority>
            )
        }
        {
            if ($valueset/endorsingAuthority) then $valueset/endorsingAuthority else (
                <endorsingAuthority id="" name="">
                    <addrLine type=""/>
                </endorsingAuthority>
            )
        }
        {
            if ($valueset/copyright) then $valueset/copyright else (
                <copyright/>
            )
        }
        {
            if ($valueset/revisionHistory) then (
                for $revisionHistory in $valueset/revisionHistory
                return
                <revisionHistory date="{$revisionHistory/@date}" by="{$revisionHistory/@by}">
                {
                    for $desc in $revisionHistory/desc
                    return
                        art:serializeNode($desc)
                }
                </revisionHistory>
            ) else (
                <revisionHistory date="" by="">
                    <desc language="{$language}"/>
                </revisionHistory>
            )
        }
        <conceptList>
        {
            for $concept in $valueset/conceptList/concept
            return
                <concept code="{$concept/@code}" codeSystem="{$concept/@codeSystem}" codeSystemName="{$concept/@codeSystemName}" codeSystemVersion="{$concept/@codeSystemVersion}" displayName="{$concept/@displayName}" level="{$concept/@level}" type="{$concept/@type}">
                {
                    for $desc in $concept/desc
                    return
                        art:serializeNode($desc)
                }
                </concept>
        }
        {
            for $include in $valueset/conceptList/include
            return
                <include ref="{$include/@ref}" flexibility="{$include/@flexibility}" exception="{$include/@exception}">
                {
                    for $desc in $include/desc
                    return
                        art:serializeNode($desc)
                }
                </include>
        }
        {
            for $exception in $valueset/conceptList/exception
            return
                <exception code="{$exception/@code}" codeSystem="{$exception/@codeSystem}" codeSystemName="{$exception/@codeSystemName}" codeSystemVersion="{$exception/@codeSystemVersion}" displayName="{$exception/@displayName}" level="{$exception/@level}" type="{$exception/@type}">
                {
                    for $desc in $exception/desc
                    return
                        art:serializeNode($desc)
                }
                </exception>
        }
        </conceptList>
        </valueSet>
    )
return
    <valueSetVersions projectPrefix="{$projectPrefix}">{$response}</valueSetVersions>