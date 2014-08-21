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

(:
   Query for deleting lock entries AND deleting newly created concepts
   Input:
   edited valueset 
   Return:
   data-safe=true
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

let $valueset := request:get-data()/valueSetVersions/valueSet
let $clear :=  update delete $get:colArtResources//valuesetLock[@ref=$valueset/valuesetLock/@ref][@effectiveDate=$valueset/valuesetLock/@effectiveDate]
let $deletes := 
if ($valueset/@statusCode='new') then
   update delete $get:colDecorData//valueSet[@statusCode='new'][@id=$valueset/@id][@effectiveDate=$valueset/@effectiveDate]
else()
return
<data-safe>true</data-safe>
