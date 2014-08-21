xquery version "1.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
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

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xforms="http://www.w3.org/2002/xforms";


let $project := request:get-parameter('project','')
let $projectId := request:get-parameter('id','')

let $decorProject :=
		if (string-length($project)>0) then
				$get:colDecorData//decor[project/@prefix=$project]
		else if (string-length($projectId)>0) then
				$get:colDecorData//decor[project/@id=$projectId]
		else()

return
<versions projectPrefix="{$decorProject/project/@prefix}" projectId="{$decorProject/project/@id}" asOf="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}">
{
    for $version in $decorProject/project/version|$decorProject/project/release
    let $pprefix := substring($decorProject/project/@prefix, 1, string-length($decorProject/project/@prefix) - 1)
    let $psuffix := translate($version/@date, '-:', '')
    let $coll := concat($get:strDecorVersion, '/', $pprefix, '/version-', $psuffix)
    (: publicationstatus 
        version = version stored but no publication request
        pending = publication request issued, but publication not yet completed nor started
        completed = publication request issued, publication completed without errors
        failed = publication request issued, publication completed with errors
        inprogress = publication request is being processed
    :)
    let $pubcomplete := if (doc-available(concat($coll, '/', $pprefix, '-', $psuffix, '-publication-completed.xml'))) then doc(concat($coll, '/', $pprefix, '-', $psuffix, '-publication-completed.xml')) else ()
    let $pubstatus := concat(if (xmldb:collection-available($coll)) then 'version' else '',
        if (not(empty($pubcomplete))) then if (string-length($pubcomplete/publication/@statusCode)>0) then concat(' ', $pubcomplete/publication/@statusCode) else ' completed' else 
        if (doc-available(concat($coll, '/', $pprefix, '-', $psuffix, '-publication-request.xml')) and not ($version/@statusCode='cancelled' or $version/@statusCode='retired')) then ' pending' else '')
    order by string($version/@date) descending
    return
        element {$version/name()} {
            $version/(@* except @publicationstatus),
            attribute {'publicationdate'} {
                $psuffix
            },
            attribute {'publicationstatus'} {
                $pubstatus
            },
            for $desc in $version/desc|$version/note
            return
                art:serializeNode($desc)
        }

}
</versions>