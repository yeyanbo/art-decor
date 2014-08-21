xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket, Marc de Graauw, Kai Heitmann
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    
:)
import module namespace get         = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace vs          = "http://art-decor.org/ns/decor/valueset" at "../../../art/api/api-decor-valueset.xqm";
import module namespace adserver    = "http://art-decor.org/ns/art-decor-server" at "../api/api-server-settings.xqm";
import module namespace art         = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace msg         = "urn:decor:REST:v1" at "get-message.xquery";
declare option exist:serialize "method=xhtml media-type=text/html";

declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');

let $decorSchemaTypes := art:getDecorTypes()

let $projectPrefix    := if (request:exists() and string-length(string-join(request:get-parameter('prefix',()),''))>0) then request:get-parameter('prefix',())[1] else ()
let $projectVersion   := if (request:exists() and string-length(string-join(request:get-parameter('version',()),''))>0) then request:get-parameter('version',())[1] else ()
let $language         := if (request:exists() and string-length(string-join(request:get-parameter('language',''),''))>0) then request:get-parameter('language',$get:strArtLanguage)[1] else ($get:strArtLanguage)

(: optionally filters the output of ProjectIndex. Supported d for 'datasets', t for 'transactions', v for 'valuesets', r for 'templates/rules'
    view is the positive statement, i.e. show only these
    filter is the negative statement, i.e. show everything but these
   Added view, because positive statements seem more natural, but left filter in, because of uknown compatibility problems upon removal
   Note that filter to date is an undocumented feature...
:)
let $view             := if (request:exists() and string-length(string-join(request:get-parameter('view',()),''))>0) then request:get-parameter('view',())[1] else ()
let $filter           := if (request:exists() and string-length(string-join(request:get-parameter('filter',()),''))>0) then request:get-parameter('filter',()) else ()  

(: these four are currently used only for valuesets :)
let $id               := if (request:exists() and string-length(string-join(request:get-parameter('id',()),''))>0) then request:get-parameter('id',())[1] else ()
let $name             := if (request:exists() and string-length(string-join(request:get-parameter('name',()),''))>0) then request:get-parameter('name',())[1] else ()
let $useRegexMatching := if (request:exists() and string-length(string-join(request:get-parameter('useRegexMatching',()),''))>0) then request:get-parameter('regex',false())[1] else (false())
let $effectiveDate    := if (request:exists() and string-length(string-join(request:get-parameter('effectiveDate',()),''))>0) then request:get-parameter('effectiveDate',())[1] else ()
let $format           := if (request:exists() and string-length(string-join(request:get-parameter('format','html'),''))>0) then request:get-parameter('format','html')[1] else ('html')

(: get filtered projects for results :)
let $projects      := 
    if (empty($projectPrefix)) then 
        (:cannot process version without prefix so only live data by default:)
        (collection($get:strDecorData)//decor[@repository='true'][not(@private='true')])
    else if (empty($projectVersion)) then
        (collection($get:strDecorData)//decor[project/@prefix=$projectPrefix])
    else
        (collection($get:strDecorVersion)//decor[@versionDate=$projectVersion][project/@prefix=$projectPrefix][@language=$language])

let $versions      := 
    if (empty($projectPrefix)) then
        (:cannot process version without prefix so only live data by default:)
        ()
    else (
        for $project in collection($get:strDecorVersion)//decor[@versionDate][project/@prefix=$projectPrefix][@language=$language]
        let $versionDate  := $project/@versionDate
        let $versionLabel := if ($project/@versionLabel) then $project/@versionLabel else ($project/project/(release|version)[@date=$versionDate]/@versionLabel)
        return
            <project prefix="{$project/project/@prefix/string()}" versionDate="{$versionDate}">{
                if ($versionLabel[string-length()>0]) then attribute versionLabel {$versionLabel} else ()
            }</project>
    )

(: get all projects for drop-down population :)
let $allProjects   := 
    for $project in collection($get:strDecorData)//decor[not(@private='true')]/project
    return
        <project prefix="{$project/@prefix/string()}" name="{if ($project/name[@language=$language]) then $project/name[@language=$language][1]/text() else $project/name[1]/text()}" repository="{$project/parent::decor/@repository='true'}"/>

let $title        := 
    if (contains($view,'d') and string-length($view)=1 and empty($filter)) then
        if (empty($projectPrefix)) then (msg:getMessage('titleDatasetIndex',$language)) else (msg:getMessage('titleDatasetIndex',$language, $allProjects[@prefix=$projectPrefix]/@name))
    else if (contains($view,'r') and string-length($view)=1 and empty($filter)) then
        if (empty($projectPrefix)) then (msg:getMessage('titleTemplateIndex',$language)) else (msg:getMessage('titleTemplateIndex',$language, $allProjects[@prefix=$projectPrefix]/@name))
    else if (contains($view,'t') and string-length($view)=1 and empty($filter)) then
        if (empty($projectPrefix)) then (msg:getMessage('titleTransactionIndex',$language)) else (msg:getMessage('titleTransactionIndex',$language, $allProjects[@prefix=$projectPrefix]/@name))
    else if (contains($view,'v') and string-length($view)=1 and empty($filter)) then
        if (empty($projectPrefix)) then (msg:getMessage('titleValueSetIndex',$language)) else (msg:getMessage('titleValueSetIndex',$language, $allProjects[@prefix=$projectPrefix]/@name))
    else (
        if (empty($projectPrefix)) then (msg:getMessage('titleProjectIndex',$language)) else (msg:getMessage('titleProjectIndex',$language, $allProjects[@prefix=$projectPrefix]/@name))
    )
let $logo         := ($projects//project/reference/@logo)[1]
let $url          := ()

return 
    if ($format='xml') then (
        (:note: this output supports the BBR config in server-settings:)
        if (empty($projectPrefix) and empty($view) and empty($filter)) then (
            response:set-status-code(200),
            response:set-header('Content-Type','text/xml'),
            <return>
            {
                $allProjects
            }
            </return>
        )
        else if (empty($projects)) then (
            response:set-status-code(404),
            response:set-header('Content-Type','text/xml'),
            <error>{msg:getMessage('errorRetrieveProjectNoResults',$language),' ',if (request:exists()) then request:get-query-string() else()}</error>
        )
        (:note: this output supports the BBR index for template and valueset ref/resolving:)
        else (
            response:set-status-code(200),
            response:set-header('Content-Type','text/xml'),
            <return prefix="{$projectPrefix}" versionDate="{$projectVersion}" versionLabel="{$versions[@prefix=$projectPrefix][@versionDate=$projectVersion]/@versionLabel}">
            {
                $versions
                ,
                if (empty($view) or contains($view,'d')) then (
                    if (contains($filter, 'd')) then () else
                        for $dataset in $projects//dataset
                        order by $dataset/@effectiveDate
                        return 
                            <dataset>{
                                $dataset/@id,
                                $dataset/@ref,
                                attribute name {$dataset/name[@language=$language][1]},
                                attribute displayName {$dataset/name[@language=$language][1]},
                                $dataset/@statusCode,
                                $dataset/@effectiveDate,
                                $dataset/@officialReleaseDate,
                                $dataset/@expirationDate,
                                $dataset/@versionLabel,
                                attribute url {adserver:getServerURLServices()},
                                attribute ident {$dataset/ancestor::decor/project/@prefix},
                                $dataset/desc
                            }</dataset>
                ) else ()
            }
            {
                if (empty($view) or contains($view,'t')) then (
                    if (contains($filter, 't')) then () else
                        for $transaction in $projects//transaction[@type!='group'][representingTemplate]
                        order by $transaction/@effectiveDate
                        return 
                            <transaction>{
                                $transaction/@id,
                                $transaction/@ref,
                                attribute name {$transaction/name[@language=$language][1]},
                                attribute displayName {$transaction/name[@language=$language][1]},
                                $transaction/@statusCode,
                                $transaction/@effectiveDate,
                                $transaction/@officialReleaseDate,
                                $transaction/@expirationDate,
                                $transaction/@versionLabel,
                                attribute url {adserver:getServerURLServices()},
                                attribute ident {$transaction/ancestor::decor/project/@prefix},
                                $transaction/desc
                            }</transaction>
                ) else ()
            }
            {
                if (empty($view) or contains($view,'v')) then (
                    if (contains($filter, 'v')) then () else
                        let $valueSets := vs:getValueSetList($id,$name,$effectiveDate,$projectPrefix,$projectVersion)
                        return
                        for $valueSet in $valueSets/*[not(@url)]/valueSet
                        let $prefix      := 
                            if ($valueSet/parent::*[@referencedFrom]) 
                            then tokenize($valueSet/parent::*/@referencedFrom,' ')[1] 
                            else $valueSet/parent::*/@ident
                        order by $valueSet/@displayName, $valueSet/@effectiveDate
                        return 
                            <valueSet>{
                                $valueSet/@id,
                                $valueSet/@ref,
                                $valueSet/@name,
                                $valueSet/@displayName,
                                $valueSet/@statusCode,
                                $valueSet/@effectiveDate,
                                $valueSet/@officialReleaseDate,
                                $valueSet/@expirationDate,
                                $valueSet/@versionLabel,
                                attribute url {adserver:getServerURLServices()},
                                attribute ident {$prefix},
                                $valueSet/desc
                            }</valueSet>
                ) else ()
            }
            {
                if (empty($view) or contains($view,'r')) then (
                    if (contains($filter, 'r')) then () else
                        for $template in $projects/rules/template
                        order by $template/@displayName, $template/@effectiveDate
                        return 
                            <template>{
                                $template/@id,
                                $template/@ref,
                                $template/@name,
                                $template/@displayName,
                                $template/@statusCode,
                                $template/@effectiveDate,
                                $template/@officialReleaseDate,
                                $template/@expirationDate,
                                $template/@versionLabel,
                                $template/@isClosed,
                                attribute url {adserver:getServerURLServices()},
                                attribute ident {$template/ancestor::decor/project/@prefix},
                                $template/desc,
                                $template/classification
                            }</template>
                ) else ()
            }
            </return>
        )
    )
    else (
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>{$title}</title>
        <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <a name="top"></a>
        <table width="100%">
            <tbody>
                <tr>
                    <td align="left">
                        <h1>{$title}</h1>
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
                        <select id="prefixSelector" onchange="javascript:location.href=window.location.pathname+'?prefix='+this.options[this.selectedIndex].value+'&amp;format=html&amp;language={$language}'">
                        <option value="">{msg:getMessage('SelectProject',$language)}</option>
                        {
                            for $project in $allProjects
                            order by $project/@repository, lower-case($project/@name)
                            return
                                <option value="{$project/@prefix/string()}">
                                {
                                    if ($project/@prefix=$projectPrefix) 
                                    then attribute {'selected'} {'true'} 
                                    else (),
                                    if ($project/@repository='true') 
                                    then '(BBR) '
                                    else (),
                                    $project/@name/string()
                                }
                                </option>
                        }
                        </select>
                        {
                            if (count($versions)>=1) then (
                                <select id="versionSelector" onchange="javascript:location.href=window.location.pathname+'?prefix='+document.getElementById('prefixSelector').options[document.getElementById('prefixSelector').selectedIndex].value+'&amp;version='+this.options[this.selectedIndex].value+'&amp;format=html&amp;language={$language}'" style="display:{if (empty($projectPrefix)) then 'none' else ('inline-block')};">
                                <option value="">--{msg:getMessage('columnLatestVersion',$language)}--</option>
                                {
                                    for $version in $versions
                                    order by lower-case($version/@versionDate) descending
                                    return
                                        <option value="{$version/@versionDate/string()}">
                                        {
                                            if ($version/@versionDate=$projectVersion) 
                                            then attribute {'selected'} {'true'} 
                                            else (),
                                            $version/@versionDate/string(),
                                            if ($version/@versionLabel) then concat(' (',$version/@versionLabel,')') else ()
                                        }
                                        </option>
                                }
                                </select>
                            ) else ()
                        }
                    </td>
                    <td align="right">
                        <img src="resources/images/nl.png" onclick="location.href=window.location.pathname+'?prefix={$projectPrefix}{if (not(empty($projectVersion))) then concat('&amp;version=',$projectVersion) else ()}&amp;format=html&amp;language=nl-NL';" class="linked flag"/>
                        <img src="resources/images/de.png" onclick="location.href=window.location.pathname+'?prefix={$projectPrefix}{if (not(empty($projectVersion))) then concat('&amp;version=',$projectVersion) else ()}&amp;format=html&amp;language=de-DE';" class="linked flag"/>
                        <img src="resources/images/us.png" onclick="location.href=window.location.pathname+'?prefix={$projectPrefix}{if (not(empty($projectVersion))) then concat('&amp;version=',$projectVersion) else ()}&amp;format=html&amp;language=en-US';" class="linked flag"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                    {
                        if (empty($projects)) then () else (
                            if (string-length($view)>0 or string-length($filter)>0) then (
                                let $newUrl := concat(string-join(tokenize(request:get-uri(),'/')[position()!=last()],'/'),'/ProjectIndex?prefix=',$projectPrefix,if (not(empty($projectVersion))) then concat('&amp;version=',$projectVersion) else (),'&amp;format=html&amp;language=',$language)
                                return
                                <span style="margin-right: 10px;"><a href="{$newUrl}">{msg:getMessage('FullIndex',$language)}</a></span>
                            ) else ()
                        )
                    }
                    {
                        if (empty($projects)) then () else (
                            if ((empty($view) or string-length($view)>1) and (empty($filter) or string-length($filter)>1)) then (
                                if (empty($view) or contains($view,'d')) then (
                                    if (contains($filter, 'd')) then () else
                                        <span style="margin-right: 10px;"><a href="#dataSetList">{msg:getMessage('DataSets',$language)}</a></span>
                                ) else ()
                                ,
                                if (empty($view) or contains($view,'t')) then (
                                    if (contains($filter, 't')) then () else
                                        <span style="margin-right: 10px;"><a href="#transactionList">{msg:getMessage('Transactions',$language)}</a></span>
                                ) else ()
                                ,
                                if (empty($view) or contains($view,'v')) then (
                                    if (contains($filter, 'v')) then () else
                                        <span style="margin-right: 10px;"><a href="#valueSetList">{msg:getMessage('ValueSets',$language)}</a></span>
                                ) else ()
                                ,
                                if (empty($view) or contains($view,'r')) then (
                                    if (contains($filter, 'r')) then () else
                                        <span style="margin-right: 10px;"><a href="#templatesList">{msg:getMessage('Templates',$language)}</a></span>
                                ) else ()
                            ) else ()
                        )
                    }
                    </td>
                </tr>
            </tbody>
        </table>
        {
            if (empty($projects)) then (
        <div class="content">
        {
            msg:getMessage('errorRetrieveProjectNoResults',$language),' ',if (request:exists()) then request:get-query-string() else()
        }
        </div>
            ) else (
        <div class="content">
        {
            if (empty($view) or contains($view,'d')) then (
                if (contains($filter, 'd')) then () else  
                <div class="h2">
                    <a name="dataSetList"/>
                    <h2>{msg:getMessage('DataSets',$language)} <span style="float:right; margin-right: 20px;"><a href="#top" style="text-decoration: none;">&#x2191;</a></span></h2>
                    <table class="values" id="dataSetList">
                        <thead>
                            <tr>
                                <th>XML</th>
                                <th>{msg:getMessage('columnAllView',$language)}</th>
                                <th>{msg:getMessage('columnCareViewSmall',$language)}</th>
                                <th>{msg:getMessage('columnName',$language)}</th>
                                <th>{msg:getMessage('effectiveDate',$language)}</th>
                                <th>{msg:getMessage('expirationDate',$language)}</th>
                                <th>{msg:getMessage('columnStatus',$language)}</th>
                                <th>{msg:getMessage('columnVersionLabel',$language)}</th>
                                {   if ($projectPrefix) then () else
                                    <th>{msg:getMessage('columnProjects',$language)}</th>
                                }
                            </tr>
                        </thead>
                        <tbody>
                        {
                            for $dataset in $projects//dataset
                                let $statusCode          := if ($dataset/@statusCode) then (data($dataset/@statusCode)) else
                                    if (count($dataset//concept[@statusCode='draft'])=0 and count($dataset//concept[@statusCode='new'])=0) then 'final' else ('draft')
                                let $statusCodeForDisplay := $decorSchemaTypes/ItemStatusCodeLifeCycle/enumeration[@value=$statusCode]/label[@language=$language]
                                
                                let $t_id                := $dataset/@id
                                let $t_effectiveDate     := $dataset/@effectiveDate
                                let $baseHref            := concat('RetrieveDataSet?id=', data($dataset/@id), '&amp;language=', $language)
                                let $versionSearchParams := 
                                    if ($dataset/ancestor::decor/@versionDate) then concat('&amp;version=', $dataset/ancestor::decor/@versionDate) else ()
                                let $href := concat($baseHref, $versionSearchParams) 
                            order by $dataset/@displayName, $dataset/@effectiveDate
                            return 
                               <tr style="background-color:white" onMouseover="this.style.backgroundColor='lightblue';" onMouseout="this.style.backgroundColor='white';">
                                   <td><a href="{$href}&amp;format=xml">xml</a></td>
                                   <td><a href="{$href}&amp;format=html&amp;hidecolumns=3456gh">html</a></td>
                                   <td><a href="{$href}&amp;format=html&amp;hidecolumns=3456bcdefghj">html</a></td>
                                   <td>{data($dataset/name[@language=$language][1])}</td>
                                   <td>{data($dataset/@effectiveDate)}</td>
                                   <td>{data($dataset/@expirationDate)}</td>
                                   <td><span class="node-s{$statusCode}">{if ($statusCodeForDisplay) then $statusCodeForDisplay else $statusCode}</span></td>
                                   <td>{data($dataset/@versionLabel)}</td>
                                   {   if ($projectPrefix) then () else
                                        <td>{data($dataset/ancestor::decor/project/@prefix)}</td>
                                   }
                               </tr>
                        }
                        </tbody>
                    </table>
                </div>
            ) else ()
        }
        { 
            if (empty($view) or contains($view,'t')) then (
                if (contains($filter, 't')) then () else  
                    <div class="h2">
                        <a name="transactionList"/>
                        <h2>{msg:getMessage('Transactions',$language)} <span style="float:right; margin-right: 20px;"><a href="#top" style="text-decoration: none;">&#x2191;</a></span></h2>
                        <table class="values" id="transactionList">
                            <thead>
                                <tr>
                                    <th>XML</th>
                                    <th>XPath</th>
                                    <th>{msg:getMessage('columnAllView',$language)}</th>
                                    <th>{msg:getMessage('columnDataView',$language)}</th>
                                    <th>{msg:getMessage('columnCareView',$language)}</th>
                                    <th>{msg:getMessage('columnCareViewSmall',$language)}</th>
                                    <th>{msg:getMessage('columnName',$language)}</th>
                                    <th>{msg:getMessage('effectiveDate',$language)}</th>
                                    <th>{msg:getMessage('expirationDate',$language)}</th>
                                    <th>{msg:getMessage('columnStatus',$language)}</th>
                                    <th>{msg:getMessage('columnVersionLabel',$language)}</th>
                                    <th>{msg:getMessage('columnScenario',$language)}</th>
                                    <th>{msg:getMessage('columnDataset',$language)}</th>
                                    {   if ($projectPrefix) then () else
                                        <th>{msg:getMessage('columnProjects',$language)}</th>
                                    }
                                </tr>
                            </thead>
                            <tbody>
                            {
                                for $transaction in $projects//transaction[@type!='group'][representingTemplate]
                                let $prefix               := data($transaction/ancestor::decor/project/@prefix)
                                let $scenarioname         := data($transaction/ancestor::scenario/name[@language=$language][1])
                                let $transactionname      := data($transaction/name[@language=$language][1])
                                let $statusCode           := data($transaction/@statusCode)
                                let $statusCodeForDisplay := $decorSchemaTypes/ItemStatusCodeLifeCycle/enumeration[@value=$statusCode]/label[@language=$language]
                                let $datasetid            := $transaction/representingTemplate/@sourceDataset
                                let $dataset              := $projects//dataset[@id=$datasetid]
                                let $datasetname          := data($dataset/name[@language=$language][1])
                                let $dataseteff           := $dataset/@effectiveDate
                                let $datasetstatus        := 
                                    if ($dataset/@statusCode) then (
                                        data($dataset/@statusCode)
                                    ) else if (count($dataset//concept[@statusCode='draft'])=0 and count($dataset//concept[@statusCode='new'])=0) then ( 
                                        'final' 
                                    ) else ('draft')
                                let $baseHref             := concat('RetrieveTransaction?id=', data($transaction/@id), '&amp;language=', $language)
                                let $versionSearchParams  := 
                                    if ($transaction/ancestor::decor/@versionDate) then concat('&amp;version=', $transaction/ancestor::decor/@versionDate) else ()
                                let $href                 := concat($baseHref, $versionSearchParams) 
                                order by $prefix, $scenarioname, $transactionname
                                return 
                                   <tr style="background-color:white" onMouseover="this.style.backgroundColor='lightblue';" onMouseout="this.style.backgroundColor='white';">
                                        <td><a href="{$href}&amp;format=xml">xml</a></td>
                                        <td><a href="RetrieveXpathsForTransaction?id={$transaction/@id}&amp;language={$language}&amp;format=xml{$versionSearchParams}">xml</a></td>
                                        <td><a href="{$href}&amp;format=html">html</a></td>
                                        <td><a href="{$href}&amp;format=html&amp;hidecolumns=6cdefh">html</a></td>
                                        <td><a href="{$href}&amp;format=html&amp;hidecolumns=45ghj">html</a></td>
                                        <td><a href="{$href}&amp;format=html&amp;hidecolumns=3456cdefghj">html</a></td>
                                        <td>{if (string-length($transactionname)>0) then ($transactionname) else (<i>{$transaction/name[1]}</i>)}</td>
                                        <td>{$transaction/@effectiveDate/string()}</td>
                                        <td>{$transaction/@expirationDate/string()}</td>
                                        <td><span class="node-s{$statusCode}">{if ($statusCodeForDisplay) then $statusCodeForDisplay else $statusCode}</span></td>
                                        <td>{$transaction/@versionLabel/string()}</td>
                                        <td>{if (string-length($scenarioname)>0) then ($scenarioname) else (<i>{data($transaction/ancestor::scenario/name[1])}</i>)}</td>
                                        <td>{if (string-length($datasetname)>0) then ($datasetname) else (<i>{$dataset/name[1]}</i>)}</td>
                                        {   if ($projectPrefix) then () else
                                            <td>{data($transaction/ancestor::decor/project/@prefix)}</td>
                                        }
                                   </tr>
                            }
                            </tbody>
                        </table>
                    </div>
            ) else ()
        }
        { 
            if (empty($view) or contains($view,'v')) then (
                if (contains($filter, 'v')) then () else
                <div class="h2">
                    <a name="valueSetList"/>
                    <h2>{msg:getMessage('ValueSets',$language)} <span style="float:right; margin-right: 20px;"><a href="#top" style="text-decoration: none;">&#x2191;</a></span></h2>
                    <table class="values" id="valueSetList">
                        <thead>
                            <tr>
                                <th>XML</th>
                                <th>HTML</th>
                                <th>CSV</th>
                                <th>{msg:getMessage('columnName',$language)}</th>
                                <th>{msg:getMessage('columnID',$language)}</th>
                                <th>{msg:getMessage('effectiveDate',$language)}</th>
                                <th>{msg:getMessage('expirationDate',$language)}</th>
                                <th>{msg:getMessage('columnStatus',$language)}</th>
                                <th>{msg:getMessage('columnVersionLabel',$language)}</th>
                                {   if ($projectPrefix) then () else
                                    <th>{msg:getMessage('columnProjects',$language)}</th>
                                }
                            </tr>
                        </thead>
                        <tbody>
                        {
                            let $valueSets := vs:getValueSetList($id,$name,$effectiveDate,$projectPrefix,$projectVersion)
                            return
                            for $valueSet in $valueSets/*[not(@url)]/valueSet
                            let $prefix      := 
                                if ($valueSet/parent::*[@referencedFrom]) 
                                then tokenize($valueSet/parent::*/@referencedFrom,' ')[1] 
                                else $valueSet/parent::*/@ident
                            let $refResolved :=
                                if ($valueSet[@id]) 
                                then true()
                                else exists($valueSets//valueSet[@id=$valueSet/@ref][$prefix=parent::*/tokenize(@referencedFrom,' ')])
                            let $statusCode           := data($valueSet/@statusCode)
                            let $statusCodeForDisplay := $decorSchemaTypes/ItemStatusCodeLifeCycle/enumeration[@value=$statusCode]/label[@language=$language]
                            let $projectList          := string-join(distinct-values($valueSet/parent::*/(@ident|@referencedFrom)),' ')
                            order by $valueSet/@displayName, $valueSet/@effectiveDate
                            return
                                <tr style="background-color:white" onMouseover="this.style.backgroundColor='lightblue';" onMouseout="this.style.backgroundColor='white';">
                                {
                                    <td><a href="RetrieveValueSet?id={$valueSet/(@id|@ref)/string()}&amp;effectiveDate={$valueSet/@effectiveDate/string()}&amp;prefix={$prefix}{if (empty($projectVersion)) then () else concat('&amp;version=',$projectVersion)}&amp;format=xml&amp;language={$language}">xml</a></td>,
                                    <td><a href="RetrieveValueSet?id={$valueSet/(@id|@ref)/string()}&amp;effectiveDate={$valueSet/@effectiveDate/string()}&amp;prefix={$prefix}{if (empty($projectVersion)) then () else concat('&amp;version=',$projectVersion)}&amp;format=html&amp;language={$language}">html</a></td>,
                                    <td><a href="RetrieveValueSet?id={$valueSet/(@id|@ref)/string()}&amp;effectiveDate={$valueSet/@effectiveDate/string()}&amp;prefix={$prefix}{if (empty($projectVersion)) then () else concat('&amp;version=',$projectVersion)}&amp;format=csv&amp;language={$language}">csv</a></td>
                                    ,
                                    <td>{if ($valueSet/@displayName) then $valueSet/@displayName/string() else ($valueSet/@name/string())}</td>
                                }
                                    <td>
                                        {
                                            if ($valueSet[@ref])
                                            then ( 
                                                <span style="padding: 0px 5px 0px 5px; text-align: center; background-color: lightgrey; color: white; font-weight: bold;">ref</span>
                                                (:,
                                                if (not($refResolved)) then
                                                    <span style="padding: 0px 5px 0px 5px; text-align: center; background-color: red; color: white; font-weight: bold;" title="{msg:getMessage('errorCouldNotResolveReference',$language)}">!</span>
                                                else ():)
                                                ,
                                                '&#160;'
                                            ) 
                                            else ()
                                        }
                                        {$valueSet/(@id|@ref)/string()}
                                    </td>
                                    <td>{$valueSet/@effectiveDate/string()}</td>
                                    <td>{$valueSet/@expirationDate/string()}</td>
                                    <td><span class="node-s{$statusCode}">{if ($statusCodeForDisplay) then $statusCodeForDisplay else $statusCode}</span></td>
                                    <td>{$valueSet/@versionLabel/string()}</td>
                                    {   if ($projectPrefix) then () else
                                        <td>{$projectList}</td>
                                    }
                                </tr>
                        }
                        </tbody>
                    </table>
                </div>
            ) else ()
        }
        {
            if (empty($view) or contains($view,'r')) then (
                if (contains($filter, 'r')) then () else
                <div class="h2">
                    <a name="templatesList"/>
                    <h2>{msg:getMessage('Templates',$language)} <span style="float:right; margin-right: 20px;"><a href="#top" style="text-decoration: none;">&#x2191;</a></span></h2>
                    <table class="values" id="templatesList">
                        <thead>
                            <tr>
                                <th>Link</th>
                                <th>{msg:getMessage('columnID',$language)}</th>
                                <th>{msg:getMessage('columnName',$language)}</th>
                                <th>{msg:getMessage('columnDisplayName',$language)}</th>
                                <th>{msg:getMessage('effectiveDate',$language)}</th>
                                <th>{msg:getMessage('expirationDate',$language)}</th>
                                <th>{msg:getMessage('columnStatus',$language)}</th>
                                <th>{msg:getMessage('columnVersionLabel',$language)}</th>
                                {   if ($projectPrefix) then () else
                                    <th>{msg:getMessage('columnProjects',$language)}</th>
                                }
                            </tr>
                        </thead>
                        <tbody>
                        {
                            (: Don't show links for templates in versioned projects :)
                            for $template in $projects//template
                            let $tid                  := $template/@id
                            let $ted                  := $template/@effectiveDate
                            let $tname                := $template/@name
                            let $statusCode           := data($template/@statusCode)
                            let $statusCodeForDisplay := $decorSchemaTypes/TemplateStatusCodeLifeCycle/enumeration[@value=$statusCode]/label[@language=$language]
                            order by $template/@displayName, $template/@effectiveDate
                            return 
                                <tr style="background-color:white" onMouseover="this.style.backgroundColor='lightblue';" onMouseout="this.style.backgroundColor='white';">
                                    <td>{
                                        if ($template/ancestor::decor[not(@versionDate)]) then 
                                            <a href="/art-decor/decor-templates--{$template/ancestor::decor/project/@prefix/string()}?templateName={$tname}&amp;templateEffectiveDate={$ted}">link</a>
                                        else ()
                                    }</td>
                                    <td>{$tid/string()}</td>
                                    <td>{$tname/string()}</td>
                                    <td>{$template/@displayName/string()}</td>
                                    <td>{$ted/string()}</td>
                                    <td>{$template/@expirationDate/string()}</td>
                                    <td><span class="node-s{$statusCode}">{if ($statusCodeForDisplay) then $statusCodeForDisplay else $statusCode}</span></td>
                                    <td>{$template/@versionLabel/string()}</td>
                                    {   if ($projectPrefix) then () else
                                        <td>{$template/ancestor::decor/project/@prefix/string()}</td>
                                    }
                                </tr>
                        }
                        </tbody>
                    </table>
                </div>
            ) else ()
        }
        </div>
            )
        }
    </body>
</html>
    )