xquery version "3.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
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
declare namespace error     = "http://art-decor.org/ns/decor/terminology/error";

(: function will purposely error when no match or more than one match is found :)
declare function local:getTerminologyAssociation($projectPrefix as xs:string, $s_cid as xs:string, $s_valueSet as xs:string?, $s_code as xs:string?, $s_codeSystem as xs:string?, $s_effectiveDate as xs:string?, $s_statusCode as xs:string?) as element() {
    $get:colDecorData//decor[project/@prefix=$projectPrefix]/terminology/terminologyAssociation[@conceptId=$s_cid][empty($s_valueSet) or @valueSet=$s_valueSet][empty($s_code) or (@code=$s_code and @codeSystem=$s_codeSystem)][empty($s_statusCode) or @statusCode=$s_statusCode][empty($s_effectiveDate) or @effectiveDate=$s_effectiveDate]
};

let $projectPrefix          := if (request:exists()) then request:get-parameter('prefix',()) else ()
let $updatedAssociation     := if (request:exists()) then request:get-data()/updatedAssociation else ()

(:let $projectPrefix        := 'jgz-'
let $updatedAssociation     :=
    <updatedAssociation conceptId="2.16.840.1.113883.2.4.3.11.60.100.2.4.2.1" effectiveDate="" statusCode="draft" versionLabel="" expirationDate="" actionText="Set status to 'draft'">
        <association conceptId="2.16.840.1.113883.2.4.3.11.60.100.2.4.2.1" code="01" codeSystem="2.16.840.1.113883.2.4.3.11.60.100.12.16" codeSystemName="W0016 Soort telefoonnummer (BDS)" displayName="Huisnummer" valueSet="" valueSetName="" flexibility="" effectiveDate="2014-02-26T03:56:58" expirationDate="" statusCode="" versionLabel=""/>
    </updatedAssociation>:)

let $s_cid                  := $updatedAssociation/association[1]/@conceptId[string-length()>0]
let $s_code                 := $updatedAssociation/association[1]/@code[string-length()>0]
let $s_codeSystem           := $updatedAssociation/association[1]/@codeSystem[string-length()>0]
let $s_valueSet             := $updatedAssociation/association[1]/@valueSet[string-length()>0]
let $s_effectiveDate        := $updatedAssociation/association[1]/@effectiveDate[string-length()>0]
let $s_statusCode           := $updatedAssociation/association[1]/@statusCode[string-length()>0]
let $s_versionLabel         := $updatedAssociation/association[1]/@versionLabel[string-length()>0]

(: 
    the only 'statusCode' we currently will support is 'removed'. This is not an actual statusCode, 
    but an instruction to delete the terminologyAssociation
    It's very well possible that in some future stage, terminologyAssociations will have a statusCode.
:)
let $u_statusCode           := $updatedAssociation/@statusCode[.='removed']
let $u_versionLabel         := $updatedAssociation/@versionLabel[string-length()>0]
let $u_expirationDate       := 
    if ($updatedAssociation/@expirationDate castable as xs:date) then
        concat($updatedAssociation/@expirationDate,'T00:00:00')
    else if ($updatedAssociation/@expirationDate castable as xs:dateTime) then
        $updatedAssociation/@expirationDate
    else ()
   
let $now                    := datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")

let $result                 :=
    try {
        (: function will purposely error when no match or more than one match is found :)
        let $currentAssociation     := local:getTerminologyAssociation($projectPrefix, $s_cid, $s_valueSet, $s_code, $s_codeSystem, $s_effectiveDate, ())
        
        return
        if ($u_statusCode='removed') then
            update delete $currentAssociation
        else (
            (:if ($u_statusCode) then
                if ($currentAssociation[@statusCode]) then
                    update value $currentAssociation/@statusCode with $u_statusCode
                else (
                    update insert attribute statusCode {$u_statusCode} into $currentAssociation
                )
            else (
                update delete $currentAssociation/@statusCode
            )
            ,:)
            if ($u_versionLabel) then 
                if ($currentAssociation[@versionLabel]) then
                    update value $currentAssociation/@versionLabel with $u_versionLabel
                else (
                    update insert attribute versionLabel {$u_versionLabel} into $currentAssociation
                )
            else (
                update delete $currentAssociation/@versionLabel
            )
            ,
            if ($u_expirationDate) then 
                if ($currentAssociation[@expirationDate]) then
                    update value $currentAssociation/@expirationDate with $u_expirationDate
                else (
                    update insert attribute expirationDate {$u_expirationDate} into $currentAssociation
                )
            else if ($u_statusCode='retired') then
                if ($currentAssociation[@expirationDate]) then
                    update value $currentAssociation/@expirationDate with $now
                else (
                    update insert attribute expirationDate {$now} into $currentAssociation
                )
            else (
                update delete $currentAssociation/@expirationDate
            )
        )
    }
    catch * {
        <error>{concat('ERROR ',$err:code,' in save: ',$err:description,' module: ',$err:module,' (',$err:line-number,' ',$err:column-number,')')}</error>
    }

return
    <data-safe>
    {
        if ($result instance of element(error)) then
            attribute error {$result}
        else ()
    }
    {
        (:make sure we return false or true:)
        not($result instance of element(error))
    }
    </data-safe>