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
          for $t in $transaction/transaction
          return
              local:scenarioBasics($t)
      }
      </transaction>
   else 
   (
      <transaction id="{$transaction/@id}" type="{$transaction/@type}" label="{$transaction/@label}" model="{$transaction/@model}" effectiveDate="{$transaction/@effectiveDate}" statusCode="{$transaction/@statusCode}" expirationDate="{$transaction/@expirationDate}" versionLabel="{$transaction/@versionLabel}">
         {
             for $name in $transaction/name
             return
                 art:serializeNode($name)
      
         }
         <actors>
         {
             for $actor in $transaction/actors/actor
             return
             <actor id="{$actor/@id}" role="{$actor/@role}"/>
         }
         </actors>
      </transaction>
   )
};

let $project        := request:get-parameter('project','')
(:let $project      := 'demo1-':)
let $decorScenarios := $get:colDecorData//decor[project/@prefix=$project]//scenarios

return
<scenarios projectPrefix="{$project}">
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
             for $transaction in $scenario/transaction
             return
                 local:scenarioBasics($transaction)
         }
         </scenario>
    }
</scenarios>
