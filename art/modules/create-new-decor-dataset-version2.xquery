xquery version "1.0";
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

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace datetime  = "http://exist-db.org/xquery/datetime";

(: This date is used for the new dataset and any child concepts :)
declare variable $now       := datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss");
declare variable $keepIds   := if (request:exists()) then request:get-parameter('keepIds','true') else ('false');



declare function local:inheritConcept($concept as element(), $statusCode as xs:string, $delmbaseId as xs:string) as item()* {

(:

if keep ids then only the effective date is set to now
if not keep ids then 
    (1) either new ids are generated (later) based on base id for datalelements
    (2) or if the format of the id is datalement.version.itemid then the new id is datalement.version+1.itemid

:)
let $cid        := $concept/@id
let $cid11      := string-join(tokenize($cid,'\.')[position() < last()], '.')
let $cid22      := number(tokenize($cid11,'\.')[last()]) + 1
let $cid33      := string-join(tokenize($cid11,'\.')[position() < last()], '.')
let $cid99      := number(tokenize($cid,'\.')[last()])

let $id := 
    if ($keepIds='true') then $cid else if ($cid11 = $delmbaseId) then concat('later:', $cid11) else concat($cid33, '.', $cid22, '.', $cid99)


let $eff        := $concept/@effectiveDate
(: Get name of concept this concept inherited from if applicable, else get name :)
let $nme        := if ($concept/inherit) then (art:getOriginalConceptName($concept/inherit)/name[1]/string()) else ($concept/name[1]/string())
(: Use id of concept this concept inherited from if applicable, else use id :)
let $inheritId  := if ($concept/inherit) then ($concept/inherit/@ref) else ($cid)
(: Use effectiveDate of concept this concept inherited from if applicable, else use effectiveDate :)
let $inheritEff := if ($concept/inherit) then ($concept/inherit/@effectiveDate) else ($eff)
return (
    comment {'Inherits from: ',$nme,' (status:',$concept/@statusCode/string(),', type:',$concept/@type/string(),')'},
    <concept id="{$id}" statusCode="{$statusCode}" effectiveDate="{$now}">
        <inherit ref="{$inheritId}" effectiveDate="{$inheritEff}"/>
        {
            for $subConcept in $concept/concept
            return
                if ($subConcept/@statusCode = ('new', 'draft', 'final')) then local:inheritConcept($subConcept, 'draft', $delmbaseId) else 
                if ($subConcept/@statusCode = ('deprecated')) then local:inheritConcept($subConcept, 'deprecated', $delmbaseId) else ()
        }
    </concept>
)
};



declare function local:add-attribute($input as node()?, $nextdelmId as xs:int) {
    let $xslt := 
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
            <xsl:param name="next" select="{$nextdelmId}"/>
             <xsl:template match="concept">
                <xsl:copy>
                     <xsl:apply-templates select="@*"/>
                     <xsl:variable name="prefid" select="substring-after(@id, ':')"/>
                     <xsl:attribute name="id">
                        <xsl:choose>
                            <xsl:when test="string-length($prefid)>0">
                               <xsl:value-of select="concat($prefid, '.', $next + count(preceding::concept|ancestor::concept))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@id"/>
                            </xsl:otherwise>
                        </xsl:choose>  
                     </xsl:attribute>
                     <xsl:apply-templates select="node()"/>
                </xsl:copy>
             </xsl:template>
             <xsl:template match="@*|node()">
                 <xsl:copy>
                     <xsl:apply-templates select="@*|node()"/>
                 </xsl:copy>
             </xsl:template>
         </xsl:stylesheet>
    return transform:transform($input, $xslt, ())
};




let $dataset       := if (request:exists()) then request:get-parameter('dataset',()) else ('')
let $datasetId     := substring-after($dataset, '|')
let $projectPrefix := substring-before($dataset, '|')

let $download      := if (request:exists()) then request:get-parameter('download',('false')) else ('false')


return
    if (string-length(normalize-space($projectPrefix))=0 or string-length(normalize-space($datasetId))=0) 
    then (
        response:set-header('Content-Type','text/html; charset=utf-8'),
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>Create-new-decor-dataset-version</title>
                <link href="/decor/services/resources/css/nictiz.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
                <h1>Create-new-decor-dataset-version</h1>
                <div class="content">
                <form name="input" action="/art/modules/create-new-decor-dataset-version.xquery" method="get">
                    <table border="0">
                        <tr>
                            <td>Project:</td>
                            <td>
                                <select name="dataset" style="width: 500px;">
                                {
                                    for $p in $get:colDecorData//decor/project
                                    let $dprefix := $p/@prefix
                                    order by lower-case($p/name[1])
                                    return
                                        for $q in $get:colDecorData//decor[project[@prefix=$dprefix]]/datasets/dataset
                                        let $did := $q/@id/string()
                                        return
                                            <option value="{$p/@prefix}|{$did}">{$p/name[1]} Dataset ID {$did}</option>
                                }
                                </select> (Verplicht)
                            </td>
                        </tr>
                        <tr>
                            <td>Met behoud van id:</td>
                            <td>
                                <select name="keepIds">
                                    <option value="true">Ja</option>
                                    <option value="false">Nee</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>Tonen of downloaden:</td>
                            <td>
                                <select name="download">
                                    <option value="true">Downloaden</option>
                                    <option value="false" selected="true">Tonen</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td><input type="submit" value="Verstuur"/></td>
                        </tr>
                    </table>
                </form>
                </div>
            </body>
        </html>
    ) 
    else (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        if ($download='true') then (response:set-header('Content-Disposition', concat('attachment; filename=',$projectPrefix,$datasetId,'-',replace($now,':',''),'.xml'))) else (),
        let $decor         := $get:colDecorData//decor[project/@prefix=$projectPrefix]
        let $baseId        := $decor//defaultBaseId[@type='DS']/@id/string()
        let $newDatasetId  := concat($baseId,'.',max($decor//dataset[starts-with(@id,concat($baseId,'.'))]/number(tokenize(@id,'\.')[last()]))+1)
        let $delmbaseId    := $decor//defaultBaseId[@type='DE']/@id/string()
        let $nextdelmId    := max($decor//concept[starts-with(@id,concat($delmbaseId,'.'))]/number(tokenize(@id,'\.')[last()])) + 1
        let $sourceDataset := $decor//dataset[@id=$datasetId]

        let $tempres :=
            <dataset id="{$newDatasetId}" statusCode="new" effectiveDate="{$now}">
            {
                $sourceDataset/*[name()!='concept'],
                for $concept in $sourceDataset/concept[not(ancestor::history)]
                return
                    (: new draft final => draft   and   deprecated => deprecated   and   rejected cancelled => (omit concept)  :)
                    if ($concept/@statusCode = ('new', 'draft', 'final')) then local:inheritConcept($concept, 'draft', $delmbaseId) else 
                    if ($concept/@statusCode = ('deprecated')) then local:inheritConcept($concept, 'deprecated', $delmbaseId) else ()
            }
            </dataset>
        (: prepare reshuffel concept/@id :)
        let $cid        := $tempres/concept[1]/@id
        let $cid11      := string-join(tokenize($cid,'\.')[position() < last()], '.')
        let $cid22      := number(tokenize($cid11,'\.')[last()]) + 1
        let $cid33      := string-join(tokenize($cid11,'\.')[position() < last()], '.')
        let $cid99      := number(tokenize($cid,'\.')[last()])
        
        
        let $result := if (count($tempres//concept[starts-with(@id,'later:')]) = 0) then $tempres else local:add-attribute($tempres, $nextdelmId)

        return
            $result

    )