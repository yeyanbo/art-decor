xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Kai U. Heitmann (schema, schematron), Marc de Graauw (DUL)

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)


import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace artx     = "http://art-decor.org/ns/art/xpath" at "art-decor-xpath.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "art-decor.xqm";

declare namespace hl7        = "urn:hl7-org:v3";
declare namespace validation = "http://exist-db.org/xquery/validation";
declare namespace transform  = "http://exist-db.org/xquery/transform";
declare namespace svrl       = "http://purl.oclc.org/dsdl/svrl";

declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

declare function local:retrieve-transactions($decor as node(), $dataset as xs:string) as node() {
    let $allXpaths :=
        <xpaths>{
            for $representingTemplate in $decor//representingTemplate[@sourceDataset=$dataset]
            return artx:getXpaths($decor, $representingTemplate)
        }</xpaths>
    let $store          := xmldb:store($get:strDecorDevelop, concat($decor/project/@prefix, 'develop-', $decor/project/@defaultLanguage, '-xpaths.xml'), $allXpaths)
    let $transactions           := 
        <transactionDatasets projectId='{$decor/project/@id}' prefix='{$decor/project/@prefix}' versionDate='{fn:current-dateTime()}' language='{$decor/project/@defaultLanguage}'>
        {
            for $transaction in $decor//transaction[representingTemplate[@sourceDataset=$dataset]]
            return art:getFullDatasetTree($transaction/@id, $decor/project/@defaultlanguage, $allXpaths)
        }
        </transactionDatasets> 
    let $store          := xmldb:store($get:strDecorDevelop, concat($decor/project/@prefix, 'develop-', $decor/project/@defaultLanguage, '-transactions.xml'), $transactions)
    return $transactions
};

declare function local:conceptNames($id as xs:string, $decor as node()) as element() {
    let $concept := $decor//dataset//concept[@id=$id][not(parent::history)]
    let $concept := if ($concept/inherit) then art:getOriginalConceptName($concept/inherit) else $concept
    let $name := $concept/name[@language=$decor/project/@defaultLanguage]
    return if ($name) then $name else $concept/name[1]
};

declare function local:validate-iso-schematron-svrl($content as item(), $grammar as item()) as element(report) {
    let $grammartransform           := art:get-iso-schematron-svrl($grammar)
    let $resulttransform            := transform:transform($content, $grammartransform, ())
    
    return (
        <report>
            <status>
            {
                if ($resulttransform/svrl:failed-assert | $resulttransform/svrl:successful-report)
                then 'invalid'
                else 'valid'
            }
            </status>
            <message>
            {
                $resulttransform
            }
            </message>
        </report>
  )
};

let $collection             := $get:colDecorData
let $dataset                := if (request:exists()) then request:get-parameter('dataset','') else ('2.16.840.1.113883.2.4.3.36.77.1.3')
let $projectPrefix          := if (request:exists()) then request:get-parameter('prefix','') else ('rivmsp-')
let $decorUsabilityLevel    := if (request:exists()) then request:get-parameter('dul','7') else ('7')
(:let $projectPrefix := 'peri20-':)
let $decor                  := $collection//project[@prefix=$projectPrefix]/ancestor::decor

let $decorschema            := $get:docDecorSchema
let $decorschematronSCHextraction :=
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    exclude-result-prefixes="xs xsl"
    version="2.0">
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
            <ns uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
            <xsl:copy-of select="//sch:pattern"/>
            <xsl:for-each select="xs:include">
                <xsl:copy-of select="document(@schemaLocation)//sch:pattern"/>
            </xsl:for-each>
        </schema>
    </xsl:template>
</xsl:stylesheet>

(:
let $decorlines := tokenize(util:serialize($decor, "method=xhtml media-type=text/html omit-xml-declaration=no indent=yes"), '\n')
let $decorlines := tokenize(util:serialize($decor, "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes"), '\n')
:)
let $transactions   := local:retrieve-transactions($decor, $dataset)

return
if ($projectPrefix= '') then (
    if (response:exists()) then (response:set-status-code(404), response:set-header('Content-Type','text/xml; charset=utf-8')) else (), 
    <error>Missing parameter 'prefix'</error>
)
else (
    if (response:exists()) then (response:set-header('Content-Type','text/xml; charset=utf-8')) else (),
    <report>
        <schema>
        {
            (: validate against DECOR schema :)
            validation:jaxv-report($decor, $decorschema)
        }
        </schema>
        <schematron>
        {
            (: extract embedded SCH rules out of the DECOR schema :)
            let $schematron := transform:transform($decorschema, $decorschematronSCHextraction, ())
            return
                local:validate-iso-schematron-svrl ($decor, $schematron)
        }
        </schematron>
        <errors>
            <error text="The following templateAssociation concepts have no elementId attribute">
            {
                for $concept in $decor//templateAssociation/concept[not(@elementId)]
                return <concept ref='{$concept/@ref}' template='{$decor//template[@id=$concept/parent::*/@templateId]/@name}' templateId='{$concept/parent::*/@templateId}'
                    project='{$concept/ancestor::decor/project[1]/@prefix}'>
                    {local:conceptNames($concept/@ref, $decor)}
                    </concept>
            }
            </error>
            <error text="The following element id occurs more than once, in templates with different name">
            {
                for $id in $decor//template//element/@id
                where count(distinct-values($decor//template//element[@id=$id]/ancestor::template/@name)) > 1
                return <element id='{$id}' template='{$id/ancestor::template/@name}'/>
            }
            </error>
            <error text="The following elementId attributes which correspond to concept items are not linked to an element in the template">
            {
                for $templateAssociation in $decor//templateAssociation
                for $template in $decor//template
                where ($templateAssociation/@templateId=$template/@id 
                       and $templateAssociation[@effectiveDate=$template/@effectiveDate])
                return 
                    for $id in $templateAssociation/concept[@ref=$decor//dataset//concept[@type='item']/@id]/@elementId
                    where count($template//element[@id=$id])=0
                    return <template name='{$template/@name}' missingElementId='{$id}'>
                    <concept>{local:conceptNames($id/parent::*/@ref, $decor)}</concept>
                    </template>
            }
            </error>
            <error text="The following templateAssociations have no corresponding template">
            {
                for $templateAssociation in $decor//templateAssociation
                where count($decor//template[@id=$templateAssociation/@templateId][@effectiveDate=$templateAssociation/@effectiveDate])=0
                return $templateAssociation 
            }
            </error>
            <error text="The following concept items correspond to an element in a template, but the element has no datatype or negationInd">
            {
                for $templateAssociation in $decor//templateAssociation
                for $template in $decor//template
                where ($templateAssociation/@templateId=$template/@id 
                       and $templateAssociation[@effectiveDate=$template/@effectiveDate])
                return 
                    for $id in $templateAssociation/concept[@ref=$decor//dataset//concept[@type='item'][not(ancestor::history)]/@id]/@elementId
                    where $template//element[@id=$id] 
                          and count($template//element[@id=$id][@datatype])=0
                          and count($template//element[@id=$id][attribute[@name='negationInd']])=0
                   return <template name='{$template/@name}' elementId='{$id}'>
                        <concept>{local:conceptNames($id/parent::*/@ref, $decor)}</concept>{$template//element[@id=$id]}
                    </template>
            }
            </error>
            <error text="The following conceptLists in dataset have no associated valueset and do occur in a scenario">
            {
            for $conceptList in $decor//dataset//conceptList[not(@ref)][not(ancestor::history)]
            where count($decor//terminologyAssociation[@valueSet][@conceptId=$conceptList/@id])=0
            and $decor//representingTemplate//concept[@ref=$conceptList/parent::*/@id]
            return $conceptList/parent::*
            }
            </error>
            <error text="The following concepts from a conceptList in dataset have no terminologyAssociation">
            {
            for $concept in $decor//dataset//conceptList[not(ancestor::history)]/concept
            where count($decor//terminologyAssociation[@conceptId=$concept/@id])=0
            and $decor//representingTemplate//concept[@ref=$concept/../../@id]
            return $concept
            }
            </error>
            <error text="The following concepts from dataset are used in at least one transaction but have no association to a template">
            {
                for $concept in $decor//dataset//concept[not(ancestor::history)]
                where $decor//representingTemplate[@ref]/concept[@ref=$concept/@id] and
                      count($decor//templateAssociation/concept[@ref=$concept/@id][@effectiveDate=$concept/@effectiveDate])=0
                return <concept ref='{$concept/@id}' type='{$concept/@type}' project='{$concept/ancestor::decor/project[1]/@prefix}'>
                    {local:conceptNames($concept/@id, $decor)}
                    </concept>
            }
            </error>
            {for $transaction in $transactions//dataset[@transactionId]
            return 
                (
                <error text="The following concepts from transaction {$transaction/name} have no XPath">{
                    for $concept in $transaction//concept[implementation][not(implementation/@xpath)]
                    return <concept ref="{$concept/@id}">{$concept/name}</concept>
                }</error>,
                <error text="The following code concepts from transaction {$transaction/name} have conformance R and minimumMultiplicity 1, but no exceptions">{
                    for $concept in $transaction//concept[@minimumMultiplicity='1'][valueDomain/@type='code'][@conformance='R'][not(valueSet//exception)]
                    return <concept ref="{$concept/@id}">{$concept/name}</concept>
                }</error>,
                <error text="The following code concepts from transaction {$transaction/name} have no associated valueSet concepts">{
                    for $concept in $transaction//concept[valueDomain/@type='code'][not(valueSet//concept)]
                    return <concept ref="{$concept/@id}">{$concept/name}</concept>
                }</error>
                )
            }
       </errors>
        {if ($decorUsabilityLevel > '6') then (
        <warnings>
            <warning text="The following concept groups from template associations have no corresponding element/@id in the template">
            {
                for $templateAssociation in $decor//templateAssociation
                for $template in $decor//template
                where ($templateAssociation[@templateId=$template/@id] 
                       and $templateAssociation[@effectiveDate=$template/@effectiveDate])
                return 
                    for $id in $templateAssociation/concept[@ref=$decor//dataset//concept[@type='group']/@id]/@elementId
                    where count($template//element[@id=$id])=0
                    return <template name='{$template/@name}' missingElementId='{$id}'>
                    <concept>{local:conceptNames($id/parent::*/@ref, $decor)}</concept>
                    </template>
            }
            </warning>
            <warning text="The following parent concepts have children in a representingTemplate, but are missing themselves">
            {
                for $representingTemplate in $decor//representingTemplate
                return 
                    for $concept in $decor//dataset[@id=$representingTemplate/@sourceDataset]//concept[@type='group'][descendant::concept[@id=$representingTemplate/concept/@ref]]
                    return 
                        if ($concept[@id=$representingTemplate/concept/@ref]) then ()
                        else <concept id='{$concept/@id}' representingTemplate='{$representingTemplate/@ref}'>{$concept/name}</concept>
            }
            </warning>
            </warnings>
        ) else ()}
    </report>
)