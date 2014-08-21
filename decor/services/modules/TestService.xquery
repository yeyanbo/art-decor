xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Marc de Graauw, Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
	
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";

declare option exist:serialize "method=xhtml media-type=xhtml";

import module namespace f = "urn:decor:REST:v1" at "get-message.xquery";

let $id       := request:get-parameter('id','')
let $language := request:get-parameter('language',$get:strArtLanguage)

let $parameters :=  request:get-parameter-names()

let $searchString := 
    for $parKey in $parameters
        let $parValue := request:get-parameter($parKey,'')
    return
        if ($parKey != 'format' and string-length($parValue) > 0) then
            (concat('@',$parKey,'=&apos;',$parValue,'&apos;'))
        else 
            ()

let $projects := xmldb:xcollection($get:strDecorData)
(:<dataset id="2.999.999.999.77.1.1" effectiveDate="2009-10-01" expirationDate="" statusCode="" versionLabel="">:)
let $datasets := xmldb:xcollection($get:strDecorData)//datasets/dataset[if ($id='') then (@*) else (@id=$id)]

return 
    if (empty($datasets)) then
        (response:set-status-code(404), <error>{f:getMessage('errorRetrieveDatasetNoResults',$language),' ',$searchString}</error>)
    else (
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>DataSetIndex</title>
        <link href="/styles/nictiz.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <h1>Data Set Index</h1>
        <div class="content">
            <table class="values" id="dataSetList">
                <thead>
                    <tr>
                        <th>XML</th>
                        <th>HTML</th>
                        <th>{f:getMessage('columnID',$language)}</th>
                        <th>{f:getMessage('effectiveDate',$language)}</th>
                        <th>{f:getMessage('expirationDate',$language)}</th>
                        <th>{f:getMessage('columnStatus',$language)}</th>
                        <th>{f:getMessage('columnVersionLabel',$language)}</th>
                        <th>{f:getMessage('columnProjects',$language)}</th>
                    </tr>
                </thead>
                <tbody>
                {
                    for $dataset in $datasets
                        let $dataSetStatusCode := if ($dataset/@statusCode) then (data($dataset/@statusCode)) else
                            if (count($dataset//concept[@statusCode='draft'])=0 and count($dataset//concept[@statusCode='new'])=0) then 'final' else ('draft')
                        let $t_id := $dataset/@id
                        let $t_effectiveDate := $dataset/@effectiveDate
                    order by $dataset/@displayName, $dataset/@effectiveDate
                    return 
                       <tr>
                           <td><a href="RetrieveDataSet?id={data($dataset/@id)}&amp;effectiveDate={data($dataset/@effectiveDate)}&amp;format=xml">xml</a></td>
                           <td><a href="RetrieveDataSet?id={data($dataset/@id)}&amp;effectiveDate={data($dataset/@effectiveDate)}&amp;format=html">html</a></td>
                           <td>{data($dataset/@id)}</td>
                           <td>{data($dataset/@effectiveDate)}</td>
                           <td>{data($dataset/@expirationDate)}</td>
                           <td>{$dataSetStatusCode}</td>
                           <td>{data($dataset/@versionLabel)}</td>
                           <td>{data($projects/*[datasets/dataset[
                                    if ($t_effectiveDate!='') then (
                                        @id=$t_id and @effectiveDate=$t_effectiveDate
                                    ) else (
                                        @id=$t_id
                                    )
                                ]]/project/@prefix)}</td>
                       </tr>
                }
                   </tbody>
            </table>
        </div>
    </body>
</html>
)