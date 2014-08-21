xquery version "1.0";
(:
    Copyright (C) 2011
    
    Author: Gerrit Boers

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
declare namespace uml="omg.org/UML1.3";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare option exist:serialize "method=xml media-type=application/xhtml+xml";

let $id := request:get-parameter('id','')
let $name := request:get-parameter('name','')
(:let $id := '2.16.840.1.113883.2.4.3.28.1.1.2.30':)
let $dcm := if (string-length($id)>0) then
               collection('/db/apps/DCM')/XMI[XMI.content/uml:TaggedValue[@tag='DCM::Id' and @value=$id]]
            else if (string-length($name)>0) then
               collection('/db/apps/DCM')/XMI[XMI.content/uml:TaggedValue[@tag='DCM::Name' and @value=$name]]
            else(collection('/db/apps/DCM')/XMI[XMI.content/uml:TaggedValue[@tag='DCM::Id' and @value='2.16.840.1.113883.2.4.3.28.1.1.2.30']])


return
$dcm

