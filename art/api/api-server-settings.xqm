xquery version "3.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)
module namespace adserver       = "http://art-decor.org/ns/art-decor-server";
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "../modules/art-decor.xqm";
declare namespace httpclient    = "http://exist-db.org/xquery/httpclient";
declare option exist:serialize "method=xml media-type=text/xml";

(:~
:   The path to the server info file. Copied here so we can remove it from art-decor-settings.xqm
:)
declare variable $adserver:strServerInfo := $get:strServerInfo;
(:~
:   The document contents of the server info. Copied here so we can remove it from art-decor-settings.xqm
:)
declare variable $adserver:docServerInfo := doc($adserver:strServerInfo);
(:~
:   The collection holding valid stylesheet for ART in its various forms (default, terminology, qualification server, ...)
:)
declare variable $adserver:strServerXSLPath := concat($get:strArtResources,'/stylesheets');

(:~
:   Return all settings
:   
:   @return server-info element with contents
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerSettings() as element() {
    $adserver:docServerInfo/server-info
};

(:~
:   Save setting
:   
:   @return nothing or error
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:saveServerSetting($settings as element()) {
    if (local:checkPermissions()) then (
        let $action := $settings/@action
        return 
        switch ($action)
        case 'save-language' return
            adserver:setServerLanguage($settings/defaultLanguage)
        case 'save-server-url' return
            adserver:setServerURLArt($settings/url-art-decor-deeplinkprefix)
        case 'save-services-url' return
            adserver:setServerURLServices($settings/url-art-decor-services)
        case 'save-server-xsl' return
            adserver:setServerXSLArt($settings/xformStylesheet)
        case 'save-repository-servers' return (
            let $currentsvrs := adserver:getServerRepositoryServers()
            let $delete      := 
                for $svr in $currentsvrs/buildingBlockServer 
                return adserver:deleteServerRepositoryServer($svr/@url)
            return
                try {
                    for $svr in $settings/externalBuildingBlockRepositoryServers/buildingBlockServer 
                    return adserver:setServerRepositoryServer($svr)
                }
                catch * {
                    (: one of the new servers returned an error. restore what we had and rethrow our error :)
                    let $delete :=
                        for $svr in adserver:getServerRepositoryServers()/buildingBlockServer
                        return adserver:deleteServerRepositoryServer($svr/@url)
                    let $add    :=
                        for $svr in $currentsvrs/buildingBlockServer
                        return adserver:setServerRepositoryServer($svr)
                    return
                    error(QName($err:module,$err:code),$err:description)
                }
        )
        case 'save-repositories' return (
            let $currentbbrs := adserver:getServerExternalRepositories()
            let $delete      := 
                for $bbr in $currentbbrs/buildingBlockRepository 
                return adserver:deleteServerExternalRepository($bbr/@url, $bbr/@ident)
            return
                try {
                    for $bbr in $settings/externalBuildingBlockRepositories/buildingBlockRepository 
                    return adserver:setServerExternalRepository($bbr)
                }
                catch * {
                    (: one of the new bbrs returned an error. restore what we had and rethrow our error :)
                    let $delete :=
                        for $bbr in adserver:getServerExternalRepositories()/buildingBlockRepository
                        return adserver:deleteServerExternalRepository($bbr/@url, $bbr/@ident)
                    let $add    :=
                        for $bbr in $currentbbrs/buildingBlockRepository
                        return adserver:setServerExternalRepository($bbr)
                    return
                    error(QName($err:module,$err:code),$err:description)
                }
        )
        default return
            error(QName('http://art-decor.org/ns/error', 'UnsupportedAction'), concat('Don''t know what to save. Unsupported action in @action: ',$action,' Supported actions are ''save-language'',''save-server-url'',''save-services-url'',''save-server-xsl'',''save-repository-servers'',''save-repositories'''))
    ) else ()
};

(:~
:   Return the configured server-language or default value 'en-US'
:   
:   @return server-language as xs:string('ll-CC')
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerLanguage() as xs:string {
    if ($adserver:docServerInfo/server-info/defaultLanguage) then
        $adserver:docServerInfo/server-info/defaultLanguage/string()
    else ('en-US')
};

(:~
:   Set the server-language
:   Example: en-US
:   
:   @param $language string value. Must have format ll-CC where ll is lower-case language and CC is uppercase country/region
:   @return nothing or error if you are not dba or if the supplied $language does not match the pattern
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:setServerLanguage($language as xs:string) {
    if (local:checkPermissions()) then (
        if (matches($language,'[a-z]{2}-[A-Z]{2}')) then (
            if ($adserver:docServerInfo/server-info/defaultLanguage) then
                update value $adserver:docServerInfo/server-info/defaultLanguage with $language
            else (
                update insert <defaultLanguage>{$language}</defaultLanguage> into $adserver:docServerInfo/server-info
            )
        ) else (
            error(QName('http://art-decor.org/ns/error', 'InvalidFormat'), 'Language must match pattern ll-CC where ll is lower-case language and CC is uppercase country/region')
        )
    ) else ()
};

(:~
:   Return the configured server-url http or https for ART-DECOR or empty string.
:   Example: http://art-decor.org/art-decor/
:   
:   @return xs:anyURI('http://.../art-decor/')
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerURLArt() as xs:string? {
    if ($adserver:docServerInfo/server-info/url-art-decor-deeplinkprefix) then
        $adserver:docServerInfo/server-info/url-art-decor-deeplinkprefix/string()
    else ()
};

(:~
:   Set the server-url http or https for ART-DECOR server
:   Example: http://art-decor.org/art-decor/
:   
:   @param $url string value. Must have format ^https?://host:port(/path)?/art-decor/
:   @return nothing or error if you are not dba or if the supplied $url does not match the pattern
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:setServerURLArt($url as xs:string) {
    if (local:checkPermissions()) then (
        if ($url castable as xs:anyURI and matches($url,'^https?://.*/art-decor/$')) then (
            if ($adserver:docServerInfo/server-info/url-art-decor-deeplinkprefix) then
                update value $adserver:docServerInfo/server-info/url-art-decor-deeplinkprefix with $url
            else (
                update insert <url-art-decor-deeplinkprefix>{$url}</url-art-decor-deeplinkprefix> into $adserver:docServerInfo/server-info
            )
        ) else (
            error(QName('http://art-decor.org/ns/error', 'InvalidFormat'), 'URL must be castable as xs:anyURI and match pattern ''https?://host:port(/path)?/art-decor/''.')
        )
    ) else ()
};

(:~
:   Return the configured server-url http or https for ART-DECOR services or empty string.
:   Example: http://art-decor.org/decor/services/
:   
:   @return xs:anyURI('http://.../services/')
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerURLServices() as xs:string? {
    if ($adserver:docServerInfo/server-info/url-art-decor-services) then
        $adserver:docServerInfo/server-info/url-art-decor-services/string()
    else ()
};

(:~
:   Set the server-url http or https for ART-DECOR services
:   Example: http://art-decor.org/decor/services/
:   
:   @param $url string value. Must have format ^https?://host:port(/path)?/services/
:   @return nothing or error if you are not dba or if the supplied $url does not match the pattern
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:setServerURLServices($url as xs:string) {
    if (local:checkPermissions()) then (
        if ($url castable as xs:anyURI and matches($url,'^https?://.*/services/$')) then (
            if ($adserver:docServerInfo/server-info/url-art-decor-services) then
                update value $adserver:docServerInfo/server-info/url-art-decor-services with $url
            else (
                update insert <url-art-decor-services>{$url}</url-art-decor-services> into $adserver:docServerInfo/server-info
            )
        ) else (
            error(QName('http://art-decor.org/ns/error', 'InvalidFormat'), 'URL must be castable as xs:anyURI and match pattern ''^https?://host:port(/path)?/services/''.')
        )
    ) else ()
};

(:~
:   Return the configured server-xsl that constitutes the interface for ART or default value apply-rules.xsl.
:   Example: apply-rules.xsl
:   
:   @return xs:string('apply.rules.xsl')
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerXSLArt() as xs:string {
    if ($adserver:docServerInfo/server-info/xformStylesheet) then
        $adserver:docServerInfo/server-info/xformStylesheet/string()
    else ('apply-rules.xsl')
};

(:~
:   Return the available server-xsls that constitutes the interface for ART
:   Example: apply-rules-artdecororg.xsl apply-rules.xsl
:   
:   @return list of available xsls
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerXSLsArt() as xs:string* {
    for $xsl in xmldb:get-child-resources($adserver:strServerXSLPath)[ends-with(.,'.xsl')]
    return $xsl
};

(:~
:   Set the server-xsl that constitutes the interface for ART
:   Example: apply-rules.xsl
:   
:   @param $xsl-resource-name string value of the xsl. Name only!
:   @return nothing or error if you are not dba or if the supplied $xsl-resource-name does not exist
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:setServerXSLArt($xsl-resource-name as xs:string) {
    if (local:checkPermissions()) then (
        let $xsl-resource-name-full := concat($adserver:strServerXSLPath,'/',tokenize($xsl-resource-name,'/')[last()])
        return
        if (doc-available($xsl-resource-name-full)) then (
            if ($adserver:docServerInfo/server-info/xformStylesheet) then
                update value $adserver:docServerInfo/server-info/xformStylesheet with $xsl-resource-name
            else (
                update insert <xformStylesheet>{$xsl-resource-name}</xformStylesheet> into $adserver:docServerInfo/server-info
            )
        ) else (
            error(QName('http://art-decor.org/ns/error', 'InvalidXSL'), concat('XSL does not exist ',$xsl-resource-name-full,'. Call adserver:getServerXSLs for valid values.'))
        )
    ) else ()
};

(:~
:   Return the configured external building block repository servers as XML element
:   Example: 
:   &lt;externalBuildingBlockRepositoryServers&gt;
:       &lt;buildingBlockServer url="http://art-decor.org/decor/services/"/&gt;
:   &lt;/externalBuildingBlockRepositoryServers&gt;
:   
:   @return list of configured external building block repository servers
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerRepositoryServers() as element()? {
    $adserver:docServerInfo/server-info/externalBuildingBlockRepositoryServers
};

(:~
:   Return the configured external building block repository servers as XML element
:   Example input: 
:   &lt;externalBuildingBlockRepositoryServers&gt;
:       &lt;buildingBlockServer url="http://art-decor.org/decor/services/"/&gt;
:   &lt;/externalBuildingBlockRepositoryServers&gt;
:   
:   @param $buildingBlockServer MUST contain the new buildingBlockServer info
:   @return nothing or error you are not dba, or if the buildingBlockServer element does not have attributes @url
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:setServerRepositoryServer($buildingBlockServer as element()) as element()? {
    if (local:checkPermissions()) then (
        if ($buildingBlockServer[name()='buildingBlockServer'][@url] and $buildingBlockServer/@url castable as xs:anyURI and matches($buildingBlockServer/@url,'^https?://.*/services/$')) then (
            let $existingRepositoryServers  := $adserver:docServerInfo/server-info/externalBuildingBlockRepositoryServers
            let $existingRepositoryServer   := $existingRepositoryServers/buildingBlockServer[@url=$buildingBlockServer/@url]
            return
            if ($existingRepositoryServer) then (
                (: BBR already exist. Delete and write new :)
                update replace $existingRepositoryServer with $buildingBlockServer
            )
            else if ($existingRepositoryServers) then
                update insert $buildingBlockServer into $existingRepositoryServers
            else (
                update insert <externalBuildingBlockRepositoryServers>{$buildingBlockServer}</externalBuildingBlockRepositoryServers> into $adserver:docServerInfo/server-info
            )
        ) else (
            error(QName('http://art-decor.org/ns/error', 'InvalidFormat'), 'Element &lt;buildingBlockServer&gt; must have attribute @url and @url must be castable as xs:anyURI and match pattern ''^https?://host:port(/path)?/services/''.')
        )
    ) else ()
};

(:~
:   Delete an existing external building block repository server. The match is done based on @url, the rest is irrelevant.
:   
:   @param $url url of the repository server to-be-deleted
:   @param $ident ident of the repository server to-be-deleted
:   @return nothing or error you are not dba
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:deleteServerRepositoryServer($url as xs:string) {
    if (local:checkPermissions()) then (
        let $existingRepositoryServers  := adserver:getServerRepositoryServers()
        return
            update delete $existingRepositoryServers/buildingBlockServer[@url=$url]
    ) else ()
};

(:~
:   Return the configured internal building block repositories as XML element
:   Example: 
:   &lt;internalBuildingBlockRepositories&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ad1bbr-" type="local"&gt;
:           &lt;name language="en-US"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="de-DE"&gt;CDA Release 2&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ad2bbr-" type="local"&gt;
:           &lt;name language="en-US"&gt;HL7 V3 Value Sets&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;HL7v3-waardenlijsten&lt;/name&gt;
:           &lt;name language="de-DE"&gt;HL7 V3 Value Sets&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ccda-" type="local"&gt;
:           &lt;name language="en-US"&gt;Consolidated CDA 1.1&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;Consolidated CDA 1.1&lt;/name&gt;
:           &lt;name language="de-DE"&gt;Consolidated CDA 1.1&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:   &lt;/internalBuildingBlockRepositories&gt;
:   
:   @return list of configured external building block repositories
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerInternalRepositories() as element() {
    let $thisServer := adserver:getServerURLServices()
    
    return
    <internalBuildingBlockRepositories>
    {
        for $bbr in $get:colDecorData//decor[@repository='true'][not(@private='true')]
        let $ident      := $bbr/project/@prefix
        return
            <buildingBlockRepository url="{$thisServer}" ident="{$ident}" type="local">
            {
                for $lang in art:getArtLanguages()
                return
                    if ($bbr/project/name[@language=$lang]) then
                        $bbr/project/name[@language=$lang]
                    else if ($bbr/project/name[@language='en-US']) then
                        <name language="{$lang}">{$bbr/project/name[@language='en-US']/node()}</name>
                    else (
                        <name language="{$lang}">{$bbr/project/name[@language=$bbr/project/@defaultLanguage]/node()}</name>
                    )
            }
            </buildingBlockRepository>
    }
    </internalBuildingBlockRepositories>
};

(:~
:   Return the configured external building block repositories as XML element
:   Example: 
:   &lt;externalBuildingBlockRepositories&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ad1bbr-" type="external"&gt;
:           &lt;name language="en-US"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="de-DE"&gt;CDA Release 2&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ad2bbr-" type="external"&gt;
:           &lt;name language="en-US"&gt;HL7 V3 Value Sets&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;HL7v3-waardenlijsten&lt;/name&gt;
:           &lt;name language="de-DE"&gt;HL7 V3 Value Sets&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ccda-" type="external"&gt;
:           &lt;name language="en-US"&gt;Consolidated CDA 1.1&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;Consolidated CDA 1.1&lt;/name&gt;
:           &lt;name language="de-DE"&gt;Consolidated CDA 1.1&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:   &lt;/externalBuildingBlockRepositories&gt;
:   
:   @return list of configured external building block repositories
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerExternalRepositories() as element()? {
let $config         := $adserver:docServerInfo/server-info/externalBuildingBlockRepositories
let $art-language   := art:getArtLanguages()
return
    <externalBuildingBlockRepositories>
    {
        for $bbr in $config/buildingBlockRepository
        return
        <buildingBlockRepository>
        {
            $bbr/@*,
            $bbr/name,
            for $lang in $art-language[not(.=$bbr/name/@language)]
            return
                <name language="{$lang}">{$bbr/name[@language='en-US']/node()}</name>
        }
        </buildingBlockRepository>
    }
    </externalBuildingBlockRepositories>
};

(:~
:   Return the configured internal and external building block repositories as XML element
:   Example: 
:   &lt;buildingBlockRepositories&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ad1bbr-" type="external"&gt;
:           &lt;name language="en-US"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="de-DE"&gt;CDA Release 2&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ad2bbr-" type="external"&gt;
:           &lt;name language="en-US"&gt;HL7 V3 Value Sets&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;HL7v3-waardenlijsten&lt;/name&gt;
:           &lt;name language="de-DE"&gt;HL7 V3 Value Sets&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ccda-" type="external"&gt;
:           &lt;name language="en-US"&gt;Consolidated CDA 1.1&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;Consolidated CDA 1.1&lt;/name&gt;
:           &lt;name language="de-DE"&gt;Consolidated CDA 1.1&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="http://myserver.org/decor/services/" ident="bbr1-" type="local"&gt;
:           &lt;name language="en-US"&gt;My BBR 1&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;Mijn BBR 1&lt;/name&gt;
:           &lt;name language="de-DE"&gt;Mein BBR 1&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="http://myserver.org/decor/services/" ident="bbr2-" type="local"&gt;
:           &lt;name language="en-US"&gt;My BBR 2&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;Mijn BBR 2&lt;/name&gt;
:           &lt;name language="de-DE"&gt;Mein BBR 2&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:   &lt;/buildingBlockRepositories&gt;
:   
:   @return list of configured external building block repositories
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getServerAllRepositories() as element() {
    <buildingBlockRepositories>
    {
        adserver:getServerExternalRepositories()/buildingBlockRepository
        ,
        adserver:getServerInternalRepositories()/buildingBlockRepository
    }
    </buildingBlockRepositories>
};

(:~
:   Return the repositories as available at the given server URL as external building block repositories as XML element
:   Example input:
:       http://art-decor.org/decor/services/
:   Example output: 
:   &lt;externalBuildingBlockRepositories used-url="uri-that-was-built-and-used"&gt;
:       &lt;buildingBlockRepository url="$external-server-services-url" ident="ad1bbr-" type="external"&gt;
:           &lt;name language="en-US"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="de-DE"&gt;CDA Release 2&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="$external-server-services-url" ident="ad2bbr-" type="external"&gt;
:           &lt;name language="en-US"&gt;HL7 V3 Value Sets&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;HL7v3-waardenlijsten&lt;/name&gt;
:           &lt;name language="de-DE"&gt;HL7 V3 Value Sets&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:       &lt;buildingBlockRepository url="$external-server-services-url" ident="ccda-" type="external"&gt;
:           &lt;name language="en-US"&gt;Consolidated CDA 1.1&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;Consolidated CDA 1.1&lt;/name&gt;
:           &lt;name language="de-DE"&gt;Consolidated CDA 1.1&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:   &lt;/externalBuildingBlockRepositories&gt;
:   
:   @param $external-server-services-url the full url to the services including the trailing slash, e.g. http://art-decor.org/decor/services/
:   @return list of available external building block repositories
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:getRepositoriesFromServer($external-server-services-url as xs:string) as element() {
    let $service-uri     := concat($external-server-services-url,'ProjectIndex?format=xml')
    return
    try {
        let $requestHeaders  := 
            <headers>
                <header name="Content-Type" value="text/xml"/>
                <header name="Cache-Control" value="no-cache"/>
                <header name="Max-Forwards" value="'0'"/>
            </headers>
        let $server-response := httpclient:head(xs:anyURI($service-uri),false(),$requestHeaders)
        let $server-check    :=
            if ($server-response/@statusCode='200') then ()
            else (
                error(QName('http://art-decor.org/ns/error', 'RetrieveError'), concat('Server returned HTTP status: ',$server-response/@statusCode/string(), ' ''',$server-response/httpclient:body/string(),''''))
            )
        return
        <externalBuildingBlockRepositories used-url="{$service-uri}">
        {
            for $repository in doc($service-uri)/return/project[@repository='true']
            return
                <buildingBlockRepository url="{$external-server-services-url}" ident="{$repository/@prefix}" type="external">
                {
                    for $lang in art:getArtLanguages()
                    return
                    <name language="{$lang}">{$repository/@name/string()}</name>
                }
                </buildingBlockRepository>
        }
        </externalBuildingBlockRepositories>
    }
    catch * {
        error(QName('http://art-decor.org/ns/error', 'RetrieveError'), concat('ERROR ',$err:code,'. Could not retrieve building block repositories from ''',$service-uri,'''. ',$err:description,' module: ',$err:module,' (',$err:line-number,' ',$err:column-number,')'))
    }
};

(:~
:   Set a new or update an existing external building block repositories
:   Example input: 
:       &lt;buildingBlockRepository url="http://art-decor.org/decor/services/" ident="ad1bbr-" type="external"&gt;
:           &lt;name language="en-US"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="nl-NL"&gt;CDA Release 2&lt;/name&gt;
:           &lt;name language="de-DE"&gt;CDA Release 2&lt;/name&gt;
:       &lt;/buildingBlockRepository&gt;
:   
:   @param $buildingBlockRepository MUST contain the new buildingBlockRepository info
:   @return nothing or error you are not dba, or if the buildingBlockRepository element does not have attributes @url, @ident or @type=''external'' and at least one element &lt;name language="ll-CC"&gt;
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:setServerExternalRepository($buildingBlockRepository as element()) {
    if (local:checkPermissions()) then (
        if ($buildingBlockRepository[name()='buildingBlockRepository'][@url][@ident][@type='external'][name/@language]) then (
            let $existingBuildingBlockRepositories  := $adserver:docServerInfo/server-info/externalBuildingBlockRepositories
            let $existingBuildingBlockRepository    := $existingBuildingBlockRepositories/buildingBlockRepository[@url=$buildingBlockRepository/@url][@ident=$buildingBlockRepository/@ident]
            return
            if ($existingBuildingBlockRepository) then (
                (: BBR already exist. Delete and write new :)
                update replace $existingBuildingBlockRepository with $buildingBlockRepository
            )
            else if ($existingBuildingBlockRepositories) then
                update insert $buildingBlockRepository into $existingBuildingBlockRepositories
            else (
                update insert <externalBuildingBlockRepositories>{$buildingBlockRepository}</externalBuildingBlockRepositories> into $adserver:docServerInfo/server-info
            )
        ) else (
            error(QName('http://art-decor.org/ns/error', 'InvalidFormat'), 'Element &lt;buildingBlockRepository&gt; must have attributes @url, @ident and @type=''external'' and at least one element &lt;name language="ll-CC"&gt;')
        )
    ) else ()
};

(:~
:   Delete an existing external building block repository. The match is done based on @url and optionally on @ident, the rest is irrelevant.
:   If you omit $ident then all BBRs for the given $url are deleted
:   
:   @param $url url of the bbr to-be-deleted
:   @param $ident ident of the bbr to-be-deleted
:   @return nothing or error you are not dba
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:deleteServerExternalRepository($url as xs:string, $ident as xs:string?) {
    if (local:checkPermissions()) then (
        let $existingBuildingBlockRepositories  := adserver:getServerExternalRepositories()
        return
            update delete $existingBuildingBlockRepositories/buildingBlockRepository[@url=$url][empty($ident) or @ident=$ident]
    ) else ()
};

(:~
:   Facilitates getting new properties in art/install-data/server-info.xml into the live art-data/server-info.xml copy
:   
:   @return nothing or error you are not dba or if the install-data/server-info.xml file is missing
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function adserver:mergeServerSettings() {
    if (local:checkPermissions()) then (
        let $strServerInfoName := concat(repo:get-root(),'art/install-data/server-info.xml')
        return
        if (doc-available($strServerInfoName)) then ( 
            let $installServerInfo := doc($strServerInfoName)/server-info
            return
                for $setting in $installServerInfo/*
                let $ns := $setting/namespace-uri()
                let $nm := $setting/local-name()
                return
                if ($adserver:docServerInfo/server-info/*[local-name()=$nm][namespace-uri()=$ns]) then (
                    (:already exists:)
                )
                else if ($nm='defaultLanguage') then (
                    adserver:setServerLanguage($setting)
                )
                else if ($nm='url-art-decor-deeplinkprefix') then (
                    adserver:setServerURLArt($setting)
                )
                else if ($nm='url-art-decor-services') then (
                    adserver:setServerURLServices($setting)
                )
                else if ($nm='xformStylesheet') then (
                    adserver:setServerXSLArt($setting)
                )
                else (
                    update insert $setting into $adserver:docServerInfo/server-info
                )
        ) else (
            error(QName('http://art-decor.org/ns/error', 'ServerInfoMissing'), concat('Cannot merge when server-info.xml is missing: ',$strServerInfoName))
        )
    ) else ()
};

(:~
:   Consolidated local function for checking if you are dba when you are writing info.
:   
:   @return nothing or error you are not dba
:   @author Alexander Henket
:   @since 2014-03-27
:)
declare function local:checkPermissions() as xs:boolean {
    if (sm:is-dba(xmldb:get-current-user())) then (true()) else (
        error(QName('http://art-decor.org/ns/error', 'InsufficientPermissions'), 'Must be in group dba to edit')
    )
};