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

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../../art/api/api-server-settings.xqm";
import module namespace art = "http://art-decor.org/ns/art" at "../../art/modules/art-decor.xqm";

declare variable $strDecorServices   := adserver:getServerURLServices();

(: get stuff that doesn't live on our own server :)
declare function local:getcacheme($url as xs:string?, $ident as xs:string?, $serversettings as element()?) as element()? {
    if ($url = $strDecorServices) then () else (
       let $x := try {
             (doc(xs:anyURI(concat($url,'RetrieveProject?format=xml&amp;mode=cache&amp;prefix=',$ident)))/decor)
        } catch * 
        { 
            <error>Caught error {$err:code}: {$err:description}. Data: {$err:value}</error>
        } 
        let $pid := $x//project/@id
        let $rootUnexpected := name(($x)[1]) != 'decor'
        return
            <cacheme bbrurl="{$url}" bbrident="{$ident}" projectId="{$pid}" error="{$rootUnexpected}">
            {
                if ($serversettings/externalBuildingBlockRepositories/buildingBlockRepository[@url = $url][@ident = $ident]) then
                    attribute isTrusted {'true'}
                else (),
                $x
            }
            </cacheme>
    )
};

let $serversettings     := adserver:getServerSettings()
let $cachedir           := $get:strDecorCache

let $timeStamp          := current-dateTime()

let $secret             := if (request:exists()) then request:get-parameter('secret', '') else ''

(: get login credentials :)
let $theactingnotifierusername := if (request:exists()) then request:get-parameter('user', '') else ''
let $theactingnotifierpassword := if (request:exists()) then request:get-parameter('password', '') else ''


(: overall bbr references <buildingBlockRepository url="http://localhost:8877/decor/services/" ident="ad1bbr-"/> :)
let $overallbbrs    := $get:colDecorData//project/buildingBlockRepository

return
    if ($secret='61fgs756.s9' and (xmldb:login('/db', $theactingnotifierusername, $theactingnotifierpassword)) ) then
        <cachedBuildingBlockRepositories>
        {
            let $all1           :=
                for $b in $overallbbrs
                group by $url   := $b/@url, $ident := $b/@ident
                order by $url, $ident
                return
                    local:getcacheme($url, $ident, $serversettings)
                
            (:  recursive-cache: look up BBRs referenced in the BBR and get them as well if not already done :)
            let $rest :=
                for $b in $all1//project/buildingBlockRepository
                group by $url := $b/@url, $ident := $b/@ident
                order by $url, $ident
                return
                    if (count($all1[@bbrurl=$url][@bbrident=$ident])=0) then 
                        local:getcacheme($url, $ident, $serversettings)
                        else () (: already cached :)
            
            let $bbrsfound := $all1 | $rest
            let $intermediate :=
                for $x in $bbrsfound[@projectId!=''][@error='false']
                group by $trusted := $x/@isTrusted, $id := $x/@projectId
                order by $trusted, $id
                return
                    if (count($bbrsfound[@projectId=$id])>1)
                    then 
                        if (count($bbrsfound[@projectId=$id][@isTrusted='true'])>=1)
                        then ($bbrsfound[@projectId=$id][@isTrusted='true'])[1]
                        else $x
                    else $x
            let $bbrcount := count(distinct-values($intermediate/@projectId))
            let $bbrerrors := count($bbrsfound[@error='true'])
            
            let $allbbrs :=
                <cachedBuildingBlockRepositories status="OK" count="{$bbrcount}" errors="{$bbrerrors}" time="{$timeStamp}">
                {
                    (: store only BBRs with unique project ids :)
                    for $y in distinct-values($intermediate/@projectId)
                    group by $id := $y
                    order by $id
                    return
                        ($intermediate[@projectId=$y])[1],
                    for $y in $bbrsfound[@error='true']
                    return
                        <unreachable url="{$y/@bbrurl}" ident="{$y/@bbrident}">
                        {
                            $y
                        }
                        </unreachable>
                }
                </cachedBuildingBlockRepositories>
            
            let $mkdir  := xmldb:create-collection($cachedir,'/bbr')
            let $result := xmldb:store($mkdir, 'cache.xml', $allbbrs)
                
            return 
                <result cached="{$bbrcount}" unreachable="{count($allbbrs//unreachable)}" time="{$timeStamp}">
                {
                    $allbbrs/unreachable
                }
                </result>
        }
        </cachedBuildingBlockRepositories>
    else 
        <cachedBuildingBlockRepositories>NOTAUTHORIZED</cachedBuildingBlockRepositories>