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

(: Add resources to form-resources, package root is in requestData/@packageRoot:)
let $requestData     := if (request:exists()) then request:get-data()/artXformResources else ()
let $formResources   := doc(concat($requestData/@packageRoot,'/resources/form-resources.xml'))/artXformResources
let $editedResources := 
    <artXformResources xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="form-resources.xsd">
    {
        for $resources in $requestData/resources
        return
            <resources>
            {
                $resources/@*
                ,
                for $key in $resources/*
                order by lower-case(name($key))
                return $key
            }
            </resources>
    }
    </artXformResources>

return
    if (not(empty($requestData)) and not(empty($formResources))) then (
        <response status="saved">
        {
            update value $formResources with $editedResources/*
            (:$editedResources/*:)
        }
        </response>
    )
    else (
        <response status="no data to save"/>
    )
