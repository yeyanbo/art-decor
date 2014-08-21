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
(:import module namespace atp  ="urn:nictiz.atp" at "atpFunctions.xqm";:)

declare namespace xis        ="http://art-decor.org/ns/xis";
declare namespace hl7        ="urn:hl7-org:v3";
declare namespace soap       ="http://schemas.xmlsoap.org/soap/envelope/";
declare namespace wsdlsoap   ="http://schemas.xmlsoap.org/wsdl/soap/";
declare namespace wsdl       ="http://schemas.xmlsoap.org/wsdl/";
declare namespace datetime   ="http://exist-db.org/xquery/datetime";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no";

(: Log debug messages? :)
declare variable $debug       := false();

declare function local:loopMessage($matchingMessages as element(), $message as element()) {
   (: get next /message :)
   let $followingNode   := <messageFilter>{$matchingMessages/message[position()>1]}</messageFilter>
   
   (: what is the current message filter we are processing :)
   let $thisMessage     := $matchingMessages/message[1]
   let $parameters      := <queryParameters>{$thisMessage//queryParameters/parameter}</queryParameters>
   let $checkParameters := local:returnNode($parameters,$matchingMessages,$message)

   return
   (: if returnNode does return false, there is no match yet :)
   (: continue with next /message filter :)
      if (matches($checkParameters,'false')) then
         (: if there is a following message :)
         if ($followingNode/node()) then
            local:loopMessage($followingNode,$message)
         else
            ()
      else 
         (: all queryParameters in the /message filter match, so return responseTemplateFile :)
         ($checkParameters)
};

declare function local:returnNode($node as element(),$matchingMessage as element(),$message as element()) {
   (: $node = parameter from messageFilter_manifest :)
   (: <parameter name="patientId" value="555555112">//*:queryByParameter/*:patientId/*:value[@root='2.16.840.1.113883.2.4.6.3']/@extension</parameter> :)
   let $followingNode := <queryParameters>{$node/parameter[position()>1]}</queryParameters>
   
   (: filter the incoming message by XPATH to the patientId, or other node we want to match with a messageFilter parameter value (configured in /hl7/../message-templates/messageFilter_manifest.xml)
      if the filter parameter = <parameter name="patientId" value="100040007">//*:queryByParameter/*:patientId/*:value[@root='2.16.840.1.113883.2.4.6.3']/@extension</parameter>
      and the incoming SOAP message has queryByParameter/patientId/value/@extension="555555112"
      the outcome is 555555112 (the patient identifier)
   :)
   let $g := if ($debug) then (util:log('DEBUG', '======SOAP-response.xquery====== string($node/parameter[1]): ')) else ()
   let $g := if ($debug) then (util:log('DEBUG', string($node/parameter[1]))) else ()
   let $message_xpath := util:eval(concat('$message',string($node/parameter[1])))
   let $g := if ($debug) then (util:log('DEBUG', '======SOAP-response.xquery====== $message_xpath: ')) else ()
   let $g := if ($debug) then (util:log('DEBUG', $message_xpath)) else ()
   return
   (: check if incoming node (patientId, ..) matches the parameter/@value from the filter parameter :)
   if (matches($message_xpath,$node//parameter[1]/@value)) then
            (: if there is a following node, see if that parameter matches also :)
            if ($followingNode//parameter) then local:returnNode($followingNode,$matchingMessage,$message)
            else
               <value>{($matchingMessage//responseTemplateFile/@value)[1]}</value>
   (: else: false :)
   else ('false')
};

(:
    Universal SOAP response stub
    Known issue: for services that define an <InputInteraction>Response element, this setup will fail, 
    for one because we can't compute which is the accept and which the reject message. Need special setup....
:)
let $login            := xmldb:login('/db', 'xis-webservice', 'webservice-xs2messages')

let $g := if ($debug) then (util:log('DEBUG', '======SOAP-response.xquery====== start of script')) else ()
let $soapRequest      := request:get-data()/soap:Envelope
let $soapService      := request:get-parameter('service','')
let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $soapService: ',$soapService))) else ()
return 
if (empty($soapRequest)) then (
    response:set-status-code(500), response:set-header('Content-Type','text/xml; charset=utf-8'), 
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
                <soap:Fault>
                    <faultcode>soap:Client</faultcode>
                    <faultstring>Service {$soapService} requires soap:Envelope</faultstring>
                    <faultactor>http://decor.nictiz.nl/actor/zim</faultactor>
                    <detail>
                        <zim:text xmlns:zim="http://decor.nictiz.nl/actor/zim/soapFault/detail">Service {$soapService} requires soap:Envelope. Please update the contents of your HTTP request.</zim:text>
                    </detail>
                </soap:Fault>
            </soap:Body>
        </soap:Envelope>
) else (
    (: this parameter, if false, will lead to an HTTP 500 SOAP:Fault that says unsupported service. This parameter may be set through the controller.xql :)
    let $supportedService := request:get-parameter('supported','true')
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $soapAction: ',request:get-header('SOAPAction')))) else ()
    let $soapAction       := substring(request:get-header('SOAPAction'),2,string-length(request:get-header('SOAPAction'))-2) (:SOAPAction is wrapped in double quotes:)
    let $message          := $soapRequest//soap:Body/*
    let $rootElement      := $soapRequest//soap:Body/hl7:*/local-name()
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $rootElement: ',$rootElement))) else ()
    let $interactionId    := ($soapRequest//soap:Body/hl7:*/hl7:interactionId[@root='2.16.840.1.113883.1.6'])[1]/@extension/string()
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $interactionId: ',$interactionId))) else ()
    
    (: get sender and receiver application ids to determine account for configuration and message storage:)
    let $senderId         := $soapRequest//soap:Body/hl7:*/hl7:sender/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension/string()
    let $receiverId       := $soapRequest//soap:Body/hl7:*/hl7:receiver/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension/string()
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $senderId: ',$senderId))) else ()
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $receiverId: ',$receiverId))) else ()
    
    (: find account, default account = art-decor :)
    let $account := 
       if (doc($get:strTestAccounts)//xis:application[@id=($senderId,$receiverId)]/parent::xis:testAccount/@name) then
          doc($get:strTestAccounts)//xis:application[@id=($senderId,$receiverId)][1]/parent::xis:testAccount/@name/string()
       else ('art-decor')
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $account: ',$account))) else ()
    
    let $messageStoragePath := concat($get:strXisAccounts, '/',$account,'/messages')
    let $config             := doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:xis
    let $resourcesPath      := $config/xis:xmlResourcesPath
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $messageStoragePath: ',$messageStoragePath))) else ()
    let $g := if ($debug) then (util:log('DEBUG', '======SOAP-response.xquery====== $config: ')) else ()
    let $g := if ($debug) then (util:log('DEBUG', $config)) else ()
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $resourcesPath: ',$resourcesPath))) else ()

    (: wsdl file -- note: this fails in case there is more than one match for a given SOAPAction ... :)
    let $wsdlContent        := (collection($resourcesPath)/wsdl:definitions[.//wsdlsoap:address[ends-with(@location/string(),$soapService)]][.//wsdl:operation/wsdl:input[@message/string()=concat('hl7:',$interactionId)]])[1]
    let $g := if ($debug) then (util:log('DEBUG', '======SOAP-response.xquery====== $wsdlContent: ')) else ()
    let $g := if ($debug) then (util:log('DEBUG', $wsdlContent)) else ()
    
    (: resolve SOAPAction into the correct operation name :)
    (:/wsdl:definitions/wsdl:binding[1]/wsdl:operation[1]/@name:)
    let $operationName      := $wsdlContent//wsdl:binding/wsdl:operation[wsdlsoap:operation/@soapAction=$soapAction]/@name/string()
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $operationName: ',$operationName))) else ()
    (: get list of valid input messages for this service based on SOAPAction :)
    let $inputInOperation   := count($wsdlContent//wsdl:portType/wsdl:operation[@name/string()=$operationName]/wsdl:input[@message=concat('hl7:',$rootElement)])>0
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $inputInOperation: ',$inputInOperation))) else ()
    
    (: get list of valid output messages for this service based on SOAPAction :)        
    let $outputMessage      := substring-after(($wsdlContent//wsdl:portType/wsdl:operation[@name/string()=$operationName][wsdl:input[@message=concat('hl7:',$rootElement)]]/wsdl:output/@message)[1],'hl7:')
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $outputMessage: ',$outputMessage))) else ()

    (: load an optional messageFilter :)
    let $messageFilter := 
        if (doc(concat($resourcesPath,'/message-templates/messageFilter_manifest','.xml'))) then
           doc(concat($resourcesPath,'/message-templates/messageFilter_manifest','.xml'))
        else ()
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $messageFilter present?: ',string-length($messageFilter)>0))) else ()
    let $g := util:log-system-out(concat('======SOAP-response.xquery====== $messageFilter present?: ',string-length($messageFilter)>0))
    
    (: get message filters that are active and match the incoming rootElement :)    
    let $matchingMessages := 
        <messageFilter>
        {
            $messageFilter//message[@active="true"][@interactionId=$rootElement][@soapAction=$soapAction] |
            $messageFilter//message[@active="true"][@interactionId=$rootElement][not(@soapAction)]
        }
        </messageFilter>
    (: test which message filter parameters match the payload of the incoming message :) 
    let $messageFilterOutput := 
        if ($messageFilter and $matchingMessages//message) then
           local:loopMessage($matchingMessages,$message)
        else ()
    let $g := if ($debug) then (util:log('DEBUG', concat('======SOAP-response.xquery====== $messageFilterOutput: ',$messageFilterOutput))) else ()

    (: file that contains the response template. pretty rudimentarily based on the output message in the wsdl :)        
    let $responseTemplateFile := 
        (: check if there is messageFilter output :)
           if ($messageFilterOutput/@value) then
               (: outputMessage is output from first filter that matches :)
               concat($resourcesPath,'/message-templates/',string($messageFilterOutput/@value))
           else
               (: if the response is a batch, look for a message template in this form: MCCI_IN200101_<input message>.xml :) 
               (: for instance: /hl7/AORTA_trunk/message-templates/MCCI_IN200101_QURX_IN990111NL.xml :)
               if ($outputMessage = 'MCCI_IN200101') then
                  concat($resourcesPath,'/message-templates/',$outputMessage,'_',$rootElement,'.xml')
               else concat($resourcesPath,'/message-templates/',$outputMessage,'.xml')

    (: respond if request is valid for this service:)
    let $responseGiven := false()
    let $response := 
        if ($supportedService!='true') then (
            response:set-status-code(500), response:set-header('Content-Type','text/xml; charset=utf-8'), <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                <soap:Body>
                    <soap:Fault>
                        <faultcode>soap:Client</faultcode>
                        <faultstring>Service {$soapService} is not (yet) supported</faultstring>
                        <faultactor>http://decor.nictiz.nl/actor/zim</faultactor>
                        <detail>
                            <zim:text xmlns:zim="http://decor.nictiz.nl/actor/zim/soapFault/detail">Service {$soapService} is not (yet) supported. Please check with your administrator if this service is a /zim service rather than a /xis service or what a valid value for the parameter 'service' is.</zim:text>
                        </detail>
                    </soap:Fault>
                </soap:Body>
            </soap:Envelope>
        ) else if (empty($rootElement) or $rootElement = '') then (
            response:set-status-code(500), response:set-header('Content-Type','text/xml; charset=utf-8'), <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                <soap:Body>
                    <soap:Fault>
                        <faultcode>soap:Client</faultcode>
                        <faultstring>The input document is not in the HL7 V3 namespace</faultstring>
                        <faultactor>http://decor.nictiz.nl/actor/zim</faultactor>
                        <detail>
                            <zim:text xmlns:zim="http://decor.nictiz.nl/actor/zim/soapFault/detail">There's no element in the HL7 V3 namespace ('urn:hl7-org:v3') under the SOAP:Body element</zim:text>
                        </detail>
                    </soap:Fault>
                </soap:Body>
            </soap:Envelope>
        ) else if (empty($interactionId) or $rootElement != $interactionId) then (
            response:set-status-code(500), response:set-header('Content-Type','text/xml; charset=utf-8'), <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                <soap:Body>
                    <soap:Fault>
                        <faultcode>soap:Client</faultcode>
                        <faultstring>The input document root element and the interactionId do not match</faultstring>
                        <faultactor>http://decor.nictiz.nl/actor/zim</faultactor>
                        <detail>
                            <zim:text xmlns:zim="http://decor.nictiz.nl/actor/zim/soapFault/detail">The element name '{$rootElement}' under soap:Body does not match the value in interactionId[@root='2.16.840.1.113883.1.6']/@extension '{$interactionId}'</zim:text>
                        </detail>
                    </soap:Fault>
                </soap:Body>
            </soap:Envelope>
        ) else if (empty($wsdlContent)) then (
            response:set-status-code(500), response:set-header('Content-Type','text/xml; charset=utf-8'), <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                <soap:Body>
                    <soap:Fault>
                        <faultcode>soap:Client</faultcode>
                        <faultstring>Service {$soapService} with interaction {$interactionId} is not supported in account '{$account}'</faultstring>
                        <faultactor>http://decor.nictiz.nl/actor/zim</faultactor>
                        <detail>
                            <zim:text xmlns:zim="http://decor.nictiz.nl/actor/zim/soapFault/detail">There's no WSDL for the service {$soapService} in the resources for the account '{$account}' [default value]. If this is not the expected account, please check the application ID in */sender/device/id[@root='2.16.840.1.113883.2.4.6.6']/@extension. If this is the correct account, please check the service URI and the interaction ID in */interactionId[@root='2.16.840.1.113883.1.6']/@extension.</zim:text>
                        </detail>
                    </soap:Fault>
                </soap:Body>
            </soap:Envelope>
        ) else if (empty($operationName) or $operationName = '') then (
            response:set-status-code(500), response:set-header('Content-Type','text/xml; charset=utf-8'), <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                <soap:Body>
                    <soap:Fault>
                        <faultcode>soap:Client</faultcode>
                        <faultstring>There's no binding/operation with the SOAPAction {$soapAction} in the service {$soapService}</faultstring>
                        <faultactor>http://decor.nictiz.nl/actor/zim</faultactor>
                        <detail>
                            <zim:text xmlns:zim="http://decor.nictiz.nl/actor/zim/soapFault/detail">There's no binding/operation with the SOAPAction {$soapAction} in the service {$soapService}. Please check the SOAPAction.</zim:text>
                        </detail>
                    </soap:Fault>
                </soap:Body>
            </soap:Envelope>
        ) else if ($inputInOperation = false()) then (
            response:set-status-code(500), response:set-header('Content-Type','text/xml; charset=utf-8'), <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                <soap:Body>
                    <soap:Fault>
                        <faultcode>soap:Client</faultcode>
                        <faultstring>The input document {$rootElement} does not match the operation with SOAPAction {$soapAction}</faultstring>
                        <faultactor>http://decor.nictiz.nl/actor/zim</faultactor>
                        <detail>
                            <zim:text xmlns:zim="http://decor.nictiz.nl/actor/zim/soapFault/detail">The input document {$rootElement} does not match the operation {$operationName} and SOAPAction {$soapAction}. Please check the combination of interaction and SOAPAction.</zim:text>
                        </detail>
                    </soap:Fault>
                 </soap:Body>
            </soap:Envelope>
        ) else if (not(doc-available($responseTemplateFile))) then (
            response:set-status-code(500), response:set-header('Content-Type','text/xml; charset=utf-8'), <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                <soap:Body>
                    <soap:Fault>
                        <faultcode>soap:Server</faultcode>
                        <faultstring>Service {$soapService} has not yet been configured (correctly). Reply message template is missing: {$responseTemplateFile}</faultstring>
                        <faultactor>http://decor.nictiz.nl/actor/zim</faultactor>
                        <detail>
                            <zim:text xmlns:zim="http://decor.nictiz.nl/actor/zim/soapFault/detail">Service {$soapService} has not yet been configured (correctly). Reply message template is missing: {$responseTemplateFile}.</zim:text>
                        </detail>
                    </soap:Fault>
                </soap:Body>
            </soap:Envelope>
        ) else (
            let $store            := xmldb:store($messageStoragePath, concat(util:uuid(),'.xml'),$soapRequest)
            let $applicationId    := $config/xis:applicationId
            let $messageIdRoot    := concat('2.16.840.1.113883.2.4.6.6.',$applicationId)
            (:let $validationReport := atp:validate-message($message,$resourcesPath):)
            let $validationReport := ''
            (:let $valid            := if ($validationReport//error) then false() else (true()):)
            let $valid            := true()
            
            return
                <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                    <soap:Body>
                        {
                            util:eval-inline($message,util:serialize(doc($responseTemplateFile)/*,'method=xml'))
                        }
                    </soap:Body>
                </soap:Envelope>
        )
        
    let $responseStore := 
        if ($response//soap:Body) then (
            xmldb:store($messageStoragePath, concat(util:uuid(),'.xml'),$response)
        ) else ()
    
    return
        $response
)