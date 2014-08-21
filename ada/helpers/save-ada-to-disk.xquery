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

let $adaDir := 'C:\Dropbox\development\ART-DECOR\ada\'
(:TODO: $xform[2] since xform contains processing instruction:)
(:return xdb:store($xformPath, $xformName, $xform[2]):)
let $result := file:sync('/db/apps/ada/helpers/', concat($adaDir, 'helpers'), ())
let $result := file:sync('/db/apps/ada/modules/', concat($adaDir, 'modules'), ())
(:let $result := file:sync('/db/apps/ada-data/projects/', concat($adaDir, 'projects'), ()):)
return $result