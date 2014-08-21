xquery version "1.0";
(:
	Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
	
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
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xforms="http://www.w3.org/2002/xforms";

let $missingCodeSystems := request:get-data()/missingCodeSystems
(:let $missingCodeSystems :=
<missingCodeSystems projectPrefix="sandbox-">
<codeSystem ref="2.16.840.1.113883.5.1008" name="null" displayName="null"/>
</missingCodeSystems>:)

let $decor := $get:colDecorData//decor[project/@prefix=$missingCodeSystems/@projectPrefix]


let $insert :=
   for $codeSystem in $missingCodeSystems/codeSystem
   return
   if ($decor/terminology/valueSet) then
      update insert $codeSystem preceding  $decor/terminology/valueSet[1]
   else(
   update insert $codeSystem into  $decor/terminology
   )

   

return
<missingCodeSystems projectPrefix="{$decor/project/@prefix}"/>
