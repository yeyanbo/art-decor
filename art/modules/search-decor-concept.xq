xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace adsearch       = "http://art-decor.org/ns/decor/search" at "../api/api-decor-search.xqm";

let $searchTerms            := if (request:exists()) then tokenize(lower-case(request:get-parameter('searchString',())),'\s') else ()
let $projectPrefix          := if (request:exists()) then (request:get-parameter('project',())) else ()
let $datasetId              := if (request:exists()) then request:get-parameter('dataset',()) else ()
let $conceptType            := if (request:exists()) then request:get-parameter('type',()) else ()

(:mostly interesting when we're called from the similar concepts context in the dataset form when we're creating a new concept:)
(:we inherit only from original concepts:)
let $originalOnly           := if (request:exists()) then request:get-parameter('originalonly',()) else ()
let $originalConceptsOnly   := if ($originalOnly castable as xs:boolean) then xs:boolean($originalOnly) else (false())

let $maxResults             := xs:integer('50')

return
adsearch:searchConcept($projectPrefix, $datasetId, $conceptType, $searchTerms, $maxResults, $originalConceptsOnly)