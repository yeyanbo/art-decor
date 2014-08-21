xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket, Santosh Chandak (santoshchandak@gmail.com)

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace hl7       = "urn:hl7-org:v3";

(: 
    This function updates the existing transaction,
    ignoring the concept having absent atrribute 
:)

declare function local:writeTransaction($transaction as element()) as element()* {
(: 
Code to generate the instance id, this should be uncommented after entire integration
let $decor := $collection//transaction[@id=$transaction/@transactionRef]/ancestor::decor
let $baseId := $decor//defaultBaseId[@type='EX']/@id/string()
let $newId := concat($baseId,'.',max($decor//instance[starts-with(@id,concat($baseId,'.'))]/number(tokenize(@id,'\.')[last()]))+1)
let $transactionId := if($transaction/@instanceOrTransaction = 'transaction') then $newId else($transaction/@id) :)

let $representingTemplate := $transaction/representingTemplate
let $updatedTransaction   :=
    <transaction id="{$transaction/@id}" type="{$transaction/@type}">
    {
        if (string-length($transaction/@model) > 0) then
            $transaction/@model
        else (),
        if (string-length($transaction/@label) > 0) then
            $transaction/@label
        else (),
        if (string-length($transaction/@effectiveDate) > 0) then
            $transaction/@effectiveDate
        else (),
        if (string-length($transaction/@statusCode) > 0) then
            $transaction/@statusCode
        else (),
        if (string-length($transaction/@expirationDate) > 0) then
            $transaction/@expirationDate
        else (),
        if (string-length($transaction/@versionLabel) > 0) then
            $transaction/@versionLabel
        else (),
        for $name in $transaction/name
        return
        art:parseNode($name)
        ,
        for $desc in $transaction/desc
        return
        art:parseNode($desc)
        ,
        $transaction/actors
        ,
        <representingTemplate sourceDataset="{$representingTemplate/@sourceDataset}">
        {
            if (string-length($representingTemplate/@ref) > 0) then
                $representingTemplate/@ref
            else (),
            if (string-length($representingTemplate/@flexibility) > 0) then
                $representingTemplate/@flexibility
            else (),
            if (string-length($representingTemplate/@displayName) > 0) then
                $representingTemplate/@displayName
            else (),
            for $concept in $representingTemplate//concept[not(ancestor-or-self::concept[@absent])]
            return
            (
                comment{concat('item ',tokenize($concept/@id,'\.')[last()],' :: ',$concept/name[1])},
                if ($concept/@conformance='C') then
                    <concept ref="{$concept/@id}" conformance="{$concept/@conformance}">
                    {
                    for $condition in $concept/condition
                    return
                        if ($condition/@conformance='NP') then
                            <condition conformance="{$condition/@conformance}">
                                {normalize-space($condition/text())}
                            </condition>
                        else if ($condition/@conformance='M') then
                            <condition minimumMultiplicity="{$condition/@minimumMultiplicity}" maximumMultiplicity="{$condition/@maximumMultiplicity}" isMandatory="true">
                            {
                                normalize-space($condition/text())
                            }
                            </condition>
                        else (
                            <condition minimumMultiplicity="{$condition/@minimumMultiplicity}" maximumMultiplicity="{$condition/@maximumMultiplicity}">
                            {
                                $condition/@conformance[string-length()>0],
                                normalize-space($condition/text())
                            }
                            </condition>
                        )
                    }
                    </concept>
                else if ($concept/@conformance='M') then
                    <concept ref="{$concept/@id}" minimumMultiplicity="{$concept/@minimumMultiplicity}" maximumMultiplicity="{$concept/@maximumMultiplicity}" isMandatory="true"/>
                else if ($concept/@conformance='NP') then
                    <concept ref="{$concept/@id}" conformance="NP"/>
                else (
                    <concept ref="{$concept/@id}" minimumMultiplicity="{$concept/@minimumMultiplicity}" maximumMultiplicity="{$concept/@maximumMultiplicity}">
                    {
                        if (string-length($concept/@conformance)>0) then
                            $concept/@conformance
                        else ()
                    }
                    </concept>
                )
            )
        }
        </representingTemplate>
    }
    </transaction>

let $oldTransaction := $get:colDecorData//transaction[@id=$updatedTransaction/@id]
return
    update replace $oldTransaction with $updatedTransaction

};

let $transaction    := request:get-data()/transaction 

return
    local:writeTransaction($transaction)

