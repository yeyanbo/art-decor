xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get         = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art         = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace adserver    = "http://art-decor.org/ns/art-decor-server" at "../api/api-server-settings.xqm";
declare namespace xs            = "http://www.w3.org/2001/XMLSchema";
declare namespace xforms        = "http://www.w3.org/2002/xforms";
declare namespace httpclient    = "http://exist-db.org/xquery/httpclient";


declare function local:groupPrototypeListByVersion($list as element()) as element() {

let $tmp :=
    for $template in $list/template[@id]
    group by $id := $template/@id, $name := $template/@name
    order by $name
    return
        <template id="{$id}">
        {
            for $version in $template
            order by $version/@effectiveDate descending
            return
                <template>
                    {
                        $version/(@* except @isClosed),
                        attribute isClosed {$version/@isClosed='true'},
                        attribute sortname {if (string-length($version/@displayName)>0) then $version/@displayName else $version/@name},
                        $version/desc,
                        $version/classification
                    }
                </template>

        }
        </template>

let $result :=
    for $template in $tmp
    return
        if (count($template/template)>1) 
        then 
            <template>
            {
                $template/template[1]/(@* except @effectiveDate),
                attribute hasMultipleVersions {'true'},
                $template/template[1]/desc,
                $template/template[1]/classification,
                $template/*
            }
            </template>
            
        else
            $template/template
    
return
    <prototypeList>
    {
        $list/@*,
        $result
    }
    </prototypeList>
    
};


let $projectPrefix      := request:get-parameter('project','')
let $art-languages      := art:getArtLanguages()
(:let $projectPrefix := 'demo1-':)
let $repositories       := $get:colDecorData//project[@prefix=$projectPrefix]/buildingBlockRepository
let $schemaTypes        := art:getDecorTypes()//TemplateTypes/enumeration
let $requestHeaders     := <headers><header name="Content-Type" value="text/xml"/></headers>

let $prototypeList      :=
    for $repository in $repositories
    return
    <prototypeList url="{$repository/@url}" ident="{$repository/@ident}">
    {
        httpclient:get(xs:anyURI(concat($repository/@url,'TemplateIndex?format=xml&amp;prefix=',$repository/@ident)),false(),$requestHeaders)/httpclient:body/return/template
    }
    </prototypeList>
    
let $ownProjectTemplateList :=
    <prototypeList url="{adserver:getServerURLServices()}" ident="{$projectPrefix}">
    {
        (: add all you project's templates :)
        for $template in $get:colDecorData//decor[project[@prefix=$projectPrefix]]/rules/template[@id]
        return
        <template>
        {
                $template/@*,
                attribute own {'true'},
                $template/classification,
                for $desc in $template/desc
                return
                    art:serializeNode($desc)
         }
         </template>

    }
    </prototypeList>

(: group prototype templates by versions :)
let $allprototypes :=
    for $p in $prototypeList|$ownProjectTemplateList
    return local:groupPrototypeListByVersion($p)

return
<prototypeList>
{
    for $template in $allprototypes/template
    group by $type := if ($template/@own) then ('zzzown') else if ($template/classification/@type) then $template/classification/@type else ('notype') 
    return
        <class type="{$type}">
        {
            if ($type="zzzown") then (
                for $element in art:getFormResourcesKey('art',$art-languages,'project-templates')
                return
                    <label language="{$element/@xml:lang}">{$element/node()}</label>
            )
            else ( 
                for $label in $schemaTypes[@value=$type]/label
                return
                <label language="{$label/@language}">{$label/text()}</label>
            )
            ,
            for $templateType in $template 
            return
                <template>
                {
                    $templateType/(@* except (@url|@ident)),
                    attribute url {$templateType/ancestor::prototypeList/@url},
                    attribute ident {$templateType/ancestor::prototypeList/@ident},
                    $templateType/desc,
                    $templateType/template
                }
                </template>
        }
        </class>
}
</prototypeList>