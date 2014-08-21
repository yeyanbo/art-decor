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

(:
   Xquery for creating new dataset concept
   Input:
   - datasetId    : dataset to insert concept into.
   - conceptType  : item/group
   - insertMode   : into/following
   - insertRef    : conceptId reference for insert
   - language     : language code for concept name
:)
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace datetime  = "http://exist-db.org/xquery/datetime";

(: variables for request parameters :)
let $datasetId      := request:get-parameter('datasetId','')
let $conceptBaseId  := request:get-parameter('conceptBaseId',())
let $conceptType    := request:get-parameter('conceptType','')
let $insertMode     := request:get-parameter('insertMode','')
let $insertRef      := request:get-parameter('insertRef','')
let $language       := request:get-parameter('language','')
(:
let $datasetId := '2.999.999.9977.77.1'
let $conceptType := 'item'
let $insertMode := 'into'
let $insertRef := '2.999.999.9977.77.2.20000'
let $language := 'nl-NL':)

(: check if dataset not final or deprecated ? (security):)
let $dataset    := $get:colDecorData//dataset[@id=$datasetId]
let $decor      := $dataset/ancestor::decor

(: Note: not protected from missing defaultBaseId for given type ... :)
let $baseId     := if (string-length($conceptBaseId)=0) then $decor//defaultBaseId[@type='DE']/@id/string() else ($conceptBaseId)
let $baseId     := if (ends-with($baseId,'.')) then $baseId else concat($baseId,'.')

let $newId      := max($dataset/parent::datasets//concept[starts-with(@id,$baseId)]/xs:integer(tokenize(@id,'\.')[last()]))
let $newId      := if (empty($newId)) then (concat($baseId,0)) else (concat($baseId,$newId + 1))

let $refConcept := $dataset//concept[@id=$insertRef][not(ancestor::history)]
let $concept    :=
    <concept type="{$conceptType}" id="{$newId}" effectiveDate="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}" statusCode="new">
        <name language="{$language}"/>
    </concept>
let $insert     :=
    if (not($dataset/concept)) then
        update insert $concept into $dataset
    else if ($insertMode='following') then
        update insert $concept following $dataset//concept[@id=$insertRef][not(ancestor::history)]
    else if ($insertMode='into') then
        if ($refConcept/concept) then
            update insert $concept preceding $refConcept/concept[1]
        else if ($refConcept/history and not($refConcept/concept)) then
            update insert $concept preceding $refConcept/history[1]
        else (
            update insert $concept into $refConcept
        )
    else ()

return
    $concept