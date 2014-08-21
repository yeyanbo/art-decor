xquery version "1.0";

(:
	Copyright (C) 2012 Art Decor Expert group, www.art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace art ="http://art-decor.org/ns/art" at "xmldb:exist:///db/apps/art/modules/art-decor.xqm";
(:let $language := request:get-parameter('lang','nl-NL'):)
(:let $language := 'nl-NL':)



let $icaMapping := request:get-data()/cics

let $storedMapping := collection(concat($get:strTerminologyData,'/ica-data/concepts'))//cics

let $preparedUpdate :=
   <cics>
      {
      for $ci in $icaMapping/ci
      order by $ci/text
      return
      <ci>
         {
         $ci/@*,
         for $desc in $ci/description
         return
         art:parseNode($desc)
         ,
         $ci/text,
         $ci/icpc,
         $ci/icd-9,
         $ci/icd-10,
         $ci/snomed
         }
      </ci>
      }
   </cics>

return
update value $storedMapping with $preparedUpdate/*