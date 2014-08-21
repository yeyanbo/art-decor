xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace aduser  = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

let $issueId    := if (request:exists()) then request:get-parameter('id',()) else ()
let $action     := if (request:exists()) then request:get-parameter('action',()) else ()

let $update     :=
    if ($action='add') then
        if (exists($get:colDecorData//issue[@id=$issueId])) then
            aduser:setUserIssueSubscription($issueId)
        else (
            error(QName('http://art-decor.org/ns/error', 'UnsupportedParameters'), concat('Could not find issue with id ''',$issueId,'''.'))
        )
    else if ($action='delete') then
        aduser:unsetUserIssueSubscription($issueId)
    else (
        error(QName('http://art-decor.org/ns/error', 'UnsupportedParameters'), concat('Unsupported value for parameter action ''',$action,'''. Supported actions are ''add'' and ''delete'''))
    )

return <result q="{request:get-query-string()}">{not($update=false())}</result>