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
import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../../../art/api/api-server-settings.xqm";
import module namespace msg      = "urn:decor:REST:v1" at "get-message.xquery";

(:declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=no";:)
declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=no indent=no 
        doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Transitional//EN
        doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd";

declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');
declare variable $strArtURL      := adserver:getServerURLArt();

declare function local:isWithinDateRange($input as xs:string,$lowBoundary as xs:string?,$highBoundary as xs:string?) as xs:boolean {
    let $i := number(replace($input,'^\d',''))
    let $l := number(replace($lowBoundary,'^\d',''))
    let $h := number(replace($highBoundary,'^\d',''))
    return
    if (empty($input) or string-length($i) < 8) then (
        true()
    ) else if (empty($lowBoundary) and empty($highBoundary)) then (
        true()
    ) else if (not(empty($lowBoundary)) and empty($highBoundary) and $i >= $l) then (
        true()
    ) else if (not(empty($highBoundary)) and empty($lowBoundary) and $i <= $h) then (
        true()
    ) else if (not(empty($lowBoundary) or empty($highBoundary)) and $i >= $l and $i <= $h) then (
        true()
    ) else (
        false()
    )
};

(: TODO: media-type beter zetten en XML declaration zetten bij XML output :)
(:declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes";:)

let $searchRegistry     := request:get-parameter('registry',())[string-length()>0][1]
let $searchId           := request:get-parameter('id',())[string-length()>0][1]
let $searchName         := tokenize(lower-case(request:get-parameter('name',())[string-length()>0][1]),'\s')
let $searchAuthority    := tokenize(lower-case(request:get-parameter('assigningAuthority',())[string-length()>0][1]),'\s')
let $effectiveDate      := request:get-parameter('effectiveDate',())[string-length()>0][1]
let $language           := request:get-parameter('language',$get:strArtLanguage)[1]

let $maxResults         := xs:integer('50')
let $queryName          := 
    <query><bool>{
        for $term in $searchName return <wildcard occur="must">{concat($term,'*')}</wildcard>
    }</bool></query>
let $queryAuthority     := 
    <query><bool>{
        for $term in $searchAuthority return <wildcard occur="must">{concat($term,'*')}</wildcard>
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

let $resultsOnAuthority :=
    if (empty($searchAuthority)) then
        $resultsOnName
    else if (empty($effectiveDate)) then (
        for $oid in $resultsOnName[ft:query(responsibleAuthority/scopingOrganization/name/part/@value,$queryAuthority)] 
        return $oid
    ) else (
        for $oid in $resultsOnName[ft:query(responsibleAuthority/scopingOrganization/name/part/@value,$queryAuthority)]
        let $isWithinRange := local:isWithinDateRange($effectiveDate,$oid/responsibleAuthority/validTime/low/@value/string(),$oid/responsibleAuthority/validTime/high/@value/string())
        return if ($isWithinRange) then $oid else ()
    )

let $logo         := 'nictiz.jpg'
let $url          := ()

let $lblLanguage          := msg:getMessage('language',$language)
let $lblEffectiveTimeFrom := msg:getMessage('effectiveTimeFrom',$language)
let $lblEffectiveTimeTo   := msg:getMessage('effectiveTimeTo',$language)
let $resultCount          := count($resultsOnAuthority)

return (
    response:set-header('Content-Type','text/html; charset=utf-8'),
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>{msg:getMessage('titleOIDIndex',$language)}</title>
        <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
    </head>
    <body onload="javascript:document.getElementById('searchName').focus();">
        <a name="top"></a>
        <table width="100%">
            <tbody>
                <tr>
                    <td align="left">
                        <h1>{msg:getMessage('titleOIDIndex',$language)}</h1>
                    </td>
                    <td align="right">
                    {if ($logo and $url) then 
                        <a href="{$url}">
                            <img src="{$resourcePath}/logos/{$logo}" alt="" title="{$url}" height="50px"/>
                        </a>
                     else if ($logo) then
                        <img src="{$resourcePath}/logos/{$logo}" alt="" height="50px"/>
                     else
                        <a href="http://www.art-decor.org">
                            <img src="{$resourcePath}/logos/art-decor-logo-small.jpg" alt="www.art-decor.org" title="http://www.art-decor.org" height="50px"/>
                        </a>
                    }
                    </td>
                </tr>
                <tr>
                    <td>
                        <form name="input">
                            <input type="hidden" name="language" value="{$language}"/>
                            <input type="hidden" id="registry" name="registry" value="{$searchRegistry}"/>
                            <span style="margin-left: 5px;">{msg:getMessage('columnRegistry',$language)}: </span>
                            <select id="registrySelector" onchange="javascript:document.getElementById('registry').value=this.options[this.selectedIndex].value;">
                            <option value="">{msg:getMessage('OptionAll',$language)}</option>
                            {
                                for $registry in $allRegistries
                                order by lower-case($registry/@name)
                                return
                                    <option value="{$registry/@name/string()}">
                                    {
                                        if ($registry/@name=$searchRegistry) 
                                        then attribute {'selected'} {'true'} 
                                        else (),
                                        $registry/@displayName/string()
                                    }
                                    </option>
                            }
                            </select>
                            <br/>
                            <span style="margin-left: 5px;">{msg:getMessage('columnOID',$language)}: </span>
                            <input type="text" id="searchId" name="id" value="{$searchId}"/>
                            <span style="margin-left: 5px;">{msg:getMessage('columnName',$language)}: </span>
                            <input type="text" id="searchName" name="name" value="{$searchName}"/>
                            <span style="margin-left: 5px;">{msg:getMessage('columnResponsibleAuthority',$language)}: </span>
                            <input type="text" id="searchAuthoriy" name="assigningAuthority" value="{$searchAuthority}"/>
                            <!--<span style="margin-left: 5px;">{replace(msg:getMessage('columnResponsibleAuthorityEffectiveTime',$language),':','')}: </span><input type="text" name="effectiveDate" value="{$effectiveDate}"/>-->
                            <input type="submit" value="{msg:getMessage('Find',$language)}" onclick="location.href=window.location.pathname+'?language={$language}"/>
                            {if ($resultCount>0) then (concat(' (',msg:getMessage('FoundXResults',$language,$resultCount),')')) else ()}
                        </form>
                    </td>
                    <td align="right">
                        <img src="{$strArtURL}img/flags/nl.png" onclick="location.href=window.location.pathname+'?language=nl-NL{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                        <img src="{$strArtURL}img/flags/de.png" onclick="location.href=window.location.pathname+'?language=de-DE{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                        <img src="{$strArtURL}img/flags/us.png" onclick="location.href=window.location.pathname+'?language=en-US{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                    </td>
                </tr>
            </tbody>
        </table>
    {
        if (empty($resultsOnAuthority)) then (
            <div class="content">
            {
                msg:getMessage('errorRetrieveOIDNoResults',$language),' ',if (request:exists()) then request:get-query-string() else()
            }
            </div>
        ) else if ($resultCount>$maxResults) then (
            <div class="content">
            {
                msg:getMessage('warningRetrieveOIDMaxResultsExceeded',$language, string($maxResults), string($resultCount))
            }
            </div>
        ) else ()
    }
        <div class="content">
            <table class="values" id="oidList">
                <thead>
                    <tr>
                        <th>XML</th>
                        <th>HTML</th>
                        <th>{msg:getMessage('columnOID',$language)}</th>
                        <th>{msg:getMessage('columnSymbolicName',$language)}</th>
                        <th>{msg:getMessage('columnStatus',$language)}</th>
                        <th>{msg:getMessage('columnRealm',$language)}</th>
                        <th>{msg:getMessage('columnDescription',$language)}</th>
                        <th>{msg:getMessage('columnResponsibleAuthority',$language)}</th>
                        <th>{msg:getMessage('columnResponsibleAuthorityEffectiveTime',$language)}</th>
                        <th>{msg:getMessage('columnRegistrationAuthority',$language)}</th>
                    </tr>
                </thead>
                <tbody>
                {
                    for $oid in subsequence($resultsOnAuthority,1,$maxResults)
                    let $registry := $oid/ancestor::myoidregistry
                    order by $oid/dotNotation/@value
                    return 
                        <tr style="background-color:white" onMouseover="this.style.backgroundColor='lightblue';" onMouseout="this.style.backgroundColor='white';">
                            <td><a href="RetrieveOID?registry={$registry/@name/string()}&amp;id={$oid/dotNotation/@value/string()}&amp;format=xml">xml</a></td>
                            <td><a href="RetrieveOID?registry={$registry/@name/string()}&amp;id={$oid/dotNotation/@value/string()}&amp;format=html{if ($language != '') then (concat('&amp;language=',$language)) else ()}">html</a></td>
                            <td>{$oid/dotNotation/@value/string()}</td>
                            <td>{$oid/symbolicName/@value/string()}</td>
                            <td>{$oid/status/@code/string()}</td>
                            <td>{$oid/realm/@code/string()}</td>
                            <td>{
                                for $description in $oid/description 
                                return (
                                    <p>{$lblLanguage,$description/@language/string(),': ',$description/@value/string()}</p>
                                )
                            }</td>
                            <td>{$oid/responsibleAuthority/code/@code/string()} - {$oid/responsibleAuthority/scopingOrganization/name/part/@value/string()}</td>
                            <td>
                            {
                                if ($oid/responsibleAuthority/validTime/low/@value) then (
                                    $lblEffectiveTimeFrom,$oid/responsibleAuthority/validTime/low/@value/string()
                                ) else ()
                            }
                            {
                                if ($oid/responsibleAuthority/validTime/high/@value) then (
                                    $lblEffectiveTimeTo,$oid/responsibleAuthority/validTime/high/@value/string()
                                ) else ()
                            }</td>
                            <td>{$oid/registrationAuthority/code/@code/string()} - {$oid/registrationAuthority/scopingOrganization/name/part/@value/string()}</td>
                        </tr>
                }
                </tbody>
            </table>
        </div>
    </body>
</html>
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