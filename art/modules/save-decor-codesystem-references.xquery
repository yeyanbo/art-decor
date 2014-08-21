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
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";

let $codeSystems :=request:get-data()/codeSystems
let $decor := $get:colDecorData//decor[project/@prefix=$codeSystems/@projectPrefix]

let $store :=
   for $codeSystem in $codeSystems/codeSystem
   let $storedCodeSystem := $decor/terminology/codeSystem[@ref=$codeSystem/@ref]
   return
   if ($storedCodeSystem) then
      update replace $storedCodeSystem with $codeSystem
   else if (not($storedCodeSystem) and $decor/terminology/valueSet) then
      update insert $codeSystem preceding  $decor/terminology/valueSet[1]
   else(
   update insert $codeSystem into  $decor/terminology
   )


return
<data-safe>true</data-safe>
