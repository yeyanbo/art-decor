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

(:let $refsetId:= request:get-parameter('id','')
let $refsetEffectiveDate:= request:get-parameter('effectiveDate',''):)

let $refsetId:= '41000146103'
let $refsetEffectiveDate:= '2012-12-03'

let $refset := collection(concat($get:strTerminologyData,'/snomed-refsets/data'))//refset[@id=$refsetId][@effectiveDate=$refsetEffectiveDate]
let $moduleId := $refset/ancestor::refsetProject/moduleDependency/@referencedComponentId

return
(
concat('id','&#9;','effectiveTime','&#9;','active','&#9;','moduleId','&#9;','refsetId','&#9;','referencedComponentId','&#13;&#10;'),
 for $member in $refset/member[@statusCode=('draft','final')]
 let $effectiveTime := concat(substring($member/@effectiveTime,1,4),substring($member/@effectiveTime,6,2),substring($member/@effectiveTime,9,2))
 let $active := if ($member/@statusCode='final') then '1' else ('0')
return
concat($member/@id,'&#9;',$effectiveTime,'&#9;',$active,'&#9;',$moduleId,'&#9;',$refsetId,'&#9;',$member/concept/@conceptId,'&#13;&#10;')
)

