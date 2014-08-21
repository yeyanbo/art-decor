xquery version "3.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Alexander henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

declare function local:addValueSetRef($decor as element(), $repoPrefix as xs:string, $association as element()) as item()* {
    let $repoDecor          := $get:colDecorData//decor[project/@prefix=$repoPrefix]
    
    let $repoVs             := $repoDecor/terminology/valueSet[(@id|@ref|@name)=$association/@valueSet][1]
    let $projectVs          := $decor/terminology/valueSet[(@id|@ref|@name)=$association/@valueSet][1]
    
    let $valueSetRefElm     := <valueSet ref="{$repoVs/(@id|@ref)}" name="{$repoVs/@name}">{$repoVs/@displayName}</valueSet>
    
    (: request:get-hostname() will give 127.0.0.1 :)
    let $hostNameAndPort    := replace(request:get-url(),'^https?://?([^/]+).*','$1')
    let $buildingBlockElm   := <buildingBlockRepository url="http://{$hostNameAndPort}/decor/services/" ident="{$repoPrefix}"/>
    
    let $addValueSetRef      :=
        if (empty($projectVs) or $projectVs/(@id|@ref) != $repoVs/(@id|@ref)) then (
            let $dummy1 := update insert $valueSetRefElm following $decor/terminology/*[last()]
            let $dummy2 := 
                if (not($decor/project/buildingBlockRepository[@url=$buildingBlockElm/@url][@ident=$buildingBlockElm/@ident])) then (
                    let $dummy3 := update insert $buildingBlockElm following $decor/project/(author|reference|restURI|defaultElementNamespace|contact)[last()]
                    return 'true'
                ) else ('false')
            
            return if ($dummy2='true') then 'ref-and-bbr' else 'ref'
        ) 
        else ()
    
    return
        if ($addValueSetRef='ref-and-bbr') then
            <info>The terminology association points to value set {$valueSetRefElm/@name/string()} ({$valueSetRefElm/@ref/string()}) that did not exist yet, so a value set reference was created. A building 
                block repository link with url {$buildingBlockElm/@url/string()} and ident {$buildingBlockElm/@ident/string()} was also created to make this reference work.</info>
        else if ($addValueSetRef='ref') then
            <info>The terminology association points to value set {$valueSetRefElm/@name/string()} ({$valueSetRefElm/@ref/string()}) that did not exist yet, so a value set was created. The building 
                block repository link required to make this reference work already existed so it was not created.</info>
        else ()
};

let $result:= 
    try {
        let $projectPrefix          := if (request:exists()) then request:get-parameter('prefix',()) else ()
        let $terminologyAssociation := if (request:exists()) then request:get-data()/association else ()
        (:let $terminologyAssociation :=
        <association conceptId="2.16.840.1.113883.2.4.3.46.99.3.2.3" conceptEffectiveDate="2011-01-28T00:00:00" effectiveDate="" code="372897005" displayName="Salbutamol" codeSystem="2.16.840.1.113883.6.96" codeSystemName="Snomed-ct"/>
        :)
        (:let $projectPrefix          := 'cbs-dstat-'
        let $terminologyAssociation := <association conceptId="2.16.840.1.113883.2.4.3.11.60.101.2.1.20040.0" conceptEffectiveDate="" effectiveDate="" code="" displayName="" codeSystem="" codeSystemName="" codeSystemVersion="" valueSet="Geslacht" flexibility="" expirationDate="" versionLabel="" inheritFromPrefix="naw-"/>:)
        
        let $effectiveDate    := 
            if ($terminologyAssociation/@effectiveDate[string-length()>0]) then 
                $terminologyAssociation/@effectiveDate
            else (datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss"))
        
        let $newAssociation :=
        <terminologyAssociation conceptId="{$terminologyAssociation/@conceptId}" effectiveDate="{$effectiveDate}">
        {
            $terminologyAssociation/(@*[string-length()>0][name()=('code','codeSystem','codeSystemName','codeSystemVersion','displayName','valueSet','flexibility')])
        }
        </terminologyAssociation>
        
        let $decor              := 
            if (not(empty($projectPrefix))) then
                $get:colDecorData//decor[project/@prefix=$projectPrefix]
            else (
                let $concept := $get:colDecorData//concept[@id=$terminologyAssociation/@conceptId]
                return
                    $concept/ancestor::decor
            )
        
        let $updateAssociation  :=
            if (not($decor/terminology)) then (
                update insert <terminology/> following $decor/ids,
                update insert $newAssociation into $decor/terminology
            )
            else if ($decor/terminology/terminologyAssociation) then (
                update insert $newAssociation following $decor/terminology/terminologyAssociation[count($decor/terminology/terminologyAssociation)]
            )
            else (
                update insert $newAssociation preceding $decor/terminology/*[1]
            )
        
        let $updateAssociation  :=
            if ($newAssociation[@valueSet] and $terminologyAssociation[string-length(@inheritFromPrefix)>0][not(@inheritFromPrefix=$projectPrefix)]) then
                local:addValueSetRef($decor, $terminologyAssociation/@inheritFromPrefix, $terminologyAssociation)
            else ()
            
        return ($updateAssociation)
    }
    catch * {
        <error>{concat('ERROR ',$err:code,' in save: ',$err:description,' module: ',$err:module,' (',$err:line-number,' ',$err:column-number,')')}</error>
    }

return
    <data-safe>
    {
        
        if ($result instance of element(error)) then
            attribute error {$result}
        else if ($result instance of element(info)) then
            attribute info {$result}
        else ()
    }
    {
        (:make sure we return false or true:)
        not($result instance of element(error))
    }
    </data-safe>