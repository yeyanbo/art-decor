xquery version "3.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Gerrit Boers
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)
module namespace dhd        = "http://art-decor.org/ns/terminology/dhd";
import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
declare variable $dhd:root := repo:get-root();

declare function dhd:getNextConceptNo()  as xs:integer {
   let $current := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//conceptNo
   let $next    := xs:integer($current) +1
   let $updateCounter := update value $current with $next
   return
   $next  
 } ;
 declare function dhd:getNextThesaurusId()  as xs:integer {
   let $current := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//conceptId
   let $next    := xs:integer($current) +1
   let $updateCounter := update value $current with $next
   return
   $next  
 } ;
 declare function dhd:getNextDescNo()  as xs:integer {
   let $current := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//descNo
   let $next    := xs:integer($current) +1
   let $updateCounter := update value $current with $next
   return
   $next  
 } ;
 declare function dhd:getNextInterfaceId()  as xs:integer {
   let $current := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//interfaceId
   let $next    := xs:integer($current) +1
   let $updateCounter := update value $current with $next
   return
   $next  
 } ;
 declare function dhd:getNextIcd10No()  as xs:integer {
   let $current := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//icd10No
   let $next    := xs:integer($current) +1
   let $updateCounter := update value $current with $next
   return
   $next  
 } ;
 declare function dhd:getNextDbcNo()  as xs:integer {
   let $current := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//dbcNo
   let $next    := xs:integer($current) +1
   let $updateCounter := update value $current with $next
   return
   $next  
 } ;
 declare function dhd:getNextDomainNo()  as xs:integer {
   let $current := collection(concat($get:strTerminologyData,'/dhd-data/meta'))//domainNo
   let $next    := xs:integer($current) +1
   let $updateCounter := update value $current with $next
   return
   $next  
 } ;

 declare function dhd:setDHDQueryPermissions() {
   for $query in xmldb:get-child-resources(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology/dhd/modules')))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology/dhd/modules/',$query)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology/dhd/modules/',$query)),'terminology'),
   if (starts-with($query,('check','get','retrieve','search'))) then
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology/dhd/modules/',$query)),sm:octal-to-mode('0755'))
   else(sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology/dhd/modules/',$query)),sm:octal-to-mode('0754')))
   ,
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology/dhd/modules/',$query)))
   )
};

declare function dhd:setDHDCollectionPermissions() {

   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data'))),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/history')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/history')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/history')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/history'))),
   for $resource in xmldb:get-child-resources(concat($dhd:root,'terminology-data/dhd-data/history'))
   return
      (
      sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/history/',$resource)),'admin'),
      sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/history/',$resource)),'terminology'),
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/history/',$resource)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/history/',$resource)))
      ),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/legacy')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/legacy')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/legacy')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/legacy'))),
   for $resource in xmldb:get-child-resources(concat($dhd:root,'terminology-data/dhd-data/legacy'))
   return
      (
      sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/legacy/',$resource)),'admin'),
      sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/legacy/',$resource)),'terminology'),
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/legacy/',$resource)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/legacy/',$resource)))
      ),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/log')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/log')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/log')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/log'))),
   for $resource in xmldb:get-child-resources(concat($dhd:root,'terminology-data/dhd-data/log'))
      return
      (
      sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/log/',$resource)),'admin'),
      sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/log/',$resource)),'terminology'),
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/log/',$resource)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/log/',$resource)))
      ),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/meta')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/meta')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/meta')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/meta'))),
   for $resource in xmldb:get-child-resources(concat($dhd:root,'terminology-data/dhd-data/meta'))
   return
      (
      sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/meta/',$resource)),'admin'),
      sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/meta/',$resource)),'terminology'),
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/meta/',$resource)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/meta/',$resource)))
      ),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/reference')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/reference')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/reference')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/reference'))),
   for $resource in xmldb:get-child-resources(concat($dhd:root,'terminology-data/dhd-data/reference'))
   return
      (
      sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/reference/',$resource)),'admin'),
      sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/reference/',$resource)),'terminology'),
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/reference/',$resource)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/reference/',$resource)))
      ),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/releases')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/releases')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/releases')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/releases'))),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/thesaurus')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/thesaurus')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/thesaurus')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/thesaurus'))),
   for $resource in xmldb:get-child-resources(concat($dhd:root,'terminology-data/dhd-data/thesaurus'))
   return
      (
      sm:chown(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/thesaurus/',$resource)),'admin'),
      sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/thesaurus/',$resource)),'terminology'),
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/thesaurus/',$resource)),sm:octal-to-mode('0664')),
      sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$dhd:root,'terminology-data/dhd-data/thesaurus/',$resource)))
      )
   
};
