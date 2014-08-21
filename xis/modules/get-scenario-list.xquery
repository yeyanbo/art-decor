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
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at  "../../art/modules/art-decor.xqm";

declare namespace xis="http://art-decor.org/ns/xis";

let $account := request:get-parameter('account','')
(:let $account := 'art-decor':)
let $scenarios := collection($get:strXisResources)//xis:scenarios

return
<scenarioList xmlns="http://art-decor.org/ns/xis">
{
for $scenario in $scenarios/xis:scenario
return
<scenario>
{
$scenario/@*,
$scenario/xis:name,
$scenario/xis:desc,
for $step in $scenario/xis:step
let $statusCode :=
   if ($step/xis:action/@type='store' and doc(concat($get:strXisAccounts, '/',$account,'/messages/',$step/xis:action/@filename))) then
   'completed'
   else ($step/@statusCode)
return
<step id="{$step/@id}" seqnr="{$step/@seqnr}" referenceDate="{$step/@referenceDate}" statusCode="{$statusCode}">
{
$step/xis:name,
$step/xis:desc
}
</step>
}
</scenario>
}
</scenarioList>