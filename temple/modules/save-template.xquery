xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw

    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace response      = "http://exist-db.org/xquery/response";
declare namespace util          = "http://exist-db.org/xquery/util";
declare namespace validation    = "http://exist-db.org/xquery/validation";

(: copied from ada :)
declare function local:validateSchema($doc as node()) as node() {
    (: Using the schema at 'http://art-decor.org/ADAR/rv/DECOR.xsd' throws a SAX error, using the local schema does not. :)
    validation:jaxv-report($doc, $get:docDecorSchema)
};

(: Checks whether a status change is allowed, now rudimentary. oldStatus may be empty sequence. :)
declare function local:allowStatusChange($oldStatus as xs:string?, $newStatus as xs:string?, $objectType as xs:string) as xs:boolean {
    let $allowed := if (($oldStatus ='final') or ($oldStatus ='cancelled') or ($oldStatus ='rejected')) then false() else true()
    return $allowed
};

declare function local:saveTemplate($prefix as xs:string, $newRules as node(), $reportOnly as xs:string) as element(){
    let $decor := collection('/db/apps/decor/data')//decor[project/@prefix=$prefix]
    let $user := xmldb:get-current-user()
    let $isAuthor := $decor/project/author[@username=$user]
    let $assert :=  if ($isAuthor) then () 
        else error(QName('http://art-decor.org/ns/error', 'YouAreNoAuthor'), concat('User ', $user, ' is not an author in this project'))
    let $logfile    := doc('/db/apps/temple/xml/log.xml')
    let $logon      := false()
    let $assert :=  if (count($newRules//template) = 1) then () 
        else error(QName('http://art-decor.org/ns/error', 'MoreOrLessThanOneTemplate'), 'Rules must contain exactly one template')
    let $assert :=  if (count($newRules//templateAssociation) <= 1) then () 
        else error(QName('http://art-decor.org/ns/error', 'MoreThanOneTemplateAssociation'), 'Rules may not contain more than one templateAssociation')
    let $newId := $newRules//template/@id
    let $newEffectiveDate := $newRules//template/@effectiveDate
    (: Make a templateAssociation if one doesn't exist. We also set templateId and effectiveDate to the same values as on template,
    so user may omit them. :)
    let $newRules :=
        <rules>{
            element templateAssociation {attribute templateId {$newId}, attribute effectiveDate {$newEffectiveDate}, $newRules//templateAssociation/concept},
            $newRules//template
        }</rules>

    let $oldTemplateAssociation := $decor//templateAssociation[@templateId=$newId][@effectiveDate=$newEffectiveDate]
    let $oldTemplate := $decor//template[@id=$newId][@effectiveDate=$newEffectiveDate]
    (: Make a new template when submitted one has id 'new', or submitted id exists but submitted effectiveDate not :)
    let $makeNewTemplate :=
        (: Template with id and effectiveDate exists :)
        if ($oldTemplate) then false()
        (: A new template, new id must be issued :)
        else if ($newRules//template[ends-with(@id,'new')]) then true()
        (: Template with this id exists, but not this effectiveDate :)
        else if ($decor//template[@id=$newId]) then true()
        (: Id does not exist and != 'new :)
        else error(QName('http://art-decor.org/ns/error', 'IdNotValid'), "Template/@id must either exist or be '{some baseId}.new'.")
    
    let $assert :=  if (not($makeNewTemplate and $decor//template[@name=$newRules//template/@name][@effectiveDate=$newEffectiveDate])) then () 
        else error(QName('http://art-decor.org/ns/error', 'TemplateByNameAndDateExists'), "A template with this name and effectiveDate already exists.")
    
    (: Issue new id :)
    (: MdG Note to self: Code copied from create-decor-template.xquery. I cannot use the entire xquery, code like 
    this - and more - should be refactored into templates api :)
    let $templateRoot := 
        if ($newRules//template/replace(@id,'.new','')[string-length()>0]) 
        then ($newRules//template/replace(@id,'.new',''))
        else ($decor/ids/defaultBaseId[@type='TM']/@id/string())
    
    (:get existing template ids, if none return 0:)
    let $templateIds := 
        for $id in $decor/rules/template/@id/string()
        return
            if (substring-after($id,concat($templateRoot,'.')) castable as xs:integer) then
                xs:integer(substring-after($id,concat($templateRoot,'.')))
            else (0)
    
    (:generate new id if mode is 'new' or 'adapt', else use existing id:)
    let $newId := 
        if ($newRules//template[ends-with(@id,'new')]) then
            if (count($decor/rules//template)>0) then
                concat($templateRoot,'.',max($templateIds)+1)
            else(concat($templateRoot,'.',1))
        else($newId)
    
    let $newRules := 
        if ($newRules//template[ends-with(@id,'new')]) then
            <rules>{
                element templateAssociation {
                    attribute templateId {$newId},
                    $newRules//templateAssociation/(@* except @templateId),
                    $newRules//templateAssociation/*
                    },
                element template {
                    attribute id {$newId},
                    $newRules//template/(@* except (@id, @statusCode)),
                    attribute statusCode {'draft'},
                    $newRules//template/*
                    }
            }</rules>
        else $newRules
    (: Validate against decor.xsd :)
    let $schemaResults  := local:validateSchema($newRules)
    let $assert         :=  
        if (not($schemaResults//status="invalid")) 
        then () 
        else error(QName('http://art-decor.org/ns/error', 'NotSchemaValid'), $schemaResults)
    let $assert         := 
        for $concept in $newRules//templateAssociation/concept
        return 
            if ($decor//dataset//concept[@id=$concept/@ref][@effectiveDate=$concept/@effectiveDate]) 
            then () 
            else error(QName('http://art-decor.org/ns/error', 'ConceptDoesNotExist'), concat('Concept id=', $concept/@ref, ' effectiveDate=', $concept/@effectiveDate, 'in templateAssociation/concept does not exist.'))
    (: Check status :)
    let $statusAllowed  := local:allowStatusChange($oldTemplate/@statusCode, $newRules//template/@statusCode[1], 'template')
    let $assert         :=  if ($statusAllowed) then () 
        else error(QName('http://art-decor.org/ns/error', 'StatusChangeNotAllowed'), concat('Setting status from ', $oldTemplate/@statusCode, ' to ', $newRules//template/@statusCode, ' is not allowed'))
    (: Block updates if an error occurred :)
    let $update         := if ($reportOnly = 'true') then (<ok/>) else
        (
        if ($logon) 
            then 
            update insert 
                <update user="{$user}" time="{fn:current-dateTime()}">
                    <old><rules>{$oldTemplateAssociation, $oldTemplate}</rules></old>
                    <new>{$newRules}</new>
                </update>
            into $logfile/logroot 
            else <nothing/>,
        if ($makeNewTemplate) 
            then (
            update insert $newRules//templateAssociation into $decor/rules,
            update insert $newRules//template into $decor/rules
            )
            else (
            update replace $decor//templateAssociation[@templateId=$newId][@effectiveDate=$newEffectiveDate] with $newRules//templateAssociation,
            update replace $decor//template[@id=$newId][@effectiveDate=$newEffectiveDate] with $newRules//template
            ),
        <ok/>
        )
    return $newRules
};

let $prefix         := if (request:exists()) then request:get-parameter('prefix', '') else ''
let $code           := if (request:exists()) then request:get-parameter('code', '') else ''
let $reportOnly     := if (request:exists()) then request:get-parameter('reportOnly', 'false') else 'false'
let $newRules :=  
    try {util:parse($code)}
    catch * {
        <templeError>{concat('Temple parsing error, code: ', $err:code, ', description: ', $err:description)}</templeError>
    }
(: When there is a parsing error, save and validate. If there is a schema validation error, validate again to catch output,
else rturn the error as is. :)
let $result := if (local-name($newRules)='templeError') then $newRules else
    try {local:saveTemplate($prefix, $newRules, $reportOnly)}
    (:catch NotSchemaValid {
        local:validateSchema($newRules)
    }:)
    catch * {
        <templeError>{concat('Temple validation error, code: ', $err:code, ', description: ', $err:description)}</templeError>
    }

let $dummy := 
    if (($result//status="invalid") or (local-name($result)='templeError')) 
    then (response:set-status-code(400)) 
    else (response:redirect-to(xs:anyURI(concat('temple.xquery?prefix=', $prefix, '&amp;id=', $result//template/@id, '&amp;effectiveDate=', $result//template/@effectiveDate))))
return $result