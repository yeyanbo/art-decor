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
(:
    Input: message and xpath file
    
    Output: all values in the message for each concept item with an XPath expression in xpath file 

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace hl7  = "urn:hl7-org:v3";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace lab  = "urn:oid:2.16.840.1.113883.2.4.6.10.35.81";
declare option exist:serialize "indent=no";
declare option exist:serialize "omit-xml-declaration=no";

let $account        := if (request:exists()) then request:get-parameter('account',('')) else 'rivmsp-graauw' 
let $file           := if (request:exists()) then normalize-space(request:get-parameter('file',(''))) else 'POCD_EX000002_T4.xml'
let $projectPrefix  := if (request:exists()) then request:get-parameter('prefix',('')) else 'rivmsp-'

let $decor   := collection($get:strDecorData)//project[@prefix=$projectPrefix]/ancestor::decor
let $message := doc(concat($get:strXisAccounts, '/', $account, '/messages/', $file))
(: get xpaths for representingTemplate whose id occurs in message as templateId :)
let $xpaths  := collection($get:strXisResources)//representingTemplateXpaths[@ref=$message//hl7:templateId/@root]

return 
<result>
    {
    element message {util:document-name($message)},
    element representingTemplate {$xpaths/@*,
        for $concept in $xpaths//concept[@ref]
        let $testPath := $concept/@xpath
        let $datasetConcept := $decor//dataset//concept[@id=$concept/@ref][not(ancestor::history)]
        return (
            element concept 
                {$concept/@*,
                $datasetConcept/@type,
                $datasetConcept/name,
                if ($testPath)
                then (
                    element count {util:eval(concat("count($message", $testPath, ")"))},
                        if ($datasetConcept/@type='item')
                        then
                            for $value in util:eval(concat("$message", $testPath)) 
                            return element value {attribute value {data($value)}, element xml {$value/..}}
                        else ()
                     )
                else ()
                }
            )
    }
}</result>