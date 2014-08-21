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
declare namespace hl7="urn:hl7-org:v3";
declare namespace xforms="http://www.w3.org/2002/xforms";

declare function local:getMatches($input as xs:string?, $output as xs:string*) as xs:string* {
    let $match := 
        if (matches($input,'\$resources/([A-Za-z0-9-]+)')) 
        then replace($input,'.*\$resources/([A-Za-z0-9-]+).*','$1') 
        else ()
    
    return
        if (string-length($match)>0) then
            local:getMatches(replace($input,concat('\$resources/',$match),''),($output,$match))
        else ($output)
};

let $packageRoot := if (request:exists()) then request:get-parameter('packageRoot',$get:strArt) else ('/db/apps/art')
(: put all xform resources in variable:)
let $all-form-resources :=
    for $key in distinct-values(collection(concat($packageRoot,'/xforms'))//@ref[matches(.,'\$resources/[^@]')] | collection(concat($packageRoot,'/xforms'))//@value[matches(.,'\$resources/[^@]')])
    return
        local:getMatches($key,())

(: existing resources:)
let $artXformResources := doc(concat($packageRoot,'/resources/form-resources.xml'))/artXformResources

(: list of all keys:)
let $keys	:= $artXformResources/resources[1]/*/name()

(: check if resource exists, if not generate empty text elements for each language in resources:)
return
<undefinedResources packageRoot="{$packageRoot}">
{
    for $undefined-resource in distinct-values($all-form-resources[not(.=$keys)])	
    return
    <resource key="{$undefined-resource}">
    {
        for $resource in $artXformResources/resources
        return
        <text xml:lang="{$resource/@xml:lang}" displayName="{$resource/@displayName}"/>
    }
    </resource>
}
</undefinedResources>