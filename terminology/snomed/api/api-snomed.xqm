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
module namespace snomed      = "http://art-decor.org/ns/terminology/snomed";

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";

declare variable $snomed:root := repo:get-root();
(:variables containing tables for Verhoeff test:)
declare variable $snomed:verhoeff_D := 
    <table>
      <row>
          <col>0</col>
          <col>1</col>
          <col>2</col>
          <col>3</col>
          <col>4</col>
          <col>5</col>
          <col>6</col>
          <col>7</col>
          <col>8</col>
          <col>9</col>
      </row>
      <row>
          <col>1</col>
          <col>2</col>
          <col>3</col>
          <col>4</col>
          <col>0</col>
          <col>6</col>
          <col>7</col>
          <col>8</col>
          <col>9</col>
          <col>5</col>
      </row>
      <row>
          <col>2</col>
          <col>3</col>
          <col>4</col>
          <col>0</col>
          <col>1</col>
          <col>7</col>
          <col>8</col>
          <col>9</col>
          <col>5</col>
          <col>6</col>
      </row>
      <row>
          <col>3</col>
          <col>4</col>
          <col>0</col>
          <col>1</col>
          <col>2</col>
          <col>8</col>
          <col>9</col>
          <col>5</col>
          <col>6</col>
          <col>7</col>
      </row>
      <row>
          <col>4</col>
          <col>0</col>
          <col>1</col>
          <col>2</col>
          <col>3</col>
          <col>9</col>
          <col>5</col>
          <col>6</col>
          <col>7</col>
          <col>8</col>
      </row>
      <row>
          <col>5</col>
          <col>9</col>
          <col>8</col>
          <col>7</col>
          <col>6</col>
          <col>0</col>
          <col>4</col>
          <col>3</col>
          <col>2</col>
          <col>1</col>
      </row>
      <row>
          <col>6</col>
          <col>5</col>
          <col>9</col>
          <col>8</col>
          <col>7</col>
          <col>1</col>
          <col>0</col>
          <col>4</col>
          <col>3</col>
          <col>2</col>
      </row>
      <row>
          <col>7</col>
          <col>6</col>
          <col>5</col>
          <col>9</col>
          <col>8</col>
          <col>2</col>
          <col>1</col>
          <col>0</col>
          <col>4</col>
          <col>3</col>
      </row>
      <row>
          <col>8</col>
          <col>7</col>
          <col>6</col>
          <col>5</col>
          <col>9</col>
          <col>3</col>
          <col>2</col>
          <col>1</col>
          <col>0</col>
          <col>4</col>
      </row>
      <row>
          <col>9</col>
          <col>8</col>
          <col>7</col>
          <col>6</col>
          <col>5</col>
          <col>4</col>
          <col>3</col>
          <col>2</col>
          <col>1</col>
          <col>0</col>
      </row>
   </table>;
(:permutation table:)
declare variable $snomed:verhoeff_P := 
   <table>
      <row>
          <col>0</col>
          <col>1</col>
          <col>2</col>
          <col>3</col>
          <col>4</col>
          <col>5</col>
          <col>6</col>
          <col>7</col>
          <col>8</col>
          <col>9</col>
      </row>
      <row>
          <col>1</col>
          <col>5</col>
          <col>7</col>
          <col>6</col>
          <col>2</col>
          <col>8</col>
          <col>3</col>
          <col>0</col>
          <col>9</col>
          <col>4</col>
      </row>
      <row>
          <col>5</col>
          <col>8</col>
          <col>0</col>
          <col>3</col>
          <col>7</col>
          <col>9</col>
          <col>6</col>
          <col>1</col>
          <col>4</col>
          <col>2</col>
      </row>
      <row>
          <col>8</col>
          <col>9</col>
          <col>1</col>
          <col>6</col>
          <col>0</col>
          <col>4</col>
          <col>3</col>
          <col>5</col>
          <col>2</col>
          <col>7</col>
      </row>
      <row>
          <col>9</col>
          <col>4</col>
          <col>5</col>
          <col>3</col>
          <col>1</col>
          <col>2</col>
          <col>6</col>
          <col>8</col>
          <col>7</col>
          <col>0</col>
      </row>
      <row>
          <col>4</col>
          <col>2</col>
          <col>8</col>
          <col>6</col>
          <col>5</col>
          <col>7</col>
          <col>3</col>
          <col>9</col>
          <col>0</col>
          <col>1</col>
      </row>
      <row>
          <col>2</col>
          <col>7</col>
          <col>9</col>
          <col>3</col>
          <col>8</col>
          <col>0</col>
          <col>6</col>
          <col>4</col>
          <col>1</col>
          <col>5</col>
      </row>
      <row>
             <col>7</col>
             <col>0</col>
             <col>4</col>
             <col>6</col>
             <col>9</col>
             <col>1</col>
             <col>3</col>
             <col>2</col>
             <col>5</col>
             <col>8</col>
         </row>
</table>;
(:inverse table:)
declare variable $snomed:verhoeff_inv := (0,4,3,2,1,5,6,7,8,9);

(: copied from functx, turns a string into a sequence of characters :)
declare function local:chars( $arg as xs:string? )  as xs:string* {
   for $ch in string-to-codepoints($arg)
   return codepoints-to-string($ch)
 } ;

declare function local:validateVerhoeff ($string as xs:integer) as xs:boolean{
   let $myArray := reverse(local:chars($string))
   return
      if (local:validateLoop(0,$myArray,0)=0) then
         xs:boolean('true')
      else(xs:boolean('false'))
};

declare function local:validateLoop ($c as xs:integer,$myArray as item()*,$index as xs:integer) as xs:integer {
   let $newC := $snomed:verhoeff_D/row[($c + 1)]/col[($snomed:verhoeff_P/row[(($index mod 8) + 1)]/col[(xs:integer($myArray[($index + 1)]) + 1)] + 1)]
   return
   if ($index lt count($myArray)-1) then
      local:validateLoop($newC,$myArray,($index + 1))
   else ($newC)
};

declare function local:generateVerhoeff($string as xs:integer) as xs:integer{
   let $myArray := reverse(local:chars($string))
   return
   $snomed:verhoeff_inv[(local:generateLoop(0,$myArray,0) +1)]
};

declare function local:generateLoop ($c as xs:integer,$myArray as item()*,$index as xs:integer) as xs:integer {
   let $newC := $snomed:verhoeff_D/row[($c + 1)]/col[($snomed:verhoeff_P/row[((($index + 1) mod 8) + 1)]/col[(xs:integer($myArray[($index + 1)]) + 1)] + 1)]
   return
   if ($index lt count($myArray)-1) then
      local:generateLoop($newC,$myArray,($index + 1))
   else ($newC)
};

declare function snomed:generateSCTID($namespace as xs:integer,$partition as xs:integer) as element() {
   let $namespaces := doc(concat($get:strTerminologyData,'/snomed-extension/core/snomed-ids.xml'))/namespaces
   let $response :=
      (: check if namespace is valid  :)
      if($namespace=$namespaces/namespace/@id) then
         (: check if partition is valid  :)
         if ($partition=$namespaces/namespace[@id=$namespace]/partition/@id) then
            let $counter := $namespaces/namespace[@id=$namespace]/partition[@id=$partition]/@counter
            return
            (: check if there are still ids left  :)
            if (xs:integer($counter) lt 100000000) then
               let $id := concat($counter,$namespace,$partition)
               let $checkDigit := local:generateVerhoeff($id)
               let $updateCounter := update value $counter with xs:integer($counter) + 1
               let $newId := concat($id,$checkDigit)
               let $idInsert := update insert <id id="{$newId}" effectiveDate="{current-dateTime()}" user="{xmldb:get-current-user()}"/> into $namespaces/namespace[@id=$namespace]/partition[@id=$partition]
               return
               <id>{$newId}</id>
            else(<error>NO MORE IDS LEFT</error>)
         else(<error>INVALID PARTITION</error>)
      else(<error>INVALID NAMESPACE</error>)
   
   return
   <response>{$response}</response>
};



 declare function snomed:setSCTQueryPermissions() {
   for $query in xmldb:get-child-resources(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology/snomed/modules')))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology/snomed/modules/',$query)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology/snomed/modules/',$query)),'terminology'),
   if (starts-with($query,('check','get','is-','retrieve','search','view'))) then
      sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology/snomed/modules/',$query)),sm:octal-to-mode('0755'))
   else(sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology/snomed/modules/',$query)),sm:octal-to-mode('0754')))
   ,
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology/snomed/modules/',$query)))
   )
};


declare function snomed:setSCTExtensionCollectionPermissions() {

   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension'))),
    
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/concepts')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/concepts')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/concepts')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/concepts'))),
   
   if (xmldb:collection-available(concat($snomed:root,'terminology-data/snomed-extension/concepts'))) then
   for $resource in xmldb:get-child-resources(concat($snomed:root,'terminology-data/snomed-extension/concepts'))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/concepts/',$resource)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/concepts/',$resource)),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/concepts/',$resource)),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/concepts/',$resource)))
   )
   else(),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/descriptions')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/descriptions')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/descriptions')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/descriptions'))),
   
   if (xmldb:collection-available(concat($snomed:root,'terminology-data/snomed-extension/descriptions'))) then
   for $resource in xmldb:get-child-resources(concat($snomed:root,'terminology-data/snomed-extension/descriptions'))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/descriptions/',$resource)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/descriptions/',$resource)),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/descriptions/',$resource)),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/descriptions/',$resource)))
   )
   else(),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/core')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/core')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/core')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/core'))),
   
   if (xmldb:collection-available(concat($snomed:root,'terminology-data/snomed-extension/core'))) then
   for $resource in xmldb:get-child-resources(concat($snomed:root,'terminology-data/snomed-extension/core'))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/core/',$resource)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/core/',$resource)),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/core/',$resource)),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/core/',$resource)))
   )
   else(),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/history')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/history')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/history')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/history'))),
   
   if (xmldb:collection-available(concat($snomed:root,'terminology-data/snomed-extension/history'))) then
   for $resource in xmldb:get-child-resources(concat($snomed:root,'terminology-data/snomed-extension/history'))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/history/',$resource)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/history/',$resource)),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/history/',$resource)),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/history/',$resource)))
   )
   else(),

   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/import')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/import')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/import')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/import'))),
      

   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/log')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/log')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/log')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/log'))),
      
   if (xmldb:collection-available(concat($snomed:root,'terminology-data/snomed-extension/log'))) then
   for $resource in xmldb:get-child-resources(concat($snomed:root,'terminology-data/snomed-extension/log'))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/log/',$resource)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/log/',$resource)),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/log/',$resource)),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/log/',$resource)))
   )
   else(),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/meta')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/meta')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/meta')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/meta'))),
      
   if (xmldb:collection-available(concat($snomed:root,'terminology-data/snomed-extension/meta'))) then
   for $resource in xmldb:get-child-resources(concat($snomed:root,'terminology-data/snomed-extension/meta'))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/meta/',$resource)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/meta/',$resource)),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/meta/',$resource)),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/meta/',$resource)))
   )
   else(),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/releases')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/releases')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/releases')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/releases'))),
   
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/refsets')),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/refsets')),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/refsets')),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/refsets'))),
   
   if (xmldb:collection-available(concat($snomed:root,'terminology-data/snomed-extension/refsets'))) then
   for $resource in xmldb:get-child-resources(concat($snomed:root,'terminology-data/snomed-extension/refsets'))
   return
   (
   sm:chown(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/refsets/',$resource)),'admin'),
   sm:chgrp(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/refsets/',$resource)),'terminology'),
   sm:chmod(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/refsets/',$resource)),sm:octal-to-mode('0775')),
   sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$snomed:root,'terminology-data/snomed-extension/refsets/',$resource)))
   )
   else()

   
};