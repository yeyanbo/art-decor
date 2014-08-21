xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw, Alexander Henket
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
(:import module namespace f   = "urn:decor:REST:v1" at "get-message.xquery";:)
declare namespace svg       = "http://www.w3.org/2000/svg";

declare variable $useLocalAssets := if (request:exists()) then request:get-parameter('useLocalAssets','false') else 'false';
declare variable $resourcePath   := if ($useLocalAssets = 'true') then ('../assets') else ('resources');

(:
    function takes a DECOR concept hierarchie as argument and returns
    the concept hierarchie as a set of nested svg:g elements 
:)
declare function local:conceptClassbox($concept as element(), $language as xs:string) as element() {
    let $id                 := $concept/@id
    let $name               := $concept/name[@language=$language][1]
    let $maxConceptName     := max($concept/(name[@language=$language][1]|concept/name[@language=$language])/string-length(normalize-space(.)))
    
    let $minClassboxWidth   := 200
    (:
        the width of the 'right hand side'. 
        for transaction based concepts this is valueDomain/@type + card/conf. 
        for dataset based concepts this valueDomain/@type 
    :)
    let $typeCardConfWidth  := if ($concept/ancestor-or-self::dataset[@transactionId]) then (130) else (80)
    let $classboxWidth      :=
        if ($typeCardConfWidth + $maxConceptName*6 > $minClassboxWidth) then
            $typeCardConfWidth + $maxConceptName*6
        else (
            $minClassboxWidth
        )
    let $classboxHeight     := 60 + count($concept/concept[@type='item']) *15
    
    let $detailUri          :=
        for $p in request:get-parameter-names()[not(.='id')] return 
        for $pval in request:get-parameter($p,()) return concat($p,'=',$pval)
    
    return
        (: group for the classbox and children :)
        element {QName('http://www.w3.org/2000/svg','g')} 
        {
            attribute id {concat('id_',replace($id,'\.','_'))}
            ,
            (: blue-ish rectangle in the classbox :)
            element {QName('http://www.w3.org/2000/svg','rect')}
            {
                attribute x {0},
                attribute y {0},
                attribute height {$classboxHeight},
                attribute width {$classboxWidth},
                (:attribute id {$id},:)
                if ($concept/self::dataset) then (
                    attribute class {'class-box'}
                ) else (
                    attribute class {'class-box class-box-hover'},
                    attribute onclick {concat('javascript:location.href=window.location.pathname+''?id=',$id,'&amp;',string-join($detailUri,'&amp;'),'''')}
                )
            }
            ,
            (: line between classbox name and classbox content :)
            element {QName('http://www.w3.org/2000/svg','path')}
            {
                attribute style {'fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1'},
                attribute d {concat('m 5, 30  h ',$classboxWidth -10)}
            }
            ,
            (: classbox name (card/conf) :)
            element {QName('http://www.w3.org/2000/svg','text')}
            {
                attribute x {$classboxWidth div 2},
                attribute y {20},
                if ($concept/inherit) then
                    attribute class {'inherit-bold'}
                else if ($concept/self::dataset) then
                    attribute class {'dataset-bold'}
                else (
                    attribute class {'normal-bold'}
                )
                ,
                let $conceptName := normalize-space(string-join($name/text(),''))
                return if (string-length($conceptName)=0) then '&#160;' else $conceptName
                ,
                if ($concept/ancestor::dataset[@transactionId]) then (
                    element {QName('http://www.w3.org/2000/svg','tspan')}
                    {
                        attribute x {$classboxWidth - 5},
                        attribute dy {0},
                        attribute style {'text-anchor:end;font-style:italic;'},
                        ' ',
                        if ($concept/@conformance=('NP','C')) then (
                            string($concept/@conformance)
                        )
                        else (
                            if ($concept/@minimumMultiplicity or $concept/@maximumMultiplicity) then (
                                concat($concept/@minimumMultiplicity,'..',$concept/@maximumMultiplicity)
                            ) else ()
                            ,
                            if ($concept/@isMandatory='true') then 'M' else string($concept/@conformance)
                        )
                    }
                ) else ()
                ,
                element {QName('http://www.w3.org/2000/svg','tspan')}
                {
                    attribute x {5},
                    attribute dy {15},
                    '&#160;'
                }
            }
            ,
            (: classbox content :)
            element {QName('http://www.w3.org/2000/svg','text')}
            {
                attribute x {5},
                attribute y {40},
                attribute class {'normal-start'},
                for $c in $concept/concept[@type='item']
                return
                    element {QName('http://www.w3.org/2000/svg','tspan')}
                    {
                        attribute x {5},
                        attribute dy {15},
                        if ($c/inherit) then (attribute class {'inherit'}) else ()
                        ,
                        let $conceptName := normalize-space(string-join($c/name[@language=$language],''))
                        return if (string-length($conceptName)=0) then '&#160;' else $conceptName
                        ,
                        element {QName('http://www.w3.org/2000/svg','tspan')}
                        {
                            attribute x {$classboxWidth - 5},
                            attribute dy {0},
                            attribute style {'text-anchor:end;'}
                            ,
                            let $conceptType := normalize-space(string-join($c/valueDomain/@type,''))
                            return if (string-length($conceptType)=0) then '&#160;' else $conceptType
                            ,
                            element {QName('http://www.w3.org/2000/svg','tspan')}
                            {
                                attribute dy {0},
                                attribute style {'font-style:italic;'},
                                ' ',
                                if ($c/@conformance=('NP','C')) then (
                                    string($c/@conformance)
                                )
                                else (
                                    if ($c/@minimumMultiplicity or $c/@maximumMultiplicity) then (
                                        concat($c/@minimumMultiplicity,'..',$c/@maximumMultiplicity)
                                    ) else ()
                                    ,
                                    if ($c/@isMandatory='true') then 'M' else string($c/@conformance)
                                )
                            }
                        }
                    }
                ,
                element {QName('http://www.w3.org/2000/svg','tspan')}
                {
                    attribute x {5},
                    attribute dy {15},
                    '&#160;'
                }
            }
            ,
            (: get classboxes for child concepts :)
            for $g in $concept/concept[@type='group']
            return
            local:conceptClassbox($g,$language)
        }
};

declare function local:reverseScan($classes as element(), $startDepth as item()) as element() {
    let $current := $classes//svg:g[count(ancestor::svg:g)=$startDepth]
    let $spacing :=10
    return
    <level depth="{$startDepth}" count="{count($current)}" maxHeight="{max($current/svg:rect/@height)}" width="{sum($current/svg:rect/@width)}">
    {
        for $item in $current
        return
            <class id="{$item/@id}" parentId="{$item/parent::svg:g/@id}" height="{$item/svg:rect/@height}" width="{$item/svg:rect/@width + ((count($current)-1) * $spacing)}"/>
    }
    {
        if ($startDepth > 0) then
            local:reverseScan($classes,$startDepth -1)
        else()
    }
    </level>
};

declare function local:procesScan($scan as element()) as element() {
    let $level := $scan
    return
    <level depth="{$level/@depth}" count="{$level/@count}" maxHeight="{$level/@maxHeight}" width="{$level/@width}">
    {
        for $class in $level/class
        let $id := $class/@id
        return
            <class id="{$class/@id}" parentId="{$class/@parentId}" height="{$class/@height}" width="{if (sum($class/preceding::*[@parentId=$id]/@width)>$class/@width) then sum($class/preceding::*[@parentId=$id]/@width) else($class/@width)}"/>
    }
    {
        if ($level/level) then
            local:procesScan($level/level)
        else()
    }
    </level>
};

declare function local:positionClasses($classes as element(), $processedScan as element(), $conceptParentId as xs:string?, $atTopLevel as xs:boolean, $transactionId as xs:string) as element() {
    let $levelSpacing   := 45
    let $id             := $classes/@id
    
    let $parentId       := $processedScan//class[@id=$id]/@parentId
    let $parentWidth    := $classes/ancestor::svg:g[@id=$parentId]/svg:rect/@width div 2
    let $parentHeight   := $classes/ancestor::svg:g[@id=$parentId]/svg:rect/@height
    let $level          := $processedScan//class[@id=$id]/parent::level/@depth
    let $xShift         := 
        if ($level=0) then
            ($processedScan//class[@id=$id]/@width div 2) - ($classes/svg:rect/@width div 2)
        else( 
            ($processedScan//class[@id=$parentId]/@width div -2) + ($processedScan//class[@id=$id]/@width div 2) - ($classes/svg:rect/@width div 2) + $parentWidth + sum($processedScan//class[@id=$id]/preceding-sibling::class[@parentId=$parentId]/@width)
        )
    let $xPath          :=
        if ($level>0) then
            $xShift + (($classes/svg:rect/@width div 2) - $parentWidth)
        else()
    let $yShift         :=
        if ($level=0) then
            $levelSpacing
        else(
            $processedScan//level[@depth=$level -1]/@maxHeight + $levelSpacing
        )
    let $startnode      :=
        if ($level=0 and not($atTopLevel)) then (
            local:getCircle($conceptParentId,$transactionId,($classes/svg:rect/@width div 2),($levelSpacing * -1) + 20)
        ) else()
    let $path           :=
        if ($level>0 or ($level=0 and not($atTopLevel))) then
            element {QName('http://www.w3.org/2000/svg','path')}
            {
                attribute style {'fill:none;stroke:#000000;stroke-width:1px'},
                attribute d {concat('m ',($classes/svg:rect/@width div 2),', 0 ','v -',($levelSpacing div 3),
                    let $hVal := $xPath * -1
                    return if ($hVal castable as xs:integer) then (concat(' h ',$hVal)) else ()
                    ,
                    let $vVal := ($yShift - $parentHeight - ($levelSpacing div 3)) * -1 
                    return if ($vVal castable as xs:integer) then (concat(' v ',$vVal)) else ())}
            }
        else()
    return
    element {QName('http://www.w3.org/2000/svg','g')}
    {
        attribute id {$id},
        attribute transform {concat('translate(',$xShift,',',$yShift,')')},
        $classes/(@* except @id|@transform),
        $classes/svg:rect,
        $classes/svg:path,
        $classes/svg:text,
        $classes/svg:a,
        $startnode,
        $path,
        for $grp in $classes/svg:g
        return
        local:positionClasses($grp,$processedScan,$conceptParentId,$atTopLevel,$transactionId)
    }
};

declare function local:getCircle($conceptParentId as xs:string?, $transactionId as xs:string, $cx as xs:integer, $cy as xs:integer) as element() {
    let $detailUri          :=
        if ($conceptParentId) then (
            concat('javascript:location.href=window.location.pathname+''?id=',$conceptParentId,'&amp;',string-join(
                for $p in request:get-parameter-names()[not(.='id')] return 
                for $pval in request:get-parameter($p,()) return concat($p,'=',$pval)
            ,'&amp;'),'''')
        )
        else (
            concat('javascript:location.href=window.location.pathname+''?',string-join(
                for $p in request:get-parameter-names()[not(.='id')] return 
                for $pval in request:get-parameter($p,()) return concat($p,'=',$pval)
            ,'&amp;'),
                if (not('transactionId'=request:get-parameter-names())) then (
                    concat('&amp;transactionId=',$transactionId)
                ) else ()
            ,'''')
        )
    return
    element {QName('http://www.w3.org/2000/svg','circle')}
    {
        attribute cx {$cx},
        attribute cy {$cy},
        attribute r {'10'},
        attribute class {'class-box class-box-hover'},
        attribute onclick {$detailUri}
    }
};

let $conceptId          := request:get-parameter('id',())
let $transactionId      := request:get-parameter('transactionId',())
(:let $transactionDate    := request:get-parameter('transactionEffectiveDate',()):)
let $language           := 
    if (request:get-parameter('language',())) then
        request:get-parameter('language',())
    else if ($conceptId) then
        $get:colDecorData//concept[@id=$conceptId][not(ancestor::history)]/ancestor::decor/project/@defaultLanguage
    else (
        ($get:colDecorData//transaction[@id=$transactionId]/ancestor::decor/project/@defaultLanguage | $get:colDecorData//dataset[@id=$transactionId]/ancestor::decor/project/@defaultLanguage)[1]
    )

let $levelSpacing       := 45
(:let $conceptId        := '2.16.840.1.113883.2.4.6.99.1.77.2.20000':)
let $concept            :=
    if ($transactionId and $conceptId)
    then (
        art:getPartialDatasetTree($transactionId,$conceptId,$language,())//concept[@id=$conceptId]
    )
    else if ($transactionId) then (
        art:getPartialDatasetTree($transactionId,(),$language,())
    )
    else (
        let $datasetId  := $get:colDecorData//concept[@id=$conceptId][not(ancestor::history)]/ancestor::dataset/@id
        return art:getPartialDatasetTree($datasetId,$conceptId,$language,())//concept[@id=$conceptId]
    )
let $conceptParentId    := $get:colDecorData//concept[@id=$conceptId][not(ancestor::history)]/parent::concept/@id
let $conceptTransactId  := if ($transactionId) then $transactionId else ($concept/ancestor::dataset/@id)
let $classes            := <classes>{local:conceptClassbox($concept,$language)}</classes>
(:let $depth            := max(count($classes//svg:g/ancestor::svg:g)):)

let $depths  := 
    for $group in $classes//svg:g
    return
        count($group/ancestor::svg:g)
let $depth   := max($depths)

let $scan    := local:reverseScan($classes,$depth)
let $process := 
    for $i in (1 to $depth)
    return
        if ($i=1 and $depth>1) then
            <step>let {concat('$step',$i,':= local:procesScan($scan)')}</step>
        else if ($i=$depth and $depth=1) then
            <step>let {concat('$step',$i,':= local:procesScan($scan)')}</step>|
            <step>return {concat('$step',$i)}</step>
        else if ($i=$depth and $depth>1) then
            <step>let {concat('$step',$i,':= local:procesScan($step',$i -1,')')}</step>|
            <step>return {concat('$step',$i)}</step>
        else(<step>let {concat('$step',$i,':= local:procesScan($step',$i -1,')')}</step>)


let $processed :=	util:eval(string-join($process,' '))
(:let $processed :=	util:eval(string-join($process//step,' '),xs:boolean('false'),$scan):)

let $width :=  
    if (count($classes//svg:g)=1) then
        $classes//svg:rect[1]/@width
    else ($processed//level[@depth=0]/class/@width)

let $height :=
    if (count($classes//svg:g)=1) then
        $classes//svg:rect[1]/@height + $levelSpacing 
    else (
        sum($processed//@maxHeight) + $levelSpacing + $levelSpacing * $depth
    )
return
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" height="{$height}" width="{$width}">

    <style type="text/css"><![CDATA[
        .dataset-bold {
        font-size:11px;
        font-weight:bold;
        text-align:start;
        line-height:125%;
        text-anchor:middle;
        fill:#000000;
        fill-opacity:1;
        stroke:none;
        font-family:Verdana;
        font-style: italic;
        }
    ]]>
    </style>
    <style type="text/css"><![CDATA[
        .normal-bold {
        font-size:11px;
        font-weight:bold;
        text-align:start;
        line-height:125%;
        text-anchor:middle;
        fill:#000000;
        fill-opacity:1;
        stroke:none;
        font-family:Verdana
        }
    ]]>
    </style>
    <style type="text/css"><![CDATA[
        .inherit-bold {
        font-size:11px;
        font-weight:bold;
        text-align:start;
        line-height:125%;
        text-anchor:middle;
        fill:#4a12eb;
        fill-opacity:1;
        stroke:none;
        font-family:Verdana
      }
    ]]>
    </style>
    <style type="text/css"><![CDATA[
        .inherit {
        fill:#4a12eb;
        fill-opacity:1;
        }
    ]]>
    </style>
    <style type="text/css"><![CDATA[
        .normal-start {
        font-size:11px;
        text-align:start;
        font-weight:normal;
        text-anchor:start;
        fill:#000000;
        fill-opacity:1;
        stroke:none;
        font-family:Verdana
        }
    ]]>
    </style>
    <style type="text/css"><![CDATA[
        .class-box {
        fill:#c4e1ff;
        fill-opacity:1;
        fill-rule:evenodd;
        stroke:#000000;
        stroke-width:0.2;
        stroke-linecap:butt;
        stroke-linejoin:miter;
        stroke-miterlimit:4;
        stroke-opacity:1;
        stroke-dasharray:none
        }
        .class-box-hover {
        cursor: pointer;
        }
        .class-box-hover:hover {
        fill-opacity:0.5;
        }
    ]]>
    </style>

    <rect style="fill:#ffffff;fill-opacity:1;stroke:#000000;stroke-width:0" width="{$width}" height="{$height}" x="0" y="0">
        <desc>Background rectangle in white to avoid transparency.</desc>
    </rect>
    {
        if ($classes/svg:g/svg:g) then
            local:positionClasses($classes/svg:g,$processed,$conceptParentId,$concept/name()='dataset',$conceptTransactId)
        else(
        (:$classes/*:)
            element {QName('http://www.w3.org/2000/svg','g')}
            {
                attribute transform {concat('translate(',0,',',$levelSpacing,')')},
                $classes/svg:g/(@* except @transform),
                $classes/svg:g/svg:*,
                if ($conceptParentId or not($concept/name()='dataset')) then (
                    local:getCircle($conceptParentId,$conceptTransactId,($classes//svg:rect[1]/@width div 2),-25),
                    element {QName('http://www.w3.org/2000/svg','path')}
                    {
                        attribute style {'fill:none;stroke:#000000;stroke-width:1px'},
                        attribute d {concat('m ',($classes//svg:rect[1]/@width div 2),', 0 ','v -',($levelSpacing div 3))}
                    }
                ) else ()
            }
        )
    }
</svg>