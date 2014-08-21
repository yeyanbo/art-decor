xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
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
Searches for valueset by @name and @displayName
If project prefix is present search is limited to that project
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";

let $searchString := util:unescape-uri(request:get-parameter('searchString',''),'UTF-8')
let $searchTerms  := tokenize(lower-case($searchString),'\s')
let $prefix       := request:get-parameter('prefix','')
let $type         := request:get-parameter('type','valueset')

(:let $searchTerms     := 'gend'
let $prefix          := 'ad2bbr-':)
let $status          := ()
let $desc            := xs:boolean('false')
let $ref             := xs:boolean('false')

let $validSearch     := 
    if (matches($searchString,'^[a-z|0-9]') and string-length($searchString)>1 and string-length($searchString)<50) then
        xs:boolean('true')
    else if (matches($searchString,'^[A-Z]') and string-length($searchString)>1 and string-length($searchString)<40) then
        xs:boolean('true')
    else(
        xs:boolean('false')
    )
let $maxResults      := xs:integer('100')
let $query           := 
    <query>
        <bool>
        {
            for $term in $searchTerms
            return
                <wildcard occur="must">{concat('*',$term,'*')}</wildcard>
        }
        </bool>
    </query>

let $options := 
    <options>
        <filter-rewrite>yes</filter-rewrite>
        <leading-wildcard>yes</leading-wildcard>
    </options>

let $decor           :=
    if (string-length($prefix)=0) then
        if ($type='codesystem') then
            $get:colDecorData//decor[@repository='true'][not(@private='true')]/terminology/codeSystem
        else (
            $get:colDecorData//decor[@repository='true'][not(@private='true')]/terminology/valueSet
        )
    else (
        if ($type='codesystem') then
            $get:colDecorData//decor[project/@prefix=$prefix]/terminology/codeSystem
        else (
            $get:colDecorData//decor[project/@prefix=$prefix]/terminology/valueSet
        )
    )

let $searchResult    := 
    if ($validSearch) then
        for $object in $decor[ft:query(@name,$query,$options) or ft:query(@displayName,$query)]
        order by $object/@name
        return
            element {$object/name()} {
                attribute ident {$object/ancestor::decor/project/@prefix},
                $object/(@* except @ident)
            }
    else(
        <result current="0" count="0"/>
    )

let $count           := count($searchResult)
let $current         := if ($count>$maxResults) then $maxResults else ($count)

return
<result current="{$current}" count="{$count}">
{
    for $result in subsequence($searchResult,1,$maxResults)
    return
        $result
}
</result>