xquery version "1.0";
(:
	Copyright (C) 2011-2013 Art-Decor Expert Group
	
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


let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//thesaurus
let $count:= count($thesaurus/concept)
let $distinct := count(distinct-values($thesaurus/concept/@thesaurusId))
return
<thesaurusInfo>
   <concepts count="{$count}" distinctThesaurusIds="{$distinct}" update="{count($thesaurus/concept[@statusCode='update'])}" review="{count($thesaurus/concept[@statusCode='review'])}" draft="{count($thesaurus/concept[@statusCode='draft'])}" missingDescription="{count($thesaurus/concept[not(desc)])}"/>
</thesaurusInfo>
