xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw
    Author: Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace comp     = "http://art-decor.org/ns/art-decor-compile" at "../api/api-decor-compile.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../api/api-server-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace artx     = "http://art-decor.org/ns/art/xpath" at "art-decor-xpath.xqm";

declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

declare variable $strArtURL      := adserver:getServerURLArt();

let $data                := if (request:exists()) then request:get-data() else ()
let $projectPrefix       := if (request:exists()) then data($data/version/@prefix) else 'peri20-'
let $versionLabel        := if (request:exists()) then data($data/version/@versionLabel) else ()
let $noteOrDesc          := if (request:exists()) then $data/version/desc else <desc>test</desc>
let $compile-language    := if (request:exists()) then data($data/version/@compile-language) else 'nl-NL'
let $publication-request := if (request:exists()) then data($data/version/@publication-request) else 'false'
let $language            := if (request:exists()) then data($data/version/@language) else 'nl-NL'
let $by                  := if (request:exists()) then data($data/version/@by) else (xmldb:get-current-user())
let $release             := if (request:exists()) then data($data/version/@release) else 'true'
let $development         := if (request:exists()) then data($data/version/@development) else 'false'
let $timeStamp           := if ($development = 'true') then 'development' else substring-before(xs:string(current-dateTime()), '.')
let $decor               := $get:colDecorData//project[@prefix=$projectPrefix]/ancestor::decor
let $decor-author        := $decor/project/author[@username=xmldb:get-current-user()]
let $decor-paramfile     := concat(util:collection-name($decor),'/decor-parameters.xml')
let $decor-params        := if (doc-available($decor-paramfile)) then doc($decor-paramfile)/decor-parameters else ()
let $decor-parameters    := 
    if (empty($decor-params)) then (
        <decor-parameters>
            <switchCreateSchematron1/>
            <switchCreateSchematronWithWrapperIncludes0/>
            <switchCreateSchematronWithWarningsOnOpen0/>
            <switchCreateSchematronClosed0/>
            <switchCreateSchematronWithExplicitIncludes0/>
            <switchCreateDocHTML1/>
            <switchCreateDocSVG1/>
            <switchCreateDocDocbook0/>
            <useLocalAssets1/>
            <useLocalLogos1/>
            <useCustomLogo0/>
            <useLatestDecorVersion1/>
            <hideColumns>45gh</hideColumns>
            <inDevelopment0/>
            <switchCreateDatatypeChecks1/>
            <createDefaultInstancesForRepresentingTemplates0/>
            <!--<artdecordeeplinkprefix></artdecordeeplinkprefix>-->
            <!--<useCustomRetrieve1 hidecolumns=""/>-->
            <logLevel>INFO</logLevel>
        </decor-parameters>
    ) else 
        <decor-parameters> 
        {
            $decor-params/(* except (inDevelopment0|inDevelopment1|useLatestDecorVersion0|useLatestDecorVersion1)),
            <inDevelopment0/>,
            <useLatestDecorVersion1/>
        }
        </decor-parameters>

(: store the version itself :)
let $versionOrRelease := 
    if ($release='true') then 
        element release {
            attribute date {$timeStamp},
            attribute by {if ($by) then $by else if ($decor-author[string-length()>0]) then data($decor-author) else xmldb:get-current-user()},
            if ($versionLabel) then attribute versionLabel {$versionLabel} else (),
            if ($noteOrDesc) then (element note {$noteOrDesc/@*, art:parseNode($noteOrDesc)/node()}) else ()
        }
    else
        element version {
            attribute date {$timeStamp},
            attribute by {if ($by) then $by else if ($decor-author[string-length()>0]) then data($decor-author) else xmldb:get-current-user()},
            if ($noteOrDesc) then (art:parseNode($noteOrDesc)) else ()
        }
let $result := 
    if ($development = 'true') then () else
    if ($decor/project/(release | version)[1]) 
    then update insert $versionOrRelease preceding $decor/project/(release | version)[1]
    else update insert $versionOrRelease into $decor/project

let $filters := comp:getCompilationFilters($decor)
(:let $filters    :=  <filters filter="off"/>:)

(: store version for each desired language, if any :)
let $overallresult := 
    if ( ($publication-request='true') or ($release='true') ) then (
        (: will create version/project collection if it does not exist :)
        let $targetDir   := xmldb:create-collection($get:strDecorVersion, substring($projectPrefix, 1, string-length($projectPrefix) - 1))
        let $targetDir   := xmldb:create-collection($targetDir, concat('version-', translate($timeStamp, '-:', '')))
        let $resourcedir := xmldb:create-collection($targetDir, 'resources')
        let $languages   := tokenize($compile-language, "\s+")
        
        (: Copy all child collections from project collection, logos/resources and potential others :)
        let $result      := 
            for $child-collection in xmldb:get-child-collections(util:collection-name($decor))
            return xmldb:copy(concat(util:collection-name($decor), '/', $child-collection), $targetDir)
        
        (: store Xpaths in decor/data/{project-name}/resources :)
        let $representingTemplates :=
            if (empty($filters) or $filters[@filter='off']) then
                $decor//representingTemplate[@ref]
            else (
                $decor//representingTemplate[parent::transaction/@id=$filters/transaction/@ref]
            )
         
        let $allXpaths :=
            <xpaths status="draft" version="{$timeStamp}" generated="{current-dateTime()}">{
                for $representingTemplate in $representingTemplates
                return artx:getXpaths($decor, $representingTemplate)
            }</xpaths>
            
        let $xpathFile  := xmldb:store($resourcedir, concat($projectPrefix, 'xpaths.xml'), $allXpaths)
        let $filterFile := xmldb:store($resourcedir, concat($projectPrefix, 'filters.xml'), $filters)
        
        (: store original decor file :)
        let $result     := xmldb:store($targetDir, concat($projectPrefix, translate($timeStamp, '-:', ''), '-decor.xml'), $decor)
        
        (: copy any communities :)
        let $result := 
            for $community in $get:colDecorData//community[@projectId=$decor/project/@id]
            let $newReourceName          := concat('community-',$community/@name/string(),'-', translate($timeStamp, '-:', ''), '.xml')
            return
                xmldb:store($targetDir, $newReourceName, $community)
        
        (: for every requested language:
            - compile and store result
            - merge xpaths into fullDatasetTree and store transactions.xml :)
        let $tads := 
            for $language in $languages 
            return (
                let $compiledProject        := comp:compileDecor($decor, $language, $timeStamp, $filters)
                
                (: if $compiledProject is empty then something went wrong (e.g. no connection to repositories possible to resolve references) and simply give up with an error, otherwise continue to save the artifacts :)
                let $compiledCollectionName := concat($projectPrefix, translate($timeStamp, '-:', ''), '-', $language, '-decor-compiled.xml')
                
                let $result                 := 
                    if ($compiledProject) then 
                        xmldb:store($targetDir, $compiledCollectionName, $compiledProject) 
                    else ()
                
                (:compilation handles filtering so it would contain exactly those ids we need:)
                let $compiledTransactionIds := $compiledProject//transaction[representingTemplate[@sourceDataset]]/@id
                let $filteredTransactions   := $decor//transaction[@id=$compiledTransactionIds]
                let $transactions           := 
                    if ($compiledProject) then
                        <transactionDatasets projectId='{$decor/project/@id}' prefix='{$projectPrefix}' versionDate='{$timeStamp}' language='{$language}'>
                        {
                            for $transaction in $filteredTransactions
                            return art:getFullDatasetTree($transaction/@id, $language, doc($xpathFile))
                        }
                        </transactionDatasets> 
                    else ()
                let $result                 := 
                    if ($compiledProject) then 
                        xmldb:store($targetDir, concat($projectPrefix, translate($timeStamp, '-:', ''), '-', $language, '-transactions.xml'), $transactions) 
                    else ()
                return
                    $compiledProject
            )
        
        (: last action: store publication request if given :)
        let $result := 
            if ($publication-request = 'true') then (
                (: create publication request :)
                let $publicationdata := 
                    <publication projectId="{$decor/project/@id}" prefix="{$projectPrefix}" versionDate="{$timeStamp}" versionSignature="{translate($timeStamp, '-:', '')}" 
                        reference="{$decor/project/reference/@url}" compile-language="{$compile-language}" deeplinkprefix="{$strArtURL}">
                    {
                        $versionOrRelease,
                        $decor-parameters
                    }
                        <request on="{$timeStamp}" status="OK"/>
                    </publication>
                return
                    xmldb:store($targetDir, concat($projectPrefix, translate($timeStamp, '-:', ''), '-', $language, 'publication-request.xml'), $publicationdata) 
            )
            else ()
        
        (: return compile project :)
        return $tads
            
     ) else <ok/>

return
    <result status="{if (count($overallresult)>0 or ((string-length($compile-language) = 0) and $release='true')) then 'OK' else 'Project does not compile. Connected to repositories or properly cached?'}" date="{$timeStamp}">
    {
        element {$versionOrRelease/name()} {
            $versionOrRelease/@*,
            attribute publicationstatus {if ($release='true') then 'version' else '', if ($publication-request='true') then ' pending' else ''},
            $versionOrRelease/*
        }
    }
    </result>