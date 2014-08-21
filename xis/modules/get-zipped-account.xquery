xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Maarten Ligtvoet
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
declare namespace compression="http://exist-db.org/xquery/compression";
declare option exist:serialize "method=text media-type=application/zip,application/octet-stream charset=utf-8";

(:which xis-data/accounts/ account do we want to download?:)
let $account     := if (request:exists()) then request:get-parameter('account','') else ''
(:the collection we want to zip, for now only messages:)
let $accountPath := concat($get:strXisAccounts, '/', $account,'/messages')
(:set date to a variable:)
let $date := datetime:format-dateTime(current-dateTime(),'yyyyMMdd-HHmm')

(: todo: would like to get all folders at once but then filename collisions occur, same filename in /messages and /reports:)
(:let $attachments := concat($get:strXisAccounts, '/', $account, '/attachments')
let $reports     := concat($get:strXisAccounts, '/', $account, '/reports')
let $testseries  := concat($get:strXisAccounts, '/', $account, '/testseries.xml'):)

(:create response which contains zip:)
return
   (
   response:set-header("Content-Disposition", concat('attachment; filename=xis_',$account,'_',$date,'.zip'))
   ,
   response:stream-binary(
       compression:zip( xs:anyURI($accountPath), false() ),
       'application/zip',
       concat('xis_',$account,'_',$date,'.zip')
       )
   )