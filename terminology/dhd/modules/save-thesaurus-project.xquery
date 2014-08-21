xquery version "1.0";
(:
	Copyright (C) 2011-2013 Art Decor Expert Group art-decor.org
	
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
import module namespace art ="http://art-decor.org/ns/art" at "../../../art/modules/art-decor.xqm";

let $editedProject := request:get-data()/project
(:let $editedProject :=
<project>
    <author id="1" username="admin" admin="true" authorize="false" edit="false" issues="false">Admin</author>
    <author id="2" username="gerrit" admin="true" authorize="true" edit="true" issues="true">Gerrit Boers</author>
    <author id="3" username="guest" admin="false" authorize="false" edit="false" issues="false">Guest</author>
    <release effectiveDate="2013-12-26" label="december 2013">
        <comment>Optioneel <i>commentaar</i> bij deze release</comment>
    </release>
</project>:)

let $storedProject := collection(concat($get:strTerminologyData,'/dhd-data/meta'))/project
let $user           := xmldb:get-current-user()

let $preparedProject :=
   <project>
   {
   $editedProject/author,
      for $release in $editedProject/release
   return
   <release>
   {
   $release/@*,
   for $comment in $release/comment
   return
   art:parseNode($comment)
   }
   </release>
   }
   </project>

let $projectUpdate :=
   if ($storedProject/author[@username=$user][@admin='true']) then
       let $update := update value $storedProject with $preparedProject/*
       return
       'OK'
   else('NO PERMISSION')


return
<data-safe>{if ($projectUpdate='OK') then 'true' else 'false'}</data-safe>