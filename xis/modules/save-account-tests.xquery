xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Alexander Henket, Maarten Ligtvoet
	
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
declare namespace xis="http://art-decor.org/ns/xis";

(: server path:)
let $newTests := request:get-data()/xis:tests
let $user := xmldb:get-current-user()

let $update :=
   <xis:tests>
{
   for $test in $newTests/xis:test
   return
   <xis:test>
   {
      $test/@*,
      for $test in $test/xis:test
      return
      <xis:test>
      {
         $test/@*,
         for $validation in $test/xis:validation
         return
         <xis:validation>
         {
         $validation/@*,
         $validation/*
         }
         </xis:validation>
      }
      </xis:test>
   }
   </xis:test>
}
</xis:tests>

let $tests :=collection(concat($get:strXisAccounts, '/',$newTests/@account))//xis:tests

return
<response>
{
update value $tests with $update/*
(:$editedAccounts:)
}
</response>