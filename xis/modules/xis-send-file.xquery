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

declare namespace soap="http://schemas.xmlsoap.org/soap/envelope/";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";

let $account        := request:get-parameter('account','')
let $file           := xmldb:encode(request:get-parameter('file',''))
let $url            := request:get-parameter('url','')
let $soapAction     := request:get-parameter('soapAction','')
(:let $file := 'XK_HAPIS1_REPC_IN990003NL_555555112_bijlage XI.xml':)
let $collection     := concat($get:strXisAccounts, '/',$account,'/messages')
let $requestHeaders := <headers><header name="SOAPAction" value="""{$soapAction}"""/><header name="Content-Type" value="text/xml"/></headers>
let $soapMessage :=
   if (doc(concat($collection,'/',$file))/soap:Envelope/soap:Body) then
      doc(concat($collection,'/',$file))/soap:Envelope
   else(
   <soap:Envelope>
      <soap:Body>
         {doc(concat($collection,'/',$file))/*}
      </soap:Body>
   </soap:Envelope>
   )
   
let $response := httpclient:post(xs:anyURI($url), $soapMessage, false(),$requestHeaders)

(: check return status. If not 200, not OK :)
let $result := 
   if ($response/@statusCode != 200) then
    $response
  else
    $response//httpclient:body/*

return
    $result