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
(:install path for art (/db, /db/apps), no trailing slash :)
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

(: helper function for creating top level database collection and index definitions required for Art webapplication :)
declare function local:createTopCollections() {
    let $decorConf   :=
            <collection xmlns="http://exist-db.org/collection-config/1.0">
               <index>
                  <fulltext default="none" attributes="false"/>
                  <lucene>
                     <analyzer class="org.apache.lucene.analysis.standard.StandardAnalyzer">
                        <param name="stopwords" type="java.util.Set"/>
                     </analyzer>
                     <text qname="name"/>
                     <text qname="desc"/>
                     <text qname="@name"/>
                     <text qname="@displayName"/>
                  </lucene>
                  <create qname="@code" type="xs:string"/>
                  <create qname="@codeSystem" type="xs:string"/>
                  <create qname="@concept" type="xs:string"/>
                  <create qname="@conceptId" type="xs:string"/>
                  <create qname="@contains" type="xs:string"/>
                  <create qname="@displayName" type="xs:string"/>
                  <create qname="@effectiveDate" type="xs:string"/>
                  <create qname="@elementId" type="xs:string"/>
                  <create qname="@flexibility" type="xs:string"/>
                  <create qname="@id" type="xs:string"/>
                  <create qname="@key" type="xs:string"/>
                  <create qname="@name" type="xs:string"/>
                  <create qname="@prefix" type="xs:string"/>
                  <create qname="@ref" type="xs:string"/>
                  <create qname="@repository" type="xs:string"/>
                  <create qname="@root" type="xs:string"/>
                  <create qname="@statusCode" type="xs:string"/>
                  <create qname="@templateId" type="xs:string"/>
                  <create qname="@transactionRef" type="xs:string"/>
                  <create qname="@valueSet" type="xs:string"/>
               </index>
            </collection>

    let $hl7Conf     :=
            <collection xmlns="http://exist-db.org/collection-config/1.0">
               <index xmlns:hl7="urn:hl7-org:v3" xmlns:xs="http://www.w3.org/2001/XMLSchema">
                  <fulltext default="none" attributes="false"/>
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
               </index>
            </collection>
    
    let $artDataConf :=
            <collection xmlns="http://exist-db.org/collection-config/1.0">
               <index xmlns:hl7="urn:hl7-org:v3" xmlns:xs="http://www.w3.org/2001/XMLSchema">
                  <fulltext default="none" attributes="false"/>
                  <create qname="@id" type="xs:string"/>
                  <create qname="@name" type="xs:string"/>
                  <create qname="@notifier" type="xs:string"/>
                  <create qname="@user" type="xs:string"/>
                  <create qname="@value" type="xs:string"/>
               </index>
            </collection>
    
    return (
        for $coll in ('ada','art-data','decor','hl7','terminology','terminology-data')
        return (
            if (not(xmldb:collection-available(concat($root,$coll)))) then (
                xmldb:create-collection($root,$coll)
            ) else()
        )
        ,
        for $coll in ('cache','data','releases')
        return (
            if (not(xmldb:collection-available(concat($root,'decor/',$coll)))) then
                xmldb:create-collection(concat($root,'decor'),$coll)
            else()
        )
        ,
        for $coll in ('art-data','decor','hl7')
        return (
            if (not(xmldb:collection-available(concat('/db/system/config',$root,$coll)))) then (
                xmldb:create-collection(concat('/db/system/config',$root),$coll)
            ) else ()
        )
        ,
        let $index-file := concat('/db/system/config',$root,'art-data/collection.xconf')
        return
        if (doc-available($index-file) and deep-equal(doc($index-file)/cfg:collection,$artDataConf)) then () else (
            xmldb:store(concat('/db/system/config',$root,'art-data'),'collection.xconf',$artDataConf),
            xmldb:reindex(concat($root,'/art-data'))
        )
        ,
        let $index-file := concat('/db/system/config',$root,'decor/collection.xconf')
        return
        if (doc-available($index-file) and deep-equal(doc($index-file)/cfg:collection,$decorConf)) then () else (
            xmldb:store(concat('/db/system/config',$root,'decor'),'collection.xconf',$decorConf),
            xmldb:reindex(concat($root,'/decor'))
        )
        ,
        let $index-file := concat('/db/system/config',$root,'hl7/collection.xconf')
        return
        if (doc-available($index-file) and deep-equal(doc($index-file)/cfg:collection,$hl7Conf)) then () else (
            xmldb:store(concat('/db/system/config',$root,'hl7'),'collection.xconf',$hl7Conf),
            xmldb:reindex(concat($root,'/hl7'))
        )
    )
};

(: helper function for creating database groups required for Art webapplication :)
declare function local:createArtGroups() {
   if (not(sm:group-exists('decor'))) then
      sm:create-group('decor','admin','Group for general access to Decor files')
   else()
      ,
   if (not(sm:group-exists('decor-admin'))) then
      sm:create-group('decor-admin','admin','Group for Decor project admins')
   else()
   ,
   if (not(sm:group-exists('terminology'))) then
      sm:create-group('terminology','admin','General terminology group')
   else()
   ,
   if (not(sm:group-exists('issues'))) then
      sm:create-group('issues','admin','Group to let users create issues')
   else()
   ,
   if (not(sm:group-exists('editor'))) then
      sm:create-group('editor','admin','Group to let users edit in general')
   else()
   ,
   if (not(sm:group-exists('tools'))) then
      sm:create-group('tools','admin','General tools group')
   else()
      ,
   if (not(sm:group-exists('debug'))) then
      sm:create-group('debug','admin','Group to switch on Orbeon debug view for user')
   else()
};

sm:set-user-primary-group('admin','dba'),
(: store the collection configuration :)
local:mkcol("/db/system/config", $target),
xmldb:store-files-from-pattern(concat("/system/config", $target), $dir, "*.xconf"),
local:createTopCollections(),
local:createArtGroups()
