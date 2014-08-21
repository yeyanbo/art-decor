xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at  "../../art/modules/art-decor.xqm";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace xis="http://art-decor.org/ns/xis";

let $testsuites:= doc($get:strTestSuites)//testsuites


return
<testsuites>
{
for $suite in $testsuites/testsuite
return
   <testsuite>
   {
   $suite/@*,
   for $name in $suite/name
   return
   art:serializeNode($name)
   ,
   
   $suite/application-role,
   for $desc in $suite/desc
   return
   art:serializeNode($desc)
   ,
   $suite/xmlResourcesPath,
   for $test in $suite/test
   return
   <test>
      {
      $test/@*,
		for $desc in $test/desc
		return
		art:serializeNode($desc)
      }
   </test>
   }
   </testsuite>
}
</testsuites>