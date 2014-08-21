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

declare namespace hl7="urn:hl7-org:v3";
declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";
declare namespace xis="http://art-decor.org/ns/xis";
declare option exist:serialize "method=xhtml media-type=text/html";


declare function local:formatHL7Date($dateString as xs:string?) as xs:string {
    if (string-length($dateString)>0) then
        concat(substring($dateString,7,2),'-',substring($dateString,5,2),'-',substring($dateString,1,4))
    else ('')
};
declare function local:getPrescriptionStartDate($prescription as element()) as xs:string* {
   if ($prescription//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:low) then
      xs:string(xs:decimal(min(data($prescription//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:low/@value))))
   else if ($prescription//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:comp/hl7:low) then
      xs:string(xs:decimal(min(data($prescription//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:comp/hl7:low/@value))))
   else if ($prescription/hl7:author/hl7:time/@value) then
      data($prescription/hl7:author/hl7:time/@value)
   else()
};
declare function local:getPrescriptionStopDate($prescription as element()) as xs:string* {
   if ($prescription//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:high) then
      xs:string(max(data($prescription//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:high/xs:decimal(@value))))
   else if ($prescription//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:comp/hl7:high) then
      xs:string(max(data($prescription//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:comp/hl7:high/xs:decimal(@value))))
   else if ($prescription/hl7:effectiveTime/hl7:high/@value) then
      data($prescription/hl7:effectiveTime/hl7:high/@value)
   else()
};
declare function local:getDispenseEventStartDate($dispenseEvent as element()) as xs:string* {
   if ($dispenseEvent//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:low) then
      xs:string(min(data($dispenseEvent//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:low/xs:decimal(@value))))
   else if ($dispenseEvent//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:comp/hl7:low) then
      xs:string(min(data($dispenseEvent//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:comp/hl7:low/xs:decimal(@value))))
   else if ($dispenseEvent/hl7:effectiveTime/hl7:low/@value) then
      data($dispenseEvent/hl7:effectiveTime/hl7:low/@value)
   else if ($dispenseEvent/hl7:effectiveTime/@value) then
      data($dispenseEvent/hl7:effectiveTime/@value)
   else()
};
declare function local:getDispenseEventStopDate($dispenseEvent as element()) as xs:string* {
   if ($dispenseEvent//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:high) then
      xs:string(max(data($dispenseEvent//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:high/xs:decimal(@value))))
   else if ($dispenseEvent//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:comp/hl7:high) then
      xs:string(max(data($dispenseEvent//hl7:medicationAdministrationRequest/hl7:effectiveTime/hl7:comp/hl7:high/xs:decimal(@value))))
   else if ($dispenseEvent/hl7:effectiveTime/hl7:high/@value) then
      data($dispenseEvent/hl7:effectiveTime/hl7:high/@value)
   else()
};
declare function local:resolvePredecessors($prescription as element(),$preprocessedPrescriptions as item()) as element() {
   <medication>
      {
      $prescription/@*,
      $prescription/*
      ,
      if ($prescription/predecessor) then
         local:resolvePredecessors($preprocessedPrescriptions/medication[@root=$prescription/predecessor/@root][@extension=$prescription/predecessor/@extension],$preprocessedPrescriptions)
      else()
      }
   </medication>
};
declare function local:determinePrescriptionStatus($prescription as element(),$uniquePrescriptions as item(), $referenceDate as xs:date) as xs:string {
   let $successors :=$uniquePrescriptions//hl7:previousPrescription[hl7:id/@extension=$prescription/hl7:id/@extension][hl7:id/@root=$prescription/hl7:id/@root]
   let $prescStopDate := local:getPrescriptionStopDate($prescription)
   return
          if ($successors) then
            let $dates :=
               for $successor in  $successors
               return
               xs:decimal(local:getPrescriptionStartDate($successor/ancestor::hl7:prescription))
            let $minDate := xs:string(min($dates))
            return
            if(xs:date(concat(substring($minDate,1,4),'-',substring($minDate,5,2),'-',substring($minDate,7,2))) > $referenceDate) then
               'active'
            else
            (
               if (some $successor in $successors satisfies $successor/hl7:statusCode/@code='aborted') then
               'inactive'
               else
               (
               let $succesorsStatus :=
                  for $successor in $successors
                  let $successorPrescription :=$successor/ancestor::hl7:prescription
                  return
                  local:determinePrescriptionStatus($successorPrescription,$uniquePrescriptions,$referenceDate)
               return
               if (every $status in $succesorsStatus satisfies $status='inactive') then
                  'active'
               else
               (
               'inactive'
               )
               )
            )
         else
         (
            if (concat(substring($prescStopDate,1,4),'-',substring($prescStopDate,5,2),'-',substring($prescStopDate,7,2)) castable as xs:date) then
               if (xs:date(concat(substring($prescStopDate,1,4),'-',substring($prescStopDate,5,2),'-',substring($prescStopDate,7,2))) < $referenceDate) then
                  'inactive'
               else('active')
            else ('active')
         )
};
declare function local:formatHL7Name($hl7Name as element()?) as xs:string {
    if (exists($hl7Name)) then
            <name>
            {
               for $given in $hl7Name/hl7:given
               return
               concat($given,' ')
            }
            {
             for $rest in $hl7Name/*[local-name()!='given']
             return
             $rest/text()
            }
            </name>
    else ('')
};
declare function local:getProduct($prescriptionOrDispense as element()) as element() {
         let $hl7Code := if (local-name($prescriptionOrDispense)='prescription') then
                           $prescriptionOrDispense/hl7:directTarget/hl7:prescribedMedication/hl7:MedicationKind/hl7:code
                         else if (local-name($prescriptionOrDispense)='medicationDispenseEvent') then
                           $prescriptionOrDispense/hl7:product/hl7:dispensedMedication/hl7:MedicationKind/hl7:code
                         else(<error>Not a prescription or dispenseEvent</error>)
         let $code := $hl7Code/@code/string()
         let $codeSystem := $hl7Code/@codeSystem/string()
         return
         if ($hl7Code/@nullFlavor) then
         <product gpkode="" atcode="">
            <naam>
               <etiket>{$hl7Code/hl7:originalText/text()}</etiket>
               <kort>{$hl7Code/hl7:originalText/text()}</kort>
               <volledig>{$hl7Code/hl7:originalText/text()}</volledig>
               <omschrijving>{$hl7Code/../hl7:desc/text()}</omschrijving>
           </naam>
           <stofNaam>
               <etiket></etiket>
               <kort></kort>
               <volledig></volledig>
           </stofNaam>
           <vorm>
               <nm15></nm15>
               <nm25></nm25>
               <nm50></nm50>
           </vorm>
           <toedieningsweg>
               <nm15></nm15>
               <nm25></nm25>
               <nm50></nm50>
           </toedieningsweg>
           <atc>
               <omschrijving></omschrijving>
           </atc>
         </product>
         else (
         if ($codeSystem='2.16.840.1.113883.2.4.4.1') then
            if (collection($get:strXisHelperConfig)//product[@gpkode=$code]) then
            collection($get:strXisHelperConfig)//product[@gpkode=$code]
            else(<error>Unknown code</error>)
         else if ($codeSystem='2.16.840.1.113883.2.4.4.7') then
            if (collection($get:strXisHelperConfig)//product[prk/hpk/@hpkode=$code]) then
               collection($get:strXisHelperConfig)//product[prk/hpk/@hpkode=$code]
            else if ($hl7Code/hl7:translation[@codeSystem='2.16.840.1.113883.2.4.4.1']) then
                     let $translationGpk := $hl7Code/hl7:translation[@codeSystem='2.16.840.1.113883.2.4.4.1']/@code
                     return
                     if (collection($get:strXisHelperConfig)//product[@gpkode=$translationGpk]) then
                        collection($get:strXisHelperConfig)//product[@gpkode=$translationGpk]
                     else(<error>Unknown code</error>)
            else(<error>Unknown code</error>)
         else if ($codeSystem='2.16.840.1.113883.2.4.4.10') then
            if (collection($get:strXisHelperConfig)//product[prk/@prkode=$code]) then
               collection($get:strXisHelperConfig)//product[prk/@prkode=$code]
            else(<error>Unknown code</error>)
         else if ($codeSystem='2.16.840.1.113883.2.4.4.8') then
            if (collection($get:strXisHelperConfig)//product[prk/hpk/artikel/@atkode=$code]) then
               collection($get:strXisHelperConfig)//product[prk/hpk/artikel/@atkode=$code]
            else if ($hl7Code/hl7:translation[@codeSystem='2.16.840.1.113883.2.4.4.7']) then
                  let $translationHpk := $hl7Code/hl7:translation[@codeSystem='2.16.840.1.113883.2.4.4.7']/@code
                  return
                  if (collection($get:strXisHelperConfig)//product[prk/hpk/@hpkode=$translationHpk]) then
                     collection($get:strXisHelperConfig)//product[prk/hpk/@hpkode=$translationHpk]
                  else(
                    if ($hl7Code/hl7:translation[@codeSystem='2.16.840.1.113883.2.4.4.1']) then
                     let $translationGpk := $hl7Code/hl7:translation[@codeSystem='2.16.840.1.113883.2.4.4.1']/@code
                     return
                     if (collection($get:strXisHelperConfig)//product[@gpkode=$translationGpk]) then
                        collection($get:strXisHelperConfig)//product[@gpkode=$translationGpk]
                     else(<error>Unknown code</error>)
                    else(<error>Unknown code</error>)
                      )
              else if ($hl7Code/hl7:translation[@codeSystem='2.16.840.1.113883.2.4.4.1']) then
                     let $translationGpk := $hl7Code/hl7:translation[@codeSystem='2.16.840.1.113883.2.4.4.1']/@code
                     return
                     if (collection($get:strXisHelperConfig)//product[@gpkode=$translationGpk]) then
                        collection($get:strXisHelperConfig)//product[@gpkode=$translationGpk]
                     else(<error>Unknown code</error>)
            else(<error>Unknown code</error>)
               
               
         else (<error>Unknown codeSystem</error>)
         )
};
declare function local:getAuthorNameAndType($hl7Author as element(), $combinedBatches as item(),$vocabulary as item()*) as element() {
      let $assignedPerson := $hl7Author/hl7:assignedPerson|$hl7Author/hl7:AssignedPerson
      return
      <author>
         {
            if ($assignedPerson/hl7:assignee/hl7:assigneePerson/hl7:name[1]) then
               local:formatHL7Name($assignedPerson/hl7:assignee[1]/hl7:assigneePerson/hl7:name)
            else(
               let $authorIdRoot := $assignedPerson/hl7:id/@root
               let $authorIdExt := $assignedPerson/hl7:id/@extension
               return
               local:formatHL7Name($combinedBatches//hl7:*[hl7:id/@root=$authorIdRoot and hl7:id/@extension=$authorIdExt][1]//hl7:name[1])/name
            ),
            if ($assignedPerson/hl7:code[1]) then
               concat(', ',$vocabulary//hl7:code[@code=$assignedPerson/hl7:code/@code][@codeSystem=$assignedPerson/hl7:code/@codeSystem]/@displayName/string())
            else(
            let $authorIdRoot := $assignedPerson/hl7:id/@root
            let $authorIdExt := $assignedPerson/hl7:id/@extension
            let $authorCode := $combinedBatches//hl7:*[hl7:id/@root=$authorIdRoot and hl7:id/@extension=$authorIdExt]/hl7:code[1]
            return
            concat(', ',$vocabulary//hl7:code[@code=$authorCode/@code][@codeSystem=$authorCode/@codeSystem]/@displayName/string())
            )
         }
      </author>
};
declare function local:getAssignedProviderNameAndType($hl7AssignedProvider as element(), $combinedBatches as item(),$vocabulary as item()*) as element() {
      <author>
         {
            let $authorIdRoot := $hl7AssignedProvider/hl7:id/@root
            let $authorIdExt := $hl7AssignedProvider/hl7:id/@extension
            return
            local:formatHL7Name(collection($get:strXisHelperConfig)//hl7:provider[hl7:id/@root=$authorIdRoot and hl7:id/@extension=$authorIdExt][1]//hl7:name[1])
          }
          {

               concat(', ',$vocabulary//hl7:code[@code=$hl7AssignedProvider/hl7:code[1]/@code][@codeSystem=$hl7AssignedProvider/hl7:code[1]/@codeSystem]/@displayName/string())

         }
      </author>
};
declare function local:processValue($value as element()) as xs:string {
   if ($value/@value) then
      concat($value/@value,' ',$value/@unit)
   else if ($value/hl7:low and $value/hl7:high and $value/@xsi:type='IVL_PQ') then
      concat($value/hl7:low/@value,'-',$value/hl7:high/@value,' ',$value/hl7:high/@unit)
   else()
           
};

let $patientId := request:get-parameter('patientId','')
let $account := request:get-parameter('account','')
let $referenceDate :=
      if (string-length(request:get-parameter('referenceDate',''))>0)then
         xs:date(substring(request:get-parameter('referenceDate',''),1,10))
      else(current-date())
      
(:let $patientId := xs:string('999999011')
let $account := 'art-decor'
let $referenceDate := current-date():)

let $xmlPath := 
   if (string-length($account)>0) then
      concat($get:strXisAccounts, '/',$account,'/messages')
   else()
   
let $vocabPath := doc($get:strTestAccounts)/xis:testAccount[@name='art-decor']//xis:xmlResourcesPath

(: need to login because user credentials are not passed with call:)
let $login            := xmldb:login("/db", "xis-webservice", "webservice-xs2messages")

let $combinedBatches := 
         let $patientSequence := collection($xmlPath)//hl7:Patient[hl7:id/@extension=$patientId][hl7:id/@root='2.16.840.1.113883.2.4.6.3']|collection($xmlPath)//hl7:patient[hl7:id/@extension=$patientId][hl7:id/@root='2.16.840.1.113883.2.4.6.3']
         let $dispenseLists :=$patientSequence/ancestor::hl7:QURX_IN990113NL
         let $prescriptionslists := $patientSequence/ancestor::hl7:QURX_IN990103NL|$patientSequence/ancestor::hl7:QURX_IN990103NL02|$patientSequence/ancestor::hl7:QURX_IN990003NL
         let $conditionList :=$patientSequence/ancestor::hl7:REPC_IN000024NL
         let $labresultList :=$patientSequence/ancestor::hl7:POLB_IN364000NL
         return 
         $dispenseLists|$prescriptionslists|$conditionList|$labresultList


(:let $dispenseLists :=collection($xmlPath)//hl7:QURX_IN990113NL/hl7:ControlActProcess/hl7:subject[hl7:MedicationDispenseList/hl7:subject/hl7:Patient/hl7:id/@extension=$patientId]
let $prescriptionslists := collection($xmlPath)//hl7:QURX_IN990103NL/hl7:ControlActProcess/hl7:subject[hl7:MedicationPrescriptionList/hl7:subject/hl7:Patient/hl7:id/@extension=$patientId]
let $combinedBatches := $dispenseLists|$prescriptionslists:)

let $vocabulary := collection(concat($vocabPath,'/vocab'))//hl7:codeSystem
let $products := collection($get:strXisHelperConfig)//product

(: Patient demographic:)
let $patients := $combinedBatches//hl7:Patient|$combinedBatches//hl7:patient
let $hl7Patient := $patients[hl7:Person/hl7:name][1]
let $patient :=
            <patient>
               <name>{local:formatHL7Name($hl7Patient/hl7:Person/hl7:name)}</name>
               <addres>{concat($hl7Patient/hl7:addr/hl7:streetName,' ',$hl7Patient/hl7:addr/hl7:houseNumber,' ',$hl7Patient/hl7:addr/hl7:additionalLocator)}</addres>
               <postcodeCity>{concat($hl7Patient/hl7:addr/hl7:postalCode,' ',$hl7Patient/hl7:addr/hl7:city)}</postcodeCity>
               <telephone>{substring-after($hl7Patient/hl7:telecom/@value[starts-with(.,'tel:')]/string(),'tel:')}</telephone>
               <bsn>{$hl7Patient/hl7:id[@root='2.16.840.1.113883.2.4.6.3']/@extension/string()}</bsn>
               <birthDate>{local:formatHL7Date($hl7Patient/hl7:Person/hl7:birthTime/@value)}</birthDate>
               <gender>{if ($hl7Patient/hl7:Person/hl7:administrativeGenderCode/@code='M') then
                           'M'
                      else if ($hl7Patient/hl7:Person/hl7:administrativeGenderCode/@code='F') then
                           'V'
                      else('Onbekend')}</gender>
            </patient>

(: Conditions :)
let $conditions := 
   <conditions>
   {
      for $condition in $combinedBatches//hl7:subject/hl7:Condition
      return
      <condition negationInd="{$condition/@negationInd}">
         <description>
            {
            if ($condition/hl7:code/@code='DX' or $condition/hl7:code/@code='DERDX') then
            $condition/hl7:value/@displayName/string()
            else ($condition/hl7:causativeAgent/hl7:administerableMaterial/hl7:*/hl7:code/@displayName/string())
            }
         </description>
         <startDate>{local:formatHL7Date($condition/hl7:effectiveTime/hl7:low/@value)}</startDate>
         <stopDate>{local:formatHL7Date($condition/hl7:effectiveTime/hl7:high/@value)}</stopDate>
         <type>{$vocabulary//hl7:code[@code=$condition/hl7:code/@code][@codeSystem=$condition/hl7:code/@codeSystem]/@displayName/string()}</type>
         <remark>
          {
            if ($condition/hl7:subjectOf1/hl7:severityObservation) then
            $vocabulary//hl7:code[@code=$condition/hl7:subjectOf1/hl7:severityObservation/hl7:value/@code][@codeSystem=$condition/hl7:subjectOf1/hl7:severityObservation/hl7:value/@codeSystem]/@displayName/string()
            else()
            }
            {
            if ($condition/hl7:subjectOf1/hl7:severityObservation and $condition/hl7:uncertaintyCode/@code != 'N') then
            ' ; '
            else()
            }
            {
            if ($condition/hl7:uncertaintyCode/@code != 'N') then
            $vocabulary//hl7:code[@code=$condition/hl7:uncertaintyCode/@code][@codeSystem=$condition/hl7:uncertaintyCode/@codeSystem]/@displayName/string()
            else()
            }
         </remark>
         <author>
            {
            if ($condition/hl7:author/hl7:patient) then
            'Patiënt'
            else(local:getAuthorNameAndType($condition/hl7:author,$combinedBatches[1],$vocabulary)
            )
            }
         </author>
      </condition>
   }
   </conditions>

(: find duplicate prescriptions and remove superceded prescriptions:)
let $uniquePrescriptions :=
   for $prescription in $combinedBatches//hl7:prescription[parent::hl7:component]
   let $prescriptions := $combinedBatches//hl7:prescription[parent::hl7:component][hl7:id/@extension=$prescription/hl7:id/@extension][hl7:id/@root=$prescription/hl7:id/@root]
   let $creationTimes :=
      for $presc in  $prescriptions
      return
      xs:decimal($presc/ancestor::*[hl7:creationTime]/hl7:creationTime/@value)
   return
   if (count($prescriptions)>1) then
      if (string(max($creationTimes))=$prescription/ancestor::*[hl7:creationTime]/hl7:creationTime/@value/string()) then
         $prescription
      else()
   else($prescription)

let $preprocessedPrescriptions :=
   <medications>
      {
      for $prescription in $uniquePrescriptions
      let $prescrProduct :=local:getProduct($prescription)
      let $startDate := local:getPrescriptionStartDate($prescription)
      let $prescStopDate := local:getPrescriptionStopDate($prescription)
      let $successors :=$combinedBatches//hl7:previousPrescription[hl7:id/@extension=$prescription/hl7:id/@extension][hl7:id/@root=$prescription/hl7:id/@root]
      let $status := local:determinePrescriptionStatus($prescription,$uniquePrescriptions,$referenceDate)
      return
      <medication root="{$prescription/hl7:id/@root}" extension="{$prescription/hl7:id/@extension}" status="{$status}" type="prescription" start="{$startDate}" stop="{$prescStopDate}" atc="{$prescrProduct/@atcode}">
         <product>
            <name>{$prescrProduct/naam/volledig/text()}</name>
            <labelName>{$prescrProduct/naam/etiket/text()}</labelName>
            <description></description>
            <route>{$prescrProduct/toedieningsweg/nm25/text()}</route>
         </product>
         {
         if ($prescription/hl7:reason) then
            <reason>
            {concat('Reden voorschrijven: ',$prescription/hl7:reason/hl7:diagnosisEvent/hl7:value/@displayName)}
            </reason>
         else()
         }
         <author>
            {
            $prescription/hl7:author
(:            local:getAuthorNameAndType($prescription/hl7:author,$combinedBatches,$vocabulary):)
            }
         </author>
         <usage>
            {
            $prescription/hl7:directTarget/hl7:prescribedMedication/hl7:therapeuticAgentOf/hl7:medicationAdministrationRequest/@negationInd,
            $prescription/hl7:directTarget/hl7:prescribedMedication/hl7:therapeuticAgentOf/hl7:medicationAdministrationRequest/hl7:text/text()
            }
         </usage>
         {
         if ($prescription/hl7:predecessor) then
            <predecessor root="{$prescription/hl7:predecessor/hl7:previousPrescription/hl7:id/@root}" extension="{$prescription/hl7:predecessor/hl7:previousPrescription/hl7:id/@extension}" statusCode="{$prescription/hl7:predecessor/hl7:previousPrescription/hl7:statusCode/@code}"/>
         else()
         ,
         if ($successors) then
            let $allSuccessors := 
               for $successor in $successors
               let $successorPresc := $successor/ancestor::hl7:prescription
               return
               <successor status="{local:determinePrescriptionStatus($successorPresc,$combinedBatches,$referenceDate)}" root="{$successorPresc/hl7:id/@root}" extension="{$successorPresc/hl7:id/@extension}"/>
             let $creationTimes :=
               for $succs in  $allSuccessors
               return
               xs:decimal($succs/ancestor::*[hl7:creationTime]/hl7:creationTime/@value)
             return
            <successors>
               {
               for $succs in $allSuccessors
               return
               if (count($allSuccessors)>1) then
                  if (string(max($creationTimes))=$succs/ancestor::*[hl7:creationTime]/hl7:creationTime/@value/string()) then
                  $succs
                  else()
               else($succs)
               }
            </successors>
         else()
         ,
         for $dispenseEvent in $combinedBatches//hl7:medicationDispenseEvent
         let $prescriptionRef := $dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:directTargetOf/hl7:prescription/hl7:id
         let $dispProduct := local:getProduct($dispenseEvent)
         let $startDate := local:getDispenseEventStartDate($dispenseEvent)
         let $stopDate := local:getDispenseEventStopDate($dispenseEvent)
         where $prescription/hl7:id[@root=$prescriptionRef/@root][@extension=$prescriptionRef/@extension]
         return
         <medication type="dispense" start="{$startDate}" stop="{$stopDate}" atc="{$dispProduct/@atcode}">
            <product>
               <name>{data($dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:MedicationKind/hl7:code/@displayName)}</name>
               <labelName>
                  {
                    if (string-length($dispProduct/naam/etiket/text())>0) then
                     $dispProduct/naam/etiket/text()
                    else('VERVALLEN')
                   }
                </labelName>
               <description></description>
               <route>{$dispProduct/toedieningsweg/nm25/text()}</route>
            </product>
            {
            if ($dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:directTargetOf/hl7:prescription/hl7:reason) then
               <reason>
               {concat('Reden voorschrijven: ',$dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:directTargetOf/hl7:prescription/hl7:reason/hl7:diagnosisEvent/hl7:value/@displayName)}
               </reason>
            else()
            }
            <author>
            {
            $dispenseEvent/hl7:responsibleParty/hl7:assignedCareProvider
(:            local:getAssignedProviderNameAndType($dispenseEvent/hl7:responsibleParty/hl7:assignedCareProvider,$combinedBatches,$vocabulary):)
            }
            </author>
            <usage>{$dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:therapeuticAgentOf/hl7:medicationAdministrationRequest/hl7:text/text()}</usage>
         </medication>
         }
      </medication>
      }
   </medications>
   
let $medications := 
   <medications>
      {
      for $prescription in $preprocessedPrescriptions/medication[(@status='active' and not( successors/successor/@status='active')) or (@status='inactive' and not(successors))]
      return
      local:resolvePredecessors($prescription,$preprocessedPrescriptions)
      ,
      for $dispenseEvent in $combinedBatches//hl7:medicationDispenseEvent
      let $prescriptionRef := $dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:directTargetOf/hl7:prescription/hl7:id
      let $prescriptionIds := $combinedBatches//hl7:component/hl7:prescription/hl7:id
      let $dispEventProduct := local:getProduct($dispenseEvent)
      let $startDate := local:getDispenseEventStartDate($dispenseEvent)
      let $stopDate := local:getDispenseEventStopDate($dispenseEvent)
      where not(exists($prescriptionIds[@root=$prescriptionRef/@root and @extension=$prescriptionRef/@extension]))
      return
      <medication type="dispense" start="{$startDate}" stop="{$stopDate}" atc="{$dispEventProduct/@atcode}">
         <product>
            <name>
               {
               if (string-length($dispEventProduct/naam/volledig/text())>0) then
                  $dispEventProduct/naam/volledig/text()
               else(data($dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:MedicationKind/hl7:code/@displayName))
               }
            </name>
            <labelName>
               {
                 if (string-length($dispEventProduct/naam/etiket/text())>0) then
                  $dispEventProduct/naam/etiket/text()
                 else('VERVALLEN')
                }
             </labelName>
            <description>{$dispEventProduct/naam/omschrijving/text()}</description>
            <route>{$dispEventProduct/toedieningsweg/nm25/text()}</route>
         </product>
         {
         if ($dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:directTargetOf/hl7:prescription/hl7:reason) then
            <reason>
            {concat('Reden voorschrijven: ',$dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:directTargetOf/hl7:prescription/hl7:reason/hl7:diagnosisEvent/hl7:value/@displayName)}
            </reason>
         else()
         }
         <author>
         {
         local:getAssignedProviderNameAndType($dispenseEvent/hl7:responsibleParty/hl7:assignedCareProvider,$combinedBatches[1],$vocabulary)
         }
         </author>
         <usage>{$dispenseEvent/hl7:product/hl7:dispensedMedication/hl7:therapeuticAgentOf/hl7:medicationAdministrationRequest/hl7:text/text()}</usage>
      </medication>
      }
   </medications>

let $labresults :=
   <labresults>
   {
    for $labresult in $combinedBatches//hl7:observationEvent
    return
    <labresult>
    <lab>{$labresult/hl7:code/@displayName/string()}</lab>
    <date>{local:formatHL7Date($labresult/hl7:effectiveTime/@value)}</date>
    <interpretationCode code="{$labresult/hl7:interpretationCode/@code}" codeSystem="{$labresult/hl7:interpretationCode/@codeSystem}"/>
    <result>{local:processValue($labresult/hl7:value)}</result>
    <method>{$labresult/hl7:methodCode/@displayName}</method>
    <reference>
      {
      if ($labresult//hl7:interpretationRange[hl7:interpretationCode/@code='N']/hl7:value) then
      local:processValue($labresult//hl7:interpretationRange[hl7:interpretationCode/@code='N']/hl7:value)
      else()
      }
    </reference>
    </labresult>
   }
   </labresults>

let $medicationoverview := 
   <medicationOverview>
   {$patient,$conditions,$medications,$labresults}
   </medicationOverview>
   
let $xsltParameters :=	<parameters>
									<param name="referenceDateString" value="{$referenceDate}"/>
								</parameters>
return
(:$preprocessedPrescriptions:)
(:<unique>{$uniquePrescriptions}</unique>:)
(:$medicationoverview:)
transform:transform($medicationoverview, xs:anyURI(concat('xmldb:exist://',$get:strXisResources,'/stylesheets/','medication2html_2.xsl')), $xsltParameters)
