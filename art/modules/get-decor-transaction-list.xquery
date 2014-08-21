xquery version "1.0";
(:
    Copyright (C) 2014-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "xmldb:exist:///db/apps/art/modules/art-decor-settings.xqm";

declare function local:getName($object as element(),$filter as element()*) as element()* {
    for $name in $object/name
    let $label := 
        if ($object/../@versionLabel) 
        then concat(' (',$object/../@versionLabel,')') 
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
                normalize-space(concat($name/text(), $label))
                (:if (count($filter/name[concat(.,../@versionLabel)=concat($name,$name/../@versionLabel)][@language=$name/@language])>1) then (
                    concat($name, $label,' :: ', datetime:format-dateTime(xs:dateTime($object/@effectiveDate),"yyyy-MM-dd'T'HH:mm:ss"))
                ) else (
                    concat($name, $label)
                ):)
            }
            ,
            normalize-space($name/text())
        }
        </name>
};

declare function local:doTransaction($transaction as element(), $filter as element()*) as element()? {
    let $statusCode := 
        if ($transaction/@statusCode) then
            $transaction/@statusCode
        else (
            if (not($transaction/ancestor::*[@statusCode=('draft','new')])) then
                'final'
            else (
                'draft'
            )
        )
     return
        <transaction id="{$transaction/@id}" effectiveDate="{$transaction/@effectiveDate}" statusCode="{$statusCode}" type="{$transaction/@type}">
        {
            local:getName($transaction, $filter)
            (:,
            $transaction/desc:)
            ,
            for $child in $transaction/transaction[.//@id=$filter/@id]
            return local:doTransaction($child,$filter)
        }
        </transaction>
};

let $project        := if (request:exists()) then request:get-parameter('project',()) else ('peri20-')
(: 
    all     = all transactions
    ds      = only transactions that have a representingTemplate/@sourceDataset
    tm      = only transactions that have a representingTemplate/@ref
    group   = only transactions of type group (transactions that group other transactions)
    item    = only transactions of type item (transactions that are stationary, initial or back)
:)
let $type           := if (request:exists()) then request:get-parameter('type','all') else ('ds')
let $scenarios      := $get:colDecorData//decor[project/@prefix=$project]/scenarios/scenario
let $transactions   := 
    if ($type='all') then
        $scenarios//transaction
    else if ($type='ds') then
        $scenarios//transaction[representingTemplate[concept]/@sourceDataset]
    else if ($type='tm') then
        $scenarios//transaction[representingTemplate[concept]/@ref]
    else if ($type='group') then
        $scenarios//transaction[@type='group']
    else if ($type='item') then
        $scenarios//transaction[not(@type='group')]
    else ()

let $projectId      := $get:colDecorData//decor/project[@prefix=$project]/@id

return
<transactions projectId="{$projectId}">
{
    for $scenario in $scenarios[.//transaction/@id=$transactions/@id]
    order by lower-case($scenario/name[1])
    return
        <scenario id="{$scenario/@id}" effectiveDate="{$scenario/@effectiveDate}" statusCode="{$scenario/@statusCode}">
        {
            local:getName($scenario, $scenarios)
            (:,
            $scenario/desc:)
            ,
            for $transaction in $scenario/transaction[.//@id=$transactions/@id]
            return local:doTransaction($transaction,$transactions)
        }
        </scenario>
}
</transactions>
