xquery version "3.0";
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
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";

let $nl := "&#10;"
let $tab := "&#9;"

let $resourcesPath := if (request:exists()) then request:get-parameter('resourcesPath','') else '/db/apps/hl7/rivmsp-20140425T120709'
let $testset := collection(concat($resourcesPath, '/test_xslt'))/testset

let $html := 
    <html>
        <head>
            <title>{$testset/@name/string()}</title>
            <meta charset="UTF-8"></meta>
        </head>
        <body>
            <h1>{$testset/@name/string()}</h1>
            {
                for $test in $testset/test
                return
                <div>
                    <h2>{$test/name}</h2>
                    <p>{$test/desc}</p>
                    <h3>Multiplicities</h3>
                    <ol>
                    {
                        for $testConcept in $test/suppliedConcepts/concept[@multiplicity]
                        return <li>{if ($testConcept/string-length()>0) then $testConcept/string() else 'No description.'}</li>
                    }
                    </ol>
                    <h3>Assertions</h3>
                    <ol>
                    {
                        for $testConcept in $test/suppliedConcepts/concept[@assert]
                        return <li>{if ($testConcept/string-length()>0) then $testConcept/string() else 'No description.'}</li>
                    }
                    </ol>
                    <h3>Schematron</h3>
                    <ol>
                    {
                        for $testConcept in $test/suppliedConcepts/assert
                        return <li>{if ($testConcept/string-length()>0) then $testConcept/string() else 'No description.'}</li>
                    }
                    </ol>
                </div>
            }
        </body>
    </html>
return $html