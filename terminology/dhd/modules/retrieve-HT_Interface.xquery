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
declare namespace compression="http://exist-db.org/xquery/compression";
(:declare option exist:serialize "method=text media-type=text/csv charset=utf-8";
:)

let $thesaurus := collection(concat($get:strTerminologyData,'/dhd-data/thesaurus'))//thesaurus

let $string:=
(
   concat('"ID_Thesaurus"',',','"ID_Interface"',',','"InterfaceTerm"',',','"Begindatum"',',','"Einddatum"',',','"MutatieDatum"',',','"MutatieCode"','&#13;&#10;'),
   for $desc in $thesaurus/concept/desc[@statusCode='final']
   let $thesaurusId := concat(substring('0000000000',1,(10 - string-length($desc/parent::concept/@thesaurusId))),$desc/parent::concept/@thesaurusId)
   let $interfaceId := concat(substring('0000000000',1,(10 - string-length($desc/@interfaceId))),$desc/@interfaceId)
   order by xs:integer($desc/@no)
   return
   concat('"',$thesaurusId,'"',',','"',$interfaceId,'"',',','"',$desc/text(),'"',',',replace($desc/@effectiveDate,'-',''),',',replace($desc/@expirationDate,'-',''),',',replace($desc/@editDate,'-',''),',','"',$desc/@editCode,'"','&#13;&#10;')
)


return
xmldb:store(concat($get:strTerminologyData,'/dhd-data/releases'),'test-it.csv',string-join($string,''),'text/csv')
