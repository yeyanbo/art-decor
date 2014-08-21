xquery version "1.0";
(:
    Copyright (C) 2011
    
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
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace UML="omg.org/UML1.3";
declare namespace xs="http://www.w3.org/2001/XMLSchema";

let $dcms := collection('/db/apps/DCM')//XMI

return
for $enumeration at $pos in $dcms//UML:Class[UML:ModelElement.stereotype/UML:Stereotype/@name='enumeration']
let $desc :=<desc language="nl-NL">{normalize-space($enumeration/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value)}</desc>
return
<valueSet id="{concat('222.333.444.11.',$pos)}" name="{$enumeration/@name}" effectiveDate="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}" displayName="{$enumeration/@name}" statusCode="draft" xmi.id="{$enumeration/@xmi.id}">
{art:parseNode($desc)}
<conceptList>
 {  
   for $classifier in $enumeration/UML:Classifier.feature/UML:Attribute
   let $tags :=$classifier/UML:ModelElement.taggedValue
   let $definition := $tags/UML:TaggedValue[@tag='DCM::DefinitionCode']/@value
   let $concept :=
      if (starts-with($definition,'SNOMEDCT:')) then
      let $code := tokenize($definition,'\s')[2]
      return
      <concept codeSystem="2.16.840.1.113883.6.96" codeSystemName="Snomed-CT" code="{$code}"/>
      else if (starts-with($definition,'PSI:')) then
      let $code := tokenize($definition,'\s')[2]
      return
      <concept codeSystem="2222.3333.4444" codeSystemName="Parelsnoer" code="{$code}"/>
      else()
      
   return
   <concept level="0" type="L" code="{$concept/@code}" displayName="{normalize-space($tags/UML:TaggedValue[@tag='description']/@value)}" codeSystem="{$concept/@codeSystem}" codeSystemName="{$concept/@codeSystemName}"/>
}
</conceptList>
</valueSet>
