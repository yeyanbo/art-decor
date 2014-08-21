xquery version "1.0";
(: $Id$ :)
(:
    Module: display running xqueries
:)

declare namespace request   = "http://exist-db.org/xquery/request";
declare namespace xmldb     = "http://exist-db.org/xquery/xmldb";
declare namespace util      = "http://exist-db.org/xquery/util";
declare namespace system    = "http://exist-db.org/xquery/system";
declare option exist:serialize "method=text media-type=text/plain";

let $theactingnotifierusername := if (request:exists()) then request:get-parameter('user', '') else ''
let $theactingnotifierpassword := if (request:exists()) then request:get-parameter('password', '') else ''

let $nl := "&#10;"

return
    if (xmldb:login('/db', $theactingnotifierusername, $theactingnotifierpassword) ) then (
        let $processes := system:get-running-xqueries()//system:xquery
        let $jobs := system:get-running-jobs()//system:job
        return
            if (empty($processes)) then (
                concat('...No running xqueries/jobs are active right now.', $nl)
            ) else (
                concat('...ID Action Info Running Since', $nl),
                for $proc in $processes[not(system:sourceKey/text()='/db/apps/systemtasks/modules/running-jobs.xquery')]
                return (
                    concat('...',
                        $proc/@id/string(), ' ',
                        $proc/system:sourceKey/text(), ' ',
                        $proc/@sourceType/string(), ' ',
                        $proc/@started/string(),
                        $nl
                    )
                )
            )
    ) else ()
