xquery version "1.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../api/api-server-settings.xqm";
declare namespace xsl            = "http://www.w3.org/1999/XSL/Transform";

let $xformStylesheet := adserver:getServerXSLArt()
let $xformStylesheet := if (string-length($xformStylesheet)=0) then 'apply-rules.xsl' else ($xformStylesheet)
   
let $stylesheet      := doc(concat($adserver:strServerXSLPath,'/',$xformStylesheet))

let $lastRefresh     := $stylesheet//xsl:param[@name='lastRefresh']

let $update          := update value $lastRefresh/@select with concat('''',current-dateTime(),'''')
return
<refresh dateTime="{$stylesheet//xsl:param[@name='lastRefresh']/@select}"/>
