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

import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace templ   = "http://art-decor.org/ns/decor/template" at "../api/api-decor-template.xqm";
declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace hl7       = "urn:hl7-org:v3";

declare variable $projectPrefix := request:get-parameter('project','');

declare function local:getTemplate($ref as xs:string?,$flexibility as xs:string?) as element()? {
    if ($ref) then 
        if ($flexibility) then
            (templ:getTemplateByRef($ref,$flexibility,$projectPrefix)/template/template)[1]
        else (
            (templ:getTemplateByRef($ref,'dynamic',$projectPrefix)/template/template)[1]
        )
    else ()
};

declare function local:getTemplateDisplayName($ref as xs:string?,$flexibility as xs:string?) as xs:string? {
    let $template := local:getTemplate($ref,$flexibility)
    return
        if (string-length($template/@displayName)>0) then ($template/@displayName) else ($template/@name)
};

declare function local:getTemplateStatusCode($ref as xs:string?,$flexibility as xs:string?) as xs:string? {
    let $template := local:getTemplate($ref,$flexibility)
    return
        $template/@statusCode
};

declare function local:getTemplateId($ref as xs:string?,$flexibility as xs:string?) as xs:string? {
    let $template := local:getTemplate($ref,$flexibility)
    return
        $template/@id
};

declare function local:filterDataset($concept as element(),$representingTemplate as element())  as element()* {
    let $id := $concept/@id
    return
        if (exists($representingTemplate/concept[@ref=$id])) then
            $concept
        else (),
        for $subConcept in $concept/concept
        return
            local:filterDataset($subConcept,$representingTemplate)

};

declare function local:scenarioBasics($transaction as element()) as element() {
    let $type     := $transaction/@type
    let $concepts := $get:colDecorData//concept
    return
        if ($type='group') then
            (:  transactions got versionable later in time, so may need to patch for content. Assume that it inherits 
                from e.g. scenario if it doesn't have its own data :)
            <transaction id="{$transaction/@id}" type="{$transaction/@type}" label="{$transaction/@label}" model="{$transaction/@model}" 
                         effectiveDate="{$transaction/@effectiveDate}" 
                         statusCode="{$transaction/@statusCode}" 
                         expirationDate="{$transaction/@expirationDate}" 
                         versionLabel="{$transaction/@versionLabel}">
            {
                for $name in $transaction/name
                return
                    art:serializeNode($name)
                ,
                for $desc in $transaction/desc
                return
                    art:serializeNode($desc)
                ,
                for $trigger in $transaction/trigger
                return
                    art:serializeNode($trigger)
                ,
                for $condition in $transaction/condition
                return
                    art:serializeNode($condition)
                ,
                for $dependencies in $transaction/dependencies
                return
                    art:serializeNode($dependencies)
                ,
                for $t in $transaction/transaction
                return
                    local:scenarioBasics($t)
            }
            </transaction>
        else (
            (:  transactions got versionable later in time, so may need to patch for content. Assume that it inherits 
                from e.g. scenario if it doesn't have its own data :)
            <transaction id="{$transaction/@id}" type="{$transaction/@type}" label="{$transaction/@label}" model="{$transaction/@model}" 
                         effectiveDate="{$transaction/@effectiveDate}" 
                         statusCode="{$transaction/@statusCode}" 
                         expirationDate="{$transaction/@expirationDate}" 
                         versionLabel="{$transaction/@versionLabel}">
            {
                for $name in $transaction/name
                return
                    art:serializeNode($name)
                ,
                for $desc in $transaction/desc
                return
                    art:serializeNode($desc)
                ,
                for $trigger in $transaction/trigger
                return
                    art:serializeNode($trigger)
                ,
                for $condition in $transaction/condition
                return
                    art:serializeNode($condition)
                ,
                for $dependencies in $transaction/dependencies
                return
                    art:serializeNode($dependencies)
            }
            <actors>
            {
                for $actor in $transaction/actors/actor
                return
                    <actor id="{$actor/@id}" role="{$actor/@role}">
                        {$get:colDecorData//scenarios/actors/actor[@id=$actor/@id]/name}
                    </actor>
            }
            </actors>
            <representingTemplate 
                ref="{$transaction/representingTemplate/@ref}"
                flexibility="{$transaction/representingTemplate/@flexibility}"
                templateId="{local:getTemplateId($transaction/representingTemplate/@ref,$transaction/representingTemplate/@flexibility)}" 
                templateDisplayName="{local:getTemplateDisplayName($transaction/representingTemplate/@ref,$transaction/representingTemplate/@flexibility)}" 
                templateStatusCode="{local:getTemplateStatusCode($transaction/representingTemplate/@ref,$transaction/representingTemplate/@flexibility)}" 
                sourceDataset="{$transaction/representingTemplate/@sourceDataset}">
            {
                $transaction/representingTemplate/(concept|comment())
            }
            </representingTemplate>
        </transaction>
    )
};

(:let $project      := 'demo1-':)
let $decorScenarios := $get:colDecorData//decor[project/@prefix=$projectPrefix]//scenarios

return
<scenarios projectPrefix="{$projectPrefix}">
    <actors>
    {
        for $actor in $decorScenarios/actors/actor
        return
        <actor>
        {
            $actor/@*,
            for $name in $actor/name
                    return
                    art:serializeNode($name)
            ,
            for $desc in $actor/desc
                    return
                    art:serializeNode($desc)
        }
        </actor>
    
    }
    </actors>
    {
        for $scenario in $decorScenarios/scenario
        order by $scenario/name[1]/lower-case(text()[1])
        return
            <scenario id="{$scenario/@id}" effectiveDate="{$scenario/@effectiveDate}" statusCode="{$scenario/@statusCode}" expirationDate="{$scenario/@expirationDate}" versionLabel="{$scenario/@versionLabel}">
            {
                for $name in $scenario/name
                return
                    art:serializeNode($name)
                ,
                for $desc in $scenario/desc
                return
                    art:serializeNode($desc)
                ,
                for $trigger in $scenario/trigger
                return
                    art:serializeNode($trigger)
                ,
                for $condition in $scenario/condition
                return
                    art:serializeNode($condition)
                ,
                for $transaction in $scenario/transaction
                return
                    local:scenarioBasics($transaction)
            }
            </scenario>
    }
</scenarios>
