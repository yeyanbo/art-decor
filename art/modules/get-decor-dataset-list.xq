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

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

declare namespace request  = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace datetime = "http://exist-db.org/xquery/datetime";
declare namespace hl7="urn:hl7-org:v3";

<datasets>
{
    let $project    := if (request:exists()) then request:get-parameter('project','') else ''
    (:let $project    := 'peri20-':)
    let $collection := $get:strDecorData
    let $datasets   := 
        if (string-length($project)>1) then
            collection($collection)//decor[project/@prefix=$project]//dataset
        else (
            collection($collection)//dataset
        )
    
    for $dataset in $datasets
    let $statusCode := 
        if (not($dataset/@statusCode)) then
            if (count($dataset//concept[@statusCode='draft'])=0 and count($dataset//concept[@statusCode='new'])=0) then
                'final'
            else (
                'draft'
            )
        else (
            $dataset/@statusCode
        )
    order by $dataset/name[1]
    return
    <dataset projectId="{$dataset/../../project/@id}" id="{$dataset/@id}" effectiveDate="{$dataset/@effectiveDate}" statusCode="{$statusCode}" versionLabel="{$dataset/@versionLabel}">
    {
        for $name in $dataset/name
        let $label := 
            if ($name/../@versionLabel[string-length()>0]) 
            then concat(' (',$name/../@versionLabel,')') 
            else () 
        return
            (: use this for the drop down selector :)
            <name>
            {
                $name/@*
                ,
                (: functional people find the date attached to the name in the selector/drop down list in the UI confusing
                    and it is not necessary when the name for a given language is unique enough. Often the effectiveDate
                    is not very helpful at all and rather random. So we generate a language dependent name specifically for 
                    the drop down selector that only concatenates the effectiveDate when the name for the given language is 
                    not unique in itself.
                :)
                attribute {'selectorName'} {
                    if (count($datasets[name[concat(.,../@versionLabel)=concat($name,$name/../@versionLabel)][@language=$name/@language]])>1) then (
                        (: eXist 2.0: concat($name, $label,' :: ', datetime:format-dateTime(xs:dateTime($dataset/@effectiveDate),'[Y]-[M01]-[D01]', substring($name/@language,1,2), (), ())):)
                        (: eXist 1.5 :)
                        concat($name, $label,' :: ', datetime:format-dateTime(xs:dateTime($dataset/@effectiveDate),"yyyy-MM-dd'T'HH:mm:ss"))
                        
                    ) else (
                        concat($name, $label)
                    )
                }
                ,
                $name/node()
            }
            </name>
        ,
        $dataset/desc
    }
    </dataset>
}
</datasets>
