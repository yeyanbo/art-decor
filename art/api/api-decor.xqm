xquery version "1.0";
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
:)
(:~
:   Library of DECOR adminstrative types functions. Most if not all functions are available in two flavors.
:   One based on project prefix and the other based on some element inside the project usually the decor
:   root element. It is the expectation that these function are sometimes called somewhere in the middle of 
:   other logic. Therefor you may be at any point in the decor project at the stage where to you need to call
:   a function in this library.
:   The $decor parameter is always used as $decor/ancestor-or-self::decor[project] to make sure we have the 
:   correct starting point.
:   Note: unlike Java, XQuery doesn't distinguish functions by the same based on signature of the parameters
:         so all functions that take $decor are postfixed with a P in the function name.
:)
module namespace decor          = "http://art-decor.org/ns/decor";
import module namespace aduser  = "http://art-decor.org/ns/art-decor-users" at "api-user-settings.xqm";
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
declare namespace error         = "http://art-decor.org/ns/decor/error";
declare namespace sm            = "http://exist-db.org/xquery/securitymanager";
declare namespace xs            = "http://www.w3.org/2001/XMLSchema";

(:
:   Legend:
:   Any guest/user always has read access
:
:   @email/         Not supported: handled by api-user-settings for now.
:   @notifier
:
:   @id             User id is an integer that increments with 1 for every user. The id is project unique and does not (necessarily) match across projects
:                           Used e.g. to bind issue authors/assignments to project authors
:
:   @username       Username that corresponds with his exist-db username
:
:   @active         User is active if there is a project/author[@username=$username][@active='true']. Note that they might be deactivated at exist-db level
:                           Maps to: (author[@username=$username][not(@active)] and $username=sm:get-group-members('decor'))
:
:   @datasets       User has write access to datasets (and terminologyAssociations) if there is a project/author[@username=$username][@active='true'][@datasets='true']
:                           Maps to: (author[@username=$username][not(@active)] and $username=sm:get-group-members('decor'))
:
:   @scenarios      User has write access to scenarios (and terminologyAssociations) if there is a project/author[@username=$username][@active='true'][@scenarios='true']
:                           Maps to: (author[@username=$username][not(@active)] and $username=sm:get-group-members('decor'))
:
:   @terminology    User has write access to terminologyAssociations/valueSets/codeSystems if there is a project/author[@username=$username][@active='true'][@terminology='true']
:                           Maps to: (author[@username=$username][not(@active)] and $username=sm:get-group-members('decor'))
:
:   @rules          User has write access to templateAssociations/templates if there is a project/author[@username=$username][@active='true'][@rules='true']
:                           Maps to: (author[@username=$username][not(@active)] and $username=sm:get-group-members('decor'))
:
:   @ids            User has write access to ids/id, but not to ids/(baseId|defaultBaseId) if there is a project/author[@username=$username][@active='true'][@ids='true']
:                           Maps to: (author[@username=$username][not(@active)] and $username=sm:get-group-members('decor'))
:
:   @issues         User has write access to issues if there is a project/author[@username=$username][@active='true'][@issues='true']
:                           Maps to: (author[@username=$username][not(@active)] and $username=sm:get-group-members('decor') and $username=sm:get-group-members('issues'))
:
:   @admin          User is admin if there is a project/author[@username=$username][@active='true'][@admin='true']
:                   Admin users may edit project properties such as: decor/(@*), project, ids/(baseId|defaultBaseId), issues/@notifier
:                           Maps to: (author[@username=$username][not(@active)] and $username=sm:get-group-members('decor') and $username=sm:get-group-members('decor-admin'))
:)
declare variable $decor:AUTHOR-TEMPLATE as element(author)  := 
    <author id="" username="" active="true" datasets="false" scenarios="false" terminology="false" rules="false" ids="false" issues="false" admin="false"/>;

(:
:   These statics are needed for function decor:authorCanEditP($decor,$username,$sections). 
:   If you change something here, you need to update the function too.
:)
declare variable $decor:SECTION-DATASETS                    := 'datasets';
declare variable $decor:SECTION-IDS                         := 'ids';
declare variable $decor:SECTION-ISSUES                      := 'issues';
declare variable $decor:SECTION-RULES                       := 'rules';
declare variable $decor:SECTION-SCENARIOS                   := 'scenarios';
declare variable $decor:SECTION-TERMINOLOGY                 := 'terminology';
declare variable $decor:SECTIONS-ALL as xs:string+          := ($decor:SECTION-DATASETS,
                                                                $decor:SECTION-IDS,
                                                                $decor:SECTION-ISSUES,
                                                                $decor:SECTION-RULES,
                                                                $decor:SECTION-SCENARIOS,
                                                                $decor:SECTION-TERMINOLOGY);

(: ======== GENERAL/READ FUNCTIONS ======== :)

(:
:   Return full project contents based on $prefix or error()
:)
declare function decor:getDecorProject($prefix as xs:string) as element(decor) {
    let $decor      := $get:colDecorData//project[@prefix=$prefix]/ancestor::decor
    
    return
        if ($decor) then
            $decor
        else (
            error(xs:QName('error:ProjectNotFound'),'Project with this prefix does not exist.')
        )
};

(:
:   Returns boolean true|false whether or not the given project exists
:)
declare function decor:isProject($prefix as xs:string) as xs:boolean {
    exists($get:colDecorData//project[@prefix=$prefix]/ancestor::decor)
};

(:
:   Returns boolean true|false whether or not the given project is a repository/BBR
:)
declare function decor:isRepository($prefix as xs:string) as xs:boolean {
    decor:isRepositoryP(decor:getDecorProject($prefix))
};

(:
:   Returns boolean true|false whether or not the given project is a private project
:)
declare function decor:isRepositoryP($decor as element()) as xs:boolean {
    $decor/ancestor-or-self::decor/project/@repository='true'
};

(:
:   Returns boolean true|false whether or not the given project is a private project
:)
declare function decor:isPrivate($prefix as xs:string) as xs:boolean {
    decor:isPrivateP(decor:getDecorProject($prefix))
};

(:
:   Returns boolean true|false whether or not the given project is a private project
:)
declare function decor:isPrivateP($decor as element()) as xs:boolean {
    $decor/ancestor-or-self::decor/project/@private='true'
};

(:
:   Returns all authors from a project. Note that this does not take the exist-db level into account
:)
declare function decor:getAuthors($prefix as xs:string) as xs:string* {
    decor:getAuthorsP(decor:getDecorProject($prefix))
};

(:
:   Returns all authors from a project. Note that this does not take the exist-db level into account
:)
declare function decor:getAuthorsP($decor as element()) as xs:string* {
    $decor/ancestor-or-self::decor/project/author/@username
};

(:
:   Returns all active authors from a project. Note that this does not take the exist-db level into account
:)
declare function decor:getActiveAuthors($prefix as xs:string) as xs:string* {
    decor:getActiveAuthorsP(decor:getDecorProject($prefix))
};

(:
:   Returns all active authors from a project. Note that this does not take the exist-db level into account
:)
declare function decor:getActiveAuthorsP($decor as element()) as xs:string* {
    ($decor/ancestor-or-self::decor/project/author[@active='true']/@username | $decor/ancestor-or-self::decor/project/author[not(@active)]/@username)
};

(:
:   Returns all inactive authors from a project. Note that this does not take the exist-db level into account
:)
declare function decor:getInactiveAuthors($prefix as xs:string) as xs:string* {
    decor:getInactiveAuthorsP(decor:getDecorProject($prefix))
};

(:
:   Returns all inactive authors from a project. Note that this does not take the exist-db level into account
:)
declare function decor:getInactiveAuthorsP($decor as element()) as xs:string* {
    $decor/ancestor-or-self::decor/project/author[@active='false']/@username
};

(:
:   Returns boolean true|false whether or not the current user is active+admin in the given project. Note that they might be deactivated at exist-db level
:)
declare function decor:isProjectAdmin($prefix as xs:string) as xs:boolean {
    decor:isProjectAdminP(decor:getDecorProject($prefix),xmldb:get-current-user())
};

(:
:   Returns boolean true|false whether or not the given user is active+admin in the given project. Note that they might be deactivated at exist-db level
:)
declare function decor:isProjectAdmin($prefix as xs:string, $username as xs:string) as xs:boolean {
    decor:isProjectAdminP(decor:getDecorProject($prefix),$username)
};

(:
:   Returns boolean true|false whether or not the current user is active+admin in the given project. Note that they might be deactivated at exist-db level
:)
declare function decor:isProjectAdminP($decor as element()) as xs:boolean {
    decor:isProjectAdminP($decor,xmldb:get-current-user())
};

(:
:   Returns boolean true|false whether or not the given user is active+admin in the given project. Note that they might be deactivated at exist-db level
:)
declare function decor:isProjectAdminP($decor as element(), $username as xs:string) as xs:boolean {
    exists($decor/ancestor-or-self::decor/project/author[@username=$username][@active='true'][@admin='true'] | $decor/ancestor-or-self::decor/project/author[@username=$username][not(@active)]['decor-admin'=sm:get-user-groups($username)])
};

(:
:   Returns boolean true|false whether or not the current user is active in the given project. Note that they might be deactivated at exist-db level
:)
declare function decor:isActiveAuthor($prefix as xs:string) as xs:boolean {
    decor:isActiveAuthorP(decor:getDecorProject($prefix), xmldb:get-current-user())
};

(:
:   Returns boolean true|false whether or not the given user is active in the given project. Note that they might be deactivated at exist-db level
:)
declare function decor:isActiveAuthor($prefix as xs:string, $username as xs:string) as xs:boolean {
    decor:isActiveAuthorP(decor:getDecorProject($prefix),$username)
};

(:
:   Returns boolean true|false whether or not the current user is active in the given project. Note that they might be deactivated at exist-db level
:)
declare function decor:isActiveAuthorP($decor as element()) as xs:boolean {
    decor:isActiveAuthorP($decor, xmldb:get-current-user())
};

(:
:   Returns boolean true|false whether or not the given user is active in the given project. Note that they might be deactivated at exist-db level
:)
declare function decor:isActiveAuthorP($decor as element(), $username as xs:string) as xs:boolean {
    $username=decor:getActiveAuthorsP($decor)
};

(:
:   Returns boolean true|false whether or not the current user is active in the given project and can edit ALL of the indicated sections.
:   Note that they might be deactivated at exist-db level
:)
declare function decor:authorCanEdit($prefix as xs:string, $sections as xs:string+) as xs:boolean {
    decor:authorCanEditP(decor:getDecorProject($prefix), xmldb:get-current-user(), $sections)
};

(:
:   Returns boolean true|false whether or not the current user is active in the given project and can edit ALL of the indicated sections.
:   Note that they might be deactivated at exist-db level
:)
declare function decor:authorCanEdit($prefix as xs:string, $username as xs:string, $sections as xs:string+) as xs:boolean {
    decor:authorCanEditP(decor:getDecorProject($prefix), $username, $sections)
};

(:
:   Returns boolean true|false whether or not the current user is active in the given project and can edit ALL of the indicated sections.
:   Note that they might be deactivated at exist-db level
:)
declare function decor:authorCanEditP($decor as element(), $sections as xs:string+) as xs:boolean {
    decor:authorCanEditP($decor, xmldb:get-current-user(), $sections)
};

(:
:   Returns boolean true|false whether or not the current user is active in the given project and can edit ALL of the indicated sections.
:   Note that they might be deactivated at exist-db level
:)
declare function decor:authorCanEditP($decor as element(), $username as xs:string, $sections as xs:string+) as xs:boolean {
    let $check          :=
        if ($sections=$decor:SECTIONS-ALL) then () else (
            error(xs:QName('error:UnsupportedSection'),concat('You have at least one unsupported section: ',$sections[not(.=$decor:SECTIONS-ALL)]))
        )

    let $decor          := $decor/ancestor-or-self::decor[project]
    let $activeAuthor   := local:getActiveAuthor($decor,$username)
    (:editor and issues may not need to be a group at some point when all author properties are stored in the decor files:)
    let $isEditor       := if ('editor'=sm:get-groups()) then $username=sm:get-group-members('editor') else true()
    (:any editor may edit issues:)
    let $isIssueEditor  := if ($isEditor=true()) then true() else if ('issues'=sm:get-groups()) then $username=sm:get-group-members('issues') else true()
    
    let $return :=
        if ($activeAuthor) then (
            for $section in $sections
            return
                switch ($section) 
                case $decor:SECTION-DATASETS    return ($activeAuthor/@datasets='true'      or $activeAuthor[not(@active)][$isEditor=true()])
                case $decor:SECTION-IDS         return ($activeAuthor/@ids='true'           or $activeAuthor[not(@active)][$isEditor=true()])
                case $decor:SECTION-ISSUES      return ($activeAuthor/@issues='true'        or $activeAuthor[not(@active)][$isIssueEditor=true()])
                case $decor:SECTION-RULES       return ($activeAuthor/@rules='true'         or $activeAuthor[not(@active)][$isEditor=true()])
                case $decor:SECTION-SCENARIOS   return ($activeAuthor/@scenarios='true'     or $activeAuthor[not(@active)][$isEditor=true()])
                case $decor:SECTION-TERMINOLOGY return ($activeAuthor/@terminology='true'   or $activeAuthor[not(@active)][$isEditor=true()])
                (:default would mean some section we don't support, but that would be impossible at this point:)
                default                         return false()
        )
        else (
            false()
        )
    
    return not(false()=$return)
};

(:
:   Return xs:dateTime(@date) of last release or version in the project or null if none exists
:)
declare function decor:getLastRevisionDate($prefix as xs:string) as xs:dateTime? {
    decor:getLastRevisionDateP(decor:getDecorProject($prefix))
};

(:
:   Return xs:dateTime(@date) of last release or version in the project or null if none exists
:)
declare function decor:getLastRevisionDateP($decor as element()) as xs:dateTime? {
    max($decor/ancestor-or-self::decor/project/(version|release)/xs:dateTime(@date))
};

(:
:   Return xs:dateTime(@date) of last release in the project or null if none exists
:)
declare function decor:getLastReleaseDate($prefix as xs:string) as xs:dateTime? {
    decor:getLastReleaseDateP(decor:getDecorProject($prefix))
};

(:
:   Return xs:dateTime(@date) of last release in the project or null if none exists
:)
declare function decor:getLastReleaseDateP($decor as element()) as xs:dateTime? {
    max($decor/ancestor-or-self::decor/project/release/xs:dateTime(@date))
};

(:
:   Return xs:dateTime(@date) of last version in the project or null if none exists
:)
declare function decor:getLastVersionDate($prefix as xs:string) as xs:dateTime? {
    decor:getLastVersionDateP(decor:getDecorProject($prefix))
};

(:
:   Return xs:dateTime(@date) of last version in the project or null if none exists
:)
declare function decor:getLastVersionDateP($decor as element()) as xs:dateTime? {
    max($decor/ancestor-or-self::decor/project/version/xs:dateTime(@date))
};

(:
:   Return base ids in the project or null if none exists. Each baseId carries attribute @default=true|false to 
:   indicate if it is also a defaultBaseId or not.
:   Using parameter $types you may optionally filter on certain types only. See DECOR format for valid values.
:
:   <baseId id="1.2.3" type="DS" prefix="xyz" default="true"/>
:)
declare function decor:getBaseIds($prefix as xs:string, $types as xs:string*) as element(baseId)* {
    decor:getBaseIdsP(decor:getDecorProject($prefix),$types)
};

(:
:   Return base ids in the project or null if none exists. Each baseId carries attribute @default=true|false to 
:   indicate if it is also a defaultBaseId or not.
:   Using parameter $types you may optionally filter on certain types only. See DECOR format for valid values.
:
:   <baseId id="1.2.3" type="DS" prefix="xyz" default="true"/>
:)
declare function decor:getBaseIdsP($decor as element(), $types as xs:string*) as element(baseId)* {
    let $baseIds        := 
        if (empty($types)) then
            $decor/ancestor-or-self::decor/ids/baseId
        else (
            $decor/ancestor-or-self::decor/ids/baseId[@type=$types]
        )
    
    let $defaultBaseIds := 
        if (empty($types)) then
            $decor/ancestor-or-self::decor/ids/defaultBaseId
        else (
            $decor/ancestor-or-self::decor/ids/defaultBaseId[@type=$types]
        )
    
    return 
        if ($baseIds[@default='true']) then (
            (:assume new style:)
            $baseIds
        ) else (
            (:assume old style:)
            for $baseId in $baseIds
            return
                <baseId>
                {
                    $baseId/@id,
                    $baseId/@type,
                    attribute {'default'} {$baseId/@id=$defaultBaseIds/@id},
                    $baseId/@prefix
                }
                </baseId>
        )
};

(:
:   Return default base ids in the project or null if none exists. Each carries attribute @prefix=text as readable form.
:   Using parameter $types you may optionally filter on certain types only. See DECOR format for valid values.
:
:   <defaultBaseId id="1.2.3" type="DS" prefix="xyz"/>
:)
declare function decor:getDefaultBaseIds($prefix as xs:string, $types as xs:string*) as element(defaultBaseId)* {
    decor:getDefaultBaseIdsP(decor:getDecorProject($prefix),$types)
};

(:
:   Return default base ids in the project or null if none exists. Each carries attribute @prefix=text as readable form.
:   Using parameter $types you may optionally filter on certain types only. See DECOR format for valid values.
:
:   <defaultBaseId id="1.2.3" type="DS" prefix="xyz"/>
:)
declare function decor:getDefaultBaseIdsP($decor as element(), $types as xs:string*) as element(defaultBaseId)* {
    let $baseIds        := 
        if (empty($types)) then
            $decor/ancestor-or-self::decor/ids/baseId
        else (
            $decor/ancestor-or-self::decor/ids/baseId[@type=$types]
        )
    
    let $defaultBaseIds := 
        if (empty($types)) then
            $decor/ancestor-or-self::decor/ids/defaultBaseId
        else (
            $decor/ancestor-or-self::decor/ids/defaultBaseId[@type=$types]
        )
    
    return 
        if ($baseIds[@default='true']) then (
            (:assume new style:)
            for $defaultBaseId in $baseIds
            return
                <defaultBaseId>{$defaultBaseId/(@* except @default)}</defaultBaseId>
        ) else (
            (:assume old style:)
            for $defaultBaseId in $defaultBaseIds
            return
                <defaultBaseId>
                {
                    $defaultBaseId/@id,
                    $defaultBaseId/@type,
                    $defaultBaseId/@prefix,
                    if ($defaultBaseId[@prefix]) then () else (
                        $baseIds[@id=$defaultBaseId/@id]/@prefix
                    )
                }
                </defaultBaseId>
        )
};

(:
:   Return full author element to caller. Caller needs to do write access checking if necessary.
:   Should multiple authors by that username exist, then this is a problem of the project, not this function
:)
declare function local:getAuthor($decor as element(decor)?, $username as xs:string) as element(author)? {
    $decor/project/author[@username=$username]
};

(:
:   Return full author element to caller. Caller needs to do write access checking if necessary.
:   Should multiple authors by that username exist, then this is a problem of the project, not this function
:)
declare function local:getActiveAuthor($decor as element(decor)?, $username as xs:string) as element(author)? {
    ($decor/ancestor-or-self::decor/project/author[@active='true'][@username=$username] | $decor/ancestor-or-self::decor/project/author[not(@active)][@username=$username])
};

(: ======== ADMIN/WRITE FUNCTIONS ======== :)

(:
:   Set/update value of decor/@repository if $isRepository=true. Delete decor/@repository if $isRepository=false
:)
declare function decor:setIsRepository($prefix as xs:string, $isRepository as xs:boolean) {
    decor:setIsRepositoryP(decor:getDecorProject($prefix),$isRepository)
};

(:
:   Set/update value of decor/@repository if $isRepository=true. Delete decor/@repository if $isRepository=false
:)
declare function decor:setIsRepositoryP($decor as element(), $isRepository as xs:boolean) {
    let $check      := decor:checkAdminPermissionsP($decor)
    
    let $decor      := $decor/ancestor-or-self::decor[project]
    
    return
        if ($decor) then
            if ($isRepository=true()) then (
                if ($decor/@repository) then (
                    update value $decor/@repository with $isRepository
                )
                else (
                    update insert attribute repository {$isRepository} into $decor
                )
            )
            else (
                (:default value is false() so delete the attribute if exists:)
                update delete $decor/@repository
            )
        else (
            error(xs:QName('error:ProjectNotFound'),'Project with this prefix does not exist.')
        )
};

(:
:   Set/update value of decor/@private if $isPrivate=true. Delete decor/@private if $isPrivate=false
:)
declare function decor:setIsPrivate($prefix as xs:string, $isPrivate as xs:boolean) {
    decor:setIsPrivateP(decor:getDecorProject($prefix),$isPrivate)
};

(:
:   Set/update value of decor/@private if $isPrivate=true. Delete decor/@private if $isPrivate=false
:)
declare function decor:setIsPrivateP($decor as element(), $isPrivate as xs:boolean) {
    let $check      := decor:checkAdminPermissionsP($decor)
    
    let $decor      := $decor/ancestor-or-self::decor[project]
    
    return
        if ($decor) then
            if ($isPrivate=true()) then (
                if ($decor/@private) then (
                    update value $decor/@private with $isPrivate
                )
                else (
                    update insert attribute private {$isPrivate} into $decor
                )
            )
            else (
                (:default value is false() so delete the attribute if exists:)
                update delete $decor/@private
            )
        else (
            error(xs:QName('error:ProjectNotFound'),'Project with this prefix does not exist.')
        )
};

(:
:   Updates a user in a project with given username and the first available increment as id. Adds the user if necessary when $addIfNecessary=true
:   Upon adding the user, all permissions are defaulted from $decor:AUTHOR-TEMPLATE. In updating the user settings only those $setting attributes 
:   are considered that match an attribute in $decor:AUTHOR-TEMPLATE.
:   Returns the resulting <author.../> element or error
:)
declare function decor:setProjectAuthor($prefix as xs:string, $username as xs:string, $settings as element(author), $addIfNecessary as xs:boolean) as element(author) {
    decor:setProjectAuthorP(decor:getDecorProject($prefix),$username,$settings,$addIfNecessary)
};

(:
:   Updates a user in a project with given username and the first available increment as id. Adds the user if necessary when $addIfNecessary=true
:   Upon adding the user, all permissions are defaulted from $decor:AUTHOR-TEMPLATE. In updating the user settings only those $setting attributes 
:   are considered that match an attribute in $decor:AUTHOR-TEMPLATE.
:   Returns the resulting <author.../> element or error
:)
declare function decor:setProjectAuthorP($decor as element(), $username as xs:string, $settings as element(author), $addIfNecessary as xs:boolean) as element(author) {
    let $check      := decor:checkAdminPermissionsP($decor)
    
    let $decor      := $decor/ancestor-or-self::decor[project]
    let $prefix     := $decor/project/@prefix
    
    (: get update set. skip anything empty. skip anything we don't know (includes email and notifier) :)
    let $update-atts    :=
        for $att in $settings/(@active|@datasets|@scenarios|@terminology|@rules|@ids|@issues|@admin)[not(.='')]
        return
        if ($att castable as xs:boolean) then ($att) else (
            error(xs:QName('error:PermissionInvalid'),concat('Permission ',$att/name(),' must be a boolean value. Found ''',$att/string(),''''))
        )
    
    let $author         := 
        if ($addIfNecessary=true()) then
            (: add the user with default template, this takes care of @id/@username/full name :)
            local:setProjectAuthor($decor, $username)
        else (
            (: author must already exist :)
            $decor/project/author[@username=$username]
        )
    
    (: update properties according to what we determined :)
    let $update         :=
        if ($author) then (
            for $att in $update-atts
            return
                if ($author/@*[name()=$att/name()]) then (
                    update value $author/@*[name()=$att/name()] with $att
                )
                else (
                    update insert $att into $author
                )
        ) else (
            error(xs:QName('error:AuthorNotFound'),'Author with this username does not exist in this project. Cannot update properties.')
        )
    
    return
        decor:getDecorProject($prefix)/project/author[@username=$username]
};

(:
:   Adds a user to a project with given username and the first available increment as id. 
:   All permissions are taken from $decor:AUTHOR-TEMPLATE
:   Returns author element or error
:
:   Dependency aduser:getUserDisplayName($username)
:)
declare function local:setProjectAuthor($decor as element(decor)?, $username as xs:string) as element(author) {
    (:permissions are checked by caller, don't need new check:)
    
    let $project    := $decor/project
    let $author     := $project/author[@username=$username]
    let $newid      := if ($project/author) then string(max($project/author/xs:integer(@id))) else ('1')
    let $newname    := aduser:getUserDisplayName($username)
    let $newauthor  :=
        <author>
        {
            attribute id {$newid},
            attribute username {$username},
            $decor:AUTHOR-TEMPLATE/(@* except (@id|@username)),
            $newname
        }
        </author>
    
    return
        if ($decor) then
            if ($author) then
                (:unexpected but possible... do not need to add anything, just return author as-is:)
                $author
            else (
                (:add user and return what we added:)
                let $add    := update insert $newauthor following $project/(name|desc|copyright|author)[last()]
                return $newauthor
            )
        else (
            error(xs:QName('error:ProjectNotFound'),'Project with this prefix does not exist.')
        )
};

(:
:   Shortcut call to decor:setProjectAuthor to activate a project user. Note: does not manipulate the exist-db setting
:)
declare function decor:activateAuthor($prefix as xs:string, $username as xs:string) as element(author) {
    decor:setProjectAuthor($prefix,$username,<author active="true"/>,false())
};

(:
:   Shortcut call to decor:setProjectAuthor to activate a project user. Note: does not manipulate the exist-db setting
:)
declare function decor:activateAuthorP($decor as element(), $username as xs:string) as element(author) {
    decor:setProjectAuthorP($decor,$username,<author active="true"/>,false())
};

(:
:   Shortcut call to decor:setProjectAuthor to deactivate a project user. Note: does not manipulate the exist-db setting
:)
declare function decor:deactivateAuthor($prefix as xs:string, $username as xs:string) as element(author) {
    decor:setProjectAuthor($prefix,$username,<author active="false"/>,false())
};

(:
:   Shortcut call to decor:setProjectAuthor to deactivate a project user. Note: does not manipulate the exist-db setting
:)
declare function decor:deactivateAuthorP($decor as element(), $username as xs:string) as element(author) {
    decor:setProjectAuthorP($decor,$username,<author active="false"/>,false())
};

(:
:   Returns nothing if the currently logged in user has administrative privileges or error
:)
declare function decor:checkAdminPermissions($prefix as xs:string) {
    if (decor:isProjectAdmin($prefix,xmldb:get-current-user())=true()) then () else (
        error(xs:QName('error:NotPermitted'),'You must have decor administrative privileges for this action.')
    )
};

(:
:   Returns nothing if the currently logged in user has administrative privileges or error
:)
declare function decor:checkAdminPermissionsP($decor as element()) {
    if (decor:isProjectAdminP($decor,xmldb:get-current-user())=true()) then () else (
        error(xs:QName('error:NotPermitted'),'You must have decor administrative privileges for this action.')
    )
};
