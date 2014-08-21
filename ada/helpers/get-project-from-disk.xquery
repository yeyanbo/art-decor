xquery version "3.0";
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
import module namespace ada     = "http://art-decor.org/ns/ada-common" at "../modules/ada-common.xqm";
declare namespace xmldb         = "http://exist-db.org/xquery/xmldb";
declare namespace sm            = "http://exist-db.org/xquery/securitymanager";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace output        = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";

let $project    := 
    if (request:exists()) 
    then (request:get-parameter('project',()))
    else ('demoapp')
let $adaDir     := 
    if (request:exists()) 
    then (request:get-parameter('localdir',())) 
    else (concat('/mnt/hgfs/source/ART DECOR trunk/ada-data/projects/', $project, '/')) 
let $adaRoot    := concat($ada:strAdaProjects,'/', $project, '/')

return
    <result>
        <definitions>
        {
            for $f in xmldb:store-files-from-pattern(concat($adaRoot, 'definitions'), concat($adaDir, 'definitions'), '*.xml') 
            return <file>{$f}</file>
        }
        </definitions>
        <schemas>
        {
            for $f in xmldb:store-files-from-pattern(concat($adaRoot, 'schemas'), concat($adaDir, 'schemas'), '*.xsd') 
            return <file>{$f}</file>
        }
        </schemas>
        <modules>
        {
            for $f in xmldb:store-files-from-pattern(concat($adaRoot, 'modules'), concat($adaDir, 'modules'), ('*.xquery')) 
            return <file>{$f}</file>
        }
        </modules>
        <views>
        {
            for $f in xmldb:store-files-from-pattern(concat($adaRoot, 'views'), concat($adaDir, 'views'), ('*.xhtml', '*.html')) 
            return <file>{$f}</file>
        }
        </views>
        <new>
        {
            for $f in xmldb:store-files-from-pattern(concat($adaRoot, 'new'), concat($adaDir, 'new'), '*.xml') 
            return <file>{$f}</file>
        }
        </new>
    </result>