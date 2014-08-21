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

declare namespace xis="http://art-decor.org/ns/xis";
(:let $account := 'art-decor':)
let $account := request:get-parameter('account','')
let $applications := doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:application
return
<applications>
{
for $application in $applications
return
<application id="{$application/@id}" name="{$application/@name}" url="{$application/@url}" organizationRegisterId="{$application/@organizationRegisterId}"/>
}
</applications>