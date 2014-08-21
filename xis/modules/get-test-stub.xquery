xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

let $nl := "&#10;"
let $tab := "&#9;"

let $lang       := 'nl-NL'
let $version    := '2014-04-16T16:02:11'
let $id         := '2.16.840.1.113883.2.4.3.11.60.90.77.4.2404'
let $uri        := concat('http://decor.nictiz.nl/decor/services/RetrieveTransaction?id=', $id, '&amp;language=', $lang, '&amp;version=', $version, '&amp;format=xml')
let $transaction := doc($uri)

let $tests :=
<testset name="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://art-decor.org/ADAR/rv/DECOR-tests.xsd">
    <release uri="{$uri}"/>
    {
    if ($transaction = () ) then <error>no xpaths found</error> else 
        <test name="{concat($transaction/dataset/@shortName, '_test')}" transactionRef="{$transaction/dataset/@transactionId}">
            <name language="nl-NL">?</name>
            <desc language="nl-NL">?</desc>
            <suppliedConcepts>{$nl, comment{'Add @context if context is not root.'}, $nl}
            <!-- Restrictions on multiplicities -->
            {(for $concept in $transaction//concept[implementation/@xpath] return                 
                <concept multiplicity="1" ref="{$concept/@id}">{concat($concept/name[1], ' moet 1 keer voorkomen.')}</concept>
            ),
            <!-- Restrictions on values -->,
            (for $concept in $transaction//concept[implementation/@xpath][@type='item'] return                 
                <concept occurrence="1" assert="{$concept/implementation/@valueLocation}='?'" ref="{$concept/@id}">{concat($concept/name[1], ' moet "?" zijn.')}</concept>
            )}
            </suppliedConcepts>
        </test>
}</testset>

return $tests