xquery version "1.0";
(:
	Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Alexander Henket
	
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

declare namespace xmldb        = "http://exist-db.org/xquery/xmldb";
declare namespace sm        = "http://exist-db.org/xquery/securitymanager";
declare namespace xis       = "http://art-decor.org/ns/xis";

(: server path:)
let $testAccount := request:get-parameter('account','')
let $user        := xmldb:get-current-user()

let $tests :=
   if ($testAccount=sm:get-user-groups($user)) then
        collection(concat($get:strXisAccounts, '/',$testAccount))//xis:tests
   else(<nope/>)

(: store which testAccount was last selected, so messages and test screen can show this at startup :)
let $result := update delete doc($get:strTestAccounts)//xis:testAccount/xis:members/xis:user[@id=$user]/@lastSelected
let $result := update insert attribute lastSelected {'true'} into doc($get:strTestAccounts)//xis:testAccount[@name=$testAccount]/xis:members/xis:user[@id=$user]

let $testsuites:= doc($get:strTestSuites)//testsuites

return
<xis:tests account="{$testAccount}">
{
   for $test in $tests/xis:test
   let $testsuite :=$testsuites/testsuite[@id=$test/@testsuiteId]
   return
   <xis:test>
   {
      $test/@*,
      for $name in $testsuite/name
      return
      art:serializeNode($name)
      ,
      $testsuite/application-role,
      for $desc in $testsuite/desc
      return
      art:serializeNode($desc)
      ,
      for $test in $test/xis:test
      return
      <xis:test>
      {
         $test/@*,

   		for $desc in $testsuite/test[@schematron=$test/@ref]/desc
   		return
   		art:serializeNode($desc)
         ,
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