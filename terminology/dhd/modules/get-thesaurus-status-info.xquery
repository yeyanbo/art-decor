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
import module namespace art    = "http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";

let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $draft :=$thesaurus/concept[@statusCode='draft']
let $update :=$thesaurus/concept[@statusCode='update']
let $review :=$thesaurus/concept[@statusCode='review']
let $rejected :=$thesaurus/concept[@statusCode='rejected']
return
<concepts draft="{count($draft)}" update="{count($update)}" review="{count($review)}" rejected="{count($rejected)}"/>

