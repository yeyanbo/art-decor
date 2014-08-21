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

declare namespace hl7  = "urn:hl7-org:v3";
declare namespace xs   = "http://www.w3.org/2001/XMLSchema";
declare namespace soap = "http://schemas.xmlsoap.org/wsdl/soap/";
declare namespace wsdl = "http://schemas.xmlsoap.org/wsdl/";
declare namespace xis  = "http://art-decor.org/ns/xis";

let $account           := if (request:exists()) then request:get-parameter('account','') else ()
(:let $account           := 'art-decor':)
let $resourcesPath     := doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:xis/xis:xmlResourcesPath/text()
let $messageTemplates  := collection(concat($resourcesPath,'/message-templates'))/*
let $interactionFile   := concat($get:strXisResources, '/vocab/2.16.840.1.113883.1.6.xml')

return
<messageTemplates account="{$account}" resourcesPath="{$resourcesPath}">
{

for $template in $messageTemplates
let $authorType     :=
    if (not(exists($template/hl7:*[lower-case(local-name())='controlactprocess']))) then
        'none'
    else if (exists($template/hl7:*[lower-case(local-name())='controlactprocess']/hl7:authorOrPerformer//hl7:*[lower-case(local-name())='assigneddevice'])) then
        'device'
    else (
        'person'
    )
let $messageName    := doc($interactionFile)//hl7:code[@code=$template/local-name()]/@displayName
let $operations     := collection($resourcesPath)//wsdl:operation[wsdl:input/@message=concat('hl7:',$template/local-name())]

let $messageSchema  := collection(concat($resourcesPath,'/schemas_codeGen_flat'))//xs:schema[xs:element[@name=$template/local-name()]]
let $messageType    := $messageSchema/xs:element[@name=$template/local-name()]/@type/string()
let $controlAct     := 
    if (exists($messageSchema//xs:complexType[@name=$messageType]//xs:group[@ref='ControlAct'])) then (
        $messageSchema//xs:group[@name='ControlAct']//xs:element[@name='ControlActProcess']/@type/string()
    ) else if (exists($messageSchema//xs:complexType[@name=$messageType]//xs:element[@name='ControlActProcess'])) then (
        $messageSchema//xs:complexType[@name=$messageType]//xs:element[@name='ControlActProcess']/@type/string()
    ) else ()
let $subject        :=
    if (exists($messageSchema//xs:complexType[@name=$controlAct]//xs:element[@name='subject'])) then (
        $messageSchema//xs:complexType[@name=$controlAct]//xs:element[@name='subject']/@type/string()
    ) else ()
let $payload        := 
    if (exists($messageSchema//xs:complexType[@name=$subject]//xs:group[@ref='Payload'])) then (
        $messageSchema//xs:group[@name='Payload']//xs:element/@name/string()
    ) else if (exists($messageSchema//xs:complexType[@name=$subject]//xs:element)) then (
        $messageSchema//xs:complexType[@name=$subject]//xs:element/@name/string()
    ) else if (exists($messageSchema//xs:complexType[@name=$controlAct]//xs:element[@name='queryByParameter'])) then (
        $messageSchema//xs:complexType[@name=$controlAct]//xs:element[@name='queryByParameter']/@name/string()
    ) else ()
where $operations
order by lower-case($template)
return
<messageTemplate interactionId="{$template/local-name()}" name="{$messageName}" authortype="{$authorType}" payload="{$payload}">
{


for $operation in $operations
let $soapAction       := collection($resourcesPath)//wsdl:binding/wsdl:operation[@name=$operation/@name]/soap:operation/@soapAction
let $wsdlBindingName  := collection($resourcesPath)//wsdl:binding[wsdl:operation[@name=$operation/@name]]/@name/string()
(: at this point there should only one endpoint, but who knows... throw away URI scheme, hostname and port so we are only left with the path in the URI :)
let $endpoint         := replace(string-join(collection($resourcesPath)//wsdl:service/wsdl:port[ends-with(@binding,$wsdlBindingName)]/soap:address/@location/string(),' '),'https?://?[^/]+','')
return
<operation name="{$operation/@name}" soapAction="{$soapAction[1]}" endpoint="{tokenize($endpoint,' ')[1]}" endpoints="{$endpoint}">
<!-- @endpoint contains the chosen endpoint, while @endpoints contains the full list (batch, non batched etc.) -->
<input message="{$operation/wsdl:input/@message}"/>
<output message="{$operation/wsdl:output/@message}"/>
</operation>
,
for $messagePayload in collection($resourcesPath)//*[hl7:interactionId/@extension=$template/local-name()][hl7:ControlActProcess/hl7:subject]
order by $messagePayload
return
<payload file="{xmldb:decode(util:document-name($messagePayload))}" fullPath="{concat(util:collection-name($messagePayload),'/',xmldb:decode(util:document-name($messagePayload)))}"/>
}
</messageTemplate>
}
</messageTemplates>