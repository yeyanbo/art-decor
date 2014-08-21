xquery version "3.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Marc de Graauw, Alexander Henket, Gerrit Boers
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)

import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../../../art/api/api-server-settings.xqm";
import module namespace vs       = "http://art-decor.org/ns/decor/valueset" at "../../../art/api/api-decor-valueset.xqm";
import module namespace msg      = "urn:decor:REST:v1" at "get-message.xquery";

declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');
declare variable $strArtURL      := adserver:getServerURLArt();

let $format           := if (request:exists() and string-length(request:get-parameter('format','')[1])>0) then request:get-parameter('format','html')[1] else ('html')
let $language         := if (request:exists() and string-length(request:get-parameter('language','')[1])>0) then request:get-parameter('language',$get:strArtLanguage)[1] else ($get:strArtLanguage)

let $id               := if (request:exists() and string-length(request:get-parameter('id',())[1])>0) then request:get-parameter('id',())[1] else ()
let $name             := if (request:exists() and string-length(request:get-parameter('name',())[1])>0) then request:get-parameter('name',())[1] else ()
let $ref              := if (request:exists() and string-length(request:get-parameter('ref',())[1])>0) then request:get-parameter('ref',())[1] else ()
let $useRegexMatching := if (request:exists() and string-length(request:get-parameter('regex',())[1])>0) then request:get-parameter('regex',false())[1] else (false())

let $effectiveDate    := if (request:exists() and string-length(request:get-parameter('effectiveDate',())[1])>0) then request:get-parameter('effectiveDate',())[1] else ()
let $projectPrefix    := if (request:exists() and string-length(request:get-parameter('prefix',())[1])>0) then request:get-parameter('prefix',())[1] else ()
let $projectVersion   := if (request:exists() and string-length(request:get-parameter('version',())[1])>0) then request:get-parameter('version',())[1] else ()
let $htmlInline       := if (request:exists() and string-length(request:get-parameter('inline',())[1])>0) then request:get-parameter('inline',())[1] else ()
let $displayHeader    := if ($htmlInline='true') then xs:boolean('false') else xs:boolean('true')

let $valueSets := 
    if (not(empty($id))) then
        if (empty($projectPrefix)) then
            vs:getExpandedValueSetById($id,$effectiveDate)
        else (
            vs:getExpandedValueSetById($id,$effectiveDate,$projectPrefix, $projectVersion)
        )
    
    else if (not(empty($name))) then
        if (empty($projectPrefix)) then
            vs:getExpandedValueSetByName($name,$effectiveDate,$useRegexMatching)
        else (
            vs:getExpandedValueSetByName($name,$effectiveDate,$projectPrefix,$useRegexMatching, $projectVersion)
        )
    
    else if (not(empty($ref)) and not(empty($projectPrefix))) then
        vs:getExpandedValueSetByRef($ref,$effectiveDate,$projectPrefix, $projectVersion)
    
    else if (not(empty($projectPrefix))) then
        let $valueSetList := vs:getValueSetList($id,$name,$effectiveDate,$projectPrefix, $projectVersion)
        for $valueSet in $valueSetList/project[not(@url)][@ident=$projectPrefix]/valueSet
        return
            vs:getExpandedValueSetById($valueSet/(@id|@ref),$valueSet/@effectiveDate,$projectPrefix,$projectVersion)
    else ()

return
    if (string-length($id)=0 and string-length($name)=0 and string-length($projectPrefix)=0) then
        if (request:exists()) then 
            (response:set-status-code(404), response:set-header('Content-Type','text/xml'), <error>{msg:getMessage('errorRetrieveValuesetNotEnoughParameters',$language)}</error>)
        else ''
    else if (empty($valueSets)) then
        if (request:exists()) then 
            (response:set-status-code(404), response:set-header('Content-Type','text/xml'), <error>{msg:getMessage('errorRetrieveValuesetNoResults',$language),' ',if (request:exists()) then request:get-query-string() else()}</error>)
        else ''
    else if ($format = 'xml') then (
        if (request:exists()) then 
            response:set-header('Content-Type','text/xml')
        else ''
        ,
        <valueSets>
        {
            $valueSets/*
        }
        </valueSets>
    ) else if ($format = 'csv') then (
        if (request:exists()) then 
            response:set-header('Content-Type','text/csv; charset=utf-8')
        else ''
        ,
        (:<concept code="xxxxxx" codeSystem="2.16.840.1.113883.2.4.15.4" displayName="Medicatie" level="0" type="A"/> :)
        (: Replace double quotes with single quotes in the CSV values, except in the code itself, 
        and place in between double quotes if there a white space character in a string
        Note that in the exceptional event that a code contains a double quote, the CSV renders invalid :)
        concat('Level;Type;Code;DisplayName;CodeSystem;CodeSystemName;CodeSystemVersion;Flexibility','&#13;&#10;'),
        for $valueset in $valueSets//valueSet[*]
        return
            for $concept in ($valueset/completeCodeSystem, $valueset/conceptList/concept, $valueset/conceptList/exception)
                let $conceptCode := data($concept/@code)
                let $quotedConceptCode := if (matches($conceptCode,'\s+')) then (concat('&quot;',$conceptCode,'&quot;')) else ($conceptCode)
                let $conceptDisplayName := replace(data($concept/@displayName),'"','&apos;')
                let $quotedConceptDisplayName := if (matches($conceptDisplayName,'\s+')) then (concat('&quot;',$conceptDisplayName,'&quot;')) else ($conceptDisplayName)
                let $conceptCodeSystem := replace(data($concept/@codeSystem),'"','&apos;')
                let $quotedConceptCodeSystem := if (matches($conceptCodeSystem,'\s+')) then (concat('&quot;',$conceptCodeSystem,'&quot;')) else ($conceptCodeSystem)
                let $generatedCodeSystemName := art:getNameForOID($concept/@codeSystem,$language,$projectPrefix)
                let $conceptCodeSystemName := replace(if ($concept/@codeSystemName) then (data($concept/@codeSystemName)) else if (replace($generatedCodeSystemName,'[0-9\.]','')!='') then ($generatedCodeSystemName) else (''),'"','&apos;')
                let $quotedConceptCodeSystemName := if (matches($conceptCodeSystemName,'\s+')) then (concat('&quot;',$conceptCodeSystemName,'&quot;')) else ($conceptCodeSystemName)
                let $conceptCodeSystemVersion := replace(data($concept/@codeSystemVersion),'"','&apos;')
                let $quotedConceptCodeSystemVersion := if (matches($conceptCodeSystemVersion,'\s+')) then (concat('&quot;',$conceptCodeSystemVersion,'&quot;')) else ($conceptCodeSystemVersion)
                let $conceptFlexibility := replace(if ($concept/@flexibility) then (data($concept/@flexibility)) else ('dynamic'),'"','&apos;')
                let $quotedconceptFlexibility := if (matches($conceptFlexibility,'\s+')) then (concat('&quot;',$conceptFlexibility,'&quot;')) else ($conceptFlexibility)
            return
                concat(data($concept/@level),';',data($concept/@type),';',$quotedConceptCode,';',$quotedConceptDisplayName,';',$quotedConceptCodeSystem,';',$quotedConceptCodeSystemName,';',$quotedConceptCodeSystemVersion,';',$quotedconceptFlexibility,'&#13;&#10;')
    ) else (
        if (request:exists()) then
            response:set-header('Content-Type','text/html')
        else (),
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>{($valueSets//@name)[1]/string()}</title>
                <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>{
                for $valueset in $valueSets//valueSet[@id or not(@ref=$valueSets//valueSet/@id)]
                let $prefix := 
                    if ($valueset/parent::*[@referencedFrom]) 
                    then tokenize($valueset/parent::*/@referencedFrom/string(),' ')[1] 
                    else $valueset/parent::*/@ident/string()
                let $desc := 
                    if ($valueset/desc[@language=$language or $language=''][string-length(string-join(node(),''))>0])
                    then art:serializeNode($valueset/desc[@language=$language or $language=''][string-length(string-join(node(),''))>0][1])
                    else if ($valueset[@ref])
                    then <desc>{msg:getMessage('ValueSetReferenceData',$language,$valueset/@ref/string(),$valueset/@name/string())}</desc>
                    else <desc/>
                return
                    <span>
                    {
                    if ($displayHeader) then (
                    <h1>{$valueset/@name/string()}</h1>,
                    <p>
                        <i>
                            {msg:getMessage('fromRepoOrProject',$language)}
                            {concat(': ',$valueset/parent::*/@ident/string())}
                            {
                                if ($valueset/parent::*[@url]) 
                                then concat(' (',$valueset/parent::*/@url/string(),') ',msg:getMessage('viaProject',$language),' ',$valueset/parent::*/@referencedFrom) 
                                else ()
                            }
                            {
                                if (not(empty($projectVersion))) then
                                    concat(' ', msg:getMessage('projectVersion',$language), ' ', $projectVersion)
                                else ()
                            }
                        </i>
                    </p>,
                    <p>{msg:getMessage('goTo',$language)}<a href="ValueSetIndex?prefix={$projectPrefix}{if (not(empty($projectVersion))) then concat('&amp;version=',$projectVersion) else ()}&amp;language={$language}" alt="">index</a> 
                    - {msg:getMessage('displayAs',$language)}<a href="RetrieveValueSet?id={$valueset/(@id|@ref)}&amp;effectiveDate={$valueset/@effectiveDate}&amp;prefix={$projectPrefix}{if (not(empty($projectVersion))) then concat('&amp;version=',$projectVersion) else ()}&amp;format=xml{if ($language != '') then (concat('&amp;language=',$language)) else ()}" alt="">XML</a>  
                    - {msg:getMessage('displayAs',$language)}<a href="RetrieveValueSet?id={$valueset/(@id|@ref)}&amp;effectiveDate={$valueset/@effectiveDate}&amp;prefix={$projectPrefix}{if (not(empty($projectVersion))) then concat('&amp;version=',$projectVersion) else ()}&amp;format=csv{if ($language != '') then (concat('&amp;language=',$language)) else ()}" alt="">CSV</a>
                    <span style="float:right;">
                        <img src="{$strArtURL}img/flags/nl.png" onclick="location.href=window.location.pathname+'?language=nl-NL{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                        <img src="{$strArtURL}img/flags/de.png" onclick="location.href=window.location.pathname+'?language=de-DE{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                        <img src="{$strArtURL}img/flags/us.png" onclick="location.href=window.location.pathname+'?language=en-US{string-join(for $p in request:get-parameter-names() return if ($p='language') then () else concat('&amp;',$p,'=',request:get-parameter($p,())[string-length()>0]),'')}';" class="linked flag"/>
                    </span>,
                    </p> )
                    else()
                    }
                    <div class="{if ($displayHeader) then 'content' else ''}">
                        <table width="100%" cellpadding="5px">
                            <tr>
                                <th colspan="5">{msg:getMessage('columnDescription',$language)}</th>
                            </tr>
                            <tr>
                                <td colspan="5">{$desc/node()}</td>
                            </tr>
                            <tr>
                                <th>{msg:getMessage('columnValueSetName',$language)}</th>
                                <th>{msg:getMessage('columnValueSetID',$language)}</th>
                                {if ($valueset/@versionLabel) then (<th>{msg:getMessage('columnVersionLabel',$language)}</th>) else ()}
                                <th>{msg:getMessage('effectiveTime',$language)}</th>
                                <th>{msg:getMessage('columnStatus',$language)}</th>
                            </tr>
                            <tr bgcolor="#F6F3EE">
                                <td><i>{$valueset/@name/string()}</i></td>
                                <td>{$valueset/(@id|@ref)/string()}</td>
                                {if ($valueset/@versionLabel) then (<td>{$valueset/@versionLabel/string()}</td>) else ()}
                                <!--:normally would use format-dateTime, but that gave a error-->
                                <td>{substring($valueset/@effectiveDate/string(),1,10)}</td>
                                <td>{$valueset/@statusCode/string()}</td>
                            </tr>
                        </table>
                        {if ($valueset[conceptList/*]) then (
                                <table cellpadding="5px">
                                    <tr>
                                        <th align="right">{msg:getMessage('xSourceCodeSystem',$language)}</th>
                                        <td>
                                        {
                                            for $sourceCodeSystem in $valueset/sourceCodeSystem
                                            return
                                                <span>&quot;<a href="CodeSystemIndex?id={$sourceCodeSystem/@id/string()}">{$sourceCodeSystem/@id/string()}&quot;&#160; ({$sourceCodeSystem/@identifierName/string()})</a></span>,
                                                <br/>
                                        }
                                        </td>
                                    </tr>
                                </table>
                            ) else ()}
                        <p/>
                        {if (count($valueset/completeCodeSystem)=1) then (
                                <p><b>{msg:getMessage('xCompleteCodeSystem',$language)}</b></p>
                            ) else if (count($valueset/completeCodeSystem)>1) then (
                                <p><b>{msg:getMessage('xCompleteCodeSystems',$language,string(count($valueset/completeCodeSystem)))}</b></p>
                            ) else ()}
                        {if ($valueset[completeCodeSystem]) then (
                            <table class="values" id="codeList" cellpadding="5px">
                                  <thead>
                                      <tr>
                                          <th>{msg:getMessage('columnCodeSystemName',$language)}</th>
                                          <th>{msg:getMessage('columnCodeSystemID',$language)}</th>
                                          <th>{msg:getMessage('columnCodeSystemVersion',$language)}</th>
                                          <th>{msg:getMessage('columnFlexibility',$language)}</th>
                                      </tr>
                                  </thead>
                                  <tbody>
                                  {for $completeCodeSystem in ($valueset/completeCodeSystem)
                                   return
                                      <tr>
                                            <td>{data($completeCodeSystem/@codeSystemName)}</td>
                                            <td>{data($completeCodeSystem/@codeSystem)}</td>
                                            <td>{data($completeCodeSystem/@codeSystemVersion)}</td>
                                            {if ($completeCodeSystem/@flexibility='dynamic' or not($completeCodeSystem[@flexibility])) then (
                                                <td>{msg:getMessage('flexibilityDynamic',$language)}</td>
                                            ) else (
                                                <td>{data($completeCodeSystem/@flexibility)}</td>
                                            )}
                                      </tr>
                                   }
                                  </tbody>
                              </table>
                        ) else ()}
                        {if ($valueset[completeCodeSystem and conceptList/*]) then (
                                <p><b>{msg:getMessage('orOneOfTheFollowing',$language)}</b></p>
                            ) else ()}
                        {if ($valueset[conceptList/*]) then (
                              <table class="values" id="codeList" cellpadding="5px">
                                  <thead>
                                  <tr>
                                      <th>{msg:getMessage('columnLevelSlashType',$language)}</th>
                                      <th>{msg:getMessage('columnCode',$language)}</th>
                                      <th>{msg:getMessage('columnCodeSystem',$language)}</th>
                                      {if ($valueset/conceptList/*[@codeSystemVersion]) then (<th>{msg:getMessage('columnCodeSystemVersion',$language)}</th>) else ()}
                                      <th>{msg:getMessage('columnDisplayName',$language)}</th>
                                      <th>{msg:getMessage('columnDescription',$language)}</th>
                                  </tr>
                                  </thead>
                                  <tbody>
                                    {for $concept in ($valueset/conceptList/concept)
                                        let $levelNumber := if (data($concept/@level)) then (xs:integer(data($concept/@level))) else (0)
                                        let $typeString := if (data($concept/@type)) then (data($concept/@type)) else ('L')
                                        let $levelType := if (string($levelNumber)!='' or $typeString!='') then (concat($levelNumber,'-',$typeString)) else ('')
                                     return
                                        <tr>
                                            <td>{$levelType}</td>
                                            <td>{for $i in 1 to $levelNumber return '&#160;&#160;&#160;'}{data($concept/@code)}</td>
                                            <td>{if ($concept/@codeSystemName) then ($concept/@codeSystemName/string()) else <i>{$concept/@codeSystem/string()}</i>}</td>
                                            {if ($valueset/conceptList/*[@codeSystemVersion]) then (<td>{$concept/@codeSystemVersion/string()}</td>) else ()}
                                            <td>{$concept/@displayName/string()}</td>
                                            <td>{$concept/desc[@language=$language or $language=''][1]/string()}</td>
                                        </tr>
                                     }
                                     {if ($valueset[conceptList/concept and conceptList/exception]) then (
                                     <tr>
                                        <td colspan="5"><hr/></td>
                                     </tr>) else ()}
                                     {for $concept in ($valueset/conceptList/exception)
                                        let $levelNumber := if ($concept[@level]) then (xs:integer($concept/@level/string())) else ('')
                                        let $typeString := if ($concept[@type]) then ($concept/@type/string()) else ('')
                                        let $levelType := if (string($levelNumber)!='' or $typeString!='') then (concat($levelNumber,'-',$typeString)) else ('')
                                     return
                                        <tr>
                                            <td>{$levelType}</td>
                                            <td><font color="grey"><i>{for $i in 1 to $levelNumber return '&#160;&#160;&#160;'}{$concept/@code/string()}</i></font></td>
                                            <td>{if ($concept/@codeSystemName) then ($concept/@codeSystemName/string()) else <i>{$concept/@codeSystem/string()}</i>}</td>
                                            {if ($valueset/conceptList/*[@codeSystemVersion]) then (<td>{$concept/@codeSystemVersion/string()}</td>) else ()} 
                                            <td><font color="grey"><i>{$concept/@displayName/string()}</i></font></td>
                                            <td>{$concept/desc[@language=$language or $language=''][1]/string()}</td>
                                        </tr>
                                     }
                                     <tr>
                                        <td colspan="5">&#160;</td>
                                     </tr>
                                     <tr style="background-color : #FAFAD2;">
                                        <td colspan="5">{msg:getMessage('CodeSystemLegendaLine',$language)}</td>
                                     </tr>
                                  </tbody>
                              </table>
                        ) else ()}
                    </div>
                    </span>
            }</body>
        </html>
    ) (: html :)