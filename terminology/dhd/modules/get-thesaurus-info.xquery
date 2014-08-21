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
let $preferredTerms := count($thesaurus/concept/desc[@type='pref'])
let $test :=count($thesaurus/concept[count(desc)=1][desc/@type='syn'])
let $snomed := count($thesaurus//snomed/@conceptId[string-length() gt 0])
let $distinctSnomed := count(distinct-values($thesaurus//snomed/@conceptId[string-length() gt 0]))
return
<thesaurusInfo>
   <conceptsMissingPreferredTerm count="{count($thesaurus/concept[not(desc[@type='pref'])])}"/>
   <concepts count="{$count}" distinctThesaurusIds="{$distinct}" singleDBC="{count($thesaurus/concept[count(dbc)=1])}" active="{count($thesaurus/concept[@statusCode='active'])}" retired="{count($thesaurus/concept[@statusCode='retired'])}" missingDescription="{count($thesaurus/concept[not(desc)])}"/>
   <snomed count="{$snomed}" distinctConceptIds="{$distinctSnomed}"/>
   <terms count="{count($thesaurus/concept/desc)}"  distinctInterfaceIds="{count(distinct-values($thesaurus/concept/desc/@interfaceId))}" empty="{count($thesaurus/concept/desc[string-length()=0])}" preferred="{count($thesaurus/concept/desc[@type='pref'])}" syn="{count($thesaurus/concept/desc[@type='syn'])}"/>
   <dbc count="{count(collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc)}" distinctInReference="{count(distinct-values(collection(concat($get:strTerminologyData,'/dhd-data/reference'))//dbc/@code))}" distinctInThesaurus="{count(distinct-values(collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//dbc[parent::concept]/@code))}"/>
</thesaurusInfo>
