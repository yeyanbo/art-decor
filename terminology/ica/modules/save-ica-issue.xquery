xquery version "3.0";
(:
	Copyright (C) 2011-2013 Art Decor Expert Group art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get    = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace aduser = "http://art-decor.org/ns/art-decor-users" at "../../../art/api/api-user-settings.xqm";
declare namespace request      = "http://exist-db.org/xquery/request";
declare namespace xhtml        = "http://www.w3.org/1999/xhtml";

let $request         := request:get-data()/issue

let $issues             := collection(concat($get:strTerminologyData,'/ica-data/meta'))//issues
let $userName        := $request/tracking/author
let $userDisplayName :=
    try {
        aduser:getUserDisplayName($userName)
    }
    catch * {
        $userName
    }

let $newIssue := 	
    <issue id="{util:uuid()}" priority="{$request/@priority}" displayName="{$request/@displayName}" type="{$request/@type}">
    {
        if ($request/object) then
            <object id="{$request/object/@id}" type="{$request/object/@type}" effectiveDate="{$request/object/@effectiveDate}"/>
        else()
    }
        <tracking effectiveDate="{datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd'T'HH:mm:ss")}" statusCode="open">
           <author id="{$request/tracking/author/@id}">{$userDisplayName}</author>
           <desc language="{string($request/tracking/desc/@language)}">{util:parse-html($request/tracking/desc)//xhtml:body/text()|util:parse-html($request/tracking/desc)//BODY/node()}</desc>
        </tracking>
    </issue>

return
<response>
{
 update insert $newIssue into $issues
}
</response>