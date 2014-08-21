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
module namespace aduser      = "http://art-decor.org/ns/art-decor-users";

import module namespace get  = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
declare namespace request    = "http://exist-db.org/xquery/request";
declare namespace xmldb      = "http://exist-db.org/xquery/xmldb";
declare namespace xs         = "http://www.w3.org/2001/XMLSchema";
declare namespace sub        = "http://art-decor.org/ns/art-decor-user-subscriptions";
declare option exist:serialize "method=xml media-type=text/xml";

(:~
:   Groups that are allowed to read and/or change properties of users that are not the currently logged in user
:)
declare variable $aduser:editGroups             := ('decor-admin','dba');
(:~
:   The path to the user info file. Copied here so we can remove it from art-decor-settings.xqm
:)
declare variable $aduser:strUserInfo            := $get:strUserInfo;
(:~
:   The document contents of the user info. Copied here so we can remove it from art-decor-settings.xqm
:)
declare variable $aduser:docUserInfo            := doc($aduser:strUserInfo);
(:~
:   To subscribe to certain issues, the type needs to be from this list. Supported types may be found in DECOR.xsd under simpleType DecorObjectType. 
:   Special: #ALL (any issue), #NOOB (issues without objects), #ISAUTHOR (issues the user authored), #ISASSIGNED (issues the user is currently assigned to)
:)
declare variable $aduser:subALL                 := '#ALL';
declare variable $aduser:subNOOB                := '#NOOB';
declare variable $aduser:subISAUTHOR            := '#ISAUTHOR';
declare variable $aduser:subISASSIGNED          := '#ISASSIGNED';
declare variable $aduser:arrSubscriptionTypes   := ($aduser:subALL,$aduser:subNOOB,$aduser:subISAUTHOR,$aduser:subISASSIGNED,doc($get:strDecorTypes)//DecorObjectType/enumeration/@value/string());
(:~
:   The default type of subscription for issues.
:)
declare variable $aduser:arrSubscriptionDefault := ($aduser:subISAUTHOR,$aduser:subISASSIGNED);
(:~
:   Resource that holds all subscriptions
:)
declare variable $aduser:strSubscriptionFile    := 'user-subscriptions.xml';

(:~
:   Return full userInfo for the currently logged in user
:   
:   @return The configured user info e.g. 
:       <user name="john">
:           <defaultLanguage/>
:           <displayName/>
:           <description/>
:           <email/>
:           <organization/>
:           <logins/>
:           <lastissuenotify/>
:       </user>, or null
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserInfo() as xs:string? {
    aduser:getUserInfo(xmldb:get-current-user())
};

(:~
:   Return full userInfo for the given username. If this username is not equal to the currently logged in user, the 
:   currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to get the info for
:   @return The configured user info e.g. 
:       <user name="john">
:           <defaultLanguage/>
:           <displayName/>
:           <description/>
:           <email/>
:           <organization/>
:           <logins/>
:           <lastissuenotify/>
:       </user>, null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserInfo($username as xs:string) as element()? {
    if ($username=xmldb:get-current-user() or sm:get-user-groups(xmldb:get-current-user())=$aduser:editGroups) then
        ($aduser:docUserInfo/users/user[@name=$username])[1]
    else (
        error(QName('http://art-decor.org/ns/error', 'InsufficientPermissions'), concat('User ',xmldb:get-current-user(),' cannot request info for user "',$username,'". User ',xmldb:get-current-user(),' must be a member of any of these groups: ',string-join($aduser:editGroups,' '),')'))
    )
};

(:~
:   Return sequence of user names that have an entry in user-info.xml
:   
:   @return The list of user names, or null
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserList() as xs:string* {
    $aduser:docUserInfo/users/user/@name
};

(:~
:   Return language for the current user (may be guest) or the server language as fallback.
:   
:   @return The configured language e.g. 'en-US'
:   @author Alexander Henket
:   @since 2013-11-07
:   @see aduser:getUserLanguage($username as xs:string, $defaultwhenempty as xs:boolean)
:)
declare function aduser:getUserLanguage() as xs:string {
    aduser:getUserLanguage(xmldb:get-current-user(), true())
};

(:~
:   Return language for the given username or the server language as fallback.
:   
:   @param $username The username to get the info for
:   @return The configured user language e.g. 'en-US', the server language (if no user setting exists) or error()
:   @author Alexander Henket
:   @since 2013-11-07
:   @see aduser:getUserLanguage($username as xs:string, $defaultwhenempty as xs:boolean)
:)
declare function aduser:getUserLanguage($username as xs:string) as xs:string {
    aduser:getUserLanguage($username, true())
};

(:~
:   Return language for the given username. If the user does not have a preference and parameter $defaultwhenempty is true, 
:   the browser language setting is returned, if that fails to get a language, the server language is returned as final 
:   fallback. If the user does not have a preference and parameter $defaultwhenempty is false, the result is empty()
:   If this username is not equal to the currently logged in user, the currently logged in user needs to be part of a group 
:   with permissions. If he is not, an error is returned.
:   
:   @param $username The username to get the info for
:   @return The configured user language e.g. 'en-US', the server language (if no user setting exists) or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserLanguage($username as xs:string, $defaultwhenempty as xs:boolean) as xs:string? {
    let $language := aduser:getUserInfo($username)/defaultLanguage[string-length()>0]
    return
    if ($language or not($defaultwhenempty)) then 
        $language
    else (
        let $lang := local:getSupportedBrowserLanguage()
        return
        if ($lang) then
            $lang
        else (
            $get:strArtLanguage
        )
    )
};

(:~
:   Return language based on browser language. The returned value comes from the list of languages found in 
:   form-resources.xml to make sure it is supported in the interface
:   See also: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
:   Accept-Language: nl,en-us;q=0.7,en;q=0.3
:   Accept-Language: nl-nl
:   Note: Safari sends only 1 language, FireFox a list, mileage may vary per browser (version)
:   
:   @return The first accepted browser language that is also supported by ART e.g. 'en-US', or ()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function local:getSupportedBrowserLanguage() as xs:string? {
    let $supported-languages := doc(concat($get:strArtResources,'/form-resources.xml'))/artXformResources/resources/@xml:lang/string()
    let $accept-language     := if (request:exists()) then request:get-header('accept-language') else ()
    
    let $accepted-and-supported-languages :=
        for $lang-range in tokenize($accept-language,',')
        let $lang := tokenize($lang-range,';')[1]
        return
            if (string-length($lang)=2) then
                (: e.g. $lang=nl :)
                $supported-languages[starts-with(lower-case(.),lower-case($lang))][1]
            else if (string-length($lang)=5) then
                $supported-languages[lower-case(.)=lower-case($lang)][1]
            else ()
    return
        $accepted-and-supported-languages[1]
};

(:~
:   Return organization for the currently logged in user
:   
:   @return The configured organization e.g. 'St. Joseph Hospital', or null
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserOrganization() as xs:string? {
    aduser:getUserOrganization(xmldb:get-current-user())
};

(:~
:   Return organization for the given username. If this username is not equal to the currently logged in user, the 
:   currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to get the info for
:   @return The configured organization e.g. 'St. Joseph Hospital', null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserOrganization($username as xs:string) as xs:string? {
    aduser:getUserInfo($username)/organization
};

(:~
:   Return display name for the currently logged in user, usually his full name
:   
:   @return The configured display name e.g. 'John Doe', or null
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserDisplayName() as xs:string? {
    aduser:getUserDisplayName(xmldb:get-current-user())
};

(:~
:   Return display name for the given username, usually his full name. If this username is not equal to the currently logged in user, the 
:   currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to get the info for
:   @return The configured display name e.g. 'John Doe', null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserDisplayName($username as xs:string) as xs:string? {
    aduser:getUserInfo($username)/displayName
};

(:~
:   Return email for the currently logged in user
:   
:   @return The configured email e.g. 'mailto:johndoe@stjosephhosptial.org', or null
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserEmail() as xs:string? {
    aduser:getUserEmail(xmldb:get-current-user())
};

(:~
:   Return email for the given username. If this username is not equal to the currently logged in user, the 
:   currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to get the info for
:   @return The configured email e.g. 'mailto:johndoe@stjosephhosptial.org', null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserEmail($username as xs:string) as xs:string? {
    aduser:getUserInfo($username)/email
};

(: Purposely disabled: we probably do not want description to be a user-setting thing but rather part of the exist-db user-accounts 
        sm:set-account-metadata($username,'http://exist-db.org/security/description',$description)
:)
(:~
:   Return description for the currently logged in user
:   
:   @return The configured description e.g. 'Added at request of XXX' or null
:   @author Alexander Henket
:   @since 2013-11-07
:)
(:declare function aduser:getUserDescription() as xs:string? {
    aduser:getUserDescription(xmldb:get-current-user())
};
:)

(:~
:   Return description for the given username. If this username is not equal to the currently logged in user, the 
:   currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to get the info for
:   @return The configured description e.g. 'Added at request of XXX', null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
(:declare function aduser:getUserDescription($username as xs:string) as xs:string? {
    aduser:getUserInfo($username)/description
};
:)

(:~
:   Return the date the account was added
:   
:   @return The configured user info e.g. 2013-01-01T12:34:23
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserCreationDate() as xs:dateTime? {
    aduser:getUserCreationDate(xmldb:get-current-user())
};

(:~
:   Return the date the account was added. If this username is not equal to the currently logged in user, the 
:   currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to get the info for
:   @return The configured user info e.g. 2013-01-01T12:34:23, null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserCreationDate($username as xs:string) as xs:dateTime? {
    let $strCreationDate := aduser:getUserInfo($username)/@effectiveDate
    return
    if (exists($strCreationDate)) then
        xs:dateTime($strCreationDate)
    else ()
};

(:~
:   Return last time the currently logged in user was logged in
:   
:   @return The configured last login time e.g. '2013-11-11T13:24:00' or null
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserLastLoginTime() as xs:dateTime? {
    aduser:getUserLastLoginTime(xmldb:get-current-user())
};

(:~
:   Return last time the currently logged in user was logged in. If this username is not equal to the 
:   currently logged in user, the currently logged in user needs to be part of a group with permissions. If he 
:   is not, an error is returned
:   
:   @param $username The username to get the info for
:   @return The configured dateTime as xs:dateTime e.g. '2013-11-11T13:24:00', null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserLastLoginTime($username as xs:string) as xs:dateTime? {
    max(aduser:getUserInfo($username)/logins/login/xs:dateTime(@at))
};

(:~
:   Return last time the currently logged in user was notified for issues
:   
:   @return The configured last notify time e.g. '2013-11-11T13:24:00' or null
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserLastIssueNotify() as xs:dateTime? {
    aduser:getUserLastIssueNotify(xmldb:get-current-user())
};

(:~
:   Return last time the currently logged in user was notified for issues. If this username is not equal to the 
:   currently logged in user, the currently logged in user needs to be part of a group with permissions. If he 
:   is not, an error is returned
:   
:   @param $username The username to get the info for
:   @return The configured dateTime as xs:dateTime e.g. '2013-11-11T13:24:00', null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:getUserLastIssueNotify($username as xs:string) as xs:dateTime? {
    if (aduser:getUserInfo($username)/lastissuenotify/@at castable as xs:dateTime) then (
        xs:dateTime(aduser:getUserInfo($username)/lastissuenotify/@at)
    ) else ()
};

(:~
:   Return the DECOR project subscription settings for the requested project. 
:   
:   @param $prefix - required. The project prefix to get the info for
:   @return one or more issue types for the project, or $aduser:arrSubscriptionDefault
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:getUserDecorSubscriptionSettings($prefix as xs:string) as xs:string+ {
    aduser:getUserDecorSubscriptionSettings(xmldb:get-current-user(),$prefix)
};

(:~
:   Return the DECOR project settings for a specific user and project.
:   
:   @param $username - required. The username to get the info for
:   @param $prefix - required. project prefix to get the info for
:   @return one or more issue types for the project, or $aduser:arrSubscriptionDefault
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:getUserDecorSubscriptionSettings($username as xs:string, $prefix as xs:string) as xs:string+ {
    (:  NOTE: this purposely bypasses the security check implemented in aduser:getUserInfo() because in 
        saving issues the subscriptions need to be updated for all users based on this info, regardless of 
        who was logged in at the time :)
    let $return := 
        if ($get:colDecorData/decor/project[@prefix=$prefix]/author[@username=$username][@notifier='on']) then
            $aduser:subALL
        else (
            ($aduser:docUserInfo/users/user[@name=$username])[1]/decor-settings/project[@prefix=$prefix]/@subscribeIssues
        )
        
    return
        if ($return) then (tokenize($return,' ')) else ($aduser:arrSubscriptionDefault)
};

(:~
:   Return boolean value to indicate if the currently logged in user has a subscription for requested issueId. 
:   
:   @param $issueId - required. The issue id to get the info for
:   @return if subscription exists 'true()', else 'false()'
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:userHasIssueSubscription($issueId as xs:string) as xs:boolean {
    aduser:userHasIssueSubscription(xmldb:get-current-user(),$issueId)
};

(:~
:   Return boolean value to indicate if this username has a subscription for requested issueId. 
:   
:   @param $username - required. The username to get the info for
:   @param $issueId - optional. The issue id to get the info for
:   @return if subscription exists 'true()', else 'false()'
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:userHasIssueSubscription($username as xs:string, $issueId as xs:string) as xs:boolean {
    collection($get:strArtData)/sub:decor-subscriptions/sub:issue[@id=$issueId][@user=$username]/@notify='true'
};

(:~
:   Return potential empty string value to indicate if this username has a subscription for requested issueId. This
:   allows you to distinguish between 'has subscription', 'explicitly does not have a subscription', 'subscription not set'
:   
:   @param $username - required. The username to get the info for
:   @param $issueId - optional. The issue id to get the info for
:   @return if subscription exists 'true()', if explicitly no subscription 'false()', else empty
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function local:userHasIssueSubscription($username as xs:string, $issueId as xs:string?) as xs:boolean? {
    let $subscription := collection($get:strArtData)/sub:decor-subscriptions/sub:issue[@id=$issueId][@user=$username]/@notify
    return
        if ($subscription castable as xs:boolean) then xs:boolean($subscription) else ()
};

(:~
:   Return boolean value to indicate if an issue with certain characteristics is within the settings for automatic subscription
:   for the current logged in user.
:   See aduser:userHasIssueAutoSubscription($username, $prefix, $issueId, $objectTypes, $originalAuthorUserName, $currentAssignedAuthorName)
:   for more info
:   
:   @param $prefix - required. The project prefix to get the info for
:   @param $issueId - optional. The issue id to get the info for
:   @param $objectTypes - optional. The issue object types to get the info for (issue/object/@type)
:   @param $originalAuthorUserName - optional. The username of the original issue author (project/author[@id=issue/tracking[first]/author/@id]/@username)
:   @param $currentAssignedAuthorName - optional. The username of the currently assigned person (project/author[@id=issue/assignment[last]/author/@id]/@username)
:   @return if subscription exists 'true()', if explicitly no subscription 'false()', else empty
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:userHasIssueAutoSubscription($prefix as xs:string, $issueId as xs:string?, $objectTypes as xs:string*, $originalAuthorUserName as xs:string?, $currentAssignedAuthorName as xs:string?) as xs:boolean {
    aduser:userHasIssueAutoSubscription(xmldb:get-current-user(), $prefix, $issueId, $objectTypes, $originalAuthorUserName, $currentAssignedAuthorName)
};

(:~
:   Return boolean value to indicate if an issue with certain characteristics is within the settings for automatic subscription
:   for the current logged in user. Logic:
:   - If the user has explicitly set or unset a subscription, return that value as the auto setting is then irrelevant
:   - If the user has an auto subscription to #ALL issues, return true()
:   - If the user is the current issue author and has an auto subscription to #ISAUTHOR issues, return true()
:   - If the user is the currently assigned to the issue and has an auto subscription to #ISASSIGNED issues, return true()
:   - If the issue has no objects and the user has an auto subscription to #NOOB issues, return true()
:   - If the issue has at least 1 object that the user has an auto subscription for , return true()
:   - Else false()
:   
:   @param $username - required. The username to get the info for
:   @param $prefix - required. The project prefix to get the info for
:   @param $issueId - optional. The issue id to get the info for
:   @param $objectTypes - optional. The issue object types to get the info for (issue/object/@type)
:   @param $originalAuthorUserName - optional. The username of the original issue author (project/author[@id=issue/tracking[first]/author/@id]/@username)
:   @param $currentAssignedAuthorName - optional. The username of the currently assigned person (project/author[@id=issue/assignment[last]/author/@id]/@username)
:   @return if subscription exists 'true()', if explicitly no subscription 'false()', else empty
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:userHasIssueAutoSubscription($username as xs:string, $prefix as xs:string, $issueId as xs:string?, $objectTypes as xs:string*, $originalAuthorUserName as xs:string?, $currentAssignedAuthorName as xs:string?) as xs:boolean {
    let $userSubscriptionSettings   := aduser:getUserDecorSubscriptionSettings($username,$prefix)
    let $userCurrentSubscription    := local:userHasIssueSubscription($username,$issueId)
    return
        if (not(empty($userCurrentSubscription))) then
            (:subscription explicitly set or unset for this particular issue:)
            $userCurrentSubscription
        else if ($userSubscriptionSettings=$aduser:subALL) then
            (:user subscribes to any issue type:)
            true()
        else if ($username=$originalAuthorUserName and $userSubscriptionSettings=$aduser:subISAUTHOR) then
            (:user subscribes to any issue where he is author:)
            true()
        else if ($username=$currentAssignedAuthorName and $userSubscriptionSettings=$aduser:subISASSIGNED) then
            (:user subscribes to any issue where he is the assigned person:)
            true()
        else if (empty($objectTypes) and $userSubscriptionSettings=$aduser:subNOOB) then
            (:user subscribes to any issue where there's no object:)
            true()
        else if (not(empty($objectTypes)) and $objectTypes=$userSubscriptionSettings) then
            (:user subscribes to any issue where there's at least one object of a certain type:)
            true()
        else
            false()
};

(: ----------------  Write functions ---------------- :)

(:~
:   See aduser:createUserInfo($username)
:
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:createUserInfo() as element() {
    aduser:createUserInfo(xmldb:get-current-user())
};

(:~
:   Create basic userInfo if there is no user info yet for the given username. If this username is not equal to the currently 
:   logged in user, the currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   If the given username does not have a matching account in eXist, an error is returned.
:   
:   @param $username The username to set the info for
:   @return The existing user info, or the basic info we just added e.g. 
:       <user name="john">
:           <defaultLanguage/>
:           <displayName/>
:           <description/>
:           <email/>
:           <organization/>
:           <logins/>
:           <lastissuenotify/>
:       </user>, null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:createUserInfo($username as xs:string) as element() {
    let $userInfo    := aduser:getUserInfo($username)
    let $now         := substring(string(current-dateTime()),1,19)
    let $newUserInfo :=
        <user name="{$username}" effectiveDate="{$now}">
            <defaultLanguage>{$get:strArtLanguage}</defaultLanguage>
            <displayName/>
            <email/>
            <organization/>
            <logins/>
            <lastissuenotify/>
            <decor-settings/>
        </user>
    let $update      :=
        if (sm:user-exists($username)) then
            if (not(exists(aduser:getUserInfo($username)))) then (
                update insert $newUserInfo into $aduser:docUserInfo/users
            ) else ()
        else (
            error(QName('http://art-decor.org/ns/error', 'UserDoesNotExist'), concat('User ',$username,' does not have an ART account yet. Cannot add user settings.'))
        )
        
    return
        aduser:getUserInfo($username)
};

(:~
:   See aduser:createUserInfo($username, $language, $displayName, $email, $organization)
:
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserInfo($language as xs:string?, $displayName as xs:string?, $email as xs:string?, $organization as xs:string?) as element() {
    aduser:setUserInfo(xmldb:get-current-user(), $language, $displayName, $email, $organization)
};

(:~
:   Set basic userInfo overwriting any existing info for the given properties. If this username is not equal to the currently 
:   logged in user, the currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to set the info for
:   @param $language The language to set, format 'll-CC' (language-country)
:   @param $displayName The display name to set
:   @param $email The email address to set format user@host.realm
:   @param $organization The organization name to set
:   @return The existing user info after applying the updates e.g. 
:       <user name="john" effectiveDate="2013-01-01T00:00:00">
:           <defaultLanguage>en-US</defaultLanguage>
:           <displayName>John Doe</displayName>
:           <description/>
:           <email/>
:           <organization>St. Johns Hospital</organization>
:       </user>, null or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserInfo($username as xs:string, $language as xs:string?, $displayName as xs:string?, $email as xs:string?, $organization as xs:string?) as element() {
    let $update   := aduser:setUserLanguage($username, $language)
    let $update   := aduser:setUserDisplayName($username, $displayName)
    let $update   := aduser:setUserEmail($username, $email)
    let $update   := aduser:setUserOrganization($username, $organization)
    
    return
        aduser:getUserInfo($username)
};

(:~
:   Purposefully a local function and currently not used. Left in for convenience. @effectiveDate is a new 
:   attribute that needs to be populated to be useful. Must be read-only, so only if the attribute is not set 
:   yet, it is written
:
:   @param $username The username to set the info for
:   @param $language The date/time stamp to set if no value exists yet
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function local:setUserCreationDate($username as xs:string, $datetime as xs:dateTime) {
    let $currentUserInfo := aduser:createUserInfo($username)
    return
        if (exists($currentUserInfo/@effectiveDate)) then (
            (:update value $currentUserInfo/@effectiveDate with $datetime:)
        )
        else (
            update insert attribute effectiveDate {$datetime} into $currentUserInfo
        )
};

(:~
:   @param $language The language to set, format 'll-CC' (language-country) or empty
:   @see aduser:setUserLanguage($username, $language)
:   @author Alexander Henket
:   @since 2013-11-07
:   @since 2014-04-07 Made $language optional so you can 'unset' the language. Applicable to guest user mostly, an empty language will trigger browser language based behavior
:)
declare function aduser:setUserLanguage($language as xs:string?) {
    aduser:setUserLanguage(xmldb:get-current-user(),$language)
};

(:~
:   Sets the default language for the given username. If this username is not equal to the currently 
:   logged in user, the currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to set the info for
:   @param $language The language to set, format 'll-CC' (language-country) or empty
:   @return nothing or error()
:   @error Parameter language SHALL be empty or have the case sensitive format ll-CC, e.g. en-US or de-DE
:   @author Alexander Henket
:   @since 2013-11-07
:   @since 2014-04-07 Made $language optional so you can 'unset' the language. Applicable to guest user mostly, an empty language will trigger browser language based behavior
:)
declare function aduser:setUserLanguage($username as xs:string, $language as xs:string?) {
    let $language        := 
        if (empty($language)) 
        then ''
        else if (matches($language,'^[a-z]{2}-[A-Z]{2}$')) 
        then $language 
        else (
            error(QName('http://art-decor.org/ns/error', 'InvalidParameterFormat'), 'Parameter language SHALL be empty or have the case sensitive format ll-CC, e.g. en-US or de-DE')
        )
    let $currentUserInfo := aduser:createUserInfo($username)
    return
        if (exists($currentUserInfo/defaultLanguage)) then
            update value $currentUserInfo/defaultLanguage with $language
        else (
            update insert <defaultLanguage>{$language}</defaultLanguage> into $currentUserInfo
        )
};

(:~
:   See aduser:setUserOrganization($username, $organization)
:
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserOrganization($organization as xs:string?) {
    aduser:setUserOrganization(xmldb:get-current-user(),$organization)
};

(:~
:   Sets the organization name for the given username. If this username is not equal to the currently 
:   logged in user, the currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to set the info for
:   @param $organization The organization name to set
:   @return nothing or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserOrganization($username as xs:string, $organization as xs:string?) {
    let $organization    := if (exists($organization)) then $organization else ('')
    let $currentUserInfo := aduser:createUserInfo($username)
    return
        if (exists($currentUserInfo/organization)) then
            update value $currentUserInfo/organization with $organization
        else (
            update insert <organization>{$organization}</organization> into $currentUserInfo
        )
};

(:~
:   See aduser:setUserDisplayName($username, $displayName)
:
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserDisplayName($displayName as xs:string?) {
    aduser:setUserDisplayName(xmldb:get-current-user(),$displayName)
};

(:~
:   Sets the display name for the given username. If this username is not equal to the currently 
:   logged in user, the currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to set the info for
:   @param $displayName The display name to set
:   @return nothing or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserDisplayName($username as xs:string, $displayName as xs:string?) {
    let $displayName     := if (exists($displayName)) then $displayName else ('')
    let $currentUserInfo := aduser:createUserInfo($username)
    return
        if (exists($currentUserInfo/displayName)) then
            update value $currentUserInfo/displayName with $displayName
        else (
            update insert <displayName>{$displayName}</displayName> into $currentUserInfo
        )
};

(:~
:   See aduser:setUserEmail($username, $email)
:
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserEmail($email as xs:string?) {
    aduser:setUserEmail(xmldb:get-current-user(),$email)
};

(:~
:   Sets the email address name for the given username. If this username is not equal to the currently 
:   logged in user, the currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to set the info for
:   @param $email The email address to set format user@host.realm
:   @return nothing or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserEmail($username as xs:string, $email as xs:string?) {
    let $email           := if (exists($email)) then $email else ('')
    let $currentUserInfo := aduser:createUserInfo($username)
    return
        if (exists($currentUserInfo/email)) then
            update value $currentUserInfo/email with $email
        else (
            update insert <email>{$email}</email> into $currentUserInfo
        )
};

(: Purposely disabled: we probably do not want description to be a user-setting thing but rather part of the exist-db user-accounts 
        sm:set-account-metadata($username,'http://exist-db.org/security/description',$description)
:)
(:~
:   See aduser:setUserDescription($username, $description)
:
:   @author Alexander Henket
:   @since 2013-11-07
:)
(:declare function aduser:setUserDescription($description as xs:string?) {
    aduser:setUserDescription(xmldb:get-current-user(),$description)
};
:)

(:~
:   Sets the description for the given username. If this username is not equal to the currently 
:   logged in user, the currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to set the info for
:   @param $description The description to set
:   @return nothing or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
(:declare function aduser:setUserDescription($username as xs:string, $description as xs:string?) {
    let $description     := if (exists($description)) then $description else ('')
    let $currentUserInfo := aduser:createUserInfo($username)
    return
        if (exists($currentUserInfo/description)) then
            update value $currentUserInfo/description with $description
        else (
            update insert <description>{$description}</description> into $currentUserInfo
        )
};
:)

(:~
:   See aduser:setUserLastLoginTime($username, $datetime)
:
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserLastLoginTime($datetime as xs:dateTime?) {
    aduser:setUserLastLoginTime(xmldb:get-current-user(),$datetime)
};

(:~
:   Sets the last login time for the given username, keeping no more than the 5 latest login elements. If this username is not equal 
:   to the currently logged in user, the currently logged in user needs to be part of a group with permissions. If he is not, an 
:   error is returned
:   
:   @param $username The username to set the info for
:   @param $datetime The dateTime to set, format yyyy-MM-ddTHH:mm:ss(.sss+/-ZZ:zz)
:   @return nothing or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserLastLoginTime($username as xs:string, $datetime as xs:dateTime?) {
    let $newlastlogin    := <login at="{substring($datetime,1,19)}"/>
    let $currentUserInfo := aduser:createUserInfo($username)
    return
        if (exists($currentUserInfo/logins)) then
            let $logins := 
                for $login in $currentUserInfo/logins/login[@at]
                order by xs:dateTime($login/@at) descending
                return $login
            let $logins :=
                for $login in ($newlastlogin|subsequence($logins,1,4))
                order by xs:dateTime($login/@at) ascending
                return $login
            return
                (: add last login record + last 4 records to avoid too long lists:)
                update replace $currentUserInfo/logins with <logins>{$logins}</logins>
        else (
            (: non-existent logins element, add into user element :)
            update insert <logins>{$newlastlogin}</logins> into $currentUserInfo
        )
};

(:~
:   See aduser:setUserLastIssueNotify($username, $datetime)
:
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserLastIssueNotify($datetime as xs:dateTime?) {
    aduser:setUserLastIssueNotify(xmldb:get-current-user(),$datetime)
};

(:~
:   Sets the last issue notify time for the given username. If this username is not equal to the currently logged in user, the 
:   currently logged in user needs to be part of a group with permissions. If he is not, an error is returned
:   
:   @param $username The username to set the info for
:   @param $datetime The dateTime to set, format yyyy-MM-ddTHH:mm:ss(.sss+/-ZZ:zz)
:   @return nothing or error()
:   @author Alexander Henket
:   @since 2013-11-07
:)
declare function aduser:setUserLastIssueNotify($username as xs:string, $datetime as xs:dateTime?) {
    let $newlastissuenotify := <lastissuenotify at="{substring($datetime,1,19)}"/>
    let $currentUserInfo    := aduser:createUserInfo($username)
    return
        if (exists($currentUserInfo/lastissuenotify)) then
            update replace $currentUserInfo/lastissuenotify with $newlastissuenotify
        else (
            update insert $newlastissuenotify into $currentUserInfo
        )
};

(:~
:   See aduser:setUserDecorSubscriptionSettings($username, $prefix, $issueTypes)
:   
:   @param $prefix The project prefix to set subscriptions for
:   @param $issueTypes  Array of space separated issue object types. Supported types may be found in DECOR.xsd under simpleType DecorObjectType. 
:                       Special: #ALL (any issue), #NOOB (issues without objects), #ISAUTHOR (issues the user authored), #ISASSIGNED (issues the user is currently assigned to)
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:setUserDecorSubscriptionSettings($prefix as xs:string, $issueTypes as xs:string+) {
    aduser:setUserDecorSubscriptionSettings(xmldb:get-current-user(), $prefix, $issueTypes)
};

(:~
:   Sets the settings for the given project. If this username is not equal to the currently logged in user, the 
:   currently logged in user needs to be part of a group with permissions. If he is not, an error is returned.
:   
:   @param $username - required. The username to set the info for
:   @param $prefix - required. The project prefix to set subscriptions for
:   @param $issueTypes - required.  Array of space separated issue object types. Supported types may be found in DECOR.xsd under simpleType DecorObjectType. 
:                       Special: #ALL (any issue), #NOOB (issues without objects), #ISAUTHOR (issues the user authored), #ISASSIGNED (issues the user is currently assigned to)
:   @return nothing or error()
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:setUserDecorSubscriptionSettings($username as xs:string, $prefix as xs:string, $issueTypes as xs:string+) {
    let $inputCheck             :=
        if ($issueTypes[not(.=$aduser:arrSubscriptionTypes)]) then
            error(QName('http://art-decor.org/ns/error', 'InvalidIssueSubscriptionType'), concat('Issue type "',string-join($issueTypes[not(.=$aduser:arrSubscriptionTypes)],' '),'" is not supported. Supported types are "',string-join($aduser:arrSubscriptionTypes,' '),'"'))
        else ()
    let $newProjectSettings     := <project prefix="{$prefix}" subscribeIssues="{string-join($issueTypes,' ')}"/>
    let $currentUserInfo        := aduser:createUserInfo($username)
    let $currentDecorSettings   := $currentUserInfo/decor-settings
    let $currentProjectSettings := $currentDecorSettings/project[@prefix=$prefix]
    
    return
        if ($currentProjectSettings) then
            update replace $currentProjectSettings with $newProjectSettings
        else if ($currentDecorSettings) then
            update insert $newProjectSettings into $currentUserInfo
        else (
            update insert <decor-settings>{$newProjectSettings}</decor-settings> into $currentUserInfo
        )
};

(:~
:   Deletes all active subscriptions for the currently logged in user and the given project or all projects if empty. 
:   Keeps deactivated subscriptions (@notify='false') if $fullreset=false() and deletes those too if $fullreset=true()
:   
:   @param $prefix - optional. The project prefix to set subscriptions for
:   @param $fullreset - required. If false will keep subscriptions that were deactivated. If false will delete any subscription
:   @return nothing
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:deleteUserIssueSubscriptions($prefix as xs:string?, $fullreset as xs:boolean) {
    aduser:deleteUserIssueSubscriptions(xmldb:get-current-user(),$prefix)
};

(:~
:   Deletes all active subscriptions for the given user and the given project or all projects if empty. 
:   Keeps deactivated subscriptions (@notify='false') if $fullreset=false() and deletes those too if $fullreset=true()
:
:   Example: if you want to delete every subscription for user john in all projects 
:       aduser:deleteUserIssueSubscriptions('john', (), true())
:   Example: if you want to delete active subscriptions for user john in project demo1- 
:       aduser:deleteUserIssueSubscriptions('john', 'demo1-', false())
:   
:   @param $username - required. The username to set the info for
:   @param $prefix - optional. The project prefix to set subscriptions for
:   @param $fullreset - required. If false will keep subscriptions that were deactivated. If false will delete any subscription
:   @return nothing
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:deleteUserIssueSubscriptions($username as xs:string, $prefix as xs:string?, $fullreset as xs:boolean) {
    let $delete :=
        if (empty($prefix)) then
            if ($fullreset) then
                update delete collection($get:strArtData)/sub:decor-subscriptions/sub:issue[@user=$username]
            else (
                update delete collection($get:strArtData)/sub:decor-subscriptions/sub:issue[@user=$username][@notify='true']
            )
        else (
            if ($fullreset) then
                update delete collection($get:strArtData)/sub:decor-subscriptions/sub:issue[@user=$username][@prefix=$prefix]
            else (
                update delete collection($get:strArtData)/sub:decor-subscriptions/sub:issue[@user=$username][@prefix=$prefix][@notify='true']
            )
        )
    return ()
};

(:~
:   Sets a subscription for the given issueId and the currently logged in user.
:   
:   @param $issueId - optional. The issue id to set the info for
:   @return nothing
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:setUserIssueSubscription($issueId as xs:string) {
    aduser:setUserIssueSubscription(xmldb:get-current-user(),$issueId)
};

(:~
:   Sets a subscription for the given issueId and the given user.
:   
:   @param $username - required. The username to set the info for
:   @param $issueId - optional. The issue id to set the info for
:   @return nothing
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:setUserIssueSubscription($username as xs:string, $issueId as xs:string) {
    local:updateUserIssueSubscription($username,$issueId,true())
};

(:~
:   Explicitly deactivates a subscription for the given issueId and currently logged in user.
:   
:   @param $username - required. The username to set the info for
:   @param $issueId - optional. The issue id to set the info for
:   @return nothing
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:unsetUserIssueSubscription($issueId as xs:string) {
    aduser:unsetUserIssueSubscription(xmldb:get-current-user(),$issueId)
};

(:~
:   Explicitly deactivates a subscription for the given issueId and the given user.
:   
:   @param $username - required. The username to set the info for
:   @param $issueId - optional. The issue id to set the info for
:   @return nothing
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function aduser:unsetUserIssueSubscription($username as xs:string, $issueId as xs:string) {
    local:updateUserIssueSubscription($username,$issueId,false())
};

(:~
:   Handles the actual logic for aduser:setUserIssueSubscription and aduser:unsetUserIssueSubscription 
:   based on parameter $activate
:   
:   @param $username - required. The username to set the info for
:   @param $issueId - required. The issue id to set the info for
:   @param $activate - required. true() will activate, false() will explicitly deactivate
:   @return nothing
:   @author Alexander Henket
:   @since 2014-06-23
:)
declare function local:updateUserIssueSubscription($username as xs:string, $issueId as xs:string, $activate as xs:boolean) {
    let $prefix                     := $get:colDecorData//issue[@id=$issueId]/ancestor::decor/project/@prefix
    let $checkParam                 :=
        if (empty($prefix) and $activate) then
            error(QName('http://art-decor.org/ns/error', 'UnknownIssue'), concat('Unable to add subscription for issue with id ''',$issueId,''' as it does not exist.'))
        else ()
    
    let $newSubscription            := 
        <decor-subscriptions xmlns="http://art-decor.org/ns/art-decor-user-subscriptions">
            <issue id="{$issueId}" user="{$username}" prefix="{$prefix}" notify="{$activate}"/>
        </decor-subscriptions>
    let $currentDecorSubscriptions  := collection($get:strArtData)/sub:decor-subscriptions
    let $currentSubscription        := $currentDecorSubscriptions/sub:issue[@id=$issueId][@user=$username]
    
    let $update                     :=
        if ($currentSubscription[@notify]) then
            update value $currentSubscription/@notify with string($activate)
        else if ($currentDecorSubscriptions) then
            update insert $newSubscription/sub:issue into $currentDecorSubscriptions
        else (
            let $subscrFile := xmldb:store($get:strArtData,$aduser:strSubscriptionFile,$newSubscription)
            return (
                sm:chgrp(xs:anyURI(concat('xmldb:exist://',$subscrFile)),'decor'),
                sm:chmod(xs:anyURI(concat('xmldb:exist://',$subscrFile)),sm:octal-to-mode('0775')),
                sm:clear-acl(xs:anyURI(concat('xmldb:exist://',$subscrFile)))
            )
        )
    return ()
};