xquery version "1.0";

(:
	Copyright (C) 2012 Art Decor Expert group, www.art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace art    = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
import module namespace get    = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
(:let $language := request:get-parameter('lang','nl-NL'):)
(:let $language := 'nl-NL':)

let $icaMapping      := request:get-data()/cics

let $storedMapping   := collection(concat($get:strTerminologyData,'/ica-data/concepts'))//cics

let $preparedProject :=
    <project>
    {
        $icaMapping/project/@*,
        $icaMapping/project/name,
        for $desc in $icaMapping/project/description
        return
        art:parseNode($desc)
        ,
        $icaMapping/project/author
    }
    </project>
let $projectUpdate :=
    update replace $storedMapping/project with $preparedProject


let $ciUpdate :=
    for $ci in $icaMapping/ci[edit]
    let $statusCode :=
        if ($ci/@statusCode='new') then
            'draft'
        else($ci/@statusCode/string())
    let $preparedCi :=
        <ci id="{$ci/@id}" code="{$ci/@code}"  statusCode="{$statusCode}" effectiveDate="{$ci/@effectiveDate}">
        {
            for $desc in $ci/description
            return
                art:parseNode($desc)
            ,
            for $rationale in $ci/rationale
            return
                art:parseNode($rationale)
            ,
            $ci/text,
            $ci/cic,
            $ci/icpc,
            $ci/icd-9,
            $ci/icd-10,
            $ci/snomed,
            $ci/other
        }
        </ci>
    return
    if ($ci[edit/@mode='edit']) then
        update replace $storedMapping//ci[@id=$ci/@id] with $preparedCi
    else if ($ci[edit/@mode='new']) then
        update insert $preparedCi into $storedMapping
    else()


return
<data-safe>true</data-safe>