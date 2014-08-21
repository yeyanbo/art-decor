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

import module namespace get    = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art    = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace aduser = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";

declare function local:resolveInherit($concept as element(),$conceptList as element()) as element() {
let $id := $concept/@id
return
    if ($concept/inherit/@ref) then
        let $inheritedConcept    := $get:colDecorData//concept[@id=$concept/inherit/@ref][@effectiveDate=$concept/inherit/@effectiveDate][not(ancestor::history)]
        
        let $resolvedConcept     := art:conceptBasics($inheritedConcept)
        let $originalConceptName := art:getOriginalConceptName($concept/inherit)
        return
        <concept id="{$id}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}" 
                 expirationDate="{$concept/@expirationDate}" officialReleaseDate="{$concept/@officialReleaseDate}"
                 versionLabel="{$concept/@versionLabel}" type="{$resolvedConcept/@type}">
        {
            $concept/edit,
            $concept/conceptLock,
            <inherit ref="{$concept/inherit/@ref}" effectiveDate="{$concept/inherit/@effectiveDate}">
            {
                $inheritedConcept/ancestor::decor/project/@prefix,
                attribute datasetId {$inheritedConcept/ancestor::dataset/@id},
                attribute iType {$resolvedConcept/@type}, 
                attribute iStatusCode {$inheritedConcept/@statusCode}, 
                attribute iExpirationDate {$inheritedConcept/@expirationDate},
                attribute iVersionLabel {$inheritedConcept/@versionLabel},
                attribute iddisplay {art:getNameForOID($concept/inherit/@ref,$inheritedConcept/ancestor::decor/project/@defaultLanguage,$inheritedConcept/ancestor::decor/project/@prefix)}
            }
            </inherit>,
            for $name in $resolvedConcept/name
            return
            art:serializeNode($name)
            ,
            for $subConcept in $inheritedConcept/concept[concat(@id,@effectiveDate)=$conceptList/inherit or concept/concat(@id,@effectiveDate)=$conceptList/inherit or count($conceptList/inherit)=0]
            let $storedConcept    := $get:colDecorData//concept[@id=$concept/@id][@effectiveDate=$concept/@effectiveDate]
            let $dataset          := $storedConcept/ancestor::dataset
            let $decor            := $dataset/ancestor::decor
            let $conceptBaseId    := $decor//defaultBaseId[@type='DE']/@id/string()
            let $username         := xmldb:get-current-user()
            let $userDisplayName  := aduser:getUserDisplayName($username)
            let $newId            := concat($conceptBaseId,'.',max($dataset//concept[starts-with(@id,concat($conceptBaseId,'.'))]/number(tokenize(@id,'\.')[last()]))+1)
            let $newEffectiveDate := datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")
            let $newLock          := <conceptLock ref="{$newId}" effectiveDate="{$newEffectiveDate}" user="{$username}" userName="{$userDisplayName}" since="{current-dateTime()}"/>
            let $insertLock       := update insert $newLock into $get:colArtResources//decorLocks
            let $newConcept       :=
                <concept id="{$newId}" type="{$subConcept/@type}" statusCode="new" effectiveDate="{$newEffectiveDate}">
                    <edit mode="edit"/>
                    {$newLock}
                    <inherit ref="{$subConcept/@id}" effectiveDate="{$subConcept/@effectiveDate}">
                    {
                        $subConcept/ancestor::decor/project/@prefix,
                        attribute datasetId {$subConcept/ancestor::dataset/@id},
                        attribute iType {$subConcept/@type}, 
                        attribute iStatusCode {$subConcept/@statusCode}, 
                        attribute iExpirationDate {$subConcept/@expirationDate},
                        attribute iVersionLabel {$subConcept/@versionLabel},
                        attribute iddisplay {art:getNameForOID($concept/inherit/@ref,$subConcept/ancestor::decor/project/@defaultLanguage,$subConcept/ancestor::decor/project/@prefix)}
                    }
                    </inherit>
                </concept>
            let $insertNewConcept := update insert $newConcept into $storedConcept
            return
                local:resolveInherit($newConcept,$conceptList)
            ,
            $concept/history
        }
        </concept>
    else()
};

let $concept := if (request:exists()) then request:get-data()/concept else ()

let $conceptList := 
    <conceptList baseRoot="{concat(string-join(tokenize($concept/@id,'\.')[position()!=last()],'.'),'.')}" baseId="{tokenize($concept/@id,'\.')[last()]}" effectiveDate="{$concept/@effectiveDate}">
    {
        for $id in tokenize($concept/concepts,'\s')
        return
        <inherit>{$id}</inherit>
    }
    </conceptList>

return
    local:resolveInherit($concept,$conceptList)