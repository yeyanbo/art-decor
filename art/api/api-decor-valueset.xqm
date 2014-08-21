xquery version "1.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket
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
:)

module namespace vs              = "http://art-decor.org/ns/decor/valueset";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "api-server-settings.xqm";
import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "../modules/art-decor.xqm";
declare namespace error          = "http://art-decor.org/ns/decor/valueset/error";
declare namespace xs             = "http://www.w3.org/2001/XMLSchema";

declare variable $vs:strDecorServicesURL := adserver:getServerURLServices();

(:~
:   Return zero or more valuesets as-is wrapped in a &lt;return/&gt; element, and subsequently inside a &lt;repository&gt; element. This repository element
:   holds at least the attribute @ident with the originating project prefix and optionally the attribute @url with the repository URL in case of an external
:   repository. Id based references can match both valueSet/@id and valueSet/@ref. The latter is resolved. Note that duplicate valueSet matches may be 
:   returned. Example output:
:   &lt;return>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/repository>
:   &lt;/return>
:   
:   @param $id           - required. Identifier of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetById ($id as xs:string, $flexibility as xs:string?) as element() {
    <return>
    {
        for $prefix in $get:colDecorData//decor[not(string(@private)='true')]/project/@prefix
        return
            vs:getValueSetById ($id, $flexibility, $prefix)/*
    }
    </return>
};

(:~
:   See vs:getValueSetById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for documentation
:   
:   @param $id           - required. Identifier of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element()* {
    vs:getValueSetById($id, $flexibility, $prefix, ())
};

(:~
:   Return zero or more valuesets as-is wrapped in a &lt;return/&gt; element, and subsequently inside a &lt;repository&gt; element. This repository element
:   holds at least the attribute @ident with the originating project prefix and optionally the attribute @url with the repository URL in case of an external
:   repository. Id based references can match both valueSet/@id and valueSet/@ref. The latter is resolved. Note that duplicate valueSet matches may be 
:   returned. Example output for valueSet/@ref:<br/>
:   &lt;return>
:       &lt;project ident="epsos-">
:           &lt;valueSet ref="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature">
:               ...
:           &lt;/valueSet>
:       &lt;/project>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-" referencedFrom="epsos-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/repository>
:   &lt;/return>
:   <p>Example output for valueSet/@id:</p>
:   &lt;return>
:       &lt;project ident="epsos-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/repository>
:   &lt;/return>
:   
:   @param $id           - required. Identifier of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id (regardless of name), yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the valueset will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element()* {
let $argumentCheck :=
    if (string-length($id)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument id is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

let $internalrepositories := 
    if (empty($version)) then
        $get:colDecorData/decor[project/@prefix=$prefix]
    else (
        collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]
    )
(: don't go looking in repositories when this is an archived project version. the project should be compiled already and be self contained. 
   repositories in their current state would give a false picture of the status quo when the project was archived
   Also don't go looking in repositories when there's no valueSet/@ref matching our id
:)
let $externalrepositories := 
    if (empty($version) and not($internalrepositories/terminology/valueSet[@id=$id])) then
        $internalrepositories/project/buildingBlockRepository
    else ()

let $repositoryValueSetLists :=
    <repositoryValueSetLists>
    {
        local:getValueSetById($id, $prefix, $externalrepositories, <buildingBlockRepository url="{$vs:strDecorServicesURL}" ident="{$prefix}"/>)[valueSet[@id]]
    }
    {
        (:from the requested project, return valueSet/(@id and @ref):)
        (: when retrieving value sets from a compiled project, the @url/@ident they came from are on the valueSet element
           reinstate that info on the repositoryValueSetList element so downstream logic works as if it really came from 
           the repository again.
        :)
        for $repository in $internalrepositories
        for $valuesets in $repository/terminology/valueSet[@id=$id]|$repository/terminology/valueSet[@ref=$id]
        group by $source := concat($valuesets/@url,$valuesets/@ident)
        return
            if (string-length($source)=0) then
                <repositoryValueSetList ident="{$repository/project/@prefix}">
                {
                    $valuesets
                }
                </repositoryValueSetList>
            else (
                <repositoryValueSetList url="{$valuesets[1]/@url}" ident="{$valuesets[1]/@ident}" referencedFrom="{$prefix}">
                {
                    for $valueset in $valuesets
                    return
                        <valueSet>{$valueset/(@* except (@url|@ident|@referencedFrom)), $valueset/node()}</valueSet>
                }
                </repositoryValueSetList>
            )
    }
    </repositoryValueSetLists>

return
    <return>
    {
        if (empty($flexibility)) then
            for $repositoryValueSetList in $repositoryValueSetLists/repositoryValueSetList[valueSet]
            let $elmname := if ($repositoryValueSetList[not(@url)]/@ident=$prefix) then 'project' else 'repository'
            return
                element {$elmname}
                {
                    $repositoryValueSetList/@*,
                    for $valueSet in $repositoryValueSetList/valueSet
                    order by xs:dateTime($valueSet/@effectiveDate) descending
                    return   $valueSet
                }
        else if (matches($flexibility,'^\d{4}')) then
            for $repositoryValueSetList in $repositoryValueSetLists/repositoryValueSetList[valueSet[@ref or @effectiveDate=$flexibility]]
            let $elmname := if ($repositoryValueSetList[not(@url)]/@ident=$prefix) then 'project' else 'repository'
            return
                element {$elmname}
                {
                    $repositoryValueSetList/@*,
                    $repositoryValueSetList/valueSet[@ref or @effectiveDate=$flexibility]
                }
        else
            for $repositoryValueSetList in $repositoryValueSetLists/repositoryValueSetList[valueSet[@ref or @effectiveDate=string((max($repositoryValueSetLists//valueSet/xs:dateTime(@effectiveDate)))[1])]]
            let $elmname := if ($repositoryValueSetList[not(@url)]/@ident=$prefix) then 'project' else 'repository'
            return
                element {$elmname}
                {
                    $repositoryValueSetList/@*,
                    $repositoryValueSetList/valueSet[@ref or @effectiveDate=string((max($repositoryValueSetLists//valueSet/xs:dateTime(@effectiveDate)))[1])]
                }
    }
    </return>
};

(:~
:   Return zero or more valuesets as-is. Name based references cannot return valueSet/@ref, only valueSet/@id. Name based references do not cross project 
:   boundaries, so no repositories beit local or remote are consulted. Note that duplicate valueSet matches may be returned. Example output:
:   &lt;return>
:       &lt;project ident="ad2bbr-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/project>
:   &lt;/return>
:   
:   @param $name             - required. Name of the valueset to retrieve (valueSet/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetByName ($name as xs:string, $flexibility as xs:string?, $useRegexMatching as xs:boolean) as element() {
    <return>
    {
        for $prefix in $get:colDecorData//decor[not(string(@private)='true')]/project/@prefix
        return
            vs:getValueSetByName($name, $flexibility, $prefix, $useRegexMatching)/*
    }
    </return>
};

(:~
:   See vs:getValueSetByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) for documentation
:   
:   @param $name             - required. Name of the valueset to retrieve (valueSet/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix           - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean) as element()* {
    vs:getExpandedValueSetByName($name, $flexibility, $prefix, $useRegexMatching, ())
};

(:~
:   Return zero or more valuesets as-is. Name based references cannot return valueSet/@ref, only valueSet/@id. Name based references do not cross project 
:   boundaries, so no repositories beit local or remote are consulted. Note that duplicate valueSet matches may be returned. Example output:
:   &lt;return>
:       &lt;project ident="ad2bbr-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/project>
:   &lt;/return>
:   
:   @param $name             - required. Name of the valueset to retrieve (valueSet/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name (regardless of id), yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix           - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @param $version          - optional. if empty defaults to current version. if valued then the valueset will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:   @since 2014-04-02 Changed behavior so 'dynamic' does not retrieve the latest version per id, but the latest calculated over all ids
:)
declare function vs:getValueSetByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) as element()* {

let $argumentCheck :=
    if (string-length($name)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument name is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()
    
let $internalrepositories       := 
    if ($useRegexMatching) then 
        if (empty($version)) then 
            $get:colDecorData/decor[project/@prefix=$prefix]/terminology/valueSet[matches(@name,$name)]
        else
            collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]/terminology/valueSet[matches(@name,$name)]
    else
        if (empty($version)) then 
            $get:colDecorData/decor[project/@prefix=$prefix]/terminology/valueSet[@name=$name]
        else
            collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]/terminology/valueSet[@name=$name]

let $repositoryValueSetLists    :=
    <repositoryValueSetLists>
    {
        (:  don't go looking in repositories when this is an archived project version. the project should be compiled already and 
            be self contained. Repositories in their current state would give a false picture of the status quo when the project 
            was archived. Also don't go looking in repositories when there's no valueSet/@ref matching our id
        :)
        if (empty($version) and not($internalrepositories[@id])) then
            let $buildingBlockRepositories  := $get:colDecorData/decor/project[@prefix=$prefix]/buildingBlockRepository
            (:this is the starting point for the list of servers we already visited to avoid circular reference problems:)
            let $bbrList                    := <buildingBlockRepository url="{$vs:strDecorServicesURL}" ident="{$prefix}"/>
            return
                local:getValueSetByName($name, $prefix, $buildingBlockRepositories, $bbrList)[valueSet[@id]]
        else ()
    }
    </repositoryValueSetLists>

let $valueSetsById := 
    if ($internalrepositories/@id | $internalrepositories/@ref) then
        (:if the project has our valueSet[@id|@ref] by name, do not check any other ids in the repositories:)
        for $id in distinct-values($internalrepositories/@id | $internalrepositories/@ref | $repositoryValueSetLists/repositoryValueSetList/valueSet[@id=($internalrepositories/@id | $internalrepositories/@ref)]/@id)
        return
            vs:getValueSetById($id,$flexibility,$prefix,$version)/*
    else (
        (:if the project has our valueSet[@id|@ref] by name, check any hit from the repositories:)
        for $id in distinct-values($internalrepositories/@id | $internalrepositories/@ref | $repositoryValueSetLists/repositoryValueSetList/valueSet/@id)
        return
            vs:getValueSetById($id,$flexibility,$prefix,$version)/*
    )
return
    <return>
    {
        if (empty($flexibility)) then
            for $repositoryValueSetList in $valueSetsById[valueSet]
            let $elmname := $repositoryValueSetList/name()
            return
                element {$elmname}
                {
                    $repositoryValueSetList/@*,
                    for $valueSet in $repositoryValueSetList/valueSet
                    order by xs:dateTime($valueSet/@effectiveDate) descending
                    return   $valueSet
                }
        else if (matches($flexibility,'^\d{4}')) then
            for $repositoryValueSetList in $valueSetsById[valueSet[@ref or @effectiveDate=$flexibility]]
            let $elmname := $repositoryValueSetList/name()
            return
                element {$elmname}
                {
                    $repositoryValueSetList/@*,
                    $repositoryValueSetList/valueSet[@ref or @effectiveDate=$flexibility]
                }
        else
            for $repositoryValueSetList in $valueSetsById[valueSet[@ref or @effectiveDate=string((max($valueSetsById//valueSet/xs:dateTime(@effectiveDate)))[1])]]
            let $elmname := $repositoryValueSetList/name()
            return
                element {$elmname}
                {
                    $repositoryValueSetList/@*,
                    $repositoryValueSetList/valueSet[@ref or @effectiveDate=string((max($valueSetsById//valueSet/xs:dateTime(@effectiveDate)))[1])]
                }
    }
    </return>
};

(:~
:   See vs:getValueSetByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for documentation
:   
:   @param $idOrName     - required. Identifier (@id) or name (@name) of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element()* {
    vs:getValueSetByRef($idOrName, $flexibility, $prefix, ())
};

(:~
:   Returns zero or more valuesets as-is. This function is useful to call from a vocabulary reference inside a template, or from a 
:   templateAssociation where @id or @name may have been used as the reference key. Uses vs:getValueSetById() and vs:getValueSetByName() to get the
:   result and returns that as-is. See those functions for more documentation on the output format.
:   
:   @param $idOrName     - required. Identifier (@id) or name (@name) of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the valueset will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element()* {

let $argumentCheck :=
    if (string-length($idOrName)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument idOrName is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

return
    if (matches($idOrName,'^[\d\.]+$')) then
        vs:getValueSetById($idOrName,$flexibility,$prefix,$version)
    else
        vs:getValueSetByName($idOrName,$flexibility,$prefix,false(),$version)
};

(:~
:   Return zero or more expanded valuesets wrapped in a &lt;return/&gt; element, and subsequently inside a &lt;repository&gt; element. This repository element
:   holds at least the attribute @ident with the originating project prefix and optionally the attribute @url with the repository URL in case of an external
:   repository. Id based references can match both valueSet/@id and valueSet/@ref. The latter is resolved. Note that duplicate valueSet matches may be 
:   returned. Example output:
:   &lt;return>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/repository>
:   &lt;/return>
:   <ul><li> Valuesets get an extra attribute @fromRepository containing the originating project prefix/ident</li> 
:   <li>valueSet/@ref is treated as if it were the referenced valueset</li>
:   <li>If parameter prefix is not used then only valueSet/@id is matched. If that does not give results, then 
:     valueSet/@ref is matched, potentially expanding into a buildingBlockRepository</li>
:   <li>Any (nested) includes in the valueset are resolved, if applicable using the buildingBlockRepository 
:     configuration in the project that the valueSet/@id was found in</li>
:                                
:   @param $id           - required. Identifier of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSetById ($id as xs:string, $flexibility as xs:string?) as element() {
    <result>
    {
        for $prefix in $get:colDecorData//decor[not(string(@private)='true')]/project/@prefix
        return
            vs:getExpandedValueSetById($id, $flexibility, $prefix)/*
    }
    </result>
};

(:~
:   See vs:getExpandedValueSetById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for documentation
:   
:   @param $id           - required. Identifier of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSetById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element() {
    vs:getExpandedValueSetById ($id, $flexibility, $prefix, ())
};

(:~
:   Return zero or more expanded valuesets wrapped in a &lt;return/&gt; element, and subsequently inside a &lt;repository&gt; element. This repository element
:   holds at least the attribute @ident with the originating project prefix and optionally the attribute @url with the repository URL in case of an external
:   repository. Id based references can match both valueSet/@id and valueSet/@ref. The latter is resolved. Note that duplicate valueSet matches may be 
:   returned. Example output:
:   &lt;return>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/repository>
:   &lt;/return>
:   <ul><li> Valuesets get an extra attribute @fromRepository containing the originating project prefix/ident</li> 
:   <li>valueSet/@ref is treated as if it were the referenced valueset</li>
:   <li>If parameter prefix is not used then only valueSet/@id is matched. If that does not give results, then 
:     valueSet/@ref is matched, potentially expanding into a buildingBlockRepository</li>
:   <li>Any (nested) includes in the valueset are resolved, if applicable using the buildingBlockRepository 
:     configuration in the project that the valueSet/@id was found in</li>
:                                
:   @param $id           - required. Identifier of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the valueset will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSetById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element() {
let $argumentCheck :=
    if (string-length($id)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument id is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

let $valueSets := vs:getValueSetById($id, $flexibility, $prefix, $version)

return
    <result>
    {
        for $repository in $valueSets/(project|repository)
        return
            element {name($repository)}
            {
                $repository/@*,
                $repository/valueSet[@ref],
                for $valueSet in $repository/valueSet[@id]
                return
                    vs:getExpandedValueSet($valueSet, $prefix, $version)
            }
    }
    </result>
};

(:~
:   Return zero or more expanded valuesets. Name based references cannot return valueSet/@ref, only valueSet/@id. Name based references do not cross project 
:   boundaries, so no repositories beit local or remote are consulted. Note that duplicate valueSet matches may be returned. Example output:
:   &lt;return>
:       &lt;repository ident="ad2bbr-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/repository>
:   &lt;/return>
:   <ul><li>Valuesets get an extra attribute @fromRepository containing the originating project prefix/ident</li> 
:   <li>If parameter prefix is used and parameter id leads to a valueSet/@ref, then this is treated as if it were the referenced valueset</li>
:   <li>If parameter prefix is not used then only valueSet/@id is matched. If that does not give results, then valueSet/@ref is matched, 
:   potentially expanding into a buildingBlockRepository</li>
:   <li>Any (nested) includes in the valueset are resolved, if applicable using the buildingBlockRepository 
:   configuration in the project that the valueSet/@id was found in</li>
:
:   @param $name             - required. Name of the valueset to retrieve (valueSet/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @return The expanded valueSet
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSetByName ($name as xs:string, $flexibility as xs:string?, $useRegexMatching as xs:boolean) as element() {
    <result>
    {
        for $prefix in $get:colDecorData//decor[not(string(@private)='true')]/project/@prefix
        return
            vs:getExpandedValueSetByName($name, $flexibility, $prefix, $useRegexMatching)/*
    }
    </result>
};

(:~
:   See vs:getExpandedValueSetByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) for documentation
:
:   @param $name             - required. Name of the valueset to retrieve (valueSet/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix           - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @return The expanded valueSet
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSetByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean) as element() {
    vs:getExpandedValueSetByName($name, $flexibility, $prefix, $useRegexMatching, ())
};

(:~
:   Return zero or more expanded valuesets. Name based references cannot return valueSet/@ref, only valueSet/@id. Name based references do not cross project 
:   boundaries, so no repositories beit local or remote are consulted. Note that duplicate valueSet matches may be returned. Example output:
:   &lt;return>
:       &lt;repository ident="ad2bbr-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/valueSet>
:       &lt;/repository>
:   &lt;/return>
:   <ul><li>Valuesets get an extra attribute @fromRepository containing the originating project prefix/ident</li> 
:   <li>If parameter prefix is used and parameter id leads to a valueSet/@ref, then this is treated as if it were the referenced valueset</li>
:   <li>If parameter prefix is not used then only valueSet/@id is matched. If that does not give results, then valueSet/@ref is matched, 
:   potentially expanding into a buildingBlockRepository</li>
:   <li>Any (nested) includes in the valueset are resolved, if applicable using the buildingBlockRepository 
:   configuration in the project that the valueSet/@id was found in</li>
:
:   @param $name             - required. Name of the valueset to retrieve (valueSet/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix           - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @param $version          - optional. if empty defaults to current version. if valued then the valueset will come explicitly from that archived project version which is expected to be a compiled version
:   @return The expanded valueSet
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSetByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) as element() {
let $argumentCheck :=
    if (string-length($name)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument name is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

let $valueSets := vs:getValueSetByName($name, $flexibility, $prefix, $useRegexMatching, $version)

return
    <result>
    {
        for $repository in $valueSets/(project|repository)
        return
            element {name($repository)}
            {
                $repository/@*,
                $repository/valueSet[@ref],
                for $valueSet in $repository/valueSet[@id]
                return
                    vs:getExpandedValueSet($valueSet, $prefix, $version)
            }
    }
    </result>
};

(:~
:   See vs:getExpandedValueSetByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for documentation
:   
:   @param $idOrName     - required. Identifier (@id) or name (@name) of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSetByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element()* {
    vs:getExpandedValueSetByRef($idOrName, $flexibility, $prefix, ())
};

(:~
:   Returns zero or more expanded valuesets. This function is useful to call from a vocabulary reference inside a template, or from a 
:   templateAssociation where @id or @name may have been used as the reference key. Uses vs:getExpandedValueSetById() and vs:getExpandedValueSetByName() 
:   to get the result and returns that as-is. See those functions for more documentation on the output format.
:   
:   @param $idOrName     - required. Identifier (@id) or name (@name) of the valueset to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the valueset will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSetByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element()* {
let $argumentCheck :=
    if (string-length($idOrName)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument idOrName is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

return
    if (matches($idOrName,'^[\d\.]+$')) then
        vs:getExpandedValueSetById($idOrName,$flexibility,$prefix, $version)
    else
        vs:getExpandedValueSetByName($idOrName,$flexibility,$prefix,false(), $version)
};

(:~
:   See vs:getExpandedValueSet($valueSet as element(), $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $valueSet     - required. The valueSet element with content to expand
:   @param $prefix       - required. The origin of valueSet. pfx- limits scope this project only
:   @return The expanded valueSet
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSet($valueSet as element(), $prefix as xs:string) as element() {
    vs:getExpandedValueSet($valueSet, $prefix, ())
};

(:~
:   Expands a valueSet with @id by recursively resolving all includes. Use vs:getExpandedValueSetsById to resolve a valueSet/@ref first. 
:   &lt;valueSet all-attributes of the input&gt;
:       &lt;desc all /&gt;
:       &lt;sourceCodeSystem id="any-concept-or-exception-codesystem-in-valueSet" identifierName="codeSystemName" /&gt;
:       &lt;completeCodeSystem all-attributes of the input&gt;
:       &lt;conceptList&gt;
:           &lt;concept all-attributes-and-desc-elements /&gt;
:           &lt;exception all-attributes-and-desc-elements exceptions-contain-no-duplicates /&gt;
:       &lt;/conceptList&gt;
:   &lt;/valueSet&gt;
:                                
:   @param $valueSet     - required. The valueSet element with content to expand
:   @param $prefix       - required. The origin of valueSet. pfx- limits scope this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the valueset will come explicitly from that archived project version which is expected to be a compiled version
:   @return The expanded valueSet
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getExpandedValueSet($valueSet as element(), $prefix as xs:string, $version as xs:string?) as element() {
let $language    := 
    if (empty($version)) then
        $get:colDecorData//decor/project[@prefix=$prefix]/@defaultLanguage
    else (
        collection($get:strDecorVersion)//decor[@versionDate=$version]/project[@prefix=$prefix]/@defaultLanguage
    )
let $rawValueSet := 
    local:getRawValueSet($valueSet,<include ref="{$valueSet/(@ref|@id)}" flexibility="{$valueSet/@effectiveDate}"/>, $language, $prefix, $version)
return
    <valueSet>
    {
        $rawValueSet/@*
        ,
        $rawValueSet/desc
        ,
        $rawValueSet/publishingAuthority
        ,
        $rawValueSet/endorsingAuthority
        ,
        $rawValueSet/revisionHistory
        ,
        $rawValueSet/copyright
    }
    {
        (: when a value set is pulled from a compiled project version, the sourceCodeSystem should already be present :)
        for $sourceCodeSystem in distinct-values($rawValueSet//conceptList/concept/@codeSystem|$rawValueSet//conceptList/exception/@codeSystem|$rawValueSet//completeCodeSystem/@codeSystem)
        let $codeSystemName := ($rawValueSet//*[@codeSystem=$sourceCodeSystem]/@codeSystemName|$rawValueSet//sourceCodeSystem[@id=$sourceCodeSystem]/@identifierName)[1]
        let $codeSystemName := 
            if   (empty($codeSystemName))
            then (art:getNameForOID($sourceCodeSystem,$language,$prefix))
            else ($codeSystemName)
        return
            <sourceCodeSystem id="{$sourceCodeSystem}" identifierName="{$codeSystemName}"/>
    }
    {
        $rawValueSet//completeCodeSystem
    }
    {
        if ($rawValueSet//conceptList[*]) then (
            <conceptList>
            {
                $rawValueSet//conceptList/concept[not(ancestor::include[string(@exception)='true'])]
            }
            {
                for $node in $rawValueSet//conceptList/(exception|concept[ancestor::include[string(@exception)='true']])
                (:group $node as $exceptions by $node/@code as $code, $node/@codeSystem as $codeSystem:)
                group by $code := $node/@code , $codeSystem := $node/@codeSystem
                return
                    (:<exception>{$exceptions/@*, $exceptions/*}</exception>:)
                    <exception>{$node[1]/@*, $node[1]/*}</exception>
            }
            {
                $rawValueSet//conceptList/duplicate
            }
            </conceptList>
        ) else ()
    }
    </valueSet>
};

(:~
:   See vs:getValueSetList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?, $version as xs:string?) for documentation
:   
:   @param $id           - optional. Identifier of the valueset to retrieve
:   @param $name         - optional. Name of the valueset to retrieve (valueSet/@name)
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - optional. determines search scope. null is full server, pfx- limits scope to this project only
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?) as element()? {
    vs:getValueSetList($id, $name, $flexibility, $prefix, ())
};

(:~
:   Returns zero or more valuesets as listed in the terminology section. This function is useful e.g. to call from a ValueSetIndex. Parameter id, name or prefix is required.
:   &lt;return>
:       &lt;repository ident="epsos-">
:           &lt;valueSet ref="2.16.840.1.113883.1.11.159331" name="ActStatus" displayName="ActStatus"/>
:           &lt;valueSet id="1.3.6.1.4.1.12559.11.10.1.3.1.42.4" name="epSOSCountry" displayName="epSOS Country" effectiveDate="2013-06-03T00:00:00" statusCode="draft"/>
:       &lt;/repository>
:       &lt;repository ident="naw-">
:           &lt;valueSet id="2.16.840.1.113883.2.4.3.11.60.101.11.13" name="Land" displayName="Land" effectiveDate="2013-03-25T14:13:00" statusCode="final"/>
:           &lt;valueSet id="2.16.840.1.113883.2.4.3.11.60.101.11.1" name="VerzekeringsSoort" displayName="Verzekeringssoort" effectiveDate="2013-03-25T14:13:00" statusCode="final"/>
:       &lt;/repository>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-" referencedFrom="epsos-">
:           &lt;valueSet id="2.16.840.1.113883.1.11.159331" name="ActStatus" displayName="ActStatus" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318"/>
:       &lt;/repository>
:   &lt;/return>
:   
:   @param $id           - optional. Identifier of the valueset to retrieve
:   @param $name         - optional. Name of the valueset to retrieve (valueSet/@name)
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - optional. determines search scope. null is full server, pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the valueset will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero value sets in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function vs:getValueSetList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?, $version as xs:string?) as element()? {
let $decorTerminology        :=
    if (empty($prefix)) then
        (:without prefix there cannot be a relevant version. Get active repositories that aren't private:)
        $get:colDecorData//decor[@repository='true'][not(@private='true')]/terminology
    else if (empty($version)) then
        (:without version but apparently with a prefix, get active project:)
        $get:colDecorData//decor[project/@prefix=$prefix]/terminology
    else (
        (:with version and apparently with a prefix, get released project:)
        collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]/terminology
    )
let $projectvaluesets        :=
    if (empty($id) and empty($name)) then
        $decorTerminology/valueSet
    else if (empty($name)) then
        $decorTerminology/valueSet[@id=$id] | 
        $decorTerminology/valueSet[@ref=$id]
    else if (empty($id)) then
        $decorTerminology/valueSet[@name=$name]
    else
        $decorTerminology/valueSet[@id=$id] |
        $decorTerminology/valueSet[@ref=$id] |
        $decorTerminology/valueSet[@name=$name]

(: local server and external building block repository handling :)
let $repositoryValueSetLists :=
    <repositoryValueSetLists>
    {
        (: when retrieving value sets from a compiled project, the @url/@ident they came from are on the valueSet element
           reinstate that info on the repositoryValueSetList element so downstream logic works as if it really came from 
           the repository again.
        :)
        for $valuesets in $projectvaluesets[@url]
        group by $source := concat($valuesets/@url,$valuesets/@ident)
        return
            <repositoryValueSetList url="{$valuesets[1]/@url}" ident="{$valuesets[1]/@ident}" referencedFrom="{$prefix}">
            {
                for $valueset in $valuesets
                return
                    <valueSet>{$valueset/(@* except (@url|@ident|@referencedFrom)), $valueset/node()}</valueSet>
            }
            </repositoryValueSetList>
    }
    </repositoryValueSetLists>
    
(:now prune projectvaluesets from any valueSet[@url] as those are 'moved' to the repository section:)
let $projectvaluesets := $projectvaluesets[not(@url)]
    
return 
    <return>
    {
        if (empty($flexibility)) then (
            let $groupedValueSets :=
                for $valueSet in $projectvaluesets
                let $elmname := if ($valueSet/ancestor::decor/project/@prefix=$prefix) then 'project' else 'repository'
                group by $ident := $valueSet/ancestor::decor/project/@prefix
                return
                    element {$elmname}
                    {
                        attribute ident {$ident}
                        ,
                        for $version in $valueSet
                        return
                            <valueSet>{ $version/@* }</valueSet>
                    }
            let $groupedRepositories :=
                for $section in $repositoryValueSetLists/repositoryValueSetList[valueSet]
                let $elmname := if ($section[1][@url]) then 'repository' else 'project'
                group by $url := $section/@url , $ident := $section/@ident , $referencedFrom := $section/@referencedFrom
                return
                    element {$elmname}
                    {
                        $section[1]/@ident,
                        $section[1]/@url,
                        if ($section[1][@url]) then attribute {'referencedFrom'} {string-join(distinct-values($section/@referencedFrom),' ')} else (),
                        for $valueSet in $section/valueSet
                        return
                            <valueSet>{ $valueSet/@* }</valueSet>
                    }
            
            return ($groupedValueSets | $groupedRepositories)
            
        ) else if (matches($flexibility,'^\d{4}')) then (
            let $valueSetIds := distinct-values(
                $repositoryValueSetLists/repositoryValueSetList/valueSet[@id][@effectiveDate/string()=$flexibility]/@id |
                $projectvaluesets[@id][@effectiveDate/string()=$flexibility]/@id)
            
            let $groupedValueSets :=
                for $valueSet in $projectvaluesets[(exists(@ref) and @ref=$valueSetIds) or @effectiveDate/string()=$flexibility]
                let $elmname := if ($valueSet/ancestor::decor/project/@prefix=$prefix) then 'project' else 'repository'
                group by $ident := $valueSet/ancestor::decor/project/@prefix
                return
                    element {$elmname}
                    {
                        attribute ident {$ident}
                        ,
                        for $valueSet in $valueSet[(exists(@ref) and @ref=$valueSetIds) or @effectiveDate/string()=$flexibility]
                        return
                            <valueSet>{ $valueSet/@* }</valueSet>
                    }
            let $groupedRepositories :=
                for $section in $repositoryValueSetLists/repositoryValueSetList[valueSet[@ref=$valueSetIds or @effectiveDate/string()=$flexibility]]
                let $elmname := if ($section[1][@url]) then 'repository' else 'project'
                group by $url := $section/@url , $ident := $section/@ident , $referencedFrom := $section/@referencedFrom
                return
                    element {$elmname}
                    {
                        $section[1]/@ident,
                        $section[1]/@url,
                        if ($section[1][@url]) then attribute {'referencedFrom'} {string-join(distinct-values($section/@referencedFrom),' ')} else (),
                        for $valueSet in $section/valueSet[@ref=$valueSetIds or @effectiveDate/string()=$flexibility]
                        return
                            <valueSet>{ $valueSet/@* }</valueSet>
                    }
            
            return ($groupedValueSets | $groupedRepositories)
            
        ) else (
            let $valueSetIds := distinct-values($projectvaluesets/(@id|@ref))
            
            let $groupedValueSets :=
                for $valueSet in $projectvaluesets
                let $elmname := if ($valueSet/ancestor::decor/project/@prefix=$prefix) then 'project' else 'repository'
                group by $ident := $valueSet/ancestor::decor/project/@prefix
                return
                    element {$elmname}
                    {
                        attribute ident {$ident}
                        ,
                        for $valueSet in $valueSet[@id]
                        let $valueSetNewest := string(
                                max(
                                    ($projectvaluesets[@id=$valueSet/@id]/xs:dateTime(@effectiveDate),
                                    $repositoryValueSetLists/repositoryValueSetList/valueSet[@id=$valueSet/@id]/xs:dateTime(@effectiveDate))
                                )
                            )
                        where $valueSet/@effectiveDate=$valueSetNewest
                        return
                            <valueSet>{ $valueSet/@* }</valueSet>
                        ,
                        (:for $valueSet in $versions[@ref]:)
                        for $valueSet in $valueSet[@ref]
                        return
                            <valueSet>{ $valueSet/@* }</valueSet>
                    }
            let $groupedRepositories :=
                for $section in $repositoryValueSetLists/repositoryValueSetList[valueSet]
                let $elmname := if ($section[1][@url]) then 'repository' else 'project'
                group by $url := $section/@url , $ident := $section/@ident , $referencedFrom := $section/@referencedFrom
                return
                    element {$elmname}
                    {
                        $section[1]/@ident,
                        $section[1]/@url,
                        if ($section[1][@url]) then attribute {'referencedFrom'} {string-join(distinct-values($section/@referencedFrom),' ')} else (),
                        for $valueSet in $section/valueSet[@id]
                        let $valueSetNewest := string(
                                max(
                                    ($projectvaluesets[@id=$valueSet/@id]/xs:dateTime(@effectiveDate),
                                    $repositoryValueSetLists/repositoryValueSetList/valueSet[@id=$valueSet/@id]/xs:dateTime(@effectiveDate))
                                )
                            )
                        where $valueSet/@effectiveDate=$valueSetNewest
                        return
                            <valueSet>{ $valueSet/@* }</valueSet>
                    }
                    
            return ($groupedValueSets | $groupedRepositories)
        )
    }
    </return>
};

(:~
 :   Get contents of a valueSet and return like this:
 :   <valueSet id|ref="oid" ...>
 :       <completeCodeSystem .../>         -- if applicable
 :       <conceptList>
 :           <concept .../>
 :           <include ...>                 -- handled by local:getValueSetInclude() 
 :               <valueSet ...>
 :                   ...
 :               </valueSet>
 :           </include>
 :           <exception .../>
 :       </conceptList>
 :   </valueSet>
 :)
declare function local:getRawValueSet ($valueSet as element(), $includetrail as element()*, $language as xs:string, $prefix as xs:string, $version as xs:string?) as element()* {
<valueSet>
{
    (:$valueSet/@*[string-length()>0]:)
    $valueSet/@*[.!='']
}
{
    for $desc in $valueSet/desc
    return
        art:serializeNode($desc)
}
{
    $valueSet/publishingAuthority
    ,
    $valueSet/endorsingAuthority
    ,
    $valueSet/copyright
}
{
    for $revisionHistory in $valueSet/revisionHistory
    return
        <revisionHistory>
        {
            (:$revisionHistory/@*[string-length()>0]:)
            $revisionHistory/@*[.!='']
            ,
            for $desc in $revisionHistory/desc
            return
                art:serializeNode($desc)
        }
        </revisionHistory>
}
<!--{
    for $sourceCodeSystem in (distinct-values($valueSet/conceptList/concept/@codeSystem),distinct-values($valueSet/conceptList/exception/@codeSystem))
    let $codeSystemName := art:getNameForOID($sourceCodeSystem,$language,$prefix)
    return
        <sourceCodeSystem id="{$sourceCodeSystem}" identifierName="{$codeSystemName}"/>
}-->
{
    for $codeSystem in $valueSet/completeCodeSystem
    return
        <completeCodeSystem>
        {
            (:$codeSystem/@*[string-length()>0]:)
            $codeSystem/@*[.!='']
        }
        </completeCodeSystem>
}
{
    if ($valueSet/conceptList[*]) then (
        <conceptList>
        {
            for $concept in $valueSet/conceptList/concept
            return
                <concept>
                {
                    (:$concept/@*[string-length()>0]:)
                    $concept/@*[.!='']
                    ,
                    for $desc in $concept/desc
                    return
                        art:serializeNode($desc)
                }
                </concept>
        }
        {
            for $include in $valueSet/conceptList/include
            return
                local:getValueSetInclude($include,$includetrail,$language,$prefix,$version)
        }
        {
            for $exception in $valueSet/conceptList/exception
            return
                <exception>
                {
                    (:$exception/@*[string-length()>0]:)
                    $exception/@*[.!='']
                    ,
                    for $desc in $exception/desc
                    return
                        art:serializeNode($desc)
                }
                </exception>
        }
        </conceptList>
    ) else ()
}
</valueSet>
};

(:~
 :   Get contents of an include and return like this:
 :   <duplicate ref="oid" flexibility="flex" exception="exception"/>  -- duplicate include found
 :   
 :   or
 :   
 :   <include ref="oid" flexibility="flex" exception="exception">     -- note that the include may be omitted if it's not found
 :       <valueSet ...>                                               -- handled by local:getValueSet()
 :           ...
 :       </valueSet>
 :   </include>
 :)
declare function local:getValueSetInclude ($include as element(), $includetrail as element()*, $language as xs:string, $prefix as xs:string, $version as xs:string?) as element()* {
let $valuesetId              := $include/@ref
let $valuesetFlex            := $include/@flexibility

(: local server and external building block repository handling :)
let $internalrepositories    :=
    if (empty($version)) then
        $get:colDecorData/decor[project/@prefix=$prefix]
    else (
        collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]
    )
let $externalrepositories    := 
    if (not($internalrepositories/terminology/valueSet[@id=$valuesetId])) then
        $internalrepositories/project/buildingBlockRepository
    else ()
(:let $requestHeaders          := <headers><header name="Content-Type" value="text/xml"/></headers>:)
let $repositoryValueSetLists :=
    <repositoryValueSetLists>
    {
        local:getValueSetById($valuesetId, $prefix, $externalrepositories, <buildingBlockRepository url="{$vs:strDecorServicesURL}" ident="{$prefix}"/>)[valueSet[@id]]
    }
    {
        for $repository in $internalrepositories
        return
            <repositoryValueSetList ident="{$repository/project/@prefix}">
            {
                $repository/terminology/valueSet[@id=$valuesetId]
            }
            </repositoryValueSetList>
    }
    </repositoryValueSetLists>

let $effectiveDate := if (matches($valuesetFlex,'^\d{4}')) then $valuesetFlex else string(max($repositoryValueSetLists//valueSet[@id=$valuesetId]/xs:dateTime(@effectiveDate))[1])
let $valueSet      := ($repositoryValueSetLists//valueSet[@id=$valuesetId][@effectiveDate=$effectiveDate])[1]

return
    if ($includetrail[@ref=$include/@ref][@flexibility=$effectiveDate]) then (
        <duplicate>{$include/@*}</duplicate>
    )
    else (
        let $includetrail := $includetrail | <include ref="{$include/@ref}" flexibility="{$effectiveDate}"/>
        return
        <include ref="{$include/@ref}">
        {
            $include/@flexibility,
            $include/@exception
        }
        {
            if (exists($valueSet)) then 
                local:getRawValueSet($valueSet,$includetrail,$language,$prefix,$version)
            else ()
        }
        </include>
    )
};

(:~
 :   Look for valueSet[@id] and recurse if valueSet[@ref] is returned based on the buildingBlockRepositories in the project that returned it.
 :   If we get a valueSet[@ref] from an external repository (through RetrieveValueSet), then tough luck, nothing can help us. The returned 
 :   data is a nested repositoryValueSetList element allowing you to see the full trail should you need that. Includes duplicate protection 
 :   so every project is checked once only.
 :   Example below reads:
 :      - We checked hwg- and found BBR hg-
 :      - We checked hg- and found BBR nictz2bbr-
 :      - We checked nictiz2bbr- and found the requested valueSet
 :   <repositoryValueSetList url="http://decor.nictiz.nl/decor/services/" ident="hg-" referencedFrom="hwg-">
 :      <repositoryValueSetList url="http://decor.nictiz.nl/decor/services/" ident="nictiz2bbr-" referencedFrom="hg-">
 :          <valueSet id="2.16.840.1.113883.2.4.3.11.60.1.11.2" name="RoleCodeNLZorgverlenertypen" displayName="RoleCodeNL - zorgverlenertype (personen)" effectiveDate="2011-10-01T00:00:00" statusCode="final">
 :          ...
 :          </valueSet>
 :      </repositoryValueSetList>
 :   </repositoryValueSetList>
 :
 :)
declare function local:getValueSetById($id as xs:string, $prefix as xs:string, $externalrepositorylist as element()*, $bbrList as element()*) as element()* {
    for $repository in $externalrepositorylist
    let $hasBeenProcessedBefore := $bbrList[@url=$repository/@url][@ident=$repository/@ident]
    return
        if (not($hasBeenProcessedBefore)) then (
            <repositoryValueSetList url="{$repository/@url}" ident="{$repository/@ident}" referencedFrom="{$prefix}">
            {
                (: doc() calls are expensive: if this buildingBlockRepository resolves to our own server, then get it 
                   directly from the db. :)
                if ($repository/@url = $vs:strDecorServicesURL) then (
                    let $results := $get:colDecorData/decor[project/@prefix=$repository/@ident]/terminology/valueSet[(@id|@ref)=$id]
                    
                    return
                        if ($results[@id]) then ($results[@id])
                        else (
                            local:getValueSetById($id, $repository/@ident, $get:colDecorData/decor/project[@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        )
                )
                else if ($get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]) then (
                    let $results := $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]/terminology/valueSet[(@id|@ref)=$id]
                    
                    return
                        if ($results[@id]) then ($results[@id])
                        else (
                            local:getValueSetById($id, $repository/@ident, $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        )
                )
                else (
                    doc(xs:anyURI(concat($repository/@url,'/RetrieveValueSet?format=xml&amp;prefix=',$repository/@ident, '&amp;id=', $id)))/valueSets/project[@ident=$repository/@ident]/valueSet[@id]
                )
            }
            </repositoryValueSetList>
        ) else ()
    
};

(:~
 :   Look for valueSet[@id] and recurse if valueSet[@ref] is returned based on the buildingBlockRepositories in the project that returned it.
 :   If we get a valueSet[@ref] from an external repository (through RetrieveValueSet), then tough luck, nothing can help us. The returned 
 :   data is a nested repositoryValueSetList element allowing you to see the full trail should you need that. Includes duplicate protection 
 :   so every project is checked once only.
 :   Example below reads:
 :      - We checked hwg- and found BBR hg-
 :      - We checked hg- and found BBR nictz2bbr-
 :      - We checked nictiz2bbr- and found the requested valueSet
 :   <repositoryValueSetList url="http://decor.nictiz.nl/decor/services/" ident="hg-" referencedFrom="hwg-">
 :      <repositoryValueSetList url="http://decor.nictiz.nl/decor/services/" ident="nictiz2bbr-" referencedFrom="hg-">
 :          <valueSet id="2.16.840.1.113883.2.4.3.11.60.1.11.2" name="RoleCodeNLZorgverlenertypen" displayName="RoleCodeNL - zorgverlenertype (personen)" effectiveDate="2011-10-01T00:00:00" statusCode="final">
 :          ...
 :          </valueSet>
 :      </repositoryValueSetList>
 :   </repositoryValueSetList>
 :
 :)
declare function local:getValueSetByName($name as xs:string, $prefix as xs:string, $externalrepositorylist as element()*, $bbrList as element()*) as element()* {
    for $repository in $externalrepositorylist
    let $hasBeenProcessedBefore := $bbrList[@url=$repository/@url][@ident=$repository/@ident]
    return
        if (not($hasBeenProcessedBefore)) then (
            <repositoryValueSetList url="{$repository/@url}" ident="{$repository/@ident}" referencedFrom="{$prefix}">
            {
                (: doc() calls are expensive: if this buildingBlockRepository resolves to our own server, then get it 
                   directly from the db. :)
                if ($repository/@url = $vs:strDecorServicesURL) then (
                    let $results := $get:colDecorData/decor[project/@prefix=$repository/@ident]/terminology/valueSet[@name=$name]
                    
                    return
                        if ($results[@id]) then ($results[@id])
                        else (
                            local:getValueSetByName($name, $repository/@ident, $get:colDecorData/decor/project[@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        )
                )
                else if ($get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]) then (
                    let $results := $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]/terminology/valueSet[@name=$name]
                    
                    return
                        if ($results[@id]) then ($results[@id])
                        else (
                            local:getValueSetByName($name, $repository/@ident, $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        )
                )
                else (
                    doc(xs:anyURI(concat($repository/@url,'/RetrieveValueSet?format=xml&amp;prefix=',$repository/@ident, '&amp;name=', $name)))/valueSets/project[@ident=$repository/@ident]/valueSet[@id]
                )
            }
            </repositoryValueSetList>
        ) else ()
    
};
