xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw, Alexander Henket, Kai U. Heitmann
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    
:)
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace f   = "urn:decor:REST:v1" at "get-message.xquery";

declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');

(: TODO: media-type beter zetten en XML declaration zetten bij XML output :)
(:declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes";:)

let $format             := request:get-parameter('format','xml')

let $searchRegistry     := request:get-parameter('registry',())[string-length()>0][1]
let $searchId           := request:get-parameter('id',())[string-length()>0][1]
let $searchName         := tokenize(lower-case(request:get-parameter('name',())[string-length()>0][1]),'\s')
let $searchStatus       := request:get-parameter('statusCode',())[string-length()>0][1]
let $language           := request:get-parameter('language',$get:strArtLanguage)[1]

let $maxResults         := xs:integer('50')
let $queryName          := 
    <query><bool>{
        for $term in $searchName return <wildcard occur="must">{concat($term,'*')}</wildcard>
    }</bool></query>
let $allRegistries      :=
    for $registry in collection($get:strOidsData)/myoidregistry
    return <registry name="{$registry/@name}" displayName="{$registry/registry/name/@value}"/>

let $resultOnRegistry   :=
    if (empty($searchRegistry)) then
        collection($get:strOidsData)/myoidregistry//oid
    else (
        collection($get:strOidsData)/myoidregistry[@name=$searchRegistry]//oid
    )

let $resultsOnId        := 
    if (empty($searchId)) then 
        $resultOnRegistry
    else (
        $resultOnRegistry[dotNotation/@value=$searchId] |
        $resultOnRegistry[starts-with(dotNotation/@value,concat($searchId,'.'))]
    )
    
let $resultsOnName      := 
    if (empty($searchName)) then 
        $resultsOnId
    else (
        for $oid in $resultsOnId[ft:query((description|symbolicName)/@value,$queryName)] 
        return $oid
    )
    
let $resultsOnStatus      := 
    if (empty($searchStatus)) then 
        $resultsOnName
    else (
        for $oid in $resultsOnName[status/@code=$searchStatus] 
        return $oid
    )

return 
    if (empty($searchId) and empty($searchName)) then (
        response:set-status-code(404), response:set-header('Content-Type','text/xml; charset=utf-8'), <error>{f:getMessage('errorRetrieveOIDNotEnoughParameters',$language)}</error>
    )
    else if (empty($resultsOnStatus)) then (
        response:set-status-code(404), response:set-header('Content-Type','text/xml; charset=utf-8'), <error>{f:getMessage('errorRetrieveOIDNoResults',$language),' ',if (request:exists()) then request:get-query-string() else()}</error>
    )
    else if ($format = 'xml') then (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        <result>{$resultsOnStatus}</result>
    ) 
    else if ($format = 'csv') then (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        <warning>{f:getMessage('errorNotImplementedYet',$language)}</warning>
    ) 
    else (
        response:set-header('Content-Type','text/html; charset=utf-8'),
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>OID {$searchId}</title>
                <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
                {
                    for $oid in $resultsOnStatus
                    return (
                    <h1>OID {data($oid/dotNotation/@value)}{if (data($oid/symbolicName/@value)) then concat(' - ',data($oid/symbolicName/@value)) else ('')}</h1>,
                    <p>{f:getMessage('goTo',$language)}<a href="OIDIndex{if ($language != '') then (concat('?language=',$language)) else ()}" alt="">index</a> - {f:getMessage('displayAs',$language)}<a href="RetrieveOID?id={$searchId}&amp;format=xml{if ($language != '') then (concat('&amp;language=',$language)) else ()}" alt="">XML</a></p>,
                    <div class="content">
                        <table>
                        <tr><th align="right">{f:getMessage('columnID',$language)}</th><td>{data($oid/dotNotation/@value)}</td></tr>
                        <tr><th align="right">{f:getMessage('registrationStatus',$language)}</th><td>{data($oid/status/@code)}</td></tr>
                        <tr><th align="right">{f:getMessage('titleOIDRegistry',$language)}</th><td>{data($oid/parent::registry/name/@value)}</td></tr>
                        </table>
                        <p/>
                        <table class="values" id="codeList">
                            <thead>
                                <tr>
                                    <th>{f:getMessage('columnRealm',$language)}</th>
                                    <th>{f:getMessage('columnCategory',$language)}</th>
                                    <th>{f:getMessage('columnDescription',$language)}</th>
                                    <th>{f:getMessage('columnResponsibleAuthority',$language)}</th>
                                    <th>{f:getMessage('columnResponsibleAuthorityStatus',$language)}</th>
                                    <th>{f:getMessage('columnResponsibleAuthorityEffectiveTime',$language)}</th>
                                    <th>{f:getMessage('columnExtraProperties',$language)}</th>
                                    <th>{f:getMessage('columnReference',$language)}</th>
                                    <th>{f:getMessage('columnRegistrationAuthority',$language)}</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>{data($oid/realm/@code)}</td>
                                    <td>{data($oid/category/@code)}</td>
                                    <td>{
                                        for $description in $oid/description
                                        return (
                                            <p>{concat(data($description/@language),': ',data($description/@value))}</p>
                                        )
                                    }</td>
                                    <td>{data($oid/responsibleAuthority/code/@code)} - {data($oid/responsibleAuthority/scopingOrganization/name/part/@value)}</td>
                                    <td>{data($oid/responsibleAuthority/statusCode/@code)}</td>
                                    <td>{f:getMessage('effectiveTimeFrom',$language,data($oid/responsibleAuthority/validTime/low/@value))}{
                                        if ($oid/responsibleAuthority/validTime/high/@value) then
                                            f:getMessage('effectiveTimeTo',$language,data($oid/responsibleAuthority/validTime/high/@value))
                                        else ()
                                    }</td>
                                    <td>{
                                        for $additionalProperty in $oid/additionalProperty 
                                        return
                                            <p>{concat(data($additionalProperty/attribute/@value),'=',data($additionalProperty/value/@value))}</p>
                                    }</td>
                                    {        
                                        if ($oid/reference)
                                        then
                                            <td><a href="{data($oid/reference/ref/@value)}">{data($oid/reference/type/@code)}</a> {f:getMessage('lastVisit',$language)}{data($oid/reference/lastVisitedDate/@value)}</td>
                                        else
                                            <td></td>
                                     }
                                    <td>{data($oid/registrationAuthority/code/@code)} - {data($oid/registrationAuthority/scopingOrganization/name/part/@value)}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    )
                }
            </body>
        </html>
        (: html :)
    )
 
 (:
        <oid>
        <dotNotation value="1.0.3166.1.2.2"/>
        <category code="LNS"/>
        <status code="completed"/>
        <realm code="UV"/>
        <description>
            <text language="en-US" value="ISO 3166 2 alpha Landcodes" identifierName="ISO 3166 Alpha 2"/>
            <text language="nl-NL" value="ISO 3166 2 alpha Landcodes" identifierName="ISO 3166 Alpha 2"/>
        </description>
        <registrationAuthority>
            <code code="OBO"/>
            <scopingOrganization>
                <name>
                    <part value="Nictiz"/>
                </name>
            </scopingOrganization>
        </registrationAuthority>
        <responsibleAuthority>
            <code code="PRI"/>
            <statusCode code="completed"/>
            <validTime>
                <low value="20111228"/>
            </validTime>
            <scopingOrganization>
                <name>
                    <part value="ISO"/>
                </name>
            </scopingOrganization>
        </responsibleAuthority>
        <additionalProperty>
            <attribute value="purpose"/>
            <value value="codesystem"/>
        </additionalProperty>
        <reference>
            <ref value="http://www.iso.org/iso/english_country_names_and_code_elements"/>
            <type code="LINK"/>
            <lastVisitedDate value="20111228"/>
        </reference>
    </oid>
        :)