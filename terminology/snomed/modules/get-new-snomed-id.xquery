xquery version "3.0";
(:
    Copyright (C) 2013 Art Decor Expert Group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    
    
    
    
    Query for generating SNOMED-CT ID's
    Use Verhoeff algorithm for checkdigit generation.
    See: http://en.wikipedia.org/wiki/Verhoeff_algorithm
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
(:multiplication table:)
declare variable $verhoeff_D := 
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
declare variable $verhoeff_P := 
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
declare variable $verhoeff_inv := (0,4,3,2,1,5,6,7,8,9);

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
   let $newC := $verhoeff_D/row[($c + 1)]/col[($verhoeff_P/row[(($index mod 8) + 1)]/col[(xs:integer($myArray[($index + 1)]) + 1)] + 1)]
   return
   if ($index lt count($myArray)-1) then
      local:validateLoop($newC,$myArray,($index + 1))
   else ($newC)
};

declare function local:generateVerhoeff($string as xs:integer) as xs:integer{
   let $myArray := reverse(local:chars($string))
   return
   $verhoeff_inv[(local:generateLoop(0,$myArray,0) +1)]
};

declare function local:generateLoop ($c as xs:integer,$myArray as item()*,$index as xs:integer) as xs:integer {
   let $newC := $verhoeff_D/row[($c + 1)]/col[($verhoeff_P/row[((($index + 1) mod 8) + 1)]/col[(xs:integer($myArray[($index + 1)]) + 1)] + 1)]
   return
   if ($index lt count($myArray)-1) then
      local:generateLoop($newC,$myArray,($index + 1))
   else ($newC)
};


(:
   checkDigit tests
   75872 == 2
   12345 == 1
   142857 == 0
   123456789012 == 0
   8473643095483728456789 == 2
:)
(:let $test:= 8473643095483728456789:)
(:let $namespace := '1000147'
let $partition := '10':)

let $namespace := request:get-parameter('namespace','')
let $partition := request:get-parameter('partition','')

let $namespaces := doc(concat($get:strTerminologyData,'/snomed-refsets/core/snomed-ids.xml'))/namespaces

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

