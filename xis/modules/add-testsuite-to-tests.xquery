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

declare namespace request    = "http://exist-db.org/xquery/request";
declare namespace xis="http://art-decor.org/ns/xis";

let $testAccount := request:get-parameter('account','')
let $testsuiteId :=request:get-parameter('id','')
(:
let $testAccount := 'art-decor'
let $testsuiteId :='1':)

let $testsuite := doc($get:strTestSuites)//testsuite[@id=$testsuiteId]
let $tests :=collection(concat($get:strXisAccounts, '/',$testAccount))//xis:tests

let $maxId :=
         if ($tests//xis:validation/@id) then
            max($tests//xis:validation/@id)
          else(number('0'))
          
let $insert :=
   <xis:test testsuiteId="{$testsuiteId}" statusCode="">
   {
      for $test at $position in $testsuite/test
      
      return
      <xis:test ref="{$test/@schematron}">
      {
         <xis:validation id="{$maxId+$position}" dateTime="" messageFile="" statusCode=""/>
      }
      </xis:test>
   }
   </xis:test>


return
<response>
{
update insert $insert into $tests
}
</response>