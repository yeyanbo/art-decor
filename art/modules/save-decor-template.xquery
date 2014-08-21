xquery version "3.0";
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
import module namespace art = "http://art-decor.org/ns/art" at  "art-decor.xqm";

declare function local:processElement($element as element()) as element()? {
    if ($element/@selected) then
        if ($element/name()='element') then
            <element>
            {
                $element/(@*[string-length()>0] except (@selected|@tmid|@tmname|@tmdisplayName|@originalType|@originalMin|@originalMax|@linkedartefactmissing|@concept|@conformance|@flexibility|@isMandatory)),
                if ($element/@conformance!='O') then
                    $element/@conformance
                else(),
                if ($element/@flexibility!='dynamic' and string-length($element/@flexibility)>0) then
                    $element/@flexibility
                else(),
                if ($element/@isMandatory='true') then
                    $element/@isMandatory
                else(),
                for $desc in $element/desc
                return
                art:parseNode($desc)
                ,
                $element/item,
                for $example in $element/example[string-length(text()) gt 0]
                return
                <example>
                {
                $example/@*[string-length()>0],
                util:parse($example/text())
                }
                </example>
                ,
                for $vocabulary in $element/vocabulary
                where some $att in $vocabulary/@* satisfies $att/string-length() gt 0
                return
                <vocabulary>{$vocabulary/(@*[string-length()>0] except @linkedartefactmissing),$vocabulary/node()}</vocabulary>
                ,
                for $property in $element/property
                where some $att in $property/@* satisfies $att/string-length() gt 0
                return
                <property>{$property/@*[string-length() gt 0]}</property>
                ,
                $element/text,
                for $attribute in $element/attribute
                return 
                local:processAttribute($attribute)
                ,
                for $item in $element/*[name()=('element','include','choice','let','assert','report','defineVariable','constraint')]
                return
                local:processElement($item)
            }
            </element>
        else if ($element/name()='choice') then
            <choice>
            {
                $element/(@*[string-length()>0] except (@selected|@originalType|@originalMin|@originalMax|@concept|@conformance|@isMandatory)),
                (:if ($element/@conformance!='O') then
                   $element/@conformance
                else(),
                if ($element/@isMandatory='true') then
                   $element/@isMandatory
                else(),:)
                for $desc in $element/desc
                return
                art:parseNode($desc)
                ,
                $element/item,
                for $item in $element/*[name()=('element','include','constraint')]
                return
                local:processElement($item)
            }
            </choice>
        else if ($element/name()='include') then
            <include>
            {
                $element/(@*[string-length()>0] except (@selected|@tmid|@tmname|@tmdisplayName|@originalType|@originalMin|@originalMax|@linkedartefactmissing|@concept|@conformance|@flexibility|@isMandatory)),
                if ($element/@conformance!='O') then
                    $element/@conformance
                else(),
                if ($element/@isMandatory='true') then
                    $element/@isMandatory
                else(),
                if ($element/@flexibility!='dynamic' and string-length($element/@flexibility)>0) then
                    $element/@flexibility
                else(),
                for $desc in $element/desc
                return
                art:parseNode($desc)
                ,
                $element/item,
                for $example in $element/example[string-length(text()) gt 0]
                return
                <example>
                {
                    $example/@*[string-length()>0],
                    util:parse($example/text())
                }
                </example>
                ,
                for $item in $element/constraint
                return
                local:processElement($item)
            }
            </include>
        else if ($element/name()='let') then
            $element
        else if ($element/name()='assert') then
            art:parseNode($element)
        else if ($element/name()='report') then
            art:parseNode($element)
        else if ($element/name()='defineVariable') then
            $element
        else if ($element/name()='constraint') then
            art:parseNode($element)
        else()
    (:else if ($element/name()=('let','assert','report','defineVariable')) then
        $element
    else if ($element/name()='constraint') then
        art:parseNode($element):)
    else()
};
declare function local:processAttribute($attribute as element()) as element()? {
    if ($attribute/@selected) then
        <attribute>
        {
            $attribute/(@*[string-length()>0] except (@selected|@originalOpt|@originalType|@prohibited|@conf|@isOptional))
            ,
            if ($attribute/@conf='isOptional') then
                attribute isOptional {'true'}
            else if ($attribute/@conf='prohibited') then
                attribute prohibited {'true'}
            else()
            ,
            for $desc in $attribute/desc
            return
            art:parseNode($desc)
            ,
            if (string-length($attribute/item/@label) gt 0) then
                <item label="{$attribute/item/@label}">
                {
                    for $desc in $attribute/item/desc[string-length(text()) gt 0]
                    return
                    art:parseNode($desc)
                }
                </item>
            else()
            ,
            for $vocabulary in $attribute/vocabulary
            where some $att in $vocabulary/@* satisfies $att/string-length() gt 0
            return
            <vocabulary>{$vocabulary/(@*[string-length()>0] except @linkedartefactmissing),$vocabulary/node()}</vocabulary>
        }
        </attribute>
    else()
};

let $editedTemplate     := if (request:exists()) then request:get-data()/template else ()

let $lock               := $get:colArtResources//lock[@ref=$editedTemplate/lock/@ref][@effectiveDate=$editedTemplate/lock/@effectiveDate]

(:get decor file form project prefix:)
let $decor              := $get:colDecorData//decor[project/@prefix=$editedTemplate/@projectPrefix]
(: get user for permission check:)
let $user               := xmldb:get-current-user()

let $defaultLanguage    := $decor/project/@defaultLanguage/string()
let $preparedTemplate   :=
    if ($user=$decor/project/author/@username and $lock) then
        <template>
        {
            $editedTemplate/(@*[string-length()>0] except (@baseId|@projectPrefix|@ident|@url)),
            for $desc in $editedTemplate/desc
            return
            art:parseNode($desc),
            $editedTemplate/classification
            ,
            for $relationship in $editedTemplate/relationship
            return
            <relationship>
            {
            $relationship/@type,
            $relationship/@*[name()=$relationship/@selected],
            $relationship/@flexibility[string-length()>0]
            }
            </relationship>
            ,
            if ($editedTemplate/context/@selected=('id','path')) then
                <context>
                {$editedTemplate/context/@*[name()=$editedTemplate/context/@selected]}
                </context>
            else()
            ,
            if (string-length($editedTemplate/item/@label) gt 0) then
                <item label="{$editedTemplate/item/@label}">
                {
                    for $desc in $editedTemplate/item/desc[string-length(text()) gt 0]
                    return
                    art:parseNode($desc)
                }
                </item>
            else()
            ,
            for $example in $editedTemplate/example[string-length(text()) gt 0]
            return
            <example>
            {
                $example/@*[string-length()>0],
                util:parse($example/text())
            }
            </example>
            ,
            for $attribute in $editedTemplate/attribute
            return
            local:processAttribute($attribute)
            ,
            for $item in $editedTemplate/(element|include|choice|let|assert|report|defineVariable|constraint)
            return
            local:processElement($item)
        }
        </template>
    else ()
let $currentTemplate    := $decor/rules/template[@id=$preparedTemplate/@id][@effectiveDate=$preparedTemplate/@effectiveDate]

let $update             :=
    if ($preparedTemplate) then
        <update>
        {
            if ($currentTemplate) then (
                update replace $currentTemplate with $preparedTemplate
            )
            else if ($decor/rules) then (
                update insert $preparedTemplate into $decor/rules
            )
            else (
                update insert <rules>{$preparedTemplate}</rules> following $decor/terminology
            )
            ,
            update delete $lock
        }
        </update>
    else (
        <message>No Permission</message>
    )

return
<data-safe id="{$editedTemplate/@id}" effectiveDate="{$editedTemplate/@effectiveDate}">{exists($update/update)}</data-safe>