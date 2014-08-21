xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
let $templateAssociation    := request:get-data()/templateAssociation
(:let $templateAssociation :=
<templateAssociation projectPrefix="demo1-" templateId="2.16.840.1.113883.3.1937.99.62.3.10.1" effectiveDate="2013-09-24T18:20:25">
   <concept ref="2.16.840.1.113883.3.1937.99.62.3.2.17" effectiveDate="2013-09-24T14:30:19" elementId="2.16.840.1.113883.3.1937.99.62.3.9.1"/>
</templateAssociation>
:)
let $decor                  := $get:colDecorData//decor[project/@prefix=$templateAssociation/@projectPrefix]
let $user                   := xmldb:get-current-user()
let $templateAssocInDb      := $decor//templateAssociation[@templateId=$templateAssociation/@templateId][@effectiveDate=$templateAssociation/@effectiveDate]

return
    if ($user=$decor/project/author/@username) then (
        let $delete :=
            for $assoc in $templateAssocInDb/concept[@ref=$templateAssociation/concept/@ref][@effectiveDate=$templateAssociation/concept/@effectiveDate][@elementId=$templateAssociation/concept/@elementId]
            return
                update delete $assoc
         
        return
            <response>OK</response>
    )
    else (
        <response>NO PERMISSION</response>
    )