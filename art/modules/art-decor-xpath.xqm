xquery version "1.0";
(:
	Author: Marc de Graauw, Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

module namespace artx       = "http://art-decor.org/ns/art/xpath";

declare namespace lab       = "urn:oid:2.16.840.1.113883.2.4.6.10.35.81";
declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace hl7       = "urn:hl7-org:v3";
declare namespace util      = "http://exist-db.org/xquery/util";
declare option exist:serialize "indent=no";
declare option exist:serialize "omit-xml-declaration=no";

declare function local:report($error as xs:string) as element() {
    element error {$error}
};

declare function artx:getXpathFromTemplate($node as element()*, $decor as element()*, $xpath as xs:string, $overrides as element()?, $representingTemplate as node()) as node()* {
    (:  input: some node, all templates and associated concepts, Xpath up to node
        output: if some template//element has @id, outputs all associated concepts with @ref, @effectiveDate, @elementId and xpath
    
        recursively walks through templates, resolving contains and includes and choices :)

    (: do elements and attributes :)
    let $xpath := 
        if (name($node) = 'template') then 
            (artx:getContextPath($node,$xpath))
        else if (name($node) = 'element') then 
            (concat($xpath, '/', $node/@name)) 
        else if (name($node) = 'attribute') then 
            (concat($xpath, '/@', $node/@name)) 
        else 
            ($xpath) 
    
    let $actualIsMandatory :=
        if ($overrides/@isMandatory) then
            $overrides/@isMandatory
        else if ((name($node) = 'element') and ($node/@isMandatory)) then
            ($node/@isMandatory)
        else attribute isMandatory {'false'}

    (: for mandatory elements, use 'M' :)
    let $actualConformance :=
        if ($actualIsMandatory = 'true') then attribute conformance {'M'} 
        else if ($overrides/@conformance) then
            $overrides/@conformance
        else if ((name($node) = 'element') and ($node/@conformance)) then
            ($node/@conformance)
        else attribute conformance {'O'}
    
    (: if nothing specified, then max=* :) 
    let $actualMaximumMultiplicity :=
        if ($overrides/@maximumMultiplicity) then
            $overrides/@maximumMultiplicity
        else if ((name($node) = 'element') and ($node/@maximumMultiplicity)) then
            ($node/@maximumMultiplicity)
        else attribute maximumMultiplicity {'*'}
    
    (: mandatory elements have min=1, if nothing specified, then min=0 :) 
    let $actualMinimumMultiplicity :=
        if ($actualIsMandatory = 'true') then attribute minimumMultiplicity {'1'} 
        else if ($overrides/@minimumMultiplicity) then
            $overrides/@minimumMultiplicity
        else if ((name($node) = 'element') and ($node/@minimumMultiplicity)) then
            ($node/@minimumMultiplicity)
        else attribute minimumMultiplicity {'0'}
    
    (: add root to xpath for id :)
    let $pred := if ($node[exists(attribute/@root) or attribute/@name='root']) then (
        for $attr in $node/attribute[exists(@root) or @name='root']
        return
            if ($attr/@root) then (concat("@root='", $attr/@root ,"'")) else (concat("@root='", $attr/@value ,"'"))
        ) else ('')
            
    let $xpath := if (string-length($pred[1])>0) then (concat($xpath,"[",string-join($pred,' or '),"]")) else ($xpath)

    (: add codesystem :)
    let $pred := if ($node[exists(vocabulary/@codeSystem)]) then (
        for $attr in $node/vocabulary[exists(@codeSystem)]
        return
            if ($attr/@code) then (concat("(@code='", $attr/@code ,"' and @codeSystem='", $attr/@codeSystem ,"')")) else (concat("@codeSystem='", $attr/@codeSystem ,"'"))
        ) else ('')
    
    let $xpath := if (string-length($pred[1])>0) then (concat($xpath,"[",string-join($pred,' or '),"]")) else ($xpath)
    
    let $xpath := 
        if ((name($node) = 'element')  and ($actualMaximumMultiplicity = '1')) 
        (: non-repeating group, we give it [1] so xpath makes clear it occurs only once :)
        then(concat($xpath, '[1]'))
        (: repeating group, has no [1]:)
        else $xpath
    
    (: do datatypes, output location of actual value for use in test condition :)
    let $valueLocation := 
        if (name($node) = 'element' and $node[@datatype])
        then 
            attribute valueLocation {
            if (($node/@datatype='PQ' or $node/@datatype='BL' or starts-with($node/@datatype, 'INT') or starts-with($node/@datatype, 'TS')))
                then '@value'
            else if (starts-with($node/@datatype, 'II'))
                then '@extension'
            (: are all datatypes starting with 'C' codes? :) 
            else if (starts-with($node/@datatype, 'C'))
                then '@code'
            else 
                ('.')
            }
        else 
            ()
    
    (: HL7 datatype :)
    let $hl7Type := 
        if (name($node) = 'element' and $node[@datatype])
        then $node/@datatype else ()

    (:  for include and @contains, pass on multiplicities, conformance, mandatory
        for templates, pass on again to element(s) :)
    let $overrides := 
        if ((name($node)='include') or ($node/@contains)) then
            <overrides>{$node/@*}</overrides>
        else $overrides

return
    if (name($node) = 'element' or name($node) = 'choice'  or name($node) = 'include' or name($node) = 'template')
    then 
    (: output the element :)
        element {name($node)} 
        (: with it's own attributes :)
        {$node/@*, 
        (: xpath so far, valueLocation if present :)
        attribute xpath {$xpath}, $valueLocation,
        (: for elements, associated concepts :)
        if (name($node) = 'element' and $node[@id]) 
        then 
            (
            (:element actualCardConf {$actualMinimumMultiplicity, $actualMaximumMultiplicity, $actualConformance, $actualIsMandatory},:)
            (: return a concept for every templateAssociation/concept which corresponds to this element/@id and occurs in representingTemplate being processed :)
            <associatedConcepts>{
                for $concept in $decor//templateAssociation[@templateId=$node/ancestor::template/@id][@effectiveDate=$node/ancestor::template/@effectiveDate]/concept[@elementId=$node/@id][@ref=$representingTemplate/concept/@ref] 
                return element concept {$concept/@ref, $concept/@effectiveDate}
            }</associatedConcepts>
            )
        else (),
        (: for includes, include template :)
        if (name($node)='include') 
        then <include>{$node/@*, artx:getXpathFromTemplate(artx:getSingleTemplate($decor, $node/@ref, if ($node/@flexibility) then $node/@flexibility else 'dynamic'), $decor, $xpath, $overrides, $representingTemplate)}</include>
        else (),
        (: ditto for contains :)
        if (name($node)='element' and $node/@contains) 
        then artx:getXpathFromTemplate(artx:getSingleTemplate($decor, $node/@contains, if ($node/@flexibility) then $node/@flexibility else 'dynamic'), $decor, $xpath, $overrides,$representingTemplate)
        else (),
        (: process the children :)
        for $el in $node/* return artx:getXpathFromTemplate($el, $decor, $xpath, (), $representingTemplate)
        }
    else ()
};

declare function artx:getXpaths($decor as element(), $representingTemplate as element()) as node() {
(:  input: $decor node, $representingTemplate id
    output: <xpaths> containing an <xpath> for each concept in transaction
:)  
    let $nl         := "&#10;"
    let $tab        := "&#9;"
    let $lang       := data($decor//project/@defaultLanguage)
    
    let $templateEd := 
        if ($representingTemplate[matches(@flexibility,'^\d{4}')]) then (
            (:starts with 4 digits, explicit dateTime:)
            $representingTemplate/@flexibility
        ) else (
            (:empty or dynamic:)
            string(max($decor//template[@id=$representingTemplate/@ref]/xs:dateTime(@effectiveDate)))
        )
    let $template   := $decor//template[@id=$representingTemplate/@ref][@effectiveDate=$templateEd]
    let $xpaths     := 
        if (not($template)) then 
            local:report(concat('Template not found: ', $representingTemplate))
        else 
            element {name($template)} {
                $template/@*, 
                for $el in $template/* 
                return artx:getXpathFromTemplate($el, $decor, artx:getContextPath($template, ''), (), $representingTemplate)
            }
    return 
    element {'transactionXpaths'} {
        (: copy atts from transaction :) 
        attribute ref {data($representingTemplate/../@id)},
        $representingTemplate/../@*[not(local-name()='id')],
        element {'templateWithXpaths'} {$xpaths}
        (:, 
        element {'representingTemplate'} {
            $representingTemplate/@*, 
            for $concept in $representingTemplate/concept 
            return (
                $nl, $tab, $tab, 
                if (not($xpaths//element[@conceptRef=$concept/@ref])) then 
                    $concept 
                else 
                    let $element := $xpaths//element[@conceptRef=$concept/@ref]
                    return 
                        element concept {
                            $element/@*,
                            attribute hl7Type {$element/@datatype}, 
                            element template {$element/ancestor::template[1]/@*} 
                        }
            )
        }:)
    }
};

declare function artx:getContextPath($template as node(), $xpath as xs:string) as xs:string {
(:  input:  template, xpath up to that template
    output: context path for template
:)
    (: Look if there's a templateId node which matches template/@id :)
    let $templateIdNode := $template//element[@name='hl7:templateId'][(attribute/@root=$template/@id) or (attribute[@name='root']/@value=$template/@id)]
    let $predContent := if ($templateIdNode[exists(attribute/@root) or attribute/@name='root']) then (
        for $attr in $templateIdNode/attribute[exists(@root) or @name='root']
        return
            if ($attr/@root) then (concat("@root='", $attr/@root ,"'")) else (concat("@root='", $attr/@value ,"'"))
        ) else ('')
    return
    (:  situation 1: template has <context id="*"/>
        - template must have template id
        - it does not have a fixed containing element (i.e. template's content may reside in element with any name :)
    if ($template/context[1][@id='*']) then (
        let $pred := if (string-length($predContent[1])>0) then (concat("hl7:templateId[",string-join($predContent,' or '),"]")) else ('')
        return
            if ($xpath and $pred) then 
                (concat($xpath,'[',$pred,']')) 
            else if (not($xpath) and $pred) then
                (concat('*[',$pred,']')) 
            else 
                ($xpath)
    )
    (:  situation 2: template has <context id="**"/>
        - template must have template id
        - it does have a fixed containing element (i.e. template's content resides in element with a particular name :)
    else if ($template/context[1][@id='**']) then (
        let $initialelementName := $template/element/@name
        let $pred := if (string-length($predContent[1])>0) then (concat($initialelementName,"[hl7:templateId[",string-join($predContent,' or '),"]]")) else ($initialelementName)
        return
            if ($xpath and $pred) then 
                (concat($xpath,'[',$pred,']')) 
            else if (not($xpath) and $pred) then 
                (concat('*[',$pred,']')) 
            else 
                ($xpath)
    )
    (:  situation 3: template has <context> without @id
        - if template has path in context (<context path='...'/>, use path 
        - template may have template id
        - if template has no path in context, make path from code and codeSystem  
    :)
    else
        (: if context/@path, use it without further ado :)
        if ($template/context[1]/@path)
        (: if <context path='/'/> do not output the '/', leading slash is already appended for each element :)
        then if ($template/context[1]/@path = '/') then '' else $template/context[1]/@path 
        else
        (: situation 4: ask AH to check this, since he may understand this :) 
        (
        let $predContent := 
            if ($template/element[@name='hl7:code'][exists(vocabulary/@codeSystem)]) then (
                for $attr in $template/element[@name='hl7:code']/vocabulary[exists(@codeSystem)]
                return
                    if ($attr/@code) then (concat("(@code='", $attr/@code ,"' and @codeSystem='", $attr/@codeSystem ,"')")) else (concat("@codeSystem='", $attr/@codeSystem ,"'"))
            ) else if ($template/element[1]/element[@name='hl7:code'][exists(vocabulary/@codeSystem)]) then (
                for $attr in $template/element[1]/element[@name='hl7:code']/vocabulary[exists(@codeSystem)]
                return
                    if ($attr/@code) then (concat("(@code='", $attr/@code ,"' and @codeSystem='", $attr/@codeSystem ,"')")) else (concat("@codeSystem='", $attr/@codeSystem ,"'"))
            ) else ('')
        let $pred := 
            if ($predContent[1]) then (
                if ($template/element[@name='hl7:code']) then (
                    concat("hl7:code[",string-join($predContent,' or '),"]")
                )
                else (
                    concat($template/element[1]/@name,"[hl7:code[",string-join($predContent,' or '),"]]")
                )
            ) else ('')
        let $ctxPath := $template/context[1]/@path
        let $outPath :=
            if (not($xpath)) then '*' else $xpath
        let $outPath :=
            if ($ctxPath) then concat($outPath, if (starts-with($ctxPath, '/')) then () else '/', $ctxPath) 
            else ($outPath)
        let $outPath :=
            if ($pred) then (concat($outPath,'[',$pred,']'))
            else $outPath
        return $outPath
    )
};

declare function artx:getSingleTemplate($decor as node()*, $nameOrId as xs:string, $flexibility as xs:string? ) as element()? {
    let $effectiveDate := 
        if (not($flexibility) or ($flexibility='dynamic')) then 
            if (matches($nameOrId,'^[\d\.]+$')) 
            then max($decor//template[@id=$nameOrId]/xs:dateTime(@effectiveDate))
            else max($decor//template[@name=$nameOrId]/xs:dateTime(@effectiveDate))
        else $flexibility
    return
        if (matches($nameOrId,'^[\d\.]+$')) then
            $decor//template[@id=$nameOrId][@effectiveDate=$effectiveDate]
            (:decor:getValueSetById($idOrName, $flexibility, $prefix):)
        else
            $decor//template[@name=$nameOrId][@effectiveDate=$effectiveDate]
            (:decor:getValueSetByName($idOrName, $flexibility, $prefix, false()):)
};


(: Of all templates in one specific Decor file, return those with the highest effectiveDate :)
declare function artx:currentTemplates($decor as node()* ) as element()*{
    (: returns a sequence with the relevant templates :)
    let $templates := $decor//template
    return 
        for $name in distinct-values($templates/@name)
        return $templates[@name=$name][@effectiveDate=max($templates[@name=$name]/xs:dateTime(@effectiveDate))]
};

(: Of all templateAssociations in one specific Decor file, return those with the highest effectiveDate :)
declare function artx:currentTemplateAssociations($decor as node()* ) as element()*{
    (: returns a sequence with the relevant templateAssociations :)
    let $templateAssociations := $decor//templateAssociation
    return 
        for $templateId in distinct-values($templateAssociations/@templateId)
        return $templateAssociations[@templateId=$templateId][@effectiveDate=max($templateAssociations[@templateId=$templateId]/xs:dateTime(@effectiveDate))]
};