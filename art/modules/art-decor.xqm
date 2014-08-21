(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
xquery version "3.0";

module namespace art            = "http://art-decor.org/ns/art";
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace vs      = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";
import module namespace aduser  = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace datetime  = "http://exist-db.org/xquery/datetime";
declare namespace hl7       = "urn:hl7-org:v3";
declare namespace xhtml     = "http://www.w3.org/1999/xhtml";
declare namespace util      = "http://exist-db.org/xquery/util";
declare namespace xforms    = "http://www.w3.org/2002/xforms";

(:  Kai Heitmann, Alexander Henket, Marc de Graauw 2014
    
    Returns SVRL version of schematron
    
    Input:  schematron grammar
    Output: SVRL for schematron grammar
:)
declare function art:get-iso-schematron-svrl($grammar as item()) as element(report) {
    let $xsltParameters :=
        <parameters>
            <param name="allow-foreign" value="'true'"/>
            <param name="generate-fired-rule" value="'false'"/>
        </parameters>
    return art:get-iso-schematron-svrl($grammar, $xsltParameters)
};

(:  Kai Heitmann, Alexander Henket, Marc de Graauw 2014
    
    Returns SVRL version of schematron
    
    Input:  schematron grammar
            xsltParameters 
    Output: SVRL for schematron grammar
:)
declare function art:get-iso-schematron-svrl($grammar as item(), $xsltParameters as node()) as element(report) {
    let $isoschematrons := $get:strUtilISOSCH2SVRL
    
    let $path2schematroninclude     := concat($isoschematrons, "/iso_dsdl_include.xsl") cast as xs:anyURI
    let $path2schematronabstract    := concat($isoschematrons, "/iso_abstract_expand.xsl") cast as xs:anyURI
    let $path2schematronxsl         := concat($isoschematrons, "/iso_svrl_for_xslt2.xsl") cast as xs:anyURI
    
    let $includetransform           := transform:transform($grammar, doc($path2schematroninclude), $xsltParameters)
    let $abstracttransform          := transform:transform($includetransform, doc($path2schematronabstract), $xsltParameters) 
    let $grammartransform           := transform:transform($abstracttransform, doc($path2schematronxsl), $xsltParameters)
    
    return $grammartransform
};

(:  Alexander Henket 2013
    
    Returns a full dataset tree for either a transaction/@id or dataset/@id,
    or when called with a specific conceptId, it returns this concept and child concepts
    
    Input:  id 
            conceptId
            language, used to filter names
    Output: dataset
        - filtered for language
        - inherits resolved
        - conceptList/@ref resolved
        - no history
        - concept/valueDomain[@type='code'] are provided with conceptList/valueSet 
            with enhanced valueSet (valueSet with names from conceptList where terminologyAssociations are present)
        - concept contains implementation element with @shortName (usable as SQL, XML name) and @xpath
:)
declare function art:getPartialDatasetTree($id as xs:string, $conceptId as xs:string?, $language as xs:string?, $xpathDoc as node()?) as element() {
    let $object         := $get:colDecorData//transaction[@id=$id] | $get:colDecorData//dataset[@id=$id]
    let $isTransaction  := $object[self::transaction]
    let $project        := $object/ancestor::decor
    let $language       := if (string-length($language)=0) then $project/project/@defaultLanguage else ($language)
    let $datasetTree    := if ($isTransaction) then art:getDatasetTree('', $id) else art:getDatasetTree($id, '')
    (: only for transactions: if the xpaths are provided, insert xpath and hl7 datatype :)
    let $xpaths         := if ($xpathDoc and $isTransaction) then $xpathDoc//transactionXpaths[@ref=$id][1] else ()

    let $name := 
        if ($isTransaction) 
        then $object/name[@language=$language][1] 
        else $datasetTree/name[@language=$language][1]
    let $desc := 
        if ($isTransaction) 
        then 
            $object/desc[@language=$language][1]
        else (
            for $n in $datasetTree/desc[@language=$language][1] 
            return art:parseNode($n)
        )
    
    let $fullDatasetTree := 
        <dataset>
        {
            $datasetTree/@*, 
            attribute shortName {art:shortName($name)}, 
            $name, 
            $desc, 
            (: only children with non-absent descendants :)
            if ($conceptId) then
                for $concept in $datasetTree//concept[@id=$conceptId][descendant-or-self::concept[not(@absent='true')]]
                return art:getFullConcept($project, $concept, $language, $xpaths, '')
            else
                for $concept in $datasetTree/concept[descendant-or-self::concept[not(@absent='true')]]
                return art:getFullConcept($project, $concept, $language, $xpaths, '')
        }
        </dataset>

    return $fullDatasetTree
};

(:  Marc de Graauw, Alexander Henket 2013
    
    Returns a full dataset tree for either a transaction/@id or dataset/@id
    
    Input:  id 
            language, used to filter names
    Output: dataset
        - filtered for language
        - inherits resolved
        - conceptList/@ref resolved
        - no history
        - concept/valueDomain[@type='code'] are provided with conceptList/valueSet 
            with enhanced valueSet (valueSet with names from conceptList where terminologyAssociations are present)
        - concept contains implementation element with @shortName (usable as SQL, XML name) and @xpath
:)
declare function art:getFullDatasetTree($id as xs:string, $language as xs:string?, $xpathDoc as node()?) as element() {
    art:getPartialDatasetTree($id, (), $language, $xpathDoc)
};

(: art:getFullDatasetTree with signature without xpaths :)
declare function art:getFullDatasetTree($id as xs:string, $language as xs:string?) as element() {
    art:getFullDatasetTree($id, $language, ())
};

(:  Marc de Graauw, Alexander Henket 2013
    
    Returns a full concept for getFullDatasetTree 
    Input:  id 
            language, used to filter names
    Output: full concept, see description of getFullDatasetTree
:)
declare function art:getFullConcept($project as node(), $concept as node(), $language as xs:string, $xpaths as node()?, $parentXpath as xs:string?) as node() {
    let $fullConcept   := 
        if ($concept/inherit) then (
            (art:getOriginalConcept($concept/inherit)//concept)[1]
        ) else (
            $project//concept[@id=$concept/@id][@effectiveDate=$concept/@effectiveDate][not(ancestor::history)]
        )
    let $shortName     := art:shortName($fullConcept/name[@language=$language][1])
    
    (: Calculate the right xpath expression for this concept :)
    (: A single row in xpaths will look like:
    <concept ref="..." effectiveDate="..." elementId="..." xpath="/hl7:ClinicalDocument... etc..." valueLocation="@extension" hl7Type="II"/>
    :)
    (: Find the elements in xpaths which contain a concept corresponding to concept/@id :) 
    (: If no xpaths file is available (it's a dataset, xpaths not generated yet, no xpath for this concept (usually no corresponding elementId in templateAssociation)), then empty :) 
    let $xpathRows := if ($xpaths) then ($xpaths//concept[@ref=$concept/@id]/../..) else ()

    (: Try to find the Xpath :)
    let $xpathRow :=
        (: If there's only one xpath for this concept, that's the one :)
        if (count($xpathRows) = 1) 
        then $xpathRows[1]
        
        (: If there's more than one, see if we have (exactly) one which starts with our parent's xpath, and pick that one :)
        else if (count($xpathRows) > 1)
        then 
            if (empty($parentXpath)) 
            then <concept message="Warning: More than one xpath for concept, but no xpath for parent."/> 
            else if (count($xpathRows[starts-with(@xpath, $parentXpath)]) = 1) 
            then $xpathRows[starts-with(@xpath, $parentXpath)][1]
            (: If there is more than one xpath for a concept, and the parent's xpath is not the first part of one of those, then this warning will be hit :)
            else <concept message="Warning: More than one xpath, unable to calculate"/>
        
        (: This should never be hit :)
        else (
            (:<concept message="Warning: Unable to calculate xpath."/>:)
        )

    return 
        <concept>
        {
            (: attributes from concept except @type from fullConcept :)
            $concept/(@* except @type)[not(.='')], 
            $fullConcept/@type,
            <implementation>
            {
                if ($shortName) then attribute shortName {$shortName} else (), 
                attribute hl7Type {$xpathRow/@datatype},
                $xpathRow/@xpath,
                $xpathRow/@valueLocation,
                $xpathRow/@message,
                element templateLocation {$xpathRow/ancestor::template[1]/@*}
            }
            </implementation>
            ,
            (: element children, not concept &amp; history children, filtered for language :)
            $concept/condition,
            $concept/inherit,
            $fullConcept/name[@language=$language][1],
            $fullConcept/synonym[@language=$language],
            $fullConcept/desc[@language=$language][1],
            $fullConcept/source[@language=$language][1],
            $fullConcept/rationale[@language=$language][1],
            $fullConcept/comment[@language=$language],
            $fullConcept/operationalization[@language=$language][1],
            for $valueDomain in $fullConcept/valueDomain
            let $conceptLists :=
                for $conceptList in $valueDomain/conceptList
                return
                    if ($conceptList[@ref]) then (
                        ($project//conceptList[@id=$conceptList/@ref][not(ancestor::history)])[1]
                    ) else (
                        $conceptList
                    )
            return (
                <valueDomain>
                {
                    $valueDomain/@*,
                    for $conceptList in $conceptLists
                    return
                        <conceptList>
                        {
                            $conceptList/@*,
                            for $conceptListItem in $conceptList/concept 
                            return (
                                <concept>
                                {
                                    $conceptListItem/@*,
                                    $conceptListItem/name[@language=$language][1],
                                    $conceptListItem/synonym[@language=$language],
                                    $conceptListItem/desc[@language=$language][1]
                                }
                                </concept>
                            )
                        }
                        </conceptList>
                    ,
                    $valueDomain/* except $valueDomain/conceptList
                }
                </valueDomain>
                ,
                (: add enhanced valueSet :)
                for $conceptList in $conceptLists
                return art:getEnhancedValueSet($project, $conceptList, $language)
            )
            ,
            $project//terminologyAssociation[@conceptId=($concept/@id|$concept/inherit/@ref)]
            , 
            for $conceptChild in $concept/concept[descendant-or-self::concept[not(@absent='true')]]
            return art:getFullConcept($project, $conceptChild, $language, $xpaths, if ($xpathRow/@xpath) then data($xpathRow/@xpath) else ())
        }
        </concept>
};

(:  Marc de Graauw 2013, Alexander Henket 2014
    Returns a name which (in most cases) should be acceptable as XML element or SQL column name
    Most common diacritics are replaced
    
    Input:  xs:string, example: "Underscored Lowercase ë"
    Output: xs:string, example: "underscored_lowercase_e"
:)
declare function art:shortName($name as xs:string?) as xs:string? {
    let $shortname := 
        if ($name) then (
            (: find matching alternatives for more or less common diacriticals, replace single spaces with _ :)
            let $r1 := translate(normalize-space(lower-case($name)),' àáãäåèéêëìíîïòóôõöùúûüýÿç€ßñ','_aaaaaeeeeiiiiooooouuuuuyycEsn')
            (: ditch anything that's not alpha numerical or underscore :)
            let $r2 := replace($r1,'[^a-zA-Z\d_]','')
            (: make sure we do not start with a digit :)
            let $r3 := if (matches($r2,'^\d')) then concat('_',$r2) else $r2
            return $r3
        ) else ()
    
    return if (matches($shortname, '^[a-zA-Z_][a-zA-Z\d_]+$')) then $shortname else ()
};

(:  Marc de Graauw, Alexander Henket 2013
    
    Returns an enhanced valueSet for a conceptList
    Input:  collection (take care to send more than project if conceptList/@ref points outside project)
            conceptList (from a dataset/concept/valueDomain)
            language, used to filter names, may be '' for no filtering
    Output: 
        valueSet with attributes from valueSet:
            <valueSet id="2.16.840.1.113883.2.4.3.46.99.3.11.5" effectiveDate="2012-07-25T15:22:56" name="tfw-meting-door" displayName="tfw-meting-door" statusCode="draft">
        conceptList with id from concept:
                <conceptList id="2.16.840.1.113883.2.4.3.46.99.3.2.55.0">
        all concepts from valueSet, 
        if a terminologyAssociation for concept exists, name from dataset, filtered by language if $language is not ''
                    <concept localId="1" code="P" codeSystem="2.16.840.1.113883.2.4.3.46.99.50" displayName="displayName-from-valueset" level="0" type="L">
                        <name language="nl-NL">Name from dataset conceptList's concept</name>
                    </concept>
        if no terminologyAssociation for concept exists, <name> is taken from @displayName in valueSet
                    <exception localId="6" code="OTH" codeSystem="2.16.840.1.113883.5.1008" displayName="Anders" level="0" type="L">
                        <name>Anders</name>
                    </exception>
                </conceptList>
            </valueSet>
        if no terminologyAssociation for valueSet exists, returns empty valueSet/conceptList:
            <valueSet><conceptList id="2.16.840.1.113883.2.4.3.46.99.3.2.55.0"/></valueSet>
        localId is a unique number within this particular conceptList (since code without codeSystem may not be unique) for use in code generators
        localId is only guaranteed to be unique within a single call, may change after dataset changes
:)
declare function art:getEnhancedValueSet($project as node(), $conceptList as element(), $language as xs:string) as element()* {
    let $conceptList            := 
        if ($conceptList/@ref)
        then $project//conceptList[@id=$conceptList/@ref][not(ancestor::history)][ancestor::decor/project/@prefix=$conceptList/ancestor::decor/project/@prefix]
        else $conceptList
    let $conceptListAssociation := $project//terminologyAssociation[@conceptId=$conceptList/@id]
    let $enhancedValueSet       :=  
        if ($conceptListAssociation) then (
            for $association in $conceptListAssociation
            let $valueSet := (vs:getExpandedValueSetByRef($association/@valueSet, $association/@flexibility, $project//project/@prefix)//valueSet[@id])[1]
            return
            <valueSet>
            {
                $valueSet/@*, 
                $association,
                $valueSet/completeCodeSystem,
                <conceptList id="{$conceptList/@id}">{
                    for $concept at $pos in $valueSet/conceptList/*
                    let $conceptAssociation := $project//terminologyAssociation[@conceptId=$conceptList/concept/@id][@code=$concept/@code][@codeSystem=$concept/@codeSystem]
                    return 
                        if ($conceptAssociation) then (
                            element {name($concept)} {
                                attribute localId {$pos},
                                $concept/@*, 
                                if ($language = '') then (
                                    $conceptList/concept[@id=$conceptAssociation/@conceptId]/*
                                )
                                else (
                                    let $conceptName    := $conceptList/concept[@id=$conceptAssociation/@conceptId]/name[@language=$language]
                                    return  if ($conceptName) then $conceptName else <name language="{$language}">{$concept/@displayName/string()}</name>
                                    ,
                                    $concept/desc[@language=$language]
                                )
                            }
                        )
                        else (
                            element {name($concept)} {attribute localId {$pos}, $concept/@*, <name>{data($concept/@displayName)}</name>}
                        )
                }</conceptList>
            }
            </valueSet>
        )
        else (
            (: concept list is not related to a valueSet :)
            <valueSet><conceptList id="{$conceptList/@id}"/></valueSet>
        )
    return $enhancedValueSet
};

(: Get the minimumMultiplicity from conditions, or zero if none :)
declare function art:getMinimumMultiplicity($concept as element()) as xs:string {
    let $minimumMultiplicity := 
        (:if ($concept/@conformance='NP')
        then ''
        else :)
        if ($concept/@minimumMultiplicity) 
        then $concept/@minimumMultiplicity
        else if ($concept/condition[@conformance="NP"]) 
        then '0' 
        else if ($concept/condition/@minimumMultiplicity) 
        then min($concept/condition/@minimumMultiplicity)
        else '0'
    return xs:string($minimumMultiplicity)
};

(: Get the maximumMultiplicity from conditions, or * if none :)
declare function art:getMaximumMultiplicity($concept as element()) as xs:string {
    let $maximumMultiplicity := 
        (:if ($concept/@conformance='NP')
        then ''
        else :)
        if ($concept/@maximumMultiplicity) 
        then $concept/@maximumMultiplicity
        else if ($concept/condition/@maximumMultiplicity) 
        then if ($concept/condition[@maximumMultiplicity='*']) then '*' else max($concept/condition/@maximumMultiplicity)
        else ('*')
    return xs:string($maximumMultiplicity)
};

(: serialize textWithMarkup for display in xforms:)
declare function art:serializeNode($textWithMarkup as element()) as element() {
    let $nodeName := name($textWithMarkup)
    return
    element {$nodeName} {
        $textWithMarkup/@*,
        util:serialize($textWithMarkup/node(),'method=xhtml encoding=UTF-8')
    }
};

(: parse serialized content to html for storage :)
declare function art:parseNode($textWithMarkup as element()?) as element() {
let $parsed-html := 
    if (exists($textWithMarkup)) then ( 
        element {name($textWithMarkup)} {
            $textWithMarkup/@*,
            util:parse-html($textWithMarkup)//xhtml:body/text()|util:parse-html($textWithMarkup)//BODY/node()
        }
    )
    else ()
return $parsed-html
};

(: serialize the desc elements submitted, if any language is missing, add a hint that it is available in other languages :)
(: support for multi language description, adds hint that desc is avaiable in other languages upon missing desc in the respective lanuage
   
   lanuage support so far for 
   de-DE, de-AT
   en-US
   nl-NL
    
   Needs still some more improvements (i.e. list of supported languages etc)
    
:)
declare function art:serializeDescriptionNodes($textWithMarkup as element()*) as element()* {
    let $art-languages  := art:getArtLanguages()
    let $placeholders   :=
        <r>
        {
            for $elm in art:getFormResourcesKey('art', $art-languages, 'no-desc-available')
            return
                <desc language="{$elm/@xml:lang}">{$elm/node()}</desc>
        }
        </r>
    let $y :=
        if (count($textWithMarkup)>0) then
            <result>
            {
                for $lang in $placeholders/desc/@language
                return
                element {$textWithMarkup[1]/name()} {
                    attribute language {$lang},
                    $textWithMarkup[@language=$lang]/(@* except @language),
                    if ($textWithMarkup[@language=$lang]) then
                        util:serialize ($textWithMarkup[@language=$lang]/node(), 'method=xhtml encoding=UTF-8')
                    else 
                        util:serialize (<font color='grey'><i>{$lang/../node()}</i>
                        {if (not($lang='en-US') and $textWithMarkup[@language='en-US']) then (<br/>,'en-US: ', $textWithMarkup[@language='en-US']/node()) else ()}</font>, 'method=xhtml encoding=UTF-8')
                }
            }
            {
                (:don't loose stuff just because it is not in the desired set...:)
                $textWithMarkup[not(@language=$placeholders/desc/@language)]
            }
            </result>
        else ()
        
    return $y
};

(: get a name for an OID, e.g. "SNOMED-CT" for 2.16.840.1.113883.6.96
    - First check the OID Registry Lookup file
    - Then check any DECOR defined ids in repositories, or specific to a project
    - Then check any DECOR defined codeSystems in repositories, or specific to the project
    - If no name could be found, return empty string
    
    params:
    @oid - optional. The OID to get the display name for
    @language - required. The language to get the name in
    @projectPrefix - optional. The prefix of the project. Falls back to 'all' projects marked as repository 
:)
declare function art:getNameForOID($oid as xs:string?,$language as xs:string,$projectPrefix as xs:string?) as xs:string {
let $language       := if (string-length($language)>0) then $language else ('en-US')
let $return         :=
    if (empty($oid)) then ('') else (
        try {
            let $registryOids   := $get:colOidsData//@oid[.=$oid][ancestor::oidList]
            
            return
            if (exists($registryOids)) then 
                if ($registryOids/../name[@language=$language]) then
                    ($registryOids/../name[@language=$language])[1]
                else (
                    ($registryOids/../name)[1]
                )
            else (
                let $projectOids    := $get:colDecorData//ids//@root[.=$oid][ancestor::decor/project/@prefix=$projectPrefix or ancestor::decor/@repository='true']
                
                return
                if (exists($projectOids)) then
                    if ($projectOids/../designation[@language=$language]) then
                        ($projectOids/../designation[@language=$language]/@displayName)[1]
                    else (
                        ($projectOids/../designation[1]/@displayName)[1]
                    )
                else (
                    (:let $idParts        := tokenize($oid,'\.')
                    let $idBase         := string-join($idParts[position()!=last()],'.')
                    let $idExt          := $idParts[last()]:)
                    (:let $idBase         := string-join(tokenize($oid,'\.')[position()!=last()],'.'):)
                    let $idBase         := replace($oid,'(.*)\.[^\.]+$','$1')
                    let $idExt          := tokenize($oid,'\.')[last()]
                    let $idBaseName     := ($get:colDecorData//ids//@id[.=$idBase]/../@prefix)[1]
                    return
                        if ($idBaseName) then 
                            concat($idBaseName,$idExt)
                        else ()
                )
            )
        }
        catch * {()}
    )
return if ($return) then $return else ('')
};

(: **** Dataset functions **** :)

(:
retrieve inherit hierarchy for decor concept
input: inherit element of decor concept
returns: hierarchie of inherit elements containing decor comment elements and the original concept
:)
declare function art:getOriginalConcept($inherit as element()) as element() {
    let $concept :=
        if ($inherit/@effectiveDate) then
            $get:colDecorData//concept[@id=$inherit/@ref][@effectiveDate=$inherit/@effectiveDate][not(ancestor::history)]
        else(
            $get:colDecorData//concept[@id=$inherit/@ref][@statusCode='final'][not(ancestor::history)]
        )
    
    return
        if ($concept/inherit) then
            <inherit prefix="{$concept/ancestor::decor/project/@prefix}" datasetId="{$concept/ancestor::dataset[1]/@id}">
            {
                $concept/comment,
                art:getOriginalConcept($concept/inherit)
            }
            </inherit>
        else (
            <inherit prefix="{$concept/ancestor::decor/project/@prefix}" datasetId="{$concept/ancestor::dataset[1]/@id}">
                {$concept}
            </inherit>
        )
};

(:
:   equivalent to getOriginalConcept, but returns name and desc of original concept only and without inherit hierarchy
:)
declare function art:getOriginalConceptName($inherit as element()) as element() {
let $concept := 
    if ($inherit/@effectiveDate) then
        $get:colDecorData//concept[@id=$inherit/@ref][@effectiveDate=$inherit/@effectiveDate][not(ancestor::history)]
    else (
        $get:colDecorData//concept[@id=$inherit/@ref][@statusCode='final'][not(ancestor::history)]
    )

return
    if ($concept/inherit) then
        art:getOriginalConceptName($concept/inherit)
    else (
        <concept id="{$inherit/@ref}" effectiveDate="{$inherit/@effectiveDate}">
        {
            $concept/name,
            $concept/desc
        }
        </concept>
    )
};

(:~
:   Return the original conceptList. If input has @id, return input. If input has @ref, find original with @id
:)
declare function art:getOriginalConceptList($conceptList as element(conceptList)?) as element(conceptList)? {
    if (empty($conceptList)) then (
        (:nothing...:)
    ) else if ($conceptList[@id]) then (
        (:input is original, return it:)
        $conceptList
    ) else (
        let $projectPrefix := 
            if ($conceptList/ancestor::decor) then 
                $conceptList/ancestor::decor/project/@prefix
            else (
                (:when called through getOriginalConcept the prefix is on a parent inherit element:)
                $conceptList/ancestor::inherit/@prefix
            )
        (:get original from same project:)
        let $originalConceptList := ($get:colDecorData//datasets//conceptList[@id=$conceptList/@ref][not(ancestor::history)][ancestor::decor/project/@prefix=$projectPrefix])[1]
        return
            if (empty($originalConceptList)) then (
                (:could not find original, just return reference:)
                $conceptList
            ) else (
                (:got original, return it:)
                $originalConceptList
            )
    )
};

(:
   Recursive function for retrieving the basic concept info for a concept hierarchy.
   Used for creating dataset navigation.
:)
declare function art:conceptBasics($concept as element()) as element() {
   let $id :=$concept/@id
   let $conceptInfo := 
      if ($concept/inherit) then
         let $inheritedConcept := art:getOriginalConcept($concept/inherit)
         let $originalConcept := $inheritedConcept//concept[not(ancestor::history)][not(ancestor::conceptList)][parent::inherit]
         return
         <concept id="{$id}" type="{$originalConcept/@type}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}" versionLabel="{$concept/@versionLabel}" expirationDate="{$concept/@expirationDate}" officialReleaseDate="{$concept/@officialReleaseDate}">
         {
            $concept/(@* except (@id|@type|@statusCode|@effectiveDate|@versionLabel|@expirationDate|@officialReleaseDate)),
            $concept/inherit,
            $originalConcept/name,
            for $c in $concept/concept
            return
            art:conceptBasics($c)
         }
         </concept>
      else
      (
         <concept id="{$id}" type="{$concept/@type}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}" versionLabel="{$concept/@versionLabel}" expirationDate="{$concept/@expirationDate}" officialReleaseDate="{$concept/@officialReleaseDate}">
         {
            $concept/(@* except (@id|@type|@statusCode|@effectiveDate|@versionLabel|@expirationDate|@officialReleaseDate)),
            $concept/name,
            for $c in $concept/concept
            return
            art:conceptBasics($c)
         }
         </concept>
      )
   return
   $conceptInfo
};

(:
:   Return id from input if it leads to an original concept. Recurse to return id of the original concept based on inherit
:)
declare function art:getOriginalConceptId($id as xs:string) as xs:string {
    let $concept := $get:colDecorData//concept[@id=$id][not(ancestor::history)]
    return
        if ($concept/inherit) then
            art:getOriginalConceptId($concept/inherit/@ref)
        else ($concept/@id)
};

(:
   Function for retrieving list of terminology associations for concept and contained conceptList/concept
:)
declare function art:getConceptAssociations ($conceptId as xs:string) as element(associations) {
let $concept            := $get:colDecorData//dataset//concept[@id=$conceptId][not(ancestor::history)][1]
let $decor              := $concept/ancestor::decor
let $projectTerminology := $decor/terminology
let $projectLanguage    := data($decor/project/@defaultLanguage)
let $language           := if (request:exists()) then request:get-parameter('language', $projectLanguage ) else ($projectLanguage)

let $originalConcept    :=
    if ($concept/inherit) then
        $get:colDecorData//dataset//concept[@id=art:getOriginalConceptId($concept/inherit/@ref)][not(ancestor::history)]
    else ($concept)
let $conceptLists       :=
    for $conceptList in $originalConcept/valueDomain/conceptList
    return art:getOriginalConceptList($conceptList)

(:let $associations       := $get:colDecorData//terminologyAssociation[@conceptId=($originalConcept/@id,$conceptListId)]:)
let $associations       := $projectTerminology//terminologyAssociation[@conceptId=($concept/@id|$originalConcept/@id|$conceptLists//@id)]

return
<associations>
{
    for $association in $associations
    let $codeSystemName := 
        if (string-length($association/@codeSystem)>0) then
            try {
                let $nm := art:getNameForOID($association/@codeSystem,$language,$decor/project/@prefix)
                return
                if (string-length($nm)>0) then $nm else ($association/@codeSystem)
            }
            catch * {
                <description>ERROR {$err:code} : {$err:description, "', module: ",
                $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</description>
            }
        else ()
      
    (:let $codeSystemName := $association/@codeSystemName:)
    let $valueSetName   :=
        if (string-length($association/@valueSet)>0) then
            if (matches($association/@valueSet,'[^\d\.]')) then (
                $association/@valueSet
            ) else if (matches($association/@flexibility,'^\d{4}')) then (
                ($projectTerminology/valueSet[@ref=$association/@valueSet]/@name | $projectTerminology/valueSet[@id=$association/@valueSet][@effectiveDate=$association/@flexibility]/@name)[1]
            ) else (
                ($projectTerminology/valueSet[@ref=$association/@valueSet]/@name | $projectTerminology/valueSet[@id=$association/@valueSet][@effectiveDate=string(max($projectTerminology/valueSet[@id=$association/@valueSet]/xs:dateTime(@effectiveDate)))]/@name)[1]
            )
        else ()
    return
    <association>
    {
        $association/(@*[not(.='')] except (@codeSystemName|@valueSetName)),
        if ($association/@codeSystem) then attribute codeSystemName {$codeSystemName} else (),
        if ($association/@valueSet) then attribute valueSetName {$valueSetName} else ()
    }
    </association>
}
</associations>
};

(:
   Recursive function for retrieving the basic concept info for a concept hierarchy in the context of a representingTemplate.
   Adds @absent='true' to concepts not in representingTemplate.
   Used for creating dataset navigation and  by transaction editor
:)
declare function art:transactionConceptBasics($concept as element(), $representingTemplate as element()) as element() {
   let $id                  := $concept/@id
   let $matchingConcept     := $representingTemplate/concept[@ref=$id]
   let $minimumMultiplicity := if($matchingConcept) then art:getMinimumMultiplicity($matchingConcept) else('0')
   let $maximumMultiplicity := if($matchingConcept) then art:getMaximumMultiplicity($matchingConcept) else('*')
   let $conformance         := if($matchingConcept) then $matchingConcept/@conformance else('')
   let $isMandatory         := if($matchingConcept/@isMandatory) then $matchingConcept/@isMandatory else('false')
   let $conditions          := 
      for $cond in $matchingConcept/condition
      return
      <condition minimumMultiplicity="{$cond/@minimumMultiplicity}" maximumMultiplicity="{$cond/@maximumMultiplicity}" conformance="{if ($cond/@isMandatory='true') then 'M' else($cond/@conformance)}" isMandatory="{$cond/@isMandatory}">
      {$cond/text()}
      </condition>

   let $conceptInfo := 
      if ($concept/inherit) then
         let $inheritedConcept := art:getOriginalConcept($concept/inherit)
         let $originalConcept := $inheritedConcept//concept[not(ancestor::history)][not(ancestor::conceptList)][parent::inherit]
         return
         <concept type="{$originalConcept/@type}" minimumMultiplicity="{$minimumMultiplicity}" maximumMultiplicity="{$maximumMultiplicity}" conformance="{if ($isMandatory='true') then 'M' else ($conformance)}" isMandatory="{$isMandatory}">
         {
            $concept/@* except $concept/@type,
            if ($matchingConcept) then () else (
                attribute absent {'true'}
            ),
            $concept/inherit,
            $originalConcept/name,
            $conditions,
            for $c in $concept/concept
            return
            art:transactionConceptBasics($c, $representingTemplate)
         }
         </concept>
      else (
         <concept minimumMultiplicity="{$minimumMultiplicity}" maximumMultiplicity="{$maximumMultiplicity}" conformance="{if ($isMandatory='true') then 'M' else($conformance)}" isMandatory="{$isMandatory}">
         {
            $concept/@*,
            if ($matchingConcept) then () else (
                attribute absent {'true'}
            ),
            $concept/name,
            $conditions,
            for $c in $concept/concept
            return
            art:transactionConceptBasics($c, $representingTemplate)
         }
         </concept>
      )
   return
   $conceptInfo
};

(: FIXME: does not work for valueSet/@ref. Need rewrite to (taken from RetrieveValueSet)
    let $valueSetList := vs:getValueSetList((),(),(),$projectPrefix)
    
    for $valueSet in $valueSetList/repository[not(@url)][@ident=$projectPrefix]/valueSet
    return
        vs:getExpandedValueSetById($valueSet/(@id|@ref),$valueSet/@effectiveDate,$projectPrefix)
:)
declare function art:currentValuesets($decor as node()) as element()*{
(: returns a sequence with the current valuesets for a particular decor node :)
for $name in distinct-values($decor//valueSet/@name)
return $decor//valueSet[@name=$name][@effectiveDate=max($decor//valueSet[@name=$name]/xs:dateTime(@effectiveDate))]
};

(: Remove superfluous elements and attributes and parse textWithMarkup nodes :)
declare function art:cleanConceptItem($concept as element()) as element() {
    let $id :=$concept/@id
    return
    <concept id="{$id}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}">
    {
        if (string-length($concept/@type)>0) then
            $concept/@type
        else()
        ,
        if (string-length($concept/@versionLabel)>0) then
            $concept/@versionLabel
        else()
        ,
        if (string-length($concept/@expirationDate)>0) then
            $concept/@expirationDate
        else()
        ,
        $concept/inherit,
        for $name in $concept/name
        return
        art:parseNode($name)
        ,
        for $desc in $concept/desc
        return
        art:parseNode($desc)
        ,
        for $source in $concept/source
        return
        art:parseNode($source)
        ,
        for $rationale in $concept/rationale
        return
        art:parseNode($rationale)
        ,
        for $comment in$concept/comment
        return
        art:parseNode($comment)
        ,
        for $operationalization in $concept/operationalization
        return
        art:parseNode($operationalization)
        ,
        $concept/valueDomain
    }
    </concept>
};

declare function art:removeConceptItemHistory($concept as element()) as element() {
    let $id :=$concept/@id
    return
    <concept id="{$id}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}">
    {
        if (string-length($concept/@type)>0) then
            $concept/@type
        else()
        ,
        if (string-length($concept/@versionLabel)>0) then
            $concept/@versionLabel
        else()
        ,
        if (string-length($concept/@expirationDate)>0) then
            $concept/@expirationDate
        else()
        ,
        $concept/inherit,
        $concept/name,
        $concept/desc,
        $concept/source,
        $concept/rationale,
        $concept/comment,
        $concept/operationalization,
        $concept/valueDomain
    }
    </concept>
};
(: used by save-decor-dataset.xquery :)
declare function art:prepareItemForUpdate($concept as element(),$storedItem as element()) as element() {
let $status := if ($concept/@statusCode='new') then
                     'draft'
                  else($concept/@statusCode)
let $history := 
      <history validTimeHigh="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}">
      {
      art:removeConceptItemHistory($storedItem)
      }
      </history>
 
return
    <concept id="{$concept/@id}" statusCode="{$status}" effectiveDate="{$concept/@effectiveDate}">
    {
        if ($concept/inherit) then () else (
           $concept/@type
        )
        ,
        if ($concept/@versionLabel[string-length()>0]) then
           $concept/@versionLabel
        else()
        ,
        if ($concept/@expirationDate[string-length()>0]) then
           $concept/@expirationDate
        else()
        ,
        (:skip extra attributes that get-concept-for-edit adds. for loop saves an if statement:)
        for $inherit in $concept/inherit
        return <inherit>{$inherit/(@ref|@effectiveDate)}</inherit>
        ,
        if ($concept/inherit) then
            for $comment in $concept/comment[string-length(.)>0]
            return
            art:parseNode($comment)
        else (
            for $name in $concept/name
            return
            art:parseNode($name)
            ,
            for $desc in $concept/desc
            return
            art:parseNode($desc)
            ,
            for $source in $concept/source[string-length(.)>0]
            return
            art:parseNode($source)
            ,
            for $rationale in $concept/rationale[string-length(.)>0]
            return
            art:parseNode($rationale)
            ,
            for $comment in$concept/comment[string-length(.)>0]
            return
            art:parseNode($comment)
            ,
            for $operationalization in $concept/operationalization[string-length(.)>0]
            return
            art:parseNode($operationalization)
            ,
            for $valueDomain in $concept/valueDomain
            return
            <valueDomain type="{$valueDomain/@type}">
            {
                if ($valueDomain/@type='code') then
                    for $conceptList in $valueDomain/conceptList
                    return
                    <conceptList>
                    {
                        $conceptList/(@id|@ref),
                        for $conceptListConcept in $conceptList/concept
                        return
                        <concept>
                        {
                            $conceptListConcept/@*,
                            $conceptListConcept/name,
                            $conceptListConcept/desc
                        }
                        </concept>
                    }
                    </conceptList>
                else(),
                for $property in $valueDomain/property[@*[string-length(.)>0]]
                return
                <property>
                {
                    if ($valueDomain/@type=('count','decimal')) then (
                        $property/@minInclude[string-length(.)>0],
                        $property/@maxInclude[string-length(.)>0],
                        $property/@default[string-length(.)>0],
                        $property/@fixed[string-length(.)>0]
                    )
                    else if ($valueDomain/@type=('duration','quantity')) then (
                        $property/@unit[string-length(.)>0],
                        $property/@minInclude[string-length(.)>0],
                        $property/@maxInclude[string-length(.)>0],
                        $property/@fractionDigits[string-length(.)>0],
                        $property/@default[string-length(.)>0],
                        $property/@fixed[string-length(.)>0]
                    )
                    else if ($valueDomain/@type=('date','datetime')) then (
                        $property/@timeStampPrecision[string-length(.)>0],
                        $property/@default[string-length(.)>0],
                        $property/@fixed[string-length(.)>0]
                    )
                    else if ($valueDomain/@type=('code','score','ordinal','boolean')) then (
                        $property/@default[string-length(.)>0],
                        $property/@fixed[string-length(.)>0]
                    )
                    else if ($valueDomain/@type=('string','text','identifier')) then (
                        $property/@default[string-length(.)>0],
                        $property/@fixed[string-length(.)>0],
                        $property/@minLength[string-length(.)>0],
                        $property/@maxLength[string-length(.)>0]
                    ) 
                    else()
                }
                </property>
                ,
                for $example in $valueDomain/example[string-length(.)>0]
                return
                   <example>
                   {
                       $example/@*[string-length()>0],
                       $example/node()
                   }
                   </example>
            }
            </valueDomain>
        )
        ,
        if ($concept/@statusCode!='new' and $concept/edit/@mode='edit') then
        $history
        else()
        ,
        $storedItem/history
   }
   </concept>
};

declare function art:prepareConceptForStore($concept as element()) as element() {
    let $id :=$concept/@id
    
    return
    <concept id="{$id}" effectiveDate="{$concept/@effectiveDate}">
    {
        if (string-length($concept/@type)>0) then
            $concept/@type
        else()
        ,
        if (string-length($concept/@statusCode)>0) then
            $concept/@statusCode
        else()
        ,
        if (string-length($concept/@versionLabel)>0) then
            $concept/@versionLabel
        else()
        ,
        if (string-length($concept/@expirationDate)>0) then
            $concept/@expirationDate
        else()
        ,
        $concept/inherit,
        for $name in $concept/name
        return
        art:parseNode($name)
        ,
        for $desc in $concept/desc
        return
        art:parseNode($desc)
        ,
        for $source in $concept/source
        return
        art:parseNode($source)
        ,
        for $rationale in $concept/rationale
        return
        art:parseNode($rationale)
        ,
        for $comment in$concept/comment
        return
        art:parseNode($comment)
        ,
        for $operationalization in $concept/operationalization
        return
        art:parseNode($operationalization)
        ,
        $concept/valueDomain
    }
    </concept>
};

(: used by save-decor-dataset.xquery :)
declare function art:prepareGroupForUpdate($concept as element(),$storedGroup as element()) as element() {
let $status := 
    if ($concept/@statusCode='new') then
        'draft'
    else ($concept/@statusCode)
let $id :=$concept/@id
let $history := 
    <history validTimeHigh="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}">
    {
        art:removeGroupContent($storedGroup)
    }
    </history>

return
    <concept id="{$id}" statusCode="{$status}" effectiveDate="{$concept/@effectiveDate}">
    {
        if ($concept/inherit) then () else (
            $concept/@type
        )
        ,
        if ($concept/@versionLabel[string-length()>0]) then
            $concept/@versionLabel
        else()
        ,
        if ($concept/@expirationDate[string-length()>0]) then
            $concept/@expirationDate
        else()
        ,
        (:skip extra attributes that get-concept-for-edit adds. for loop saves an if statement:)
        for $inherit in $concept/inherit
        return <inherit>{$inherit/(@ref|@effectiveDate)}</inherit>
        ,
        if ($concept/inherit) then
            for $comment in $concept/comment[string-length(.)>0]
            return
            art:parseNode($comment)
        else (
            for $name in $concept/name
            return
            art:parseNode($name)
            ,
            for $desc in $concept/desc
            return
            art:parseNode($desc)
            ,
            for $source in $concept/source[string-length(.)>0]
            return
            art:parseNode($source)
            ,
            for $rationale in $concept/rationale[string-length(.)>0]
            return
            art:parseNode($rationale)
            ,
            for $comment in$concept/comment[string-length(.)>0]
            return
            art:parseNode($comment)
            ,
            for $operationalization in $concept/operationalization[string-length(.)>0]
            return
            art:parseNode($operationalization)
        )
        ,
        $storedGroup/concept
        ,
        if ($concept/@statusCode!='new' and $concept/edit/@mode='edit') then
            $history
        else()
        ,
        $storedGroup/history
    }
    </concept>
};

declare function art:removeGroupContent($concept as element()) as element() {

<concept id="{$concept/@id}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}">
{
    if (string-length($concept/@type)>0) then
        $concept/@type
    else()
    ,
    if (string-length($concept/@versionLabel)>0) then
        $concept/@versionLabel
    else()
    ,
    if (string-length($concept/@expirationDate)>0) then
        $concept/@expirationDate
    else()
    ,
    for $element in $concept/(* except (concept|history))
    return
    $element
}
{
    for $element in $concept/concept
    return
    <concept id="{$element/@id}" statusCode="{$element/@statusCode}" effectiveDate="{$element/@effectiveDate}"/>
}
</concept>
};

(:
   Xquery function for retrieving the concept tree of a dataset for navigation purposes.
   Requires either:
   - id of a dataset.
   - transactionId of a transaction containing a representingTemplate
   Returns the concept hierarchy for the dataset, 
   inherits are resolved to retrieve the name of the concept.
   Providing a transactionId will return the cardinalities and conformance of the concept
   and an attribute absent='true' on concepts not in the representingTemplate
:)
declare function art:getDatasetTree($datasetId as xs:string, $transactionId as xs:string) as element() { 
    let $representingTemplate :=
        if ($transactionId != '') then
            $get:colDecorData//transaction[@id=$transactionId]/representingTemplate
        else ()
    
    let $dataset := 
        if ($representingTemplate) then
            $get:colDecorData//dataset[@id=$representingTemplate/@sourceDataset]
        else ($get:colDecorData//dataset[@id=$datasetId])
    
    let $statusCode := 
        if ($dataset/@statusCode) then (
            $dataset/@statusCode
        )
        else (
            if (count($dataset//concept[@statusCode='draft'])=0 and count($dataset//concept[@statusCode='new'])=0) then
                'final'
            else ('draft')
        )
    
    return
    <dataset id="{$dataset/@id}" effectiveDate="{$dataset/@effectiveDate}" statusCode="{$statusCode}" versionLabel="{$dataset/@versionLabel}">
    {
        if ($representingTemplate) then (
            attribute {'transactionId'} {$transactionId}, 
            attribute {'transactionEffectiveDate'} {$get:colDecorData//transaction[@id=$transactionId]/@effectiveDate}
        ) else ()
    }
    {
        for $name in $dataset/name
        return
            art:serializeNode($name)
        ,
        for $desc in $dataset/desc
        return
            art:serializeNode($desc)
        ,
        for $concept in $dataset/concept
        return
            if ($representingTemplate) then
                art:transactionConceptBasics($concept,$representingTemplate)
            else (art:conceptBasics($concept))
    }
    </dataset>
};

(: get Decor Types from DECOR.xsd:)
declare function art:getLabelsAndHints($type as element()) as element()* {
let $art-languages  := art:getArtLanguages()
return (
    for $label in $type/xs:annotation/xs:appinfo/xforms:label
    return
    <label language="{$label/@xml:lang}">{$label/text()}</label>
    ,
    (:add any missing language as copy from en-US:)
    if ($type/xs:annotation/xs:appinfo/xforms:label) then (
        for $lang in $art-languages[not(.=$type/xs:annotation/xs:appinfo/xforms:label/@xml:lang)]
        return
        <label language="{$lang}">{$type/xs:annotation/xs:appinfo/xforms:label[@xml:lang='en-US']/text()}</label>
    ) else ()
    ,
    for $hint in $type/xs:annotation/xs:appinfo/xforms:hint
    return
    <hint language="{$hint/@xml:lang}">{$hint/text()}</hint>
    ,
    (:add any missing language as copy from en-US:)
    if ($type/xs:annotation/xs:appinfo/xforms:hint) then (
        for $lang in $art-languages[not(.=$type/xs:annotation/xs:appinfo/xforms:hint/@xml:lang)]
        return
        <hint language="{$lang}">{$type/xs:annotation/xs:appinfo/xforms:hint[@xml:lang='en-US']/text()}</hint>
    ) else ()
)
};

(:~ Called from all DECOR oriented forms :)
declare function art:getDecorTypes() as element()* {
    art:getDecorTypes(false())
};

(:~ Called from DECOR-core post-install.xql with parameter true() to recreate the normalized xml file from a potentially updated DECOR.xsd file :)
declare function art:getDecorTypes($recreate as xs:boolean) as element()* {
    if ($recreate or not(doc-available($get:strDecorTypes))) then (
        let $types      := $get:docDecorSchema/xs:schema/xs:element|$get:docDecorSchema/xs:schema/xs:complexType|$get:docDecorSchema/xs:schema/xs:simpleType
        let $decorTypes := 
            <decorTypes>
            {
                for $type in $types
                return
                    element {$type/@name} {
                        art:getLabelsAndHints($type),
                        for $element in $type//xs:element
                        return
                        <element name="{$element/@name}" ref="{$element/@ref}">
                        {
                            art:getLabelsAndHints($element)
                        }
                        </element>
                        ,
                        for $attribute in $type//xs:attribute
                        return
                        <attribute name="{$attribute/@name}" ref="{$attribute/@ref}">
                        {
                            art:getLabelsAndHints($attribute)
                        }
                        </attribute>
                        ,
                        for $enumeration in $type//xs:enumeration
                        return
                        <enumeration value="{$enumeration/@value}">
                        {
                            art:getLabelsAndHints($enumeration)
                        }
                        </enumeration>
                    }
            }
            </decorTypes>
        
        (:don't store if we cannot write:)
        let $f          := tokenize($get:strDecorTypes,'/')[last()]
        let $upd        := 
            if (doc-available($get:strDecorTypes)) then
                if (sm:has-access(xs:anyURI(concat($get:strArtData,'/',$f)),'w')) then
                    xmldb:store($get:strArtData,$f,$decorTypes)
                else ()
            else if (sm:has-access(xs:anyURI($get:strArtData),'w')) then
                xmldb:store($get:strArtData,$f,$decorTypes)
            else ()
        
        return $decorTypes
    ) else (
        doc($get:strDecorTypes)/decorTypes
    )
};

(:
:   Return artXformResources from the requested package by calling "package"/resources/form-resources.xml
:   Contents are sorted alphabetically
:
:   <artXformResources packageRoot="$package">
:       <resources xml:lang="en-US" displayName="English (en-US)">
:           <key>value</key>
:           ...
:       </resources>
:       <resources xml:lang="nl-NL" displayName="Nederlands (nl-NL)">
:           <key>value</key>
:           ...
:       </resources>
:       <resources xml:lang="de-DE" displayName="Deutsch (de-DE)">
:           <key>value</key>
:           ...
:       </resources>
:   </artXformResources>
:)
declare function art:getFormResources($packageRoot as xs:string?) as element(artXformResources) {
let $packageRoot    := if ($packageRoot) then $packageRoot else 'art'
let $formResources  := doc(concat($get:root,$packageRoot,'/resources/form-resources.xml'))/artXformResources

return
    <artXformResources packageRoot="{$packageRoot}">
    {
        for $resources in $formResources/resources
        return
        <resources xml:lang="{$resources/@xml:lang}" displayName="{$resources/@displayName}">
        {
            for $key in $resources/*
            order by lower-case(name($key))
            return
                $key
        }
        </resources>
    }
    </artXformResources>
};

(:
:   Return artXformResources from the requested package by calling "package"/resources/form-resources.xml
:   and in the requested language. Contents are sorted alphabetically
:   If the parameter language is empty, then try to get from the user settings and if all else fails go 
:   to server setting.
:   Other languages in the form-resources.xml are returned empty to signal that they are available.
:
:   <artXformResources packageRoot="$package">
:       <resources xml:lang="en-US" displayName="English (en-US)">
:           <key>value</key>
:           ...
:       </resources>
:       <resources xml:lang="nl-NL" displayName="Nederlands (nl-NL)"/>
:       <resources xml:lang="de-DE" displayName="Deutsch (de-DE)"/>
:   </artXformResources>
:)
declare function art:getFormResources($packageRoot as xs:string?, $language as xs:string?) as element(artXformResources) {
let $packageRoot    := if ($packageRoot) then $packageRoot else 'art'
let $formResources  := doc(concat($get:root,$packageRoot,'/resources/form-resources.xml'))/artXformResources

(:getUserLanguage gets user language if defined, or falls back onto server language. If the user is not logged in, the user is guest:)
let $language       := if (empty($language)) then (aduser:getUserLanguage()) else ($language)

return
    <artXformResources packageRoot="{$packageRoot}">
    {
        (:make requested language the first:)
        for $resources in $formResources/resources[@xml:lang=$language]
        return
            <resources xml:lang="{$resources/@xml:lang}" displayName="{$resources/@displayName}">
            {
                for $key in $resources/*
                order by lower-case(name($key))
                return
                    $key
            }
            </resources>
    }
    {
        (:and add any other available languages as empty elements. ART can then make the user choose from available languages:)
        for $resources in $formResources/resources[not(@xml:lang=$language)]
        return
            <resources xml:lang="{$resources/@xml:lang}" displayName="{$resources/@displayName}"/>
    }
    </artXformResources>
};

(:
:   Return form key/value pairs from the requested package by calling "package"/resources/form-resources.xml
:   and in the requested language(s).
:   If the parameter language is empty, then try to get from the user settings and if all else fails go 
:   to server setting.
:
:       <key xml:lang="en-US">value</key>
:       <key xml:lang="nl-NL">value</key>
:)
declare function art:getFormResourcesKey($packageRoot as xs:string?, $language as xs:string*, $key as xs:string) as element()* {
let $packageRoot    := if ($packageRoot) then $packageRoot else 'art'
(:getUserLanguage gets user language if defined, or falls back onto server language. If the user is not logged in, the user is guest:)
let $language       := if (empty($language)) then (aduser:getUserLanguage()) else ($language)

let $formResources  := doc(concat($get:root,$packageRoot,'/resources/form-resources.xml'))/artXformResources/resources[@xml:lang=$language]

for $element in $formResources/*[name()=$key]
return
    element {$key} {$element/../@xml:lang, $element/node()}
};

(:
:   Return language supported in ART by returning all @xml:lang attributes in the art/resources/form-resources.xml
:   Example: ('en-US','nl-NL','de-DE')
:)
declare function art:getArtLanguages() as xs:string+ {
let $packageRoot    := $get:strArt
let $formResources  := doc(concat($packageRoot,'/resources/form-resources.xml'))/artXformResources

return
    $formResources/resources/@xml:lang
};