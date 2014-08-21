xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "art-decor.xqm";
declare namespace request       = "http://exist-db.org/xquery/request";

let $project        := if (request:exists()) then request:get-parameter('project',())[string-length()>0] else ()
let $decor          := $get:colDecorData/decor[project/@prefix=$project]
let $defaultLang    := $decor/project/@defaultLanguage
let $language       := if (request:exists()) then request:get-parameter('language',$defaultLang)[string-length()>0] else ($defaultLang)

return
    <ids>
    {
        (:
        Add empty designation for language, otherwise you cannot edit the designation in the project form. TODO: fix empty designations before/on save 
        <id root="1.0.639.2">
            <designation language="nl-NL" type="" displayName="ISO-639-2 Alpha 3" lastTranslated="" mimeType="">ISO-639-2 Alpha 3 Language</designation>
        </id>
        :)
        (:
            Old style:
                <baseId id="1.2.3" type="DS" prefix="xyz"/>
                <defaultBaseId id="1.2.3" type="DS"/>
            New style:
                <baseId id="1.2.3" type="DS" prefix="xyz" default="true"/>
                
            Rewrite old style to new style.
        :)
        for $baseId in $decor/ids/baseId
        return
            <baseId>
            {
                $baseId/@*[string-length()>0]
                ,
                if ($baseId[not(@default)]) then (
                    attribute {'default'} {exists($decor/ids/defaultBaseId[@id=$baseId/@id])}
                )
                else()
            }
            </baseId>
        ,
        (: For now: keep old style so we can fix all dependent code later :)
        $decor/ids/defaultBaseId,
        for $identifier in $decor/ids/id
        return
            element {name($identifier)} {
                $identifier/@*,
                (:create if not available in the language so the user may fill it out:)
                if (string-length($language)>0 and not($identifier/designation[@language=$language]))
                then (<designation language="{$language}" type="preferred" displayName=""/>)
                else (),
                (:retain anything that was not requested but still in there:)
                for $designation in $identifier/designation
                return
                <designation language="{$designation/@language}" type="{$designation/@type}" displayName="{$designation/@displayName}">
                {$designation/node()}
                </designation>
            }
    }
    </ids>