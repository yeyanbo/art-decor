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
(:~
:Common ADA functions and utilities for locations etc.
:
:@author Marc de Graauw
:@version 0.1
:@param $els Sequence of elements to which conceptId will be added (and to child nodes as well)
:@param $spec A single enhanced dataset for a particular transaction, usually from a specific {project}-{version}-ada-release.xml
:@return The sequence of elements from input, with conceptId
:)

module namespace ada = "http://art-decor.org/ns/ada-common";
declare namespace repo="http://exist-db.org/xquery/repo";

(:  These are copied from art-common.xqm, since we want a separate install for ADA, and not require all of ART.
    When there is a lightweigt art-common installer, we can refer to art-commmon.xqm again. :)
declare variable $ada:root := repo:get-root();
(:~ String variable with everything under ada/projects :)
declare variable $ada:strAda     := concat($ada:root,'ada');
(:~ String variable with everything under ada-data/projects :)
declare variable $ada:strAdaProjects     := concat($ada:root,'ada-data/projects');
(:~ Collection variable with everything under ada/projects :)
declare variable $ada:colAdaProjects     := collection($ada:strAdaProjects);
(:~ Get the eXist hostname (request:get-hostname() does work in VM :)
declare variable $ada:hostname := doc('../conf.xml')//exist/@uri;

(:~
:Get a schema for a document
:
:@param $prefix See ada:getUri
:@param $type   See ada:getUri
:@return A collection 
:)
declare function ada:getSchemaUri($doc as node()) as xs:string {
    let $prefix := data($doc//data/*/@prefix)
    let $uri := ada:getUri($prefix, 'schemas')
    return concat($uri, local-name($doc//data/*), '.xsd')
};

(:~
:Get a collection for a a subcollection in ADA
:
:@param $prefix See ada:getUri
:@param $type   See ada:getUri
:@return A collection 
:)
declare function ada:getCollection($prefix as xs:string, $type as xs:string?) as node()* {
    let $uri := ada:getUri($prefix, $type)
    return collection($uri)
};

(:~
:Get the URI for a a subcollection in ADA. Function does not verfiy whether the collection exists,
:which would be just overhead if the caller is tested.
:
:@param $prefix Project prefix with or without trailing hyphen, i.e. 'demo1' or 'demo1-'
:@param $type Desired subcollection, i.e. 'data' or 'definitions', i.e.: 'definitions' or 'data'
:@return URI string, i.e. '/db/apps/ada/projects/demo1/data/'
:)
declare function ada:getUri($prefix as xs:string, $type as xs:string?) as xs:string {
    let $prefix := if (ends-with($prefix, '-')) then substring($prefix, 1, string-length($prefix) - 1) else $prefix
    let $uri := 
        if ($type = ()) then $ada:strAdaProjects
        else concat($ada:strAdaProjects, '/', $prefix, '/', $type, '/')
    return $uri
};

(:~
:Get the URI for a a subcollection in ADA. Function does not verfiy whether the collection exists,
:which would be just overhead if the caller is tested.
:
:@param $prefix Project prefix with or without trailing hyphen, i.e. 'demo1' or 'demo1-'
:@param $type Desired subcollection, i.e. 'data' or 'definitions', i.e.: 'definitions' or 'data'
:@return URI string, i.e. '/db/apps/ada/projects/demo1/data/'
:)
declare function ada:getHttpUri($prefix as xs:string, $type as xs:string?) as xs:string {
    let $uri := replace(ada:getUri($prefix, $type), '/db/apps', $ada:hostname)
    return $uri
};