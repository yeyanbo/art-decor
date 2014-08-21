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
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

let $request := request:get-data()/issue
(:let $request :=
        <issue id="2.16.840.1.113883.2.4.6.99.1.77.6.5" priority="N" displayName="test" type="RFC">
            <object id="2.16.840.1.113883.2.4.6.99.1.77.2.20000" type="DE" effectiveDate="2010-09-24"/>
            <tracking effectiveDate="2012-01-19T13:36:40.291+01:00" statusCode="open">
                <author id="2">Gerrit Boers</author>
                <desc language="nl-NL">dfbsdfg<b>sadfgdsfg</b>
                    <sub>d</sub>
                </desc>
            </tracking>
        </issue>:)

let $storedIssue := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//issue[@id=$request/@id]
let $user         := xmldb:get-current-user()
let $project      := collection(concat($get:strTerminologyData,'/snomed-extension/meta'))//project[@ref=$storedIssue/parent::issues/@ref]
let $issueCreator := xs:boolean($project/author[@username=$user]/@issues)

        
let $update :=
    <issue id="{$request/@id}" priority="{$request/@priority}" displayName="{$request/@displayName}" type="{$request/@type}">
    {
        for $object in $request/object
        return
            <object id="{$object/@id}" type="{$object/@type}" effectiveDate="{$object/@effectiveDate}"/>
            ,
            for $event in $request/tracking|$request/assignment
            order by xs:dateTime($event/@effectiveDate) ascending
            return
                if (name($event)='tracking') then
                    <tracking effectiveDate="{$event/@effectiveDate}" statusCode="{$event/@statusCode}">
                    {$event/author}
                    {
                        for $desc in $event/desc
                        return
                        art:parseNode($desc)
                    }
                    </tracking>
                else if (name($event)='assignment') then
                    <assignment to="{$event/@to}" name="{$event/@name}" effectiveDate="{$event/@effectiveDate}">
                    {$event/author}
                    {
                        for $desc in $event/desc
                        return
                        art:parseNode($desc)
                    }
                    </assignment>
                else()
    }
    </issue>

return
<response>
   {
   if ($issueCreator) then
      update replace $storedIssue with $update
   else('NO PERMISSION')
   }
</response>