xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace iss     = "http://art-decor.org/ns/decor/issue" at "../api/api-decor-issue.xqm";

let $id             := if (request:exists()) then (request:get-parameter('id',())) else ()
let $effectiveDate  := if (request:exists()) then (request:get-parameter('effectiveDate',())[string-length()>0]) else ()

return
    iss:getExpandedIssuesByObject($id, $effectiveDate)