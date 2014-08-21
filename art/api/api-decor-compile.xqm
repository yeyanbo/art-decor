xquery version "1.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket, Marc de Graauw
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)
(: TODO: Should come up with some kind of marker in content retrieved from a repo just to make it clear that is not actual local to this file? :)
module namespace comp = "http://art-decor.org/ns/art-decor-compile";

import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "../modules/art-decor.xqm";
import module namespace vs       = "http://art-decor.org/ns/decor/valueset" at "api-decor-valueset.xqm";
import module namespace templ    = "http://art-decor.org/ns/decor/template" at "api-decor-template.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "api-server-settings.xqm";
declare namespace xdb            = "http://exist-db.org/xquery/xmldb";
declare namespace request        = "http://exist-db.org/xquery/request";
declare namespace response       = "http://exist-db.org/xquery/response";
declare namespace datetime       = "http://exist-db.org/xquery/datetime";
declare option exist:serialize "method=xml media-type=text/xml";

declare variable $comp:debug               := false();
declare variable $comp:strArtURL           := adserver:getServerURLArt();
declare variable $comp:strDecorServicesURL := adserver:getServerURLServices();

(: Filtered for language :)
declare function local:compileProject($node as element(project),$language as xs:string) as element() {
element {$node/name()} {
    $node/@*,
    $node/name[@language=$language][1],
    $node/desc[@language=$language][1],
    $node/copyright,
    $node/author,
    $node/reference,
    $node/restURI,
    $node/defaultElementNamespace,
    $node/contact,
    $node/buildingBlockRepository,
    for $versionRelease in $node/(version|release)
    return
        element {name($versionRelease)} {
            $versionRelease/@*,
            $versionRelease/(note|desc)[@language=$language][1]
        }
}
};

(: Calls central function getFullDatasetTree :)
declare function local:compileDatasets($node as element(datasets), $language as xs:string, $filters as element(filters)?) as element() {
    <datasets>
    {
        $node/@*,                                                   (:doesn't currently have any, but who knows... better not to loose data:)
        for $child in $node/node()
        return
            if ($child[self::dataset]) then ( 
                                                                    (:if there's no */@ref in $filters, assume no filtering is requested:)
                if (empty($filters) or $filters[@filter='off'] or $child[@id=$filters/dataset/@ref]) 
                then art:getFullDatasetTree($child/@id, $language)  (: dataset is compiled :)
                else ()                                             (: dataset is filtered out :)
            )
            else (
                $child
            )
    }
    </datasets>
};

(:recursively handle the tree:)
declare function local:compileScenarios($node as element(), $filters as element(filters)?) as node() {
    if (empty($filters) or $filters[@filter='off']) then (
        (:no filtering necessary. return as-is:)
        $node
    ) else if ($node[self::scenarios]) then (
        element {$node/name()} {
            $node/@*,
            for $child in $node/node() return local:compileScenarios($child,$filters)
        }
    )
    else if ($node[self::scenario]) then (
        (: copy only scenarios which are listed in filters :)
        if ($node[@id=$filters/scenario/@ref]) then (
            element {$node/name()} {
                $node/@*,
                for $child in $node/node() return local:compileScenarios($child,$filters)
            }
        ) else (
            (:filtered out...:)
            comment {concat($node/name(),' was filtered id=''',$node/@id,''' ',$node/name[1]/string())}
        )
    )
    else if ($node[self::transaction]) then (
        (: copy only transactions which are listed in filters :)
        if ($node[@id=$filters/transaction/@ref]) then (
            element {$node/name()} {
                $node/@*,
                for $child in $node/node() return local:compileScenarios($child,$filters)
            }
        ) else (
            (:filtered out...:)
            comment {concat($node/name(),' (',$node/@type,') was filtered id=''',$node/@id,''' ',$node/name[1]/string())}
        )
    )
    else (
        (: copy any other node :)
        $node
    )
};

declare function local:compileTerminology($node as element(terminology), $filters as element(filters)?) as element(terminology) {
    let $projectPrefix      := $node/ancestor::decor/project/@prefix/string()
    
    return
        <terminology>
        {
            $node/terminologyAssociation
            ,
            $node/codeSystem
            ,
            if (empty($filters) or $filters[@filter='off']) then (
                (:no filtering necessary. return as-is:)
                for $valueSet in $node/valueSet
                let $expandedValueSets :=
                    if ($valueSet[@ref]) then
                        vs:getExpandedValueSetById($valueSet/@ref, $valueSet/@flexibility, $projectPrefix)
                    else
                        vs:getExpandedValueSetById($valueSet/@id, $valueSet/@effectiveDate, $projectPrefix)
                return
                for $expandedValueSet in $expandedValueSets//valueSet
                return
                    element {name($expandedValueSet)} {
                        $expandedValueSet/@*,
                        $expandedValueSet/parent::repository/(@url|@ident|@referencedFrom),
                        for $n in $expandedValueSet/desc 
                        return art:parseNode($n),
                        $expandedValueSet/node()[not(self::desc)]
                    }
            ) else (
                (: Filter list may contain both dynamic and static where static == the newest. 
                   This would lead to duplicates, so build first and group second:)
                let $compiledValueSets  :=
                    for $valueSet in $filters/valueSet
                    let $expandedValueSets  := 
                        if ($valueSet[@ref]) then
                            vs:getExpandedValueSetByRef($valueSet/@ref, $valueSet/@flexibility, $projectPrefix)
                        else
                            vs:getExpandedValueSetById($valueSet/@id, $valueSet/@effectiveDate, $projectPrefix)
                    return (
                        for $expandedValueSet in $expandedValueSets//valueSet
                        return
                            element {name($expandedValueSet)} {
                                $expandedValueSet/@*,
                                $expandedValueSet/parent::repository/(@url|@ident|@referencedFrom),
                                for $n in $expandedValueSet/desc 
                                return art:parseNode($n),
                                $expandedValueSet/node()[not(self::desc)]
                            }
                    )
                return (
                    for $valueSet in $compiledValueSets
                    group by $id := $valueSet/@id, $effectiveDate := $valueSet/@effectiveDate, $ref := $valueSet/@ref
                    return $valueSet[1]
                    ,
                    if (string($comp:debug)='true') then (
                        for $valueSet in $node/valueSet[not(concat(@id,@effectiveDate)=$compiledValueSets/concat(@id,@effectiveDate))][not(@ref=$compiledValueSets/@id)]
                        return (
                            comment {'Filtered valueSet ',if ($valueSet[@ref]) then 'ref=' else 'id=',$valueSet/(@id|@ref),' name=',$valueSet/@name,if ($valueSet[@effectiveDate]) then concat(' effectiveDate=',$valueSet/@effectiveDate) else ()},'&#10;'
                        )
                        ,
                        for $valueSet in $compiledValueSets[not(concat(@id,@effectiveDate)=$node/valueSet/concat(@id,@effectiveDate))][not(@id=$node/valueSet/@ref)]
                        return (
                            comment {'Adding valueSet id=',$valueSet/@id,' name=',$valueSet/@name,' effectiveDate=',$valueSet/@effectiveDate},'&#10;'
                        )
                    ) else ()
                )
            )
        }
        </terminology>
};

declare function local:compileIds($node as element(ids)) as element(ids) {
let $projectPrefix   := $node/ancestor::decor/project/@prefix/string()
let $projectLanguage := $node/ancestor::decor/project/@defaultLanguage/string()
let $allDefinedOIDs  := $node/id/@root/string()
let $allDeclaredOIDs := 
    for $oid in ($node/ancestor::decor//@codeSystem[not(ancestor-or-self::example)][not(ancestor-or-self::ids)] | 
                 $node/ancestor::decor//@root[not(ancestor-or-self::example)][not(ancestor-or-self::ids)])
    return tokenize($oid, '\|')
    
return
    element {$node/name()} {
        $node/node()
        ,
        '&#10;        ',
        comment {'BEGIN IDs added through compilation'}
        ,
        for $oid in distinct-values($allDeclaredOIDs)[not(.=$allDefinedOIDs)]
        (:  these aren't covered by art:getNameForOID. They are inexpensive to get, 
            while art:getNameForOID is extremely expensive :)
        let $local      := ($node/ancestor::decor//template[@id=$oid] | 
                            $node/ancestor::decor//template[@ref=$oid] |
                            $node/ancestor::decor//codeSystem[@id=$oid] | 
                            $node/ancestor::decor//codeSystem[@ref=$oid])
        let $oidName    :=
            if ($local/@displayName) then
                ($local/@displayName/string())[1]
            else if ($local/@name) then
                ($local/@name/string())[1]
            else
                (art:getNameForOID($oid, $projectLanguage, $projectPrefix))
        return
            if (string-length($oidName)>0) then
                <id root="{$oid}">
                    <designation displayName="{$oidName}" language="{$projectLanguage}">{$oidName}</designation>
                </id>
            else(
                comment {'Could not find OID name for ',$oid}
            )
    }
};

declare function local:compileTemplates($node as element(rules)?, $filters as element(filters)?) as element(rules)? {
let $projectPrefix  := $node/ancestor::decor/project/@prefix

return
    <rules>
    {
        let $startTemplates     :=
            if ($filters[@filter='on']) then (
                for $template in $filters/template
                return 
                    templ:getTemplateById($template/@ref,$template/@flexibility,$projectPrefix)/template/template
            ) else (
                $node/template[@id],
                for $template in $node/template[@ref]
                return 
                    templ:getTemplateById($template/@ref,$template/@flexibility,$projectPrefix)/template/template
            )
        
        let $templateChain      := local:getTemplateChain($projectPrefix, $startTemplates, $startTemplates)
            
        return
            for $template in $templateChain
            group by $id := $template/@id, $effectiveDate := $template/@effectiveDate, $ref := $template/@ref
            order by $id, $ref
            return (
                '&#10;        ',
                comment {if ($template[1]/@displayName) then $template[1]/@displayName else ($template[1]/@name)},
                $node/templateAssociation[@templateId=$template[1]/(@id|@ref)][not(@effectiveDate) or @effectiveDate=$template[1]/@effectiveDate],
                $template[1]
            )
    }
    </rules>
};

declare function local:getTemplateChain($projectPrefix as xs:string, $startTemplate as element(template)*, $filteredResults as element(template)*) as element(template)* {
    let $templates :=
        for $ref in ($startTemplate//element/@contains | $startTemplate//include/@ref)
        let $template   := templ:getTemplateByRef($ref,$ref/../@flexibility,$projectPrefix)/template/template[@id]
        return
            if (empty($template) or $filteredResults[@id=$template/@id][@effectiveDate=$template/@effectiveDate]) then
                $filteredResults
            else (
                local:getTemplateChain($projectPrefix,$template,($filteredResults|$template))
            )
    return
    if (empty($templates)) then $filteredResults else $templates 
};

declare function comp:compileDecor($decorproject as element(decor), $language as xs:string) as element(decor) {
    let $now := substring(string(current-dateTime()),1,19)
    return comp:compileDecor($decorproject, $language, $now, (), false())
};

declare function comp:compileDecor($decorproject as element(decor), $language as xs:string, $now as xs:string) as element(decor) {
    comp:compileDecor($decorproject, $language, $now, (), false())
};

declare function comp:compileDecor($decorproject as element(decor), $language as xs:string, $now as xs:string, $filters as element(filters)?) as element(decor) {
    comp:compileDecor($decorproject, $language, $now, $filters, false())
};

declare function comp:compileDecor($decorproject as element(decor), $language as xs:string, $now as xs:string, $filters as element(filters)?, $testfilters as xs:boolean) as element(decor) {
    let $compiledDatasets       := 
        if ($decorproject/datasets) then 
            local:compileDatasets($decorproject/datasets, $language, $filters)
        else ()
    let $startTemplatesInScope  :=
        <filters>
        {
            (:filter templates based on transactions only if there are transactions in this project, and filtering is on:)
            if ($decorproject/scenarios//transaction and $filters[@filter='on']) then (
                attribute filter {'on'},
                for $ref in $decorproject/scenarios//transaction[@id=$filters/transaction/@ref]/representingTemplate[@ref]
                group by $reff := $ref/@ref, $eff := $ref/@flexibility[not(.='dynamic')]
                return
                    <template ref="{$reff}" flexibility="{if ($eff) then $eff else 'dynamic'}"/>
            ) else (
                attribute filter {'off'}
            )
        }
        </filters>
    
    let $compiledTemplates      := local:compileTemplates($decorproject/rules, $startTemplatesInScope)
    
    let $associationsInScope    := $compiledDatasets//terminologyAssociation
    (:for valuesets we ALWAYS calculate the right set. With the introduction of template[@ref] it is 
    unpredicatable whether or not all valueSet[@ref] are accounted for. If we leave it up to the users 
    they might be missing one or more valueSet[@ref]:)
    (:  when filtering is off, we 
            - include all valueSet[@id|@ref] regardless of usage
            - include valueSets that are actually in use through *used* terminologyAssociations/templates
        when filtering is on, we 
            - include valueSets that are actually in use through *used* terminologyAssociations/templates
    :)
    let $valueSetsInScope       := 
        <filters>
        {
            $filters/@filter,
            (:when filtering is off, we 
                - always include all valueSet[@id|@ref] regardless of usage
            :)
            if ($filters[@filter='off']) then (
                for $ref in $decorproject/terminology/valueSet[@id]
                return
                    <valueSet ref="{$ref/@id}" flexibility="{$ref/@effectiveDate}"/>
                ,
                for $ref in $decorproject/terminology/valueSet[@ref]
                return
                    <valueSet ref="{$ref/@ref}" flexibility="{if ($ref/@flexibility) then $ref/@flexibility else 'dynamic'}"/>
            )
            else ()
            ,
            (:  - include valueSets that are actually in use through *used* terminologyAssociations/templates
                
                please note that this step might duplicate valueSet elements created above. 
                this is mitigated in compileTerminology
            :)
            for $ref in ($associationsInScope[@valueSet] | $compiledTemplates//vocabulary[@valueSet])
            group by $reff := $ref/@valueSet, $eff := $ref/@flexibility[not(.='dynamic')]
            return
                <valueSet ref="{$reff}" flexibility="{if ($eff) then $eff else 'dynamic'}"/>
        }
        </filters>
    
    return 
    if ($testfilters) then (
        <filters>
        {
            $filters/@*,
            $filters/(node() except ignore),
            if ($filters[@filter='on']) then (
                $valueSetsInScope/valueSet
                ,
                for $template in $compiledTemplates/template
                return <template ref="{$template/(@id|@ref)}" name="{$template/@name}" flexibility="{if ($template/@effectiveDate) then $template/@effectiveDate else 'dynamic'}"/>
            ) else ()
            ,
            $filters/ignore
        }
        </filters>
    ) else (
        <decor>
        {
            (: hack alert. This forces the serializer to write our 'foreign' namespace declarations. Reported on the exist list :)
            for $ns-prefix at $i in in-scope-prefixes($decorproject)[not(.=('xml'))]
            let $ns-uri := namespace-uri-for-prefix($ns-prefix, $decorproject)
            return
                attribute {QName($ns-uri,concat($ns-prefix,':dummy-',$i))} {$ns-uri}
            ,
            $decorproject/@*,
            attribute versionDate {$now},
            attribute versionLabel {$decorproject/project/(release|version)[@date=$now]/@versionLabel},
            attribute compilationDate {$now},
            attribute language {$language},
            if (string-length($comp:strArtURL)>0) then 
                attribute deeplinkprefix {$comp:strArtURL}
            else (),
            if (string-length($comp:strDecorServicesURL)>0) then 
                attribute deeplinkprefixservices {$comp:strDecorServicesURL}
            else ()
            ,
            '&#10;',
            comment {
                '&#10;',
                'This is a compiled version of a DECOR based project. Compilation date: ', $now ,'&#10;',
                'PLEASE NOTE THAT ITS ONLY PURPOSE IS TO FACILITATE HTML AND SCHEMATRON GENERATION. HENCE THIS IS A ONE OFF FILE UNSUITED FOR ANY OTHER PURPOSE','&#10;',
                'Compilation process calls getFullDataSetTree where all inheritance of concepts from repositories is resolved','&#10;',
                'Compilation process leaves valueSet[@ref] as-is but adds, if available, the valueSet (versions) it references. These are marked with valueSet[@referencedFrom, @ident and/or @url]','&#10;',
                'Compilation process tries to find names for any OIDs referenced in the project but not yet in ids/id, and adds an entry if a name is found','&#10;',
                'Compilation process does not yet handle retrieval of referenced templates if they are not inside this project'
            },
            for $node in $decorproject/node()
            return
                if ($node/name()='project') then (
                    local:compileProject($node,$language)
                ) else if ($node/name()='datasets') then (
                    $compiledDatasets
                ) else if ($node/name()='scenarios') then (
                    local:compileScenarios($node, $filters) 
                ) else if ($node/name()='terminology') then (
                    local:compileTerminology($node, $valueSetsInScope)
                ) else if ($node/name()='ids') then (
                    local:compileIds($node)
                ) else if ($node/name()='rules') then (
                    $compiledTemplates 
                ) else (
                    $node
                )
        }
        </decor>
    )
};

declare function comp:getCompilationFilters($decor as element(decor)) as element(filters)? {
let $filters        := 
    if (doc-available(concat(util:collection-name($decor),'/filters.xml')))
    then doc(concat(util:collection-name($decor),'/filters.xml'))/filters[not(@filter='off')]
    else ()

let $filterSetting  := if ($filters) then ('on') else ('off')
(: Use cases to support:
    1. Do datasets based on id (includes valuesets and terminologyAssociations, excludes any scenarios)
    2. Do full scenarios based on id (includes linked datasets, valuesets, terminologyAssociations, templates)
    3. Do transaction (groups) based on id (includes linked datasets, valuesets, terminologyAssociations, templates)
    4. ...
    
   Filtering actually works on the inclusion mechanism. If it is not in the filters file, it should not be compiled.
:)
let $filteredTransactions :=
    if ($filters/transaction/@ref)
    (: use case 3 :)
    then $decor//transaction[ancestor-or-self::transaction[@id=$filters/transaction/@ref]]
    
    else if ($filters/scenario/@ref and $filters/dataset/@ref)
    (: use case 2 -- but with additional filter on dataset :)
    then $decor//transaction[representingTemplate[@sourceDataset=$filters/dataset/@ref]][ancestor::scenario[@id=$filters/scenario/@ref]]
    
    else if ($filters/scenario/@ref)
    (: use case 2 -- id based only :)
    then $decor//transaction[ancestor::scenario[@id=$filters/scenario/@ref]]
    
    else if ($filters/dataset/@ref)
    (: use case 1 - does not include transactions ... :)
    then ()
    
    (: final fallback if no filtering is applied: leave empty :)
    else ()
    
(: rewrite the filters so we now know what it is exactly that we need to do :)
let $finalFilters :=
    (
        for $ref in distinct-values($filteredTransactions//@sourceDataset | $filters/dataset/@ref)
        return
            <dataset ref="{$ref}" name="{$decor//dataset[@id=$ref]/name[1]/string()}"/>
        ,
        for $ref in distinct-values($filteredTransactions/ancestor-or-self::scenario/@id)
        return
            <scenario ref="{$ref}" name="{$decor//scenario[@id=$ref]/name[1]/string()}"/>
        ,
        for $ref in distinct-values($filteredTransactions/ancestor-or-self::transaction/@id)
        return
            <transaction ref="{$ref}" name="{$decor//transaction[@id=$ref]/name[1]/string()}"/>
        ,
        for $ref in $filteredTransactions//representingTemplate[@ref]
        group by $reff := $ref/@ref, $eff := $ref/@flexibility[not(.='dynamic')]
        return
            <template ref="{$reff}" name="{$decor//tempate[(@id|@ref|@name)=$ref]/@name[1]}" flexibility="{if ($eff) then $eff else 'dynamic'}"/>
    )
return
    <filters filter="{$filterSetting}">
    {
        if ($filterSetting='on') then (
            $finalFilters
            ,
            '&#10;'
            ,
            if ($finalFilters[@ref]) then (
                <ignore>{
                    comment {'Any reference below here will be ignored based on applicable filters:'}
                    ,
                    for $node in ($decor//dataset | $decor//scenario | $decor//transaction)[not(@id=$finalFilters/@ref)]
                    return
                        <filter type="{$node/name()}" dref="{$node/@id}" dname="{$node/name[1]/string()}"/>
                }</ignore>
            )
            else if ($filters) then (
                <ignore>{
                    comment {'WARNING: Filters where defined, but the project doesn''t match any of the referred artifacts.'}
                    ,
                    $filters/node()
                }</ignore>
            )
            else ()
        )
        else (
            comment {'Filtering is off, everything will be included'}
        )
    }
    </filters>
};