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

declare function local:processElement($element as element(),$prototypeId as xs:string,$newTemplateId as xs:string, $newElementId as xs:string) as element()? {
    if ($element/@selected) then
        if ($element/name()='element') then
            <element>
            {
                $element/(@*[string-length()>0] except (@id|@selected|@tmid|@tmname|@tmdisplayName|@originalType|@originalMin|@originalMax|@linkedartefactmissing|@concept|@conformance|@flexibility|@isMandatory)),
                if ($element/@conformance!='O') then
                   $element/@conformance
                else(),
                if ($element/@flexibility!='dynamic' and string-length($element/@flexibility)>0) then
                   $element/@flexibility
                else(),
                if ($element/@isMandatory='true') then
                   $element/@isMandatory
                else(),
                if ($element/@concept) then
                   attribute id {$newElementId}
                else(),
                for $desc in $element/desc
                return
                art:parseNode($desc)
                ,
                $element/item,
                for $example in $element/example[string-length(text())>0]
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
                local:processAttribute($attribute,$newTemplateId)
                ,
                for $item in $element/*[name()=('element','include','choice','let','assert','report','defineVariable','constraint')]
                return
                local:processElement($item,$prototypeId,$newTemplateId,$newElementId)
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
                local:processElement($item,$prototypeId,$newTemplateId,$newElementId)
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
                local:processElement($item,$prototypeId,$newTemplateId,$newElementId)
            }
            </include>
        else if ($element/name()='let') then
            $element
        else if ($element/name()='assert') then
            $element
        else if ($element/name()='report') then
            $element
        else if ($element/name()='defineVariable') then
            $element
        else if ($element/name()='constraint') then
           art:parseNode($element)
        else()
    else if ($element/name()=('let','assert','report','defineVariable')) then
        $element
    else if ($element/name()='constraint') then
        art:parseNode($element)
    else ()
};

declare function local:processAttribute($attribute as element(),$newTemplateId as xs:string) as element()? {
    if ($attribute/@selected) then
        <attribute>
        {
            $attribute/(@*[string-length()>0] except (@selected|@originalOpt|@originalType|@prohibited|@conf|@isOptional|@value))
            ,
            if ($attribute/@name='root' and $attribute/../@name='hl7:templateId' and matches($attribute/@value,'[a-zA-Z]')) then
                attribute value {$newTemplateId}
            else($attribute/@value)
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
                    for $desc in $attribute/item/desc[string-length(text())>0]
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
    else ()
   
};


let $newTemplate    := request:get-data()/template

(:get decor file form project prefix:)
let $decor          := $get:colDecorData//decor[project/@prefix=$newTemplate/@projectPrefix]
(: get user for permission check:)
let $user           := xmldb:get-current-user()

let $defaultLanguage := $decor/project/@defaultLanguage/string()

let $response :=
    (:check if user id author in project:)
    if ($user=$decor/project/author/@username) then (
        (:if a baseId is present use it, else use default template baseId:)
        let $templateRoot :=
            if (string-length($newTemplate/@baseId)>0) then
                $newTemplate/@baseId/string()
            else
                ($decor/ids/defaultBaseId[@type='TM']/@id/string())
        (:get existing template ids, if none return 0:)
        let $templateIds := 
            for $id in $decor/rules//template/@id/string()
            return
            if (substring-after($id,concat($templateRoot,'.')) castable as xs:integer) then
                xs:integer(substring-after($id,concat($templateRoot,'.')))
            else 
                (0)
        (:generate new id if mode is 'new' or 'adapt', else use existing id:)
        let $newTemplateId := 
            if ($newTemplate/@mode=('new','adapt')) then
                if (count($decor/rules//template)>0) then
                    concat($templateRoot,'.',max($templateIds)+1)
                else(concat($templateRoot,'.',1))
            else
                ($newTemplate/@id)
          
        let $templateElementRoot := $decor/ids/defaultBaseId[@type='EL']/@id/string()
        let $templateElementIds  := 
            for $id in $decor/rules//element/@id/string()
            return
                if (substring-after($id,concat($templateElementRoot,'.')) castable as xs:integer) then
                    xs:integer(substring-after($id,concat($templateElementRoot,'.')))
                else
                    (0)
        let $newTemplateElementId := 
            if (count($decor/rules//element)>0) then
                concat($templateElementRoot,'.',max($templateElementIds)+1)
            else
                (concat($templateElementRoot,'.',1))
        let $templateEffectiveTime :=datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")
        let $prototypeId := $newTemplate/@id/string()
        return
        <insert>
        {
            comment{$newTemplate/@displayName},
            (:if mode is 'new' and conceptId is present, create new templateAssociation for concept:)
            if ($newTemplate/@mode='new' and $newTemplate/@conceptId) then
                <templateAssociation templateId="{$newTemplateId}" effectiveDate="{$templateEffectiveTime}">
                    <concept ref="{$newTemplate/@conceptId}" effectiveDate="{$newTemplate/@conceptEffectiveDate}" elementId="{$newTemplateElementId}"/>
                </templateAssociation>
            (:if mode id 'version' or 'adapt' copy existing associations into new templateAssociation:)
            else if ($newTemplate/@mode=('version','adapt')) then
                let $existingTemplateAssociation := $decor//templateAssociation[@templateId=$newTemplate/@id][@effectiveDate=$newTemplate/@effectiveDate]
                return
                <templateAssociation templateId="{$newTemplateId}" effectiveDate="{$templateEffectiveTime}">
                {$existingTemplateAssociation/concept}
                </templateAssociation>
            else ()
        }
            <template id="{$newTemplateId}" name="{$newTemplate/@name}" effectiveDate="{$templateEffectiveTime}" statusCode="draft">
            {
                $newTemplate/@displayName[string-length()>0],
                $newTemplate/@isClosed[string-length()>0],
                $newTemplate/@expirationDate[string-length()>0],
                $newTemplate/@officialReleaseDate[string-length()>0],
                $newTemplate/@versionLabel[string-length()>0],
                for $desc in $newTemplate/desc
                return
                art:parseNode($desc),
                $newTemplate/classification
                ,
                for $relationship in $newTemplate/relationship
                return
                <relationship>
                {
                    $relationship/@type,
                    $relationship/@*[name()=$relationship/@selected],
                    $relationship/@flexibility[string-length()>0]
                }
                </relationship>
                ,
                if ($newTemplate/context/@selected=('id','path')) then
                <context>
                    {$newTemplate/context/@*[name()=$newTemplate/context/@selected]}
                </context>
                else()
                ,
                if (string-length($newTemplate/item/@label) gt 0) then
                    <item label="{$newTemplate/item/@label}">
                    {
                        for $desc in $newTemplate/item/desc[string-length(text()) gt 0]
                        return
                        art:parseNode($desc)
                    }
                    </item>
                else()
                ,
                for $example in $newTemplate/example[string-length(text()) gt 0]
                return
                <example>
                {
                $example/@*[string-length()>0],
                util:parse($example/text())
                }
                </example>
                ,
                for $attribute in $newTemplate/attribute
                return
                local:processAttribute($attribute,$newTemplateId)
                ,
                for $item in $newTemplate/*[name()=('element','include','choice','let','assert','report','defineVariable','constraint')]
                return
                local:processElement($item,$prototypeId,$newTemplateId,$newTemplateElementId)
            }
            </template>
        </insert>
    
    )
    else (
        <message>No Permission</message>
    )
return

<data-safe id="{$response/template/@id}" effectiveDate="{$response/template/@effectiveDate}">
{
    if ($response/template) then (
        let $update :=
            if (not($decor/rules)) then (
                update insert <rules/> following $decor/terminology,
                update insert $response/node() into $decor/rules
            ) 
            else if ($decor/rules/template) then (
                (:if this is a new version, insert below old version:)
                if ($newTemplate/@mode='version') then
                    update insert $response/node() following $decor/rules/template[@id=$newTemplate/@id]
                else (
                    update insert $response/node() following $decor/rules/template[count($decor/rules/template)]
                )
            )
            else (
                update insert $response/node() into $decor/rules
            )
        return 'true'
    )
    else (
        'false'
    )

}
</data-safe>