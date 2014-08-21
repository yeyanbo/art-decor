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
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";

(: decor project also contains @repository and @private markers. Those are ignored for now :)
let $decorProject := if (request:exists()) then request:get-data()/project else ()

let $newProject :=
    <project id="{$decorProject/@id}" prefix="{$decorProject/@prefix}" defaultLanguage="{$decorProject/@defaultLanguage}">
    {
        $decorProject/name,
        for $desc in $decorProject/desc
        return
            art:parseNode($desc),
        $decorProject/copyright,
        for $author in $decorProject/author
        return
           <author>
           {
               $author/@*[string-length()>0],
               $author/node()
           }
           </author>
        ,
        $decorProject/reference,
        $decorProject/restURI,
        $decorProject/defaultElementNamespace,
        $decorProject/contact,
        for $bbr in $decorProject/buildingBlockRepository[string-length(@url)>0][string-length(@ident)>0]
        return
            <buildingBlockRepository>{$bbr/@url, $bbr/@ident, $bbr/@licenseKey}</buildingBlockRepository>
        ,
        (:for $versionInfo in $decorProject/(version|release)
        return
            element {name($versionInfo)} {
                $versionInfo/(@*[string-length()>0] except @publicationstatus),
                for $desc in $versionInfo/(desc|note)
                return 
                    art:parseNode($desc)
            }:)
        $get:colDecorData//project[@id=$decorProject/@id]/(version|release)
    }
    </project>

let $update    := update replace $get:colDecorData//project[@id=$decorProject/@id] with $newProject

return
<data-safe>true</data-safe>