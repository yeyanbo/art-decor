(:
    Copyright (C) 2013-2014  Marc de Graauw
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
xquery version "1.0";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace ada ="http://art-decor.org/ns/ada-common" at "../modules/ada-common.xqm";

declare namespace sm = "http://exist-db.org/xquery/securitymanager";

declare function local:write4group($uri as xs:anyURI) {
    sm:chown($uri,'admin'),
    sm:chgrp($uri,'ada-user'),
    sm:chmod($uri,'rwxrwx---'),
    sm:clear-acl($uri)
};

declare function local:exec4group($uri as xs:anyURI) {
    sm:chown($uri,'admin'),
    sm:chgrp($uri,'ada-user'),
    sm:chmod($uri,'rwxr-x---'),
    sm:clear-acl($uri)
};

let $project   := if (request:exists()) then request:get-parameter('project',()) else ('demoapp')
let $project   := if (ends-with($project,'-')) then substring($project,1,string-length($project)-1) else ($project)

return
<result>
{
    let $projectdir := xmldb:create-collection($ada:strAdaProjects, $project)
    let $perms      := local:write4group($projectdir)
    let $cc         := xmldb:create-collection($projectdir, 'data')
    let $perms      := local:write4group($cc)
    let $cc         := xmldb:create-collection($projectdir, 'schemas')
    let $perms      := local:exec4group($cc)
    let $cc         := xmldb:create-collection($projectdir, 'new')
    let $perms      := local:exec4group($cc)
    let $cc         := xmldb:create-collection($projectdir, 'modules')
    let $perms      := local:exec4group($cc)
    let $cc         := xmldb:create-collection($projectdir, 'views')
    let $perms      := local:exec4group($cc)
    let $cc         := xmldb:create-collection($projectdir, 'xslt')
    let $perms      := local:exec4group($cc)
    let $cc         := xmldb:create-collection($projectdir, 'definitions')
    let $perms      := local:exec4group($cc)
    return <dir>{$cc}</dir>
}
</result>