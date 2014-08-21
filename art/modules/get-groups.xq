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

declare namespace hl7="urn:hl7-org:v3";
declare namespace soap="http://schemas.xmlsoap.org/soap/envelope/";
declare namespace datetime="http://exist-db.org/xquery/datetime";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace sm="http://exist-db.org/xquery/securitymanager";

let $user   := if (request:exists()) then request:get-parameter('username',()) else ()
let $groups := if (string-length($user)=0) then sm:get-groups() else (sm:get-user-groups($user))

return
<groups>
{
    for $group in $groups
    order by $group
    return
        <group>{$group}</group>
}
</groups>


