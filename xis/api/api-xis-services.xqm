xquery version "3.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)
module namespace adxss          = "http://art-decor.org/ns/art-decor-xis-services";

import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
declare namespace soap          = "http://schemas.xmlsoap.org/wsdl/soap/";
declare namespace wsdl          = "http://schemas.xmlsoap.org/wsdl/";
declare namespace xis           = "http://art-decor.org/ns/xis";

(:~
:   WSDLs come from all over the place and do not necessarily have the correct service/port/address/@location.
:   Services on this server need to be under http(s)://<servername>:<port>/xis/...
:   This base string is used when exposing, comparing etc.
:)
declare variable $adxss:baseServiceUri := 
    if (request:exists()) 
    then (concat(request:get-scheme(),'://',request:get-server-name(),':',request:get-server-port(),'/xis/'))
    else ('http://localhost:8877/xis/');

(:~
:   Returns a boolean on whether or not the service on the $uri is active on this server for at least one HL7 package. It does 
:   its comparison based on the final part in the path. URI is expected to come in without any query string
:
:   @param $uri The URI to check, without query string
:   @return true|false
:   @author Alexander Henket
:   @since 2014-06-05
:)
declare function adxss:isActive($uri as xs:anyURI) as xs:boolean {
    let $serviceUri     := replace($uri,'^https?:/+[^/]+/(xis/)?',$adxss:baseServiceUri)
    
    return
    exists(adxss:getActiveServices()/xis:service[@location=$serviceUri])
};

(:~
:   Returns an XML representation of active services
:   <services xmlns="http://art-decor.org/ns/xis">
:       <service name="AanmeldenGegevens_Service" location="http://localhost:8877/xis/AanmeldenGegevens" locationResource="AanmeldenGegevens"/>
:       <service name="Conditiesquery_Service" location="http://localhost:8877/xis/ConditiesqueryBatch" locationResource="ConditiesqueryBatch"/>
:       <service name="ZorgOverdrachtVerzoekJGZ_02_Service" location="http://localhost:8877/xis/02/ZorgOverdrachtVerzoekJGZ" locationResource="02/ZorgOverdrachtVerzoekJGZ"/>
:   </services>
:
:   @return <services xmlns="http://art-decor.org/ns/xis">(<service name="ServiceNameAsInWSDL" location="SoapAddressLocationUri" locationResource="SoapAddressLocationUriPath"/>)*</services>
:   @author Alexander Henket
:   @since 2014-06-05
:)
declare function adxss:getActiveServices() as element(xis:services) {
    let $services           := if (doc-available($get:strSoapServiceList)) then (doc($get:strSoapServiceList)/xis:services/xis:service) else ()
    let $currentServices    := collection($get:strHl7)//wsdl:service
    return
    <services xmlns="http://art-decor.org/ns/xis">
    {
        for $service in $services
        let $checkedServices :=
            if ($service[1]/@location and $service[1]/@name=$currentServices/@name) then (
                adxss:getAvailableServices((),$service[1]/@location)/xis:service
            )
            else ( 
                let $location           := 
                    if ($service[1]/@version[not(.='')]) 
                    then concat($adxss:baseServiceUri,$service[1]/@version,'/',$service[1]/@name) 
                    else concat($adxss:baseServiceUri,$service[1]/@name)
                let $locationResource   := 
                    if ($service[1]/@version[not(.='')]) 
                    then concat($service[1]/@version,'/',$service[1]/@name) 
                    else ($service[1]/@name)
                return
                if ($currentServices//soap:address[ends-with(@location,$locationResource)]) then
                    adxss:getAvailableServices((),$location)/xis:service
                else (
                    <no-match calculatedLocation="{$location}" calculatedLocationResource="{$locationResource}">{$service[1]}</no-match>
                )
            )
        group by $serviceUri := if ($service/@location) then $service/@location else concat($service/@name,$service/@version)
        order by $service[1]/@name
        return
            for $checkedService in $checkedServices
            group by $checkedServiceUri := $checkedService/@location
            order by $checkedService[1]/@name
            return
                if ($checkedService[1][local-name()='service']) 
                then (
                    <service>{$checkedService[1]/@name, $checkedService[1]/@location, $checkedService[1]/@locationResource}</service>
                )
                else (
                    $checkedService[1]
                )
   }
   </services>
};

(:~
:   Saves active services. Expects:
:       <service name="AanmeldenGegevens_Service" location="http://localhost:8877/xis/AanmeldenGegevens" locationResource="AanmeldenGegevens"/>
:       <service name="Conditiesquery_Service" location="http://localhost:8877/xis/ConditiesqueryBatch" locationResource="ConditiesqueryBatch"/>
:       <service name="ZorgOverdrachtVerzoekJGZ_02_Service" location="http://localhost:8877/xis/02/ZorgOverdrachtVerzoekJGZ" locationResource="02/ZorgOverdrachtVerzoekJGZ"/>
:
:   @param $activeServices (<service xmlns="http://art-decor.org/ns/xis" name="ServiceNameAsInWSDL" location="SoapAddressLocationUri" locationResource="SoapAddressLocationUriPath"/>)*
:   @author Alexander Henket
:   @since 2014-06-05
:)
declare function adxss:saveActiveServices($activeServices as element(xis:service)*) {
    let $prunedServices :=
        for $service in $activeServices
        group by $nameLocationResource := concat($service/@name,$service/@locationResource)
        return $service[1]
    return
    if (doc-available($get:strSoapServiceList)) then (
        update value doc($get:strSoapServiceList)//xis:services with $prunedServices
    )
    else (
        let $col := string-join(tokenize($get:strSoapServiceList,'/')[not(last())],'/')
        let $res := tokenize($get:strSoapServiceList,'/')[last()]
        return
        xmldb:store($col,$res,<services xmlns="http://art-decor.org/ns/xis">{$prunedServices}</services>)
    )
};

(:~
:   Returns an XML representation of available services
:
:   @return <services xmlns="http://art-decor.org/ns/xis">(<service name="ServiceNameAsInWSDL" location="SoapAddressLocationUri" locationResource="SoapAddressLocationUriPath"/>)*</services>
:   @author Alexander Henket
:   @since 2014-06-05
:   @see adxss:getAvailableServices($hl7ResourcePath as xs:string?)
:)
declare function adxss:getAvailableServices() as element(xis:services) {
    adxss:getAvailableServices(())
};

(:~
:   Returns an XML representation of available services, optionally filtered based on the resource path
:
:   @param $hl7ResourcePath e.g. /db/apps/hl7/jgz-test-20140528T125924. Empty means no filtering is applied
:   @return <services xmlns="http://art-decor.org/ns/xis">(<service name="ServiceNameAsInWSDL" location="SoapAddressLocationUri" locationResource="SoapAddressLocationUriPath"/>)*</services>
:   @author Alexander Henket
:   @since 2014-06-05
:   @see adxss:getAvailableServices($hl7ResourcePath as xs:string?, $uri as xs:string?)
:)
declare function adxss:getAvailableServices($hl7ResourcePath as xs:string?) as element(xis:services) {
    adxss:getAvailableServices($hl7ResourcePath,())
};

(:~
:   Returns an XML representation of available services, optionally filtered based on the resource path and/or service URI. Example:
:   <services xmlns="http://art-decor.org/ns/xis">
:       <service name="AppRegBewerken_GBO_Service" location="http://localhost:8877/xis/AppRegBewerken_GBO" locationResource="AppRegBewerken_GBO" hl7collection="/db/apps/hl7/jgz-test-20140528T125924" hl7collectionname="jgz-test-20140528T125924">
:           <operation name="AppRegBewerken_SysteemrolToevoegen" soapaction="urn:hl7-org:v3/AppRegBewerken_SysteemrolToevoegen" implemented="false" requiredTemplates="PRPM_IN908100NL02Response">
:               <input message="hl7:PRPM_IN908100NL02"/>
:               <output message="hl7:PRPM_IN908100NL02Response"/>
:           </operation>
:           <operation name="AppRegBewerken_SysteemrolWijzigen" soapaction="urn:hl7-org:v3/AppRegBewerken_SysteemrolWijzigen" implemented="false" requiredTemplates="PRPM_IN908200NL02Response">
:               <input message="hl7:PRPM_IN908200NL02"/>
:               <output message="hl7:PRPM_IN908200NL02Response"/>
:           </operation>
:           <operation name="AppRegBewerken_ApplicatieWijzigen" soapaction="urn:hl7-org:v3/AppRegBewerken_ApplicatieWijzigen" implemented="false" requiredTemplates="PRPM_IN908400NLResponse">
:               <input message="hl7:PRPM_IN908400NL"/>
:               <output message="hl7:PRPM_IN908400NLResponse"/>
:           </operation>
:       </service>
:       <service name="AppRegBewerken_Service" location="http://localhost:8877/xis/AppRegBewerken" locationResource="AppRegBewerken" hl7collection="/db/apps/hl7/jgz-test-20140528T125924" hl7collectionname="jgz-test-20140528T125924">
:           <operation name="AppRegBewerken_SysteemrolToevoegen" soapaction="urn:hl7-org:v3/AppRegBewerken_SysteemrolToevoegen" implemented="false" requiredTemplates="PRPM_IN908100NL02Response">
:               <input message="hl7:PRPM_IN908100NL02"/>
:               <output message="hl7:PRPM_IN908100NL02Response"/>
:           </operation>
:           <operation name="AppRegBewerken_SysteemrolWijzigen" soapaction="urn:hl7-org:v3/AppRegBewerken_SysteemrolWijzigen" implemented="false" requiredTemplates="PRPM_IN908200NL02Response">
:               <input message="hl7:PRPM_IN908200NL02"/>
:               <output message="hl7:PRPM_IN908200NL02Response"/>
:           </operation>
:           <operation name="AppRegBewerken_ApplicatieWijzigen" soapaction="urn:hl7-org:v3/AppRegBewerken_ApplicatieWijzigen" implemented="false" requiredTemplates="PRPM_IN908400NLResponse">
:               <input message="hl7:PRPM_IN908400NL"/>
:               <output message="hl7:PRPM_IN908400NLResponse"/>
:           </operation>
:       </service>
:       <service name="AppRegInteractieVersieOpvragen_GBO_Service" location="http://localhost:8877/xis/AppRegInteractieVersieOpvragen_GBO" locationResource="AppRegInteractieVersieOpvragen_GBO" hl7collection="/db/apps/hl7/jgz-test-20140528T125924" hl7collectionname="jgz-test-20140528T125924">
:           <operation name="AppRegInteractieVersieOpvragen_InteractieVersieOpvragen" soapaction="urn:hl7-org:v3/AppRegInteractieVersieOpvragen_InteractieVersieOpvragen" implemented="false" requiredTemplates="PRPM_IN907130NL">
:               <input message="hl7:PRPM_IN907030NL"/>
:               <output message="hl7:PRPM_IN907130NL"/>
:           </operation>
:       </service>
:       <service name="AppRegInteractieVersieOpvragen_Service" location="http://localhost:8877/xis/AppRegInteractieVersieOpvragen" locationResource="AppRegInteractieVersieOpvragen" hl7collection="/db/apps/hl7/jgz-test-20140528T125924" hl7collectionname="jgz-test-20140528T125924">
:           <operation name="AppRegInteractieVersieOpvragen_InteractieVersieOpvragen" soapaction="urn:hl7-org:v3/AppRegInteractieVersieOpvragen_InteractieVersieOpvragen" implemented="false" requiredTemplates="PRPM_IN907130NL">
:               <input message="hl7:PRPM_IN907030NL"/>
:               <output message="hl7:PRPM_IN907130NL"/>
:           </operation>
:       </service>
:   </services>
:
:   @param $hl7ResourcePath e.g. /db/apps/hl7/jgz-test-20140528T125924. Empty means no filtering is applied
:   @param $uri e.g. http://art-decor.org/xis/AanmeldenGegevens. Empty means no filtering is applied
:   @return <services xmlns="http://art-decor.org/ns/xis">(<service name="ServiceNameAsInWSDL" location="SoapAddressLocationUri" locationResource="SoapAddressLocationUriPath"/>)*</services>
:   @author Alexander Henket
:   @since 2014-06-05
:   @see adxss:getAvailableServices($hl7ResourcePath as xs:string?, $uri as xs:string?)
:)
declare function adxss:getAvailableServices($hl7ResourcePath as xs:string?, $uri as xs:string?) as element(xis:services) {
let $hl7ResourcePath    := if (empty($hl7ResourcePath)) then ($get:strHl7) else ($hl7ResourcePath)
let $uri                := if ($uri) then (replace($uri,'^https?:/+[^/]+/(xis/)?','')) else ()
return
<services xmlns="http://art-decor.org/ns/xis">
{
    for $endpoint in (collection($hl7ResourcePath)//wsdl:definitions/wsdl:service/wsdl:port/soap:address[not($uri)] |
                      collection($hl7ResourcePath)//wsdl:definitions/wsdl:service/wsdl:port/soap:address[replace(@location,'^https?:/+[^/]+/(xis/)?','')=$uri])
    (:output e.g.: /db/apps/hl7/jgz-20131008T222300 :)
    let $resourcePath       := replace(util:collection-name($endpoint),concat('(',$get:strHl7,'/[^/]+)/.*'),'$1')
    (:output e.g.: jgz-20131008T222300 :)
    let $resourceName       := tokenize($resourcePath,'/')[last()]
    (:output is a sequence of root elements that could serve as send/receive template:)
    let $messageTemplates   := 
        if (xmldb:collection-available(concat($resourcePath,'/message-templates')))
        then collection(concat($resourcePath,'/message-templates'))/*/local-name()
        else ()
    
    let $definition         := $endpoint/ancestor::wsdl:definitions
    let $serviceName        := $endpoint/ancestor::wsdl:service/@name
    (:  input e.g.  http:/www.xis.nl/Conditiesquery
        output e.g. http://localhost:8877/xis/Conditiesquery
    :)
    let $portUri            := replace($endpoint/@location,'^https?:/+[^/]+/(xis/)?',$adxss:baseServiceUri)
    (:  input e.g.  http:/www.xis.nl/Conditiesquery
        output e.g. Conditiesquery
    :)
    let $portResource       := replace($endpoint/@location,'^https?:/+[^/]+/(xis/)?','')
    let $portBinding        := replace($endpoint/parent::wsdl:port/@binding,'^.*:','')
    
    order by lower-case($serviceName)
    return
        <service name="{$serviceName}" location="{$portUri}" locationResource="{$portResource}" hl7collection="{$resourcePath}" hl7collectionname="{$resourceName}">
        {
            for $operation in $definition/wsdl:binding[@name=$portBinding]/wsdl:operation
            let $operationName          := $operation/@name
            let $soapBindingStyle       := $operation/../soap:binding/@style
            let $soapBindingsTransport  := $operation/../soap:binding/@transport
            let $soapAction             := $operation/soap:operation/@soapAction
            let $bindingType            := replace($operation/parent::wsdl:binding/@type,'^.*:','')
            let $portTypeOperation      := $definition/wsdl:portType[@name=$bindingType]/wsdl:operation[@name=$operationName]
            let $requiredTemplates      := $portTypeOperation/wsdl:output/@message/replace(.,'^.*:','')
            let $implemented            := $requiredTemplates=$messageTemplates
            return
                <operation name="{$operationName}" soapaction="{$soapAction}">
                {
                    (:attribute soapbindingstyle {$soapBindingStyle},
                    attribute soapbindingtransport {$soapBindingsTransport},
                    attribute bindingType {$bindingType},:)
                    attribute {'implemented'} {$implemented},
                    attribute {'requiredTemplates'} {string-join($requiredTemplates,' ')},
                    for $input in $portTypeOperation/wsdl:input
                    return
                        <input message="{$input/@message}"/>
                    ,
                    for $output in $portTypeOperation/wsdl:output
                    return
                        <output message="{$output/@message}"/>
                }
                </operation>
        }
        </service>
}
</services>
};
