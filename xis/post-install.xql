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
import module namespace adpfix  = "http://art-decor.org/ns/art-decor-permissions" at "api/api-permissions.xqm";
declare namespace sm            = "http://exist-db.org/xquery/securitymanager";
declare namespace xmldb         = "http://exist-db.org/xquery/xmldb";
declare namespace xis           = "http://art-decor.org/ns/xis";
declare namespace cfg           = "http://exist-db.org/collection-config/1.0";
declare namespace repo          = "http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
declare variable $root := repo:get-root();

declare function local:storeSettings() {
    if (doc-available(concat($root,'xis-data/test-accounts.xml'))) then () else (
        xmldb:copy(concat($root,'xis/resources'),concat($root,'xis-data'),'test-accounts.xml')
    ),
    if (doc-available(concat($root,'xis-data/soap-service-list.xml'))) then () else (
        xmldb:copy(concat($root,'xis/resources'),concat($root,'xis-data'),'soap-service-list.xml')
    ),
    if (doc-available(concat($root,'xis-data/test-suites.xml'))) then () else (
        xmldb:store(concat($root,'xis-data'), 'test-suites.xml', <testsuites/>)
    ),
    if (xmldb:collection-available(concat($root,'xis-data/data'))) then () else (
        xmldb:create-collection(concat($root,'xis-data'),'data'),
        xmldb:copy(concat($root,'xis/data'),concat($root,'xis-data'))
    ),
    if (xmldb:collection-available(concat($root,'xis-data/vocab'))) then () else (
        xmldb:create-collection(concat($root,'xis-data'),'vocab'),
        xmldb:copy(concat($root,'xis/resources/vocab'),concat($root,'xis-data'))
    )
};
 
(: helper function for creating test account collections and settings permissions :)
declare function local:createTestAccounts() {
    let $accounts := doc(concat($root,'xis-data/test-accounts.xml'))/xis:testAccounts
    for $account in $accounts/xis:testAccount
        let $accountName := $account/@name/string()
        
        return
        if (string-length($accountName)>1) then (
            (: create group if needed :)
            if (not(sm:group-exists($accountName))) then
                sm:create-group($accountName,'admin','test account')
            else()
        ,
        (: create collection if needed and set permissions :)
        if (not(xmldb:collection-available(concat($root,'xis-data/accounts/',$accountName)))) then (
            xmldb:create-collection(concat($root,'xis-data/accounts/'),$accountName),
            xmldb:create-collection(concat($root,'xis-data/accounts/',$accountName),'messages'),
            xmldb:create-collection(concat($root,'xis-data/accounts/',$accountName),'reports'),
            xmldb:store(concat($root,'xis-data/accounts/',$accountName), 'testseries.xml', <xis:tests/>),
            
            sm:chown(xs:anyURI(concat($root,'xis-data/accounts/',$accountName)),'admin'),
            sm:chgrp(xs:anyURI(concat($root,'xis-data/accounts/',$accountName)),$accountName),
            sm:chmod(xs:anyURI(concat($root,'xis-data/accounts/',$accountName)),sm:octal-to-mode('0770')),
            sm:clear-acl(xs:anyURI(concat($root,'xis-data/accounts/',$accountName))),
            
            sm:chown(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/messages')),'admin'),
            sm:chgrp(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/messages')),$accountName),
            sm:chmod(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/messages')),sm:octal-to-mode('0770')),
            sm:clear-acl(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/messages'))),
            
            sm:chown(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/reports')),'admin'),
            sm:chgrp(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/reports')),$accountName),
            sm:chmod(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/reports')),sm:octal-to-mode('0770')),
            sm:clear-acl(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/reports'))),
            
            sm:chown(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/testseries.xml')),'admin'),
            sm:chgrp(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/testseries.xml')),$accountName),
            sm:chmod(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/testseries.xml')),sm:octal-to-mode('0770')),
            sm:clear-acl(xs:anyURI(concat($root,'xis-data/accounts/',$accountName,'/testseries.xml')))
        )
        else()
        ,
        (: if users exist in database, add users to group :)
        for $user in $account/xis:members/xis:user
        let $accountUserName := $user/@id
        return
            if (sm:user-exists($user)) then
                if (not(sm:get-user-groups($accountUserName)=$accountName)) then
                    sm:add-group-member($accountName, $accountUserName) 
                else()
            else()
        )
    else()

};

(: check if message collection exists, if not then create and set permissions :)
local:storeSettings(),
local:createTestAccounts(),
adpfix:setXisDataPermissions()
