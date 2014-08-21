xquery version "1.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

(: scans the database for artXformResources and returns a list of package roots with package title and abbreviation:)
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
declare namespace expath    = "http://expath.org/ns/pkg";

<packageRoots>
{
   for $package in xmldb:get-child-collections($get:strDecorData)
   let $abbrev      := $package
   let $expath-file := concat($get:strDecorData,'/',$package,'/expath-pkg.xml')
   let $title       := if (doc-available($expath-file)) then doc($expath-file)//expath:title else ($abbrev)
   return
   <root abbrev="{$abbrev}" title="{$title}"/>
}
</packageRoots>