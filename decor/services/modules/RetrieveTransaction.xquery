xquery version "3.0";
(:
	Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
	
	Author: Marc de Graauw, Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get         = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art         = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace adserver    = "http://art-decor.org/ns/art-decor-server" at "../../../art/api/api-server-settings.xqm";
import module namespace msg         = "urn:decor:REST:v1" at "get-message.xquery";

declare option exist:serialize "method=html5 media-type=text/html encoding=UTF-8";

declare variable $artDeepLink           := adserver:getServerURLArt();
declare variable $artDeepLinkTerminology:= if (contains($artDeepLink,'localhost')) then 'http://localhost:8877/terminology/' else concat($artDeepLink,'../terminology/');
declare variable $artDeepLinkServices   := adserver:getServerURLServices();

declare variable $codeSystemSNOMED      := '2.16.840.1.113883.6.96';
declare variable $codeSystemLOINC       := '2.16.840.1.113883.6.1';
declare variable $codeSystemsCLAML      := collection($get:strTerminologyData)//ClaML/Identifier/@uid;
(:performance:)
declare variable $codeSystemNames       := <cs id="{$codeSystemSNOMED}" nm="SNOMED-CT"/>|<cs id="{$codeSystemLOINC}" nm="LOINC"/>;

declare variable $useLocalAssets        := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath          := if ($useLocalAssets = 'true') then ('../assets') else ('resources');

declare function local:getDisplayNameFromCodesystem($code as xs:string, $codeSystem as xs:string) as xs:string* {
    if ($codeSystem=$codeSystemSNOMED) then
        doc(concat($artDeepLinkTerminology,'snomed/getConcept/',encode-for-uri($code)))//concept[@conceptId=$code]/desc[@type='fsn'][@active]
    else if ($codeSystem=$codeSystemLOINC) then
        doc(concat($artDeepLinkTerminology,'loinc/searchLOINC/',encode-for-uri($code)))//concept[@loinc_num=$code]/longName
    else
        doc(concat($artDeepLinkTerminology,'claml/RetrieveClass?classificationId=',$codeSystem,'&amp;code=',encode-for-uri($code)))/Class[@code=$code][@classificationId=$codeSystem]/Rubric[@kind='preferred']/Label[1]
};

(: Build HTML rows for concept 
:)
declare function local:getConceptRows(
    $concept as element(), 
    $parentId as xs:string, 
    $language as xs:string, 
    $baseIds as element()*, 
    $decortypes as element(), 
    $columns as element(), 
    $unfiltered as xs:string,
    $community as element()*,
    $isTransaction as xs:boolean,
    $version as xs:string?
    ) as element()* {
    let $rowId := concat('id_', replace($concept/@id, '\.', '_'))
    (: assemble termlist from terminologyAssociations on the concept, and conceptList(s) :)
    let $termList       := (
        for $item in $concept/terminologyAssociation[@code][@codeSystem]
        let $codeSystemName := 
            if ($codeSystemNames[@id=$item/@codeSystem]) then 
                $codeSystemNames[@id=$item/@codeSystem]/@nm 
            else if ($item/@codeSystemName) then 
                $item/@codeSystemName 
            else 
                art:getNameForOID($item/@codeSystem,$language,'')
        let $codeSystemName := if (string-length($codeSystemName)=0) then $item/@codeSystem else $codeSystemName
        let $displayName    := if ($item/@displayName) then $item/@displayName else local:getDisplayNameFromCodesystem($item/@code,$item/@codeSystem)
        let $deeplinktocode := 
            if ($item/@codeSystem=$codeSystemSNOMED) then
                concat($artDeepLink,'snomed-ct?conceptId=',encode-for-uri($item/@code))
            else if ($item/@codeSystem=$codeSystemLOINC) then
                concat($artDeepLink,'loinc?conceptId=',encode-for-uri($item/@code))
            else if ($item/@codeSystem=$codeSystemsCLAML) then
                concat($artDeepLink,'claml?classificationId=',encode-for-uri($item/@codeSystem),'&amp;conceptId=',encode-for-uri($item/@code))
            else ()
        let $title          := concat(msg:getMessage('columnCode',$language),': ',$item/@code,' ',$displayName,' (',$codeSystemName,')')
        return 
        <li title="{$title}">{
            if ($deeplinktocode) then 
                <a href="{$deeplinktocode}">{concat($item/@code/string(), ' - ', $codeSystemName)}</a>
            else
                concat($item/@code/string(), ' - ', $codeSystemName)
        }</li>
        ,
        for $valueSet in $concept/valueSet[@id]
        let $vsid   := $valueSet/@id/string()
        let $vsnm   := $valueSet/@name/string()
        let $vsef   := $valueSet/@effectiveDate/string()
        let $vsdn   := if ($valueSet/@displayName) then ($valueSet/@displayName/string()) else ($valueSet/@name/string())
        let $tatype := if ($valueSet/terminologyAssociation[matches(@flexibility,'^\d')]) then (msg:getMessage('static',$language)) else (msg:getMessage('dynamic',$language))
        return
            <li title="{concat(msg:getMessage('columnValueSet',$language),': ',$vsid,' ',$vsdn,' ',$vsef,' (',$tatype,')')}">
                <a href="RetrieveValueSet?id={$vsid}&amp;effectiveDate={$vsef}&amp;version={$version}&amp;format=html&amp;language={$language}">{$vsdn}</a>
            </li>
        )
    (: assemble codelist :)
    let $codeList    := 
        if ($concept/valueDomain/conceptList/concept) then (
            <ul>
            {
            for $item in $concept/valueDomain/conceptList/concept
            let $name := if ($item/name[@language=$language]) then $item/name[@language=$language] else $item/name[1]
            return 
            <li>{$name/string()}</li>
            }
            </ul>
        )
        else if ($concept/valueSet/conceptList/concept) then (
            <ul>
            {
            for $item in $concept/valueSet/conceptList/*[not(@type='A')]
            let $name := if ($item/name[@language=$language]) then $item/name[@language=$language] else $item/name[1]
            return <li>{$name/string()}</li>
            }
            {
            for $item in $concept/valueSet/completeCodeSystem
            let $csid := $item/@codeSystem
            return 
            <li>{concat(msg:getMessage('columnCodeSystem',$language),': ', if ($item/@codeSystemName/string()) then $item/@codeSystemName/string() else art:getNameForOID($csid,$language,''))}</li>
            }
            </ul>
        ) else ()
    (: assemble the data content for table details :)
    let $tds :=
            <tr>
                <td class="columnName" style="{if ($concept/@statusCode/string()='draft' or $concept/@statusCode/string()='final') then '' else 'color:#bbb;'}">
                    {   
                        $concept/name[@language=$language][1]/string(), if ($concept/synonym) then concat('(', string-join($concept/synonym, ', '), ')') else()
                    }
                </td>
                <td class="columnID">{replace(concat($baseIds[@id=string-join(tokenize($concept/@id,'\.')[position()!=last()],'.') ]/@prefix,tokenize($concept/@id,'\.')[last()]),'-dataelement', '')}</td>
                {
                    if ($isTransaction) then (
                    <td class="columnMandatory">{if ($concept[@isMandatory="true"]) then "+" else "-"}</td>,
                    <td class="columnConformance">{$concept/@conformance/string()}</td>,
                    <td class="columnCardinality">{if ($concept/@conformance='NP' or string-length(concat($concept/@minimumMultiplicity,$concept/@maximumMultiplicity))=0) then () else concat($concept/@minimumMultiplicity/string(), '..', $concept/@maximumMultiplicity/string())}</td>,
                    <td class="columnMax">{if ($concept/@conformance='NP') then () else replace($concept/@maximumMultiplicity, '\*', 'n')}</td>
                    ) else ()
                }
                <td class="columnDatatype">{$decortypes//DataSetValueType/enumeration[@value=$concept/valueDomain/@type][1]/label[@language=$language]/string()}</td>
                <td class="columnUnit">{string-join($concept/valueDomain/property/@unit, '; ')}</td>
                <td class="columnExample">{string-join($concept/valueDomain/example, '; ')}</td>
                <td class="columnCodes">{$codeList}</td>
                <td class="columnDescription">{$concept/desc/string()}</td>
                <td class="columnSource">{$concept/source/string()}</td>
                <td class="columnRationale">{$concept/rationale/string()}</td>
                <td class="columnOperationalization">{$concept/operationalization/string()}</td>
                <td class="columnComment"><ul>{for $comment in $concept/comment return <li>{$comment/string()}</li>}</ul></td>
                {
                    if ($isTransaction) then (
                    <td class="columnCondition">{
                        if ($concept/condition) then (
                            <ul>
                            {
                                for $condition in $concept/condition[not(position()=last())] 
                                return
                                    <li> 
                                    {
                                        concat($condition/@minimumMultiplicity/string(), '..', $condition/@maximumMultiplicity/string(), ' ', $condition/@conformance/string(), ': ', $condition/string())
                                    }
                                    </li>
                            }
                            {
                                    <li>
                                    {
                                        concat($concept/condition[position()=last()]/@minimumMultiplicity/string(), '..', $concept/condition[position()=last()]/@maximumMultiplicity/string(), 
                                        ' ', $concept/condition[position()=last()]/@conformance/string(), ' ', msg:getMessage('else',$language))
                                    }
                                    </li>
                            }
                            </ul>
                        ) else ()
                    }</td>
                    ) else ()
                }
                <td class="columnStatus">{$concept/@statusCode/string()}</td>
                {
                    if (not(empty($community))) then
                        <td class="columnCommunity">
                            <ul>
                            {
                                for $association in $community//associations/association[object[@type='DE'][@ref=$concept/@id]]/data
                                let $assocType  := $association/@type
                                let $typeDef    := $association/ancestor::community/prototype/data[@type=$assocType]
                                return
                                    <li>
                                        {<span title="{$typeDef/@label}" style="padding: inherit;">{$assocType/string()}</span>}: {$association/node()}
                                    </li>
                            }
                            </ul>
                        </td>
                    else ()
                }
                <td class="columnTerminology">{$termList}</td>
            </tr>
    (: assemble table row, and hide or show columns :)
    let $tr :=
            <tr class="bg-{$concept/@type}" data-tt-id="{$rowId}">
                {
                if (string($parentId) = '') then () else attribute data-tt-parent-id {$parentId},
                for $td in $tds/td
                return 
                    <td>{
                        $td/@*, 
                        if ($columns/column[@name=$td/@class]/@hidden) then (attribute style {'display:none;'}) else (), 
                        if ($td[@class=('columnCodes','columnComment','columnCommunity')]) then $td/*[1] else if ($td[@class=('columnTerminology')]) then $td/* else $td/string()
                    }</td>
                }
            </tr>
    return ($tr, 
        let $children := if ($unfiltered = 'true')
            then $concept/concept
            else $concept/concept[not(@statusCode='deprecated')][not(@statusCode='obsolete')]
        for $conceptChild in $children
        return local:getConceptRows($conceptChild, $rowId, $language, $baseIds, $decortypes, $columns, $unfiltered, $community,$isTransaction, $version)) 
};

(: Build the main HTML view 
Accepts hidecolumns string, i.e.: '123456789a' or '54'
Hides columns based on (hex) number. 
:)
declare function local:getHTML(
    $fullDatasetTree as node(), 
    $language as xs:string, 
    $baseIds as element()*, 
    $decortypes as element(), 
    $hidecolumns as xs:string, 
    $unfiltered as xs:string, 
    $version as xs:string?,
    $url as xs:anyURI?,
    $logo as xs:anyURI?,
    $community as element()*
    )  as node() {
    let $isTransaction := exists($fullDatasetTree/@transactionId)
    let $title         := 
        if ($isTransaction) then 
            msg:getMessage('Transaction',$language,$fullDatasetTree/name[@language=$language][1]/string())
        else (
            msg:getMessage('DataSet',$language,$fullDatasetTree/name[@language=$language][1]/string())
        )
    (: column name can't be hidden :)
    let $columns :=
    <columns>
        <column name="columnName"></column>
        <column name="columnID">                {if (contains($hidecolumns, '2'))                                                   then attribute hidden {'true'} else () }</column>
        {if ($isTransaction) then (
        
            <column name="columnMandatory">     {if (contains($hidecolumns, '3') or not($fullDatasetTree/@transactionId))           then attribute hidden {'true'} else () }</column>,
            <column name="columnConformance">   {if (contains($hidecolumns, '4') or not($fullDatasetTree/@transactionId))           then attribute hidden {'true'} else () }</column>,
            <column name="columnCardinality">   {if (contains($hidecolumns, '5') or not($fullDatasetTree/@transactionId))           then attribute hidden {'true'} else () }</column>,
            <column name="columnMax">           {if (contains($hidecolumns, '6') or not($fullDatasetTree/@transactionId))           then attribute hidden {'true'} else () }</column>
        
        ) else ()}
        <column name="columnDatatype">          {if (contains($hidecolumns, '7'))                                                   then attribute hidden {'true'} else () }</column>
        <column name="columnUnit">              {if (contains($hidecolumns, '8'))                                                   then attribute hidden {'true'} else () }</column>
        <column name="columnExample">           {if (contains($hidecolumns, '9'))                                                   then attribute hidden {'true'} else () }</column>
        <column name="columnCodes">             {if (contains($hidecolumns, 'a'))                                                   then attribute hidden {'true'} else () }</column>
        <column name="columnDescription">       {if (contains($hidecolumns, 'b'))                                                   then attribute hidden {'true'} else () }</column>
        <column name="columnSource">            {if (contains($hidecolumns, 'c'))                                                   then attribute hidden {'true'} else () }</column>
        <column name="columnRationale">         {if (contains($hidecolumns, 'd'))                                                   then attribute hidden {'true'} else () }</column>
        <column name="columnOperationalization">{if (contains($hidecolumns, 'e'))                                                   then attribute hidden {'true'} else () }</column>
        <column name="columnComment">           {if (contains($hidecolumns, 'f'))                                                   then attribute hidden {'true'} else () }</column>
        {if ($isTransaction) then (
        
            <column name="columnCondition">         {if (contains($hidecolumns, 'g') or not($fullDatasetTree/@transactionId))       then attribute hidden {'true'} else () }</column>
        
        ) else ()}
        <column name="columnStatus">            {if (contains($hidecolumns, 'h'))                                                   then attribute hidden {'true'} else () }</column>
        {if (not(empty($community))) then
        
            <column name="columnCommunity">     {if (contains($hidecolumns, 'i'))                                                   then attribute hidden {'true'} else () }</column>
        
        else ()}
        <column name="columnTerminology">       {if (contains($hidecolumns, 'j'))                                                   then attribute hidden {'true'} else () }</column>
    </columns>

    (: for testing only :)
    (:let $linkroot := 'http://localhost:8877':)
    let $html := 
    <html>
        <head>
            <title>{$title}</title>
            <meta charset="UTF-8"></meta>
            <script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-1.9.0.js"></script>
            <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"></link>
            <!--link href="{$linkroot}/decor/services/resources/css/nictiz.css" rel="stylesheet" type="text/css"/-->
            <link href="{$resourcePath}/css/jquery.treetable.css" rel="stylesheet" type="text/css" />
            <link href="{$resourcePath}/css/jquery.treetable.theme.css" rel="stylesheet" type="text/css" />
            <!--link href="{$linkroot}/decor/services/resources/css/jquery.treetable.theme.nictiz.css" rel="stylesheet" type="text/css" /-->
            <script src="{$resourcePath}/scripts/jquery.treetable.js"></script>
            <script src="{$resourcePath}/scripts/treetable-extra.js"></script>
            <style type="text/css">
                .bg-item {{ }}
                .bg-group {{ background-color: #eee; }}
            </style>
        </head>
        <body>
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
                </tbody>
            </table>
            <p>{msg:getMessage('columnVersionLabel',$language)}: {if ($version) then $version else msg:getMessage('columnLatestVersion',$language)}</p>
            <button id="expandAll" type="button">{msg:getMessage('buttonExpandAll',$language)}</button> 
            <button id="collapseAll" type="button">{msg:getMessage('buttonCollapseAll',$language)}</button> 
            <!--button id="collapseCodes" type="button">{msg:getMessage('buttonCollapseAllCodes',$language)}</button-->
            <select id="hiddenColumns"> 
                <option value="title">{msg:getMessage('showColumn',$language)}</option>
                    {
                    for $column in $columns/column[not(@name='columnName')]
                    return 
                    <option value="{$column/@name/string()}">{if ($column/@hidden) then () else attribute disabled {'disabled'}, msg:getMessage($column/@name/string(),$language)}</option> 
                    }
            </select> 
            <table id="transactionTable">
                <thead>
                    <tr>
                        <th class="columnName">
                            <b>{msg:getMessage('columnName', $language)}</b>
                        </th>
                       {
                       for $column in $columns/column[not(@name='columnName')]
                       return 
                        <th class="{$column/@name}">
                            {if ($column/@hidden) then (attribute style {'display:none;'}) else ()}
                            <b>{msg:getMessage($column/@name,$language)}</b>
                            <button class="hideMe" style="float:right" type="button"><b>x</b></button>
                        </th>
                       }
                    </tr>
                </thead>
                <tbody>
                    {
                    let $children := if ($unfiltered = 'true')
                        then $fullDatasetTree/concept
                        else $fullDatasetTree/concept[not(@statusCode='deprecated')][not(@statusCode='obsolete')]
                    for $concept in $children
                    return local:getConceptRows($concept, '', $language, $baseIds, $decortypes, $columns, $unfiltered, $community, $isTransaction, $version)
                    }
                </tbody>
            </table>
        </body>
    </html>
    return $html
};

declare function local:getSimpleHTML(
    $fullDatasetTree as node(), 
    $language as xs:string, 
    $baseIds as element()*, 
    $decortypes as element(), 
    $hidecolumns as xs:string, 
    $unfiltered as xs:string, 
    $version as xs:string?,
    $url as xs:anyURI?,
    $logo as xs:anyURI?,
    $community as element()*
    )  as node() {
    let $title        := 
        if ($fullDatasetTree/@transactionId) then 
            msg:getMessage('Transaction',$language,$fullDatasetTree/name[@language=$language][1]/string())
        else (
            msg:getMessage('DataSet',$language,$fullDatasetTree/name[@language=$language][1]/string())
        )
    
    let $columns := <columns/>

    let $html := 
    <html>
        <head>
            <title>{$title}</title>
            <meta charset="UTF-8"></meta>
            <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"></link>
            <style type="text/css">
                 <![CDATA[
                 ol { list-style-type: none; }
                 li.group { font-weight: bold; }
                 li.item { list-style-type: none; }
                 ul.code { list-style-position: inside; padding: 10px; border: 0px; }
                 li.condition { list-style-type: circle; }
                 ]]>
            </style>
        </head>
        <body>
        
        {
        
            let $children := if ($unfiltered = 'true')
                then $fullDatasetTree/concept
                else $fullDatasetTree/concept[not(@statusCode='deprecated')][not(@statusCode='obsolete')]
            for $concept in $children
                return local:getSimpleConceptRows($concept, $language, $baseIds, $decortypes, $columns, $unfiltered, $community, 1)
        }
        </body>
    </html>
    return $html
};

declare function local:getSimpleConceptRows(
    $concept as element(), 
    $language as xs:string, 
    $baseIds as element()*, 
    $decortypes as element(), 
    $columns as element(), 
    $unfiltered as xs:string,
    $community as element()*,
    $level as xs:integer
    ) as element()* {
    
     (: assemble codelist :)
    let $codeList := 
        if ($concept/valueSet/conceptList/concept) then (
            <ul class="code">
            {
            for $item in $concept/valueSet/conceptList/*
            return <li>{$item/name[1]/string()}</li>
            }
            {
            for $item in $concept/valueSet/completeCodeSystem
            let $csid := $item/@codeSystem
            return 
            <li>{concat('Codesystem: ', if ($item/@codeSystemName/string()) then $item/@codeSystemName/string() else art:getNameForOID($csid,$language,''))}</li>
            }
            </ul>
        ) else if ($concept/valueDomain/conceptList/concept) then (
            <ul class="code">
            {
            for $item in $concept/valueDomain/conceptList/concept
            return 
            <li>{$item/name[1]/string()}</li>
            }
            </ul>
        ) else ()
    let $condition := 
        if ($concept/condition) then (
            <ul>
            {
                for $condition in $concept/condition[not(position()=last())] 
                return
                    <li class="condition"> 
                    {
                        concat($condition/@minimumMultiplicity/string(), '..', $condition/@maximumMultiplicity/string(), ' ', $condition/@conformance/string(), ': ', $condition/string())
                    }
                    </li>
            }
            {
                    <li class="condition">
                    {
                        concat($concept/condition[position()=last()]/@minimumMultiplicity/string(), '..', $concept/condition[position()=last()]/@maximumMultiplicity/string(), 
                        ' ', $concept/condition[position()=last()]/@conformance/string(), ' ', msg:getMessage('else',$language))
                    }
                    </li>
            }
            </ul>
        ) else ()
    
    let $children := 
        if ($unfiltered = 'true')
        then $concept/concept
        else $concept/concept[not(@statusCode='deprecated')][not(@statusCode='obsolete')]
    
    let $ci := concat($concept/name[@language=$language][1]/string(), if ($concept/synonym) then concat('(', string-join($concept/synonym, ', '), ')') else(), ' ',
        if ($concept/@type='group') then '' else concat(' (', $decortypes//DataSetValueType/enumeration[@value=$concept/valueDomain/@type][1]/label[@language=$language]/string(), ') '),
        tokenize($concept/@id,'\.')[last()], ' ',
        if ($concept/@conformance='NP') then 'NP' else concat($concept/@minimumMultiplicity/string(), '..', $concept/@maximumMultiplicity/string()), ' ', 
        $concept/@conformance/string())
    
    let $html := 
        if ($level = 1) 
        then (
            <h2>{$ci}</h2>,
            <i>{$condition}</i>,
            $codeList,
            for $conceptChild in $children
            return local:getSimpleConceptRows($conceptChild, $language, $baseIds, $decortypes, $columns, $unfiltered, $community, $level+1)
        )
        else (
            <ol>
                <li class="{if ($concept/@type='group') then 'group' else 'item'}">{$ci}</li>
                {
                     <i>{$condition}</i>
                }
                {
                    $codeList
                }
                {
                    for $conceptChild in $children
                    return local:getSimpleConceptRows($conceptChild, $language, $baseIds, $decortypes, $columns, $unfiltered, $community, $level+1)
                }
            </ol>
        )
    return
        $html
    
};

declare function local:mergeDatasetTreeWithCommunity (
    $fullDatasetTree as node(), 
    $language as xs:string, 
    $community as element()*
    ) as node() {
    <dataset>
    {
        $fullDatasetTree/@*
        ,
        for $node in $fullDatasetTree/*
        return 
            if ($node instance of element(concept)) then
                local:mergeConceptTreeWithCommunity($node,$language,$community)
            else ($node)
    }
    </dataset>
};

declare function local:mergeConceptTreeWithCommunity (
    $concept as element(), 
    $language as xs:string, 
    $community as element()*
    ) as element() {
    let $communityInfo := $community//associations/association[object[@ref=$concept/@id][@type='DE']][data]
    return
    <concept>
    {
        $concept/@*,
        $concept/inherit,
        $concept/name,
        $concept/desc
    }
    {
        if (exists($communityInfo)) then
            <community name="{$communityInfo/ancestor::community/@name}">
            {
                for $association in $communityInfo/data
                let $assocType  := $association/@type
                let $typeDef    := $association/ancestor::community/prototype/data[@type=$assocType]
                return
                    <data>
                    {
                        $typeDef/@*,
                        $association/node()
                    }
                    </data>
            }
            </community>
        else ()
    }
    {
        for $node in $concept/(* except (inherit|name|desc))
        return 
            if  ($node instance of element(concept)) then
                local:mergeConceptTreeWithCommunity($node,$language,$community)
            else ($node)
    }
    </concept>
};

let $id                   := if (request:exists()) then request:get-parameter('id','') else '2.16.840.1.113883.2.4.3.36.77.4.401'
let $communityprefix      := if (request:exists()) then request:get-parameter('community','') else ''
    (: rivm mdl bericht :)
    (: '2.16.840.1.113883.2.4.3.11.60.90.77.4.2301':) (: peri acute overdracht:)
    (:'2.16.840.1.113883.3.1937.99.62.3.4.2':) (: transactie demo1 :)
    (:'2.16.840.1.113883.2.4.3.36.77.1.1':) (: dataset rivm :)
    (:'2.16.840.1.113883.2.4.3.11.60.90.77.1.3':) (: dataset peri :)
    (:'2.16.840.1.113883.3.1937.99.62.3.1.1':) (: dataset demo1 :)
let $version              := if (request:exists()) then request:get-parameter('version',()) else ()
let $format               := if (request:exists()) then request:get-parameter('format','html') else 'html'
let $hidecolumns          := if (request:exists()) then request:get-parameter('hidecolumns','') else ''
let $language             := if (request:exists()) then request:get-parameter('language',()) else ()
let $unfiltered           := if (request:exists()) then request:get-parameter('unfiltered','false') else 'false'
let $decortypes           := art:getDecorTypes()

let $project              := 
    if ($version)
    then $get:colDecorVersion//decor[descendant-or-self::*[@id=$id]][@versionDate=$version][empty($language) or @language=$language][1]
    else $get:colDecorData//decor[descendant-or-self::*[@id=$id]]
let $transactionOrDataset := $project//(dataset|transaction)[@id=$id][not(@type='group')]
let $referenceLogo        := $project/project/reference/@logo
let $referenceUrl         := $project/project/reference/@url
let $projectId            := $project/project/@id

let $language             := if (empty($language)) then $project/project/@defaultLanguage else ($language)

let $fullDatasetTree      := 
    if ($version) then (
        if (name($transactionOrDataset) = 'dataset') 
        then ($project//dataset[@id=$id]) 
        else ($get:colDecorVersion//transactionDatasets[@versionDate = $version][@language = $language]//dataset[@transactionId=$id])
    ) else if ($id) then (
        art:getFullDatasetTree($id, $language)
    ) else ()
    
let $community            := $get:colDecorData//community[not($communityprefix) or @name=$communityprefix][@projectId=$projectId][access/author[@username=(xmldb:get-current-user(),'guest')][contains(@rights,'r')]]
(:let $community            := $get:colDecorData//community[@name=$communityprefix][@projectId=$projectId]:)
    
(: replace the longest baseId in output, could be improved by using baseId prefix :)
let $baseIds := for $id in $project//ids/baseId[@type='DE'] order by $id/string-length(@id) return $id
let $result  := 
    if (not($fullDatasetTree)) then (
        if (request:exists()) then (
            response:set-status-code(404), response:set-header('Content-Type','text/xml')
         ) else ()
    )
    else if ($format = 'xml') then (
        let $xml := local:mergeDatasetTreeWithCommunity($fullDatasetTree,$language,$community)
        return if (request:exists()) then (response:set-header('Content-Type','text/xml'), $xml) else ($xml)
    ) 
    else if ($format = 'list') then (
        let $html := local:getSimpleHTML($fullDatasetTree, $language, $baseIds, $decortypes, $hidecolumns, $unfiltered, $version, $referenceUrl, $referenceLogo, $community)
        return if (request:exists()) then (response:set-header('Content-Type','text/html'), $html) else ($html)
    )
    else (
        let $html := local:getHTML($fullDatasetTree, $language, $baseIds, $decortypes, $hidecolumns, $unfiltered, $version, $referenceUrl, $referenceLogo, $community)
        return if (request:exists()) then (response:set-header('Content-Type','text/html'), $html) else ($html)
    )
return $result