xquery version "1.0";
(:
	Copyright (C) 2012-2013 Art Decor Expert Group
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace xdb="http://exist-db.org/xquery/xmldb";
import module namespace sm = "http://exist-db.org/xquery/securitymanager";
import module namespace repo="http://exist-db.org/xquery/repo";
import module namespace dhd ="http://art-decor.org/ns/terminology/dhd" at "dhd/api/api-dhd.xqm";
import module namespace snomed ="http://art-decor.org/ns/terminology/snomed" at "snomed/api/api-snomed.xqm";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
(:install path for art (/db, /db/apps), no trailing slash :)
declare variable $root := repo:get-root();

declare function local:copyInstallData() {
   (
   xdb:copy(concat($root,'terminology/install-data'),concat($root,'terminology-data/snomed-extension/core'),'refset.xsd')
   ,
   if (not(doc-available(concat($root,'terminology-data/snomed-extension/core/snomed-ids.xml')))) then
   xdb:copy(concat($root,'terminology/install-data'),concat($root,'terminology-data/snomed-extension/core'),'snomed-ids.xml')
   else()
   )
 };


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

(: check if message collection exists, if not then create and set permissions :)
local:copyInstallData(),
dhd:setDHDCollectionPermissions(),
dhd:setDHDQueryPermissions(),
snomed:setSCTExtensionCollectionPermissions(),
snomed:setSCTQueryPermissions(),
local:setCIlistQueryPermissions()

