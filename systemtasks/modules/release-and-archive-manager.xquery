xquery version "3.0";
(:
    Copyright (C) 2014-2014 ART-DECOR expert group art-decor.org
    
    Author: Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "../../art/modules/art-decor.xqm";

declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace response      = "http://exist-db.org/xquery/response";
declare namespace xmldb         = "http://exist-db.org/xquery/xmldb";
declare namespace util          = "http://exist-db.org/xquery/util";
declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";


(: a secret parameter :)
let $secret := if (request:exists()) then request:get-parameter('secret', '') else ('')

(: get login credentials :)
let $theactingnotifierusername := if (request:exists()) then request:get-parameter('user', '') else ('')
let $theactingnotifierpassword := if (request:exists()) then request:get-parameter('password', '') else ('')

(:
    get possible extra action parameter
    action = setpublicationstatus with parameters project (prefix) and date (release date), set to parameter status
:)
let $specialaction  := if (request:exists()) then request:get-parameter('action', '') else ('')
let $projectPrefix  := if (request:exists()) then request:get-parameter('project', '') else ('')
let $date           := if (request:exists()) then request:get-parameter('date', '') else ('')
let $signature      := if (request:exists()) then request:get-parameter('signature', '') else ('')
let $status         := if (request:exists()) then request:get-parameter('status', '') else ('')

let $shortproject   := substring($projectPrefix, 1, string-length($projectPrefix) - 1)
let $coll           := concat($get:strDecorVersion, '/', $shortproject, '/version-', $signature)
let $project        := $get:colDecorData//decor[project/@prefix=$projectPrefix]
let $projectversionreleaseitem := $project/project/(version|release)[@date=$date]

let $timeStamp      := substring-before(xs:string(current-dateTime()), '.')

return
    if ($secret='61fgs756.s9' and (xmldb:login('/db', $theactingnotifierusername, $theactingnotifierpassword))) then
        if ($specialaction = 'setpublicationstatus') then
            <result collection="{$coll}">
            {
                (: create an xml object named (projectprefix)-publication-completed.xml with the status the following content : :)
                let $s := <publication projectPrefix="{$projectPrefix}" statusCode="{$status}"/>
                let $x := xmldb:store($coll, concat($projectPrefix, $signature, '-publication-completed.xml'), $s)
                (: set the status of the release version of the project just processed to pending unless is was set in the mean time :)
                let $itemstatusCode := 'pending'
                let $statusupdate :=
                    if ((string-length($date)>0) and (string-length($projectPrefix)>0) and (count($projectversionreleaseitem)>0) and ($status='inprogress')) then
                        if (string-length($projectversionreleaseitem/@statusCode)=0) then
                            update insert attribute statusCode {$itemstatusCode} into $projectversionreleaseitem
                        else
                            () (: do nothing :)
                    else ()
                (: return :)
                return ()
            }
            </result>
        else
            <publication-request-list count="{count($get:colDecorVersion//publication[count(processed)=0][count(request)>0])}">
            {
                (: look thru all publication requests in version directory that carry a request but are not yet processed :)
                for $pubrequest in $get:colDecorVersion//publication[count(processed)=0][count(request)>0]
                (: get parent collection name :)
                let $parent := util:collection-name($pubrequest)
                (: hush thru all child resources and if they are a compilation create a publication reuqest :)
                let $compiledFiles :=
                    for $xcollection in xmldb:get-child-resources($parent)
                    let $docname := concat($parent, '/', $xcollection)
                    let $ddoc := doc($docname)
                    (: compilationDate indicates that this resource is a compilation :)
                    let $compilationDate := if ($ddoc/decor/@compilationDate) then $ddoc/decor/@compilationDate else ''
                    return
                        if ($ddoc/decor) then
                            (: return the resource = DECOR XML (original or compiled file as a base64 encoded blob :)
                            <compiled-file-b64 name="{$xcollection}" language="{$ddoc/decor/@language}">
                                {
                                    if (string-length($compilationDate)>0)
                                    then attribute {"compilationDate"} {$compilationDate}
                                    else attribute {"original"} {"true"}
                                }
                                {util:base64-encode(util:serialize($ddoc, 'method=xml'))}
                            </compiled-file-b64>
                        else ()
                let $noofcfiles := count($compiledFiles)
                (: if we found requests, mark the publication reuqest a processed = OK else as NOQ no request :)
                let $processed := <processed on="{$timeStamp}" status="{if ($noofcfiles > 0) then 'OK' else 'NOQ'}"/>
                (: do the real update of the process request file :)
                let $result := update insert $processed into $pubrequest
                return
                    if ($noofcfiles>0) then
                        <publication-request count="{$noofcfiles}">
                            {$pubrequest}
                            {$compiledFiles}
                        </publication-request>
                    else
                        <publication-request count="0"/>
            }
            </publication-request-list>
    else <no-access/>