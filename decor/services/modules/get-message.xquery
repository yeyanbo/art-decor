xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
	
:)
module namespace f="urn:decor:REST:v1";

declare function f:getMessage($key as xs:string,$language as xs:string) as xs:string {
    f:getMessage($key,$language,'','','','')
};
declare function f:getMessage($key as xs:string,$language as xs:string,$p1 as xs:string?) as xs:string {
    f:getMessage($key,$language,$p1,'','','')
};
declare function f:getMessage($key as xs:string,$language as xs:string,$p1 as xs:string?,$p2 as xs:string?) as xs:string {
    f:getMessage($key,$language,$p1,$p2,'','')
};
declare function f:getMessage($key as xs:string,$language as xs:string,$p1 as xs:string?,$p2 as xs:string?,$p3 as xs:string?) as xs:string {
    f:getMessage($key,$language,$p1,$p2,$p3,'')
};
declare function f:getMessage($key as xs:string,$language as xs:string,$p1 as xs:string?,$p2 as xs:string?,$p3 as xs:string?,$p4 as xs:string?) as xs:string {
    let $theMESSAGES := doc('REST-i18n.xml')
    let $defaultLanguage := 'nl-NL'
    let $tmp1 :=
        if ($theMESSAGES/*/entry[@key=$key]/text[@language=$language]) then (
            $theMESSAGES/*/entry[@key=$key]/text[@language=$language]/node()
        ) else if ($theMESSAGES/*/entry[@key=$key]/text[@language=$defaultLanguage]) then (
            $theMESSAGES/*/entry[@key=$key]/text[@language=$defaultLanguage]/node()
        ) else if ($theMESSAGES/*/entry[@key=$key]/text[@language='en-US']) then (
            $theMESSAGES/*/entry[@key=$key]/text[@language='en-US']/node()
        ) else (
            concat('NOT FOUND in messages: MESSAGE key=',$key,' p1=%%1 p2=%%2 p3=%%3 p4=%%4')
        )
    let $tmp2 := if (not(empty($p1))) then (replace($tmp1, '%%1', $p1)) else (replace($tmp1, '%%1', ''))
    let $tmp3 := if (not(empty($p2))) then (replace($tmp2, '%%2', $p2)) else (replace($tmp2, '%%2', ''))
    let $tmp4 := if (not(empty($p3))) then (replace($tmp3, '%%3', $p3)) else (replace($tmp3, '%%3', ''))
    let $tmp5 := if (not(empty($p4))) then (replace($tmp4, '%%4', $p4)) else (replace($tmp4, '%%4', ''))
    return $tmp5
};