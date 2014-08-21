xquery version "3.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Marc de Graauw
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace val ="http://art-decor.org/ns/validation" at "validation.xqm";
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
import module namespace artx ="http://art-decor.org/ns/art/xpath" at  "../../art/modules/art-decor-xpath.xqm";

declare namespace transform     = "http://exist-db.org/xquery/transform";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace response      = "http://exist-db.org/xquery/response";
declare namespace hl7           ="urn:hl7-org:v3";
declare namespace util          = 'http://exist-db.org/xquery/util';
declare namespace xis           ="http://art-decor.org/ns/xis";
declare namespace svrl          = "http://purl.oclc.org/dsdl/svrl";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare option exist:serialize "indent=no";
declare option exist:serialize "omit-xml-declaration=no";

(: Log debug messages? :)
let $debug             := true()

let $validationId := if (request:exists()) then request:get-parameter('id','') else '3'
let $testAccount := if (request:exists()) then request:get-parameter('account','') else 'rivmsp-graauw'

(: Get validation from id:)
let $testUrl := concat($get:strXisAccounts, '/',$testAccount)
let $validation := collection($testUrl)//xis:validation[@id=$validationId]
(: Make history file if not exists, store path to history.xml :)
let $history := if (not(fn:doc-available(concat($testUrl, '/history.xml')))) then xmldb:store($testUrl, 'history.xml', <xis:history xmlns:xis="http://art-decor.org/ns/xis"/>) else concat($testUrl, '/history.xml')

let $testsuiteTest := $validation/ancestor::xis:test[@testsuiteId]
(: Get XMLresourcesPath from testsuite:)
let $xmlResourcesPath := doc($get:strTestSuites)//testsuite[@id=$testsuiteTest/@testsuiteId]/xmlResourcesPath
(: Get message from path:)
let $messageFile := concat($get:strXisAccounts, '/',$testAccount,'/messages/', $validation/@messageFile)
let $message := doc($messageFile)
(: Get report from path:)
let $report := doc(concat($get:strXisAccounts, '/',$testAccount,'/reports/', $validation/@messageFile))
let $schemaValid := 
    if (not($report)) then false()
    else if ($report//error) then false()
    else true()

(: ==== START Schematron validation of messageInstance. Requires SVRL version of SCH (!) ==== :)
let $messageSchematronFile := concat($xmlResourcesPath,'/test_xslt/',$validation/parent::xis:test/@ref,'.xsl')
let $schematronIssues := val:validateSchematron($message, $messageSchematronFile) 

let $issueReport := <validationReport>{$schematronIssues}</validationReport>
let $result := val:makeIssueReport($issueReport)

let $status :=
   if  (not($schemaValid)) then 'invalid' 
   else if ($result//error) then 'fail'
   else'pass'

let $testUpdate :=
  let $delete :=
   (update delete $validation/validationReport,
   update delete $validation/messageFile)
  let $insert :=
   (update insert $result into $validation,
   update insert <messageFile>{$message}</messageFile> into $validation)
  let $updateStatus:= update value $validation/@statusCode with $status
  let $updateDateTime := update value $validation/@dateTime with current-dateTime()
  let $suiteStatus :=
    if (not($testsuiteTest//xis:validation[string-length(@statusCode)=0])) then
      if (count($testsuiteTest//xis:validation)=count($testsuiteTest//xis:validation[@statusCode='pass'])) then
         'pass'
      else('fail')
   else ('incomplete')
  let $suiteStatusUpdate := update value $testsuiteTest/@statusCode with $suiteStatus
  let $dummy := update insert <xis:result testsuiteId="{$testsuiteTest/@testsuiteId}"  testsuiteStatusCode="{$testsuiteTest/@statusCode}">{$validation/@*}</xis:result> into doc($history)/xis:history
  return
  <dummy/>
return
<result validationId="{$validationId}">{$status}</result>
(:$result:)
