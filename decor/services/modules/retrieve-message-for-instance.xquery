xquery version "1.0";
(:
	Author: Marc de Graauw
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get  = "http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
import module namespace arti = "http://art-decor.org/ns/art/instance" at  "../../../art/modules/art-decor-instance.xqm";

declare namespace hl7        = "urn:hl7-org:v3";
declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

let $collection    := collection($get:strDecorData)
let $id            := request:get-parameter('id','') 
(:let $id := '2.16.840.1.113883.2.4.3.36.77.19.2':)
let $instance      := $collection/descendant-or-self::*[@id=$id][1] (: Adding [1] to select the first item, ideally ids should be unique:)
let $projectPrefix := $instance/ancestor::decor/project/@prefix
let $path          := concat('xmldb:exist://', util:collection-name($instance), '/')
let $runtimedir    := concat($projectPrefix, 'runtime-develop/')
(:let $messagedir    := concat($runtimedir, 'messages/'):)
(:let $dummy         := 
    if (not(xmldb:collection-available(concat($path, $messagedir))))
    then xmldb:create-collection($path, $messagedir) 
    else ():)
let $stylesheet    := concat($path, $runtimedir, $projectPrefix, 'main-templates.xsl')

let $defaultInstance := 
    if(name($instance) = 'instance' and $instance/@role='example') 
    then
        let $transaction := $collection//scenario[@id=$instance/../@ref]/transaction/transaction[@type='initial']
        let $instanceDocument := arti:mergeInstanceWithTransaction($collection, $instance, $transaction)
        return arti:generateInstance($collection, $instanceDocument, $instanceDocument/@role) 
    else <error>Not an example instance</error>

(:return $defaultInstance :)
let $result := transform:transform($defaultInstance, doc($stylesheet), ())
(:let $stored-doc := xmldb:store(concat($path, $messagedir), concat($projectPrefix, $id, '.xml'), $result, '.xml'):)
return
$result