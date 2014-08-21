xquery version "1.0";
(:
	Copyright (C) 2011-2014 Art-Decor Expert Group
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xforms="http://www.w3.org/2002/xforms";

declare function local:serializeNode($textWithMarkup as element()) as element() {
    let $nodeName := name($textWithMarkup)
    return
    element {$nodeName} {
        $textWithMarkup/@language,
        util:serialize($textWithMarkup/node(),'method=xhtml encoding=UTF-8')
        
    }
};

<issues>
{
    let $refsetId := request:get-parameter('refsetId','')
(:    let $refsetId := '41000146103':)
    let $language := 'nl-NL'
    let $refset := collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset[@id=$refsetId]
    let $enumerations := $get:docDecorSchema/xs:schema/xs:simpleType[*/xs:enumeration]
    let $issues := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//issues[@ref=$refsetId]/issue
            
    for $issue in $issues
    let $lastTracking := max($issue//tracking/xs:dateTime(@effectiveDate))
    let $lastAssignment := max($issue//assignment/xs:dateTime(@effectiveDate))
    let $type := $issue/@type
    let $priority := if (string-length($issue/@priority)>0) then ($issue/@priority/string()) else ('N')
    return
        <issue id="{$issue/@id}" priority="{$priority}" displayName="{$issue/@displayName}" 
            typeName="{$enumerations[@name='IssueType']//xs:enumeration[@value=$type]/xs:annotation/xs:appinfo/xforms:label[@xml:lang=$language]}"
            type="{$issue/@type}" lastDate="{$lastTracking}" currentStatusCode="{$issue/tracking[@effectiveDate=$lastTracking][1]/@statusCode}"
            lastAuthor="{$issue/tracking[@effectiveDate=$lastTracking]/author/text()}"
            lastAssignment="{$issue/assignment[@effectiveDate=$lastAssignment]/@name}">
            {
            for $object in $issue/object
            let $type := $object/@type
            order by $type
            return
            <object id="{$object/@id}"   type="{$type}">

            </object>    
                
                ,
            for $event in $issue/tracking|$issue/assignment
            order by xs:dateTime($event/@effectiveDate) descending
            return
            if (name($event)='tracking') then
            <tracking effectiveDate="{$event/@effectiveDate}" statusCode="{$event/@statusCode}">
            {$event/author}
            {
            for $desc in $event/desc
            return
            local:serializeNode($desc)
            }
            </tracking>
            else if (name($event)='assignment') then
            <assignment to="{$event/@to}" name="{$event/@name}" effectiveDate="{$event/@effectiveDate}">
            {$event/author}
            {
            for $desc in $event/desc
            return
            local:serializeNode($desc)
            }
            </assignment>
            else()
            }
        </issue>
}
</issues>