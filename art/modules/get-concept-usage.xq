xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

let $id :=request:get-parameter('id',())
(:let $id :='2.999.999.999.77.2.10030':)
let $concepts :=
    for $concept in $get:colDecorData//concept[inherit/@ref=$id][not(ancestor::history)]
    return
        <dataset id="{$concept/ancestor::dataset/@id}" effectiveDate="{$concept/ancestor::dataset/@effectiveDate}" 
                 prefix="{$concept/ancestor::decor/project/@prefix}" projectName="{$concept/ancestor::decor/project/name[1]}" 
                 conceptId="{$concept/@id}" conceptEffectiveDate="{$concept/@effectiveDate}">
            {$concept/ancestor::dataset/name}
        </dataset>

let $transactions := 
    for $concept in $get:colDecorData//transaction//concept[@ref=(attribute id {$id}|$concepts//@conceptId)]
    let $datasetId := $concept/ancestor::representingTemplate/@sourceDataset
    return
        <transaction id="{$concept/../../@id}" effectiveDate="{$concept/../../@effectiveDate}" statusCode="{$concept/../../@statusCode}" conformance="{$concept/@conformance}" isMandatory="{$concept/@isMandatory}">
        {
            attribute {'prefix'} {$concept/ancestor::decor/project/@prefix}
            ,
            attribute {'datasetId'} {$datasetId}
            ,
            attribute {'minimumMultiplicity'} {
                if ($concept/@conformance='NP') then
                    '0'
                else if (not($concept/@conformance='C') and not($concept/@minimumMultiplicity)) then
                    '0'
                else if (not($concept/@conformance='C')) then
                    $concept/@minimumMultiplicity/string()
                else if ($concept/@conformance='C' and $concept[not(@conformance='NP')][not(@minimumMultiplicity)]) then
                    '0'
                else if ($concept/condition[not(@conformance='NP')][@minimumMultiplicity]) then
                    min($concept/condition[not(@conformance='NP')][@minimumMultiplicity]/number(@minimumMultiplicity))
                else
                    '0'
            }
            ,
            attribute {'maximumMultiplicity'} {
                if ($concept/@conformance='NP') then
                    '0'
                else if (not($concept/@conformance='C') and ($concept/@maximumMultiplicity='*' or not($concept/@maximumMultiplicity))) then
                    '*'
                else if (not($concept/@conformance='C')) then
                    $concept/@maximumMultiplicity/string()
                else if ($concept/@conformance='C' and $concept[not(@conformance='NP')][@maximumMultiplicity='*' or not(@maximumMultiplicity)]) then
                    '*'
                else if ($concept/condition[not(@conformance='NP')][@maximumMultiplicity]) then
                    max($concept/condition[not(@conformance='NP')][@maximumMultiplicity]/number(@maximumMultiplicity))
                else
                    '*'
            }
            ,
            $concept/../../name
            ,
            for $datasetName in $get:colDecorData//dataset[@id=$datasetId]/name
            return
                element {'datasetName'} { $datasetName/@*, $datasetName/text() }
        }
        </transaction>

let $templateAssociations := 
    for $templateAssociation in $get:colDecorData//templateAssociation[concept/@ref=(attribute id {$id}|$concepts/@conceptId)]
    let $template := $get:colDecorData//template[@id=$templateAssociation/@templateId][@effectiveDate=$templateAssociation/@effectiveDate][@statusCode!='deprecated']
    return
        if ($template) then
            let $templateName := if ($template/@displayName) then $template/@displayName/string() else ($template/@name/string())
            for $concept in $templateAssociation/concept[@ref=$id]
            let $elementId   := $concept/@elementId
            let $target      := $template//element[@id=$elementId]
            let $isMandatory := if ($target/@isMandatory='true') then 'true' else ('false')
            return
                <template id="{$templateAssociation/@templateId}" name="{$templateName}" effectiveDate="{$templateAssociation/@effectiveDate}" element="{$target/@name}" 
                    minimumMultiplicity="{$target/@minimumMultiplicity}" maximumMultiplicity="{$target/@maximumMultiplicity}" conformance="{$target/@conformance}" 
                    isMandatory="{$isMandatory}" targetElement="{$target/@name}" prefix="{$template/ancestor::decor/project/@prefix}"
                    projectName="{$template/ancestor::decor/project/name[1]}"/>
        else ()
return
<usage>
{
   $concepts
	,
   $transactions
	,
   $templateAssociations
}
</usage>


