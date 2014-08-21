xquery version "3.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket, Kai U. Heitmann
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

module namespace templ           = "http://art-decor.org/ns/decor/template";

import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "api-server-settings.xqm";
import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "../modules/art-decor.xqm";
import module namespace adsearch = "http://art-decor.org/ns/decor/search" at "api-decor-search.xqm";

declare namespace xforms         = "http://www.w3.org/2002/xforms";
declare namespace error          = "http://art-decor.org/ns/decor/template/error";
declare namespace xs             = "http://www.w3.org/2001/XMLSchema";

declare variable $templ:strDecorServicesURL := adserver:getServerURLServices();

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   server local repositories that aren't private and either refer to or define the requested template(s).
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $id           - required. Identifier of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getTemplateById ($id as xs:string, $flexibility as xs:string?) as element(return) {
    <return>
    {
        for $prefix in $get:colDecorData//decor[@repository='true'][not(@private='true')]/project/@prefix
        return
            templ:getTemplateById ($id, $flexibility, $prefix)/*
    }
    </return>
};

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix.
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $id           - required. Identifier of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element(return) {
    templ:getTemplateById($id, $flexibility, $prefix, ())
};

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix and optionally from the archived version, but by default from the active project.
:   The template element has attribute @ident to indicate the project it holds data for, and carries the @ref attribute when the project has a 
:   reference to the requested template(s). If a project happens to refer to AND define the template there will be at least 2 template elements, 
:   with the project prefix in @ident, one carrying @ref and one carrying @id.
:
:   Inside the path /return/template[@id or @ref][@ident] is 1..* template element. This may is the actual template (@id or @ref) as-is with one 
:   exception: when the template originates from a different project than parent::template/@ident, the origin is added using template/@url and 
:   template/@ident.
:
:   Example output:
:   &lt;return>
:       &lt;!-- Reference found in project vacc- with template found in BBR ccda- -->
:       &lt;template ref="1.2.3.4" ident="vacc-">
:           &lt;template id="1.2.3.4" name="AgeObservation" displayName="Age Observation" statusCode="active" effectiveDate="2011-01-01T00:00:00" url="http://art-decor.org/decor/services/" ident="ccda-">
:               ...
:           &lt;/template>
:           &lt;template id="1.2.3.4" name="AgeObservation" displayName="Age Observation" statusCode="active" effectiveDate="2012-02-02T00:00:00" url="http://art-decor.org/decor/services/" ident="ccda-">
:               ...
:           &lt;/template>
:           &lt;template ref="1.2.3.4" name="AgeObservation" displayName="Age Observation"/>
:       &lt;/template>
:       &lt;!-- Defined templates found in project vacc- -->
:       &lt;template id="1.2.3.4" ident="vacc-">
:           &lt;template id="1.2.3.4" name="AgeObservation" displayName="Age Observation" statusCode="review" effectiveDate="2013-03-03T00:00:00">
:               ...
:           &lt;/template>
:           &lt;template id="1.2.3.4" name="AgeObservation" displayName="Age Observation" statusCode="draft" effectiveDate="2014-04-04T00:00:00">
:               ...
:           &lt;/template>
:       &lt;/template>
:   &lt;/return>
:   
:   @param $id           - required. Identifier of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the template will come explicitly from that archived project version which is expected to be a compiled version
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:)
declare function templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element(return) {
let $argumentCheck              :=
    if (string-length($id)=0) then
        error(xs:QName('error:NotEnoughArguments'),'Argument id is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

let $internalrepositories       := 
    if (empty($version)) then
        $get:colDecorData//decor[project/@prefix=$prefix]
    else (
        collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]
    )

let $repositoryTemplateLists    :=
    <repositoryTemplateLists>
    {
        (:  don't go looking in repositories when this is an archived project version. the project should be compiled already and 
            be self contained. Repositories in their current state would give a false picture of the status quo when the project 
            was archived. Also don't go looking in repositories when there's no template/@ref matching our id
        :)
        if (empty($version) and not($internalrepositories/rules/template[@id=$id])) then
            let $buildingBlockRepositories  := $internalrepositories/project/buildingBlockRepository
            (:this is the starting point for the list of servers we already visited to avoid circular reference problems:)
            let $bbrList                    := <buildingBlockRepository url="{$templ:strDecorServicesURL}" ident="{$prefix}"/>
            return
                local:getTemplateById($id, $prefix, $buildingBlockRepositories, $bbrList)[template[@id]]
        else ()
    }
    {
        for $repository in $internalrepositories
        for $templates in $repository/rules/template[@id=$id]|$repository/rules/template[@ref=$id]
        group by $source := concat($templates/@url,$templates/@ident)
        return
            if (string-length($source)=0) then
                <repositoryTemplateList ident="{$repository/project/@prefix}">
                {
                    $templates
                }
                </repositoryTemplateList>
            else (
                <repositoryTemplateList url="{$templates[1]/@url}" ident="{$templates[1]/@ident}" referencedFrom="{$prefix}">
                {
                    for $template in $templates
                    return
                        <template>{$template/(@* except (@url|@ident|@referencedFrom)), $template/node()}</template>
                }
                </repositoryTemplateList>
            )
    }
    </repositoryTemplateLists>

let $allTemplates               :=
    if (empty($flexibility)) then
        (:flexibility empty -- return all ref+id:)
        $repositoryTemplateLists/repositoryTemplateList/template
    else if (matches($flexibility,'^\d{4}')) then
        (:flexibility explicit timestamp -- return ref and matches only:)
        $repositoryTemplateLists/repositoryTemplateList/template[@ref or @effectiveDate=$flexibility]
    else
        (:flexibility probably 'dynamic' -- return ref and newest only:)
        $repositoryTemplateLists/repositoryTemplateList/template[@ref or @effectiveDate=string((max($repositoryTemplateLists/*/template/xs:dateTime(@effectiveDate)))[1])]
return
    <return>
    {
        for $templatesById in $allTemplates[@id][not($allTemplates[@ref]) or not(parent::*/@url)]
        group by $id := $templatesById/@id
        return (
            <template id="{$id}" ident="{$prefix}">
            {
                for $template in $templatesById
                order by xs:dateTime($template/@effectiveDate) descending
                return 
                    templ:getNormalizedTemplate(
                        <template>
                        {
                            $template/(@* except (@url|@ident)),
                            $template/parent::*/@url,
                            $template/parent::*/@ident,
                            $template/node()
                        }
                        </template>
                    )
            }
            </template>
        )
        ,
        for $templatesByRef in $allTemplates[@ref]
        group by $id := $templatesByRef/@ref
        return (
            <template ref="{$id}" ident="{$prefix}">
            {
                for $template in $allTemplates[@id=$id][parent::*/@url]
                order by xs:dateTime($template/@effectiveDate) descending
                return 
                    templ:getNormalizedTemplate(
                        <template>
                        {
                            $template/(@* except (@url|@ident)),
                            $template/parent::*/@url,
                            $template/parent::*/@ident,
                            $template/node()
                        }
                        </template>
                    )
                ,
                $templatesByRef
            }
            </template>
        )
    }
    </return>
};

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   server local repositories that aren't private and either refer to or define the requested template(s).
:   See templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) for more info
:   
:   @param $name                - required. Name of the template to retrieve. Matches template/@name
:   @param $flexibility         - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $useRegexMatching    - required. When true uses Lucene to find the template/@name match. When false uses case sensitive exact matching.
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getTemplateByName ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?)
:)
declare function templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $useRegexMatching as xs:boolean) as element(return) {
    <return>
    {
        for $prefix in $get:colDecorData//decor[@repository='true'][not(@private='true')]/project/@prefix
        return
            templ:getTemplateByName($name, $flexibility, $prefix, $useRegexMatching)/*
    }
    </return>
};

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix.
:   See templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) for more info
:   
:   @param $name                - required. Name of the template to retrieve. Matches template/@name
:   @param $flexibility         - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix              - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching    - required. When true uses Lucene to find the template/@name match. When false uses case sensitive exact matching.
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getTemplateByName ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?)
:)
declare function templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean) as element()* {
    templ:getTemplateByName($name, $flexibility, $prefix, $useRegexMatching, ())
};

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix and optionally from the archived version, but by default from the active project.
:   The results are found as follows:
:   1. Get all matches based on template/@name from project
:   2. Use template/@id + param $flexibility from matches and return result of templ:getTemplateById($id, $flexibility, $prefix, $version)
:   
:   @param $name                - required. Name of the template to retrieve. Matches template/@name
:   @param $flexibility         - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix              - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching    - required. When true uses Lucene to find the template/@name match. When false uses case sensitive exact matching.
:   @param $version             - optional. if empty defaults to current version. if valued then the template will come explicitly from that archived project version which is expected to be a compiled version
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) as element(return) {
let $argumentCheck          :=
    if (string-length($name)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument name is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

let $decor                  := 
    if (empty($version)) then 
        $get:colDecorData/decor[project/@prefix=$prefix]
    else
        collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]

let $internalrepositories       := 
    if ($useRegexMatching) then 
        let $luceneQuery    := local:getSimpleLuceneQuery(tokenize(lower-case($name),'\s'))
        let $luceneOptions  := local:getSimpleLuceneOptions()
        return
            $decor/rules/template[ft:query(@name,$luceneQuery,$luceneOptions)]
    else
        $decor/rules/template[@name=$name]

let $repositoryTemplateLists    :=
    <repositoryTemplateLists>
    {
        (:  don't go looking in repositories when this is an archived project version. the project should be compiled already and 
            be self contained. Repositories in their current state would give a false picture of the status quo when the project 
            was archived. Also don't go looking in repositories when there's no template/@ref matching our id
        :)
        if (empty($version) and not($internalrepositories[@id])) then
            let $buildingBlockRepositories  := $decor/project/buildingBlockRepository
            (:this is the starting point for the list of servers we already visited to avoid circular reference problems:)
            let $bbrList                    := <buildingBlockRepository url="{$templ:strDecorServicesURL}" ident="{$prefix}"/>
            return
                local:getTemplateByName($name, $prefix, $buildingBlockRepositories, $bbrList)[template[@id]]
        else ()
    }
    </repositoryTemplateLists>

return
    <return>
    {
        for $id in distinct-values($internalrepositories/@id | $internalrepositories/@ref | $repositoryTemplateLists/repositoryTemplateList/template/@id)
        return
            templ:getTemplateById($id,$flexibility,$prefix,$version)/template
    }
    </return>
};

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix.
:   See templ:getTemplateByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $idOrName     - required. Identifier or Name of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getTemplateByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getTemplateByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element()* {
    templ:getTemplateByRef($idOrName, $flexibility, $prefix, ())
};

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix and optionally from the archived version, but by default from the active project.
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) and
:       templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $idOrName     - required. Identifier or Name of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the template will come explicitly from that archived project version which is expected to be a compiled version
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:   @see templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getTemplateByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element()* {

let $argumentCheck :=
    if (string-length($idOrName)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument idOrName is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

return
    if (matches($idOrName,'^[\d\.]+$')) then
        templ:getTemplateById($idOrName,$flexibility,$prefix,$version)
    else
        templ:getTemplateByName($idOrName,$flexibility,$prefix,false(),$version)
};

(:~
:   Return zero or more expanded templates wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   server local repositories that aren't private and either refer to or define the requested template(s).
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $id           - required. Identifier of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getExpandedTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getExpandedTemplateById ($id as xs:string, $flexibility as xs:string?) as element() {
    <result>
    {
        for $prefix in $get:colDecorData//decor[@repository='true'][not(@private='true')]/project/@prefix
        return
            templ:getExpandedTemplateById($id, $flexibility, $prefix)/*
    }
    </result>
};

(:~
:   Return zero or more expanded templates wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix.
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $id           - required. Identifier of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getExpandedTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element() {
    templ:getExpandedTemplateById ($id, $flexibility, $prefix, ())
};

(:~
:   Return zero or more templates wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   server local repositories that aren't private and either refer to or define the requested template(s).
:   The template element has attribute @ident to indicate the project it holds data for, and carries the @ref attribute when the project has a 
:   reference to the requested template(s). If a project happens to refer to AND define the template there will be at least 2 template elements, 
:   with the project prefix in @ident, one carrying @ref and one carrying @id.
:
:   Inside the path /return/template[@id or @ref][@ident] is 1..* template element. This may is the expanded template (@id or @ref) with additions:
:   - when the template originates from a different project than parent::template/@ident, the origin is added using template/@url and template/@ident.
:   - the item element is added at every relevant level where the template itself doesn't explicitly define it
:   - the include element will have the extra attributes tmid, tmname, tmdisplayName containing the id/name/displayName of the referred template (unless it cannot be found)
:   - the include element will have an extra attribute linkedartefactmissing='true' when the referred template cannot be found
:   - the include element will contain the template it refers (unless it cannot be found)
:   - the element[@contains] element will have the extra attributes tmid, tmname, tmdisplayName containing the id/name/displayName of the contained template (unless it cannot be found)
:   - the element[@contains] element will have an extra attribute linkedartefactmissing='true' when the contained template cannot be found
:   - the vocabulary[@valueSet] element will have the extra attributes vsid, vsname, vsdisplayName containing the id/name/displayName of the referred value set (unless it cannot be found)
:   - the vocabulary[@valueSet] element will have an extra attribute linkedartefactmissing='true' when the referred value set cannot be found
:   - at the bottom of the template there may be extra elements:
:     - If this is a template that is used in a transaction: &lt;representingTemplate ref="..." flexibility="..." model="..." sourceDataset="..." type="stationary" schematron="vacc-vacccda2"/>
:     - For every include[@ref] / element[@contains]        : &lt;ref type="contains|include" id="..." name="..." displayName="..." effectiveDate="...."/>
:     - For every project template that calls this template : &lt;ref type="dependency" id="..." name="..." displayName="..." effectiveDate="...."/>
:       &lt;staticAssociations>
:
:           - For every template association:
:           &lt;origconcept datasetId="..." ref="..." effectiveDate="..." elementId="...">
:               &lt;concept id=".." effectiveDate="...">
:                   &lt;name language="nl-NL">...</name>
:                   &lt;desc language="nl-NL">...</desc>
:               &lt;/concept>
:           &lt;/origconcept>
:
:       &lt;/staticAssociations>
:
:
:   Example output:
:   &lt;return>
:       &lt;!-- Defined templates found in project vacc- -->
:       <template ref="1.3.6.1.4.1.19376.1.5.3.1.3.4" ident="vacc-">
:           &lt;!-- Defined templates found in project vacc- -->
:           &lt;template id="1.2.3.4" name="HistoryofPresentIllness" displayName="History of Present Illness Section" isClosed="false" effectiveDate="2012-06-01T00:00:00" statusCode="draft" versionLabel="" expirationDate="" officialReleaseDate="" url="http://art-decor.org/decor/services/" ident="ad3bbr-">
:               &lt;desc language="en-US">...</desc>
:               &lt;desc language="de-DE">...</desc>
:               &lt;classification type="cdasectionlevel">
:                   &lt;item label="HistoryofPresentIllness"/>
:               &lt;/classification>
:               &lt;context id="**">
:                   &lt;item label="HistoryofPresentIllness"/>
:               &lt;/context>
:               &lt;example>
:                   &lt;section classCode="DOCSECT" moodCode="EVN">
:                       &lt;templateId root="2.16.840.1.113883.2.11.10.103"/>
:                       &lt;code code="10164-2" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="History of Present Illness"/>
:                       &lt;title>title</title>
:                       &lt;text>text</text>
:                   &lt;/section>
:               &lt;/example>
:               &lt;element name="hl7:section">
:                   &lt;item label="HistoryofPresentIllness"/>
:                   &lt;attribute name="classCode" value="DOCSECT" isOptional="true"/>
:                   &lt;attribute name="moodCode" value="EVN" isOptional="true"/>
:                   &lt;element name="hl7:templateId" minimumMultiplicity="1" maximumMultiplicity="1" datatype="II">
:                       &lt;item label="HistoryofPresentIllness"/>
:                       &lt;attribute name="root" value="1.3.6.1.4.1.19376.1.5.3.1.3.4"/>
:                   &lt;/element>
:                   &lt;element name="hl7:code" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="CD">
:                       &lt;item label="HistoryofPresentIllness"/>
:                       &lt;vocabulary code="10164-2" codeSystem="2.16.840.1.113883.6.1" vsid="" vsname="" vsdisplayName=""/>
:                   &lt;/element>
:                   &lt;element name="hl7:title" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="ST">
:                       &lt;item label="HistoryofPresentIllness"/>
:                   &lt;/element>
:                   &lt;element name="hl7:text" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true" datatype="SD.TEXT">
:                       &lt;item label="HistoryofPresentIllness"/>
:                   &lt;/element>
:               &lt;/element>
:               &lt;-- Extra elements: -->
:               &lt;representingTemplate ref="1.3.6.1.4.1.19376.1.5.3.1.3.4" flexibility="2012-06-01T00:00:00" model="POCD_MT000040NL" sourceDataset="2.16.840.1.113883.3.1937.99.61.7.1.1" type="stationary" schematron="vacc-vacccda2"/>
:               &lt;ref type="contains" id="2.16.840.1.113883.3.1937.99.61.7.10.900222" name="ImmunizationActivity" displayName="CCDA Immunization Activity" effectiveDate="2014-03-07T11:56:16"/>
:               &lt;ref type="dependency" id="2.16.840.1.113883.3.1937.99.61.7.10.900220" name="ImmunizationSection" displayName="CCDA Immunization Section" effectiveDate="2014-03-07T11:45:34"/>
:               &lt;ref type="dependency" id="2.16.840.1.113883.3.1937.99.61.7.10.1" name="MinimalCDAVaccdocument" displayName="Minimal CDA vaccination document" effectiveDate="2013-10-10T00:00:00"/>
:               &lt;staticAssociations/>
:           &lt;/template>
:           &lt;template ref="1.3.6.1.4.1.19376.1.5.3.1.3.4" name="HistoryofPresentIllness" displayName="History of Present Illness Section"/>
:       &lt;/template>
:   &lt;/return>
:   
:   @param $id           - required. Identifier of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the template will come explicitly from that archived project version which is expected to be a compiled version
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:)
declare function templ:getExpandedTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element() {
let $argumentCheck :=
    if (string-length($id)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument id is required')
    else if (string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix is required')
    else ()

let $templates := templ:getTemplateById($id, $flexibility, $prefix, $version)

return
    <result>
    {
        for $templatesById in $templates/*
        return
            element {name($templatesById)}
            {
                $templatesById/@*,
                for $template in $templatesById/template
                return
                if ($template[@ref]) then
                    $template
                else
                    templ:getExpandedTemplate($template, $prefix, $version)
            }
    }
    </result>
};

(:~
:   Return zero or more exapnded templates wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   server local repositories that aren't private and either refer to or define the requested template(s).
:   See templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) for more info
:   
:   @param $name                - required. Name of the template to retrieve. Matches template/@name
:   @param $flexibility         - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $useRegexMatching    - required. When true uses Lucene to find the template/@name match. When false uses case sensitive exact matching.
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getExpandedTemplateByName ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?)
:)
declare function templ:getExpandedTemplateByName ($name as xs:string, $flexibility as xs:string?, $useRegexMatching as xs:boolean) as element() {
let $argumentCheck :=
    if (string-length($name)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument name is required')
    else ()

return
    <result>
    {
        for $prefix in $get:colDecorData//decor[@repository='true'][not(@private='true')]/project/@prefix
        return
            templ:getExpandedTemplateByName($name, $flexibility, $prefix, $useRegexMatching)/*
    }
    </result>
};

(:~
:   Return zero or more expanded templates wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix.
:   See templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) for more info
:   
:   @param $name                - required. Name of the template to retrieve. Matches template/@name
:   @param $flexibility         - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix              - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching    - required. When true uses Lucene to find the template/@name match. When false uses case sensitive exact matching.
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getExpandedTemplateByName ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?)
:)
declare function templ:getExpandedTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean) as element() {
    templ:getExpandedTemplateByName($name, $flexibility, $prefix, $useRegexMatching, ())
};

(:~
:   Return zero or more expanded templates wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix and optionally from the archived version, but by default from the active project.
:   The results are found as follows:
:   1. Get all matches based on template/@name from project
:   2. Use template/@id + param $flexibility from matches and return result of templ:getTemplateById($id, $flexibility, $prefix, $version)
:   
:   @param $name                - required. Name of the template to retrieve. Matches template/@name
:   @param $flexibility         - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix              - required. determines search scope. pfx- limits scope to this project only
:   @param $useRegexMatching    - required. When true uses Lucene to find the template/@name match. When false uses case sensitive exact matching.
:   @param $version             - optional. if empty defaults to current version. if valued then the template will come explicitly from that archived project version which is expected to be a compiled version
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getExpandedTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getExpandedTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $useRegexMatching as xs:boolean, $version as xs:string?) as element() {
let $argumentCheck :=
    if (string-length($name)=0 or string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix and name are required')
    else ()

let $templates := templ:getTemplateByName($name, $flexibility, $prefix, $useRegexMatching, $version)

return
    <result>
    {
        for $templatesById in $templates/*
        return
            element {name($templatesById)}
            {
                $templatesById/@*,
                for $template in $templatesById/template
                return
                if ($template[@ref]) then
                    $template
                else
                    templ:getExpandedTemplate($template, $prefix, $version)
            }
    }
    </result>
};

(:~
:   Return zero or more templates as-is wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix.
:   See templ:getTemplateByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $idOrName     - required. Identifier or Name of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getExpandedTemplateByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getExpandedTemplateByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string) as element()* {
    templ:getExpandedTemplateByRef($idOrName, $flexibility, $prefix, ())
};

(:~
:   Return zero or more expanded templates wrapped in a &lt;return/&gt; element, and subsequently inside one or more &lt;template&gt; elements for
:   the project as indicated by param $prefix and optionally from the archived version, but by default from the active project.
:   See templ:getTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) and
:       templ:getTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) for more info
:   
:   @param $idOrName     - required. Identifier or Name of the template to retrieve
:   @param $flexibility  - optional. null gets all versions, yyyy-mm-ddThh:mm:ss gets this specific version, anything that doesn't cast to xs:dateTime gets latest version
:   @param $prefix       - required. determines search scope. pfx- limits scope to this project only
:   @param $version      - optional. if empty defaults to current version. if valued then the template will come explicitly from that archived project version which is expected to be a compiled version
:   @return Matching templates in &lt;return/&gt; element
:   @author Alexander Henket
:   @since 2014-06-20
:   @see templ:getExpandedTemplateById ($id as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:   @see templ:getExpandedTemplateByName ($name as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?)
:)
declare function templ:getExpandedTemplateByRef ($idOrName as xs:string, $flexibility as xs:string?, $prefix as xs:string, $version as xs:string?) as element()* {

let $argumentCheck :=
    if (string-length($idOrName)=0 or string-length($prefix)=0) then 
        error(xs:QName('error:NotEnoughArguments'),'Argument prefix and idOrName are required')
    else ()

return
    if (matches($idOrName,'^[\d\.]+$')) then
        templ:getExpandedTemplateById($idOrName,$flexibility,$prefix, $version)
    else
        templ:getExpandedTemplateByName($idOrName,$flexibility,$prefix,false(), $version)
};

declare function templ:getExpandedTemplate($template as element(), $prefix as xs:string) as element() {
    templ:getExpandedTemplate($template, $prefix, ())
};

declare function templ:getExpandedTemplate($template as element(), $prefix as xs:string, $version as xs:string?) as element() {
(: all rules and terminologies of this project for later use :)
let $decorRules                     := 
    if (empty($version)) then
        $get:colDecorData//decor[project/@prefix=$prefix]/rules
    else (
        collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]/rules
    )
let $decorTerms  := $decorRules/ancestor::decor/terminology
(: all transactions where this template is ref'ed :)
let $decorRepresentingTemplates     := $decorRules/ancestor::decor/scenarios//transaction/representingTemplate[@ref]
let $newestTemplateEffectiveDate    := string(max($decorRules/template[@id=$template/@id]/xs:dateTime(@effectiveDate)))
let $currentTemplateIsNewest        := exists($template[@ref][not(@flexibility)] or $template[@ref][not(@flexibility='dynamic')] or $template[@effectiveDate = $newestTemplateEffectiveDate])

let $language                       := $decorRules/ancestor::decor/project/@defaultLanguage

return
    <template id="{$template/@id}" name="{$template/@name}" displayName="{$template/@displayName}" isClosed="{$template/@isClosed='true'}"
              effectiveDate="{$template/@effectiveDate}" statusCode="{$template/@statusCode}" versionLabel="{$template/@versionLabel}"
              expirationDate="{$template/@expirationDate}" officialReleaseDate="{$template/@officialReleaseDate}">
    {
        $template/@url,
        $template/@ident,
        art:serializeDescriptionNodes($template/desc)/*
    }
    {
        let $theitem := if ($template/item) then $template/item else <item label="{$template/@name}"/>
        
        for $node in $template/*[not(name()='desc')]
        return
            local:copyNodes($node, $theitem, 1, $decorRules, $decorTerms)
    }
    {
        (: get where the template is a representing template :)
        for $rtemp in $decorRepresentingTemplates
        let $rtempFlexibility := 
            if ($rtemp[matches(@flexibility,'^\d{4}')]) then (
                (:starts with 4 digits, explicit dateTime:)
                string($rtemp/@flexibility)
            ) else (
                (:empty or dynamic:)
                $newestTemplateEffectiveDate
            )
        let $rtempFlexValue   :=
            if (string-length($rtemp/@flexibility)>0) then (
                $rtemp/@flexibility
            ) else (
                'dynamic'
            )
        let $rtempTransaction := $rtemp/parent::transaction
        return
        if ($rtemp[@ref=$template/@id][$rtempFlexibility=$template/@effectiveDate]) then
               <representingTemplate ref="{$rtemp/@ref}" flexibility="{$rtempFlexValue}" model="{$rtempTransaction/@model}" sourceDataset="{$rtemp/@sourceDataset}" type="{$rtempTransaction/@type}" schematron="{$prefix}{$rtempTransaction/@label}"/>
        else()
    }
    {
        local:getDependendies($template, $template/@id, 1, $decorRules)
    }
    {
       
        local:templateUses($template, $template/@id, 1, $decorRules)
    }
    {
        (: template dependencies, automatgically determined :)
        let $me := $template/@effectiveDate
        for $template in $decorRules
            return 
                if ($template/@effectiveDate != $me) then <ref type="template" id="{$template/@id}" name="{$template/@name}" displayName="{$template/@displayName}" effectiveDate="{$template/@effectiveDate}"/> else ()
    }
    {
        <staticAssociations>
        {
            for $association in $decorRules/templateAssociation[@templateId=$template/@id][@effectiveDate=$template/@effectiveDate]/concept
            let $datasetId := $get:colDecorData//concept[@id=$association/@ref][@effectiveDate=$association/@effectiveDate][not(ancestor::history)]/ancestor::dataset/@id
            return
            <origconcept datasetId="{$datasetId}" ref="{$association/@ref}" effectiveDate="{$association/@effectiveDate}" elementId="{$association/@elementId}">
            {
                art:getOriginalConceptName($association)
            }
            </origconcept>
        }
        </staticAssociations>
    }
</template>
};

(:~
:   Returns template with elements as-is except:
:   - template/@isClosed gets an explicit value
:   - attribute is normalized as name/value pair
:   - element/include/vocabulary that could have @flexibility but don't get flexibility='dynamic'
:   - empty attributes on element/include/choice/attribute/classification/relationship/vocabulary/example are stripped
:)
declare function templ:getNormalizedTemplate($template as element()) as element(template) {
let $theitem := if ($template/item) then $template/item else <item label="{$template/@name}"/>
return
    <template>
    {
        $template/(@*[string-length()>0] except (@isClosed)),
        if ($template[@id]) then 
            attribute isClosed {$template/@isClosed='true'}
        else ()
    }
    {
        for $node in $template/*
        return
            local:normalizeNodes($node)
    }
    </template>
};

(:
:   Rewrite all shorthands to the same name/value format to ease processing
:   Remove @isOptional if @probited='true'. Explicitly set @isOptional otherwise. (default value for @isOptional is 'false')
:)
declare function templ:normalizeAttributes($attributes as element(attribute)*) as element(attribute)* {
    for $attribute in $attributes
    for $att in $attribute/(@* except (@xsi:type|@selected|@originalOpt|@originalType|@conf|@isOptional|@prohibited|@datatype|@value))
    let $anme := if ($att[name()='name']) then $att/string() else ($att/name())
    let $aval := if ($att[name()='name']) then $att/../@value/string() else ($att/string())
    return
        <attribute name="{$anme}">
        {
            if (string-length($aval)>0) then 
                attribute value {$aval}
            else (),
            if ($att/../@prohibited='true') then
                attribute prohibited {'true'}
            else (
                attribute isOptional {$att/../@isOptional='true'}
            ),
            $att/../@datatype,
            $att/../node()
        }
        </attribute>
};

declare function templ:getTemplateList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?) as element()? {
    templ:getTemplateList($id, $name, $flexibility, $prefix, (), false())
};

declare function templ:getTemplateList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?, $version as xs:string?) as element()? {
    templ:getTemplateList($id, $name, $flexibility, $prefix, $version, false())
};

declare function templ:getTemplateList ($id as xs:string?, $name as xs:string?, $flexibility as xs:string?, $prefix as xs:string?, $version as xs:string?, $classified as xs:boolean) as element()? {
let $decorRules         :=
    if (empty($prefix)) then
        (:without prefix there cannot be a relevant version. Get active repositories that aren't private:)
        $get:colDecorData//decor[@repository='true'][not(@private='true')]/rules
    else if (empty($version)) then
        (:without version but apparently with a prefix, get active project:)
        $get:colDecorData//decor[project/@prefix=$prefix]/rules
    else (
        (:with version and apprently with a prefix, get released project:)
        collection($get:strDecorVersion)//decor[@versionDate=$version][project/@prefix=$prefix]/rules
    )

let $projecttemplates   :=
    if (empty($id) and empty($name)) then
        $decorRules/template
    else if (empty($name)) then
        $decorRules/template[@id=$id] | 
        $decorRules/template[@ref=$id]
    else if (empty($id)) then
        $decorRules/template[@name=$name]
    else
        $decorRules/template[@id=$id] |
        $decorRules/template[@ref=$id] |
        $decorRules/template[@name=$name]

let $decorRepresentingTemplates := $decorRules/ancestor::decor[project/@prefix=$prefix]/scenarios//representingTemplate[@ref]

(: get all project templates:)
let $result             :=
    for $projectTemplatesById in $projecttemplates[not(@url)]
    group by $id := $projectTemplatesById/(@id|@ref)
    return
        let $allTemplatesById           :=
            (: when retrieving templates from a compiled project, the @url/@ident they came from are on the template element
               reinstate that info on the repositoryTemplateList element so downstream logic works as if it really came from 
               the repository again.
            :)
            if ($projecttemplates[@url]) then (
                <repositoryTemplateLists>
                {
                    for $templates in $projecttemplates[@url][@id=$id]
                    group by $source := concat($templates/@url,$templates/@ident)
                    return
                        <repositoryTemplateList url="{$templates[1]/@url}" ident="{$templates[1]/@ident}" referencedFrom="{$prefix}">
                        {
                            $templates
                        }
                        </repositoryTemplateList>
                }
                </repositoryTemplateLists>
            )
            else (templ:getTemplateById($id,(),$prefix,$version))
        return
        <template>
        {
            $id
        }
        {
            for $template in $allTemplatesById/*/template
            let $newestTemplateEffectiveDate  := string(max($allTemplatesById/*/template/xs:dateTime(@effectiveDate)))
            let $currentTemplateEffectiveDate := $template/@effectiveDate
            let $lookingForNewest             := $currentTemplateEffectiveDate=$newestTemplateEffectiveDate
            order by $template/@effectiveDate descending
            return
                <template>
                {
                    if ($template/@id) then (
                        $template/@id,
                        $template/@name,
                        attribute displayName {if ($template/@displayName) then $template/@displayName else $template/@name},
                        $template/@statusCode,
                        $template/@versionLabel,
                        $template/@effectiveDate,
                        $template/@expirationDate,
                        $template/@officialReleaseDate,
                        $template/@isClosed,
                        if ($template/@url) then (
                            $template/@url,
                            $template/@ident
                        ) else (),
                        $template/classification
                    ) else if ($template/@ref) then (
                        $template/@ref,
                        $template/@name,
                        attribute displayName {if ($template/@displayName) then $template/@displayName else $template/@name},
                        $template/@effectiveDate
                    ) else (),
                    
                    for $rtemp in ( $decorRepresentingTemplates[@ref=$template/@id][@flexibility=$currentTemplateEffectiveDate] |
                                    $decorRepresentingTemplates[$lookingForNewest][@ref=$template/@id][not(@flexibility)] |
                                    $decorRepresentingTemplates[$lookingForNewest][@ref=$template/@id][@flexibility='dynamic'])
                    return
                         <representingTemplate>{$rtemp/@ref, $rtemp/@flexibility[not(.='dynamic')]}</representingTemplate>
                }
                </template>
        }
        </template>

let $schemaTypes        := art:getDecorTypes()//TemplateTypes/enumeration

return
    <return>
    {
        if ($classified=false()) then (
            for $r in $result
            order by count($r//representingTemplate)=0, $r/template[1]/@displayName, $r/template[1]/@name
            return $r
        )
        else (
            (: this is the code for a classification based hierarchical tree view :)
            (:get templates with and without classification:)
            for $clt in (distinct-values($result//classification/@type),if ($result[not(template/classification/@type)]) then '' else ())
            group by $type := if ($clt='') then 'notype' else $clt
            order by count($schemaTypes[@value=$type]/preceding-sibling::enumeration)
            return
            <class uuid="{util:uuid()}" type="{$type}">
            {
                for $label in $schemaTypes[@value=$type]/label
                return
                    <label language="{$label/@language}">{$label/text()}</label>
            }
            {
                let $templateSet  :=
                    if ($clt='') then
                        $result[not(template/classification/@type)]
                    else (
                        $result[template/classification[@type=$type]]
                    )
                for $section in $templateSet
                return
                    <template uuid="{util:uuid()}">
                    {
                        $section/(@* except @uuid),
                        for $template in $section/template
                        return
                            <template uuid="{util:uuid()}">
                            {
                                $template/(@* except @uuid),
                                $template/*
                            }
                            </template>
                    }
                    </template>
            }
            </class>
        )
    }
    </return>

};

declare function local:getTemplateById($id as xs:string, $prefix as xs:string, $externalrepositorylist as element()*, $bbrList as element()*) as element()* {
    for $repository in $externalrepositorylist
    let $hasBeenProcessedBefore := $bbrList[@url=$repository/@url][@ident=$repository/@ident]
    return
    if (not($hasBeenProcessedBefore)) then (
        <repositoryTemplateList url="{$repository/@url}" ident="{$repository/@ident}" referencedFrom="{$prefix}">
        {
            (: if this buildingBlockRepository resolves to our own server, then get it directly from the db. :)
            if ($repository/@url = $templ:strDecorServicesURL) then (
                let $results := $get:colDecorData/decor[project/@prefix=$repository/@ident]/rules/template[(@id|@ref)=$id]
                
                return
                    if ($results[@id]) then ($results[@id])
                    else (
                        local:getTemplateById($id, $repository/@ident, $get:colDecorData/decor/project[@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                    )
            )
            (: check cache first and do a server call as last resort. :)
            else (
                let $cachedProject   := $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]
                let $cachedTemplates := $cachedProject/rules/template[(@id|@ref)=$id]
                
                return
                    if ($cachedProject) then (
                        $cachedTemplates[@id],
                        if ($cachedTemplates[@ref]) then (
                            local:getTemplateById($id, $repository/@ident, $cachedProject/project/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        ) else ()
                    )
                    (: doc() call as last resort. :)
                    else (
                        doc(xs:anyURI(concat($repository/@url,'RetrieveTemplate?format=xml&amp;prefix=',$repository/@ident, '&amp;id=', $id)))/rules/template[@id]
                    )
            )
        }
        </repositoryTemplateList>
    ) else ()
};

declare function local:getTemplateByName($name as xs:string, $prefix as xs:string, $externalrepositorylist as element()*, $bbrList as element()*) as element()* {
    for $repository in $externalrepositorylist
    let $hasBeenProcessedBefore := $bbrList[@url=$repository/@url][@ident=$repository/@ident]
    return
    if (not($hasBeenProcessedBefore)) then (
        <repositoryTemplateList url="{$repository/@url}" ident="{$repository/@ident}" referencedFrom="{$prefix}">
        {
            (: if this buildingBlockRepository resolves to our own server, then get it directly from the db. :)
            if ($repository/@url = $templ:strDecorServicesURL) then (
                let $results := $get:colDecorData/decor[project/@prefix=$repository/@ident]/rules/template[@name=$name]
                
                return
                    if ($results[@id]) then ($results[@id])
                    else (
                        local:getTemplateByName($name, $repository/@ident, $get:colDecorData/decor/project[@prefix=$repository/@ident]/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                    )
            )
            (: check cache first and do a server call as last resort. :)
            else (
                let $cachedProject   := $get:colDecorCache//decor[@deeplinkprefixservices=$repository/@url][project/@prefix=$repository/@ident]
                let $cachedTemplates := $cachedProject/rules/template[@name=$name]
                
                return
                    if ($cachedProject) then (
                        $cachedTemplates[@id],
                        if ($cachedTemplates[@ref]) then (
                            local:getTemplateByName($name, $repository/@ident, $cachedProject/project/buildingBlockRepository, ($bbrList | $externalrepositorylist))
                        ) else ()
                    )
                    (: doc() call as last resort. :)
                    else (
                        doc(xs:anyURI(concat($repository/@url,'RetrieveTemplate?format=xml&amp;prefix=',$repository/@ident, '&amp;name=', $name)))/rules/template[@id]
                    )
            )
        }
        </repositoryTemplateList>
    ) else ()
};

(:~
:   Returns lucene config xml for a sequence of strings. The search will find yield results that match all terms+trailing wildcard in the sequence
:   Example output:
:   <query>
:       <bool>
:           <wildcard occur="must">term1*</wildcard>
:           <wildcard occur="must">term2*</wildcard>
:       </bool>
:   </query>
:
:   @param $searchTerms required sequence of terms to look for
:   @return lucene config
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function local:getSimpleLuceneQuery($searchTerms as xs:string+) as element() {
    <query>
        <bool>{
            for $term in $searchTerms
            return
                <wildcard occur="must">{concat($term,'*')}</wildcard>
        }</bool>
    </query>
};

(:~
:   Returns lucene options xml that instruct filter-rewrite=yes
:)
declare function local:getSimpleLuceneOptions() as element() {
    <options>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

(:~
:   Returns template element as-is except:
:   - attribute is normalized as name/value pair
:   - element/include/vocabulary that could have @flexibility but don't get flexibility='dynamic'
:   - empty attributes on element/include/choice/attribute/classification/relationship/vocabulary/example are stripped
:)
declare function local:normalizeNodes($tnode as element()) as element()* {
    let $elmname := name($tnode)
    return
        if ($elmname='element') then (
            element element {
                $tnode/@*[string-length()>0],
                if ($tnode[string-length(@contains)>0][string-length(@flexibility)=0]) then (
                    attribute flexibility {'dynamic'}
                ) else (),
                for $node in $tnode/*
                return
                    local:normalizeNodes($node)
            }
        ) else if ($elmname='include') then (
            element include {
                $tnode/@*[string-length()>0],
                if ($tnode[string-length(@ref)>0][string-length(@flexibility)=0]) then (
                    attribute flexibility {'dynamic'}
                ) else (),
                for $node in $tnode/*
                return
                    local:normalizeNodes($node)
            }
        ) else if ($elmname='choice') then (
            element choice {
                $tnode/@*[string-length()>0],
                for $node in $tnode/*
                return
                    local:normalizeNodes($node)
            }
        ) else if ($elmname='attribute') then (
            for $s in templ:normalizeAttributes($tnode)
            return
            element attribute {
                $s/@*[string-length()>0],
                for $node in $s/*
                return
                    local:normalizeNodes($node)
            }
        ) else if ($elmname='classification') then (
            element classification {
                $tnode/@*[string-length()>0],
                $tnode/node()
            }
        ) else if ($elmname='relationship') then (
            element relationship {
                $tnode/@*[string-length()>0],
                $tnode/node()
            }
        ) else if ($elmname='vocabulary') then (
            element vocabulary {
                $tnode/@*[string-length()>0],
                if ($tnode[string-length(@valueSet)>0][string-length(@flexibility)=0]) then (
                    attribute flexibility {'dynamic'}
                ) else (),
                $tnode/node()
            }
        ) else if ($elmname='example') then (
            element example {
                $tnode/@*[string-length()>0],
                $tnode/node()
            }
        ) else (
            (:desc,item,text,constraint,example,let,defineVariable,assert,report,...:)
            $tnode
        )
};
(:=======================:)

declare function templ:getRepositoryAndBBRTemplateList ($searchTerms as xs:string*, $prefix as xs:string?) as element()* {

    (: all rules on this server (repositories only) and in this server's cache :)
    let $repository := 
        if (string-length($prefix)>0) 
        then $get:colDecorData//decor[project/@prefix=$prefix]/rules | $get:colDecorCache//decor[project/@prefix=$prefix]/rules
        else $get:colDecorData//decor[@repository='true']/rules | $get:colDecorCache//decor/rules

    (: get project templates with an @id, either by searching a specific one with searchTerms or all :)
    let $result :=
        if (empty($searchTerms)) then (
            let $tempres := 
                for $template in $repository/template[@id]
                (: group $template as $versions by $template/@id as $id :)
                group by $id := $template/@id, $name := $template/@name
                order by $name
                return
                    <template id="{$id}">
                    {
                        for $version in $template
                        let $newestTemplateEffectiveDate    := string(max($repository/template[(@id|@ref)=$version/@id]/xs:dateTime(@effectiveDate)))
                        let $currentTemplateEffectiveDate   := $version/@effectiveDate
                        let $lookingForNewest               := $currentTemplateEffectiveDate=$newestTemplateEffectiveDate
                        let $displayName                    := if (string-length($version/@displayName)>0) then $version/@displayName else $version/@name
                        order by $version/@effectiveDate descending
                        return
                            <template name="{$version/@name}" displayName="{$displayName}" isClosed="{$version/@isClosed='true'}" 
                                      expirationDate="{$version/@expirationDate}" officialReleaseDate="{$version/@officialReleaseDate}">
                            {
                                attribute id {$version/@id},
                                attribute statusCode {$version/@statusCode},
                                attribute versionLabel {$version/@versionLabel},
                                attribute effectiveDate {$version/@effectiveDate},
                                attribute sortname {$displayName},
                                attribute fromRepository {$version/ancestor::decor/project/@prefix},
                                $version/desc,
                                $version/classification
                            }
                            </template>
                    }
                    </template>
             
             let $count := count($tempres//template)
             return
                <result current="{$count}" total="{$count}">
                {
                    $tempres
                }
                </result>
         )
         else (
            let $tempres := 
                for $template in adsearch:searchTemplatesInRuleSet($searchTerms, $repository, $adsearch:maxResults)/*
                group by $id := $template/@id
                order by $template/@name
                return
                    <template id="{$id}">
                    {
                        for $version in $template
                        let $newestTemplateEffectiveDate  := string(max($repository/template[(@id|@ref)=$version/@id]/xs:dateTime(@effectiveDate)))
                        let $currentTemplateEffectiveDate := $version/@effectiveDate
                        let $lookingForNewest             := $currentTemplateEffectiveDate=$newestTemplateEffectiveDate
                        let $displayName                    := if (string-length($version/@displayName)>0) then $version/@displayName else $version/@name
                        order by $version/@effectiveDate descending
                        return
                            <template name="{$version/@name}" displayName="{$displayName}" isClosed="{$version/@isClosed='true'}" 
                                      expirationDate="{$version/@expirationDate}" officialReleaseDate="{$version/@officialReleaseDate}">
                            {
                                attribute id {$version/@id},
                                attribute statusCode {$version/@statusCode},
                                attribute versionLabel {$version/@versionLabel},
                                attribute effectiveDate {$version/@effectiveDate},
                                attribute sortname {$displayName},
                                $version/desc,
                                $version/classification
                            }
                            </template>
                    }
                    </template>
            
             let $count := count($tempres//template)
             return
                <result current="{$count}" total="{$count}">
                {
                    $tempres
                }
                </result>
         )

    return
        <rules>
        {
             for $r in $result
             order by $r/template[1]/@sortname
             return $r
        }
        </rules>

};

declare function local:cardconfs1element ($e as element()*, $minimumMultiplicity as xs:string?, $maximumMultiplicity as xs:string?, $isMandatory as xs:string?, $conformance as xs:string? ) as element()* {
    (: override the first element in $e template/* with the card / conf spec submitted ; should be as easy as using update but didn't find it here :)
    
    for $child in $e/(element|attribute|assert|report|let|include|choice)
    let $minimumMultiplicity := if (string-length($minimumMultiplicity)=0) then ($child/@minimumMultiplicity) else ($minimumMultiplicity)
    let $maximumMultiplicity := if (string-length($maximumMultiplicity)=0) then ($child/@maximumMultiplicity) else ($maximumMultiplicity)
    let $isMandatory := if (string-length($isMandatory)=0) then ($child/@isMandatory) else ($isMandatory)
    let $conformance := if (string-length($conformance)=0) then ($child/@conformance) else ($conformance)
    return
        if ((count($e[preceding-sibling::element])=0) and ($child/name() = 'element'))
        then (
            element {$child/name()} {
                $child/(@* except (@minimumMultiplicity|@maximumMultiplicity|@isMandatory|@conformance)),
                if (string-length($minimumMultiplicity)>0) then attribute minimumMultiplicity {$minimumMultiplicity} else (),
                if (string-length($maximumMultiplicity)>0) then attribute maximumMultiplicity {$maximumMultiplicity} else (),
                if (string-length($isMandatory)>0) then attribute isMandatory {$isMandatory} else (),
                if (string-length($conformance)>0) then attribute conformance {$conformance} else (),
                $child/node()
            }
        ) else (
            element {$child/name()} {
                $child/@*,
                $child/node()
            }
        )
};

declare function local:artefactMissing($what as xs:string, $ref as xs:string?, $flexibility as xs:string?, $decorRules as element()*, $decorTerms as element()*) as element()? {
    (: returns <artefact missing="true"... if artefact cannot be found in decor project :)
    if ($what='template') then (
        let $searchTemplates     := $decorRules/template[@id=$ref] | $decorRules/template[@ref=$ref] | $decorRules/template[@name=$ref]
        let $searchEffectiveDate := 
            if (matches($flexibility,'^\d{4}')) then (
                (:starts with 4 digits, explicit dateTime:)
                $flexibility 
            ) else (
                (:empty or dynamic:)
                string(max($searchTemplates/xs:dateTime(@effectiveDate)))
            )
        let $tmp                 := $searchTemplates[@ref] | $searchTemplates[@effectiveDate=$searchEffectiveDate]
        return
            <artefact missing="{empty($tmp)}" id="{$tmp[1]/(@id|@ref)}" name="{$tmp[1]/@name}" displayName="{$tmp[1]/@displayName}"/>
            
    ) else if ($what='valueSet') then (
        (: find out effectiveDate for this value set :)
        let $searchValuesets     := $decorTerms/valueSet[@id=$ref] | $decorTerms/valueSet[@ref=$ref] | $decorTerms/valueSet[@name=$ref]
        let $newestInSearch      := string(max($searchValuesets[@effectiveDate]/xs:dateTime(@effectiveDate)))
        let $searchEffectiveDate := 
            if (matches($flexibility,'^\d{4}')) then (
                (:starts with 4 digits, explicit dateTime:)
                $flexibility 
            ) else if ($searchValuesets[@effectiveDate]) then (
                (: a value set with @effectiveDate :)
                $newestInSearch
            ) else ('')
        let $tmp                 := $searchValuesets[@ref] | $searchValuesets[@effectiveDate=$searchEffectiveDate]
        return
            <artefact missing="{empty($tmp)}" id="{$tmp[1]/(@id|@ref)}" name="{$tmp[1]/@name}" displayName="{$tmp[1]/@displayName}"/>
    ) else (
        <artefact missing="false" id="" name="" displayName=""/>
    )
};

declare function local:copyNodes($tnode as element(), $item as element(), $nesting as xs:integer, $decorRules as element()*, $decorTerms as element()*) as element()* {
    let $elmname := name($tnode)
    let $theitem := if ($tnode/item) then $tnode/item else ($item)
    return
        if ($nesting > 30) then (
            (: too deeply nested, raise error and give up :)
            element templateerror {
                attribute {'type'} {'nesting'}(:,
                $tnode:)
            }
        ) else if ($elmname='include') then (
            let $searchTemplate := $decorRules/template[@id=$tnode/@ref] | $decorRules/template[@name=$tnode/@ref]
            let $recent         := $searchTemplate[@effectiveDate=max($searchTemplate/xs:dateTime(@effectiveDate))]
            let $artefact       := local:artefactMissing('template', $tnode/@ref, $tnode/@flexibility, $decorRules, $decorTerms)
            return
            element include {
                $tnode/(@* except (@tmid|@tmname|@tmdisplayName|@linkedartefactmissing)),
                attribute {'tmid'} {$artefact/@id},
                attribute {'tmname'} {$artefact/@name},
                attribute {'tmdisplayName'} {$artefact/@displayName},
                attribute {'linkedartefactmissing'} {$artefact/@missing},
                $tnode/text(),
                for $s in $tnode/desc 
                return art:serializeNode($s)
                ,
                $theitem,
                for $s in $tnode/(* except (desc|item))
                return
                local:copyNodes($s, $theitem, $nesting+1, $decorRules, $decorTerms)
                ,
                let $recentcardconf := local:cardconfs1element ($recent, $tnode/@minimumMultiplicity, $tnode/@maximumMultiplicity, $tnode/@isMandatory, $tnode/@conformance)
                let $theitem        := if ($recent/item) then $recent/item else <item label="{$recent/@name}"/>
                for $t in $recentcardconf
                return
                local:copyNodes($t, $theitem, $nesting+1, $decorRules, $decorTerms),
                <staticAssociations>
                {
                    for $association in $decorRules/templateAssociation[@templateId=$recent/@id][@effectiveDate=$recent/@effectiveDate]/concept
                    let $datasetId := $get:colDecorData//concept[@id=$association/@ref][@effectiveDate=$association/@effectiveDate][not(ancestor::history)]/ancestor::dataset/@id
                    return
                        <origconcept datasetId="{$datasetId}" ref="{$association/@ref}" effectiveDate="{$association/@effectiveDate}" elementId="{$association/@elementId}">
                        {
                            art:getOriginalConceptName($association)
                        }
                        </origconcept>
                }
                </staticAssociations>
            }
        ) else if ($elmname='desc') then (
            art:serializeNode($tnode)
        ) else if ($elmname='constraint') then (
            art:serializeNode($tnode)
        ) else if ($elmname='relationship') then (
            let $ref := $tnode/@template[string-length()>0]
            let $rtf := if (empty($ref)) then () else (templ:getTemplateByRef($ref,$tnode/@flexibility,$decorRules/ancestor::decor/project/@prefix))
            return
            element relationship {
                $tnode/@*,
                if ($rtf//template) then (
                    attribute templateName { if (string-length($rtf//template[1]/template[1]/@displayName)>0) then $rtf//template[1]//template[1]/@displayName else $rtf//template[1]/template[1]/@name },
                    attribute templateFrom { $rtf//template[1]/template[1]/@ident }
                ) else (),
                $tnode/*
            }
        ) else if ($elmname='vocabulary') then (
            let $artefact := local:artefactMissing('valueSet', $tnode/@valueSet, $tnode/@flexibility, $decorRules, $decorTerms)
            return
            element vocabulary {
                $tnode/(@* except (@vsid,@vsname,@vsdisplayName,@linkedartefactmissing)),
                if ($tnode/@valueSet) then (
                    attribute {'vsid'} {$artefact/@id},
                    attribute {'vsname'} {$artefact/@name},
                    attribute {'vsdisplayName'} {$artefact/@displayName},
                    attribute linkedartefactmissing {$artefact/@missing} 
                ) else (),
                $tnode/*
            }
        ) else if ($elmname='example') then (
            $tnode
        ) else if ($elmname='attribute') then (
            for $s in templ:normalizeAttributes($tnode)
            return
            element attribute {
                $s/@*,
                for $t in $s/* 
                return local:copyNodes($t, $theitem, $nesting+1, $decorRules, $decorTerms)
            }
        ) else (
            let $artefact := local:artefactMissing('template', $tnode/@contains, $tnode/@flexibility, $decorRules, $decorTerms)
            return
            element {$elmname} {
                $tnode/(@* except (@tmid|@tmname|@tmdisplayName|@linkedartefactmissing)),
                if ($tnode/@contains) then (
                    attribute {'tmid'} {$artefact/@id},
                    attribute {'tmname'} {$artefact/@name},
                    attribute {'tmdisplayName'} {$artefact/@displayName},
                    attribute {'linkedartefactmissing'} {$artefact/@missing}
                ) else (),
                $tnode/text(),
                for $s in $tnode/desc 
                return art:serializeNode($s)
                ,
                $theitem,
                for $s in $tnode/(* except (desc|item))
                return
                local:copyNodes($s, $theitem, $nesting+1, $decorRules, $decorTerms)
            }
        )
};

declare function local:getDependendies($version as element(), $self as xs:string?, $level as xs:int, $decorRules as element()*) as element()* {
    
    let $lvtextinclude := if ($level=1) then 'include' else 'dependency'
    let $lvtextcontains := if ($level=1) then 'contains' else 'dependency'

    let $dep :=
        if ($level > 7) then
            (: too deeply nested, raise error and give up :)
            ()
        else if (($version/@id = $self) and ($level > 1)) then
            (: ref to myself in a level greater than 1, give up, you are done :)
            ()
        else
            (
                if ($decorRules//include/@ref) then
                    (:for $chain in $decorRules/template[.//include[@ref=$version/@id or @ref=$version/@name]]:)
                    for $chain in $decorRules//include[@ref=$version/@id]/ancestor::template|$decorRules//include[@ref=$version/@name]/ancestor::template
                    return (
                    <ref type="{$lvtextinclude}" id="{$chain/@id}" name="{$chain/@name}" displayName="{$chain/@displayName}" effectiveDate="{$chain/@effectiveDate}"/>,
                    local:getDependendies($chain, $self, $level+1, $decorRules)
                    )
                    else (),
                if ($decorRules//element/@contains) then
                    (: this is dirty because exist does not work with the expression below correctly if there are no elements with @contains :)
                    for $chain in $decorRules//element[@contains=$version/@id]/ancestor::template|$decorRules//element[@contains=$version/@name]/ancestor::template
                    return (
                    <ref type="{$lvtextcontains}" id="{$chain/@id}" name="{$chain/@name}" displayName="{$chain/@displayName}" effectiveDate="{$chain/@effectiveDate}"/>,
                    local:getDependendies($chain, $self, $level+1, $decorRules)
                    )
                else ()
            )
     
     for $d in distinct-values($dep/@id)
     return $dep[@id = $d][1]
     
};

declare function local:templateUses($version as element(), $self as xs:string?, $level as xs:int, $decorRules as element()*) as element(uses)* {

    let $uses := 
        if ($level > 7) then
            (: too deeply nested, raise error and give up :)
            ()
        else if (($version/@id = $self) and ($level > 1)) then
            (: ref to myself in a level greater than 1, give up, you are done :)
            ()
        else
            (
                for $lc in ($version//element[@contains] | $version//include[@ref])
                let $xid            := if ($lc/name() = 'element') then $lc/@contains else $lc/@ref
                let $xtype          := if ($lc/name() = 'element') then 'contains' else 'include'
                let $flex           := $lc/@flexibility
                let $searchTemplate := $decorRules/template[@id=$xid] | $decorRules/template[@name=$xid]
                let $effd           := 
                    if (matches($flex,'^\d{4}')) 
                    then $flex
                    else max($searchTemplate/xs:dateTime(@effectiveDate))
                let $templ          := $searchTemplate[@effectiveDate=$effd]
                return
                for $x in $templ
                return (
                    <uses type="{$xtype}" id="{$x/@id}" name="{$x/@name}" displayName="{$x/@displayName}" effectiveDate="{$x/@effectiveDate}"/>
                    (:, only one level
                    local:templateUses($x, $self, $level+1, $decorRules)
                    :)
                )
            )
    return
        for $d in distinct-values($uses/@id)
        return $uses[@id = $d][1]

};

