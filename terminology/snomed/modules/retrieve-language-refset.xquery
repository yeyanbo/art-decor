xquery version "1.0";
(:
	Copyright (C) 2011-2013 Art Decor Expert Group art-decor.org
	
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
import module namespace art ="http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";
declare option exist:serialize "method=text media-type=text/csv charset=utf-8";

let $refsetId:= request:get-parameter('id','')
let $refsetEffectiveDate:= request:get-parameter('effectiveDate','')

(:let $refsetId:= '41000146103'
let $refsetEffectiveDate:= '2012-12-03':)

let $refset := collection(concat($get:strTerminologyData,'/snomed-refsets/data'))//refset[@id=$refsetId][@effectiveDate=$refsetEffectiveDate]
let $moduleId := $refset/ancestor::refsetProject/moduleDependency/@referencedComponentId
let $languageRefsetId :='31000146106'
let $nextReleaseDate := '20140131'

return
(
concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','refsetId','&#9;','referencedComponentId','&#9;','acceptabilityId','&#13;&#10;'),
 for $desc in $refset/member[@statusCode=('draft','final')]/desc
 let $effectiveTime := 
   if (string-length($desc/@effectiveTime)=0) then 
      $nextReleaseDate
   else(concat(substring($desc/@effectiveTime,1,4),substring($desc/@effectiveTime,6,2),substring($desc/@effectiveTime,9,2)))
 let $active := 
   if ($desc/@statusCode='final') then 
      '1'
   else('0')
 let $acceptability := 
   if ($desc/@type='pref') then 
      '900000000000548007'
   else('900000000000549004')
return
concat(util:uuid(),'&#9;',$effectiveTime,'&#9;',$active,'&#9;',$moduleId,'&#9;',$languageRefsetId,'&#9;',$desc/@id,'&#9;',$acceptability,'&#13;&#10;')
)

