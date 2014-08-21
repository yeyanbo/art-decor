xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace templ   = "http://art-decor.org/ns/decor/template" at "../api/api-decor-template.xqm";

let $searchTerms    := if (request:exists()) then tokenize(lower-case(request:get-parameter('searchString',())),'\s') else ()
let $projectPrefix  := if (request:exists()) then (request:get-parameter('project',())) else ()

(:let $searchString := 'gend'
let $prefix :='demo1-':)

let $decor          := $get:colDecorData//decor[project/@prefix=$projectPrefix]

let $requestHeaders := <headers><header name="Content-Type" value="text/xml"/></headers>

let $schemaTypes    := art:getDecorTypes()//TemplateTypes/enumeration

let $result := 
    for $repository in $decor/project/buildingBlockRepository
    return
    <repositoryTemplateList url="{$repository/@url}" ident="{$repository/@ident}">
    {
        templ:getRepositoryAndBBRTemplateList($searchTerms, $repository/@ident)
    }
    </repositoryTemplateList>

return
    <result count="{count($result//template[template])}" search="{$searchTerms}">
    {
        (:get templates with and without classification:)
        for $clt in (distinct-values($result//classification/@type),if ($result//template[template[not(classification/@type)]]) then '' else ())
        group by $type := if ($clt='') then 'notype' else $clt
        order by count($schemaTypes[@value=$type]/preceding-sibling::enumeration)
        return
        <class type="{$type}">
        {
            for $label in $schemaTypes[@value=$type]/label
            return
                <label language="{$label/@language}">{$label/text()}</label>
        }
        {
            let $templateSet := 
                if ($clt='') then
                    $result//result[@current>0]/template[template[not(classification/@type)]]
                else (
                    $result//result[@current>0]/template[template/classification[@type=$type]]
                )
            for $r in $templateSet
            let $fromRepository := $r/ancestor::repositoryTemplateList/@ident
            return
                <template>
                {
                    $r/@*,
                    if ($r/@fromRepository) then () else attribute fromRepository {$fromRepository},
                    for $t in $r/template
                    let $alreadyrefed := count($decor/rules/template[@ref=$t/@id]) > 0
                    order by $t/@effectiveDate descending
                    return
                        <template>
                        {
                            $t/@*,
                            if ($alreadyrefed) then attribute alreadyrefed {'true'} else (),
                            $t/*
                        }
                        </template>
                }
                </template>
        }
        </class>
    }
    </result>