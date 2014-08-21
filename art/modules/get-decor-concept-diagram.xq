xquery version "1.0";
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

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace svg       = "http://www.w3.org/2000/svg";
declare namespace xlink     = "http://www.w3.org/1999/xlink";

declare function local:resolveInherit($concept as element()) as element() {
let $id :=$concept/@id
return
    if (string-length($concept/inherit/@ref)>1) then
    let $inheritedConcept := $get:colDecorData//concept[@id=$concept/inherit/@ref][@effectiveDate=$concept/inherit/@effectiveDate][not(ancestor::history)]
    let $baseId :=string-join(tokenize($inheritedConcept/@id,'\.')[position()!=last()],'.')                                                                     
    let $prefix := $get:colDecorData//baseId[@id=$baseId]/@prefix
    return
        <concept id="{$id}" inheritedType="{$inheritedConcept/@type}" inheritedStatusCode="{$inheritedConcept/@statusCode}" effectiveDate="{$inheritedConcept/@effectiveDate}" versionLabel="{$inheritedConcept/@versionLabel}" expirationDate="{$inheritedConcept/@expirationDate}" prefix="{$prefix}">
        {
            $concept/inherit,
            for $name in $inheritedConcept/name
            return
            <inheritedName language="{$name/@language}">{$name/text()}</inheritedName>
            ,
            for $desc in $inheritedConcept/desc
            return
            <inheritedDesc language="{$desc/@language}">{$desc/text()}</inheritedDesc>
            ,
            for $source in $inheritedConcept/source
            return
            <inheritedSource language="{$source/@language}">{$source/text()}</inheritedSource>
            ,
            for $rationale in $inheritedConcept/rationale
            return
            <inheritedRationale language="{$rationale/@language}">{$rationale/text()}</inheritedRationale>
            ,
            for $comment in $inheritedConcept/comment
            return
            <inheritedComment language="{$comment/@language}">{$comment/text()}</inheritedComment>
            ,
            for $operationalization in $inheritedConcept/operationalization
            return
            <inheritedOperationalization language="{$operationalization/@language}">{$operationalization/text()}</inheritedOperationalization>
            ,
            for $valueDomain in $inheritedConcept/valueDomain
            return
            <inheritedValueDomain type="{$valueDomain/@type}">{$valueDomain/*}</inheritedValueDomain>
            ,
            for $c in $concept/concept
            return
            local:resolveInherit($c)
        }
        </concept>

    else (

        <concept id="{$id}" type="{$concept/@type}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}" versionLabel="{$concept/@versionLabel}" expirationDate="{$concept/@expirationDate}">
        {
            for $name in $concept/name
            return
            art:serializeNode($name)
            ,
            for $desc in $concept/desc
            return
            art:serializeNode($desc)
            ,
            for $source in $concept/source
            return
            art:serializeNode($source)
            ,
            for $rationale in $concept/rationale
            return
            art:serializeNode($rationale)
            ,
            for $comment in $concept/comment
            return
            art:serializeNode($comment)
            ,
            for $operationalization in $concept/operationalization
            return
            art:serializeNode($operationalization)
            ,
            $concept/valueDomain
            ,
            for $c in $concept/concept
            return
            local:resolveInherit($c)
        }
        </concept>
    )
};

(: 
    function takes a DECOR concept hierarchie as argument and returns
    the concept hierarchie as a set of nested svg:g elements 
:)
declare function local:conceptClassbox($concept as element(), $language as xs:string) as element() {
    let $id             :=$concept/@id
    let $name           := $concept/name[@language=$language]|$concept/inheritedName[@language=$language]
    let $nameLength     := $name/string-length()
    let $conceptNames   := $concept/concept[@type='item']/name[@language=$language]|$concept/concept[inherit/@iType='item']/inheritedName[@language=$language]
    let $maxConceptName := max($conceptNames/string-length(normalize-space(.)))
    
    let $minClassboxWidth := 200
    let $classboxWidth  := 
        if ((80 + $maxConceptName*6 > $minClassboxWidth) and (80 + $maxConceptName*6 >=( 80 + $nameLength*6))) then
        80 + $maxConceptName*6
        else if ((80 + $nameLength*6 > $minClassboxWidth) and (80 + $maxConceptName*6 < (80 + $nameLength*6))) then
        80 + $nameLength*6
        else if ((80 + $maxConceptName*6 < $minClassboxWidth) and (80 + $maxConceptName*6 < (80 + $nameLength*6))) then
        80 + $nameLength*6
        else ($minClassboxWidth)
    let $classboxHeight := 60 +  count($concept/concept[@type='item' or inherit/@iType='item']) *15
    return
    <svg:g id="{$id}">
        <svg:rect y="0" x="0" height="{$classboxHeight}" width="{$classboxWidth}" id="{$id}" class="class-box">
        </svg:rect>
        <svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                d="m 5, 30  h {$classboxWidth -10}" id="path2872">
        </svg:path>
        {
            if ($concept/inheritedName) then
                <svg:text class="inherit-bold"    x="{($classboxWidth div 2)}" y="20">
                {$name/text()}
                </svg:text>
            else (
                <svg:text class="normal-bold"    x="{($classboxWidth div 2)}" y="20">
                {$name/text()}
                </svg:text>
            )
        }
        <svg:text class="normal-start" x="5" y="40">
        {
            for $c in $concept/concept[@type='item' or inherit/@iType='item']
            return
                if ($c/inheritedName) then
                    <svg:tspan style="fill:#4a12eb" x="5" dy="15">
                    {$c/name[@language=$language]/text(),$c/inheritedName[@language=$language]/text()}
                    <svg:tspan style="text-anchor:end" x="{$classboxWidth - 5}" dy="0">
                    {string($c/valueDomain/@type),string($c/inheritedValueDomain/@type)}
                    </svg:tspan>
                    </svg:tspan>
                 else (
                    <svg:tspan x="5" dy="15">
                    {$c/name[@language=$language]/text(),$c/inheritedName[@language=$language]/text()}
                    <svg:tspan style="text-anchor:end" x="{$classboxWidth - 5}" dy="0">
                    {string($c/valueDomain/@type),string($c/inheritedValueDomain/@type)}
                    </svg:tspan>
                    </svg:tspan>
                )
            }
        </svg:text>
        {
            for $g in $concept/concept[@type='group' or inherit/@iType='group']
            return
            local:conceptClassbox($g,$language)
        }
    </svg:g>
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

declare function local:positionClasses($classes as element(), $processedScan as element()) as element() {
    let $levelSpacing := 45
    let $id :=$classes/@id
    
    let $parentId := $processedScan//class[@id=$id]/@parentId
    let $parentWidth := $classes/ancestor::svg:g[@id=$parentId]/svg:rect/@width div 2
    let $parentHeight := $classes/ancestor::svg:g[@id=$parentId]/svg:rect/@height
    let $level := $processedScan//class[@id=$id]/parent::level/@depth
    let $xShift := 
        if ($level=0) then
            ($processedScan//class[@id=$id]/@width div 2) - ($classes/svg:rect/@width div 2)
        else( ($processedScan//class[@id=$parentId]/@width div -2) + ($processedScan//class[@id=$id]/@width div 2) - ($classes/svg:rect/@width div 2) + $parentWidth + sum($processedScan//class[@id=$id]/preceding-sibling::class[@parentId=$parentId]/@width))
    let $xPath := 
        if ($level>0) then
             $xShift + (($classes/svg:rect/@width div 2) - $parentWidth)
        else()
        
    let $yShift := 
        if ($level=0) then
            0
        else($processedScan//level[@depth=$level -1]/@maxHeight + $levelSpacing)
    let $path := 
        if ($level>0) then
            <svg:path style="fill:none;stroke:#000000;stroke-width:1px" d="{concat('m ',($classes/svg:rect/@width div 2),', 0 ','v -',($levelSpacing div 3),' h ',$xPath * -1,' v ', -1 * ($yShift - $parentHeight - ($levelSpacing div 3)))}"/>
        else()
    return
    <svg:g id="{$id}" transform="{concat('translate(',$xShift,',',$yShift,')')}">
    {
        $classes/svg:rect,
        
        $classes/svg:path,
        $classes/svg:text,
        $classes/svg:a,
        $path,
        for $grp in $classes/svg:g
        return
        local:positionClasses($grp,$processedScan)
        
    }
    </svg:g>
};

let $conceptId      := request:get-parameter('id','2.16.840.1.113883.2.4.6.99.1.77.2.20000')
let $language := 'nl-NL'
let $levelSpacing   := 45
(:let $conceptId := '2.16.840.1.113883.2.4.6.99.1.77.2.20000':)
let $collection     := $get:strDecorData
let $concept        := collection($collection)//concept[@id=$conceptId][not(ancestor::history)]
let $classes        := <classes>{local:conceptClassbox(local:resolveInherit($concept),$language)}</classes>
(:let $depth := max(count($classes//svg:g/ancestor::svg:g)):)

let $depths         := 
    for $group in $classes//svg:g
    return
    count($group/ancestor::svg:g)
let $depth          := max($depths)

let $scan           := local:reverseScan($classes,$depth)
let $process        := 
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


let $processed :=    util:eval(string-join($process,' '))
(:let $processed :=    util:eval(string-join($process//step,' '),xs:boolean('false'),$scan):)

let $width :=  
    if(count($classes//svg:g)=1) then
        $classes//svg:rect[1]/@width
    else($processed//level[@depth=0]/class/@width)

let $height := 
    if(count($classes//svg:g)=1) then
        $classes//svg:rect[1]/@height
    else(sum($processed//@maxHeight) + $levelSpacing * $depth)
return
<svg:svg id="svg2" version="1.1" height="{$height}" width="{$width}">
      <svg:style type="text/css"><![CDATA[
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
      </svg:style>
            <svg:style type="text/css"><![CDATA[
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
      </svg:style>
      <svg:style type="text/css"><![CDATA[
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
      </svg:style>
      <svg:style type="text/css"><![CDATA[
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
    ]]>
    </svg:style>
    <svg:rect style="fill:#ffffff;fill-opacity:1;stroke:#000000;stroke-width:0"
                id="backgroundObject" width="{$width}" height="{$height}" x="0" y="0">
        <svg:desc>Background rectangle in white to avoid transparency.</svg:desc>
    </svg:rect>
    { if ($classes/svg:g/svg:g) then
            local:positionClasses($classes/svg:g,$processed)
        else($classes/*)
    }
</svg:svg>