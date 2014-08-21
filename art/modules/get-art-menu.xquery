xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
(: PATH MUST BE ABSOLUTE BECAUSE THE CONTEXT IS THE APPLY-RULES STYLESHEET:)
import module namespace get         = "http://art-decor.org/ns/art-decor-settings" at "xmldb:exist:///db/apps/art/modules/art-decor-settings.xqm";
(:import module namespace get       = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";:)
import module namespace art         = "http://art-decor.org/ns/art" at "xmldb:exist:///db/apps/art/modules/art-decor.xqm";

declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace response      = "http://exist-db.org/xquery/response";
declare namespace xhtml         = "http://www.w3.org/1999/xhtml";

let $decors         := $get:colDecorData//decor[not(@private='true')]
let $art-languages  := art:getArtLanguages()

return
<projects>
{
    for $project in $decors/project
    let $defaultlang := $project/@defaultLanguage
    let $defaultname := 
        if   ($project/name[@language=$defaultlang]) 
        then ($project/name[@language=$defaultlang]) 
        else ($project/name[1])
    order by lower-case($defaultname)
    return
        <project prefix="{$project/@prefix}" defaultLanguage="{$defaultlang}">{
            attribute repository {$project/parent::decor/@repository='true'}
            ,
            (:get core languages:)
            for $lang in $art-languages
            return
                if   ($project/name[@language=$lang]) 
                then ($project/name[@language=$lang])
                else (<name language="{$lang}">{$defaultname/node()}</name>)
            ,
            (:get any other languages:)
            $project/name[not(@language=$art-languages)]
        }</project>
}
</projects>