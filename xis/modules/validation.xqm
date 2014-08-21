xquery version "3.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Alexander Henket, Marc de Graauw
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
module namespace val = "http://art-decor.org/ns/validation";

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace hl7        = "urn:hl7-org:v3";
declare namespace lab        = "urn:oid:2.16.840.1.113883.2.4.6.10.35.81";
declare namespace xis        = "http://art-decor.org/ns/xis";
declare namespace xs         = "http://www.w3.org/2001/XMLSchema";
declare namespace svrl       = "http://purl.oclc.org/dsdl/svrl";
declare namespace util       = "http://exist-db.org/xquery/util";
declare namespace validation = "http://exist-db.org/xquery/validation";
declare namespace transform  = "http://exist-db.org/xquery/transform";
declare namespace xdb        = "http://exist-db.org/xquery/xmldb";
declare namespace de         = "http://art-decor.org/ns/error";

(: Log debug messages? :)
declare variable $val:debug   := false();

(: http://www.xqueryfunctions.com/xq/functx_path-to-node-with-pos.html -- Adaptations:
    Adds leading slash to returned path
    Outputs hl7:node for nodes in HL7v3 namespace
    Outputs *:node[namespace-uri()='...'] for nodes in other namespaces where ... may be an empty string
:)
declare function local:path-to-node-with-pos ( $node as node()? )  as xs:string {
    let $return := 
        string-join (
            for $ancestor in $node/ancestor-or-self::*
            let $sibsOfSameName := $ancestor/../*[name() = name($ancestor)]
            return 
                concat(
                    if (namespace-uri($ancestor)='urn:hl7-org:v3') then ( 
                        concat('hl7:', local-name($ancestor)) 
                    ) else (
                        concat('*:', local-name($ancestor))
                    ),
                    if (count($sibsOfSameName) <= 1) then (
                        ''
                    ) else (
                        concat('[',local:index-of-node($sibsOfSameName,$ancestor),']')
                    ),
                    if (namespace-uri($ancestor) != 'urn:hl7-org:v3') then ( 
                        concat('[namespace-uri()=''', namespace-uri($ancestor), ''']') 
                    ) else (
                        ''
                    )
                )
        , '/')
        
    return concat('/',$return)
};
(: http://www.xqueryfunctions.com/xq/functx_index-of-node.html -- Copied as-is :)
declare function local:index-of-node ( $nodes as node()*, $nodeToFind as node() )  as xs:integer* {
    for $seq in (1 to count($nodes))
    return $seq[$nodes[$seq] is $nodeToFind]
};

declare function val:validateSchemaCDA($input as node(), $cdaSchema as xs:string) as node()* {
    let $check         := 
        if (doc-available($cdaSchema)) then 
            true() 
        else (
            error(QName('http://art-decor.org/ns/error', 'SchemaFileMissing'), concat('XML Schema file missing: ',$cdaSchema))
        )
    
    (: this XSL gets everything HL7 and leaves everything non-HL7 :)
    let $cdaNormalizeXSL := concat($get:strXisResources, '/stylesheets/remove_non_hl7_namespace.xsl')
    
    (: remove anything not in the HL7 namespace :)
    let $normalizedMessage := transform:transform($input, doc($cdaNormalizeXSL), ())
    
    (: return validation result :)
    return 
        validation:jaxv-report($normalizedMessage, doc($cdaSchema))
};

(: FIXME We're basically asssuming that input is B64 CDA, but it might be a JPG or PDF... should properly catch that and just skip :)
declare function val:validateSchematronCDA($input as node(), $baseCollectionSCH as xs:string, $mappings as element()?) as node()* {
    let $re                := $input/local-name()
    
    (:let $g := util:log('DEBUG', concat('============ validateSchematronCDA parameters baseCollectionSCH=',$baseCollectionSCH, ' and mapping count=',count($mappings/*))):)
    
    let $messageSchematron := local:getSchematronFile($input,$mappings)
    
    (:let $g                 := util:log('DEBUG', concat('============ Got schematron for embedded instance: ',$cdaSchematron)):)
    
    (: return validation result :)
    return 
        if (string-length($messageSchematron)>0) then (
            let $messageSchematron := if (doc-available(concat($baseCollectionSCH,$messageSchematron))) then (
                concat($baseCollectionSCH,$messageSchematron)
            ) else (
                error(QName('http://art-decor.org/ns/error', 'SchematronFileMissing'), concat('Schematron file determined but missing: ', concat($baseCollectionSCH,$messageSchematron)))
            )
            return
                transform:transform($input, doc($messageSchematron), ())
        ) else (
            <svrl:issues>
                <svrl:issue type="schematron" role="error" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
                    <svrl:text>Could not determine a schematron to validate with. This could be an internal error where the instance2schematron mapping configuration was not configured correctly. Alternatively you did not provide an instance with a recognized root element nor templateId.</svrl:text>
                </svrl:issue>
            </svrl:issues>
        )
};

declare function local:getSchematronFile($input as node(), $mappings as element()?) as xs:string? {
    let $checkParameter := 
        if (empty($mappings)) then (
            error(QName('http://art-decor.org/ns/error', 'MappingsMissing'), 'Mapping configuration for Schematron missing. This is usually a file called schematron_svrl/instance2schematron.xml and needs a toplevel element mappings.')
        ) else ()
    
    let $ns             := $input[1]/namespace-uri()
    let $re             := $input[1]/local-name()
    
    (:let $g := util:log('DEBUG', concat('===(getSchematronFile)=== Got root node: ', $re, ' in namespace: ',$ns,' found templateId? ', $templateId/@root)):)
    
    (:
        There are two structures for instance2schematron.xml around.
        Old school:
            <mappings>
                <map rootelement="ClinicalDocument" rootns="urn:hl7-org:v3" schsvrl="">
                    <templateId root="2.16.840.1.113883.2.4.3.36.10.10" schsvrl="rivmsp-nsp-bc-mdl.xsl"/>
                    <templateId root="2.16.840.1.113883.2.4.3.36.10.20" schsvrl="rivmsp-nsp-bc-pa.xsl"/>
                </map>
            </mappings>
        New school:
            <mappings>
                <!-- template name: counseling-fase-1c -->
                <map model="REPC_IN004110UV01" namespace="urn:hl7-org:v3" templateRoot="2.16.840.1.113883.2.4.6.10.90.59" sch="peri20-counseling-fase-1c.sch" schsvrl="peri20-counseling-fase-1c.xsl"/>
                <!-- template name: counseling-1c -->
                <map model="REPC_IN004110UV01" namespace="urn:hl7-org:v3" templateRoot="2.16.840.1.113883.2.4.6.10.90.54" sch="peri20-counseling-1c.sch" schsvrl="peri20-counseling-1c.xsl"/>
            </mappings>
            
        We want to support both.
    :)
    
    (: First try to find the schematron based on a template in the input instance :)
    (: Retrieve the first templateId which also occurs in map :)
    let $templateId          := ($input//hl7:templateId[@root=$mappings//*[string-length(@schsvrl)>0]/(@root|@templateRoot)])[1]
    (: Then retrieve the first mapping line that matches this template :)
    let $templateMappingLine := 
        if (not(empty($templateId))) then (
            ($mappings//*[(@root|@templateRoot)=$templateId/@root][string-length(@schsvrl)>0])[1] 
        ) else ()
    
    return
        if (not(empty($templateMappingLine))) then (
            (:let $g := util:log('DEBUG', concat('===(getSchematronFile)=== Returning specific schematron instance: ', $templateMappingLine/@schsvrl))
            return:) $templateMappingLine/@schsvrl
        ) else (
            let $rootMappingLine := ($mappings//map[@rootelement=$re][@rootns=$ns][string-length(@schsvrl)>0])[1]
            return
                if (not(empty($rootMappingLine))) then (
                    (:let $g := util:log('DEBUG', concat('===(getSchematronFile)=== Returning fallback schematron instance: ', $rootMappingLine/@schsvrl))
                    return:) $rootMappingLine/@schsvrl
                ) else (
                    (:let $g := util:log('DEBUG', concat('===(getSchematronFile)=== Returning root element based schematron instance: ', concat($re,'.xsl')))
                    return:) concat($re,'.xsl')
                )
        )
};

(:~
:   Tries to come up with a reasonable file/resource name extension including the dot, based on mediaType and file name. Can return empty string.
:   
:   @param $mediaType - (optional) contains the mime type
:   @param $fileUri   - (optional) contains the URI for
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function local:getExtension($mediaType as xs:string?, $fileUri as xs:string?) as xs:string {
    let $mediaType := lower-case($mediaType)
    
    return
    if (tokenize($mediaType,'/')[last()]=('pdf','xml','jpg','jpeg','gif','html','rtf','xhtml','xsl')) then
        (:should be a valid extension:)
        concat('.',tokenize($mediaType,'/')[last()])
    else if ($mediaType='text/plain') then
        (:plain text file:)
        '.txt'
    else if (contains($mediaType,'xml') and contains($mediaType,'html')) then
        (:xhtml:)
        '.xhtml'
    else if (contains($mediaType,'xml')) then
        (:xml of some sort:)
        '.xml'
    else if (string-length((tokenize($fileUri,'\.')[last()])[1])>0) then
        (:get extension from file path in hl7:reference/@value:)
        concat('.',(tokenize($fileUri,'\.')[last()])[1])
    else (
        (:we don't know what extension so leave empty:)
        ''
    )
};

(:~
:   Stores a given base64Binary as resource under the given name in xis-data/accounts/<account>/attachments
:   
:   @param $resourceName - (required) contains the "file" name, without collection path
:   @param $input        - (required but may be empty) contains the base64 encoded contents of the resource
:   @param $mediaType    - (optional) contains the mime type of the $input
:   @author Alexander Henket
:   @since 2013-06-14
:)
declare function local:saveAsResource($resourceName as xs:string, $input as xs:base64Binary*, $mediaType as xs:string?) as xs:boolean {
    (: write the decoded CDA content to database :)
    (: to fix: this writes the CDA content to the database each time you click on the HL7-interaction in ART :)
    let $account            := request:get-parameter('account',(''))
    let $messageStoragePath := concat($get:strXisAccounts, '/',$account,'/attachments')

    let $createCollection   := 
        if (not(xmldb:collection-available($messageStoragePath))) then (
            xmldb:create-collection(concat($get:strXisAccounts, '/',$account),'/attachments')
        ) else ()
    
    (: write the decoded CDA content filepath to exist log :)
    let $g                  := util:log('DEBUG', concat('---(saveAsResource)--- Storing attachment in ', $messageStoragePath, '/' , $resourceName))
    
    let $return             :=
        if (string-length($mediaType)>0) then
            xmldb:store($messageStoragePath, $resourceName, $input, $mediaType)
        else (
            xmldb:store($messageStoragePath, $resourceName, $input)
        )
    
    let $g                  := util:log('DEBUG', concat('---(saveAsResource)--- Stored attachment in ', $return))
    
    return
        string-length($return)>0
};

declare function val:validateSchematron($messageInstance as node(),  $messageSchematronFile as xs:string) as node()* {
    (: ==== START Schematron validation of messageInstance. Requires SVRL version of SCH (!) ==== :)
    try {
        (: DB path to Schematron for this message instance based on interaction-id :)
        let $g := if ($val:debug) then (util:log('DEBUG', concat('============ START MAIN XML Schematron validation of instance with ', $messageSchematronFile, ' doc-available: ', doc-available($messageSchematronFile)))) else ()
        
        let $messageSchematron := if (doc-available($messageSchematronFile)) 
            then doc($messageSchematronFile) 
            else (error(QName('http://art-decor.org/ns/error', 'SchematronFileMissing'), concat('Schematron file missing: ', $messageSchematronFile)))
        
        let $schematronReport  := transform:transform($messageInstance, $messageSchematron, ())
        return
        if (empty($schematronReport)) then (
            error(QName('http://art-decor.org/ns/error', 'SchematronReportEmpty'), concat('Schematron report is empty for: ', $messageSchematron))
        ) else (
            for $issue in $schematronReport//*[@role='warning' or @role='error']
            let $location := replace(replace($issue/@location,'\*:([^\[]+)\[namespace-uri\(\)=''urn:hl7-org:v3''\]','hl7:$1'),'\[1\]','')
            return
                <issue type="schematron" role="{$issue/@role}" test="{$issue/@test}" see="{$issue/@see}" flag="{$issue/@flag}">
                    <description>{$issue/svrl:text/text()}</description>
                    <location path="{$location}"/>
                </issue>
        ) 
    } 
    catch * {
        <issue type="schematron" role="error">
            <description>ERROR {$err:code} in main Schematron validation: {$err:description, "', module: ", $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</description>
            <location path=""/>
        </issue>
    }
    (: ==== END Schematron validation of messageInstance. Requires SVRL version of SCH (!) ==== :)
};

declare function val:makeIssueReport($issueReport as node()) as node(){
    (: DB path to XSL that handles the final returned view of all errors/warnings :)
    let $issueReportXSL    := concat($get:strXisResources, '/stylesheets/groupIssues.xsl')
    return  
        try {transform:transform($issueReport, doc($issueReportXSL), ())}
        catch * {
                <issue type="schema" role="error">
                    <description>ERROR {$err:code} in main XSLT issue transform: {$err:description, "', module: ", $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</description>
                    <location line=""/>
                </issue>
        }
};

declare function val:validateMessage($file as xs:string, $account as xs:string, $xpath as xs:string) as node()* {
    let $filePath           := concat($get:strXisAccounts, '/',$account,'/messages/',$file)
    
    let $g := if ($val:debug) then (util:log('DEBUG', concat('============ Supplied parameters: account=',$account,' file=',$file,' xpath=',$xpath))) else ()
    let $g := if ($val:debug) then (if (doc-available($filePath)) then (util:log('DEBUG', '============ Found file: yes')) else (util:log('DEBUG', '============ Found file: no'))) else ()
    
    (: Test account XIS configuration data :)
    let $config             := doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:xis
    (: DB path to Schematron for instance and contained instances in this message :)
    let $baseCollectionSCH  := 
        if (xmldb:collection-available(concat("xmldb:exist://",$config/xis:xmlResourcesPath,"/schematron_svrl/"))) then
            concat("xmldb:exist://",$config/xis:xmlResourcesPath,"/schematron_svrl/")
         else (
            concat("xmldb:exist://",$config/xis:xmlResourcesPath,"/schematron_xslt/")
         )
    (: DB path to Schematron for instance and contained instances in this message :)
    let $baseCollectionXSD  := concat("xmldb:exist://",$config/xis:xmlResourcesPath,"/schemas_codeGen_flat/")
    (: DB path to mapping file that holds relations to Schematron :)
    let $mappings           := collection($baseCollectionSCH)//mappings
    let $checkParameter     := 
        if (empty($mappings)) then (
            error(QName('http://art-decor.org/ns/error', 'MappingsMissing'), concat('Mapping configuration for Schematron missing. This is usually a file called schematron_svrl/instance2schematron.xml and needs a toplevel element mappings.Base path ',$baseCollectionSCH))
        ) else ()
    
    let $messageInstance    := 
        try { 
            let $message    := doc($filePath)//*[util:node-xpath(.)=$xpath]
            return
            if ($message[string(@representation)='B64' or string(@xsi:type)='xs:base64Binary']) then (
                util:parse(util:base64-decode(doc($filePath)//*[normalize-space(util:node-xpath(.))=$xpath]))/*
            ) else if ($message) then (
                $message
            ) else (
                error(QName('http://art-decor.org/ns/error','ContentMissing'),concat('Could not find contents in file ',$file,' in account ',$account,' using xpath expression ',$xpath))
            )
        }
        catch * {
            <de:error xmlns:de="http://art-decor.org/ns/error">{concat($err:code, ' while getting message instance: ', $err:description, ', module: ', $err:module, '(', $err:line-number, ',', $err:column-number, ')')}</de:error>
        }
    
    let $g := if ($val:debug and $messageInstance/self::de:error) then (util:log('ERROR', $messageInstance/text())) else ()
    let $g := if ($val:debug) then (util:log('DEBUG', concat('============ Message instance found: ',count($messageInstance)))) else ()
    
    (: DB path to CDA schema, might not be applicable to this particular messageInstance :)
    let $cdaSchema         := concat($baseCollectionXSD,'ClinicalDocument.xsd')
    let $g := if ($val:debug) then (util:log('DEBUG', '============ START MAIN XML Schema validation')) else ()
    
    (: ==== START XML Schema validation of messageInstance. Requires flattened XSD (!) ==== :)
    let $schemaIssues  := 
        try {
            let $schemaReport  :=
                if ($messageInstance/self::de:error) then (
                    <noerror/>
                ) else if ($messageInstance[self::hl7:ClinicalDocument]) then (
                    let $check         := if (not(doc-available($cdaSchema))) then (error(QName('http://art-decor.org/ns/error', 'SchemaFileMissing'), concat('XML Schema file missing: ',$cdaSchema))) else ()
                    (: CDA needs pre-processing before validation :)
                    return val:validateSchemaCDA($messageInstance,$cdaSchema)
                ) else (
                    (: DB path to flattened XML Schema for this message instance based on interaction-id, batch could contain multiple ... :)
                    let $messageSchema := concat($baseCollectionXSD,($messageInstance[1]/local-name())[1],'.xsd')
                    let $check         := if (not(doc-available($messageSchema))) then (error(QName('http://art-decor.org/ns/error', 'SchemaFileMissing'), concat('XML Schema file missing: ',$messageSchema))) else ()
                    return validation:jaxv-report($messageInstance,doc($messageSchema))
                )
            
            for $schemaIssue in $schemaReport//*[@level='Warning' or @level='Error']
            let $location      := concat($schemaIssue/@line,':',$schemaIssue/@column)
            return
                <issue type="schema" role="{if ($schemaIssue/@level='Error') then 'error' else($schemaIssue/@level)}" count="{if ($schemaIssue/@repeat) then $schemaIssue/@repeat else ('1')}">
                    <description>{$schemaIssue/text()}</description>
                    <location line="{$location}"/>
                </issue>
        } 
        catch * {
            <issue type="schema" role="error">
                <description>ERROR {$err:code} in main XML Schema validation: {$err:description, "', module: ", $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</description>
                <location line=""/>
            </issue>
        }
    (: ==== END XML Schema validation of messageInstance. Requires flattened XSD (!) ==== :)
    
    let $g := if ($val:debug) then (util:log('DEBUG', '============ START MAIN Schematron validation of instance')) else ()
    
    (: ==== START Schematron validation of messageInstance. Requires SVRL version of SCH (!) ==== :)
    let $messageSchematronFile := concat($baseCollectionSCH,local:getSchematronFile($messageInstance,$mappings))
    let $schematronIssues := val:validateSchematron($messageInstance, $messageSchematronFile)
    (: ==== END Schematron validation of messageInstance. Requires SVRL version of SCH (!) ==== :)
    
    (: ==== START saving messageInstance attachments. ==== :)
    let $embeddedStorage      :=
        if ($val:debug) then (
            try {
                for $b64 in $messageInstance//*[string(@representation)='B64' or string(@xsi:type)='xs:base64Binary']
                let $mediaType    := $b64/@mediaType/string()
                let $resourceUri  := ($b64/hl7:reference/@value/string())[1]
                let $resourceName := concat(util:document-name($messageInstance),'_',$b64/position())
                let $resourceName := concat($resourceName, local:getExtension($mediaType,$resourceUri))
                let $g   := util:log('DEBUG', concat('============ STORE EMBEDDED BASE64 as separate file: ',$resourceName))
                return
                    local:saveAsResource($resourceName, xs:base64Binary(($b64/text())[1]), $mediaType)
            }
            catch * {
                concat('ERROR', $err:code, ' in saving attachment: ', $err:description, ', module: ', $err:module, '(', $err:line-number, ',', $err:column-number, ')')
            }
        ) else ()
    let $g := if ($val:debug) then (util:log('DEBUG', concat('============ STORE EMBEDDED BASE64 as separate file succeeded? ',string-join($embeddedStorage,' ')))) else ()
    (: ==== END saving messageInstance attachments. ==== :)
    
    let $g := if ($val:debug) then (util:log('DEBUG', concat('============ START EMBEDDED XML Schema validation of embedded instances (if any) with ',$cdaSchema))) else ()
    
    (: ==== START XML Schema validation of B64 encoded parts in messageInstance. Requires flattened CDA XSD (!) ==== :)
    (:            handle all B64 encoded instances in for loop and add to schematronReport:)
    let $embeddedSchemaIssues :=  
        try {
            for $b64 in $messageInstance//*[string(@representation)='B64' or string(@xsi:type)='xs:base64Binary']
            let $embedPath                := local:path-to-node-with-pos($b64)
            (: decode :)
            let $decodedString            := util:base64-decode($b64)
            (: parse into XML :)
            let $decodedMessage           := 
                try {
                    util:parse($decodedString)
                }
                catch * {
                    <de:error xmlns:de="http://art-decor.org/ns/error">{concat($err:code, ' while getting message instance: ', $err:description, ', module: ', $err:module, '(', $err:line-number, ',', $err:column-number, ')')}</de:error>
                }
            let $embeddedSchemaReport     := 
                if ($decodedMessage/self::de:error) then (
                    <noerror/>
                ) else (
                    val:validateSchemaCDA($decodedMessage,$cdaSchema)
                )
            return
                for $schemaIssue in $embeddedSchemaReport//*[@level='Warning' or @level='Error']
                let $location             := concat($schemaIssue/@line,':',$schemaIssue/@column)
                return
                    <issue type="schema" role="{if ($schemaIssue/@level='Error') then 'error' else($schemaIssue/@level)}" count="{if ($schemaIssue/@repeat) then $schemaIssue/@repeat else ('1')}" embed="{$embedPath}">
                        <description>{$schemaIssue/text()}</description>
                        <location line="{$location}"/>
                    </issue>
        }
        catch * {
            <issue type="schema" role="error">
                <description>ERROR {$err:code} in XML Schema validation: {$err:description, "', module: ", $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</description>
                <location line=""/>
            </issue>
        }
    (: ==== END XML Schema validation of B64 encoded parts in messageInstance. Requires flattened CDA XSD (!) ==== :)
    
    let $g := if ($val:debug) then (util:log('DEBUG', concat('============ START EMBEDDED Schematron validation of embedded instances. Mappings found ',count($mappings/*)))) else ()
    
    (: ==== START Schematron validation of B64 encoded parts in messageInstance. Requires SVRL version of SCH (!) ==== :)
    (:            TODO: this refers hardcoded to schematronfile peri20-seo-1c.xsl, should be replaced with a function to derive correct schematron :)
    let $embeddedSchematronIssues := 
        try {
            for $b64 in $messageInstance//*[string(@representation)='B64' or string(@xsi:type)='xs:base64Binary']
            let $embedPath                := local:path-to-node-with-pos($b64)
            (:decode:)
            let $decodedString     := util:base64-decode($b64)
            (: parse into XML and get first node (otherwise we are document-node level and getSchematronFile will fail to get the root element name) :)
            let $decodedMessage    := 
                try {
                    util:parse($decodedString)/*
                }
                catch * {
                    <de:error xmlns:de="http://art-decor.org/ns/error">{concat($err:code, ' while getting message instance: ', $err:description, ', module: ', $err:module, '(', $err:line-number, ',', $err:column-number, ')')}</de:error>
                }
            let $embeddedSchematronReport := 
                if ($decodedMessage/self::de:error) then (
                    <noerror/>
                ) else (
                    val:validateSchematronCDA($decodedMessage, $baseCollectionSCH, $mappings)
                )
            return
                if (not(empty($embeddedSchematronReport))) then (
                    for $issue in $embeddedSchematronReport//*[@role='warning' or @role='error']
                    let $location := replace(replace($issue/@location,'\*:([^\[]+)\[namespace-uri\(\)=''urn:hl7-org:v3''\]','hl7:$1'),'\[1\]','')
                    return
                        <issue type="schematron" role="{$issue/@role}" test="{$issue/@test}" see="{$issue/@see}" flag="{$issue/@flag}" embed="{$embedPath}">
                            <description>{$issue/svrl:text/text()}</description>
                            <location path="{$location}"/>
                        </issue>
                ) else ()
        }
        catch * {
            <issue type="schematron" role="error">
                <description>ERROR {$err:code} in Schematron validation on embedded instance: {$err:description, "', module: ", $err:module, "(", $err:line-number, ",", $err:column-number, ")"}</description>
                <location path=""/>
            </issue>
        }
    (: ==== END Schematron validation of B64 encoded parts in messageInstance. Requires SVRL version of SCH (!) ==== :)
    
    let $issueReport := <validationReport validationBase="{$config/xis:xmlResourcesPath}">{$schemaIssues|$schematronIssues|$embeddedSchemaIssues|$embeddedSchematronIssues}</validationReport>
    (: DB path to XSL that handles the final returned view of all errors/warnings :)

    return val:makeIssueReport($issueReport)
};

declare function val:pseudoValidation ($file as xs:string, $account as xs:string) as node()* {
    (: Test account XIS configuration data :)
    let $config            := doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:xis
    
    let $schemaIssues :=
        <issue type="schema" role="error">
            <description>Message not validated against XML Schema. XML validation is off for this account</description>
            <location path=""/>
        </issue>
    let $schematronIssues :=
        <issue type="schematron" role="warning">
            <description>Message not validated against Schematron. XML validation is off for this account</description>
            <location path=""/>
        </issue>
    
    let $issueReport := <validationReport validationBase="{$config/xis:xmlResourcesPath}">{$schemaIssues|$schematronIssues}</validationReport>
    (: DB path to XSL that handles the final returned view of all errors/warnings :)
    return val:makeIssueReport($issueReport)
};

declare function val:revalidate($account as xs:string, $file as xs:string, $xpath as xs:string?) as xs:boolean {
    let $accountPath       := concat($get:strXisAccounts, '/',$account)
    let $reportPath        := concat($accountPath, '/reports/')
    let $report            := concat($reportPath, $file)
    
    (: Test account XIS configuration data :)
    let $validationBase    := 
        if (not(empty($account))) then
            doc($get:strTestAccounts)//xis:testAccount[@name=$account]/xis:xis/xis:xmlResourcesPath
        else ()
    
    (: create on option to switch validation off :)
    (: set this option on test-accounts.xml, for example :)
    (:   <testAccount id="3" name="route66" displayName="Route 66" validationSwitchOff="true"> :)
    let $validationSwitchOff := 
        if (not(empty($account))) then
            exists(doc($get:strTestAccounts)//xis:testAccount[@name=$account]//xis:xmlValidation[string(.)='false'])
        else (false())
        
    (: write the $validationSwitchOff to exist log :)
    let $g                  := util:log('DEBUG', concat('---($validationSwitchOff)--- Is validation on (switch=false=default) or off (switch=true) ', $validationSwitchOff))

    return if (string-length($account)>0 and string-length($file)>0 and string-length($xpath)>0) then
        (: Create collection for reports if necessary :)
        let $collectiondummy   :=
            if (not(xmldb:collection-available(concat($accountPath, '/reports')))) then
                xmldb:create-collection($accountPath, '/reports')
            else ()
        return
            (: Does pseudo-validation if validation is turned off :) 
            if ($validationSwitchOff) then (
                let $store := 
                    if (not(doc-available($report))) then 
                        xdb:store($reportPath, $file, val:pseudoValidation($file, $account))
                    else ()
                
                return false()
            (: Does revalidation if validationBase has changed in the account since last validation :) 
            ) else if (not(doc-available($report))) then (
                let $store := xdb:store($reportPath, $file, val:validateMessage($file, $account, $xpath))
                
                return true()
            (: Does revalidation if validationBase has changed in the account since last validation :) 
            ) else if (doc($report)/validationReport[empty(@validationBase) or @validationBase != $validationBase]) then (
                let $store := xdb:remove($reportPath, $file)
                let $store := xdb:store($reportPath, $file, val:validateMessage($file, $account, $xpath))
                
                return true()
            ) else (false())
    else (false())
};