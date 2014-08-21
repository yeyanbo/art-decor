xquery version "1.0";

import module namespace xmldb   = "http://exist-db.org/xquery/xmldb";
declare namespace cfg           = "http://exist-db.org/collection-config/1.0";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
declare variable $root := repo:get-root();

declare function local:storeSettings() {
    let $oidsDataConf :=
        <collection xmlns="http://exist-db.org/collection-config/1.0">
            <index xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3">
                <lucene>
                    <analyzer class="org.apache.lucene.analysis.standard.StandardAnalyzer">
                        <param name="stopwords" type="java.util.Set"/>
                    </analyzer>
                    <text qname="desc"/>
                    <text qname="@value"/>
                </lucene>
                <create qname="@oid" type="xs:string"/>
            </index>
        </collection>
    
    return (
        (:create apps dir:)
        for $coll in ('tools/oids-data')
        return (
            if (not(xmldb:collection-available(concat($root,$coll)))) then (
                xmldb:create-collection($root,$coll),
                sm:chown(xs:anyURI(concat('xmldb:exist:///',$root,$coll)),'admin:tools'),
                sm:chmod(xs:anyURI(concat('xmldb:exist:///',$root,$coll)),'rwxrwxr-x'),
                sm:clear-acl(xs:anyURI(concat('xmldb:exist:///',$root,$coll)))
            ) else ()
        )
        ,
        (:create index dir:)
        for $coll in ('tools/oids-data')
        return (
            if (not(xmldb:collection-available(concat('/db/system/config',$root,$coll)))) then (
                xmldb:create-collection(concat('/db/system/config',$root),$coll)
            ) else ()
        )
        ,
        (:move any old-style oids package data into oids-data:)
        if (xmldb:collection-available(concat($root,'tools/oids/data'))) then
            for $resource in xmldb:get-child-resources(concat($root,'tools/oids/data'))
            return (
                xmldb:move(concat($root,'tools/oids/data'),concat($root,'tools/oids-data'),$resource),
                sm:chown(concat($root,'tools/oids-data',$resource),'admin:tools'),
                sm:chmod(concat($root,'tools/oids-data',$resource),'rw-rw-r--')
            )
        else()
        ,
        (:add/overwrite index file and reindex:)
        let $index-file := concat('/db/system/config',$root,'tools/oids-data/collection.xconf')
        return
        if (doc-available($index-file) and deep-equal(doc($index-file)/cfg:collection,$oidsDataConf)) then () else (
            xmldb:store(concat('/db/system/config',$root,'tools/oids-data'),'collection.xconf',$oidsDataConf),
            xmldb:reindex(concat($root,'/tools'))
        )
    )
};

local:storeSettings()