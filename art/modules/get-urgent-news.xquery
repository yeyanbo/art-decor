xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Kai U. Heitmann

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

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace util="http://exist-db.org/xquery/util";

let $timeStamp := current-dateTime()
let $urgentnewslocation := concat($get:strArtData, '/', 'urgentnews.xml')
let $urgentnews := doc($urgentnewslocation)
let $result := 
    <r>
        {
            for $un in $urgentnews//news
            let $d := if ($un/@showuntil castable as xs:dateTime) then xs:dateTime($un/@showuntil) else xs:dateTime(0)
            return if ($d > $timeStamp) then $un else ()
        }
    </r>
let $cnt := count ($result/*)

return
    if ($cnt = 0) then
        <urgentnews status="NONE" count="0" time="{$timeStamp}"/>
    else
        <urgentnews status="OK" count="{$cnt}" time="{$timeStamp}">
        {   
            for $x in $result/news
            return
                <news>
                {
                    $x/@*,
                    for $t in $x/text
                    return art:serializeNode($t)
                }
                </news>
        }
        </urgentnews>