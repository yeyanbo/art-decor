xquery version "3.0";
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
import module namespace sm      = "http://exist-db.org/xquery/securitymanager";
import module namespace xmldb   = "http://exist-db.org/xquery/xmldb";
import module namespace repo    = "http://exist-db.org/xquery/repo";
declare namespace cfg           = "http://exist-db.org/collection-config/1.0";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
declare variable $root := repo:get-root();

declare function local:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            xmldb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, tokenize($path, "/"))
};

(: helper function for creating top level database collection and index definitions required for Xis webapplication :)
declare function local:createTopCollections() {
    let $xisDataConf :=
            <collection xmlns="http://exist-db.org/collection-config/1.0">
                <index xmlns:hl7="urn:hl7-org:v3" xmlns:xs="http://www.w3.org/2001/XMLSchema">
                    <fulltext default="none" attributes="false"/>
                    <lucene>
                        <analyzer class="org.apache.lucene.analysis.standard.StandardAnalyzer">
                            <param name="stopwords" type="java.util.Set"/>
                        </analyzer>
                        <text qname="naam"/>
                        <text qname="hl7:name"/>
                    </lucene>
                    <create qname="hl7:interactionId" type="xs:string"/>
                    <create qname="hl7:creationTime" type="xs:string"/>
                    <create qname="@value" type="xs:string"/>
                    <create qname="hl7:id" type="xs:string"/>
                    <create qname="@extension" type="xs:string"/>
                    <create qname="@root" type="xs:string"/>
                    <create qname="hl7:code" type="xs:string"/>
                    <create qname="@code" type="xs:string"/>
                    <create qname="@displayName" type="xs:string"/>
                    <create qname="@codeSystem" type="xs:string"/>
                    <create qname="hl7:queryByParameter" type="xs:string"/>
                    <create qname="hl7:PrimaryCareProvision" type="xs:string"/>
                    <create qname="hl7:Condition" type="xs:string"/>
                    <create qname="hl7:MedicationDispenseEvent" type="xs:string"/>
                    <create qname="hl7:MedicationDispenseList" type="xs:string"/>
                    <create qname="xs:complexType" type="xs:string"/>
                    <create qname="xs:element" type="xs:string"/>
                    <create qname="@name" type="xs:string"/>
                    <create qname="@gpkode" type="xs:string"/>
                    <create qname="@atcode" type="xs:string"/>
                    <create qname="@prkode" type="xs:string"/>
                    <create qname="@hpkode" type="xs:string"/>
                    <create qname="@atkode" type="xs:string"/>
                </index>
            </collection>
    
    return (
        for $coll in ('xis-data/accounts')
        return (
            if (not(xmldb:collection-available(concat($root,$coll)))) then (
                xmldb:create-collection($root,$coll)
            ) else()
        )
        ,
        for $coll in ('xis-data')
        return (
            if (not(xmldb:collection-available(concat('/db/system/config',$root,$coll)))) then (
                xmldb:create-collection(concat('/db/system/config',$root),$coll)
            ) else ()
        )
        ,
        let $index-file := concat('/db/system/config',$root,'xis-data/collection.xconf')
        return
        if (doc-available($index-file) and deep-equal(doc($index-file)/cfg:collection,$xisDataConf)) then () else (
            xmldb:store(concat('/db/system/config',$root,'xis-data'),'collection.xconf',$xisDataConf),
            xmldb:reindex(concat($root,'/art-data'))
        )
    )
};

(: helper function for creating database group 'xis' required for Art XIS webapplication :)
declare function local:createXisGroup() {
   if (not(sm:group-exists('xis'))) then
   sm:create-group('xis','admin','Group for general access to XIS data')
   else()
};

(: helper function for creating database user 'webservice' required for Art XIS webapplication :)
declare function local:createXisUser() {
   if (not(sm:user-exists('xis-webservice'))) then
   sm:create-account('xis-webservice','webservice-xs2messages','xis','XIS Webservice','Used for storing received messages')
   else()
};

(: store the collection configuration :)
local:createTopCollections(),
local:createXisGroup(),
local:createXisUser()