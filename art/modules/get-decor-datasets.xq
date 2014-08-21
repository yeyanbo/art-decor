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

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace hl7       = "urn:hl7-org:v3";

declare function local:conceptBasics($concept as element()) as element() {
let $id :=$concept/@id
return
    <concept id="{$id}" type="{$concept/@type}">
  	{
  		$concept/name,
  		for $c in $concept/concept
  		return
  		local:conceptBasics($c)
  	}
    </concept>
};

<datasets>
{
let $collection := $get:strDecorData

for $dataset in collection($collection)//dataset
order by $dataset/name
return
<dataset id="{$dataset/@id}" effectiveDate="{$dataset/@effectiveDate}" statusCode="{$dataset/@statusCode}">
{
	$dataset/name,
	$dataset/desc,
	for $concept in $dataset/concept
	return
	local:conceptBasics($concept)
}
</dataset>

}
</datasets>
