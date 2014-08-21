xquery version "1.0";
(:
	Authors: Marc de Graauw
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at  "../../../art/modules/art-decor.xqm";
import module namespace artx ="http://art-decor.org/ns/art/xpath" at  "../../../art/modules/art-decor-xpath.xqm";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace hl7="urn:hl7-org:v3";
declare namespace util = 'http://exist-db.org/xquery/util';
declare option exist:serialize "indent=no";
declare option exist:serialize "omit-xml-declaration=no";

let $collection := collection($get:strDecorData)

let $format := if (request:exists()) then request:get-parameter('format','xml') else 'xml'
let $transactionId := if (request:exists()) then request:get-parameter('id','') else '2.16.840.1.113883.2.4.3.36.77.4.701'
let $version              := if (request:exists()) then request:get-parameter('version','') else ()

let $decor := 
    if ($version)
    then $get:colDecorVersion//decor[descendant::*[@id=$transactionId]][@versionDate=$version][1]
    else $get:colDecorData//decor[descendant::*[@id=$transactionId]]

let $assert :=  if (count($decor) = 1) then () 
    else error(QName('http://art-decor.org/ns/error', 'MoreOrLessThanOneDecor'), 'Parameters id and version point to zero or more than one decor file.')

(: For a version, get the stored xpaths from release, else calculate them for current decor :)
let $xpaths :=
    if ($version)
    then collection(concat(util:collection-name($decor), '/resources'))//xpaths[1]/transactionXpaths[@ref=$transactionId][1]
    else artx:getXpaths($decor, $decor//transaction[@id=$transactionId]/representingTemplate)
return $xpaths
(:return art:getFullDatasetTree($transactionId, (), $xpaths):)