xquery version "3.0";
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

for $textFile in xmldb:get-child-resources(concat($get:strTerminologyData,'/snomed-extension/import/text'))
let $root :=
   if (contains($textFile,'Concept')) then
      'concepts'
   else if (contains($textFile,'Description')) then
      'descriptions'
   else if (contains($textFile,'Relationship')) then
      'relations'
   else()
let $rows :=
   if (contains($textFile,'Concept')) then
      'concept'
   else if (contains($textFile,'Description')) then
      'description'
   else if (contains($textFile,'Relationship')) then
      'relation'
   else()
 let $file :=
   <file name="{$textFile}" rows="{$rows}" root="{$root}">
   {util:binary-to-string(util:binary-doc(concat($get:strTerminologyData,'/snomed-extension/import/text/',$textFile)))}
   </file>
   
 let $xsltParameters :=	
    <parameters>
    </parameters>
return
(:$file:)
xmldb:store(concat($get:strTerminologyData,'/snomed-extension/import/Terminology'),concat($root,'.xml'),transform:transform($file, xs:anyURI(concat('xmldb:exist://',$get:strTerminology,'/snomed/resources/stylesheets/tabDelimited-to-xml.xsl')), $xsltParameters))
