xquery version "1.0";
(:
    Copyright (C) 2014-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace adsearch        = "http://art-decor.org/ns/decor/search" at "../api/api-decor-search.xqm";
import module namespace get             = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

let $searchTerms    := if (request:exists()) then tokenize(lower-case(request:get-parameter('searchString',())),'\s') else ()
let $projectPrefix  := if (request:exists()) then (request:get-parameter('project',())) else ()
let $type           := if (request:exists()) then (request:get-parameter('type',())) else ()
let $filter         := if (request:exists()) then (request:get-parameter('filter',())) else ()
let $maxResults     := if (request:exists()) then (request:get-parameter('maxResults',())) else ()
let $maxResults     := if ($maxResults castable as xs:integer) then xs:integer($maxResults) else xs:integer('10')

return
    if ($type='VS') then (
        adsearch:searchValueset($projectPrefix, $searchTerms, $maxResults)
    )
    (: filter is supposed to be a datasetId :)
    else if ($type='DE') then (
        adsearch:searchConcept($projectPrefix, $filter, (), $searchTerms, $maxResults, false())
    )
    else if ($type='TM') then (
        adsearch:searchTemplate($projectPrefix, $searchTerms, $maxResults)
    )
    else if ($type='IS') then (
        adsearch:searchIssue($projectPrefix, $searchTerms, $maxResults)
    )
    else if ($type='SC') then (
        adsearch:searchScenario($projectPrefix, $searchTerms, $maxResults)
    )
    else if ($type='TR') then (
        adsearch:searchTransaction($projectPrefix, $searchTerms, $maxResults)
    )
    else if ($type='DS') then (
        adsearch:searchDataset($projectPrefix, $searchTerms, $maxResults)
    )
    else (
    )