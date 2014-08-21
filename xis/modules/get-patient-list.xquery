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
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
declare namespace hl7       = "urn:hl7-org:v3";

declare function local:formatHL7Date($dateString as xs:string) as xs:string {
    if (string-length($dateString)>0) then
        concat(substring($dateString,7,2),'-',substring($dateString,5,2),'-',substring($dateString,1,4))
    else('')
};

declare function local:formatHL7Name($hl7Name as element()) as xs:string {
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

};
let $account := request:get-parameter('account','')

let $xmlPath := 
   if (string-length($account)>0) then
      concat($get:strXisAccounts, '/',$account,'/messages')
   else()
(: need to login because user credentials are not passed with call:)
let $login      := xmldb:authenticate("/db", "xis-webservice", "webservice-xs2messages")
let $patientIds := distinct-values(collection($xmlPath)//hl7:Patient/hl7:id[@root='2.16.840.1.113883.2.4.6.3']/@extension|collection($xmlPath)//hl7:patient/hl7:id[@root='2.16.840.1.113883.2.4.6.3']/@extension)
let $patients   := 
    for $id in $patientIds
    let $patientSequence := collection($xmlPath)//hl7:Patient[hl7:id/@extension=$id][hl7:id/@root='2.16.840.1.113883.2.4.6.3']|collection($xmlPath)//hl7:patient[hl7:id/@extension=$id][hl7:id/@root='2.16.840.1.113883.2.4.6.3']
    return
        $patientSequence[hl7:Person/hl7:name][1]
return
<patients>
{
    for $patient in $patients
    let $prescriptionLists := collection($xmlPath)//hl7:MedicationPrescriptionList[hl7:subject/hl7:Patient/hl7:id[@extension=$patient/hl7:id/@extension and @root=$patient/hl7:id/@root]]
    let $dispenseLists := collection($xmlPath)//hl7:MedicationDispenseList[hl7:subject/hl7:Patient/hl7:id[@extension=$patient/hl7:id/@extension and @root=$patient/hl7:id/@root]]
    let $observationReports := collection($xmlPath)//hl7:subject/hl7:observationReport[hl7:recordTarget/hl7:patient/hl7:id[@extension=$patient/hl7:id/@extension and @root=$patient/hl7:id/@root]]
    order by $patient/hl7:Person/hl7:name/hl7:family[1]
    return
        <patient>
            <name>{local:formatHL7Name($patient/hl7:Person/hl7:name)}</name>
            <bsn>{$patient/hl7:id[@root='2.16.840.1.113883.2.4.6.3']/@extension/string()}</bsn>
            <birthDate>{local:formatHL7Date($patient/hl7:Person/hl7:birthTime/@value)}</birthDate>
            <gender>
            {if ($patient/hl7:Person/hl7:administrativeGenderCode/@code='M') then
                'M'
            else if ($patient/hl7:Person/hl7:administrativeGenderCode/@code='F') then
                'V'
            else('Onbekend')}
            </gender>
            <conditions>{count(collection($xmlPath)//hl7:Condition[hl7:subject/hl7:patient/hl7:id[@extension=$patient/hl7:id/@extension and @root=$patient/hl7:id/@root]])}</conditions>
            <prescriptions>{count($prescriptionLists//hl7:prescription)}</prescriptions>
            <dispenseEvents>{count($dispenseLists//hl7:medicationDispenseEvent)}</dispenseEvents>
            <labresults>{count($observationReports//hl7:observationEvent)}</labresults>
        </patient>
}
</patients>
