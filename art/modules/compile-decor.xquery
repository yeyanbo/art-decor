xquery version "1.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Kai Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace xdb = "http://exist-db.org/xquery/xmldb";
declare namespace hl7 = "urn:hl7-org:v3";
declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";


let $projectPrefix := request:get-parameter('prefix','')

return
if (string-length($projectPrefix)=0) then (
     <results>
        <errors>
            <error text="nps">Internal error: Missing parameter prefix</error>
        </errors>
        <object name="Internal error: Missing parameter prefix"/>
    </results>
)
else (
    <results>
        <warnings>
            <warning text="nyi">This feature is not yet implemented</warning>
        </warnings>
        <object name="This feature is not yet implemented"/>
    </results>
)