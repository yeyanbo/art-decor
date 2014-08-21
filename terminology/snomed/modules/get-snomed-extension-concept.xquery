xquery version "1.0";
(:
	Copyright (C) 2011-2014 Art Decor Expert Group art-decor.org
	
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


let $uuid := request:get-parameter('uuid','')
(:let $uuid :='65961f63-606d-4d6f-b1e3-311e88a14d07':)


let $result :=
      collection(concat($get:strTerminologyData,'/snomed-extension/concepts'))//concept[@uuid=$uuid]
   
return
<concept>
{$result/@*,
$result/desc[@active='1'],
for $src in $result/src[@active='1']
order by $src/@typeId
return
$src
,
$result/*[not(name()=('desc','src'))][@active='1']
}
</concept>
