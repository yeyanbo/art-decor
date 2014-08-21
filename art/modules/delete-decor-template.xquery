xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
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
let $templateName := request:get-parameter('template','')
let $effectiveDate := request:get-parameter('effectiveDate','')
(:let $templateName :='bloedgroep'
let $effectiveDate :='2013-01-30T16:27:09' :)

let $template := $get:colDecorData//template[@name=$templateName][@effectiveDate=$effectiveDate][@statusCode='new']
let $templateAssociations := $get:colDecorData//templateAssociation[@templateId=$template/@id][@effectiveDate=$effectiveDate]
return
(
    update delete $templateAssociations,
    update delete $template
)