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
declare namespace request       = "http://exist-db.org/xquery/request";

let $projectPrefix      := if (request:exists()) then (request:get-parameter('project',())) else ()
let $searchTerms        := if (request:exists()) then (tokenize(lower-case(request:get-parameter('searchString',())[string-length()>0]),'\s')) else ()
let $types              := if (request:exists()) then (tokenize(request:get-parameter('type',())[string-length()>0],'\s')) else ()
let $priorities         := if (request:exists()) then (tokenize(request:get-parameter('priority',())[string-length()>0],'\s')) else ()
let $statuscodes        := if (request:exists()) then (tokenize(request:get-parameter('statusCode',())[string-length()>0],'\s')) else ()
let $lastassignedids    := if (request:exists()) then (tokenize(request:get-parameter('assignedTo',())[string-length()>0],'\s')) else ()
let $labels             := if (request:exists()) then (tokenize(request:get-parameter('labels',())[string-length()>0],'\s')) else ()
return
    iss:getIssueList($projectPrefix, $searchTerms, $types, $priorities, $statuscodes, $lastassignedids, $labels)