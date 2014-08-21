xquery version "3.0";
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

(:
   Xquery for retrieving template for editing
   Input:
   - template/@id
   - template/@effectiveDate
   - languageCode
   
:)
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace vs      = "http://art-decor.org/ns/decor/valueset" at "../api/api-decor-valueset.xqm";
import module namespace templ   = "http://art-decor.org/ns/decor/template" at "../api/api-decor-template.xqm";
declare namespace httpclient    = "http://exist-db.org/xquery/httpclient";

(: keep it simple for performance. if the requested valueSet is in the project terminology by ref, don't look further :)
declare function local:isValueSetInScope($projectPrefix as xs:string, $ref as attribute()?,$flexibility as attribute()?,$valueSetList as element()*) as attribute()? {
    if (string-length($ref)=0) then ()
    else (
        let $vsElms := $valueSetList[(@id|@name|@ref)=$ref]
        let $vsEff  := if (matches($flexibility,'^\d{4}')) then $flexibility else (string(max($vsElms[@effectiveDate]/xs:dateTime(@effectiveDate))))
       
        return
            if ($vsElms[@ref] or $vsElms[@effectiveDate=$vsEff]) then () else (attribute linkedartefactmissing {'true'})
    )
};

(: keep it simple for performance. if the requested template is in the project rules by ref, don't look further :)
declare function local:isTemplateInScope($projectPrefix as xs:string, $ref as attribute()?,$flexibility as attribute()?,$templateList as element()*) as attribute()* {
    if (string-length($ref)=0) then ()
    else (
        let $templates  := (templ:getTemplateByRef($ref,if (matches($flexibility,'^\d{4}')) then $flexibility else 'dynamic',$projectPrefix)/*/template[@id])[1]
        
        return
            if ($templates) then (
                attribute tmid {$templates/@id},
                attribute tmdisplayName {if ($templates/@displayName) then $templates/@displayName else $templates/@name}
            ) else (
                attribute linkedartefactmissing {'true'}
            )
    )
};

declare function local:getDatatype($datatype as xs:string?, $classification-format as xs:string?) as xs:string? {
    let $classification-format  := if (empty($classification-format)) then 'hl7v3xml1' else $classification-format
    let $datatypes              := $get:colDecorCore//supportedDataTypes[@type=$classification-format]
    let $datatype               := if (contains($datatype,':')) then substring-after($datatype,':') else ($datatype)
    let $flavor                 := $datatypes//flavor[@name=$datatype]
    return
        if ($flavor) then ($flavor/ancestor::dataType[1]/@name) else ($datatype)
};

declare function local:recurseItemForEdit($projectPrefix as xs:string, $item as element(),$language as xs:string,$valueSetList as element()*,$templateList as element()*,$selected as xs:boolean) as element()* {
if ($item/name()='attribute') then
    for $att in templ:normalizeAttributes($item)
    return
        <attribute>
        {
            $att/@name,
            $att/@value,
            if ($att[not(@prohibited='true')]) then
                if ($att[@isOptional='true']) then 
                    attribute isOptional {'true'}
                else
                    attribute isOptional {'false'}
            else (
                attribute prohibited {'true'}
            )
            ,
            $att/@datatype
            ,
            if ($att/@datatype) then
                attribute originalType {local:getDatatype($att/@datatype,$item/ancestor::template/classification/@format)}
            else()
            ,
            attribute originalOpt {'true'}
            ,
            attribute conf {if ($att/@isOptional='true') then 'isOptional' else if ($att/@prohibited='true') then 'prohibited' else ''},
            if ($selected) then (attribute selected {''}) else ()
            ,
            for $desc in $att/desc
            return
            art:serializeNode($desc)
            ,
            for $subitem in $att/*[name()!='desc']
            return
                if ($subitem[name()!='vocabulary']) then
                    $subitem
                else (
                    <vocabulary>
                    {
                        $subitem/@*[not(name()='linkedartefactmissing')],
                        local:isValueSetInScope($projectPrefix, $subitem/@valueSet,$subitem/@flexibility,$valueSetList),
                        $subitem/*
                    }
                    </vocabulary>
                )
        }
        </attribute>
else if ($item/name()='element') then
    <element>
    {
        $item/(@* except (@tmid|@tmname|@tmdisplayName|@linkedartefactmissing)),
        local:isTemplateInScope($projectPrefix, $item/@contains,$item/@flexibility,$templateList)
        ,
        if ($item/@datatype) then
            attribute originalType {local:getDatatype($item/@datatype,$item/ancestor::template/classification/@format)}
        else()
        ,
        if (not($item/@minimumMultiplicity)) then
            attribute minimumMultiplicity {'0'}
        else()
        ,
        if (not($item/@maximumMultiplicity)) then
            attribute maximumMultiplicity {'*'}
        else()
        ,
        attribute originalMin {'0'}
        ,
        attribute originalMax {'*'}
        ,
        if (not($item/@conformance)) then
            let $conformance := if ($item/@minimumMultiplicity='1') then 'R' else('O')
            return
            attribute conformance {$conformance}
        else()
        ,
        if (not($item/@isMandatory)) then
            attribute isMandatory {'false'}
        else()
        ,
        if ($selected) then (attribute selected {''}) else ()
        ,
        for $desc in $item/desc
        return
        art:serializeNode($desc)
        ,
        for $vocabulary in $item/vocabulary
        return
            <vocabulary>
            {
                $vocabulary/@*[not(name()='linkedartefactmissing')],
                local:isValueSetInScope($projectPrefix, $vocabulary/@valueSet,$vocabulary/@flexibility,$valueSetList),
                $vocabulary/*
            }
            </vocabulary>
        ,
        $item/property,
        $item/item,
        $item/text,
        for $example in $item/example
        return
        <example type="{$example/@type}" caption="{$example/@caption}">
        {
            for $exampleElement in $example/node()
            return
            util:serialize($exampleElement,'method=xml encoding=UTF-8')
        }
        </example>
        ,
        for $subItem in $item/(attribute|element|choice|include|let|defineVariable|assert|report|constraint)
        return
        local:recurseItemForEdit($projectPrefix, $subItem,$language,$valueSetList,$templateList,$selected)
    }
    </element>
else if ($item/name()='choice') then
    <choice>
    {
        $item/@*,
        if (not($item/@minimumMultiplicity)) then
            attribute minimumMultiplicity {'0'}
        else()
        ,
        if (not($item/@maximumMultiplicity)) then
            attribute maximumMultiplicity {'*'}
        else()
        ,
        attribute originalMin {'0'}
        ,
        attribute originalMax {'*'}
        ,
        if (not($item/@conformance)) then
            let $conformance := if ($item/@minimumMultiplicity='1') then 'R' else('O')
            return
            attribute conformance {$conformance}
        else()
        ,
        if (not($item/@isMandatory)) then
            attribute isMandatory {'false'}
        else()
        ,
        if ($selected) then (attribute selected {''}) else ()
        ,
        for $desc in $item/desc
        return
        art:serializeNode($desc)
        ,
        $item/item,
        for $subItem in $item/*[name()=('element','include','constraint')]
        return
        local:recurseItemForEdit($projectPrefix, $subItem,$language,$valueSetList,$templateList,$selected)
    }
    </choice>
else if ($item/name()='include') then
    <include>
    {
        $item/(@* except (@tmid|@tmname|@tmdisplayName|@linkedartefactmissing)),
        local:isTemplateInScope($projectPrefix, $item/@ref,$item/@flexibility,$templateList)
        ,
        if (not($item/@minimumMultiplicity)) then
            attribute minimumMultiplicity {'0'}
        else()
        ,
        if (not($item/@maximumMultiplicity)) then
            attribute maximumMultiplicity {'*'}
        else()
        ,
        attribute originalMin {'0'}
        ,
        attribute originalMax {'*'}
        ,
        if (not($item/@conformance)) then
            let $conformance := if ($item/@minimumMultiplicity='1') then 'R' else('O')
            return
            attribute conformance {$conformance}
        else()
        ,
        if (not($item/@isMandatory)) then
            attribute isMandatory {'false'}
        else()
        ,
        if (not($item/@flexibility)) then
            attribute flexibility {'dynamic'}
        else()
        ,
        if ($selected) then (attribute selected {''}) else ()
        ,
        for $desc in $item/desc
        return
        art:serializeNode($desc)
        ,
        $item/item,
        for $example in $item/example
        return
        <example type="{$example/@type}" caption="{$example/@caption}">
        {
            for $exampleElement in $example/node()
            return
            util:serialize($exampleElement,'method=xml encoding=UTF-8')
        }
        </example>
        ,
        for $subItem in $item/constraint
        return
        local:recurseItemForEdit($projectPrefix, $subItem,$language,$valueSetList,$templateList,$selected)
    }
    </include>
else if ($item/name()='let') then
    <let>{if ($selected) then (attribute selected {''}) else (),$item/(@* except @selected),$item/node()}</let>
else if ($item/name()='assert') then
    <assert>{if ($selected) then (attribute selected {''}) else (),$item/(@* except @selected),art:serializeNode($item)/node()}</assert>
else if ($item/name()='report') then
    <report>{if ($selected) then (attribute selected {''}) else (),$item/(@* except @selected),art:serializeNode($item)/node()}</report>
else if ($item/name()='constraint') then
    <constraint>{if ($selected) then (attribute selected {''}) else (),$item/(@* except @selected),art:serializeNode($item)/node()}</constraint>
else()
};

declare function local:index-of-node( $nodes as node()* , $nodeToFind as node() )  as xs:integer* {
    for $seq in (1 to count($nodes))
    return $seq[$nodes[$seq] is $nodeToFind]
};

declare function local:mergePrototypeTemplateForEdit($projectPrefix as xs:string, $item as element(),$template as element(),$language as xs:string,$valueSetList as element()*,$templateList as element()*) as element()* {
    (:
       - get corresponding node in prototype
    :)
    let $node := util:eval-inline($template,local:path-to-node($item))[1]

    return (
        (:
            if parent is not 'template' check for missing prototype nodes
        :)
        if (not($item/parent::template)) then
            let $precedingItem := $item/preceding-sibling::*[1]
            let $precedingNodes := reverse($node/preceding-sibling::*)
            return
            (: 
                if there are no preceding nodes in template, get all preceding nodes from prototype
                else get preceding nodes up to node with same name as preceding template node
            :)
            if (count($item/preceding-sibling::*)=0 and count($node/preceding-sibling::*)>0) then
                for $precedingNode in $node/preceding-sibling::*
                return
                    local:recurseItemForEdit($projectPrefix,$precedingNode,$language,$valueSetList,$templateList,false())
            else (
                (:   
                    check if there are preceding nodes in prototype that are not in the template
                :)
                let $indexNode  := $precedingNodes[name()=$precedingItem/name()][name()='choice' or concat(@name,@ref,@contains)=$precedingItem/concat(@name,@ref,@contains)]
                let $index      := if ($indexNode) then local:index-of-node($precedingNodes,$indexNode) else (0)
                
                for $n in reverse($precedingNodes)
                where local:index-of-node($precedingNodes,$n) lt $index
                return
                    local:recurseItemForEdit($projectPrefix,$n,$language,$valueSetList,$templateList,false())
            )
        else (),
        if ($item/name()='attribute') then
            let $item := templ:normalizeAttributes($item)
            return
                <attribute selected="{if ($node) then 'original' else ''}">
                {
                    $item/@name,
                    $item/@value,
                    if ($item[@prohibited='true']) then
                        attribute prohibited {'true'}
                    else (
                        attribute isOptional {$item/@isOptional='true'}
                    )
                    ,
                    $item/@datatype,
                    if ($node/@datatype) then
                        attribute originalType {local:getDatatype($node/@datatype,$node/ancestor::template/classification/@format)}
                    else if ($item/@datatype) then
                        attribute originalType {local:getDatatype($item/@datatype,$item/ancestor::template/classification/@format)}
                    else()
                    ,
                    if ($node) then $node/@originalOpt else (attribute originalOpt {'true'})
                    ,
                    attribute conf {if ($item/@isOptional='true') then 'isOptional' else if ($item/@prohibited='true') then 'prohibited' else ''},
                    for $desc in $item/desc
                    return
                    art:serializeNode($desc)
                    ,
                    for $subitem in $item/*[name()!='desc']
                    return
                        if ($subitem[name()!='vocabulary']) then
                            $subitem
                        else (
                            <vocabulary>
                            {
                                $subitem/@*[not(name()='linkedartefactmissing')],
                                local:isValueSetInScope($projectPrefix, $subitem/@valueSet,$subitem/@flexibility,$valueSetList),
                                $subitem/*
                            }
                            </vocabulary>
                        )
                }
                </attribute>
        else if ($item/name()='element') then
            <element selected="{if ($node) then 'original' else ''}">
            {
                $item/(@* except (@tmid|@tmname|@tmdisplayName|@linkedartefactmissing)),
                local:isTemplateInScope($projectPrefix, $item/@contains,$item/@flexibility,$templateList)
                ,
                if ($node/@datatype) then
                    attribute originalType {local:getDatatype($node/@datatype,$node/ancestor::template/classification/@format)}
                else if ($item/@datatype) then (
                    attribute originalType {local:getDatatype($item/@datatype,$item/ancestor::template/classification/@format)}
                )
                else ()
                ,
                if (not($item/@minimumMultiplicity)) then
                    attribute minimumMultiplicity {'0'}
                else ()
                ,
                if (not($item/@maximumMultiplicity)) then
                    attribute maximumMultiplicity {'*'}
                else()
                ,
                if ($node/@minimumMultiplicity) then
                    attribute originalMin {$node/@minimumMultiplicity}
                else (
                    attribute originalMin {'0'}
                )
                ,
                if ($node/@maximumMultiplicity) then
                    attribute originalMax {$node/@maximumMultiplicity}
                else (
                    attribute originalMax {'*'}
                )
                ,
                if (not($item/@conformance)) then
                    attribute conformance {'O'}
                else ()
                ,
                if (not($item/@isMandatory)) then
                    attribute isMandatory {'false'}
                else ()
                ,
                for $desc in $item/desc
                return
                art:serializeNode($desc)
                ,
                for $vocabulary in $item/vocabulary
                return
                    <vocabulary>
                    {
                        $vocabulary/@*[not(name()='linkedartefactmissing')],
                        local:isValueSetInScope($projectPrefix, $vocabulary/@valueSet,$vocabulary/@flexibility,$valueSetList),
                        $vocabulary/*
                    }
                    </vocabulary>
                ,
                $item/property,
                $item/item,
                $item/text,
                for $example in $item/example
                return
                    <example type="{$example/@type}" caption="{$example/@caption}">
                    {
                       for $exampleElement in $example/node()
                       return
                       util:serialize($exampleElement,'method=xml encoding=UTF-8')
                    }
                    </example>
                ,
                for $subItem in $item/(attribute|element|choice|include|constraint|let|defineVariable|assert|report)
                return
                    local:mergePrototypeTemplateForEdit($projectPrefix, $subItem,$template,$language,$valueSetList,$templateList)
            }
            </element>
        else if ($item/name()='choice') then
            <choice selected="{if ($node) then 'original' else ''}">
            {
                $item/@*,
                if (not($item/@minimumMultiplicity)) then
                    attribute minimumMultiplicity {'0'}
                else()
                ,
                if (not($item/@maximumMultiplicity)) then
                    attribute maximumMultiplicity {'*'}
                else()
                ,
                if ($node/@minimumMultiplicity) then
                    attribute originalMin {$node/@minimumMultiplicity}
                else(attribute originalMin {'0'})
                ,
                if ($node/@maximumMultiplicity) then
                    attribute originalMax {$node/@maximumMultiplicity}
                else(attribute originalMax {'*'})
                ,
                if (not($item/@conformance)) then
                    attribute conformance {'O'}
                else()
                ,
                if (not($item/@isMandatory)) then
                    attribute isMandatory {'false'}
                else()
                ,
                for $desc in $item/desc
                return
                art:serializeNode($desc)
                ,
                $item/item,
                for $subItem in $item/(element|choice|include|constraint)
                return
                local:mergePrototypeTemplateForEdit($projectPrefix, $subItem,$template,$language,$valueSetList,$templateList)
            }
            </choice>
        else if ($item/name()='include') then
            <include selected="{if ($node) then 'original' else ''}">
            {
                $item/(@* except (@tmid|@tmname|@tmdisplayName|@linkedartefactmissing)),
                local:isTemplateInScope($projectPrefix, $item/@ref,$item/@flexibility,$templateList)
                ,
                if (not($item/@minimumMultiplicity)) then
                    attribute minimumMultiplicity {'0'}
                else()
                ,
                if (not($item/@maximumMultiplicity)) then
                    attribute maximumMultiplicity {'*'}
                else()
                ,
                if ($node/@minimumMultiplicity) then
                    attribute originalMin {$node/@minimumMultiplicity}
                else (
                    attribute originalMin {'0'}
                )
                ,
                if ($node/@maximumMultiplicity) then
                    attribute originalMax {$node/@maximumMultiplicity}
                else (
                    attribute originalMax {'*'}
                )
                ,
                if (not($item/@conformance)) then
                    attribute conformance {'O'}
                else ()
                ,
                if (not($item/@isMandatory)) then
                    attribute isMandatory {'false'}
                else ()
                ,
                for $desc in $item/desc
                return
                art:serializeNode($desc)
                ,
                $item/item
                ,
                for $example in $item/example
                return
                    <example type="{$example/@type}" caption="{$example/@caption}">
                    {
                        for $exampleElement in $example/node()
                        return
                        util:serialize($exampleElement,'method=xml encoding=UTF-8')
                    }
                    </example>
                ,
                for $subItem in $item/constraint
                return
                    local:mergePrototypeTemplateForEdit($projectPrefix, $subItem,$template,$language,$valueSetList,$templateList)
            }
            </include>
        else if ($item/name()='let') then
            <let selected="{if ($node) then 'original' else ''}">
            {
                $item/(@* except @selected),
                $item/node()
            }
            </let>
        else if ($item/name()='assert') then
            <assert selected="{if ($node) then 'original' else ''}">
            {
                $item/(@* except @selected),
                art:serializeNode($item)/node()
            }
            </assert>
        else if ($item/name()='report') then
            <report selected="{if ($node) then 'original' else ''}">
            {
                $item/(@* except @selected),
                art:serializeNode($item)/node()
            }
            </report>
        else if ($item/name()='constraint') then
            <constraint selected="{if ($node) then 'original' else ''}">
            {
                $item/(@* except @selected),
                art:serializeNode($item)/node()
            }
            </constraint>
        else (),
        (:
           if parent is not 'template' check if there are prototype nodes after the last template node
        :)
        if (not($item/parent::template) and not($item/following-sibling::*) and $node/following-sibling::*) then
            for $n in $node/following-sibling::*
            return
                local:recurseItemForEdit($projectPrefix,$n,$language,$valueSetList,$templateList,false())
        else()
    )
};

declare function local:path-to-node ( $nodes as node()* )  as xs:string* { 
    let $xPath :=
        for $element in $nodes/ancestor-or-self::*[not(name(.)=('httpclient:response','httpclient:body','decor','rules','template'))]
        let $elementName := $element/name()
        let $name        := if ($element/@name) 
                            then $element/@name
                            else ($element/@*[not(name()=('isOptional','prohibited','name','datatype','value'))][1])
        return
        if ($name) then concat($elementName,'[@',$name/name(),'=''',$name/string(),''']') else ()
   return
   string-join($xPath,'/')
};
 
(:get prototype for editor with normalized attributes:)
declare function local:getPrototype($id as xs:string,$flexibility as xs:string?,$projectPrefix) as element()? {
    let $prototype      := (templ:getTemplateById($id,if (matches($flexibility,'^\d{4}')) then $flexibility else 'dynamic',$projectPrefix)/*/template[@id])[1]
    return
        if ($prototype) then $prototype else <template/>
};

(:acquire lock. new if we are a project author AND (the owner of the current OR if there is no lock yet), don't create lock otherwise:)
declare function local:acquireLock($decor as element(), $username as xs:string, $id as xs:string, $effectiveDate as xs:string) as element() {
    let $lock       := $get:colArtResources//lock[@type='TM'][@ref=$id][@effectiveDate=$effectiveDate]
    
    return
        if (not($decor/project/author[@username=$username])) then
            <false/>
        else if (empty($lock) or $lock/@user=$username) then
            let $newLock    := <lock type="TM" ref="{$id}" effectiveDate="{$effectiveDate}" user="{$username}" userName="{$decor/project/author[@username=$username]/text()}" since="{current-dateTime()}"/>
            let $deleteLock := if ($lock) then update delete $lock else ()
            let $insertLock := update insert $newLock into $get:colArtResources//decorLocks
            
            return <true>{$newLock}</true>
        else (
            <false>{$lock}</false>
        )
};


let $projectPrefix  := if (request:exists()) then request:get-parameter('project',()) else ('demo1-')
let $id             := if (request:exists()) then request:get-parameter('id',()) else ('2.16.840.1.113883.3.1937.777.10.1')
let $effectiveDate  := if (request:exists()) then request:get-parameter('effectiveDate',()) else ('2007-04-01T00:00:00')
let $mode           := if (request:exists()) then request:get-parameter('mode',()) else ('new')

(:let $id := '2.16.840.1.113883.10.20.22.4.31'
let $effectiveDate := '2012-06-01T00:00:00'
let $mode := 'edit'
let $language := 'nl-NL':)

(: username for permission check and use in conceptLock:)
let $username       := xmldb:get-current-user()
let $decor          := $get:colDecorData//concept

let $template       := 
    if ($mode='new') then (
        local:getPrototype($id,$effectiveDate,$projectPrefix)
    )
    else (
        (templ:getTemplateById($id,if (matches($effectiveDate,'^\d{4}')) then $effectiveDate else 'dynamic',$projectPrefix)/*/template[@id])[1]
    )
let $decor          := $get:colDecorData//decor[project/@prefix=$projectPrefix]
(:let $valueSetList   := vs:getValueSetList((), (), (), $decor/project/@prefix)//valueSet:)
(:let $templateList   := for $t in $decor/rules/template return <template>{$t/@*}</template>:)
let $valueSetList   := $decor/terminology/valueSet
let $templateList   := $decor/rules/template
let $language       := if (request:exists()) then request:get-parameter('language',$decor/project/@defaultLanguage/string()) else ($decor/project/@defaultLanguage/string())
let $lockAcquired   := if ($mode='edit') then local:acquireLock($decor, $username, $id, $effectiveDate) else (<true/>)

let $response :=
    (:check if user is author:)
    if ($lockAcquired/self::false) then
        <template>{if ($lockAcquired/*) then $lockAcquired/* else 'NO PERMISSION'}</template>
    else if (not($mode=('edit','new','version','adapt'))) then
        <template>{'MODE ''',$mode,''' UNSUPPORTED'}</template>
    else (
        let $specialization := $template/relationship[@type='SPEC'][@template][1]
        (:get prototype for editor with normalized attributes:)
        let $prototype      := if ($specialization) then (local:getPrototype($specialization/@template,$specialization/@flexibility,$projectPrefix)) else ()
        
        let $useBaseId      := if (count($decor/ids/baseId[@type='TM'][@default='true'])=1) then $decor/ids/baseId[@type='TM'][@default='true']/@id else ($decor/ids/baseId[@type='TM'])[1]/@id
        
        return
        <template projectPrefix="{$decor/project/@prefix}" baseId="{$useBaseId}">
        {
            attribute statusCode {if ($mode='edit') then $template/@statusCode else 'new'},
            $template/(@* except (@projectPrefix|@baseId|@statusCode)),
            for $att in ('displayName','versionLabel','isClosed')
            return
                if (not($template/@*[name()=$att])) then
                    attribute {$att} {''}
                else()
        }
        <edit edit="edit"/>
        {
            $lockAcquired/*
        }
        {
            if (not($template/desc[@language=$language])) then
                <desc language="{$language}"/>
            else()
            ,
            for $desc in $template/desc
            return
            art:serializeNode($desc)
        }
        {
            $template/classification
        }
        {
            for $relationship in $template/relationship
            let $addAttribute := if ($relationship/@template) then 'model' else 'template'
            return
            <relationship>
            {
                $relationship/@*,
                attribute selected {if ($relationship/@template) then 'template' else 'model'},
                attribute {$addAttribute} {''},
                if (not($relationship/@flexibility)) then
                    attribute flexibility {''}
                else()
            }
            </relationship>
            ,
            if ($mode=('new','version','adapt')) then (
                <relationship type="{if ($mode='new') then 'SPEC' else upper-case($mode)}" template="{$template/@id}" selected="template" flexibility="{$template/@effectiveDate}" templateName="{$template/@name}"/>
            ) else ()
        }
        {
            if ($template/context/@path) then
                <context id="" path="{$template/context/@path}" selected="path"/>
            else if ($template/context/@id) then
                <context id="{$template/context/@id}" path="" selected="id"/>
            else(<context id="" path="" selected=""/>)
        }
        {
            if ($template/item) then
                <item label="{$template/item/@label}">
                {
                    for $desc in $template/item/desc
                    return
                    art:serializeNode($desc)
                }
                </item>
            else()
        }
        {
            for $example in $template/example
            return
            <example type="{$example/@type}" caption="{$example/@caption}">
            {
                for $exampleElement in $example/node()
                return
                util:serialize($exampleElement,'method=xml encoding=UTF-8')
            }
            </example>
            ,
            if (not($template/example)) then
                <example type="neutral" caption=""></example>
            else()
        }
        {
            if (exists($specialization) and exists($prototype)) then (
                for $item in $template/(attribute|element|choice|include|let|defineVariable|assert|report|constraint)
                return
                local:mergePrototypeTemplateForEdit($projectPrefix,$item,$prototype,$language,$valueSetList,$templateList)
            )
            else (
                for $item in $template/(attribute|element|choice|include|let|defineVariable|assert|report|constraint)
                return
                local:recurseItemForEdit($projectPrefix,$item,$language,$valueSetList,$templateList,true())
            )
        }
        </template>
    )
  
return
$response