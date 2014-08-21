xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
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
   Xquery for retrieving concept for editing
   Input:
   - concept/@id
   - concept/@effectiveDate
   - language code
   - optional breakLock=true
   Returns
   If a lock is present and breakLock=false:    the existing lock element
   It a lock is present and breakLock=true:     the concept with the new lock element
   If no lock is present:                       the concept with the new lock element
:)
import module namespace get    = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art    = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace aduser = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";

declare function local:getConceptForEdit($concept as element(),$lock as element(),$language as xs:string,$deInherit as xs:boolean,$generateConceptListIds as xs:boolean,$deRefId as xs:string?) as element() {
let $editMode               := if ($concept/@statusCode=('new','draft')) then 'edit' else if ($concept/@statusCode='final') then 'move' else ()
let $deRefId                := if ($concept/inherit) then () else ($deRefId)
let $inheritedConcept       := if ($concept/inherit) then (art:getOriginalConcept($concept/inherit)//concept)[1] else ()
let $localInherit           := if ($concept/inherit) then ($inheritedConcept/parent::inherit/@prefix=$concept/ancestor::decor/project/@prefix) else (false())
let $copyFromConcept        := if ($concept/inherit) then $inheritedConcept else $concept
let $baseId                 := if ($concept/inherit) then (string-join(tokenize($inheritedConcept/@id,'\.')[position()!=last()],'.')) else ()
let $baseIdPrefix           := if ($inheritedConcept) then $get:colDecorData//baseId[@id=$baseId]/@prefix else ()
let $inheritedAssociations  := if ($inheritedConcept or $deRefId) then art:getConceptAssociations($concept/@id) else ()
return
    <concept id="{$concept/@id}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}"
             expirationDate="{$concept/@expirationDate}" officialReleaseDate="{$concept/@officialReleaseDate}"
             versionLabel="{$concept/@versionLabel}">
    {
        if ($concept/inherit) then (
            attribute type {$inheritedConcept/@type}
        )
        else (
            attribute type {$concept/@type}
        )
    }
    <edit mode="{$editMode}" deinherit="{$deInherit}"/>
    {
        $lock
        ,
        if ($concept/inherit and not($deInherit)) then
            <inherit>
            {
                $concept/inherit/(@ref|@effectiveDate),
                $inheritedConcept/parent::inherit/@prefix,
                $inheritedConcept/parent::inherit/@datasetId,
                attribute iType {$inheritedConcept/@type}, 
                attribute iStatusCode {$inheritedConcept/@statusCode}, 
                attribute iExpirationDate {$inheritedConcept/@expirationDate},
                attribute iVersionLabel {$inheritedConcept/@versionLabel},
                attribute iddisplay {art:getNameForOID($concept/inherit/@ref,$language,$inheritedConcept/parent::inherit/@prefix)},
                attribute localInherit {$localInherit},
                $concept/inherit/*
            }
            </inherit>
        else ()
        ,
        if ((not($concept/inherit) or $deInherit) and not($copyFromConcept/name[@language=$language])) then
            <name language="{$language}"/>
        else (
            for $name in $copyFromConcept/name
            return
            art:serializeNode($name)
        )
        ,
        if ((not($concept/inherit) or $deInherit) and not($copyFromConcept/desc[@language=$language])) then
            <desc language="{$language}"/>
        else (
            for $desc in $copyFromConcept/desc
            return
            art:serializeNode($desc)
        )
        ,
        if ((not($concept/inherit) or $deInherit) and not($copyFromConcept/source[@language=$language])) then
            <source language="{$language}"/>
        else (
            for $source in $copyFromConcept/source
            return
            art:serializeNode($source)
        )
        ,
        if ((not($concept/inherit) or $deInherit) and not($copyFromConcept/rationale[@language=$language])) then
            <rationale language="{$language}"/>
        else (
            for $rationale in $copyFromConcept/rationale
            return
            art:serializeNode($rationale)
        )
        ,
        if (not($concept/comment[@language=$language])) then
            <comment language="{$language}"/>
        else (
            for $node in $concept/comment
            return
            art:serializeNode($node)
        )
        ,
        if ($concept/inherit) then
            for $node in $inheritedConcept/comment
            let $serializedNode := art:serializeNode($node)
            return
                if ($deInherit) then
                    $serializedNode
                else (
                    <inheritedComment>{$serializedNode/@*, $serializedNode/node()}</inheritedComment>
                )
        else ()
        ,
        if ((not($concept/inherit) or $deInherit) and not($copyFromConcept/operationalization[@language=$language])) then
            <operationalization language="{$language}"/>
        else (
            for $operationalization in $copyFromConcept/operationalization
            return
            art:serializeNode($operationalization)
        )
    }
    {
        if ($concept/inherit and $deInherit) then
            (: create terminology association for concept if present for inherited concept:)
            for $terminologyAssociation in $inheritedAssociations/association[@conceptId=$inheritedConcept/@id]
            return
                <terminologyAssociation conceptId="{$concept/@id}" effectiveDate="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}">
                {
                    $terminologyAssociation/(@*[string-length()>0][name()=('code','codeSystem','codeSystemName','codeSystemVersion','displayName','valueSet','flexibility')])
                }
                </terminologyAssociation>
        else ()
    }
    {
        if ((not($concept/inherit) or $deInherit) and $concept[@type='item'][not(valueDomain)]) then
            <valueDomain type="count">
                <property unit="" minInclude="" maxInclude="" fractionDigits="" timeStampPrecision="YMD" default="" fixed="" minLength="" maxLength=""/>
                <conceptList id="{concat($concept/@id,'.0')}"/>
                <example type="neutral" caption=""/>
            </valueDomain>
        else ()
        ,
        for $valueDomain at $vdpos in $copyFromConcept/valueDomain
        return
        <valueDomain type="{$valueDomain/@type}">
        {
            if ((not($concept/inherit) or $deInherit) and not($valueDomain/property[@*[string-length()>0]])) then
                <property unit="" minInclude="" maxInclude="" fractionDigits="" timeStampPrecision="" default="" fixed="" minLength="" maxLength=""/>
            else (
                for $property in $valueDomain/property[@*[string-length()>0]]
                return
                <property unit="{$property/@unit}" minInclude="{$property/@minInclude}" maxInclude="{$property/@maxInclude}" fractionDigits="{$property/@fractionDigits}" timeStampPrecision="{$property/@timeStampPrecision}" default="{$property/@default}" fixed="{$property/@fixed}" minLength="{$property/@minLength}" maxLength="{$property/@maxLength}">
                {
                    $property/*
                }
                </property>
            )
        }
        {
            for $conceptList at $clpos in $valueDomain/conceptList
            (: unsupported fancy style:
                valueDomain 1 conceptList 1 == 11
                valueDomain 1 conceptList 2 == 12
                valueDomain 2 conceptList 1 == 21 :)
            (: normal style: 
                if there's only 1 valueDomain containing 1 conceptList, just use 0 :)
            let $newclid                := 
                if (count($copyFromConcept/valueDomain/conceptList)=1) 
                then concat($concept/@id,'.','0') 
                else concat($concept/@id,'.',$vdpos, $clpos)
            
            (: could be @ref :)
            let $originalConceptList    := art:getOriginalConceptList($conceptList)
            return (
                <conceptList>
                {
                    if ($conceptList[@ref=$deRefId] or ($deInherit and $generateConceptListIds)) then (
                        attribute id {$newclid},
                        attribute oldid {$conceptList/(@id|@ref)},
                        (: create terminology association for concept if present for inherited concept:)
                        for $terminologyAssociation in $inheritedAssociations/association[@conceptId=$originalConceptList/@id]
                        return
                            <terminologyAssociation conceptId="{$newclid}" effectiveDate="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}">
                            {
                                $terminologyAssociation/(@*[string-length()>0][name()=('code','codeSystem','codeSystemName','codeSystemVersion','displayName','valueSet','flexibility')])
                            }
                            </terminologyAssociation>
                    ) 
                    else if ($deInherit) then (
                        attribute ref {$conceptList/(@id|@ref)}
                    )
                    else ($conceptList/(@id|@ref))
                }
                {
                    for $conceptListConcept at $clcpos in $originalConceptList/concept
                    let $newclcid := 
                        if (count($copyFromConcept/valueDomain/conceptList)=1) 
                        then concat($concept/@id,'.',$clcpos)
                        else concat($newclid,'.',$clcpos)
                    
                    return (
                        if ($conceptList[@ref=$deRefId] or ($deInherit and $generateConceptListIds)) then
                            (: create terminology association for concept if present for inherited concept:)
                            for $terminologyAssociation in $inheritedAssociations/association[@conceptId=$conceptListConcept/@id]
                            return
                                <terminologyAssociation conceptId="{$newclcid}" effectiveDate="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}">
                                {
                                    $terminologyAssociation/(@*[string-length()>0][name()=('code','codeSystem','codeSystemName','codeSystemVersion','displayName','valueSet','flexibility')])
                                }
                                </terminologyAssociation>
                        else ()
                        ,
                        <concept>
                        {
                            if ($conceptList[@ref=$deRefId] or ($deInherit and $generateConceptListIds)) then (
                                attribute id {$newclcid}
                            ) else ($conceptListConcept/(@id|@ref))
                            ,
                            attribute exception {$conceptListConcept/@exception='true'}
                            ,
                            $conceptListConcept/(@* except (@id|@ref|@exception))
                        }
                        {
                            $conceptListConcept/name,
                            $conceptListConcept/desc,
                            if (not($conceptListConcept/desc[@language=$language])) then
                                <desc language="{$language}"/>
                            else ()
                        }
                        </concept>
                    )
                }
                </conceptList>
            )
        }
        {
            if ((not($concept/inherit) or $deInherit) and not($valueDomain/example)) then
                <example type="neutral" caption=""/>
            else (
                for $example in $valueDomain/example
                return
                <example type="{$example/@type}" caption="{$example/@caption}">{$example/node()}</example>
            )
            ,
            $valueDomain/(* except (property|conceptList|example))
        }
        </valueDomain>
        ,
        $concept/history
    }
    </concept>
};

(: variables for request parameters:)
let $id                         := request:get-parameter('id','')
let $effectiveDate              := request:get-parameter('effectiveDate','')
let $breakLock                  := request:get-parameter('breakLock','false')
(:  when this variable is true, we copy properties from the concept that this concept 
    used to inherit from so they become copied properties from the this concept:)
let $deInherit                  := xs:boolean(request:get-parameter('deInherit','false'))
let $generateConceptListIds     := xs:boolean(request:get-parameter('generateIds','true'))

(:  when this variable is valued, we are instructed to generate new ids for a certain conceptList[@ref]
    this variable can only be used if the concept itself does not inherit
:)
let $deRefId                    := request:get-parameter('deRefId',())

(: username and user info for use in conceptLock:)
let $username         := xmldb:get-current-user()
let $userDisplayName  := aduser:getUserDisplayName($username)

(: TODO add check if user is author in decor project :)

(: check if concept is locked :)
let $lock             := $get:colArtResources//conceptLock[@ref=$id][@effectiveDate=$effectiveDate]
let $concept          := $get:colDecorData//concept[@id=$id][@effectiveDate=$effectiveDate][not(ancestor::history)]
let $language         := request:get-parameter('language',$concept/ancestor::decor/project/@defaultLanguage/string())

let $response :=
    if (empty($lock) or $lock/@user=$username or $breakLock='true') then
        let $newLock    := <conceptLock ref="{$id}" effectiveDate="{$effectiveDate}" user="{$username}" userName="{$userDisplayName}" since="{current-dateTime()}"/>
        let $deleteLock := if ($lock) then update delete $lock else ()
        let $insertLock := update insert $newLock into $get:colArtResources//decorLocks
        return
        local:getConceptForEdit($concept,$newLock,$language,$deInherit,$generateConceptListIds,$deRefId)
    else (
        <concept>{$lock}</concept>
    )

return
    $response
