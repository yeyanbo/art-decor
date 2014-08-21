xquery version "1.0";
(:
    Copyright (C) 2011
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)


declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace UML="omg.org/UML1.3";
declare namespace xs="http://www.w3.org/2001/XMLSchema";

let $dcmcollection := ('/db/apps/DCM/xmi')

let $allAuthors := collection($dcmcollection)//UML:TaggedValue[@tag='DCM::ContentAuthorList']
let $authorList :=
for $author in distinct-values($allAuthors/@value/string())
order by $author
return
$author

let $allDcms := collection($dcmcollection)//XMI
let $decor:= collection('/db/apps/decor/data/')//decor[project/@prefix='psi-']
let $deleteExistingConcepts := update delete $decor/datasets/dataset/concept

let $test :=transform:transform($allDcms[1],xs:anyURI("xmldb:exist:///db/apps/DCM/dcmXMI-2-Decor.xsl"),<parameters/>)
return
for $dcm in $allDcms
return
update insert transform:transform($dcm,xs:anyURI("xmldb:exist:///db/apps/DCM/dcmXMI-2-Decor.xsl"),<parameters/>) into $decor/datasets/dataset



