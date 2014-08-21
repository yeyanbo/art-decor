xquery version "1.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xforms="http://www.w3.org/2002/xforms";



let $project := request:get-parameter('project','')
let $projectId := request:get-parameter('id','')
(:let $projectId :=''
let $project := 'sandbox-':)
let $decor :=
		if (string-length($project)>0) then
				$get:colDecorData//decor[project/@prefix=$project]
		else if (string-length($projectId)>0) then
				$get:colDecorData//decor[project/@id=$projectId]
		else()

let $root :=util:collection-name($decor)
let $runtimeColllection :=concat($root,'/',$decor/project/@prefix,'runtime-develop')

let $status :=
   if (xmldb:collection-available($runtimeColllection)) then
      let $mainTemplates :=xmldb:created($runtimeColllection,concat($decor/project/@prefix,'main-templates.xsl'))
      let $generatedTemplates :=xmldb:created($runtimeColllection,concat($decor/project/@prefix,'generated-templates.xsl'))
      let $generatedValuesets :=xmldb:created($runtimeColllection,concat($decor/project/@prefix,'generated-valuesets.xsl'))
      let $generatedXpaths :=xmldb:created($runtimeColllection,concat($decor/project/@prefix,'xpaths.xml'))
      let $allAvailable :=
         if (string-length($mainTemplates)>0 and string-length($generatedTemplates)>0 and string-length($generatedValuesets)>0 and string-length($generatedXpaths)>0) then
            true()
         else(false())
      return
      <status allAvailable="{$allAvailable}" projectPrefix="{$decor/project/@prefix}">
         <main created="{$mainTemplates}"/>
         <templates created="{$generatedTemplates}"/>
         <valuesets created="{$generatedValuesets}"/>
         <xpaths created="{$generatedXpaths}"/>
      </status>
   else(
      <status allAvailable="{false()}" projectPrefix="{$decor/project/@prefix}">
         <main created=""/>
         <templates created=""/>
         <valuesets created=""/>
         <xpaths created=""/>
      </status>
   )
return
$status