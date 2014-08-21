xquery version "3.0";
(:
	Copyright (C) 2011-2013 Art-Decor Expert Group
	
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
declare namespace compression="http://exist-db.org/xquery/compression";
declare option exist:serialize "method=text media-type=text/csv charset=utf-8";



let $releaseFile := doc(concat($get:strTerminologyData,'/dhd-data/releases/20140108/20140108_HT_Interface.xml'))/*

return
      (
      response:set-header("Content-Disposition", concat('attachment; filename=release_','test','.txt')),
      concat(
         string-join(
            for $column in $releaseFile/row[1]/*
            return
            concat('"',$column/name(),'"')
         ,',')
         ,'&#13;&#10;')
       ,
       for $row in $releaseFile/row
       return
         concat(
         string-join(
          for $rowColumn in $row/*
          let $string := if ($rowColumn/@type='string') then concat('"',$rowColumn/text(),'"') else if (string-length($rowColumn)=0) then '' else $rowColumn/text()
          return
          $string
                   ,',')
         ,'&#13;&#10;')
       )