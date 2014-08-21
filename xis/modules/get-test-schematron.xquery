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
declare option exist:serialize "indent=no";
declare option exist:serialize "omit-xml-declaration=no";

import module namespace art      = "http://art-decor.org/ns/art" at "../../art/modules/art-decor.xqm";

let $nl := "&#10;"
let $tab := "&#9;"

(: Test name should be '*' or a named test :)
let $testName := if (request:exists()) then request:get-parameter('name','*') else '*' 
let $testcoll := collection('/db/apps/hl7/peri20-test-counseling22c/test_xslt')
for $testset in $testcoll//testset
return
    
    let $release := doc(data($testset//release/@uri)) 
    let $name := function($testConceptId) {data($release//concept[@id=$testConceptId][1]/name[1])}
    (: get tests, xpaths :)
    let $tests := if ($testName = '*') then $testset//test else $testset//test[@name=$testName]
    for $test in $tests
        let $count := count($release//@xpath)
        return
            if ($count=0) then <error>No xpaths found</error> 
            else 
                let $schematron := 
                <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
                    {$nl, comment {concat('Schematron generated ', xs:string(current-dateTime()), ', for: ', $test/@name, ', transaction: ', $test/@transactionRef, ', version: ', $testset/@version)}} 
                    <sch:ns uri="urn:hl7-org:v3" prefix="hl7"/>
                    <sch:ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
                    <sch:ns uri="urn:oid:2.16.840.1.113883.2.4.6.10.35.81" prefix="lab"/>
                    <sch:ns uri="http://www.w3.org/XML/1998/namespace" prefix="xml"/>
                    
                    <sch:pattern id="Occurs">
                        <sch:rule context="{if ($test/suppliedConcepts/@context) then $test/suppliedConcepts/@context/string() else '/'}">
                        {
                        for $testConcept in $test/suppliedConcepts/concept[@multiplicity]
                        let $xpath := 
                            if (count($release//concept[@id=$testConcept/@ref]/implementation/@xpath)=1) then
                                replace($release//concept[@id=$testConcept/@ref]/implementation/@xpath, '\[1\]', '')
                            else ()
                        return
                        if ($xpath) then 
                            (
                                let $reason := concat($name($testConcept/@ref), ' moet precies ', data($testConcept/@multiplicity), ' keer voorkomen.') 
                                return 
                                    (
                                    $nl, $tab, $tab,
                                    comment {$reason},
                                    <sch:assert role="error" test="count({concat($xpath, '[not(@negationInd="true")]', if ($testConcept/@predicate) then concat('[', data($testConcept/@predicate), ']') else '')})={data($testConcept/@multiplicity)}">
                                        {if ($testConcept/string-length()>0) then $testConcept/string() else $reason}
                                    </sch:assert>
                                    )
                            )
                            else 
                            (
                                $nl, $tab, $tab,
                                comment {concat('Restrict occurrences of ', $name($testConcept/@ref))},
                                <error>No Xpath or more than one Xpaths found for concept: {data($testConcept/@ref)}</error>
                            )
                        }
                        </sch:rule>
                    </sch:pattern>
                
                    <sch:pattern id="Values">
                        <sch:rule context="{if ($test/suppliedConcepts/@context) then $test/suppliedConcepts/@context/string() else '/'}">
                        {
                        for $testConcept in $test/suppliedConcepts/concept[@assert]
                        let $xpath := replace($release//concept[@id=$testConcept/@ref]/implementation/@xpath, '\[1\]', '')
                        return
                        if ($xpath) then 
                            (
                                let $reason := concat($name($testConcept/@ref), ' moet aan ', data($testConcept/@assert), ' voldoen.')
                                return
                                    (
                                    $nl, $tab, $tab,
                                    comment {$reason},
                                    <sch:assert role="error" test="({concat($xpath, if ($testConcept/@predicate) then concat('[', data($testConcept/@predicate), ']') else '')}){if ($testConcept/@occurrence) then concat('[', data($testConcept/@occurrence), ']') else ''}/{data($testConcept/@assert)}">
                                        {if ($testConcept/string-length()>0) then $testConcept/string() else $reason}
                                    </sch:assert>
                                    )
                            )
                            else 
                            (
                                $nl, $tab, $tab,
                                comment {concat('Restrict value of ', $name($testConcept/@ref))},
                                <error>No Xpath found for concept: {data($testConcept/@ref)}</error>
                            )
                        }
                        </sch:rule>
                    </sch:pattern>

                    <sch:pattern id="Test">
                        <sch:rule context="/">
                        {
                        for $testConcept in $test/suppliedConcepts/assert
                        return
                            (
                            $nl, $tab, $tab,
                            <sch:assert role="error">
                                {$testConcept/@test, $testConcept/string()}
                            </sch:assert>
                            )
                        }
                        </sch:rule>
                    </sch:pattern>
                </sch:schema>
            
                let $schematron-file := xmldb:store(util:collection-name($testset), concat($test/@name, '.sch'), $schematron)
                let $svrl-file       := xmldb:store(util:collection-name($testset), concat($test/@name, '.xsl'), art:get-iso-schematron-svrl($schematron))
            
                return $schematron