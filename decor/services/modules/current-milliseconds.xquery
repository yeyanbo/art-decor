xquery version "1.0";
(:
	Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
	
	Author: Kai U. Heitmann
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
	
:)

(:
    Get number of milliseconds since 01-01-2000 00:00:00 (no parameter) 
    or the current time as string if parameter format is 'string'
:)
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace util = "http://exist-db.org/xquery/util";

let $format := request:get-parameter('format','') 

let $cm := if ($format='string') then util:system-dateTime() else xs:decimal ( ( util:system-dateTime() - xs:dateTime('2000-01-01T00:00:00') ) div xs:dayTimeDuration('PT1S') * 1000 )

return 
    <random>{$cm}</random>