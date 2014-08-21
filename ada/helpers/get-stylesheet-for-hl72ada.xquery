(:
    Copyright (C) 2013-2014  Marc de Graauw
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
xquery version "1.0";
(:
    A first shot at an XQuery which generates a stylesheet which extracts data from HL7 and makes an adaxml document out of it.
    Currently to be used to make a first-shot stylesheet which needs manual improvement.
:)

declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace hl7="urn:hl7-org:v3";
(: TODO: namespaces from decor file are to be used from input :)
declare namespace peri="urn:nictiz-nl:v3/peri";
declare namespace lab="urn:oid:2.16.840.1.113883.2.4.6.10.35.81";

import module namespace ada ="http://art-decor.org/ns/ada-common" at "../../ada/modules/ada-common.xqm";
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
declare copy-namespaces no-preserve, inherit;
declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

declare variable $debug          := true();
declare variable $quote          := "&#39;";
declare variable $accolade-open  := "&#123;";
declare variable $accolade-close := "&#125;";
declare variable $ampersand      := "&#38;";
declare variable $newline        := "&#10;";

declare variable $warning        := concat("Generated code at ", datetime:format-dateTime(current-dateTime(), "yyyy-MM-dd HH:mm:ss z"), " *** do not make any changes here, do regenerate (xquery)");
declare variable $xqueryname     := "HL72ADA";

declare function local:reportError($error as xs:string, $severity as xs:integer) as element() {
    for $i in 1 to 1
    return <xsl:comment><error severity="{$severity}">{$error}</error></xsl:comment>
};

declare function local:getConceptTemplate($concept) as element()* {
    <xsl:template name="{$concept/implementation/@shortName}">
        {
        (: Build the adaxml element, with <shortName conceptId='...' :)
        <xsl:element name="{$concept/implementation/@shortName}"> 
            <xsl:attribute name="conceptId">{data($concept/@id)}</xsl:attribute>
            {
                if ($concept/@type = 'item') 
                then 
                    (: For concept items, add value attribute if a valueLocation is provided. For quantities, add unit if in input HL7 doc :) 
                    (
                    if ($concept/implementation/@valueLocation) then <xsl:attribute name="value"><xsl:value-of select="{$concept/implementation/@valueLocation}"/></xsl:attribute>  else comment {'no valueLocation'},
                    if ($concept/valueDomain/@type="quantity") then <xsl:if test="@unit"><xsl:attribute name="unit"><xsl:value-of select="@unit"/></xsl:attribute></xsl:if> else ()
                    )
                else 
                    (: For concept groups, generate calls to named templates :)
                    for $child in $concept/concept
                    return local:getConceptCalls($child, if($concept/implementation/@xpath) then $concept/implementation/@xpath else '')
            }
        </xsl:element>
        }
    </xsl:template>,
    for $child in $concept/concept
    return local:getConceptTemplate($child)
};

declare function local:getConceptCalls($concept as element(), $parentXpath as xs:string) as node()* {
    let $relativeXpath := 
        if (starts-with($concept/implementation/@xpath, concat($parentXpath, '/')))
        then substring-after($concept/implementation/@xpath, concat($parentXpath, '/'))
        else ()
    return
        if ($relativeXpath) then
            <xsl:for-each select="{$relativeXpath}">
                <xsl:call-template name="{$concept/implementation/@shortName}"/>
            </xsl:for-each>
        else
        (: If no relative Xpath is found, assume that xpath is unique from root, use this :)
            if ($concept/implementation/@xpath)
            then
                (comment {concat('No relative xpath for concept ' , $concept/implementation/@shortName, ' used absolute Xpath')},
                <xsl:for-each select="{$concept/implementation/@xpath}">
                    <xsl:call-template name="{$concept/implementation/@shortName}"/>
                </xsl:for-each>
                )            
            else comment {concat('No xpath for concept ' , $concept/implementation/@shortName)}
};

(: parameters :)
let $projectPrefix := if (request:exists()) then request:get-parameter('id','') else 'rivmsp-'
let $versionDate   := if (request:exists()) then request:get-parameter('id','') else '2013-08-12T11:48:06'
let $transactionId := if (request:exists()) then request:get-parameter('id','') else '2.16.840.1.113883.2.4.3.36.77.4.101' 

let $collection    := $get:colDecorVersion
let $transactionDataset := $collection//transactionDatasets[@versionDate=$versionDate]/dataset[@transactionId=$transactionId]

let $stylesheet :=
    <xsl:stylesheet 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:hl7="urn:hl7-org:v3" 
        xmlns:xs="http://www.w3.org/2001/XMLSchema" 
        xmlns:lab="urn:oid:2.16.840.1.113883.2.4.6.10.35.81"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    {
        comment {$warning},
        comment {'Stylesheet which transforms a HL7 message to adaxml.'}
    }
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <adaxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <data>{
                element {$transactionDataset/@shortName/string()}
                    {
                    attribute transactionRef {$transactionDataset/@transactionId},
                    $transactionDataset/@transactionEffectiveDate,
                    $transactionDataset/../@prefix,
                    $transactionDataset/../@versionDate,
                    $transactionDataset/../@language,
                    attribute id {util:uuid()},
                    for $child in $transactionDataset/concept
                    return local:getConceptCalls($child, '')
                    }
            }</data>
        </adaxml>
    </xsl:template>
    {$newline, $newline}
    {
        for $concept in $transactionDataset/concept
        return (local:getConceptTemplate($concept), $newline, $newline)
    }
    
    <xsl:template match="text()|@*"/>

</xsl:stylesheet>

let $runtimedir := ada:getUri($projectPrefix, 'xslt')
let $generated  := xmldb:store($runtimedir, 'hl72ada.xsl', $stylesheet) 

return 
    $stylesheet