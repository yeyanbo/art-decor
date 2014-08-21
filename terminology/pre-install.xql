xquery version "1.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

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
            xdb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, tokenize($path, "/"))
};

declare function local:createSCTExtensionCollections() {
   let $extensionConf :=
   <collection xmlns="http://exist-db.org/collection-config/1.0">
       <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
           <lucene>
               <analyzer class="org.apache.lucene.analysis.standard.StandardAnalyzer">
                   <param name="stopwords" type="java.util.Set"/>
               </analyzer>
               <text qname="desc"/>
           </lucene>
           <create qname="@uuid" type="xs:string"/>
           <create qname="@id" type="xs:string"/>
           <create qname="@conceptId" type="xs:string"/>
           <create qname="@soId" type="xs:string"/>
           <create qname="@sourceId" type="xs:string"/>
           <create qname="@destinationId" type="xs:string"/>
           <create qname="@refsetId" type="xs:string"/>
           <create qname="@moduleId" type="xs:string"/>
           <create qname="@typeId" type="xs:string"/>
           <create qname="@ref" type="xs:string"/>
           <create qname="@distance" type="xs:string"/>
           <create qname="@mapTarget" type="xs:string"/>
           <create qname="@referencedComponentId" type="xs:string"/>
           <create qname="id" type="xs:string"/>
           <create qname="@effectiveTime" type="xs:string"/>
           <create qname="@effectiveDate" type="xs:string"/>
       </index>
   </collection>
   return
   (
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension')))) then
      xdb:create-collection(concat($root,'terminology-data'),'snomed-extension')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/core')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'core')
   else()
   ,
   if (not(xdb:collection-available(concat('/db/system/config',$root,'terminology-data/snomed-extension')))) then
      xdb:create-collection(concat('/db/system/config',$root,'terminology-data'),'snomed-extension')
   else()
   ,
   xdb:store(concat('/db/system/config',$root,'terminology-data/snomed-extension'),'collection.xconf',$extensionConf)
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/concepts')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'concepts')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/descriptions')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'descriptions')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/import')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'import')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/history')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'history')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/log')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'log')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/meta')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'meta')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/releases')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'releases')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/snomed-extension/refsets')))) then
      xdb:create-collection(concat($root,'terminology-data/snomed-extension'),'refsets')
   else()
   )
};
declare function local:createDHDCollections() {
   let $dhdConf :=
      <collection xmlns="http://exist-db.org/collection-config/1.0">
          <index>
              <lucene>
                  <analyzer class="org.apache.lucene.analysis.standard.StandardAnalyzer">
                      <param name="stopwords" type="java.util.Set"/>
                  </analyzer>
                  <text qname="desc"/>
              </lucene>
              <create qname="@thesaurusId" type="xs:string"/>
              <create qname="@idLink" type="xs:string"/>
              <create qname="@id" type="xs:string"/>
              <create qname="@no" type="xs:string"/>
              <create qname="@code" type="xs:string"/>
              <create qname="@agbCode" type="xs:string"/>
              <create qname="@conceptId" type="xs:string"/>
              <create qname="@statusCode" type="xs:string"/>
              <create qname="@specialismCode" type="xs:string"/>
          </index>
      </collection>
   return
   (
   if (not(xdb:collection-available(concat($root,'terminology-data/dhd-data')))) then
      xdb:create-collection(concat($root,'terminology-data'),'dhd-data')
   else()
   ,
   if (not(xdb:collection-available(concat('/db/system/config',$root,'terminology-data/dhd-data')))) then
      xdb:create-collection(concat('/db/system/config',$root,'terminology-data'),'dhd-data')
   else()
   ,
   xdb:store(concat('/db/system/config',$root,'terminology-data/dhd-data'),'collection.xconf',$dhdConf)
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/dhd-data/history')))) then
      xdb:create-collection(concat($root,'terminology-data/dhd-data'),'history')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/dhd-data/legacy')))) then
      xdb:create-collection(concat($root,'terminology-data/dhd-data'),'legacy')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/dhd-data/log')))) then
      xdb:create-collection(concat($root,'terminology-data/dhd-data'),'log')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/dhd-data/meta')))) then
      xdb:create-collection(concat($root,'terminology-data/dhd-data'),'meta')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/dhd-data/reference')))) then
      xdb:create-collection(concat($root,'terminology-data/dhd-data'),'reference')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/dhd-data/releases')))) then
      xdb:create-collection(concat($root,'terminology-data/dhd-data'),'releases')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/dhd-data/thesaurus')))) then
      xdb:create-collection(concat($root,'terminology-data/dhd-data'),'thesaurus')
   else()
   )
};
declare function local:createICACollections() {
   let $icaConf :=
      <collection xmlns="http://exist-db.org/collection-config/1.0">
          <index xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3">
              <fulltext default="none" attributes="false"/>
              <create qname="@effectiveDate" type="xs:string"/>
              <create qname="@id" type="xs:string"/>
              <create qname="@code" type="xs:string"/>
              <create qname="@statusCode" type="xs:string"/>
          </index>
      </collection>
   return
   (
   if (not(xdb:collection-available(concat($root,'terminology-data/ica-data')))) then
      xdb:create-collection(concat($root,'terminology-data'),'ica-data')
   else()
   ,
   if (not(xdb:collection-available(concat('/db/system/config',$root,'terminology-data/ica-data')))) then
      xdb:create-collection(concat('/db/system/config',$root,'terminology-data'),'ica-data')
   else()
   ,
   xdb:store(concat('/db/system/config',$root,'terminology-data/ica-data'),'collection.xconf',$icaConf)
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/ica-data/concepts')))) then
      xdb:create-collection(concat($root,'terminology-data/ica-data'),'concepts')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/ica-data/history')))) then
      xdb:create-collection(concat($root,'terminology-data/ica-data'),'history')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/ica-data/log')))) then
      xdb:create-collection(concat($root,'terminology-data/ica-data'),'log')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/ica-data/meta')))) then
      xdb:create-collection(concat($root,'terminology-data/ica-data'),'meta')
   else()
   ,
   if (not(xdb:collection-available(concat($root,'terminology-data/ica-data/releases')))) then
      xdb:create-collection(concat($root,'terminology-data/ica-data'),'releases')
   else()
   )
};
(: store the collection configuration :)
local:mkcol("/db/system/config", $target),
xdb:store-files-from-pattern(concat("/system/config", $target), $dir, "*.xconf"),
local:createSCTExtensionCollections(),
local:createDHDCollections(),
local:createICACollections()