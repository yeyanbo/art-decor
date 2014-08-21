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

declare function local:inheritConcept($concept as element()) as item()* {
let $id         := $concept/@id
let $eff        := $concept/@effectiveDate
(: Get name of concept this concept inherited from if applicable, else get name :)
let $nme        := if ($concept/inherit) then (art:getOriginalConceptName($concept/inherit)/name[1]/string()) else ($concept/name[1]/string())
(: Use id of concept this concept inherited from if applicable, else use id :)
let $inheritId  := if ($concept/inherit) then ($concept/inherit/@ref) else ($id)
(: Use effectiveDate of concept this concept inherited from if applicable, else use effectiveDate :)
let $inheritEff := if ($concept/inherit) then ($concept/inherit/@effectiveDate) else ($eff)
return (
    comment {'Inherits from: ',$nme,' (status:',$concept/@statusCode/string(),', type:',$concept/@type/string(),')'},
    <concept id="{$id}" statusCode="draft" effectiveDate="{$now}">
        <inherit ref="{$inheritId}" effectiveDate="{$inheritEff}"/>
        {
            for $subConcept in $concept/concept
            return
                local:inheritConcept($subConcept)
        }
    </concept>
)
};

let $projectPrefix := if (request:exists()) then request:get-parameter('prefix',()) else ('hwg-')
let $datasetId     := if (request:exists()) then request:get-parameter('datasetId',()) else ('2.16.840.1.113883.2.4.3.11.60.70.77.1.1')
let $download      := if (request:exists()) then request:get-parameter('download',('false')) else ('false')
(: TODO this parameter is not implemented :)
let $keepIds       := if (request:exists()) then request:get-parameter('keepIds','true') else ('true')

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
                                <select name="prefix" style="width: 300px;">
                                {
                                    for $p in $get:colDecorData//decor/project
                                    order by lower-case($p/name[1])
                                    return
                                        <option value="{$p/@prefix}">{$p/name[1]}</option>
                                }
                                </select> (Verplicht)
                            </td>
                        </tr>
                        <tr>
                            <td>Dataset-id:</td>
                            <td><input type="text" name="datasetId" value="" style="width: 300px;"/> (Verplicht)</td>
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
        let $sourceDataset := $decor//dataset[@id=$datasetId]

        return
            <dataset id="{$newDatasetId}" statusCode="new" effectiveDate="{$now}">
            {
                $sourceDataset/*[name()!='concept'],
                for $concept in $sourceDataset/concept[not(ancestor::history)]
                return
                    local:inheritConcept($concept)
            }
            </dataset>
    )