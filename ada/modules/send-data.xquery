(:
    Copyright (C) 2013-2014  Marc de Graauw
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
xquery version "3.0";

import module namespace ada ="http://art-decor.org/ns/ada-common" at "ada-common.xqm";

declare namespace httpclient = "http://exist-db.org/xquery/httpclient";
declare namespace request    = "http://exist-db.org/xquery/request";
declare namespace hl7        = "urn:hl7-org:v3";
declare namespace soap       = "http://schemas.xmlsoap.org/soap/envelope/";

let $prefix := if (request:exists()) then request:get-parameter('prefix','') else 'demo1-' 
let $rootdir := concat($ada:strAdaProjects, '/', translate($prefix, '-', ''))
let $datadir := concat($rootdir, '/data')
let $sentdir := concat($rootdir, '/sent')
let $faileddir := concat($rootdir, '/failed')

let $soapMessage :=
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
            <docws:ProvideDocument xmlns:docws="urn:oid:2.16.840.1.113883.2.4.3.46.10.1">
                <docws:Ping/>
            </docws:ProvideDocument>
        </soap:Body>
    </soap:Envelope>
let $receiverUrl := 'http://laptopmarc:8088/mockProvideDocument_Binding'
let $requestHeaders := <headers><header name="SOAPAction" value=""""""/><header name="Content-Type" value="text/xml"/></headers>

(:let $message := collection($datadir)/*[@id='9528f370-1a2e-4a35-bc23-e855483f8f37']:)

let $response := httpclient:post(xs:anyURI($receiverUrl), $soapMessage, false(),$requestHeaders)

(: check return status. If not 200, not OK :)
let $result := 
    if ($response/@statusCode != 200) then
        xmldb:store($faileddir, 'response.xml', $response)
  else
        xmldb:store($sentdir, 'response.xml', $response)

return $result