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

let $newActors := request:get-data()/actors

(:let $newActors :=
   <actors projectPrefix="tfw-">
      <actor id="2.16.840.1.113883.2.4.3.46.99.3.5.1" type="person">
         <name language="nl-NL">Patiënt</name>
         <name language="en-US">Patient</name>
      </actor>
      <actor id="2.16.840.1.113883.2.4.3.46.99.3.5.2" type="organization">
         <name language="en-US">Weight Registry</name>
         <name language="nl-NL">Gewicht register</name>
      </actor>
   </actors>:)


let $decor := $get:colDecorData//decor[project/@prefix=$newActors/@projectPrefix]

let $actorsAvailable :=
    if (not($decor/scenarios)) then 
        update insert <scenarios><actors/></scenarios> preceding $decor/ids 
    else if (not($decor/scenarios/actors)) then
        update insert <actors/> preceding $decor/scenarios/node()
    else()
   
let $actorsUpdate :=
    <actors>
    {
        for $actor in $newActors/actor
        return
        <actor>
        {
            $actor/@*
            ,
            for $name in $actor/name
            return
            art:parseNode($name)
            ,
            for $desc in $actor/desc
            return
            art:parseNode($desc)
        }
        </actor>
    }
    </actors>

return
update value $decor/scenarios/actors with $actorsUpdate/*

