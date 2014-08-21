xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR Expert Group art-decor.org
    
    Author: dr Kai U. Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
(:
    Xquery for setting statusCode of version/release object in a specific project
    Input: post of statusChange element:
    <version-release-status-change projectPrefix="vacc-" date="2014-05-20T11:34:22" statusCode="active"/>
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";

declare variable $logFileName := concat('transactions-',datetime:format-date(current-date(),"yyyy"),'.xml');


let $statusChange := request:get-data()/version-release-status-change
(:
let $statusChange :=
    <version-release-status-change projectPrefix="vacc-" date="2014-05-20T11:34:22" statusCode="active"/>
:)

let $projectPrefix  := $statusChange/@projectPrefix
let $itemdate       := $statusChange/@date
let $itemstatusCode := $statusChange/@statusCode

let $user := xmldb:get-current-user()

let $project := $get:colDecorData//decor[project/@prefix=$projectPrefix]
let $projectversionreleaseitem := $project/project/(version|release)[@date=$itemdate]

let $statusUpdate :=
    if ($user=$project/project/author/@username) then (
        if (string-length($projectversionreleaseitem/@statusCode)=0) then
            update insert attribute statusCode {$itemstatusCode} into $projectversionreleaseitem
        else
            if ($projectversionreleaseitem/@statusCode = $itemstatusCode) then 
                () (: do nohing :)
            else
                update value $projectversionreleaseitem/@statusCode with $itemstatusCode,
        <response projectPrefix="{$projectPrefix}" date="{$itemdate}" statusCode="{$itemstatusCode}" targetDate="{$projectversionreleaseitem/@date}">OK</response>
    ) else (<response>NO PERMISSION</response>)

return
    $statusUpdate
