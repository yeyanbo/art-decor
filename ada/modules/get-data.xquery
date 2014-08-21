xquery version "3.0";
(:
    Copyright (C) 2013-2014  Marc de Graauw
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
import module namespace ada     = "http://art-decor.org/ns/ada-common" at "ada-common.xqm";
import module namespace adaxml  = "http://art-decor.org/ns/ada-xml" at "ada-xml.xqm";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";

let $id                 := if (request:exists()) then request:get-parameter('id','') else 'new' 
let $transactionName    := if (request:exists()) then request:get-parameter('transactionName','') else 'counseling_bericht_22' 
let $app                := if (request:exists()) then request:get-parameter('app','') else 'counseling' 
let $resource           := concat($ada:strAdaProjects,'/', translate($app, '-', ''), '/new/', $transactionName, '.xml')
let $newXml             := doc($resource)
(: TODO: permissions.... when called from XForm :)
let $data               := 
    if ($id='new') 
    then $newXml/*
    else (
        let $originalData := collection($ada:strAdaProjects)//*[@id=$id]
        return 
            if ($originalData) then adaxml:addAttributes($originalData, $newXml)
            else <data><error>{concat('No data found for: ', $id)}</error></data>
        )
return $data