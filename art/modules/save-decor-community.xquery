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

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at  "art-decor.xqm";

declare function local:preparePrototype($prototype as element()) as element() {
    <prototype>
    {
        for $data in $prototype/data
        return
            <data>
            {
                $data/@*,
                for $desc in $data/desc
                return
                    art:parseNode($desc)
            }
            </data>
    }
    </prototype>
};

declare function local:prepareAssociations($associations as element()) as element() {
    <associations>
    {
        for $association in $associations/association
        return
            <association>
            {
                $association/object,
                for $data in $association/data
                return
                    art:parseNode($data)
            }
            </association>
    }
    </associations>
};

(: get community from request :)
let $editedCommunity    := request:get-data()/community
(: community stored in DB :)
let $storedCommunity    := $get:colDecorData//community[@name=$editedCommunity/@name][@projectId=$editedCommunity/@projectId]
(: check if lock in edited community is matched in db :)
let $lock               := $get:colArtResources//communityLock[@ref=$editedCommunity/communityLock/@ref][@projectId=$editedCommunity/communityLock/@projectId]

let $updates :=
    if ($lock) then (
        update value $storedCommunity/@displayName with $editedCommunity/@displayName,
        update replace $storedCommunity/desc with for $desc in $editedCommunity/desc return art:parseNode($desc),
        update replace $storedCommunity/access with $editedCommunity/access,
        update replace $storedCommunity/prototype with local:preparePrototype($editedCommunity/prototype),
        if (not($storedCommunity/associations)) then
            update insert <associations/> following $storedCommunity/prototype
        else(),
        update replace $storedCommunity/associations with local:prepareAssociations($editedCommunity/associations),
        update delete $lock
    ) else ()

return
<data-safe>true</data-safe>