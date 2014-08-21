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

declare function local:prepareTransaction($transaction as element()) as element() {
    let $type :=$transaction/@type
    let $concepts := $get:colDecorData//concept
    return
        if ($type='group') then
            <transaction>
            {
                $transaction/@*[string-length()>0]
                ,
                for $name in $transaction/name
                return
                art:parseNode($name)
                ,
                for $desc in $transaction/desc
                return
                art:parseNode($desc)
                ,
                 for $trigger in $transaction/trigger
                return
                art:parseNode($trigger)
                ,
                for $condition in $transaction/condition
                return
                art:parseNode($condition)
                ,
                for $dependencies in $transaction/dependencies
                return
                art:parseNode($dependencies)
                ,
                for $t in $transaction/transaction
                return
                local:prepareTransaction($t)
            }
            </transaction>
        else (
            <transaction>
            {
                $transaction/@*[string-length()>0]
                ,
                for $name in $transaction/name
                return
                art:parseNode($name)
                ,
                for $desc in $transaction/desc
                return
                art:parseNode($desc)
                ,
                for $trigger in $transaction/trigger
                return
                art:parseNode($trigger)
                ,
                for $condition in $transaction/condition
                return
                art:parseNode($condition)
                ,
                for $dependencies in $transaction/dependencies
                return
                art:parseNode($dependencies)
            }
                <actors>
                {
                    for $actor in $transaction/actors/actor
                    return
                        <actor id="{$actor/@id}" role="{$actor/@role}"/>
                }
                </actors>
                {
                    if ($transaction/representingTemplate/(@ref|@flexibility|@sourceDataset)[string-length()>0]|$transaction/representingTemplate/(concept|comment())) then (
                        <representingTemplate>
                        {
                            (:KH/AH 2013-02-21 @displayName is deprecated, so don't save that... Just save known valid attributes:)
                            $transaction/representingTemplate/(@ref|@flexibility|@sourceDataset)[string-length()>0],
                            $transaction/representingTemplate/(concept|comment())
                        }
                        </representingTemplate>
                    ) else ()
                }
            </transaction>
        )
};

declare function local:prepareScenario($scenario as element()) as element() {
<scenario>
{
    $scenario/@*[string-length()>0]
    ,
    for $name in $scenario/name
    return
    art:parseNode($name)
    ,
    for $desc in $scenario/desc
    return
    art:parseNode($desc)
    ,
    for $trigger in $scenario/trigger
    return
    art:parseNode($trigger)
    ,
    for $condition in $scenario/condition
    return
    art:parseNode($condition)
    ,
    for $transaction in $scenario/transaction
    return
    local:prepareTransaction($transaction)
}
</scenario>
};

let $post   := request:get-data()/scenarios
let $decor  := $get:colDecorData//decor[project/@prefix=$post/@projectPrefix]

let $update :=
    if (not($decor/scenarios)) then 
        update insert <scenarios/> preceding $decor/ids 
    else()

let $update :=
    for $scenario in $post/scenario
    let $storedScenario := $decor//scenario[@id=$scenario/@id]
    return
        if ($scenario/edit/@mode='edit') then
            if ($storedScenario) then
                update replace $storedScenario with local:prepareScenario($scenario)
            else (
                if (exists($decor//scenarios/scenario)) then
                    update insert local:prepareScenario($scenario) following $decor/scenarios/scenario[count($decor/scenarios/scenario)]
                else (
                    update insert local:prepareScenario($scenario) into $decor/scenarios
                )
            )
   else ()

let $statusUpdate:= update value $decor//(scenario|transaction)[@statusCode='new']/@statusCode with 'draft'

return
<scenarios/>
