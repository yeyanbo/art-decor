xquery version "1.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

declare function local:getType($type as element()) as element()* {
    <type>
    {
        $type/@*,
        for $subType in $type/dataType|$type/flavor|$type/atomicDataType
        return
        local:getType($subType),
        $type/attribute,
        $type/element
    }
    </type>
};

let $datatypeType   := if (request:exists()) then request:get-parameter('type',())[1] else ()
let $datatypeType   := if (string-length($datatypeType)>0) then $datatypeType else 'hl7v3xml1'

let $decorDatatypes := $get:colDecorCore/supportedDataTypes[@type=$datatypeType]

let $typeTree       := local:getType($decorDatatypes)

return
<supportedDataTypes>
{
    $decorDatatypes/@*
}
{
    for $type in $typeTree//type
    return
        <type>
        {$type/@name}
        <item name="{$type/@name}"/>
        {
            for $subtype in $type//type
            return
            <item name="{$subtype/@name}"/>
        }
        {
            $type/attribute,
            $type/element
        }
        </type>
}
</supportedDataTypes>