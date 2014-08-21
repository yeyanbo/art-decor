xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw, Alexander Henket
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace f   = "urn:decor:REST:v1" at "get-message.xquery";

(: TODO: media-type beter zetten en XML declaration zetten bij XML output :)
declare option exist:serialize "method=xhtml media-type=xhtml omit-xml-declaration=yes";

let $id            := request:get-parameter('id','')
let $code          := request:get-parameter('code','')
let $effectiveDate := request:get-parameter('effectiveDate','')
let $language      := request:get-parameter('language',$get:strArtLanguage)
let $format        := request:get-parameter('format','xml')

let $parameters :=  request:get-parameter-names()

let $searchString := 
    for $parKey in $parameters
        let $parValue := request:get-parameter($parKey,'')
    return
        if ($parKey != 'format' and string-length($parValue) > 0) then
            (concat('@',$parKey,'=&apos;',$parValue,'&apos;'))
        else 
            ()

let $codes := ()

return 
    <warning>{f:getMessage('errorNotImplementedYet',$language),' ',$searchString}</warning>