xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai U. Heitmann, Alexander Henket

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

declare namespace xs            = "http://www.w3.org/2001/XMLSchema";
declare namespace httpclient    = "http://exist-db.org/xquery/httpclient";

declare function local:getADRAMStatus($decorReferenceURL as xs:string?) as xs:string {
let $requestHeaders := 
    <headers>
        <header name="Content-Type" value="text/xml"/>
        <header name="Cache-Control" value="no-cache"/>
        <header name="Max-Forwards" value="'0'"/>
    </headers>
(: check availablility of reference/@url :)
let $unavailable    := '500'
let $longtimeago    := '1900-01-01T00:00:00'
let $servicestatus  :=
    if (string-length($decorReferenceURL)=0)
    then '500'
    else
        (: get headers -:)
        (:
            <httpclient:response xmlns:httpclient="http://exist-db.org/xquery/httpclient" statusCode="200">
                <httpclient:headers>
                    <httpclient:header name="Server" value="nginx/1.5.5"/>
                    <httpclient:header name="Date" value="Fri, 14 Mar 2014 05:33:33 GMT"/>
                    <httpclient:header name="Content-Type" value="text/html; charset=utf-8"/>
                    <httpclient:header name="Connection" value="keep-alive"/>
                    <httpclient:header name="X-Powered-By" value="ART-DECOR-ADRAM"/>
                    <httpclient:header name="Vary" value="Accept-Encoding,User-Agent"/>
                </httpclient:headers>
            </httpclient:response>
        :)
        try {
            let $pubDir         := httpclient:head(xs:anyURI($decorReferenceURL), false(), $requestHeaders)
            let $statusCode     := $pubDir/@statusCode
            let $adramConfig    := httpclient:get(xs:anyURI(concat($decorReferenceURL, '/adram.config.xml')), false(), $requestHeaders)
            let $adramStatus    := $adramConfig/@statusCode
            (:let $adramHeader := exists($response1/httpclient:headers/httpclient:header[@name='X-Powered-By'][@value='ART-DECOR-ADRAM']):)
            (: check wheter adram is configured there, if so get the @touch attribute to find out when the cron job last touched the config :) 
            let $response2      := 
                if ($adramStatus ='200') then (
                    let $adramLastRun := 
                        if ($adramConfig/httpclient:body/adram/@touched[string-length()>0]) 
                        then $adramConfig/httpclient:body/adram/@touched 
                        else $longtimeago
                    let $timediff     := days-from-duration(current-dateTime() - xs:dateTime($adramLastRun))
                    
                    (: if last touch is more than 2 days ago assume halted :)
                    return if ($timediff <= 2) then 'adram' else 'halted'
                )
                else (
                    (: if adram.config.xml does not exist then assume 'not configured' :)
                )
                
            return if ($statusCode='200') then concat($statusCode, ' ', $response2) else $unavailable
        } catch * { $unavailable }

return $servicestatus
};

let $project        := if (request:exists()) then request:get-parameter('project',())[string-length()>0]         else ()
let $language       := if (request:exists()) then request:get-parameter('language',())[string-length()>0]        else ()
let $projectId      := if (request:exists()) then request:get-parameter('id',())[string-length()>0]              else ()
let $checkADRAM     := if (request:exists()) then request:get-parameter('checkadram','false')[string-length()>0] else ()
let $decorProject   :=
    if ($project) then
        $get:colDecorData//project[@prefix=$project[1]]
    else if ($projectId) then
        $get:colDecorData//project[@id=$projectId[1]]
    else ()

(:XFORMS extras. This is used as prefix for project logos:)
let $projectColl    := replace(util:collection-name($decorProject),'^.*data/','')

return
<project id="{$decorProject/@id}" prefix="{$decorProject/@prefix}" defaultLanguage="{$decorProject/@defaultLanguage}" repository="{$decorProject/parent::decor/@repository='true'}" private="{$decorProject/parent::decor/@private='true'}">
{
    attribute collection {$projectColl},
    (:ADRAM extras:)
    if ($checkADRAM='true') then (
        attribute servicestatus {local:getADRAMStatus($decorProject/reference/@url)}
    ) else ()
}
{
    $decorProject/name,
    art:serializeDescriptionNodes($decorProject/desc)/*,
    $decorProject/copyright,
    for $author in $decorProject/author
    return
        <author>
        {
            $author/@*,
            if (not($author/@email)) then attribute email {''} else (),
            if (not($author/@notifier)) then attribute notifier {''} else (),
            $author/node()
        }
        </author>
    ,
    <reference url="{$decorProject/reference/@url}" logo="{$decorProject/reference/@logo}"/>,
    $decorProject/restURI,
    $decorProject/defaultElementNamespace,
    $decorProject/contact,
    $decorProject/buildingBlockRepository
}
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
        for $baseId in $decorProject/../ids/baseId
        return
            <baseId>
            {
                $baseId/@*[string-length()>0]
                ,
                if ($baseId[not(@default)]) then (
                    attribute {'default'} {exists($decorProject/../ids/defaultBaseId[@id=$baseId/@id])}
                )
                else()
            }
            </baseId>
        ,
        (: For now: keep old style so we can fix all dependent code later :)
        $decorProject/../ids/defaultBaseId,
        for $identifier in $decorProject/../ids/id
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
{
   $decorProject/../issues/labels
}
</project>