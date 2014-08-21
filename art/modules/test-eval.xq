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
declare namespace svg       = "http://www.w3.org/2000/svg";
declare namespace xlink     = "http://www.w3.org/1999/xlink";

(:
    function takes a DECOR concept hierarchie as argument and returns
    the concept hierarchie as a set of nested svg:g elements 
:)
declare function local:conceptClassbox($concept as element()) as element() {
    let $id                 := $concept/@id
    let $maxConceptName     := max($concept/concept[@type='item']/name/string-length(normalize-space(.)))
    let $nameLength         := $concept/name[1]/string-length()
    let $minClassboxWidth   := 200
    let $classboxWidth      := 
        if ((80 + $maxConceptName*6 > $minClassboxWidth) and (80 + $maxConceptName*6 >( 80 + $nameLength*6))) then
            80 + $maxConceptName*6
        else if ((80 + $nameLength*6 > $minClassboxWidth) and (80 + $maxConceptName*6 < (80 + $nameLength*6))) then
            80 + $nameLength*6
        else if ((80 + $maxConceptName*6 < $minClassboxWidth) and (80 + $maxConceptName*6 < (80 + $nameLength*6))) then
            80 + $nameLength*6
        else ($minClassboxWidth)
    let $classboxHeight     := 60 +  count($concept/concept[@type='item']) *15
    
    return
    <svg:g id="{$id}">
        <svg:rect y="0" x="0" height="{$classboxHeight}" width="{$classboxWidth}" id="{$id}" class="class-box"/>
        <svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
            d="m 5, 30  h {$classboxWidth -10}" id="path2872">
        </svg:path>
        <svg:text class="normal-bold" x="{($classboxWidth div 2)}" y="20">
            {$concept/name[1]/text()}
        </svg:text>
        <svg:text class="normal-start" x="5" y="40">
        {
            for $c in $concept/concept[@type='item']
            return
            <svg:tspan x="5" dy="15">
                {$c/name[1]/text()}
                <svg:tspan style="text-anchor:end" x="{$classboxWidth - 5}" dy="0">
                    {string($c/value/@type)}
                </svg:tspan>
            </svg:tspan>
        }
        </svg:text>
        {
            for $g in $concept/concept[@type='group']
            return
                local:conceptClassbox($g)
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
    let $levelSpacing   := 45
    let $id             := $classes/@id
    
    let $parentId       := $processedScan//class[@id=$id]/@parentId
    let $parentWidth    := $classes/ancestor::svg:g[@id=$parentId]/svg:rect/@width div 2
    let $parentHeight   := $classes/ancestor::svg:g[@id=$parentId]/svg:rect/@height
    let $level          := $processedScan//class[@id=$id]/parent::level/@depth
    let $xShift         := 
        if ($level=0) then 
            ($processedScan//class[@id=$id]/@width div 2) - ($classes/svg:rect/@width div 2)
        else (
            ($processedScan//class[@id=$parentId]/@width div -2) + ($processedScan//class[@id=$id]/@width div 2) - ($classes/svg:rect/@width div 2) + $parentWidth + sum($processedScan//class[@id=$id]/preceding-sibling::class[@parentId=$parentId]/@width)
        )
    let $xPath          := 
        if ($level>0) then
            $xShift + (($classes/svg:rect/@width div 2) - $parentWidth)
        else()
    let $yShift         := 
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

(:let $conceptId := request:get-parameter('id','2.16.840.1.113883.2.4.6.99.1.77.2.20000'):)
let $language       := 'nl-NL'
let $levelSpacing   := xs:integer(45)
let $conceptId      := '2.16.840.1.113883.2.4.6.99.1.77.2.20000'
let $collection     := $get:strDecorData
let $concept        := collection($collection)//dataset[1]//concept[@id=$conceptId]
let $classes        := <classes>{local:conceptClassbox($concept)}</classes>
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


let $processed      := util:eval(string-join($process,' '))
(:let $processed := util:eval(string-join($process//step,' '),xs:boolean('false'),$scan):)
let $sumHeight      := sum($processed//@maxHeight)
let $width          :=
    if (count($classes//svg:g)=1) then
        $classes//svg:rect[1]/@width
    else($processed//level[@depth=0]/class/@width)

let $height :=
    if(count($classes//svg:g)>1) then
        $sumHeight + $levelSpacing*$depth
    else($classes//svg:rect[1]/@height)
return
<test sumHeight="{$sumHeight}" height="{$height}" depth="{$depth}" levelSpacing="{$levelSpacing}">
    <scan>
    {$scan}
    </scan>
    <process>
    {$process}
    </process>
    <processed>
    {$processed}
    </processed>
</test>