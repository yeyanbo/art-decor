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
    Random String Generator

    This function returns a <random> element with a randomized string as element content
    in the format r-x where x is a UUID
:)

declare namespace util = "http://exist-db.org/xquery/util";

let $x := util:uuid()
return
    <random>r-{$x}</random>