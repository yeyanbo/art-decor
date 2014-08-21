xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace aduser   = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../api/api-server-settings.xqm";

declare namespace session      = "http://exist-db.org/xquery/session";
declare namespace xhtml        = "http://www.w3.org/1999/xhtml";

(: 
   Get form name and decor document prefix
   ! This needs to be changed to use a request parameter for the decor project prefix
:)
let $fullForm := request:get-parameter('form','home')

let $formName := 
    if (contains(request:get-parameter('form',('home')),'--')) then
        substring-before(request:get-parameter('form',('home')),'--')
    else (
        request:get-parameter('form',('home'))
    )	

let $document := 
    if (contains(request:get-parameter('form',('home')),'--')) then
        substring-after(request:get-parameter('form',('home')),'--')
    else (
        string('')
    )	


(: Get user info for access control, user preferences and display :)
let $user             := xmldb:get-current-user()
let $userDisplayName  := 
    try {
        if ($user='guest' or aduser:getUserDisplayName($user)[string-length()=0]) then
            $user
        else (
            aduser:getUserDisplayName($user)
        )
    }
    catch * {
        $user
    }
let $groups           := sm:get-user-groups($user)

(: get package list and create lookup list for xforms :)
(:let $resourcesList := collection($get:root)//artXformResources:)
(:let $fullFormPath :=   
    for $resources in $resourcesList
    let $root := substring-before(util:collection-name($resources),'/resources')
    let $list := 
        for $form in collection(concat($root,'/xforms'))//xhtml:html
        return
            <form name="{substring-before(util:document-name($form),'.xhtml')}" path="{concat(util:collection-name($form),'/',util:document-name($form))}"/>
    return
        $list:)
let $fullFormPath := 
    for $form in collection($get:root)//xhtml:html[ends-with(util:collection-name(.),'/xforms')]
    return
        <form name="{substring-before(util:document-name($form),'.xhtml')}" path="{concat(util:collection-name($form),'/',util:document-name($form))}"/>


let $form := doc($fullFormPath[@name=$formName]/@path)
let $xsltParameters :=	
    <parameters>
        <param name="current-application" value="{$formName}"/>
        <param name="user" value="{$userDisplayName}"/>
        <param name="group" value="{$groups}"/>
        <param name="document" value="{$document}"/>
        <param name="cameFromUri" value="{$fullForm}"/>
    </parameters>

let $xformStylesheet := adserver:getServerXSLArt()
let $xformStylesheet := if (string-length($xformStylesheet)=0) then 'apply-rules.xsl' else ($xformStylesheet)

return
(:$content:)
transform:transform($form, xs:anyURI(concat('xmldb:exist://',$get:strArtResources,'/stylesheets/',$xformStylesheet)), $xsltParameters)