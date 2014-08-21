xquery version "1.0";
(:
    Copyright (C) 2012 Art Decor Expert Group
    
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
declare namespace UML="omg.org/UML1.3";

declare function local:processClass($class as element(),$xmi as element()) as element() {
				let $id :=$class/@xmi.id
				let $generalization :=$xmi//UML:Generalization[@subtype=$id]
				let $taggedValues := $class/UML:ModelElement.taggedValue/UML:TaggedValue
				let $desc := <desc language="nl-NL">{$taggedValues[@tag='documentation']/@value/string()}</desc>
				
				return
				<concept id="{$id}" multiplicity="{$xmi//UML:AssociationEnd[@type=$id]/@multiplicity}" type="{if ($generalization) then 'item' else('group')}" statusCode="draft" effectiveDate="{string-join(tokenize($taggedValues[@tag='date_created']/@value,'\s'),'T')}">
				  {
				  for $association in $xmi//UML:TaggedValue[@tag='DCM::DefinitionCode'][@modelElement=$id]
				  let $rawCode := normalize-space($association/@value)
				  let $code:=tokenize($rawCode,'\s')[2]
				  return
				  if (starts-with($rawCode,'SNOMEDCT:')) then
				     let $displayName :=normalize-space(substring-after($rawCode,$code))
				     return
				     <association codeSystem="2.16.840.1.113883.6.96" codeSystemName="Snomed-CT" code="{$code}" displayName="{$displayName}"/>
				  else if (starts-with($rawCode,'PSI:')) then
				     <association codeSystem="2222.3333.4444" codeSystemName="Parelsnoer" code="{$code}" displayName="{$class/@name}"/>
				  else()
				  }
               <name language="nl-NL">{$class/@name/string()}</name>
               {art:parseNode($desc)}
               {
               if ($class/UML:ModelElement.stereotype/UML:Stereotype/@name='rootconcept') then
                  let $rootPackage := $xmi//UML:Package[not(ancestor::UML:package)]
                  let $rationale:=<rationale>{$rootPackage/UML:Namespace.ownedElement/UML:Package[@name='Purpose']/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value/string()}</rationale>
                  let $instruction :=<instruction>{$rootPackage/UML:Namespace.ownedElement/UML:Package[@name='Instruction']/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value/string()}</instruction>
                  let $interpretation :=<interpretation>{$rootPackage/UML:Namespace.ownedElement/UML:Package[@name='Interpretation']/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value/string()}</interpretation>
                  let $careProcess :=<careProcess>{$rootPackage/UML:Namespace.ownedElement/UML:Package[@name='Care Process']/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value/string()}</careProcess>
                  return
                  (
                  <rationale>
                  {art:parseNode($rationale)/node()}
                   </rationale>,
                   <operationalization language="nl-NL">
                   {art:parseNode($instruction)/node()}
                   <p/>
                   {art:parseNode($interpretation)/node()}
                   <p/>
                   {art:parseNode($careProcess)/node()}
                   </operationalization>
                   )
               else()
               }
               {
               for $relation in $xmi//UML:AssociationEnd[@aggregation='composite'][@type=$id]
               let $subId := $relation/../UML:AssociationEnd[@aggregation='none']/@type/string()
               return
               local:processClass($xmi//UML:Class[@xmi.id=$subId],$xmi)
               }
               {
               if ($generalization) then
                  local:getValueDomain($class,$generalization,$xmi)
               else()
               }
				</concept>
};
declare function local:getValueDomain($class as element(),$generalization as element(),$xmi as element()) as element() {
   let $typeName := $generalization/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_targetName']/@value/string()
   return
   if ($typeName='BL') then
      <valueDomain type="boolean"/>
   else if ($typeName='CD') then
      <valueDomain type="code">
         <conceptList id="">
         {
         for $attribute in $class/UML:Classifier.feature/UML:Attribute
         return
       <concept id="">
           <name language="nl-NL">
              {$attribute/@name/string()}
           </name>
           {
				  for $association in $attribute/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='DCM::DefinitionCode']
				  let $rawCode := normalize-space($association/@value)
				  let $code:=tokenize($rawCode,'\s')[2]
				  return
				  if (starts-with($rawCode,'SNOMEDCT:')) then
				     let $displayName :=normalize-space(substring-after($rawCode,$code))
				     return
				     <association codeSystem="2.16.840.1.113883.6.96" codeSystemName="Snomed-CT" code="{$code}" displayName="{$displayName}"/>
				  else if (starts-with($rawCode,'PSI:')) then
				     <association codeSystem="2222.3333.4444" codeSystemName="Parelsnoer" code="{$code}" displayName="{$attribute/@name}"/>
				  else()
				  }
       </concept>
         }
         </conceptList>
      </valueDomain>
   else if ($typeName='CO') then
      <valueDomain type="ordinal">
       <conceptList id="">
         {
         for $attribute in $class/UML:Classifier.feature/UML:Attribute
         return
       <concept id="">
           <name language="nl-NL">
              {$attribute/@name/string()}
           </name>
           {
				  for $association in $attribute/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='DCM::DefinitionCode']
				  let $rawCode := normalize-space($association/@value)
				  let $code:=tokenize($rawCode,'\s')[2]
				  return
				  if (starts-with($rawCode,'SNOMEDCT:')) then
				     let $displayName :=normalize-space(substring-after($rawCode,$code))
				     return
				     <association codeSystem="2.16.840.1.113883.6.96" codeSystemName="Snomed-CT" code="{$code}" displayName="{$displayName}"/>
				  else if (starts-with($rawCode,'PSI:')) then
				     <association codeSystem="2222.3333.4444" codeSystemName="Parelsnoer" code="{$code}" displayName="{$attribute/@name}"/>
				  else()
				  }
       </concept>
         }
         </conceptList>
      </valueDomain>
   else if ($typeName='ED') then
      <valueDomain type="text"/>
   else if ($typeName='II') then
      <valueDomain type="identifier"/>
   else if ($typeName='INT') then
      <valueDomain type="count"/>
   else if ($typeName=('PQ','AantallenPerTijdseenheid','Hoeveelheid')) then
      <valueDomain type="quantity"/>
   else if ($typeName='ST') then
      <valueDomain type="string"/>
   else if ($typeName='TS') then
      <valueDomain type="datetime"/>
   else if ($typeName='Periode') then
      <valueDomain type="duration"/>
   else(
      let $superclass :=$xmi//UML:Class[@xmi.id=$generalization/@supertype]
      let $superGeneralization := $xmi//UML:Generalization[@subtype=$superclass/@xmi.id]
      return
      
      
      if($superclass/UML:ModelElement.stereotype/UML:Stereotype/@name='enumeration') then
      <valueDomain type="code">
        <conceptList id="">
         {
         for $attribute in $superclass/UML:Classifier.feature/UML:Attribute
         return
       <concept id="">
           <name language="nl-NL">
              {$attribute/@name/string()}
           </name>
           {
				  for $association in $attribute/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='DCM::DefinitionCode']
				  let $rawCode := normalize-space($association/@value)
				  let $code:=tokenize($rawCode,'\s')[2]
				  return
				  if (starts-with($rawCode,'SNOMEDCT:')) then
				     let $displayName :=normalize-space(substring-after($rawCode,$code))
				     return
				     <association codeSystem="2.16.840.1.113883.6.96" codeSystemName="Snomed-CT" code="{$code}" displayName="{$displayName}"/>
				  else if (starts-with($rawCode,'PSI:')) then
				     <association codeSystem="2222.3333.4444" codeSystemName="Parelsnoer" code="{$code}" displayName="{$attribute/@name}"/>
				  else()
				  }
       </concept>
         }
         </conceptList>
         </valueDomain>
         else(<valueDomain type="{$superclass/@name}"/>)
      )
};



let $dcmcollection := ('/db/apps/DCM/xmi')

(:let $allAuthors := collection($dcmcollection)//UML:TaggedValue[@tag='DCM::ContentAuthorList']
let $authorList :=
for $author in distinct-values($allAuthors/@value/string())
order by $author
return
$author:)

let $allDcms := collection($dcmcollection)//XMI
let $decor:= collection('/db/apps/decor/data/')//decor[project/@prefix='psi-']
(:let $deleteExistingConcepts := update delete $decor/datasets/dataset[1]/concept:)


return
<dataset id="222.333.444.1.1" statusCode="draft" effectiveDate="2012-10-28T11:58:36">
  <name language="nl-NL">ParelsnoerDCM Blokkendoos</name>
  <desc language="nl-NL">
     <b>N.B.</b>Dit is een test.<br/>
     De dataset is uit de Enterprise Architect XMI export middels xslt en xquery omgezet naar Decor. De correcte werking is nog niet gevalideerd!
  </desc>  
   {
   for $dcm in $allDcms
   let $rootClass := $dcm//UML:Class[UML:ModelElement.stereotype/UML:Stereotype/@name='rootconcept']
   return
   local:processClass($rootClass,$dcm)
   }
</dataset>


