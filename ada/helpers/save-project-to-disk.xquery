(:
    Copyright (C) 2013-2014  Marc de Graauw
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
xquery version "3.0";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";
declare namespace file       = "http://exist-db.org/xquery/file";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";

declare variable $adaprojectroot := concat(repo:get-root(),'/ada/projects');

let $project    := 
    if (request:exists()) 
    then (request:get-parameter('project',()))
    else ('demoapp')
let $adaDir     := 
    if (request:exists()) 
    then (request:get-parameter('localdir',())) 
    else (concat('/mnt/hgfs/source/ART DECOR trunk/ada-data/projects/', $project, '/')) 
let $adaRoot    := concat($adaprojectroot,'/', $project, '/')

let $result := file:sync(concat($adaRoot, 'data'), concat($adaDir, 'data'), ())
let $result := file:sync(concat($adaRoot, 'hl7'), concat($adaDir, 'hl7'), ())
let $result := file:sync(concat($adaRoot, 'xslt'), concat($adaDir, 'xslt'), ())
return $result