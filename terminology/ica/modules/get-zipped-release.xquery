xquery version "1.0";
(:
	Copyright (C) 2011-2013 Art-Decor Expert Group
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
declare namespace compression="http://exist-db.org/xquery/compression";
declare option exist:serialize "method=text media-type=application/zip,application/octet-stream charset=utf-8";


let $collection := request:get-parameter('release','')



return
   if (string-length($collection) gt 0 and xmldb:collection-available(concat($get:strTerminologyData,'/ica-data/releases/',$collection))) then
   (
   response:set-header("Content-Disposition", concat('attachment; filename=',$collection,'.zip'))
   ,
   response:stream-binary(
       compression:zip( xs:anyURI(concat($get:strTerminologyData,'/ica-data/releases/',$collection,'/')), false() ),
       'application/zip',
       concat($collection,'.zip')
       )
   )
   else()
 