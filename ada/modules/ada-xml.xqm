(:
    Copyright (C) 2013-2014  Marc de Graauw
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
xquery version "3.0";
(:~
:Common ADA functions for processing ADA XML format. The ADA XML format is (XML not rendered well by xqdoc):
:<adaxml>
:  <meta status="{status}">
:    <step>
:    Zero or more steps
:    </step>
:  </meta>
:  <data>
:    The actual data, conforming to a schema in ada-data/projects/{project}/schemas
:  </data>
:  Zero or more translations data, i.e. CDA, SOAP etc.
:</adaxml>
:
:ADA XML is processed in steps. Each step corresponds to an ADA XML step-function, i.e.
:step 'validate-schema' corresponds to adaxml:validateSchema(...)
:The output of step-functions should be a step element, made with adaxml:makeStep(...)
:Adding a step to an ADA XML doc with adaxml:addStep(...) inserts the step into the ADA XML document and
:updates the meta/@status of the ADA XML document.
:
:@author Marc de Graauw
:@version 0.1
:)
module namespace adaxml = "http://art-decor.org/ns/ada-xml";
declare namespace validation = "http://exist-db.org/xquery/validation";

(:~
:Removes empty values from adaxml/data
:
:@param $elements Sequence of elements from which empty values will be removed.
:@return The sequence of elements from input, with missing attributes
:)
declare function adaxml:removeEmptyValues($elements as element()*) as element()* {
    for $element in $elements
    let $newNode := 
        element {name($element)} {
            if ($element/*) then (
                (: all attributes, process element children :)
                $element/@*,
                for $child in $element/*
                return adaxml:removeEmptyValues($child)
                )
            else 
                (:only conceptId for empty concepts, all for non-empty concepts:)
                if ($element/@value='') then ($element/@conceptId) else ($element/@*)
            }
     return $newNode
};

(:~
:Adds missing @value and @unit atributes to adaxml/data
:
:@param $elements Sequence of elements to which attributes will be added (and to child nodes as well)
:@param $nexXml Elements which contains an empty XML instance with all attributes
:@return The sequence of elements from input, with missing attributes
:)
declare function adaxml:addAttributes($elements as element()*, $newXml as node()) as element()* {
    for $element in $elements
    let $newElement := element {name($element)} {
        if ($element/*) then (
            $element/@*,
            for $child in $element/* return adaxml:addAttributes($child, $newXml)
            )
        else
            if (not($element/@value)) then ($element/@*[not(local-name()='value' or local-name()='unit')], $newXml//*[@conceptId=$element/@conceptId]/@value, $newXml//*[@conceptId=$element/@conceptId]/@unit) else ($element/@*)
        }
    return $newElement
};

(:~
:Removes conceptId from all nodes recursively
:
:@param $elements Sequence of elements to which conceptId will be added (and to child nodes as well)
:@return The sequence of elements from input, with conceptId removed
:)
declare function adaxml:removeConceptId($elements as element()*) as element()* {
    for $element in $elements
    let $newel := 
        element {name($element)} 
        {$element/(@* except @conceptId), for $child in $element/* return adaxml:removeConceptId($child)}
    return $newel
};

(:~
:Adds conceptId to all concept nodes recursively
:
:@param $elements Sequence of elements to which conceptId will be added (and to child nodes as well)
:@param $spec A single enhanced dataset for a particular transaction, usually from a specific {project}-{version}-ada-release.xml
:@return The sequence of elements from input, with conceptId
:)
declare function adaxml:addConceptId($elements as element()*, $spec as element()*) as element()* {
    for $element in $elements
    let $conceptId := $spec[implementation/@shortName=local-name($element)]/@id
    let $newel := 
        element {
            name($element)} {$element/(@* except @conceptId), 
            if ($conceptId) then attribute conceptId {data($conceptId)} else (),
            for $child in $element/* return adaxml:addConceptId($child, $spec/*)
            }
    return $newel
};

(:~
: Adds code, codeSystem, displayname to coded concepts
:
:@param $elements Sequence of elements to which code etc. will be added (and to child nodes as well)
:@param $spec A single enhanced dataset for a particular transaction, usually from a specific {project}-{version}-ada-release.xml
:@return The sequence of elements from input, with code etc.
:)
declare function adaxml:addCode($elements as element()*, $spec as element()*) as element()* {
    for $element in $elements
    let $codedConcept := $spec[implementation/@shortName=local-name($element)]/valueSet/conceptList/concept[@localId=$element/@value]
    let $newel := 
        element {
            name($element)} {$element/(@* except (@code|@codeSystem|@displayName)), 
            if ($codedConcept) then $codedConcept/(@code|@codeSystem|@displayName) else (),
            for $child in $element/* return adaxml:addCode($child, $spec/*)
            }
    return $newel
};

(:~
: Adds localId when @code is provided but @value is omitted
:
:@param $elements Sequence of elements to which conceptId will be added (and to child nodes as well)
:@param $spec A single enhanced dataset for a particular transaction, usually from a specific {project}-{version}-ada-release.xml
:@return The sequence of elements from input, with localId
:)
declare function adaxml:addLocalId($elements as element()*, $spec as element()*) as element()* {
    for $element in $elements
    let $conceptSpec := $spec[@id=$element/@conceptId]
    let $localId := $conceptSpec/valueSet/conceptList/concept[@code=$element/@code]/@localId
    let $newel := 
        element {name($element)} 
            {$element/@*,
            if ($element/@code and not($element/@value)) 
            then 
                if (count($localId)>1) then attribute error {concat('More than one code found for code ', $element/@code, ' ,concept ', $element/@conceptId)} else attribute value {$localId}
            else (),  
            for $child in $element/* return adaxml:addLocalId($child, $spec/*)
            }
    return $newel
};

(:~
: Adds a step element to adaxml/meta
:
:@param $doc ADA XML document
:@param $step A step element 
:@param $trace Optional boolean, if true saves tracing info
:@return true()
:)
declare function adaxml:addStep($doc as node(), $step as element(), $trace-data as xs:boolean?){
    let $step := 
        element step {
            $step/@*, 
            attribute status-before {$doc/adaxml/meta/@status}, 
            $step/*, 
            if ($trace-data) then element data-before {$doc/data} else ()
        }
    let $update := update insert $step into $doc/adaxml/meta
    let $update := update replace $doc/adaxml/meta/@status with $step/@status-after
    return $update
};

(:~
: Makes a step element for adaxml/meta
:
:@param $status New status of ADA XML document
:@param $action Text of undertaken action 
:@param $contents Optional element containing content to be inserted in step element
:@return step element 
:)
declare function adaxml:makeStep($status as xs:string, $action as xs:string, $contents as element()?){
    let $step := 
        <step status-after="{$status}" action="{$action}" time="{fn:current-dateTime()}">
            {$contents}
        </step>
    return $step
};

(:~
:Validate a data in an ADA XML document with a schema. Tests for existence of document and schema. 
:Sets @status to 'valid' or 'invalid'.
:
:@param $docUri URI string
:@param $schemaUri URI string
:@return step element
:)
declare function adaxml:validateSchema($docUri as xs:string, $schemaUri as xs:string) as node() {
    let $doc := adaxml:getDocument($docUri)
    let $schema := adaxml:getDocument($schemaUri)
    let $result := validation:jaxv-report($doc/adaxml/data/*, $schema)
    let $step := 
        if ($result//exception) 
        then adaxml:makeStep('error', 'validate-schema', $result)
        else adaxml:makeStep($result/status, 'validate-schema', $result)
    return $step
};

(:~
: Apply a stylesheet to a document. Tests for existence of document and stylesheet, 
: will raise error.
:
:@param $docUri URI string
:@param $stylesheetUri URI string
:@return converted data
:)
declare function adaxml:applyStylesheet($docUri as xs:string, $stylesheetUri as xs:string) as node()*{
    let $doc := adaxml:getDocument($docUri)
    let $stylesheet:= adaxml:getDocument($stylesheetUri)
    return transform:transform($doc, $stylesheet, ())
};

(:~
:Convert data to HL7, add HL7 to ADA XML document.
:
:@param $docUri URI string
:@param $stylesheetUri URI string
:@return step element
:)
declare function adaxml:addHL7Data($docUri as xs:string, $stylesheetUri as xs:string) as node()*{
    let $result := 
        try {
            adaxml:applyStylesheet($docUri, $stylesheetUri)
        }
        catch * {
            <exception type="stylesheet" role="error" xslt="{$stylesheetUri}">
                <description>ERROR {$err:code} in transform: {$err:description, "', module: ", $err:module}</description>
                <location line="{$err:line-number}" column="{$err:column-number}"/>
            </exception>
        }
    let $update := 
        if ($result//exception) 
        then () 
        else (
            update delete doc($docUri)/adaxml/hl7data,
            update insert element hl7data {$result} into doc($docUri)/adaxml
            )
    let $step := 
        if ($result//exception) 
        then adaxml:makeStep('error', 'apply-stylesheet', $result)
        else adaxml:makeStep('hl7data-added', 'apply-stylesheet', ())
    return $step
};

(:~
: Safe version of doc($uri), raises a 'DocNotAvailable' error when doc not available instead of 
: returning empty sequence. To be used when document must exist.
:
:@param $uri URI string
:@return document node
:)
declare function adaxml:getDocument($uri as xs:string) as node(){
    let $doc := 
        if (doc-available($uri)) then 
            doc($uri) 
        else (error(QName('http://art-decor.org/ns/error', 'DocNotAvailable'), concat('Document not available: ', $uri))
    )
    return $doc
};