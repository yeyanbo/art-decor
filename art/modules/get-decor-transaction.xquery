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
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace hl7="urn:hl7-org:v3";

declare function local:getTemplateDisplayName($ref as xs:string?,$flexibility as xs:string?) as xs:string? {
   if (string-length($ref)>0) then
      let $templates           := collection($get:strDecorData)//template[@id=$ref]|collection($get:strDecorData)//template[@name=$ref]
      let $searchEffectiveDate :=
          if (matches($flexibility,'^\d{4}')) then (
              $flexibility
          ) else (
              string(max($templates/xs:dateTime(@effectiveDate)))
          )
      let $displayName         := ($templates[@effectiveDate=$searchEffectiveDate]/@displayName)[1]
      return
      if (string-length($displayName)>0) then ($displayName) else (($templates[@effectiveDate=$searchEffectiveDate]/@name)[1])
   else ()
};

declare function local:filterDataset($concept as element(),$representingTemplate as element())  as element()* {
            let $id:=$concept/@id
            return
            if (exists($representingTemplate/concept[@ref=$id])) then
            $concept
            else(),
            for $subConcept in $concept/concept
            return
            local:filterDataset($subConcept,$representingTemplate)

};
declare function local:scenarioBasics($transaction as element()) as element() {
    let $type :=$transaction/@type
    return
        if ($type='group') then
            <transaction id="{$transaction/@id}" type="{$transaction/@type}" label="{$transaction/@label}" model="{$transaction/@model}" effectiveDate="{$transaction/@effectiveDate}" statusCode="{$transaction/@statusCode}" expirationDate="{$transaction/@expirationDate}" versionLabel="{$transaction/@versionLabel}">
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
            <transaction id="{$transaction/@id}" type="{$transaction/@type}" label="{$transaction/@label}" model="{$transaction/@model}" effectiveDate="{$transaction/@effectiveDate}" statusCode="{$transaction/@statusCode}" expirationDate="{$transaction/@expirationDate}" versionLabel="{$transaction/@versionLabel}">
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
            <representingTemplate ref="{$transaction/representingTemplate/@ref}" flexibility="{$transaction/representingTemplate/@flexibility}" templateDisplayName="{local:getTemplateDisplayName($transaction/representingTemplate/@ref,$transaction/representingTemplate/@flexibility)}" sourceDataset="{$transaction/representingTemplate/@sourceDataset}">
            {
                $transaction/representingTemplate/concept
            }
            </representingTemplate>
        </transaction>
    )
};

let $scenarioId            := request:get-parameter('id','')
let $scenarioEffectiveDate := request:get-parameter('effectiveDate','')

let $transaction := 
   if (string-length($scenarioEffectiveDate) gt 0) then
   $get:colDecorData//transaction[@id=$scenarioId][@effectiveDate=$scenarioEffectiveDate]
   else($get:colDecorData//transaction[@id=$scenarioId])

return
local:scenarioBasics($transaction)

