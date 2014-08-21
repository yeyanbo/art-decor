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
xquery version "3.0";

import module namespace ada ="http://art-decor.org/ns/ada-common" at "ada-common.xqm";
import module namespace adaxml ="http://art-decor.org/ns/ada-xml" at "ada-xml.xqm";

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace response  = "http://exist-db.org/xquery/response";

let $data:= request:get-data()/*
let $app := $data/@app 
let $id := $data/@id
let $rootdir := concat($ada:strAdaProjects, '/', $app)
let $datadir := concat($rootdir, '/data')
let $transactionRef := $data/@transactionRef
let $transactionEffectiveDate := $data/@transactionEffectiveDate
let $datasets := collection(concat($rootdir, '/definitions'))//transactionDatasets/dataset
let $spec := $datasets[@transactionId="2.16.840.1.113883.3.1937.99.62.3.4.2"][@transactionEffectiveDate="2012-09-05T16:59:35"][1]
let $cleanedData := adaxml:removeEmptyValues($data)
let $cleanedData := adaxml:addCode($cleanedData, $spec)
let $result := if (collection($datadir)//*[@id=$data/@id]) 
    then 
        (
        let $adaxml := collection($datadir)//*[@id=$data/@id]/ancestor::adaxml
        let $dummy := update replace $adaxml/meta/@last-update-by with xmldb:get-current-user()
        let $dummy := update replace $adaxml/meta/@last-update-date with fn:current-dateTime()
        let $dummy := update delete $adaxml/data/*
        return update insert $cleanedData into $adaxml/data 
        )
    else
        (
        let $uuid := util:uuid()
        let $newdata := 
            element adaxml {
                element meta {
                    attribute status {'new'},
                    attribute created-by {xmldb:get-current-user()},
                    attribute last-update-by {xmldb:get-current-user()},
                    attribute creation-date {fn:current-dateTime()},
                    attribute last-update-date {fn:current-dateTime()}
                    },
                    element data {
                        element {name($data)} {$data/@*[not(local-name()='id')], attribute id {$uuid}, $cleanedData/*}
                    }
            }
        return xmldb:store($datadir, concat($uuid, '.xml'), $newdata)
        )
return $result