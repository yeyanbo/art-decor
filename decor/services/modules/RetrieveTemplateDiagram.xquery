xquery version "3.0";
(:~
:   Copyright (C) 2014-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Kai U. Heitmann
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)
(:
    experimental now
:)
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace templ   = "http://art-decor.org/ns/decor/template" at "../../../art/api/api-decor-template.xqm";
import module namespace msg     = "urn:decor:REST:v1" at "get-message.xquery";
declare namespace svg       = "http://www.w3.org/2000/svg";
declare namespace xlink     = "http://www.w3.org/1999/xlink";

declare variable $language := if (request:exists()) then request:get-parameter('language',$get:strArtLanguage) else ($get:strArtLanguage);

declare function local:showDate ($date as xs:dateTime) as xs:string {
    let $predate := replace(string($date), '-', '&#8209;')
    
    return
        if (matches(string($date), '\d\d\d\d-\d\d-\d\dT00:00:00.*', '')) then replace(string($predate), 'T00:00:00.*', '')
        else if (matches(string($date), '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.*')) then replace(string($predate), 'T(\d\d:\d\d:\d\d).*', ' $1')
        else string($predate)
};

declare function local:templateScan ($t as element()?, $projectPrefix as xs:string, $by as xs:string, $indent as xs:int, $ylevel as xs:int) as element()* {
(: get the templates, elements and include chain :)

let $oname := $t/name()

return
    if (empty($t)) then ()
    else if ($oname = 'template') then (
        <template>
        {
            $t/@id,
            $t/@name,
            $t/@displayName,
            attribute effectiveDate {local:showDate($t/@effectiveDate)},
            attribute by {$by},
            attribute len {(if (string-length($t/@id) > string-length($t/@name)) then string-length($t/@id) else string-length($t/@name)) + string-length($t/@effectiveDate) }
        }
        {
            for $lc at $step in ($t//element[@contains] | $t//include[@ref])
            let $xid    := if ($lc/name() = 'element') then $lc/@contains else $lc/@ref
            let $lcby   := if ($lc/name() = 'element') then msg:getMessage('contains',$language) else $lc/name()
            let $xflx   := if ($lc/@flexibility) then $lc/@flexibility else 'dynamic'
            let $lct    := templ:getTemplateByRef($xid,$xflx,$projectPrefix)/*/template[@id]
            return
                local:templateScan($lct, $projectPrefix, $lcby, $indent + 1, $ylevel + $step) 
        }
        </template>
    ) else if ($oname = 'element' and @contains) then (
        <element>
        {
            $t/@contains,
            $t/@flexibility,
            attribute by {$by},
            attribute len { string-length($t/@contains) + string-length($t/@flexibility) }
        }
        {
            for $lc at $step in ($t//element[@contains] | $t//include[@ref])
            let $xid    := if ($lc/name() = 'element') then $lc/@contains else $lc/@ref
            let $lcby   := if ($lc/name() = 'element') then msg:getMessage('contains',$language) else $lc/name()
            let $xflx   := if ($lc/@flexibility) then $lc/@flexibility else 'dynamic'
            let $lct    := templ:getTemplateByRef($xid,$xflx,$projectPrefix)/*/template[@id]
            return 
                local:templateScan ($lct, $projectPrefix, $lcby, $indent + 1, $ylevel + $step)
        }
        </element>
    ) else if ($oname = 'include' and @ref) then (
        <include>
        {
            $t/@ref,
            $t/@flexibility,
            attribute by {$by},
            attribute len { string-length($t/@ref) + string-length($t/@flexibility) }
        }
        {
            for $lc at $step in ($t//element[@contains] | $t//include[@ref])
            let $xid    := if ($lc/name() = 'element') then $lc/@contains else $lc/@ref
            let $lcby   := if ($lc/name() = 'element') then msg:getMessage('contains',$language) else $lc/name()
            let $xflx   := if ($lc/@flexibility) then $lc/@flexibility else 'dynamic'
            let $lct    := templ:getTemplateByRef($xid,$xflx,$projectPrefix)/*/template[@id]
            return 
                local:templateScan ($lct, $projectPrefix, $lcby, $indent + 1, $ylevel + $step) 
        }
        </include>
     ) else ()
};

declare function local:chainCopy1 ($t as element(), $indent as xs:int) as element() {
    let $oname := $t/name()
    return
        element {$oname} {
            $t/@*,
            attribute indent {$indent},
            for $i at $step in $t/*
            return local:chainCopy1($i, $indent+1)
        }
};

declare function local:chainCopy2 ($t as element(), $pos as xs:int) as element() {
    let $oname := $t/name()
    return
        element {$oname} {
            $t/@*,
            attribute pos {$pos},
            for $i at $step in $t//*
            let $oname := $i/name()
            return element {$oname} {
                $i/@*,
                attribute pos {$step},
                attribute connector {
                    if ($t//*[($step - 1)]/@indent = $t//*[$step]/@indent) then 2 
                    else if ($t//*[($step - 1)]/@indent < $t//*[$step]/@indent) then 1
                    else if ($t//*[($step - 1)]/@indent > $t//*[$step]/@indent) then 4 + 1
                    else 0
                }
            }
        }
};

declare function local:drawbox ($t as element(), $ty as xs:string, $classboxWidth as xs:int) as element()* {
let $txt := concat ($t/@id,' (', $t/@effectiveDate,')')
let $tn := concat (if (string-length($t/@displayName)>0) then $t/@displayName else $t/@name, $t/@contains, $t/@ref)
let $xx := 10 + 15 * $t/@indent
let $yy := -20 + 45 * $t/@pos
let $stripx := $xx - 10
let $stripy := $yy + 18
(:
    get vertical angle connector offset:
    0: no angle at all
    1: short angle connection, first item under parent
    2: long angle connection, second and later item under parent
    3: multiple blocks angle connection, back to parent level
:)
let $path := if ($t/@connector = 1) then (
        <path>
        {
            <svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                      d="m {$stripx}, {$stripy - 25} v 25" id="path2872"/>,
            <svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                      d="m {$stripx}, {$stripy} h 10" id="path2872"/>
        }
        </path>
    ) else if ($t/@connector = 2) then (
        <path>
        {
            <svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                      d="m {$stripx}, {$stripy - 45} v 45" id="path2872"/>,
            <svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                      d="m {$stripx}, {$stripy} h 10" id="path2872"/>
        }
        </path>
    ) else if ($t/@connector > 2) then (
        <path>
        {
            <svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                      d="m {$stripx}, {$stripy - $t/@connector * 25 - 10} v {$t/@connector * 25 + 10}" id="path2872"/>,
            <svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                      d="m {$stripx}, {$stripy} h 10" id="path2872"/>
        }
        </path>
    )
    else
        <path/>
return (
    $path/*,
    <svg:rect x="{$xx}" y="{$yy}" stroke-width="0.25" stroke-miterlimit="10" width="{$classboxWidth}" height="37.668" class="class-box"/>,
    <svg:text transform="matrix(1 0 0 1 {$xx+5} {$yy+15})" class="normal-start">
        <svg:tspan x="0" y="0"><svg:tspan class="text-bold">{$tn}</svg:tspan> ({$ty})</svg:tspan>
        <svg:tspan x="0" y="14">{$txt}</svg:tspan>
    </svg:text>
    )
};

declare function local:drawtree ($t as element()*, $classboxWidth as xs:int) as element()* {
let $x := 0
return

    if ($t/name() = 'tree') then (
         for $i at $step in $t/*
         return local:drawtree($i, $classboxWidth)
    ) else (
        for $i at $step in $t
        return (
            local:drawbox ($i, $i/@by, $classboxWidth),
            for $j at $step in $i/*
            return local:drawtree($j, $classboxWidth)
        )
    )
};

let $projectPrefix          := if (request:exists()) then request:get-parameter('project', ()) else ()
let $templateId             := if (request:exists()) then request:get-parameter('id', ()) else ()
let $templateEffectiveDate  := if (request:exists()) then request:get-parameter('effectiveDate', ()) else ()
let $format                 := if (request:exists()) then request:get-parameter('format','svg') else ('svg')

let $classboxHeight         := 150
let $concept                := 'ABC'
let $absolutepos            := 1

let $templatesById          := templ:getTemplateById($templateId, $templateEffectiveDate, $projectPrefix)/*/template[@id]

let $templatechain          := 
    if (count($templatesById)=1) then
        local:chainCopy2(local:chainCopy1(<tree>{local:templateScan ($templatesById, $projectPrefix, 'template', 1, 1)}</tree>, -1), 1)
    else ()

let $maxstrlen              := max($templatechain//@len)

return

if (empty($templatesById)) then
    (response:set-status-code(404), response:set-header('Content-Type','text/xml'), <error>{msg:getMessage('errorRetrieveTemplateNoResults',$language, if (request:exists()) then request:get-query-string() else())}</error>)
else if (count($templatesById)>1) then
    (response:set-status-code(500), response:set-header('Content-Type','text/xml'), <error>{msg:getMessage('errorRetrieveTemplateMultipleResult',$language, if (request:exists()) then request:get-query-string() else())}</error>)
else if ($format='xml') then (
    <x project="{$projectPrefix}">
    {
        $templatechain,
        <max>{$maxstrlen}</max>
    }
    </x>
    (:local:templateScan ($templatesById, $projectPrefix, 'template', 1, 1):)
    (:$templatesById:)
)
else if (count($templatechain/*)=0) then ()
else (
    let $classboxWidth  := 30 + $maxstrlen*7

    let $height         := max($templatechain//@pos) * 47 + 50
    let $width          := max($templatechain//@indent) * 50 + $classboxWidth + 50
    
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
          .text-bold {
              font-size:11px;
              font-weight:bold;
              line-height:125%;
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
              fill:#FFEAEA;
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
            <!--<svg:path style="fill:none;stroke:#000000;stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                      d="m 15, 30 h {$classboxWidth - 10}" id="path2872">
            </svg:path>-->
        {
            local:drawtree ($templatechain, $classboxWidth)
        }
        <!--
        <svg:text transform="matrix(1 0 0 1 15 25)" class="normal-start">
            <svg:tspan x="0" y="0"><svg:tspan class="text-bold">Arztmeldung6IfSG </svg:tspan>(template)</svg:tspan>
            <svg:tspan x="0" y="14">{$templateId} as of {$templateEffectiveDate}</svg:tspan>
        </svg:text>-->
    </svg:svg>
)