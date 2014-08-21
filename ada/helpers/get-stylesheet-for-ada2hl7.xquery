xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket, Marc de Graauw

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

declare namespace datetime="http://exist-db.org/xquery/datetime";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace hl7="urn:hl7-org:v3";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace xdb="http://exist-db.org/xquery/xmldb";

(: TODO: namespaces from decor file are to be used from input :)
declare namespace peri="urn:nictiz-nl:v3/peri";
declare namespace lab="urn:oid:2.16.840.1.113883.2.4.6.10.35.81";

import module namespace ada ="http://art-decor.org/ns/ada-common" at "../../ada/modules/ada-common.xqm";
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "../../art/modules/art-decor.xqm";
import module namespace artx ="http://art-decor.org/ns/art/xpath" at  "../../art/modules/art-decor-xpath.xqm";

declare copy-namespaces no-preserve, inherit;

declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

declare variable $debug          := true();
declare variable $quote          := "&#39;";
declare variable $accolade-open  := "&#123;";
declare variable $accolade-close := "&#125;";
declare variable $ampersand      := "&#38;";
declare variable $newline        := "&#10;";

declare variable $warning        := concat("Generated code (v0.8) at ", datetime:format-dateTime(current-dateTime(), "yyyy-MM-dd HH:mm:ss z"), " *** do not make any changes here, do regenerate (xquery)");

declare variable $xqueryname     := "Template2XSL";

declare function local:reportError($error as xs:string, $severity as xs:integer) as element() {
    for $i in 1 to 1
    return <xsl:comment><error severity="{$severity}">{$error}</error></xsl:comment>
};

declare function local:getNameWithoutPredicate($name as xs:string) as xs:string {
    if (contains($name,'[')) then substring-before($name,'[') else $name
};

(:
    Get the right template from a collection of templates. Parameters
    templateRef - Name or Id of the template
    templateEffectiveDate - EffectiveDate (static reference), 'dynamic' or empty (both point to the 'newest' version)
    templates - collection of templates to choose from
:)
declare function local:getTemplate($templateRef as attribute(), $templateEffectiveDate as xs:string?, $templates as element()*) as element()? {
    if (matches(data($templateEffectiveDate),'^\d{4}')) then (
        $templates[@id=$templateRef or @name=$templateRef][@effectiveDate=$templateEffectiveDate]
    )
    else (
        $templates[@id=$templateRef or @name=$templateRef][@effectiveDate=string(max($templates[@id=$templateRef or @name=$templateRef]/xs:dateTime(@effectiveDate)))]
    )
};

declare function local:getTemplateChain($node as element(), $chain-so-far as xs:string,$templates as element()*) as element()* {
let $r :=
    if ($node/(@contains|@ref)) then (
        let $template := local:getTemplate ($node/(@contains|@ref), $node/@flexibility,$templates)
        return
            if (not(contains($chain-so-far,concat($template/@id,'-',$template/@effectiveDate)))) then (
                $template,
                for $node in $template//(element[@contains]|include)
                return
                    local:getTemplateChain($node, concat($chain-so-far,' ',$template/@id,'-',$template/@effectiveDate), $templates)
            ) else ()
    ) else ()
    
return $r

};

declare function local:xslTemplateName($template as element()) as xs:string {
    let $name := concat($template/@name, '-', replace(data($template/@effectiveDate),'[-T:]',''))
    return $name
};

declare function local:copyTemplateNode($node as element()*, $templates as element()*, $templateAssociations as element()*) as node()* {
    (:
    instance generator, recursively walks through templates
    :)
    (: check for errors :)
    if (empty($node)) 
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
                local:copyTemplateNode($child, $templates, $templateAssociations)
        ) else (
            local:reportError(concat('No handling yet for element ', name($node)), 2)
        )
        (:for $el in $node/* return local:copyTemplateNode($el, $templates, $templateAssociations):)
    
    (: for includes, only process included template :)
    else if (name($node)='include') 
    then
        let $template := local:getTemplate($node/@ref, $node/@flexibility, $templates)
        let $select   := local:associatedConceptsForTemplate($node/@ref, $node/@flexibility, $templates, $templateAssociations)
        let $maximumMultiplicity := 
            if ($node[@maximumMultiplicity]) then xs:string($node/@maximumMultiplicity)
            else if ($template/element[1][@maximumMultiplicity]) then xs:string($template/element[1]/@maximumMultiplicity)
            else 'undefined'
        let $minimumMultiplicity := 
            if ($node[@minimumMultiplicity]) then xs:string($node/@minimumMultiplicity)
            else if ($template/element[1][@minimumMultiplicity]) then xs:string($template/element[1]/@minimumMultiplicity)
            else 'undefined'
        return (
            local:processTemplateAttributes($template),
            if ($select = 'no-associated-concepts-for-template')
            then (
                (: if there are no associatied concepts, and 
                    minimumMultiplicity = 0, skip the thing,
                    else if maximumMultiplicity = 1, call it for fixed text / values
                    else report an error
                :)
                if ($minimumMultiplicity = '0')
                then <xsl:comment>{concat('Skipped ', $node/@ref,' ',$node/@flexibility, '(', $minimumMultiplicity, '..', $maximumMultiplicity, ') which has no associated concepts')}</xsl:comment>
                else if ($maximumMultiplicity = '1') 
                then <xsl:call-template name="{local:xslTemplateName($template)}"/>
                else local:reportError(concat('template ', $node/@ref,' ',$node/@flexibility, ' is contained with maximumMultiplicity=', $maximumMultiplicity,' , and minimumMultiplicity=', $minimumMultiplicity,', but has no associated concepts'), 3)
            )
            else if ($maximumMultiplicity = 'undefined')
            then local:reportError(concat('MaximumMultiplicity is undefined for include ', $node/@ref), 3)
            else if ($maximumMultiplicity = '1')
            then
                <xsl:if test="{$select}">
                    <xsl:call-template name="{local:xslTemplateName($template)}"/>
                </xsl:if>
            else 
                <xsl:for-each select="{$select}">
                    <xsl:call-template name="{local:xslTemplateName($template)}"/>
                </xsl:for-each>
        )
    (: process <element> child :)
    else if (name($node)='element') 
    then
        (: for contains, process element once for each concept, call template, process children :)
        if ($node[@contains])
        then (
            let $template := local:getTemplate($node/@contains, $node/@flexibility, $templates)
            let $select   := local:associatedConceptsForTemplate($node/@contains, $node/@flexibility, $templates, $templateAssociations)
            return 
            if ($select = 'no-associated-concepts-for-template')
            then (
                (: check if maximumMultiplicity > 1 ? then would need for-each and associated concept:)
                if ($node[@maximumMultiplicity='*'])
                then (<xsl:comment>{concat('template ', $node/@contains,' ',$node/@flexibility, ' is contained with maximumMultiplicity=*, but has no associated concepts')}</xsl:comment>)
                else (),
                element {local:getNameWithoutPredicate($node/@name)} {
                    local:processTemplateAttributes($node),
                    <xsl:call-template name="{local:xslTemplateName($template)}"/>
                }
            )
            else
                <xsl:if test="{$select}">
                    {element {local:getNameWithoutPredicate($node/@name)} {
                        local:processTemplateAttributes($node),
                        <xsl:call-template name="{local:xslTemplateName($template)}"/>}
                     }
                </xsl:if>
        )
        else if ($node[@id]) then (
            let $select   := local:associatedConceptsForElementId($node/ancestor::template, $node/@id, $templateAssociations)
            return
                if ($select = 'no-associated-concepts-for-element')
                then (
                    local:processTemplateElement($node, $templates, $templateAssociations)
                )
                else (
                    <xsl:for-each select="{$select}">
                    {
                        local:processTemplateElement($node, $templates, $templateAssociations)
                    }
                    </xsl:for-each>
                )
        )
        (: if no contains att, process element :)
        else (
            local:processTemplateElement($node, $templates, $templateAssociations)
        )
    
    (: else: output error and element as is, do process children :) 
    else (
        local:reportError(concat('Unprocessed element ', name($node)), 2), 
        element {name($node)} {
            $node/@*, for $el in $node/* return local:copyTemplateNode($el, $templates, $templateAssociations)
        }
    )
};

declare function local:processTemplateElement($node as element(), $templates as element()*, $templateAssociations as element()*) as node()* {
    (:  input:  '<element>' node from template
                sequence of relevant templates
        output: sequence of nodes (mostly elements, but may contain comments)
    :)
    
    (: element/@name may contain predicates (name='X[Y]'), omit predicate :)
    if ($node[descendant-or-self::element/@id or number(@minimumMultiplicity)>0 or not(string(@isMandatory)='false')]) then ( 
        let $element :=
            (
                if ($debug) then (
                <xsl:text>&#xa;</xsl:text>,
                <xsl:comment>{concat('HL7: ', $node/@name, ' datatype: ', $node/@datatype, ' elementId: ', $node/@id)}</xsl:comment>,
                <xsl:text>&#xa;</xsl:text>,
                if ($node/@id) 
                then (<xsl:comment>Concept: <xsl:value-of select="local-name(.)"/>, conceptId: <xsl:value-of select="./@conceptId/string()"/>, value: <xsl:value-of select="./@value/string()"/></xsl:comment>, <xsl:text>&#xa;</xsl:text>)
                else ()
                ) else (),
                element {local:getNameWithoutPredicate($node/@name)} {
                    local:processTemplateAttributes($node), 
                    (: TODO: handle multiple element/@id in same template :)
                    (: process datatypes :)
                    if ($node[@datatype]) 
                    then local:processDatatype($node,$templateAssociations)
                    else (),
                    (:  process children, omit 'attribute' , 'vocabulary' and 'property' child nodes,
                        they have already been handled in datatype or attribute processing :)
                    for $el in $node/*[local-name()!='attribute'][local-name()!='vocabulary'][local-name()!='property']
                    return local:copyTemplateNode($el, $templates, $templateAssociations)
                }
            )
        return
            if ($node[@datatype]) then (
                <xsl:variable name="node">{$element}</xsl:variable>,
                <xsl:if test="{exists($node[number(@minimumMultiplicity)>0 or string(@isMandatory)='true'])}() or $node/*[not(@nullFlavor)]">
                    <xsl:copy-of select="$node"/>
                </xsl:if>
            )
            else ($element)
    ) else local:reportError(concat('unhandled element :', data($node/@name)), 3)
};

declare function local:processDatatype($node as element(), $templateAssociations as element()*) as node()* {
    (:  input: <element> node which has @datatype
        output: call-template statement for datatype, with appropriate params
    :)
    let $tempAssocArray := $templateAssociations[@templateId=$node/ancestor::template/@id][@effectiveDate=$node/ancestor::template/@effectiveDate]/concept/@elementId
    let $datatype       := if ($node/@datatype='SD.TEXT') then $node/@datatype/string() else tokenize($node/@datatype/string(),'\.')[1]
    return
    <xsl:call-template name="{$datatype}">
        {   
            if ($node/attribute[@name='xsi:type'][not(string(@isOptional)='true')] 
                or $node[$datatype=('BL', 'CS', 'CD','CE','CV','CO', 'PQ')]
            ) then (
                <!-- xsi:type -->,
                <xsl:with-param name="xsiType" select="'{concat('hl7:', $datatype)}'"/>
            ) else ()
        }
        {   
            (: note: does not support attribute with vocabulary element. not common but possible... :)
            <!-- nullFlavor -->,
            if ($node/attribute[@name='nullFlavor'][@value][not(string(@isOptional)='true') or parent::*[number(@minimumMultiplicity)>0]]) then (
                <xsl:with-param name="nullFlavor" select="'{data(($node/attribute[@name='nullFlavor']/@value)[1])}'"/>
            )
            else if ($node/attribute[@nullFlavor][not(string(@isOptional)='true') or parent::*[number(@minimumMultiplicity)>0]]) then (
                <xsl:with-param name="nullFlavor" select="'{data(($node/attribute/@nullFlavor)[1])}'"/>
            )
            else if (string($node/@isMandatory)!="true" and $node/@id) then (
                 <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
            )
            else ()
        }
        {
        (: handle params for element with elementId in $tempAssocArray (list of associated concepts) :)
        if ($node[@id=$tempAssocArray]) then 
        (
                if ($node[$datatype='CS']) then (
                    <!-- datatype CS -->,
                    <xsl:with-param name="code" select="@code"/>
                
                )
                else if ($node[$datatype=('CD','CE','CV','CO')]) then (
                    <!-- datatype CD / CE / CV / CO -->,
                    <xsl:with-param name="code" select="@code"/>,
                    <xsl:with-param name="codeSystem" select="@codeSystem"/>,
                    <xsl:with-param name="displayName" select="@displayName"/>,
                    <xsl:with-param name="codeSystemName" select="@codeSystemName"/>,
                    <xsl:with-param name="codeSystemVersion" select="@codeSystemVersion"/>
                )
                else if ($node[$datatype=('SC')]) then (
                    <!-- datatype SC -->,
                    <xsl:with-param name="code" select="@code"/>,
                    <xsl:with-param name="codeSystem" select="@codeSystem"/>,
                    <xsl:with-param name="displayName" select="@displayName"/>,
                    <xsl:with-param name="codeSystemName" select="@codeSystemName"/>,
                    <xsl:with-param name="codeSystemVersion" select="@codeSystemVersion"/>,
                    <xsl:with-param name="text" select="@value"/>
                )
                
                else if ($node[$datatype=('II')]) then (
                    <!-- datatype II -->,
                    <xsl:with-param name="root">
                        <xsl:choose>
                            <xsl:when test="@root">
                                <xsl:value-of select="@root"/>
                            </xsl:when>
                            <xsl:otherwise>{
                                if ($node/attribute[@root]) then
                                    data(($node/attribute/@root)[1])
                                else if ($node/attribute[@name='root']) then
                                    data(($node/attribute[@name='root']/@value)[1])
                                else ()
                            }</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>,
                    <xsl:with-param name="extension" select="@value"/>
                
                )
                else if ($node[$datatype=('BL','BN','INT','ON','TN','TS')]) then (
                    <!-- datatype 'BL','BN','INT','ON','TN','TS' -->,
                    <xsl:with-param name="value" select="@value"/> 
                    
                )
                else if ($node[$datatype=('MO')]) then (
                    <!-- datatype MO -->,
                    (: note that datatype MO has @currency rather than @unit. Handled in DECOR_DTr1.xsl :)
                    <xsl:with-param name="value" select="@value"/>,
                    (: take unit from instance if provided, else from template :)
                    <xsl:with-param name="unit">
                        <xsl:choose>
                            <xsl:when test="@unit">
                                <xsl:value-of select="@unit"/>
                            </xsl:when>
                            <xsl:otherwise>{
                                if ($node/property[@currency]) then
                                    tokenize(($node/property/@currency)[1],'\|')[1]
                                else if ($node/attribute[@currency]) then
                                    tokenize(($node/attribute/@currency)[1],'\|')[1]
                                else if ($node/attribute[@name='currency']) then
                                    tokenize(($node/attribute[@name='currency']/@value)[1],'\|')[1]
                                else ()
                            }</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                
                )
                else if ($node[$datatype=('PQ')]) then (
                    <!-- datatype PQ -->,
                    <xsl:with-param name="value" select="@value"/>,
                    (: take unit from instance if provided, else from template :)
                    <xsl:with-param name="unit">
                        <xsl:choose>
                            <xsl:when test="@unit">
                                <xsl:value-of select="@unit"/>
                            </xsl:when>
                            <xsl:otherwise>{
                                if ($node/property[@unit]) then
                                    tokenize(($node/property/@unit)[1],'\|')[1]
                                else if ($node/attribute[@unit]) then
                                    tokenize(($node/attribute/@unit)[1],'\|')[1]
                                else if ($node/attribute[@name='unit']) then
                                    tokenize(($node/attribute[@name='unit']/@value)[1],'\|')[1]
                                else ()
                            }</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                
                )
                else if ($node[starts-with($datatype,'IVL')]) then (
                    <!-- datatype IVL -->,
                    (: TODO handle [@id] based logic for composite element :)
                    comment {'Missing support for the correct parameters with this datatype.'}
                    
                )
                else if ($node[starts-with($datatype,'RTO')]) then (
                    <!-- datatype RTO -->,
                    (: TODO handle [@id] based logic for composite element :)
                    comment {'Missing support for the correct parameters with this datatype.'}
                    
                )
                else if ($node[$datatype=('AD')]) then (
                    <!-- datatype AD -->,
                    (: TODO handle [@id] based logic for composite element :)
                    <xsl:with-param name="value" select="@value"/>
                
                )
                else if ($node[$datatype=('ADXP')]) then (
                    <!-- datatype ADXP -->,
                    <xsl:with-param name="value" select="@value"/>
                
                )
                else if ($node[$datatype=('EN','PN')]) then (
                    <!-- datatype EN, PN -->,
                    (: TODO handle [@id] based logic for composite element :)
                    <xsl:with-param name="value" select="@value"/>
                
                )
                else if ($node[$datatype=('ENXP')]) then (
                    <!-- datatype ENXP -->,
                    <xsl:with-param name="value" select="@value"/>,
                    <xsl:with-param name="qualifier" select="@qualifier"/>
                
                )
                else if ($node[$datatype=('ED')]) then (
                    <!-- datatype ED -->,
                    (: TODO handle [@id] based logic for composite element :)
                    <xsl:with-param name="mediaType" select="@mediaType"/>,
                    <xsl:with-param name="representation" select="@representation"/>,
                    <xsl:with-param name="compression" select="@compression"/>,
                    <xsl:with-param name="charset" select="@charset"/>,
                    <xsl:with-param name="language" select="@language"/>,
                    <xsl:with-param name="text" select="@text"/>
                
                )
                else if ($node[$datatype=('ST')]) then (
                    <!-- datatype ST -->,
                    <xsl:with-param name="text" select="@value"/>
                )
                else if ($node[$datatype=('TEL')]) then (
                    <!-- datatype TEL -->,
                    (: TODO handle [@id] based logic for composite element (useablePeriod) :)
                    <xsl:with-param name="value" select="@value"/>,
                    <xsl:with-param name="use">
                        <xsl:choose>
                            <xsl:when test="@use">
                                <xsl:value-of select="@use"/>
                            </xsl:when>
                            <xsl:otherwise>{
                                if ($node/attribute[@use]) then
                                    data(($node/attribute/@use)[1])
                                else if ($node/attribute[@name='use']) then
                                    data(($node/attribute[@name='use']/@value)[1])
                                else ()
                            }</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                )
                else if ($node[$datatype=('URL')]) then (
                    <!-- datatype URL -->,
                    <xsl:with-param name="value" select="@value"/>
                
                )
                else (
                    <!-- unsupported datatype -->,
                    comment {'Missing support for the correct parameters with this datatype. Defaulting to "value". Datatype found: ',$datatype},
                    <xsl:with-param name="value" select="@value"/>
                )
            )
            (: here we get to the elements which do not have an elementId which occurs in $tempAssocArray :)
            else (
                (:exclude nullFlavor and xsi:type as they are handled above:)
                for $attr in $node/(attribute[not(string(@isOptional)='true')]|property)/(@root|@extension|@unit|@currency|@mediaType|@representation|@qualifier|@use|@operator)
                return (
                    <!-- unassociated elementId, not optional, shorthand notation for attributes -->,
                    <xsl:with-param name="{name($attr)}">
                        <xsl:choose>
                            <xsl:when test="@{name($attr)}">
                                <xsl:value-of select="@{name($attr)}"/>
                            </xsl:when>
                            <xsl:otherwise>{tokenize($attr/string(),'\|')[1]}</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                ),
                for $attr in $node/attribute[not(string(@isOptional)='true')][@name[not(.=('nullFlavor','xsi:type'))]][@value]
                return (
                    <!-- unassociated elementId, not optional, @name/@value notation for attributes -->,
                    <xsl:with-param name="{$attr/@name/string()}">
                        <xsl:choose>
                            <xsl:when test="@{$attr/@name/string()}">
                                <xsl:value-of select="@{$attr/@name/string()}"/>
                            </xsl:when>
                            <xsl:otherwise>{tokenize($attr/@value,'\|')[1]}</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                ),
                if (($node/vocabulary[@code][@codeSystem])[1]) then (
                    <!-- unassociated elementId, vocabulary with codeSystem -->,
                    <xsl:with-param name="code" select="'{data(($node/vocabulary[@code][@codeSystem])[1]/@code)}'"/>,
                    <xsl:with-param name="codeSystem" select="'{data(($node/vocabulary[@code][@codeSystem])[1]/@codeSystem)}'"/>,
                    <xsl:with-param name="displayName" select="'{data(($node/vocabulary[@code][@codeSystem])[1]/@displayName)}'"/>,
                    <xsl:with-param name="codeSystemName" select="'{data(($node/vocabulary[@code][@codeSystem])[1]/@codeSystemName)}'"/>,
                    <xsl:with-param name="codeSystemVersion" select="'{data(($node/vocabulary[@code][@codeSystem])[1]/@codeSystemVersion)}'"/>
                ) else if (($node/vocabulary[@code])[1]) then (
                    <!-- unassociated elementId, vocabulary without codeSystem -->,
                    <xsl:with-param name="code" select="'{data(($node/vocabulary[@code])[1]/@code)}'"/>
                ) else (),
                if ($node[text]) then (
                    <!-- unassociated elementId, fixed text -->,
                    <xsl:with-param name="text" select="'{data($node/text)}'"/>
                ) 
                else (
                    <!-- no associated elementId, catchall, element not handled -->
                )
            )
        }
    </xsl:call-template>
};

declare function local:associatedConceptsForTemplate($templateRef as attribute(), $templateEffectiveDate as xs:string?, $templates as element()*, $templateAssociations as element()*) as xs:string {
    (:  input: some template ref 
        output: xpath string which selects all concepts from current node down which are
                associated with input template in a templateAssociation

        select all templates which match id or name in $templateRef
        check whether template exists, and whether it's called for any concepts
    :)
    let $template := local:getTemplate($templateRef,$templateEffectiveDate,$templates)
    
    let $select   := 
        for $concept at $step in $templateAssociations[@templateId=$template/@id][@effectiveDate=$template/@effectiveDate]/concept
        (: does not work for some reason: where $template//element[@id=$concept/@elementId][not(ancestor::element[@id])]:)
        return (
            concat(if ($step=1) then '' else '| ', 'descendant-or-self::*[@conceptId=', $quote, $concept/@ref, $quote,']')
        )
    return
        if (not($template/@id)) 
        then concat('no-template-for-ref-', xs:string($templateRef),'-', replace($templateEffectiveDate,'[-T:]',''))
        else if (empty($select)) 
        then ('no-associated-concepts-for-template')
        else string-join($select,' ')
};

declare function local:associatedConceptsForElementId($template, $elementId as xs:string, $templateAssociations as element()*) as xs:string {
    (:  input: template, elementId 
        output: xpath string which selects all concepts from current node down which are
                associated with input template in a templateAssociation

        select all templates which match id or name in $templateRef
        check whether template exists, and whether it's called for any concepts
    :)
    let $select   := 
        for $concept at $step in $templateAssociations[@templateId=$template/@id][@effectiveDate=$template/@effectiveDate]/concept[@elementId=$elementId]
        return concat(if ($step=1) then '' else '| ', 'descendant-or-self::*[@conceptId=', $quote, $concept/@ref, $quote,']')
    return
        if (empty($select)) 
        then ('no-associated-concepts-for-element')
        else string-join($select,' ')
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
    if ($node/property[@unit]) then (
        ($node/property/@unit)[1]
    ) else (),
    if ($node/property[@currency]) then (
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

(: main proc :)

(: parameters :)
let $projectPrefix := if (request:exists()) then request:get-parameter('prefix','') else 'peri20-'
let $transactionId := if (request:exists()) then request:get-parameter('id','') else '2.16.840.1.113883.2.4.3.11.60.90.77.4.2404' 
let $versionDate   := if (request:exists()) then request:get-parameter('versionDate','') else 'development' 

(: get local data collection :)
let $collection    := $get:colDecorVersion
(: get DECOR project :)
let $decor         := $collection//decor[@versionDate=$versionDate][project[@prefix=$projectPrefix]]

(: transaction is not versionable currently, so get latest scenario that contains our transaction:)
let $scenarioEffectiveDate:= string(max($decor//scenarios[parent::decor]/scenario[.//transaction[@id=$transactionId]]/xs:dateTime(@effectiveDate)))
let $scenario             := $decor//scenarios[parent::decor]/scenario[@effectiveDate=$scenarioEffectiveDate][.//transaction[@id=$transactionId]]
let $transaction          := $scenario//transaction[@id=$transactionId]
let $initialTemplate      := local:getTemplate($transaction/representingTemplate/@ref, $transaction/representingTemplate/@flexibility, $decor//rules/template)

(: representingTemplate of our transaction points us to the first. Get template chain from there 
  by following includes and contains. This avoid having to create a transform for every template:)
let $templates            := 
    let $listWithDuplicates :=
        for $node in $initialTemplate//(element[@contains]|include)
        return
            local:getTemplateChain($node, concat($initialTemplate/@id,'-',$initialTemplate/@effectiveDate), $decor//rules/template)
     return
        for $node in $listWithDuplicates|$initialTemplate
        let $dupkey := concat($node/@id,'-',$node/@effectiveDate)
        order by $dupkey
        return
            $node[1]

(:cache all templateAssociation elements. We'll attach them as appropriate:)
let $templateAssociations := $collection//templateAssociation

let $errors := <errors/>
    
let $stylesheet :=
    if (count($errors/*)>0) then
        $errors
    else
    <xsl:stylesheet 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:hl7="urn:hl7-org:v3" 
        xmlns:xs="http://www.w3.org/2001/XMLSchema" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    {
        comment {$warning}
    }
    <!--xsl:import href="../../../decor/core/DECOR-DTr1.xsl"/-->
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
    {
        (: call template corresponding to representingTemplate/@ref for each transaction :)
        for $transaction in $collection//transaction[not(@type='group')][@id=$transactionId]
        let $template := local:getTemplate($transaction/representingTemplate/@ref,$transaction/representingTemplate/@flexibility,$templates)
        return 
            if ($template/@name) then 
                <xsl:for-each select="//*[@transactionRef='{$transaction/@id/string()}'][last()]">
                    <xsl:call-template name="{local:xslTemplateName($template)}"/>
                </xsl:for-each>
            else ()
    }
    </xsl:template>
    
    {for $template in $templates
    return  
    (
    comment {concat('Template: ', $template/@name, ' effectiveDate=' , $template/@effectiveDate,' (ID=',$template/@id,')')},
    <xsl:template name="{if ($template/@name) then $template/@name else 'no-name'}-{replace(data($template/@effectiveDate),'[-T:]','')}">
        {
            if ($debug) then (
            <xsl:text>&#xa;</xsl:text>,
            <xsl:comment>{concat('Template: ', $template/@name, ' effectiveDate=' , $template/@effectiveDate,' (ID=',$template/@id,')')}</xsl:comment>,
            <xsl:text>&#xa;</xsl:text>
            ) else ()
        }
        {
            if (not($template)) 
            then local:reportError('Template not found', 3)
            else for $el in $template/* return local:copyTemplateNode($el, $templates, $templateAssociations)
        }
    </xsl:template>
    )}

    <xsl:template match="text()|@*"/>

</xsl:stylesheet>

let $main-stylesheet := 
    <xsl:stylesheet 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:hl7="urn:hl7-org:v3" 
        xmlns:xs="http://www.w3.org/2001/XMLSchema" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
        
        <!-- Main stylesheet, include templates to override imported templates -->
        
        <xsl:import href="http://art-decor.org/ADAR/rv/DECOR-DTr1.xsl"/>
        <xsl:import href="generated-templates.xsl"/>
        <xsl:output method="xml" indent="yes"/>

    </xsl:stylesheet>

let $runtimedir := ada:getUri($projectPrefix, 'xslt')
let $generated := xdb:store($runtimedir, 'generated-templates.xsl', $stylesheet) 
let $dummy := 
    if (not(doc-available(concat($runtimedir, '/main-templates.xsl')))) 
    then concat('created ', xdb:store($runtimedir, 'main-templates.xsl', $main-stylesheet))
    else ('main stylesheet already exists')

return 
    $stylesheet