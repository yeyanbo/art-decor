xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Alexander Henket

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

declare function local:buildValueSet($editedValueset as element(), $baseValueset as element()) as element() {
    <valueSet>
    {
        $baseValueset/@*
    }
    {
        for $desc in $editedValueset/desc[.//text()[string-length()>0]]
        return
        art:parseNode($desc)
    }
    {
        (:want at least a @name on publishingAuthority for it to persist:)
        for $authority in $editedValueset/publishingAuthority[@name[string-length()>0]]
        return
        <publishingAuthority>
        {
            $authority/@*[string-length()>0]
            ,
            for $addrLine in $authority/addrLine[string-length()>0]
            return <addrLine>{$addrLine/@*[string-length()>0],$addrLine/node()}</addrLine>
        }
        </publishingAuthority>
    }
    {
        (:want at least a @name on endorsingAuthority for it to persist:)
        for $authority in $editedValueset/endorsingAuthority[@name[string-length()>0]]
        return
        <endorsingAuthority>
        {
            $authority/@*[string-length()>0]
            ,
            for $addrLine in $authority/addrLine[string-length()>0]
            return <addrLine>{$addrLine/@*[string-length()>0],$addrLine/node()}</addrLine>
        }
        </endorsingAuthority>
    }
    {
        $editedValueset/copyright[string-length()>0]
    }
    {
        (:want at least a @date on revisionHistory for it to persist:)
        for $revisionHistory in $editedValueset/revisionHistory[string-length(@date)>0]
        return
        <revisionHistory>
        {
            $revisionHistory/@*[string-length()>0],
            for $desc in $revisionHistory/desc
            return
                art:parseNode($desc)
        }
        </revisionHistory>
    }
    {
        for $completeCodeSystem in $editedValueset/completeCodeSystem[string-length(@codeSystem)>0]
        return
        <completeCodeSystem>{$completeCodeSystem/@*[string-length()>0]}</completeCodeSystem>
    }
    {
        if ($editedValueset/conceptList[concept|include|exception]) then
            <conceptList>
            {
                for $concept in $editedValueset/conceptList/concept[string-length(@code)>0][string-length(@codeSystem)>0]
                return
                <concept>{$concept/@*[string-length()>0], for $desc in $concept/desc[.//text()[string-length()>0]] return art:parseNode($desc)}</concept>
                ,
                for $include in $editedValueset/conceptList/include[string-length(@ref)>0]
                return
                <include>{$include/@*[string-length()>0], for $desc in $include/desc[.//text()[string-length()>0]] return art:parseNode($desc)}</include>
                ,
                for $exception in $editedValueset/conceptList/exception[string-length(@code)>0][string-length(@codeSystem)>0]
                return
                <exception>{$exception/@*[string-length()>0], for $desc in $exception/desc[.//text()[string-length()>0]] return art:parseNode($desc)}</exception>
            }
            </conceptList>
        else ()
    }
    </valueSet>
};

let $post           := if (request:exists()) then request:get-data()/valueSetVersions else ()

let $editedValueset := $post/valueSet
let $decor          := $get:colDecorData//decor[project/@prefix=$post/@projectPrefix]
(: get user for permission check:)
let $user           := xmldb:get-current-user()

let $response :=
    (:check if user is authorized:)
    if ($user=$decor/project/author/@username) then
        let $lock := $get:colArtResources//lock[@ref=$editedValueset/lock/@ref][@effectiveDate=$editedValueset/lock/@effectiveDate]
        return
        (:if there is a lock this valueset already exists:)
        if ($lock) then
            let $baseValueset     := <valueSet>{$editedValueset/@*[string-length()>0][not(name()=('baseId'))]}</valueSet>
            let $preparedValueSet := local:buildValueSet($editedValueset, $baseValueset)
            return (
                update replace $decor//valueSet[@id=$preparedValueSet/@id][@effectiveDate=$preparedValueSet/@effectiveDate] with $preparedValueSet,
                update delete $lock,
                <data-safe>true</data-safe>
            )
    else (
        (:if a baseId is present use it, else use default baseId:)
        let $valueSetRoot   :=
        if (string-length($editedValueset/@baseId)>0) then
            $editedValueset/@baseId/string()
        else (
            $decor/ids/defaultBaseId[@type='VS']/@id/string()
        )
        (:get existing valueSet ids, if none return 0:)
        let $valueSetIds    :=
            for $id in $decor//valueSet/@id/string()
            return
            if (substring-after($id,concat($valueSetRoot,'.')) castable as xs:integer) then
                xs:integer(substring-after($id,concat($valueSetRoot,'.')))
            else(0)
        (:generate new id if mode is 'new' or 'adapt', else use existing id:)
        let $newValueSetId  :=
            if ($editedValueset/edit/@mode=('new','adapt')) then
                if (count($decor/terminology/valueSet) gt 0) then
                    concat($valueSetRoot,'.',max($valueSetIds)+1)
                else(concat($valueSetRoot,'.',1))
            else($editedValueset/@id)
        let $baseValueset   := 
            <valueSet id="{$newValueSetId}" effectiveDate="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}" statusCode="draft">
            {
               $editedValueset/@*[string-length()>0][not(name()=('id','effectiveDate','statusCode','baseId'))]
            }
            </valueSet>
        let $newValueSet    := local:buildValueSet($editedValueset, $baseValueset)
        return (
            if (not($decor/terminology) and $decor/codedConcepts) then
                update insert <terminology/> following $decor/codedConcepts
            else if (not($decor/terminology) and not($decor/codedConcepts)) then
                update insert <terminology/> following $decor/ids
            else (),
            update insert $newValueSet into $decor/terminology,
            <data-safe>true</data-safe>
        )
    )
    else (<response>NO PERMISSION</response>)

return
$response
