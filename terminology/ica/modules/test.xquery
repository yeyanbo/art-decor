xquery version "1.0";
(:
	Copyright (C) 2014 Art-Decor Expert Group
	
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
declare variable $root := repo:get-root();

 declare function local:setCIlistQueryPermissions() {
   for $query in xmldb:get-child-resources(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/ica/modules')))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/ica/modules/',$query)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/ica/modules/',$query)),'terminology'),
   if (starts-with($query,('check','get','retrieve','search'))) then
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/ica/modules/',$query)),sm:octal-to-mode('0755'))
   else(sm:chmod(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/ica/modules/',$query)),sm:octal-to-mode('0754')))
   ,
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$root,'terminology/ica/modules/',$query)))
   )
};

let $missingCIC  := collection(concat($get:strTerminologyData,'/ica-data/concepts'))//ci[not(cic)]
let $currentDate :=datetime:format-date(current-date(),"yyyy-MM-dd")
return
for $ci in $missingCIC
let $cic :=  
   <cic id="{util:uuid()}" code="" statusCode="draft" effectiveDate="" expirationDate="" editDate="{$currentDate}">
      <desc></desc>
   </cic>
return
update insert $cic into $ci
