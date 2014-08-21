xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    
    Input: prefix, versionDate, language
    
    Xquery will create a collection in HL7 collection with:
    - eXist packaging (repo.xml, build.xml, expath-pkg.xml)
    - subcollection test_xslt, with {project}-tests.xml copied from release, if available
    - other necessary subcollections
    
    After this one will still need to:
    - import schematrons
    - import schemas
    - create test schematrons
    - create SVRL versions of all schematron
:)

import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "art-decor.xqm";

declare option exist:serialize "indent=yes";
declare option exist:serialize "omit-xml-declaration=no";

let $open-curly := '&#123;' (: for { :)
let $closed-curly := '&#125;' (: for } :)

let $prefix               := if (request:exists()) then request:get-parameter('prefix',()) else 'peri20-'
let $version              := if (request:exists()) then request:get-parameter('version',()) else '2014-04-16T16:02:11'
let $language             := if (request:exists()) then request:get-parameter('language',()) else 'nl-NL'

let $project        := $get:colDecorVersion//decor[project/@prefix=$prefix][@versionDate=$version][empty($language) or @language=$language][1]
let $timestamp      := translate($version, '-:', '')
let $releaseName    := concat($prefix, $timestamp)
let $targetDir      := xmldb:create-collection($get:strHl7, $releaseName)
let $releasedir     := concat('xmldb:exist://', util:collection-name($project))

let $xml :=
<project default="xar" name="{$releaseName}">
    <property name="project.version" value="{$timestamp}"/>
    <property name="project.app" value="{$releaseName}"/>
    <property name="build.dir" value="build"/>
    <target name="xar">
        <mkdir dir="${$open-curly}build.dir{$closed-curly}"/>
        <zip basedir="." destfile="${$open-curly}build.dir{$closed-curly}/${$open-curly}project.app{$closed-curly}-${$open-curly}project.version{$closed-curly}.xar" excludes="${$open-curly}build.dir{$closed-curly}/*"/>
    </target>
</project>
let $result := xmldb:store($targetDir, 'build.xml', $xml)

let $xml :=
<package xmlns="http://expath.org/ns/pkg" name="{concat('http://decor.nictiz.nl/', $releaseName)}" abbrev="{$releaseName}" version="{$timestamp}" spec="1.0">
    <title>{$releaseName}</title>
</package>
let $result := xmldb:store($targetDir, 'expath-pkg.xml', $xml)

let $xml :=
<meta xmlns="http://exist-db.org/xquery/repo">
    <description>{$releaseName}</description>
    <author/>
    <website/>
    <status>stable</status>
    <license>GNU-LGPL</license>
    <copyright>true</copyright>
    <type>library</type>
    <target>{concat(substring-after($get:strHl7, $get:root), $releaseName)}</target>
    <prepare/>
    <finish/>
    <permissions user="admin" password="" group="dba" mode="rw-rw-r--"/>
    <deployed>{substring-before(xs:string(current-dateTime()), '.')}</deployed>
</meta>
let $result := xmldb:store($targetDir, 'repo.xml', $xml)

let $testDir := xmldb:create-collection($targetDir, 'test_xslt')
let $result := if (doc-available(concat($releasedir, '/resources/', $prefix, 'tests.xml'))) then xmldb:copy(concat($releasedir, '/resources'), $testDir, concat($prefix, 'tests.xml')) else () 
let $result := xmldb:create-collection($targetDir, 'schematron_xslt')
let $result := xmldb:create-collection($targetDir, 'schemas_codeGen_flat')
let $result := xmldb:create-collection($targetDir, 'xml')
return concat($releaseName, ' created')