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

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace hl7       = "urn:hl7-org:v3";

declare function local:conceptBasics($concept as element()) as element() {
    let $id :=$concept/@id
    return
        if (string-length($concept/inherit/@ref)>1) then
            let $inheritedConcept := 
                if ($concept/inherit/@effectiveDate castable as xs:dateTime) 
                then $get:colDecorData//concept[@id=$concept/inherit/@ref][@effectiveDate=$concept/inherit/@effectiveDate]
                else($get:colDecorData//concept[@id=$concept/inherit/@ref][@statusCode='final'])
            let $baseId :=string-join(tokenize($inheritedConcept/@id,'\.')[position()!=last()],'.')
            let $prefix := $get:colDecorData//baseId[@id=$baseId]/@prefix
            
            return
                <concept id="{$id}" inheritedType="{$inheritedConcept/@type}" inheritedStatusCode="{$inheritedConcept/@statusCode}" effectiveDate="{$inheritedConcept/@effectiveDate}" versionLabel="{$inheritedConcept/@versionLabel}" expirationDate="{$inheritedConcept/@expirationDate}" prefix="{$prefix}">
                {
                    for $name in $inheritedConcept/name
                    return
                    <inheritedName language="{$name/@language}">{$name/text()}</inheritedName>
                    ,
                    
                    for $c in $concept/concept
                    return
                    local:conceptBasics($c)
                }
                </concept>
        
        else (
            <concept id="{$id}" type="{$concept/@type}"  statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}">
            {
                $concept/name
                ,
                for $c in $concept/concept
                return
                local:conceptBasics($c)
            }
            </concept>
        )
};

<datasets>
{
    let $id := request:get-parameter('id','2.16.840.1.113883.2.4.6.99.1.77.1')
    (:let $id := '2.16.840.1.113883.2.4.6.99.1.77.1':)
    let $collection := $get:strDecorData
    let $dataset    := collection($collection)//dataset[@id=$id]
    let $statusCode := 
        if (not($dataset/@statusCode)) then
            if (count($dataset//concept[@statusCode='draft'])=0 and count($dataset//concept[@statusCode='new'])=0) 
            then ('final')
            else ('draft')
        else ($dataset/@statusCode)
    
    return
    <dataset id="{$dataset/@id}" effectiveDate="{$dataset/@effectiveDate}" statusCode="{$statusCode}">
    {
        $dataset/name,
        $dataset/desc,
        for $concept in $dataset/concept
        return
        local:conceptBasics($concept)
    }
    </dataset>
}
</datasets>
