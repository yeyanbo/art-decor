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
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace xmldb         = "http://exist-db.org/xquery/xmldb";
declare namespace xis           = "http://art-decor.org/ns/xis";

(: server path:)
let $testAccount        := if (request:exists()) then request:get-parameter('account','') else ()
let $testAccount        := if (string-length($testAccount)=0) then 'art-decor' else $testAccount

(: store which testAccount was last selected, so messages and test screen can show this at startup :)
let $user               := xmldb:get-current-user()
let $userAllAccounts    := doc($get:strTestAccounts)//xis:testAccount/xis:members/xis:user[@id=$user]
let $userThisAccount    := doc($get:strTestAccounts)//xis:testAccount[@name=$testAccount]/xis:members/xis:user[@id=$user]
let $result             := 
    if ($user=sm:get-group-members('xis')) then (
        update delete $userAllAccounts/@lastSelected,
        update insert attribute lastSelected {'true'} into $userThisAccount
    ) else ()

let $collectionPath     := concat($get:strXisAccounts, '/',$testAccount,'/messages')
let $collectionContent  := xmldb:get-child-resources($collectionPath)

return
<files>
{
    for $file in $collectionContent
    let $fullPath  := concat($collectionPath,'/',$file)
    let $mediaType := xmldb:get-mime-type(xs:anyURI($fullPath))
    order by $file
    return
        if (not(util:is-binary-doc($fullPath)) and doc-available($fullPath)) then (
            <file name="{$file}" dateTime="{xmldb:created($collectionPath,$file)}" rootName="{doc(concat($collectionPath,'/',$file))/*/local-name()}" mediaType="{$mediaType}"/>
        ) else ()
}
</files>