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

(: Add resources to form-resources, package root is in undefinedResources/@packageRoot:)



let $request        := if (request:exists()) then request:get-data()/undefinedResources else ()

(:let $request        :=
<undefinedResources packageRoot="/db/apps/art">
    <resource key="abc-key-bogus">
        <text xml:lang="en-US" displayName="English (en-US)">English</text>
        <text xml:lang="nl-NL" displayName="Nederlands (nl-NL)">Nederlands</text>
        <text xml:lang="de-DE" displayName="Deutsch (de-DE)">Deutsch</text>
    </resource>
</undefinedResources>:)

let $formResources  := doc(concat($request/@packageRoot,'/resources/form-resources.xml'))/artXformResources

let $newResources   :=
    <artXformResources>
    {
        $formResources/@*
        ,
        for $resources in $formResources/resources
        let $lang := $resources/@xml:lang
        return
            <resources>
            {
                $resources/@*
                ,
                for $text in ($resources/*|$request/resource)
                let $sortkey := if ($text/@key) then $text/@key else $text/name()
                let $textval := if ($text/@key) then $text/text[@xml:lang=$lang]/text() else $text/text()
                order by lower-case($sortkey)
                return
                    element {$sortkey} {$textval}
            }
            </resources>
    }
    </artXformResources>

return
<response>
{
    for $resources in $formResources/resources
    let $lang := $resources/@xml:lang
    return
        update replace $resources with $newResources/resources[@xml:lang=$lang]
    (:for $resource in $request/resource
    for $text in $resource/text
    return
        update insert element {$resource/@key} {$text/text()} into $formResources/resources[@xml:lang=$text/@xml:lang]:)
}
</response>
