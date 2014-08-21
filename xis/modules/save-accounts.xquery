xquery version "1.0";
(:
	Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers, Alexander Henket
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";

declare namespace sm  = "http://exist-db.org/xquery/securitymanager";
declare namespace xis = "http://art-decor.org/ns/xis";

let $editedAccounts := request:get-data()/*

let $accounts := doc($get:strTestAccounts)/xis:testAccounts
(: create collections and groups if needed :)
let $groups :=
    for $account in $editedAccounts/xis:testAccount
    let $accountName := $account/@name/string()
    return
        <insert>
        {
            if (not(sm:group-exists($accountName))) then
                sm:create-group($accountName,'admin','test account')
            else()
            ,
            if (not(xmldb:collection-available(concat($get:strXisAccounts,'/',$accountName)))) then
               let $createCollection := xmldb:create-collection($get:strXisAccounts,$accountName)
               let $createTestSeries := xmldb:store(concat($get:strXisAccounts, '/',$accountName), 'testseries.xml', <xis:tests xmlns:xis="http://art-decor.org/ns/xis"/>)
               let $createMessageCollection := xmldb:create-collection(concat($get:strXisAccounts, '/',$accountName),'messages')
               let $createReportsCollection := xmldb:create-collection(concat($get:strXisAccounts, '/',$accountName),'reports')
               return
                   <result>
                   {
                       sm:chown($createCollection,'admin'),
                       sm:chgrp($createCollection, $accountName),
                       sm:chmod($createCollection,sm:octal-to-mode('0770')),
                       sm:clear-acl($createCollection),
                       
                       sm:chown($createTestSeries,'admin'),
                       sm:chgrp($createTestSeries,$accountName),
                       sm:chmod($createTestSeries,sm:octal-to-mode('0770')),
                       sm:clear-acl($createTestSeries),

                       sm:chown($createMessageCollection,'admin'),
                       sm:chgrp($createMessageCollection,$accountName),
                       sm:chmod($createMessageCollection,sm:octal-to-mode('0770')),
                       sm:clear-acl($createMessageCollection),

                       sm:chown($createReportsCollection,'admin'),
                       sm:chgrp($createReportsCollection,$accountName),
                       sm:chmod($createReportsCollection,sm:octal-to-mode('0770')),
                       sm:clear-acl($createReportsCollection)
                   }
                   </result>
            else()
            ,
            for $accountUserName in $account/xis:members/xis:user/@id
            return
                if (sm:user-exists($accountUserName)) then
                    if (not(sm:get-user-groups($accountUserName)=$accountName)) then
                        sm:add-group-member($accountName, $accountUserName) 
                    else()
                else()
            ,
            for $dbUserName in sm:list-users()
            return
                if (sm:get-group-members($accountName)=$dbUserName and not($dbUserName=$account/xis:members/xis:user/@id)) then
                    sm:remove-group-member($accountName, $dbUserName)
                else()
        }
        </insert>
return
<response>
{
update value $accounts with $editedAccounts/*
(:$editedAccounts:)

}
</response>

