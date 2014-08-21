xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

(:
   Xquery for setting template statusCode
   Input: post of template
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art ="http://art-decor.org/ns/art" at "art-decor.xqm";


let $template := request:get-data()/template
let $lock           := $get:colArtResources//lock[@ref=$template/lock/@ref][@effectiveDate=$template/lock/@effectiveDate]

(:get decor file for permission check:)
let $decor :=$get:colDecorData//template[@id=$template/@id][@effectiveDate=$template/@effectiveDate]/ancestor::decor
(: get user for permission check:)
let $user := xmldb:get-current-user()

let $statusUpdate :=
   if ($user=$decor/project/author/@username) then
      if (not($lock)) then
      let $storedTemplate := $get:colDecorData//template[@id=$template/@id][@effectiveDate=$template/@effectiveDate]
      return
      (
      if (string-length(normalize-space($template/@versionLabel)) gt 0 and $template/@statusCode='active') then
         if ($storedTemplate/@versionLabel) then
            update value $storedTemplate/@versionLabel with $template/@versionLabel
         else(update insert $template/@versionLabel into $storedTemplate)
      else(),
      if (string-length(normalize-space($template/@expirationDate)) gt 0) then
         let $expirationDate :=
               if (string-length(normalize-space($template/@expirationDate))=10) then
                  concat($template/@expirationDate,'T00:00:00')
               else($template/@expirationDate)
         return
         if ($storedTemplate/@expirationDate) then
            update value $storedTemplate/@expirationDate with $expirationDate
         else(update insert attribute expirationDate {$expirationDate} into $storedTemplate)
      else()
      ,
      update value $storedTemplate/@statusCode with $template/@statusCode/string(),
      <response>OK</response>
      )
      else(<response>{$lock}</response>)
      
   else(<response>NO PERMISSION</response>)
return
$statusUpdate