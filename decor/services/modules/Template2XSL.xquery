xquery version "3.0";
(:
	Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
	
	Author: Kai U. Heitmann
	
	in part taken (copy and adaption) from
	get-stylesheet-for-templates: 2012-2013: Marc de Graauw, Alexander Henket
    
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get  = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art  = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace artx = "http://art-decor.org/ns/art/xpath" at  "../../../art/modules/art-decor-xpath.xqm";

declare namespace datetime   = "http://exist-db.org/xquery/datetime";
declare namespace xsl        = "http://www.w3.org/1999/XSL/Transform";
declare namespace hl7        = "urn:hl7-org:v3";

(: TODO: namespaces from decor file are to be used from input :)
declare namespace peri       = "urn:nictiz-nl:v3/peri";
declare namespace lab        = "urn:oid:2.16.840.1.113883.2.4.6.10.35.81";

declare copy-namespaces no-preserve, inherit;

declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

declare variable $quote          := "&#39;";
declare variable $accolade-open  := "&#123;";
declare variable $accolade-close := "&#125;";
declare variable $ampersand      := "&#38;";
declare variable $newline        := "&#10;";

declare variable $warning        := concat("Generated code (v0.8) at ", datetime:format-dateTime(current-dateTime(), "yyyy-MM-dd HH:mm:ss z"), " *** do not make any changes here, do regenerate (xquery)");

declare variable $xqueryname     := "Template2XSL";

declare variable $prefix         := request:get-parameter('prefix','');
declare variable $decorRules     := collection($get:strDecorData)//decor[project/@prefix=$prefix]/rules;

declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');


declare function local:reportError($error as xs:string, $severity as xs:integer) as element() {
    for $i in 1 to 1
    return <error severity="{$severity}">{$error}</error>
};

declare function local:getNameWithoutPredicate($name as xs:string) as xs:string {
    if (contains($name,'[')) then substring-before($name,'[') else $name
};

(:
    Get the right template from a collection of templates. Parameters
    templateRef - Name or Id of the template
    templateEffectiveDate - EffectiveDate (static reference), 'dynamic' or empty (both point to the 'newest' version)
:)
declare function local:getTemplate($templateRef as attribute(), $templateEffectiveDate as xs:string?) as element() {
    let $t :=
        if (matches(data($templateEffectiveDate),'^\d{4}')) then (
            $decorRules/template[@id=$templateRef or @name=$templateRef][@effectiveDate=$templateEffectiveDate]
        )
        else (
            $decorRules/template[@id=$templateRef or @name=$templateRef][@effectiveDate=string(max($decorRules/template[@id=$templateRef or @name=$templateRef]/xs:dateTime(@effectiveDate)))]
        )
    return
        if (count($t)=1)
        then
            <template>
            {
                $t/@*,
                $t/*
            }
            {
                <staticAssociations>
                {
                    for $association in $decorRules/templateAssociation[@templateId=$t/@id][@effectiveDate=$t/@effectiveDate]/concept
                    return
                        <origconcept ref="{$association/@ref}" effectiveDate="{$association/@effectiveDate}" elementId="{$association/@elementId}">
                        {
                            art:getOriginalConceptName($association)
                        }
                        </origconcept>
                }
                </staticAssociations>
            }
            </template>
        else
            local:reportError(concat("Template get error, found ", count($t)), 3)
};

declare function local:getTemplateChain($node as element(), $chain-so-far as xs:string) as element()* {
let $r :=
    if ($node/(@contains|@ref)) then (
        let $template := local:getTemplate($node/(@contains|@ref), $node/@flexibility)
        return (
            if (not(contains($chain-so-far,concat($template/@id,'-',$template/@effectiveDate)))) then (
                $template,
                for $node in $template//(element[@contains]|include)
                return
                    local:getTemplateChain($node, concat($chain-so-far,' ',$template/@id,'-',$template/@effectiveDate))
            ) else ()
        )
    ) else ()
    
return $r

};

declare function local:copyTemplateNode($node as element()*, $templateAssociations as element()*) as node()* {
    (:
    instance generator, recursively walks through templates
    :)
    (: check for errors :)
    if (fn:empty($node)) 
    then 
        local:reportError('No template', 3) 
    
    else if (count($node)>1) 
    then 
        local:reportError('More than one template', 3) 
    
    (: the following are not relevant for message (I hope) :)
    else if (name($node)=('example','desc','context','relationship','classification','item','label','defineVariable','let','assert','report','template','constraint','text', 'staticAssociations', 'origconcept', 'concept')) 
    then ()
    
    (: now begin your task :)
    else if (name($node)='attribute')
    then
        local:processTemplateAttributes($node)
    
    else if (name($node)='choice')
    then 
        if ($node/parent::element[@datatype]) then (
            for $child in $node/*
            return
                local:copyTemplateNode($child, $templateAssociations)
        ) else (
            local:reportError(concat('No handling yet for element ', name($node)), 2)
        )
        (:for $el in $node/* return local:copyTemplateNode($el, $templates, $templateAssociations):)
    
    (: for includes, only process included template :)
    else if (name($node)='include') 
    then
        for $el in (:$node/*:) local:getTemplate($node/@ref, $node/@flexibility)/*
        return local:copyTemplateNode($el, $templateAssociations)
    
    (: process <element> child :)
    else if (name($node)='element') 
    then
        (: for contains, process element once for each concept, call template, process children :)
        if ($node[@contains])
        then (
            let $template := local:getTemplate($node/@contains, $node/@flexibility)
            let $tmpname := concat($template/@name, '-', replace(data($template/@effectiveDate),'[-T:]','') )
            return
                element {local:getNameWithoutPredicate($node/@name)} {
                    local:processTemplateAttributes($node),
                    <xsl:call-template name="{$tmpname}">
                        <importparameter from="{$tmpname}"/>
                    </xsl:call-template>
                }
        )
        else if ($node[@id]) then (
            let $repeatable := $node[number(@maximumMultiplicity)>1]
            return
                if (empty($repeatable))
                then (
                    local:processTemplateElement($node, $templateAssociations)
                )
                else (
                    <xsl:for-each select="{concat('$element-', $node/@id)}">
                    {
                        local:processTemplateElement($node, $templateAssociations)
                    }
                    </xsl:for-each>
                )
        )
        (: if no contains att, process element :)
        else ( 
            local:processTemplateElement($node, $templateAssociations)
        )
    
    (: else: output error and element as is, do process children :) 
    else (
        local:reportError(concat('Unprocessed element ', name($node)), 2), 
        element {name($node)} {
            $node/@*, for $el in $node/* return local:copyTemplateNode($el, $templateAssociations)
        }
    )
};

declare function local:processTemplateElement($node as element(), $templateAssociations as element()*) as node()* {
(:  input:  '<element>' node from template
            sequence of relevant templates
    output: sequence of nodes (mostly elements, but may contain comments)
:)

(: element/@name may contain predicates (name='X[Y]'), omit predicate :)

let $r :=
    element {local:getNameWithoutPredicate($node/@name)} {
        local:processTemplateAttributes($node), 
        (: TODO: handle multiple element/@id in same template :)
        (: process datatypes :)
        if ($node[@datatype]) 
        then local:processDatatype($node, $templateAssociations)
        else (),
        (:  process children, omit 'attribute' , 'vocabulary' and 'property' child nodes,
            they have already been handled in datatype or attribute processing :)
        for $el in $node/*[local-name()!='attribute'][local-name()!='vocabulary'][local-name()!='property']
        return local:copyTemplateNode($el, $templateAssociations)
    }

return
    if ($r[@* or node()] or $node[number(@minimumMultiplicity)>0 or string(@isMandatory)='true']) then
        if ($node[@datatype]) then (
            (: KH1 :)
            if (exists($node[number(@minimumMultiplicity)>0 or string(@isMandatory)='true']) or $r/*[not(@nullFlavor)])
            then 
                if ($node[@id]) 
                then <xsl:for-each select="{concat("$element-", $node/@id)}">{$r}</xsl:for-each>
                else $r
            else 
                $r
        )
        else ($r)
    else (
        comment {'Omitting optional element',$node/@name,if ($node[@datatype]) then concat('with datatype ',$node/@datatype) else ()}
    )
    
};

declare function local:processDatatype($node as element(), $templateAssociations as element()*) as node()* {
    (:  input: <element> node which has @datatype
        output: call-template statement for datatype, with appropriate params
    :)
    let $tempAssocArray :=
        $node/ancestor::include[last()]/staticAssociations/origconcept/@elementId |
        $templateAssociations[@templateId=$node/ancestor::template/@id][@effectiveDate=$node/ancestor::template/@effectiveDate]/concept/@elementId
    let $datatype       := if ($node/@datatype='SD.TEXT') then $node/@datatype/string() else tokenize($node/@datatype/string(),'\.')[1]
    (: KH2 :)
    let $r :=
    <xsl:call-template name="{$datatype}">
        {
            if ($node/attribute[@name='xsi:type'][not(string(@isOptional)='true')]) then (
                <xsl:with-param name="xsiType" select="'{$datatype}'"/>
            ) else ()
        }
        {
            (: note: does not support attribute with vocabulary element. not common but possible... :)
            if ($node[string(@isMandatory)!='true']/attribute[@name='nullFlavor'][@value][not(string(@isOptional)='true') or parent::*[number(@minimumMultiplicity)>0]]) then (
                <xsl:with-param name="nullFlavor" select="'{tokenize(($node/attribute[@name='nullFlavor']/@value)[1],'\|')[1]}'"/>
            )
            else if ($node[string(@isMandatory)!='true']/attribute[@nullFlavor][not(string(@isOptional)='true') or parent::*[number(@minimumMultiplicity)>0]]) then (
                <xsl:with-param name="nullFlavor" select="'{tokenize(($node/attribute/@nullFlavor)[1],'\|')[1]}'"/>
            )
            else if ($node[@id][string(@isMandatory)!='true']) then (
                 <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
            )
            else if ($node[number(@minimumMultiplicity)>0][string(@isMandatory)!='true']) then (
                 <xsl:with-param name="nullFlavor" select="'NI'"/>
            )
            else ()
        }
        {
            if ($node[$datatype='CS'][@id=$tempAssocArray]) then (
                <xsl:with-param name="code">
                {
                    let $tt :=
                        if ($node/vocabulary[@code]) then
                            ($node/vocabulary/@code)[1]/string()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@code'}
                        else
                            <xsl:choose>
                                <xsl:when test="@code">
                                    <xsl:value-of select="@code"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('CD','CE','CV','CO','SC')][@id=$tempAssocArray]) then (
                if ($node/vocabulary[@code][@codeSystem]) then (
                    <xsl:with-param name="code">
                        <xsl:choose>
                            <xsl:when test="@code">
                                <xsl:value-of select="@code"/>
                            </xsl:when>
                            <xsl:otherwise>{($node/vocabulary[@code][@codeSystem]/@code)[1]/string()}</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    ,
                    <xsl:with-param name="codeSystem">
                        <xsl:choose>
                            <xsl:when test="@codeSystem">
                                <xsl:value-of select="@codeSystem"/>
                            </xsl:when>
                            <xsl:otherwise>{($node/vocabulary[@code][@codeSystem]/@codeSystem)[1]/string()}</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    ,
                    <xsl:with-param name="displayName">
                    {
                        let $tt :=
                            if ($node/vocabulary[@code][@codeSystem]/@displayName) then
                                ($node/vocabulary[@code][@codeSystem]/@displayName)[1]/string()
                            else ()
                        return
                            if (empty($tt)) then 
                                attribute {'select'} {'@displayName'}
                            else
                                <xsl:choose>
                                    <xsl:when test="@displayName">
                                        <xsl:value-of select="@displayName"/>
                                    </xsl:when>
                                    <xsl:otherwise>{$tt}</xsl:otherwise>
                                </xsl:choose>
                    }
                    </xsl:with-param>
                    ,
                    <xsl:with-param name="codeSystemName">
                    {
                        let $tt :=
                            if ($node/vocabulary[@code][@codeSystem]/@codeSystemName) then
                                ($node/vocabulary[@code][@codeSystem]/@codeSystemName)[1]/string()
                            else ()
                        return
                            if (empty($tt)) then 
                                attribute {'select'} {'@codeSystemName'}
                            else
                                <xsl:choose>
                                    <xsl:when test="@codeSystemName">
                                        <xsl:value-of select="@codeSystemName"/>
                                    </xsl:when>
                                    <xsl:otherwise>{$tt}</xsl:otherwise>
                                </xsl:choose>
                    }
                    </xsl:with-param>
                    ,
                    <xsl:with-param name="codeSystemVersion">
                    {
                        let $tt :=
                            if ($node/vocabulary[@code][@codeSystem]/@codeSystemVersion) then
                                ($node/vocabulary[@code][@codeSystem]/@codeSystemVersion)[1]/string()
                            else ()
                        return
                            if (empty($tt)) then 
                                attribute {'select'} {'@codeSystemVersion'}
                            else
                                <xsl:choose>
                                    <xsl:when test="@codeSystemVersion">
                                        <xsl:value-of select="@codeSystemVersion"/>
                                    </xsl:when>
                                    <xsl:otherwise>{$tt}</xsl:otherwise>
                                </xsl:choose>
                    }
                    </xsl:with-param>
                )
                else (
                    <xsl:with-param name="code" select="@code"/>,
                    <xsl:with-param name="codeSystem" select="@codeSystem"/>,
                    <xsl:with-param name="displayName" select="@displayName"/>,
                    <xsl:with-param name="codeSystemName" select="@codeSystemName"/>,
                    <xsl:with-param name="codeSystemVersion" select="@codeSystemVersion"/>
                )
                ,
                if ($node[$datatype=('SC')][@id=$tempAssocArray]) then (
                    <xsl:with-param name="text">
                    {
                        let $tt :=
                            if ($node/text) then
                                $node/text/node()
                            else ()
                        return
                            if (empty($tt)) then 
                                attribute {'select'} {'@text'}
                            else
                                <xsl:choose>
                                    <xsl:when test="@text">
                                        <xsl:value-of select="@text"/>
                                    </xsl:when>
                                    <xsl:otherwise>{$tt}</xsl:otherwise>
                                </xsl:choose>
                    }
                    </xsl:with-param>
                )
                else ()
            )
            (: TODO: if (node[@id]) dan elementId opzoeken, concept id erbij, dan $select-clause='//concept[@id='..']/@value
                     daarna op datatype with-param maken, in selelect $select-clause stoppen :)
                     
            else if ($node[$datatype=('II')][@id=$tempAssocArray]) then (
                <xsl:with-param name="root">
                {
                    let $tt :=
                        if ($node/attribute[@root]) then
                            tokenize(($node/attribute/@root)[1],'\|')[1]
                        else if ($node/attribute[@name='root']) then
                            tokenize(($node/attribute[@name='root']/@value)[1],'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@root'}
                        else
                            <xsl:choose>
                                <xsl:when test="@root">
                                    <xsl:value-of select="@root"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="extension">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@extension'}
                        else
                            <xsl:choose>
                                <xsl:when test="@extension">
                                    <xsl:value-of select="@extension"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('BL','BN','INT','ON','TN','TS')][@id=$tempAssocArray]) then (
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param> 
                
            )
            else if ($node[$datatype=('MO')][@id=$tempAssocArray]) then (
                (: note that datatype MO has @currency rather than @unit. Handled in DECOR_DTr1.xsl :)
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                (: take unit from instance if provided, else from template :)
                <xsl:with-param name="unit">
                {
                    let $tt :=
                        if ($node/property[@currency]) then
                            tokenize(($node/property/@currency)[1],'\|')[1]
                        else if ($node/attribute[@currency]) then
                            tokenize(($node/attribute/@currency)[1],'\|')[1]
                        else if ($node/attribute[@name='currency']) then
                            tokenize(($node/attribute[@name='currency']/@value)[1],'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@unit'}
                        else
                            <xsl:choose>
                                <xsl:when test="@currency">
                                    <xsl:value-of select="@currency"/>
                                </xsl:when>
                                <xsl:when test="@unit">
                                    <xsl:value-of select="@unit"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('PQ')][@id=$tempAssocArray]) then (
                (: note that datatype MO has @currency rather than @unit. Handled in DECOR_DTr1.xsl :)
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="unit">
                {
                    let $tt :=
                        if ($node/property[@unit]) then
                            tokenize(($node/property/@unit)[1],'\|')[1]
                        else if ($node/attribute[@unit]) then
                            tokenize(($node/attribute/@unit)[1],'\|')[1]
                        else if ($node/attribute[@name='unit']) then
                            tokenize(($node/attribute[@name='unit']/@value)[1],'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@unit'}
                        else
                            <xsl:choose>
                                <xsl:when test="@unit">
                                    <xsl:value-of select="@unit"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('AD')][@id=$tempAssocArray]) then (
                (: TODO handle [@id] based logic for composite element :)
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="use">
                {
                    let $tt :=
                        if ($node/attribute[@use]) then
                            tokenize($node/attribute/@use/string(),'\|')[1]
                        else if ($node/attribute[@name='use']) then
                            tokenize($node/attribute[@name='use']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@use'}
                        else
                            <xsl:choose>
                                <xsl:when test="@use">
                                    <xsl:value-of select="@use"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('ADXP')][@id=$tempAssocArray]) then (
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="qualifier">
                {
                    let $tt :=
                        if ($node/attribute[@qualifier]) then
                            tokenize($node/attribute/@qualifier/string(),'\|')[1]
                        else if ($node/attribute[@name='qualifier']) then
                            tokenize($node/attribute[@name='qualifier']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@qualifier'}
                        else
                            <xsl:choose>
                                <xsl:when test="@qualifier">
                                    <xsl:value-of select="@qualifier"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('EN','PN')][@id=$tempAssocArray]) then (
                (: TODO handle [@id] based logic for composite element :)
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="use">
                {
                    let $tt :=
                        if ($node/attribute[@use]) then
                            tokenize($node/attribute/@use/string(),'\|')[1]
                        else if ($node/attribute[@name='use']) then
                            tokenize($node/attribute[@name='use']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@use'}
                        else
                            <xsl:choose>
                                <xsl:when test="@use">
                                    <xsl:value-of select="@use"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('ENXP')][@id=$tempAssocArray]) then (
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="qualifier">
                {
                    let $tt :=
                        if ($node/attribute[@qualifier]) then
                            tokenize($node/attribute/@qualifier/string(),'\|')[1]
                        else if ($node/attribute[@name='qualifier']) then
                            tokenize($node/attribute[@name='qualifier']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@qualifier'}
                        else
                            <xsl:choose>
                                <xsl:when test="@qualifier">
                                    <xsl:value-of select="@qualifier"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('ED')][@id]) then (
                (: TODO handle [@id] based logic for composite element :)
                <xsl:with-param name="mediaType">
                {
                    let $tt :=
                        if ($node/attribute[@mediaType]) then
                            tokenize($node/attribute/@mediaType/string(),'\|')[1]
                        else if ($node/attribute[@name='mediaType']) then
                            tokenize($node/attribute[@name='mediaType']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@mediaType'}
                        else
                            <xsl:choose>
                                <xsl:when test="@mediaType">
                                    <xsl:value-of select="@mediaType"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="representation">
                {
                    let $tt :=
                        if ($node/attribute[@representation]) then
                            tokenize($node/attribute/@representation/string(),'\|')[1]
                        else if ($node/attribute[@name='representation']) then
                            tokenize($node/attribute[@name='representation']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@representation'}
                        else
                            <xsl:choose>
                                <xsl:when test="@representation">
                                    <xsl:value-of select="@representation"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="compression">
                {
                    let $tt :=
                        if ($node/attribute[@compression]) then
                            tokenize($node/attribute/@compression/string(),'\|')[1]
                        else if ($node/attribute[@name='compression']) then
                            tokenize($node/attribute[@name='compression']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@compression'}
                        else
                            <xsl:choose>
                                <xsl:when test="@compression">
                                    <xsl:value-of select="@compression"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="charset">
                {
                    let $tt :=
                        if ($node/attribute[@charset]) then
                            tokenize($node/attribute/@charset/string(),'\|')[1]
                        else if ($node/attribute[@name='charset']) then
                            tokenize($node/attribute[@name='charset']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@charset'}
                        else
                            <xsl:choose>
                                <xsl:when test="@charset">
                                    <xsl:value-of select="@charset"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="language">
                {
                    let $tt :=
                        if ($node/attribute[@language]) then
                            tokenize($node/attribute/@language/string(),'\|')[1]
                        else if ($node/attribute[@name='language']) then
                            tokenize($node/attribute[@name='language']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@language'}
                        else
                            <xsl:choose>
                                <xsl:when test="@language">
                                    <xsl:value-of select="@language"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="text">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@text'}
                        else
                            <xsl:choose>
                                <xsl:when test="@text">
                                    <xsl:value-of select="@text"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('ST')][@id=$tempAssocArray]) then (
                <xsl:with-param name="text">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@text'}
                        else
                            <xsl:choose>
                                <xsl:when test="@text">
                                    <xsl:value-of select="@text"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('TEL')][@id=$tempAssocArray]) then (
                (: TODO handle [@id] based logic for composite element (useablePeriod) :)
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
                ,
                <xsl:with-param name="use">
                {
                    let $tt :=
                        if ($node/attribute[@use]) then
                            tokenize($node/attribute/@use/string(),'\|')[1]
                        else if ($node/attribute[@name='use']) then
                            tokenize($node/attribute[@name='use']/@value/string(),'\|')[1]
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@use'}
                        else
                            <xsl:choose>
                                <xsl:when test="@use">
                                    <xsl:value-of select="@use"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else if ($node[$datatype=('URL')][@id=$tempAssocArray]) then (
                <xsl:with-param name="value">
                {
                    let $tt :=
                        if ($node/text) then
                            $node/text/node()
                        else ()
                    return
                        if (empty($tt)) then 
                            attribute {'select'} {'@value'}
                        else
                            <xsl:choose>
                                <xsl:when test="@value">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <xsl:otherwise>{$tt}</xsl:otherwise>
                            </xsl:choose>
                }
                </xsl:with-param>
            
            )
            else (
                if ($node[@id=$tempAssocArray]) then (
                    local:reportError('No handling yet for datatype of this bound element. Using default handling based on properties and attributes', 2)
                ) else ()
                ,
                (:exclude nullFlavor and xsi:type as they are handled above:)
                for $attr in $node/(attribute[string(@isOptional)='false']|property)/(@root|@extension|@unit|@currency|@mediaType|@representation|@qualifier|@use|@operator|@prohibited)
                return (
                    <xsl:with-param name="{name($attr)}">
                        <xsl:choose>
                            <xsl:when test="@{name($attr)}">
                                <xsl:value-of select="@{name($attr)}"/>
                            </xsl:when>
                            <xsl:otherwise>{tokenize($attr/string(),'\|')[1]}</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                )
                ,
                for $attr in $node/attribute[not(string(@isOptional)='true')][@name[not(.=('nullFlavor','xsi:type'))]][@value]
                return (
                    <xsl:with-param name="{$attr/@name/string()}">
                        <xsl:choose>
                            <xsl:when test="@{$attr/@name/string()}">
                                <xsl:value-of select="@{$attr/@name/string()}"/>
                            </xsl:when>
                            <xsl:otherwise>{tokenize($attr/@value,'\|')[1]}</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                )
                ,
                if (($node/vocabulary[@code][@codeSystem])[1]) then (
                    <xsl:with-param name="code" select="'{($node/vocabulary[@code][@codeSystem])[1]/@code/string()}'"/>,
                    <xsl:with-param name="codeSystem" select="'{($node/vocabulary[@code][@codeSystem])[1]/@codeSystem/string()}'"/>,
                    <xsl:with-param name="displayName" select="'{($node/vocabulary[@code][@codeSystem])[1]/@displayName/string()}'"/>,
                    <xsl:with-param name="codeSystemName" select="'{($node/vocabulary[@code][@codeSystem])[1]/@codeSystemName/string()}'"/>,
                    <xsl:with-param name="codeSystemVersion" select="'{($node/vocabulary[@code][@codeSystem])[1]/@codeSystemVersion/string()}'"/>
                ) else if (($node/vocabulary[@code])[1]) then (
                    <xsl:with-param name="code" select="'{($node/vocabulary[@code])[1]/@code/string()}'"/>
                ) else ()
                ,
                if ($node[text]) then (
                    <xsl:with-param name="text" select="'{$node/text/node()}'"/>
                ) else ()
            )
        }
    </xsl:call-template>
    return
        (: KH3 :)
        if (count($r/*)>0) then $r else ()
};

declare function local:processTemplateAttributes($node as element()) as attribute()* {
    (:  input:  '<attribute>' node from template
        output: all attributes which go on HL7v3 element
        
        attributes either come as <attribute X='Y'/>, which go to message as is
        or as <attribute name='X' value='Y'/>

        TODO: value often needs to be supplied in code
        TODO: handle 'isOptional' attribute, are now ignored
        TODO: handle more than one attribute child, now only first is handled
    :)
    if ($node/property[@unit] and not($node/@datatype)) then (
        ($node/property/@unit)[1]
    ) else (),
    if ($node/property[@currency] and not($node/@datatype)) then (
        ($node/property/@currency)[1]
    ) else (),
    for $att in $node/attribute[not(string(@isOptional)='true')]/@* 
    return
        if (not(name($att)=('name','value','isOptional','datatype')))
        then attribute {name($att)} {tokenize(data($att),'\|')[1]}
        else if (name($att)='name' and $att='xsi:type') 
        then attribute {$att} {if ($node/@datatype='SD.TEXT') then $node/@datatype/string() else tokenize($node/@datatype/string(),'\.')[1]}
        else if (name($att)='name' and $att/../@value)
        then attribute {$att} {tokenize(data($att/../@value),'\|')[1]}
        else if (name($att)='name' and $att/string()=('negationInd','contextConductionInd','independentInd','institutionSpecified','inversionInd'))
        then attribute {$att} {'false'}
        else if (name($att)='name')
        then attribute {$att} {'error: no attribute value'}
        else ()
};

declare function local:cardconfs1element ($e as element()*, $minimumMultiplicity as xs:string?, $maximumMultiplicity as xs:string?, $isMandatory as xs:string?, $conformance as xs:string?) as element()* {
    (: override the first element in $e template/* with the card / conf spec submitted ; should be as easy as using update but didn't find it here :)
    
    for $child in $e/(element|attribute|assert|report|let|include|choice)
    let $minimumMultiplicity := if (string-length($minimumMultiplicity)=0) then ($child/@minimumMultiplicity) else ($minimumMultiplicity)
    let $maximumMultiplicity := if (string-length($maximumMultiplicity)=0) then ($child/@maximumMultiplicity) else ($maximumMultiplicity)
    let $isMandatory := if (string-length($isMandatory)=0) then ($child/@isMandatory) else ($isMandatory)
    let $conformance := if (string-length($conformance)=0) then ($child/@conformance) else ($conformance)
    return
        if ((count($e[preceding-sibling::element])=0) and ($child/name() = 'element'))
        then (
            element {$child/name()} {
                $child/(@* except (@minimumMultiplicity|@maximumMultiplicity|@isMandatory|@conformance)),
                if (string-length($minimumMultiplicity)>0) then attribute minimumMultiplicity {$minimumMultiplicity} else (),
                if (string-length($maximumMultiplicity)>0) then attribute maximumMultiplicity {$maximumMultiplicity} else (),
                if (string-length($isMandatory)>0) then attribute isMandatory {$isMandatory} else (),
                if (string-length($conformance)>0) then attribute conformance {$conformance} else (),
                $child/node()
            }
        ) else (
            element {$child/name()} {
                $child/@*,
                $child/node()
            }
        )
};

declare function local:artefactMissing($what as xs:string, $ref as xs:string?, $flexibility as xs:string?) as xs:boolean {
    (: returns false() :)
    let $x := 0
    return false()
};

declare function local:copyNodes($tnode as element(), $item as element(), $nesting as xs:integer) as element()* {
    let $elmname := name($tnode)
    return
        if ($nesting > 30) then
            (: too deeply nested, raise error and give up :)
            element error {
                attribute {'type'} {'nesting'}(:,
                $tnode:)
            }
        else if ($elmname='include') then
            let $recent := local:getTemplate($tnode/@ref, $tnode/@flexibility)
            return
                element include {
                    $tnode/@*,
                    attribute {'linkedartefactmissing'} {local:artefactMissing('template', $tnode/@ref, $tnode/@flexibility)},
                    $tnode/text(),
                    let $recentcardconf := local:cardconfs1element($recent, $tnode/@minimumMultiplicity, $tnode/@maximumMultiplicity, $tnode/@isMandatory, $tnode/@conformance)
                    for $t in $recentcardconf
                    return
                        local:copyNodes($t, $item, $nesting+1),
                        element staticAssociations {
                            for $association in $decorRules/templateAssociation[@templateId=$recent/@id][@effectiveDate=$recent/@effectiveDate]/concept
                            return
                                <origconcept ref="{$association/@ref}" effectiveDate="{$association/@effectiveDate}" elementId="{$association/@elementId}">
                                {
                                    art:getOriginalConceptName($association)
                                }
                                </origconcept>
                        }
                }
        else if ($tnode/name()='vocabulary') then
            element {$elmname} {
                $tnode/@*,
                if ($tnode/@valueSet) then attribute {'linkedartefactmissing'} {local:artefactMissing('valueSet', $tnode/@valueSet, $tnode/@flexibility)} else (),
                $tnode/*
            }
        else if ($tnode/name()='example') then (
            (: copy only level one example here, others are copied later :)
            if ($nesting = 1) then () else ()
        )
        else
            element {$elmname} {
                $tnode/@*,
                if ($tnode/@contains) then attribute {'linkedartefactmissing'} {local:artefactMissing('template', $tnode/@contains, $tnode/@flexibility)} else (),
                $tnode/text(),
                (: change sequence of elements, attributes first, then examples, then the rest :)
                for $s in $tnode/*[name()='attribute']
                return
                    local:copyNodes($s, $item, $nesting+1),
                for $s in $tnode/*[name()='example']
                return 
                    (),
                for $s in $tnode/*[not(name()='attribute')][not(name()='example')]
                return
                    local:copyNodes($s, $item, $nesting+1)
            }
};

declare function local:getParametersFromElementIds($t as element(), $xpath as xs:string, $nesting as xs:integer) as element()* {

    for $elmid in $t/(element|include|choice)
    let $xpath := concat($xpath, '/', $elmid/@name)
    let $params := 
        if ($elmid[@id]) then
            <param name="{concat('element-', $elmid/@id)}" id="{$elmid/@id}" xpath="{$xpath}" datatype="{$elmid/@datatype}" 
                minimumMultiplicity="{$elmid/@minimumMultiplicity}" maximumMultiplicity="{$elmid/@maximumMultiplicity}"
                conformance="{$elmid/@conformance}" isMandatory="{$elmid/@isMandatory}">
            {
                local:getParametersFromElementIds($elmid, $xpath, $nesting+1)
            }
            </param>
        else local:getParametersFromElementIds($elmid, $xpath, $nesting+1)
        
    return
        $params
           
};

declare function local:doImportParams ($snode as node()*, $all as node()*, $aswith as xs:boolean, $nesting as xs:integer) as node()* {

    for $p in $snode/parent::xsl:template//importparameter
    return 
        for $q in $all//self::xsl:template[@name=$p/@from]
        return (
            if ($aswith=true()) 
            then 
                for $qq in $q/xsl:param
                return <xsl:with-param name="{$qq/@name}" select="{concat('$', $qq/@name)}"/>
            else 
                $q/xsl:param
            ,
            local:doImportParams($q/importcontainedparameter, $all, $aswith, $nesting)
        )
};

declare function local:copyTemplateStylesheet ($snode as node()*, $all as node()*, $nesting as xs:integer) as node()* {
    if ($snode/self::importparameter) then
        for $p in $all//self::xsl:template[@name=$snode/@from]/xsl:param
        return (
            <xsl:with-param name="{$p/@name}" select="{concat('$', $p/@name)}"/>, 
            local:doImportParams($p/parent::xsl:template/importcontainedparameter, $all, true(), $nesting)
        )
    else if ($snode/self::importcontainedparameter) then
        local:doImportParams($snode, $all, false(), $nesting)
    else if ($snode instance of comment()) then
        $snode
    else if ($snode instance of text()) then
       $snode
    else 
        element { fn:QName(fn:namespace-uri($snode), fn:name($snode)) } {
            $snode/@*,
            for $s in $snode/(*|comment()|text())
            return local:copyTemplateStylesheet ($s, $all, $nesting+1)
        }
};

(: main proc :)
let $debug         := true()

(: parameters :)
let $id            := if (request:exists()) then request:get-parameter('id','') else '' 
let $effectiveDate := if (request:exists()) then request:get-parameter('effectiveDate','') else '' 
let $format        := if (request:exists()) then request:get-parameter('format','') else ''


(: get local data collection :)
let $collection    := collection($get:strDecorData)
(: get DECOR project :)
let $decor         := $collection//project[@prefix=$prefix]/parent::decor

(: get a version of the template with @id from parameter, dynamic or with @effectiveDate :)
let $version       := 
    if (string-length($effectiveDate)>0) then
        local:getTemplate($decor//rules/template[@id=$id][1]/@id, $effectiveDate)
    else if (count($decor//rules/template[@id=$id])>0) then
        local:getTemplate($decor//rules/template[@id=$id][1]/@id, '')
    else () 
(: create an item label as a dummy :)
let $item          := <item>{concat('tmp-', $version/@id, '-', $version/@effectiveDate)}</item>

let $rootTemplate := 
    if (count($version)>0) 
    then 
        for $n in $version
        return local:copyNodes($n, $item, 1)
    else ()

(:
    get template chain from $rootTemplate 
    by following includes and contains
    and output a list with distinct templates
:)
let $templates := 
    let $listWithDuplicates :=
        for $node in $rootTemplate//(element[@contains]|include)
        return
            local:getTemplateChain($node, concat($rootTemplate/@id, '-', $rootTemplate/@effectiveDate))
    return
        for $node in $listWithDuplicates
        (:group $node as $tvd by concat($node/@id,'-',$node/@effectiveDate) as $dupkey:)
        group by $dupkey := concat($node/@id,'-',$node/@effectiveDate)
        return
            $node[1] (:local:copyNodes($tvd[1], <item>{concat('tmp-', $dupkey)}</item>, 1):)

(:cache all templateAssociation elements. We'll attach them as appropriate:)
let $templateAssociations := $collection//templateAssociation

let $errors :=
    <errors>
    {
        if (string-length($prefix)=0) then
            local:reportError('No prefix, specify prefix of DECOR project', 3)
        else ()
    }
    {
        if (string-length($id)=0) then
            local:reportError('No template id, specify template id', 3)
        else if (count($version/self::template)=0) then
            local:reportError(concat('Template ', $id, if (string-length($effectiveDate)>0) then ' as of ' else '', $effectiveDate, ' not found.'), 3)
        else ()
    }
    {    
        if (count($version/self::template)>1) then
            local:reportError(concat('Ambiguous template by id, ', $id, ', add version parameter (effectiveDate)'), 3)
        else ()
    }
    </errors>
    
let $stylesheet :=
    if (count($errors/*)>0) then
        $errors/*
    else
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" 
                    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                    version="2.0">
    
        {
            comment {$warning}
        }
        
        <!--
        <xsl:import href="http://art-decor.org/ADAR/rv/DECOR-DTr1.xsl"/>
        -->
        <xsl:output method="xml" indent="yes"/>
        
        {
            let $resulttemplate :=
                for $template at $step in $rootTemplate | $templates
                let $tmpname := concat(if ($template/@name) then $template/@name else 'no-name', '-', replace(data($template/@effectiveDate),'[-T:]',''))
                let $r := <p> { local:getParametersFromElementIds($template, '', 1) } </p>
                return (
                    (:$templates[@id='2.16.840.1.113883.2.4.6.10.90.900624'][@effectiveDate='2013-03-20T00:00:00']
                    ,:)
                    <xsl:template name="{$tmpname}">
                    {
                        comment {concat('Template: ', $template/@name, ' effectiveDate=' , $template/@effectiveDate,' (ID=',$template/@id,')')}
                    }
                    {
                        
                        for $rr at $stepr in $r//param
                        let $man := if (string($rr/@isMandatory)="true") then "M" else ""
                        let $pname := $rr/@name
                        let $duplicate := if ($rr is ($r//param[@name=$pname])[. = $rr][1]) then false() else true()
                        let $pathcomment :=  comment { concat(" Path: ", $tmpname, "::", $rr/@xpath, " ", 
                                                $rr/@minimumMultiplicity, "..", $rr/@maximumMultiplicity, " ",
                                                $rr/@conformance, " ", $man, " * Type: ", $rr/@datatype) 
                                              } 
                        return
                            if ($duplicate=true()) then comment {
                                    concat("WARNING :: DUPLICATE PARAMETER - PELASE CORRECT BY HAND :: ", $pname, ' ', $pathcomment)
                                } else
                                    <xsl:param name="{$pname}">
                                    {
                                        $pathcomment
                                    }
                                    {
                                        for $oc in $template/staticAssociations/origconcept[@elementId=$rr/@id]
                                        let $baseId := string-join(tokenize($oc/@ref,'\.')[position()!=last()], '.')
                                        let $concid := tokenize($oc/@ref,'\.')[last()]
                                        let $concprefix := $decor//baseId[@id=$baseId]/@prefix
                                        return comment { concat(" Concept ", $concprefix, $concid, " :: ", $oc/concept/name[1], " (ID=", $oc/@ref, ")" ) }
                                    }
                                    </xsl:param>
                    }
                    {
                        <importcontainedparameter/>
                    }
                    <xsl:text>&#xa;</xsl:text><xsl:comment>{concat('Template: ', $template/@name, ' effectiveDate=' , $template/@effectiveDate,' (ID=',$template/@id,')')}</xsl:comment><xsl:text>&#xa;</xsl:text>
                    {
                        if (not($template))
                        then local:reportError('Template not found', 3)
                        else 
                            for $el in $template/*
                            return local:copyTemplateNode($el, $templateAssociations)
                    }
                    </xsl:template>
                )
                
            return
                for $rr at $step in $resulttemplate
                return local:copyTemplateStylesheet($rr, $resulttemplate, 1)
        }

        <xsl:template match="text()|@*"/>

    </xsl:stylesheet>

let $summaryoftemplates :=
    <templates>
    {
        if (1=1) then 
            for $t at $step in $rootTemplate | $templates
            let $r := <p> { local:getParametersFromElementIds($t, '', 1) } </p>
            return 
                <template id="{$t/@id}" effectiveDate="{$t/@effectiveDate}" name="{$t/@name}" displayName="{$t/@displayName}">
                {
                    if ($step = 1) then attribute {"root"} {"true"} else ()
                }
                {
                                   
                    for $rr in ($r//param)
                    let $pname := $rr/@name
                    let $duplicate := if ($rr is ($r//param[@name=$pname])[. = $rr][1]) then false() else true()
                    return
                        <parameter name="{$rr/@name}" duplicate="{$duplicate}">
                        {
                            for $oc in $t/staticAssociations/origconcept[@elementId=$rr/@id]
                            let $baseId := string-join(tokenize($oc/@ref,'\.')[position()!=last()], '.')
                            let $concid := tokenize($oc/@ref,'\.')[last()]
                            let $concprefix := $decor//baseId[@id=$baseId]/@prefix
                            return <concept base="{$concprefix}" lid="{$concid}" name="{$oc/concept/name[1]}" id="{$oc/@ref}"/>
                        }
                        </parameter>
                }
                </template>
        else ()
    }
    </templates>
    
let $main-stylesheet := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" 
                    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                    version="2.0">
        
        <!-- Main stylesheet, include templates to override imported templates -->
        
        <xsl:import href="http://art-decor.org/ADAR/rv/DECOR-DTr1.xsl"/>
        <xsl:import href="generated-xsl.xsl"/>
        <xsl:output method="xml" indent="yes"/>
    
        <xsl:template match="/">
            <hl7bericht>
                <xsl:call-template name="{$stylesheet/xsl:template[1]/@name}">
                {
                    for $pp at $step in $summaryoftemplates//parameter
                    let $tmpname := concat(if ($pp/parent::template/@name) then $pp/parent::template/@name else 'no-name', '-', replace(data($pp/parent::template/@effectiveDate),'[-T:]',''))
                    return
                        if ($pp/@duplicate=true()) then comment {
                                concat("WARNING :: DUPLICATE - PELASE CORRECT BY HAND :: ", $pp/@name)
                            } else
                                <xsl:with-param name="{$pp/@name}" select="xxx_path_to_extract_xxx">
                                {
                                    comment {
                                        concat("Template :: ", $tmpname)
                                    }
                                }
                                {
                                    for $cc in $pp/concept
                                    (:group $cc as $cname by $cc/@name as $cn:)
                                    group by $cn := $cc/@name
                                    return comment {
                                        $cn
                                    }
                                }
                                </xsl:with-param>
                }
                </xsl:call-template>
            </hl7bericht>
        </xsl:template>
        
    </xsl:stylesheet>

let $overallresult :=
    <result>
        <root>
        {
            if (1=1) then 
                for $t in $summaryoftemplates/template[@root='true']
                return $t
            else ()
        }
        </root>
        <referencedtemplates>
        {
            if (1=1) then
                for $t in $summaryoftemplates/template[not(@root='true')]
                return $t
            else ()
        }
        </referencedtemplates>
        <mainstylesheet>
        {
            if (1=1) then $main-stylesheet else ()
        }
        </mainstylesheet>
        <stylesheet>
        {
            if (1=1) then $stylesheet else ()
        }
        </stylesheet>
    </result>

let $title := if ($stylesheet/xsl:template[1]/@name) then $stylesheet/xsl:template[1]/@name else "Error"
let $html :=
    <html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>{string($title)}</title>
       <link href="{$resourcePath}/css/default.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
    {
        if (count($overallresult//error[@severity>2])>0) then (
            <h1>
            {
                 "Template based XSL for Instance Creation: Error"
            }
            </h1>,
            <div class="content">
            {
                <ul>
                {
                    for $e in $overallresult//error[@severity>2]
                    return <li>{string($e)}</li>
                }
                </ul>
            }
            </div>
            
        ) else (
            <h1>
            {
                concat("Template based XSL for Instance Creation for template ", $id, if (string-length($effectiveDate)>0) then ' as of ' else ' (dynamic) ', $effectiveDate)
            }
            </h1>,
            <div class="content">
            
                <div>
                    <table cellpadding="2">
                        {
                            for $ot in $overallresult/root | $overallresult/referencedtemplates
                            return (
                            
                                if ($ot/self::root) then
                                    <tr>{<td colspan="4"><h2>Root Template Overview</h2></td>}</tr>
                                else if ($ot/self::referencedtemplates and count($overallresult/referencedtemplates/template)=0) then
                                    <tr>{<td colspan="4"><h2>No Referenced Templates</h2></td>}</tr>
                                else if ($ot/self::referencedtemplates and count($overallresult/referencedtemplates/template)>0) then
                                    <tr>{<td colspan="4"><h2>Referenced Templates Overview</h2></td>}</tr>
                                else (),
    
                                if (count($ot/template)>0) then
                                    <tr>{<th>Name</th>,<th>Display Name</th>,<th>Id</th>,<th>Effective Date</th>}</tr>
                                else (),
                                
                                for $t in $ot/template
                                return (
                                    <tr>{<td colspan="4"><hr/></td>}</tr>,
                                    <tr>
                                    {
                                        <td valign="top" rowspan="2">
                                        <a href="{$xqueryname}?id={$t/@id}&amp;effectiveDate={$t/@effectiveDate}&amp;prefix={$prefix}&amp;format=html">
                                        <strong>{string($t/@name)}</strong></a><br/>
                                            <a href="{$xqueryname}?id={$t/@id}&amp;effectiveDate={$t/@effectiveDate}&amp;prefix={$prefix}&amp;format=xsl">
                                            <img src="resources/images/file.png"/>
                                            <font color="green"><strong> XSL</strong></font>_download</a></td>,
                                        <td valign="top">{string($t/@displayName)}</td>,
                                        <td valign="top">{string($t/@id)}</td>,
                                        <td valign="top">{string($t/@effectiveDate)}</td>
                                    }
                                    </tr>,
                                    if ($t//parameter) then
                                        <tr>
                                        {
                                            <th>Element-ID</th>,
                                            <th colspan="2">Data element references</th>
                                        }
                                        </tr>
                                    else (),
                                    for $p in $t//parameter
                                    return
                                        <tr>
                                        {
                                            <td/>,
                                            <td valign="top">
                                                {
                                                    string($p/@name)
                                                }
                                                {
                                                    if ($p/@duplicate=true()) then (<br/>, <i> +++ Duplicate parameter, please correct by hand </i>)
                                                    else ''
                                                }
                                            </td>,
                                            <td colspan="2">
                                            {
                                                <ul>
                                                {
                                                    for $c in $p/concept
                                                    return ( 
                                                        <li>{concat($c/@base, $c/@lid, " :: ", $c/@name, " (ID=", $c/@id, ")")}</li>
                                                    )
                                                }
                                                </ul>
                                            }
                                            </td>
                                        }
                                        </tr>
                                    )
                             )
                         }
                         {
                            <tr>{<td colspan="4"><h2>Main XSL Example</h2></td>}</tr>
                         }
                         {
                            <tr>{<td colspan="4"><a href="{$xqueryname}?id={$id}&amp;effectiveDate={$effectiveDate}&amp;prefix={$prefix}&amp;format=mainxsl">
                            <img src="resources/images/file.png"/>
                            <font color="green"><strong> XSL</strong></font>_download</a></td>}</tr>
                         }
                         {
                            if (count($overallresult//error[@severity<3])>0) then (
                                <tr>{<td colspan="4"><h2>Error/Warnings</h2></td>}</tr>,
                                <tr>
                                {
                                    <td colspan="4">
                                    {
                                        <ul>
                                        {
                                            for $e in $overallresult//error[@severity<3]
                                                return <li>{string($e)}</li>
                                        }
                                        </ul>
                                    }
                                    </td>
                                 }
                                 </tr>
                             ) else ()
                          }
                    </table>
                </div>
            </div>
         )
    }
    </body>
    </html>

return 
    if ($format = 'mainxsl') then (
        response:set-header('Content-Type','text/xsl; charset=utf-8'),
        response:set-header('Content-Disposition', 'attachment; filename=mainxsl.xsl'),
        $overallresult/mainstylesheet/*
    ) else if ($format = 'xsl') then (
        response:set-header('Content-Type','text/xsl; charset=utf-8'),
        response:set-header('Content-Disposition', 'attachment; filename=generated-xsl.xsl'),
        $overallresult/stylesheet/*
    ) else if ($format = 'origxml') then (
        response:set-header('Content-Type','text/xml; charset=utf-8'),
        $overallresult
    ) else (
        response:set-status-code(200), 
        response:set-header('Content-Type','text/html; charset=utf-8'),
        $html
    )
