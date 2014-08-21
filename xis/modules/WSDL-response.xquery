xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace wsdlsoap   = "http://schemas.xmlsoap.org/wsdl/soap/";
declare namespace wsdl       = "http://schemas.xmlsoap.org/wsdl/";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no";

let $get-uri          := request:get-uri()
let $get-url          := request:get-url()
(:by using service, we would only get the final apart of the URI thereby skipping any version in versioned URI:)
(:let $soapService      := request:get-parameter('service',''):)
let $soapService      := replace($get-url,'.*/xis/','/')
(:let $format           := if (string-length(request:get-parameter('format',''))>0) then (request:get-parameter('format','')) else ('xml'):) 

(: Consider rewrite of file so the address URI actually matches the actual service URI :)
let $return           := (collection($get:strHl7)//wsdlsoap:address[ends-with(string(@location),$soapService)]/ancestor::wsdl:definitions)[1]

return
    $return