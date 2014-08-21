xquery version "3.0";
(:
	Copyright (C) 2014 Art-Decor Expert Group
	
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

let $counters := collection(concat($get:strTerminologyData,'/dhd-data/meta'))/ids
let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))/thesaurus
let $maxConceptNo := max($thesaurus/concept/xs:integer(@no))
let $maxConceptId := max($thesaurus/concept/xs:integer(@thesaurusId))
let $maxDescNo := max($thesaurus//desc/xs:integer(@no))
let $maxInterfaceId := max($thesaurus//desc/xs:integer(@interfaceId))
let $maxIcd10No := max($thesaurus//icd10/xs:integer(@no))
let $maxDbcNo := max($thesaurus//dbc/xs:integer(@no))
let $maxDomainNo := max($thesaurus//specialism/xs:integer(@no))
return

<ids>
   <conceptNo max="{$maxConceptNo}" counter="{$counters/conceptNo}" ok="{$maxConceptNo=$counters/conceptNo}"/>
   <conceptId max="{$maxConceptId}" counter="{$counters/conceptId}" ok="{$maxConceptId=$counters/conceptId}"/>
   <descNo max="{$maxDescNo}" counter="{$counters/descNo}" ok="{$maxDescNo=$counters/descNo}"/>
   <interfaceId max="{$maxInterfaceId}" counter="{$counters/interfaceId}" ok="{$maxInterfaceId=$counters/interfaceId}"/>
   <icd10No max="{$maxIcd10No}" counter="{$counters/icd10No}" ok="{$maxIcd10No=$counters/icd10No}"/>
   <dbcNo max="{$maxDbcNo}" counter="{$counters/dbcNo}" ok="{$maxDbcNo=$counters/dbcNo}"/>
   <domainNo max="{$maxDomainNo}" counter="{$counters/domainNo}" ok="{$maxDomainNo=$counters/domainNo}"/>
</ids>