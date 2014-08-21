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
import module namespace get  = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
declare namespace xis        = "http://art-decor.org/ns/xis";
declare namespace datetime   = "http://exist-db.org/xquery/datetime";
declare namespace httpclient = "http://exist-db.org/xquery/httpclient";
declare namespace request    = "http://exist-db.org/xquery/request";
declare namespace hl7        = "urn:hl7-org:v3";
declare namespace soap       = "http://schemas.xmlsoap.org/soap/envelope/";

(: Log debug messages? :)
declare variable $debug     := false();

let $messageInfo            := request:get-data()/message

let $account                := $messageInfo/@account
let $configuration          := doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:xis
let $resourcesPath          := $configuration/xis:xmlResourcesPath

let $g                      := if ($debug) then (util:log('DEBUG', concat('======xis-send-message.xquery====== Message info: ',$account, ' resourcePath: ', $resourcesPath))) else ()
let $g                      := if ($debug) then (util:log('DEBUG', <i>======xis-send-message.xquery====== $messageInfo: {$messageInfo}</i>)) else ()

(: path where messages are stored :)
let $messageStoragePath     := concat($get:strXisAccounts, '/',$account,'/messages')

let $messageTemplateFile    := concat($resourcesPath,'/message-templates/',$messageInfo/@interactionId,'.xml')
let $messageId              := $messageInfo/@id
let $applicationId          := $configuration/xis:applicationId
let $systemCertificateId    := $configuration/xis:systemCertificateId
let $messageIdRoot          := concat('2.16.840.1.113883.2.4.6.6.',$applicationId)
let $receiverId             := $messageInfo/receiver/@applicationId
let $receiverUrl            := concat($messageInfo/receiver/@url,$messageInfo/@endpoint)
let $receiverRegisterId     := if (string-length($messageInfo/receiver/@organizationRegisterId)>0) then
                                    $messageInfo/receiver/@organizationRegisterId
                                 else '12345678'
let $authorId               := $messageInfo/uziInfo/uziNumber/text()
let $authorName             := $messageInfo/uziInfo/subjectName/text()
let $authorRoleCode         := $messageInfo/uziInfo/roleCode/text()
let $authorRole             := $messageInfo/uziInfo/subjectTitle/text()
let $organizationId         := $messageInfo/uziInfo/uraNumber/text()
let $organizationName       := $messageInfo/uziInfo/subjectOrganisation/text()
let $organizationCode       := $configuration/xis:organizationRoleCode/@code
let $organizationCodeName   := $configuration/xis:organizationRoleCode/@displayName
let $organizationCity       := $configuration/xis:organizationCity/text()
let $controlActFileExists   := doc-available(xmldb:encode($messageInfo/@payloadFile))
let $controlActFile         := if ($controlActFileExists) then (doc(xmldb:encode($messageInfo/@payloadFile))) else ()
let $patientId              := 
    if (string-length(normalize-space(($messageInfo/patientId/text())[1]))>0) then
        ($messageInfo/patientId/text())[1]
    else if ($controlActFileExists) then (
        if (exists($controlActFile//hl7:attentionLine[hl7:keyWordText[@code='PATID'][@codeSystem='2.16.840.1.113883.2.4.15.1']])) then
            ($controlActFile//hl7:attentionLine[hl7:keyWordText[@code='PATID'][@codeSystem='2.16.840.1.113883.2.4.15.1']]/hl7:value/@extension/string())[1]
        else (
            ($controlActFile//hl7:ControlActProcess/hl7:subject//hl7:*[@root='2.16.840.1.113883.2.4.6.3']/@extension/string())[1]
        )
    )
    else ()
let $parsedAuthorName       :=
    <name xmlns="urn:hl7-org:v3">
        <given>{substring-before($authorName,' ' )}</given>
        {if (contains(tokenize($authorName,'\s'),'van')) then
            <prefix qualifier="VV">van </prefix>
         else ()
        }
        <family qualifier="BR">{tokenize($authorName,'\s')[last()]}</family>
    </name>
let $queryParameters        := $messageInfo/parameters

(: this variable is used as subject in the message template, for instance: /db/apps/hl7/AORTA_v61000/message-templates/PORX_IN932000NL.xml :)

let $controlActSubjects     :=
    if ($controlActFileExists) then
        util:eval(util:serialize($controlActFile//hl7:ControlActProcess,'method=xml'))/hl7:subject
    else ()
    
(: this variable can be used in the message template, for instance: /db/apps/hl7/AORTA_v61000/message-templates/PORX_IN932000NL.xml :)
let $attentionLine          := $controlActFile//hl7:attentionLine
let $collection             := concat($get:strXisAccounts, '/',$account,'/messages')
let $requestHeaders         := <headers><header name="SOAPAction" value="""{$messageInfo/@soapAction}"""/><header name="Content-Type" value="text/xml"/></headers>

let $g                      := if (exists($controlActSubjects)) then util:log('DEBUG', concat('======xis-send-message.xquery====== controlActSubjects node: ',string-join($controlActSubjects/*/local-name(),' '))) else ()
let $g                      := util:log('DEBUG', concat('======xis-send-message.xquery====== saving into collection: ',$collection))
let $g                      := util:log('DEBUG', concat('======xis-send-message.xquery====== Before util:eval: ',$messageTemplateFile))
let $g                      := util:log('DEBUG', concat('======xis-send-message.xquery====== Before util:eval. doc-available? ',doc-available($messageTemplateFile)))

let $hl7message             := util:eval(util:serialize(doc($messageTemplateFile),'method=xml'))

let $g                      := util:log('DEBUG', concat('======xis-send-message.xquery====== After util:eval: ',$messageTemplateFile))

let $soapMessage :=
   <soap:Envelope>
      <soap:Body>
         {$hl7message}
      </soap:Body>
   </soap:Envelope>
   
let $g                      := util:log('DEBUG', concat('======xis-send-message.xquery====== Posting to URL: ',$receiverUrl))

let $response               := httpclient:post(xs:anyURI($receiverUrl), $soapMessage, false(),$requestHeaders)

(: check return status. If not 200, not OK :)
let $result                 := 
    if ($response/@statusCode != 200) then
        $response
    else
        $response//httpclient:body/*

(: location where messages are stored :)
let $instancesPath          := $messageStoragePath
(: get all the logged messages. If we just sent a message to our own server, this will include a message with that messageId :)
let $messages               := collection($instancesPath)//*[hl7:interactionId or self::hl7:ClinicalDocument[not(hl7:text)] or string(@representation)='B64' or string(@xsi:type)='xs:base64Binary']
(: filter out the message matching the same messageId we just sent :)
let $matchingMessages       := $messages//*[@extension=$messageId]

(: if there was a matching message (already stored by SOAP-reponse.xquery) then set variable to false :)
let $storeMessageBoolean    := if ($matchingMessages) then false() else true()

let $g                      := util:log('DEBUG', concat('======xis-send-message.xquery====== Message to send: ',$soapMessage))

(: store outgoing message :)
let $store                  := 
    if ($storeMessageBoolean) then
        xmldb:store($messageStoragePath, concat(util:uuid(),'.xml'),$soapMessage)
    else ()

(: store incoming response including headers :)
let $responseStore          := 
    if ($storeMessageBoolean) then 
        xmldb:store($messageStoragePath, concat(util:uuid(),'.xml'),$response)
    else ()

return
$result