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

module namespace cs              = "http://art-decor.org/ns/decor/codesystem";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "api-server-settings.xqm";
import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "../modules/art-decor.xqm";
declare namespace error          = "http://art-decor.org/ns/decor/codesystem/error";
declare namespace xs             = "http://www.w3.org/2001/XMLSchema";

declare variable $cs:strDecorServicesURL := adserver:getServerURLServices();

(:~
:   Return zero or more codesystems as-is wrapped in a &lt;return/&gt; element, and subsequently inside a &lt;repository&gt; element. This repository element
:   holds at least the attribute @ident with the originating project prefix and optionally the attribute @url with the repository URL in case of an external
:   repository. Id based references can match both codeSystem/@id and codeSystem/@ref. The latter is resolved. Note that duplicate codeSystem matches may be 
:   returned. Example output:
:   &lt;return>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/repository>
:   &lt;/return>
:   
:   @param $id           - required. Identifier of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemById ($id as xs:string, $flexibility as xs:string?) as element() {
    <return>
    {
        for $prefix in $get:colDecorData//decor[not(string(@private)='true')]/project/@prefix
        return
            cs:getCodeSystemById ($id, $flexibility, $prefix)/*
    }
    </return>
};

(:~
:   See cs:getCodeSystemById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for documentation
:   
:   @param $id           - required. Identifier of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element()* {
    cs:getCodeSystemById($id, $flexibility, $prefix, ())
};

(:~
:   Return zero or more codesystems as-is wrapped in a &lt;return/&gt; element, and subsequently inside a &lt;repository&gt; element. This repository element
:   holds at least the attribute @ident with the originating project prefix and optionally the attribute @url with the repository URL in case of an external
:   repository. Id based references can match both codeSystem/@id and codeSystem/@ref. The latter is resolved. Note that duplicate codeSystem matches may be 
:   returned. Example output for codeSystem/@ref:<br/>
:   &lt;return>
:       &lt;project ident="epsos-">
:           &lt;codeSystem ref="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature">
:               ...
:           &lt;/codeSystem>
:       &lt;/project>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-" referencedFrom="epsos-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/repository>
:   &lt;/return>
:   <p>Example output for codeSystem/@id:</p>
:   &lt;return>
:       &lt;project ident="epsos-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/repository>
:   &lt;/return>
:   
:   @param $id           - required. Identifier of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id (regardless of name), yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the codesystem will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element()* {
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
   Also don't go looking in repositories when there's no codeSystem/@ref matching our id
:)
let $externalrepositories := 
    if (empty($version) and not($internalrepositories/terminology/codeSystem[@id=$id])) then
        $internalrepositories/project/buildingBlockRepository
    else ()

let $repositoryCodeSystemLists :=
    <repositoryCodeSystemLists>
    {
        local:getCodeSystemById($id, $prefix, $externalrepositories, <buildingBlockRepository url="{$cs:strDecorServicesURL}" ident="{$prefix}"/>)[codeSystem[@id]]
    }
    {
        (:from the requested project, return codeSystem/(@id and @ref):)
        (: when retrieving code systems from a compiled project, the @url/@ident they came from are on the codeSystem element
           reinstate that info on the repositoryCodeSystemList element so downstream logic works as if it really came from 
           the repository again.
        :)
        for $repository in $internalrepositories
        for $codesystems in $repository/terminology/codeSystem[@id=$id]|$repository/terminology/codeSystem[@ref=$id]
        group by $source := concat($codesystems/@url,$codesystems/@ident)
        return
            if (string-length($source)=0) then
                <repositoryCodeSystemList ident="{$repository/project/@prefix}">
                {
                    $codesystems
                }
                </repositoryCodeSystemList>
            else (
                <repositoryCodeSystemList url="{$codesystems[1]/@url}" ident="{$codesystems[1]/@ident}" referencedFrom="{$prefix}">
                {
                    for $codesystem in $codesystems
                    return
                        <codeSystem>{$codesystem/(@* except (@url|@ident|@referencedFrom)), $codesystem/node()}</codeSystem>
                }
                </repositoryCodeSystemList>
            )
    }
    </repositoryCodeSystemLists>

return
    <return>
    {
        if (empty($flexibility)) then
            for $repositoryCodeSystemList in $repositoryCodeSystemLists/repositoryCodeSystemList[codeSystem]
            let $elmname := if ($repositoryCodeSystemList[not(@url)]/@ident=$prefix) then 'project' else 'repository'
            return
                element {$elmname}
                {
                    $repositoryCodeSystemList/@*,
                    for $codeSystem in $repositoryCodeSystemList/codeSystem
                    order by xs:dateTime($codeSystem/@effectiveDate) descending
                    return   $codeSystem
                }
        else if (matches($flexibility,'^\d{4}')) then
            for $repositoryCodeSystemList in $repositoryCodeSystemLists/repositoryCodeSystemList[codeSystem[@ref or @effectiveDate=$flexibility]]
            let $elmname := if ($repositoryCodeSystemList[not(@url)]/@ident=$prefix) then 'project' else 'repository'
            return
                element {$elmname}
                {
                    $repositoryCodeSystemList/@*,
                    $repositoryCodeSystemList/codeSystem[@ref or @effectiveDate=$flexibility]
                }
        else
            for $repositoryCodeSystemList in $repositoryCodeSystemLists/repositoryCodeSystemList[codeSystem[@ref or @effectiveDate=string((max($repositoryCodeSystemLists//codeSystem/xs:dateTime(@effectiveDate)))[1])]]
            let $elmname := if ($repositoryCodeSystemList[not(@url)]/@ident=$prefix) then 'project' else 'repository'
            return
                element {$elmname}
                {
                    $repositoryCodeSystemList/@*,
                    $repositoryCodeSystemList/codeSystem[@ref or @effectiveDate=string((max($repositoryCodeSystemLists//codeSystem/xs:dateTime(@effectiveDate)))[1])]
                }
    }
    </return>
};

(:~
:   Return zero or more codesystems as-is. Name based references cannot return codeSystem/@ref, only codeSystem/@id. Name based references do not cross project 
:   boundaries, so no repositories beit local or remote are consulted. Note that duplicate codeSystem matches may be returned. Example output:
:   &lt;return>
:       &lt;project ident="ad2bbr-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/project>
:   &lt;/return>
:   
:   @param $name             - required. Name of the codesystem to retrieve (codeSystem/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemByName ($name as xs:string, $flexibility as xs:string?, $useRegexMatching as xs:boolean) as element() {
    <return>
    {
        for $prefix in $get:colDecorData//decor[not(string(@private)='true')]/project/@prefix
        return
            cs:getCodeSystemByName($name, $flexibility, $prefix, $useRegexMatching)/*
    }
    </return>
};

(:~
:   See cs:getCodeSystemByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) for documentation
:   
:   @param $name             - required. Name of the codesystem to retrieve (codeSystem/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix           - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean) as element()* {
    cs:getExpandedCodeSystemByName($name, $flexibility, $prefix, $useRegexMatching, ())
};

(:~
:   Return zero or more codesystems as-is. Name based references cannot return codeSystem/@ref, only codeSystem/@id. Name based references do not cross project 
:   boundaries, so no repositories beit local or remote are consulted. Note that duplicate codeSystem matches may be returned. Example output:
:   &lt;return>
:       &lt;project ident="ad2bbr-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/project>
:   &lt;/return>
:   
:   @param $name             - required. Name of the codesystem to retrieve (codeSystem/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name (regardless of id), yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix           - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @param $version          - optional. if empty defaults to current version. if valued then the codesystem will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:   @since 2014-04-02 Changed behavior so 'dynamic' does not retrieve the latest version per id, but the latest calculated over all ids
:)
declare function cs:getCodeSystemByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) as element()* {

let $argumentCheck :=
    if (string-length($name)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument name is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()
    
let $internalrepositories       := 
    if ($useRegexMatching) then 
        if (empty($version)) then 
            $get:colDecorData/decor[project/@prefix=$prefix]/terminology/codeSystem[matches(@name,$name)]
        else
            collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]/terminology/codeSystem[matches(@name,$name)]
    else
        if (empty($version)) then 
            $get:colDecorData/decor[project/@prefix=$prefix]/terminology/codeSystem[@name=$name]
        else
            collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]/terminology/codeSystem[@name=$name]

let $repositoryCodeSystemLists    :=
    <repositoryCodeSystemLists>
    {
        (:  don't go looking in repositories when this is an archived project version. the project should be compiled already and 
            be self contained. Repositories in their current state would give a false picture of the status quo when the project 
            was archived. Also don't go looking in repositories when there's no codeSystem/@ref matching our id
        :)
        if (empty($version) and not($internalrepositories[@id])) then
            let $buildingBlockRepositories  := $get:colDecorData/decor/project[@prefix=$prefix]/buildingBlockRepository
            (:this is the starting point for the list of servers we already visited to avoid circular reference problems:)
            let $bbrList                    := <buildingBlockRepository url="{$cs:strDecorServicesURL}" ident="{$prefix}"/>
            return
                local:getCodeSystemByName($name, $prefix, $buildingBlockRepositories, $bbrList)[codeSystem[@id]]
        else ()
    }
    </repositoryCodeSystemLists>

let $codeSystemsById := 
    for $id in distinct-values($internalrepositories/@id | $internalrepositories/@ref | $repositoryCodeSystemLists/repositoryCodeSystemList/codeSystem/@id)
    return
        cs:getCodeSystemById($id,$flexibility,$prefix,$version)/*

return
    <return>
    {
        if (empty($flexibility)) then
            for $repositoryCodeSystemList in $codeSystemsById[codeSystem]
            let $elmname := $repositoryCodeSystemList/name()
            return
                element {$elmname}
                {
                    $repositoryCodeSystemList/@*,
                    for $codeSystem in $repositoryCodeSystemList/codeSystem
                    order by xs:dateTime($codeSystem/@effectiveDate) descending
                    return   $codeSystem
                }
        else if (matches($flexibility,'^\d{4}')) then
            for $repositoryCodeSystemList in $codeSystemsById[codeSystem[@ref or @effectiveDate=$flexibility]]
            let $elmname := $repositoryCodeSystemList/name()
            return
                element {$elmname}
                {
                    $repositoryCodeSystemList/@*,
                    $repositoryCodeSystemList/codeSystem[@ref or @effectiveDate=$flexibility]
                }
        else
            for $repositoryCodeSystemList in $codeSystemsById[codeSystem[@ref or @effectiveDate=string((max($codeSystemsById//codeSystem/xs:dateTime(@effectiveDate)))[1])]]
            let $elmname := $repositoryCodeSystemList/name()
            return
                element {$elmname}
                {
                    $repositoryCodeSystemList/@*,
                    $repositoryCodeSystemList/codeSystem[@ref or @effectiveDate=string((max($codeSystemsById//codeSystem/xs:dateTime(@effectiveDate)))[1])]
                }
    }
    </return>
};

(:~
:   See cs:getCodeSystemByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for documentation
:   
:   @param $idOrName     - required. Identifier (@id) or name (@name) of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element()* {
    cs:getCodeSystemByRef($idOrName, $flexibility, $prefix, ())
};

(:~
:   Returns zero or more codesystems as-is. This function is useful to call from a vocabulary reference inside a template, or from a 
:   templateAssociation where @id or @name may have been used as the reference key. Uses cs:getCodeSystemById() and cs:getCodeSystemByName() to get the
:   result and returns that as-is. See those functions for more documentation on the output format.
:   
:   @param $idOrName     - required. Identifier (@id) or name (@name) of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the codesystem will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element()* {

let $argumentCheck :=
    if (string-length($idOrName)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument idOrName is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

return
    if (matches($idOrName,'^[\d\.]+$')) then
        cs:getCodeSystemById($idOrName,$flexibility,$prefix,$version)
    else
        cs:getCodeSystemByName($idOrName,$flexibility,$prefix,false(),$version)
};

(:~
:   Return zero or more expanded codesystems wrapped in a &lt;return/&gt; element, and subsequently inside a &lt;repository&gt; element. This repository element
:   holds at least the attribute @ident with the originating project prefix and optionally the attribute @url with the repository URL in case of an external
:   repository. Id based references can match both codeSystem/@id and codeSystem/@ref. The latter is resolved. Note that duplicate codeSystem matches may be 
:   returned. Example output:
:   &lt;return>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/repository>
:   &lt;/return>
:   <ul><li> Codesystems get an extra attribute @fromRepository containing the originating project prefix/ident</li> 
:   <li>codeSystem/@ref is treated as if it were the referenced codesystem</li>
:   <li>If parameter prefix is not used then only codeSystem/@id is matched. If that does not give results, then 
:     codeSystem/@ref is matched, potentially expanding into a buildingBlockRepository</li>
:                                
:   @param $id           - required. Identifier of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystemById ($id as xs:string, $flexibility as xs:string?) as element() {
    <result>
    {
        for $prefix in $get:colDecorData//decor[not(string(@private)='true')]/project/@prefix
        return
            cs:getExpandedCodeSystemById($id, $flexibility, $prefix)/*
    }
    </result>
};

(:~
:   See cs:getExpandedCodeSystemById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for documentation
:   
:   @param $id           - required. Identifier of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystemById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element() {
    cs:getExpandedCodeSystemById ($id, $flexibility, $prefix, ())
};

(:~
:   Return zero or more expanded codesystems wrapped in a &lt;return/&gt; element, and subsequently inside a &lt;repository&gt; element. This repository element
:   holds at least the attribute @ident with the originating project prefix and optionally the attribute @url with the repository URL in case of an external
:   repository. Id based references can match both codeSystem/@id and codeSystem/@ref. The latter is resolved. Note that duplicate codeSystem matches may be 
:   returned. Example output:
:   &lt;return>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/repository>
:   &lt;/return>
:   <ul><li> Codesystems get an extra attribute @fromRepository containing the originating project prefix/ident</li> 
:   <li>codeSystem/@ref is treated as if it were the referenced codesystem</li>
:   <li>If parameter prefix is not used then only codeSystem/@id is matched. If that does not give results, then 
:     codeSystem/@ref is matched, potentially expanding into a buildingBlockRepository</li>
:                                
:   @param $id           - required. Identifier of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the codesystem will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystemById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element() {
let $argumentCheck :=
    if (string-length($id)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument id is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

let $codeSystems := cs:getCodeSystemById($id, $flexibility, $prefix, $version)

return
    <result>
    {
        for $repository in $codeSystems/(project|repository)
        return
            element {name($repository)}
            {
                $repository/@*,
                $repository/codeSystem[@ref],
                for $codeSystem in $repository/codeSystem[@id]
                return
                    cs:getExpandedCodeSystem($codeSystem, $prefix, $version)
            }
    }
    </result>
};

(:~
:   Return zero or more expanded codesystems. Name based references cannot return codeSystem/@ref, only codeSystem/@id. Name based references do not cross project 
:   boundaries, so no repositories beit local or remote are consulted. Note that duplicate codeSystem matches may be returned. Example output:
:   &lt;return>
:       &lt;repository ident="ad2bbr-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/repository>
:   &lt;/return>
:   <ul><li>Codesystems get an extra attribute @fromRepository containing the originating project prefix/ident</li> 
:   <li>If parameter prefix is used and parameter id leads to a codeSystem/@ref, then this is treated as if it were the referenced codesystem</li>
:   <li>If parameter prefix is not used then only codeSystem/@id is matched. If that does not give results, then codeSystem/@ref is matched, 
:   potentially expanding into a buildingBlockRepository</li>
:
:   @param $name             - required. Name of the codesystem to retrieve (codeSystem/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @return The expanded codeSystem
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystemByName ($name as xs:string, $flexibility as xs:string?, $useRegexMatching as xs:boolean) as element() {
    <result>
    {
        for $prefix in $get:colDecorData//decor[not(string(@private)='true')]/project/@prefix
        return
            cs:getExpandedCodeSystemByName($name, $flexibility, $prefix, $useRegexMatching)/*
    }
    </result>
};

(:~
:   See cs:getExpandedCodeSystemByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) for documentation
:
:   @param $name             - required. Name of the codesystem to retrieve (codeSystem/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix           - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @return The expanded codeSystem
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystemByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean) as element() {
    cs:getExpandedCodeSystemByName($name, $flexibility, $prefix, $useRegexMatching, ())
};

(:~
:   Return zero or more expanded codesystems. Name based references cannot return codeSystem/@ref, only codeSystem/@id. Name based references do not cross project 
:   boundaries, so no repositories beit local or remote are consulted. Note that duplicate codeSystem matches may be returned. Example output:
:   &lt;return>
:       &lt;repository ident="ad2bbr-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.10282" name="ParticipationSignature" displayName="ParticipationSignature" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318">
:               ...
:           &lt;/codeSystem>
:       &lt;/repository>
:   &lt;/return>
:   <ul><li>Codesystems get an extra attribute @fromRepository containing the originating project prefix/ident</li> 
:   <li>If parameter prefix is used and parameter id leads to a codeSystem/@ref, then this is treated as if it were the referenced codesystem</li>
:   <li>If parameter prefix is not used then only codeSystem/@id is matched. If that does not give results, then codeSystem/@ref is matched, 
:   potentially expanding into a buildingBlockRepository</li>
:
:   @param $name             - required. Name of the codesystem to retrieve (codeSystem/@name) Regex pattern matching is allowed. Searching is case sensitive.
:   @param $flexibility      - optional. null gets all versions, 'dynamic' gets the newest version based on name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix           - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching - required. determines whether or not $name is regular expression or not
:   @param $version          - optional. if empty defaults to current version. if valued then the codesystem will come explicitly from that archived project version which is expected to be a compiled version
:   @return The expanded codeSystem
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystemByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) as element() {
let $argumentCheck :=
    if (string-length($name)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument name is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

let $codeSystems := cs:getCodeSystemByName($name, $flexibility, $prefix, $useRegexMatching, $version)

return
    <result>
    {
        for $repository in $codeSystems/(project|repository)
        return
            element {name($repository)}
            {
                $repository/@*,
                $repository/codeSystem[@ref],
                for $codeSystem in $repository/codeSystem[@id]
                return
                    cs:getExpandedCodeSystem($codeSystem, $prefix, $version)
            }
    }
    </result>
};

(:~
:   See cs:getExpandedCodeSystemByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for documentation
:   
:   @param $idOrName     - required. Identifier (@id) or name (@name) of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystemByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element()* {
    cs:getExpandedCodeSystemByRef($idOrName, $flexibility, $prefix, ())
};

(:~
:   Returns zero or more expanded codesystems. This function is useful to call from a vocabulary reference inside a template, or from a 
:   templateAssociation where @id or @name may have been used as the reference key. Uses cs:getExpandedCodeSystemById() and cs:getExpandedCodeSystemByName() 
:   to get the result and returns that as-is. See those functions for more documentation on the output format.
:   
:   @param $idOrName     - required. Identifier (@id) or name (@name) of the codesystem to retrieve
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the codesystem will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystemByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element()* {
let $argumentCheck :=
    if (string-length($idOrName)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument idOrName is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

return
    if (matches($idOrName,'^[\d\.]+$')) then
        cs:getExpandedCodeSystemById($idOrName,$flexibility,$prefix, $version)
    else
        cs:getExpandedCodeSystemByName($idOrName,$flexibility,$prefix,false(), $version)
};

(:~
:   See cs:getExpandedCodeSystem($codeSystem as element(), $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $codeSystem     - required. The codeSystem element with content to expand
:   @param $prefix       - required. The origin of codeSystem. pfx- limits scope this project only
:   @return The expanded codeSystem
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystem($codeSystem as element(), $prefix as xs:string) as element() {
    cs:getExpandedCodeSystem($codeSystem, $prefix, ())
};

(:~
:   Expands a codeSystem with @id. Use cs:getExpandedCodeSystemsById to resolve a codeSystem/@ref first. 
:   &lt;codeSystem all-attributes of the input&gt;
:       &lt;desc all /&gt;
:       &lt;conceptList&gt;
:           &lt;codedConcept all-attributes-and-designation-elements /&gt;
:       &lt;/conceptList&gt;
:   &lt;/codeSystem&gt;
:                                
:   @param $codeSystem     - required. The codeSystem element with content to expand
:   @param $prefix       - required. The origin of codeSystem. pfx- limits scope this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the codesystem will come explicitly from that archived project version which is expected to be a compiled version
:   @return The expanded codeSystem
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getExpandedCodeSystem($codeSystem as element(), $prefix as xs:string, $version as xs:string?) as element() {
let $language    := 
    if (empty($version)) then
        $get:colDecorData//decor/project[@prefix=$prefix]/@defaultLanguage
    else (
        collection($get:strDecorVersion)//decor[@versionDate=$version]/project[@prefix=$prefix]/@defaultLanguage
    )
let $rawCodeSystem := 
    local:getRawCodeSystem($codeSystem,<include ref="{$codeSystem/(@ref|@id)}" flexibility="{$codeSystem/@effectiveDate}"/>, $language, $prefix, $version)
return
    <codeSystem>
    {
        $rawCodeSystem/@*
        ,
        $rawCodeSystem/desc
        ,
        $rawCodeSystem/publishingAuthority
        ,
        $rawCodeSystem/endorsingAuthority
        ,
        $rawCodeSystem/revisionHistory
        ,
        $rawCodeSystem/copyright
    }
    {
        if ($rawCodeSystem//conceptList[*]) then (
            <conceptList>
            {
                $rawCodeSystem//conceptList/codedConcept
            }
            </conceptList>
        ) else ()
    }
    </codeSystem>
};

(:~
:   See cs:getCodeSystemList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?, $version as xs:string?) for documentation
:   
:   @param $id           - optional. Identifier of the codesystem to retrieve
:   @param $name         - optional. Name of the codesystem to retrieve (codeSystem/@name)
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - optional. determines search scope. null is full server, pfx- limits scope to this project only
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?) as element()? {
    cs:getCodeSystemList($id, $name, $flexibility, $prefix, ())
};

(:~
:   Returns zero or more codesystems as listed in the terminology section. This function is useful e.g. to call from a CodeSystemIndex. Parameter id, name or prefix is required.
:   &lt;return>
:       &lt;repository ident="epsos-">
:           &lt;codeSystem ref="2.16.840.1.113883.1.11.159331" name="ActStatus" displayName="ActStatus"/>
:           &lt;codeSystem id="1.3.6.1.4.1.12559.11.10.1.3.1.42.4" name="epSOSCountry" displayName="epSOS Country" effectiveDate="2013-06-03T00:00:00" statusCode="draft"/>
:       &lt;/repository>
:       &lt;repository ident="naw-">
:           &lt;codeSystem id="2.16.840.1.113883.2.4.3.11.60.101.11.13" name="Land" displayName="Land" effectiveDate="2013-03-25T14:13:00" statusCode="final"/>
:           &lt;codeSystem id="2.16.840.1.113883.2.4.3.11.60.101.11.1" name="VerzekeringsSoort" displayName="Verzekeringssoort" effectiveDate="2013-03-25T14:13:00" statusCode="final"/>
:       &lt;/repository>
:       &lt;repository url="http://art-decor.org/decor/services/" ident="ad2bbr-" referencedFrom="epsos-">
:           &lt;codeSystem id="2.16.840.1.113883.1.11.159331" name="ActStatus" displayName="ActStatus" effectiveDate="2013-03-11T00:00:00" statusCode="final" versionLabel="DEFN=UV=VO=1206-20130318"/>
:       &lt;/repository>
:   &lt;/return>
:   
:   @param $id           - optional. Identifier of the codesystem to retrieve
:   @param $name         - optional. Name of the codesystem to retrieve (codeSystem/@name)
:   @param $flexibility  - optional. null gets all versions, 'dynamic' gets the newest version based on id or name, yyyy-mm-ddThh:mm:ss gets this specific version
:   @param $prefix       - optional. determines search scope. null is full server, pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the codesystem will come explicitly from that archived project version which is expected to be a compiled version
:   @return Zero code systems in case no matches are found, one if only one exists or if a specific version was requested, or more if more versions exist and no specific version was requested
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function cs:getCodeSystemList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?, $version as xs:string?) as element()? {
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
let $projectcodesystems        :=
    if (empty($id) and empty($name)) then
        $decorTerminology/codeSystem
    else if (empty($name)) then
        $decorTerminology/codeSystem[@id=$id] | 
        $decorTerminology/codeSystem[@ref=$id]
    else if (empty($id)) then
        $decorTerminology/codeSystem[@name=$name]
    else
        $decorTerminology/codeSystem[@id=$id] |
        $decorTerminology/codeSystem[@ref=$id] |
        $decorTerminology/codeSystem[@name=$name]

(: local server and external building block repository handling :)
let $repositoryCodeSystemLists :=
    <repositoryCodeSystemLists>
    {
        (: when retrieving code systems from a compiled project, the @url/@ident they came from are on the codeSystem element
           reinstate that info on the repositoryCodeSystemList element so downstream logic works as if it really came from 
           the repository again.
        :)
        for $codesystems in $projectcodesystems[@url]
        group by $source := concat($codesystems/@url,$codesystems/@ident)
        return
            <repositoryCodeSystemList url="{$codesystems[1]/@url}" ident="{$codesystems[1]/@ident}" referencedFrom="{$prefix}">
            {
                for $codesystem in $codesystems
                return
                    <codeSystem>{$codesystem/(@* except (@url|@ident|@referencedFrom)), $codesystem/node()}</codeSystem>
            }
            </repositoryCodeSystemList>
    }
    </repositoryCodeSystemLists>
    
(:now prune projectcodesystems from any codeSystem[@url] as those are 'moved' to the repository section:)
let $projectcodesystems := $projectcodesystems[not(@url)]
    
return 
    <return>
    {
        if (empty($flexibility)) then (
            let $groupedCodeSystems :=
                for $codeSystem in $projectcodesystems
                let $elmname := if ($codeSystem/ancestor::decor/project/@prefix=$prefix) then 'project' else 'repository'
                group by $ident := $codeSystem/ancestor::decor/project/@prefix
                return
                    element {$elmname}
                    {
                        attribute ident {$ident}
                        ,
                        for $version in $codeSystem
                        return
                            <codeSystem>{ $version/@* }</codeSystem>
                    }
            let $groupedRepositories :=
                for $section in $repositoryCodeSystemLists/repositoryCodeSystemList[codeSystem]
                let $elmname := if ($section[1][@url]) then 'repository' else 'project'
                group by $url := $section/@url , $ident := $section/@ident , $referencedFrom := $section/@referencedFrom
                return
                    element {$elmname}
                    {
                        $section[1]/@ident,
                        $section[1]/@url,
                        if ($section[1][@url]) then attribute {'referencedFrom'} {string-join(distinct-values($section/@referencedFrom),' ')} else (),
                        for $codeSystem in $section/codeSystem
                        return
                            <codeSystem>{ $codeSystem/@* }</codeSystem>
                    }
            
            return ($groupedCodeSystems | $groupedRepositories)
            
        ) else if (matches($flexibility,'^\d{4}')) then (
            let $codeSystemIds := distinct-values(
                $repositoryCodeSystemLists/repositoryCodeSystemList/codeSystem[@id][@effectiveDate/string()=$flexibility]/@id |
                $projectcodesystems[@id][@effectiveDate/string()=$flexibility]/@id)
            
            let $groupedCodeSystems :=
                for $codeSystem in $projectcodesystems[(exists(@ref) and @ref=$codeSystemIds) or @effectiveDate/string()=$flexibility]
                let $elmname := if ($codeSystem/ancestor::decor/project/@prefix=$prefix) then 'project' else 'repository'
                group by $ident := $codeSystem/ancestor::decor/project/@prefix
                return
                    element {$elmname}
                    {
                        attribute ident {$ident}
                        ,
                        for $codeSystem in $codeSystem[(exists(@ref) and @ref=$codeSystemIds) or @effectiveDate/string()=$flexibility]
                        return
                            <codeSystem>{ $codeSystem/@* }</codeSystem>
                    }
            let $groupedRepositories :=
                for $section in $repositoryCodeSystemLists/repositoryCodeSystemList[codeSystem[@ref=$codeSystemIds or @effectiveDate/string()=$flexibility]]
                let $elmname := if ($section[1][@url]) then 'repository' else 'project'
                group by $url := $section/@url , $ident := $section/@ident , $referencedFrom := $section/@referencedFrom
                return
                    element {$elmname}
                    {
                        $section[1]/@ident,
                        $section[1]/@url,
                        if ($section[1][@url]) then attribute {'referencedFrom'} {string-join(distinct-values($section/@referencedFrom),' ')} else (),
                        for $codeSystem in $section/codeSystem[@ref=$codeSystemIds or @effectiveDate/string()=$flexibility]
                        return
                            <codeSystem>{ $codeSystem/@* }</codeSystem>
                    }
            
            return ($groupedCodeSystems | $groupedRepositories)
            
        ) else (
            let $codeSystemIds := distinct-values($projectcodesystems/(@id|@ref))
            
            let $groupedCodeSystems :=
                for $codeSystem in $projectcodesystems
                let $elmname := if ($codeSystem/ancestor::decor/project/@prefix=$prefix) then 'project' else 'repository'
                group by $ident := $codeSystem/ancestor::decor/project/@prefix
                return
                    element {$elmname}
                    {
                        attribute ident {$ident}
                        ,
                        for $codeSystem in $codeSystem[@id]
                        let $codeSystemNewest := string(
                                max(
                                    ($projectcodesystems[@id=$codeSystem/@id]/xs:dateTime(@effectiveDate),
                                    $repositoryCodeSystemLists/repositoryCodeSystemList/codeSystem[@id=$codeSystem/@id]/xs:dateTime(@effectiveDate))
                                )
                            )
                        where $codeSystem/@effectiveDate=$codeSystemNewest
                        return
                            <codeSystem>{ $codeSystem/@* }</codeSystem>
                        ,
                        (:for $codeSystem in $versions[@ref]:)
                        for $codeSystem in $codeSystem[@ref]
                        return
                            <codeSystem>{ $codeSystem/@* }</codeSystem>
                    }
            let $groupedRepositories :=
                for $section in $repositoryCodeSystemLists/repositoryCodeSystemList[codeSystem]
                let $elmname := if ($section[1][@url]) then 'repository' else 'project'
                group by $url := $section/@url , $ident := $section/@ident , $referencedFrom := $section/@referencedFrom
                return
                    element {$elmname}
                    {
                        $section[1]/@ident,
                        $section[1]/@url,
                        if ($section[1][@url]) then attribute {'referencedFrom'} {string-join(distinct-values($section/@referencedFrom),' ')} else (),
                        for $codeSystem in $section/codeSystem[@id]
                        let $codeSystemNewest := string(
                                max(
                                    ($projectcodesystems[@id=$codeSystem/@id]/xs:dateTime(@effectiveDate),
                                    $repositoryCodeSystemLists/repositoryCodeSystemList/codeSystem[@id=$codeSystem/@id]/xs:dateTime(@effectiveDate))
                                )
                            )
                        where $codeSystem/@effectiveDate=$codeSystemNewest
                        return
                            <codeSystem>{ $codeSystem/@* }</codeSystem>
                    }
                    
            return ($groupedCodeSystems | $groupedRepositories)
        )
    }
    </return>
};

(:~
 :   Get contents of a codeSystem and return like this:
 :   <codeSystem id|ref="oid" ...>
 :       <desc/>                           -- if applicable
 :       <conceptList>
 :           <codedConcept .../>
 :       </conceptList>
 :   </codeSystem>
 :)
declare function local:getRawCodeSystem ($codeSystem as element(), $includetrail as element()*, $language as xs:string, $prefix as xs:string, $version as xs:string?) as element()* {
<codeSystem>
{
    $codeSystem/@*
}
{
    for $desc in $codeSystem/desc
    return
        art:serializeNode($desc)
}
{
    $codeSystem/publishingAuthority
    ,
    $codeSystem/endorsingAuthority
    ,
    $codeSystem/copyright
}
{
    for $revisionHistory in $codeSystem/revisionHistory
    return
        <revisionHistory>
        {
            $revisionHistory/@*[string-length()>0]
            ,
            for $desc in $revisionHistory/desc
            return
                art:serializeNode($desc)
        }
        </revisionHistory>
}
{
    if ($codeSystem/conceptList[*]) then (
        <conceptList>
        {
            for $concept in $codeSystem/conceptList/codedConcept
            return
                <codedConcept>
                {
                    $concept/@*[not(empty(.))]
                    ,
                    for $desc in $concept/designation
                    return
                        art:serializeNode($desc)
                }
                </codedConcept>
        }
        </conceptList>
    ) else ()
}
</codeSystem>
};

(:~
 :   Look for codeSystem[@id] and recurse if codeSystem[@ref] is returned based on the buildingBlockRepositories in the project that returned it.
 :   If we get a codeSystem[@ref] from an external repository (through RetrieveCodeSystem), then tough luck, nothing can help us. The returned 
 :   data is a nested repositoryCodeSystemList element allowing you to see the full trail should you need that. 
 :   Example below reads:
 :      - We checked hwg- and found BBR hg-
 :      - We checked hg- and found BBR nictz2bbr-
 :      - We checked nictiz2bbr- and found the requested codeSystem
 :   <repositoryCodeSystemList url="http://decor.nictiz.nl/decor/services/" ident="hg-" referencedFrom="hwg-">
 :      <repositoryCodeSystemList url="http://decor.nictiz.nl/decor/services/" ident="nictiz2bbr-" referencedFrom="hg-">
 :          <codeSystem id="2.16.840.1.113883.2.4.3.11.60.1.11.2" name="RoleCodeNLZorgverlenertypen" displayName="RoleCodeNL - zorgverlenertype (personen)" effectiveDate="2011-10-01T00:00:00" statusCode="final">
 :          ...
 :          </codeSystem>
 :      </repositoryCodeSystemList>
 :   </repositoryCodeSystemList>
 :
 :)
declare function local:getCodeSystemById($id as xs:string, $prefix as xs:string, $externalrepositorylist as element()*, $bbrList as element()*) as element()* {
    for $repository in $externalrepositorylist
    let $hasBeenProcessedBefore := $bbrList[@url=$repository/@url][@ident=$repository/@ident]
    return
        if (not($hasBeenProcessedBefore)) then (
            <repositoryCodeSystemList url="{$repository/@url}" ident="{$repository/@ident}" referencedFrom="{$prefix}">
            {
                (: doc() calls are expensive: if this buildingBlockRepository resolves to our own server, then get it 
                   directly from the db. :)
                if ($repository/@url = $cs:strDecorServicesURL) then (
                    let $results := $get:colDecorData/decor[project/@prefix=$repository/@ident]/terminology/codeSystem[(@id|@ref)=$id]
                    
                    return
                        if ($results[@id]) then ($results[@id])
                        else (
                            local:getCodeSystemById($id, $repository/@ident, $get:colDecorData/decor/project[@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        )
                )
                else if ($get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]) then (
                    let $results := $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]/terminology/codeSystem[(@id|@ref)=$id]
                    
                    return
                        if ($results[@id]) then ($results[@id])
                        else (
                            local:getCodeSystemById($id, $repository/@ident, $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        )
                )
                else (
                    doc(xs:anyURI(concat($repository/@url,'/RetrieveCodeSystem?format=xml&amp;prefix=',$repository/@ident, '&amp;id=', $id)))/codeSystems/project[@ident=$repository/@ident]/codeSystem[@id]
                )
            }
            </repositoryCodeSystemList>
        ) else ()
    
};

(:~
 :   Look for codeSystem[@id] and recurse if codeSystem[@ref] is returned based on the buildingBlockRepositories in the project that returned it.
 :   If we get a codeSystem[@ref] from an external repository (through RetrieveCodeSystem), then tough luck, nothing can help us. The returned 
 :   data is a nested repositoryCodeSystemList element allowing you to see the full trail should you need that. 
 :   Example below reads:
 :      - We checked hwg- and found BBR hg-
 :      - We checked hg- and found BBR nictz2bbr-
 :      - We checked nictiz2bbr- and found the requested codeSystem
 :   <repositoryCodeSystemList url="http://decor.nictiz.nl/decor/services/" ident="hg-" referencedFrom="hwg-">
 :      <repositoryCodeSystemList url="http://decor.nictiz.nl/decor/services/" ident="nictiz2bbr-" referencedFrom="hg-">
 :          <codeSystem id="2.16.840.1.113883.2.4.3.11.60.1.11.2" name="RoleCodeNLZorgverlenertypen" displayName="RoleCodeNL - zorgverlenertype (personen)" effectiveDate="2011-10-01T00:00:00" statusCode="final">
 :          ...
 :          </codeSystem>
 :      </repositoryCodeSystemList>
 :   </repositoryCodeSystemList>
 :
 :)
declare function local:getCodeSystemByName($name as xs:string, $prefix as xs:string, $externalrepositorylist as element()*, $bbrList as element()*) as element()* {
    for $repository in $externalrepositorylist
    let $hasBeenProcessedBefore := $bbrList[@url=$repository/@url][@ident=$repository/@ident]
    return
        if (not($hasBeenProcessedBefore)) then (
            <repositoryCodeSystemList url="{$repository/@url}" ident="{$repository/@ident}" referencedFrom="{$prefix}">
            {
                (: doc() calls are expensive: if this buildingBlockRepository resolves to our own server, then get it 
                   directly from the db. :)
                if ($repository/@url = $cs:strDecorServicesURL) then (
                    let $results := $get:colDecorData/decor[project/@prefix=$repository/@ident]/terminology/codeSystem[@name=$name]
                    
                    return
                        if ($results[@id]) then ($results[@id])
                        else (
                            local:getCodeSystemByName($name, $repository/@ident, $get:colDecorData/decor/project[@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        )
                )
                else if ($get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]) then (
                    let $results := $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]/terminology/codeSystem[@name=$name]
                    
                    return
                        if ($results[@id]) then ($results[@id])
                        else (
                            local:getCodeSystemByName($name, $repository/@ident, $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        )
                )
                else (
                    doc(xs:anyURI(concat($repository/@url,'/RetrieveCodeSystem?format=xml&amp;prefix=',$repository/@ident, '&amp;name=', $name)))/codeSystems/project[@ident=$repository/@ident]/codeSystem[@id]
                )
            }
            </repositoryCodeSystemList>
        ) else ()
    
};
