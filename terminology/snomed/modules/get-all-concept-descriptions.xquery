xquery version "1.0";
(:
	Copyright (C) 2012 Art-Decor Expert Group
	
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
let $conceptId := request:get-parameter('conceptId','138875005')
(:let $conceptId := '302619004':)
let $descriptions := collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$conceptId]/desc
return
<result current="1" count="1">
{
 for $res in $descriptions
 return
 <description type="{$res/@type}" conceptId="{$res/../@conceptId}" fullName="{$res/../desc[@type='fsn']/text()}">{$res/text()}</description>
}
</result>