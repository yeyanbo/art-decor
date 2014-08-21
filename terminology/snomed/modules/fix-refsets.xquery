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

let $moduleId:= '11000146104'
let $languageRefsetId :='31000146106'
for $refset in collection(concat($get:strTerminologyData,'/snomed-extension/refsets'))//refset
let $refsetId := $refset/@id
return
(
    (:add @moduleId to refset if not present:)
    if (not($refset/@moduleId)) then
      update insert attribute moduleId {$moduleId} into $refset
    else(),
    (:delete all retired members where an active concept exists:)
    for $member in $refset//member[@statusCode=('new','cancelled','retired')]
    return
    update delete $member
    ,
    (:
    For each desc
    check if uuid present, if not add and set with memberId value
    :)
    for $desc in $refset//desc[@memberId][not(@uuid)]
    return
    update insert attribute uuid {$desc/@memberId} into $desc
    ,
    (:
    For each desc
    check if @effectiveTime set, if not set with effectiveDate
    :)
    for $desc in $refset//desc[string-length(@effectiveTime)=0][string-length(@effectiveDate) gt 0]
    return
    update value $desc/@effectiveTime with $desc/@effectiveDate
    ,
    (:
    For each desc
    where @uuid=@memberId delete @memberId
    :)
    for $desc in $refset//desc[@uuid=@memberId]
    return
    update delete $desc/@memberId
)