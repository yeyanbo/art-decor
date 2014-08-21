xquery version "1.0";
(:
    Copyright (C) 2011
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace art ="http://art-decor.org/ns/art" at "xmldb:exist:///db/apps/art/modules/art-decor.xqm";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace UML="omg.org/UML1.3";
declare namespace xs="http://www.w3.org/2001/XMLSchema";


declare function local:cleanConcept($concept as element()) as element() {
				let $id :=$concept/@id
				return
				<concept id="{$id}" type="{$concept/@type}" statusCode="{$concept/@statusCode}" effectiveDate="{$concept/@effectiveDate}">
					{
						if (string-length($concept/@versionLabel)>0) then
							$concept/@versionLabel
						else()
						,
						if (string-length($concept/@expirationDate)>0) then
							$concept/@expirationDate
						else()
						,
						$concept/inherit,
						$concept/name,
						$concept/desc,
						$concept/rationale,
						$concept/operationalization,
						$concept/valueDomain
						,
						for $subConcept in $concept/concept
						return
						local:cleanConcept($subConcept)
					}
				</concept>
};




let $dcmcollection := ('/db/apps/DCM/xmi')
let $decor:= collection('/db/apps/decor/data/')//decor[project/@prefix='psi-']


(:1. create ids:)

let $createIds :=
for $concept at $pos in $decor//concept[not(ancestor::conceptList)]
return
update value $concept/@id with concat('222.333.444.2.',$pos)

(:2. create ids for conceptlist and concepts:)

let $createConceptListIds :=
for $concept at $pos in $decor//concept[not(ancestor::conceptList)][valueDomain/conceptList]
return
(
update value $concept/valueDomain/conceptList/@id with concat($concept/@id,'.0')
,
for $conceptListConcept at $subPos in $concept/valueDomain/conceptList/concept
return
update value $conceptListConcept/@id with concat($concept/@id,'.',$subPos)
)


(:3. create terminology associations:)

let $associations :=
for $concept in $decor//concept[not(ancestor::conceptList)][association]
return
(
for $association in $concept/association
let $terminologyAssociation := 
<terminologyAssociation conceptId="{$concept/@id}" code="{$association/@code}" displayName="{$association/@displayName}" codeSystem="{$association/@codeSystem}" codeSystemName="{$association/@codeSystemName}"/>
return
update insert $terminologyAssociation into $decor/terminology
,
for $conceptListConcept  in $concept/valueDomain/conceptList/concept
return
for $subAssociation in $conceptListConcept/association
let $terminologyAssociation := 
<terminologyAssociation conceptId="{$conceptListConcept/@id}" code="{$subAssociation/@code}" displayName="{$subAssociation/@displayName}" codeSystem="{$subAssociation/@codeSystem}" codeSystemName="{$subAssociation/@codeSystemName}"/>
return
update insert $terminologyAssociation into $decor/terminology
)


(:4. create representingTemplate:)
let $representingTemplate :=
for $concept in $decor//concept[not(ancestor::conceptList)]
let $minimum :=
   if (contains($concept/@multiplicity,'..')) then
      normalize-space(substring-before($concept/@multiplicity,'..'))
   else if (not(contains($concept/@multiplicity,'..')) and string-length($concept/@multiplicity)>0) then
      normalize-space($concept/@multiplicity)
   else('0')
let $maximum :=
   if (contains($concept/@multiplicity,'..')) then
      normalize-space(substring-after($concept/@multiplicity,'..'))
   else if (not(contains($concept/@multiplicity,'..')) and string-length($concept/@multiplicity)>0) then
      normalize-space($concept/@multiplicity)
   else('1')
let $templateConcept :=
<concept ref="{$concept/@id}" minimumMultiplicity="{$minimum}" maximumMultiplicity="{$maximum}"/>
return
update insert $templateConcept into $decor/scenarios/scenario/transaction/transaction[1]/representingTemplate


(:5. rebuild concepts, remove superfluous attributes and elements serialize text content:)

(:let $cleanDataset :=
<dataset id="{$decor/datasets/dataset[1]/@id}" statusCode="{$decor/datasets/dataset[1]/@statusCode}" effectiveDate="{$decor/datasets/dataset[1]/@effectiveDate}">
	{
		$decor/datasets/dataset[1]/name
		,
		$decor/datasets/dataset[1]/desc
		,
		for $concept in $decor/datasets/dataset[1]/concept
		return
		local:cleanConcept($concept)
	}
</dataset>
let $deleteDataset := update delete $decor/datasets/dataset[1]
let $replaceDataset := update insert $cleanDataset into $decor/datasets:)

(:7. delete superfluous:)
let $delete :=
for $concept in $decor//concept[ancestor::conceptList]
return
update delete $concept/association
let $subDelete :=
for $concept in $decor//concept[not(ancestor::conceptList)]
return
(
update delete $concept/@multiplicity,
update delete $concept/association
)



return
<finished/>



