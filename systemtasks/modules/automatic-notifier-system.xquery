xquery version "3.0";
(:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Kai Heitmann

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get      = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
import module namespace art      = "http://art-decor.org/ns/art" at "../../art/modules/art-decor.xqm";
import module namespace aduser   = "http://art-decor.org/ns/art-decor-users" at "../../art/api/api-user-settings.xqm";
import module namespace adserver = "http://art-decor.org/ns/art-decor-server" at "../../art/api/api-server-settings.xqm";

(:
    Email through Sendmail from eXist about recently changed issues per user per trigger
:)

declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace response      = "http://exist-db.org/xquery/response";
declare namespace mail          = "http://exist-db.org/xquery/mail";
declare namespace datetime      = "http://exist-db.org/xquery/datetime";
declare namespace xmldb         = "http://exist-db.org/xquery/xmldb";

let $deeplinkprefix            := if (request:exists()) then request:get-parameter('deeplinkprefix', adserver:getServerURLArt()) else (adserver:getServerURLArt())
let $mysender                  := if (request:exists()) then request:get-parameter('mysender','ART-DECOR Notifier <reply.not.possible@art-decor.org>') else ('ART-DECOR Notifier <reply.not.possible@art-decor.org>')

(: a secret parameter :)
let $secret                    := if (request:exists()) then request:get-parameter('secret', '') else ('')

(: get login credentials :)
let $theactingnotifierusername := if (request:exists()) then request:get-parameter('user', '') else ('')
let $theactingnotifierpassword := if (request:exists()) then request:get-parameter('password', '') else ('')

let $now                       := datetime:format-dateTime(current-dateTime(),"yyyy-MM-dd' 'HH:mm:ss")
(:~ use localhost :)
let $smtp                      := ()

(: multi language form resource :)
let $resource := doc(concat($get:strArtResources, '/form-resources.xml'))/artXformResources

let $notifyresult              :=
    if ($secret='61fgs756.s9' and (xmldb:login('/db', $theactingnotifierusername, $theactingnotifierpassword))) then
        <notify>
        {
            (: go thru every project :)
            for $pa in $get:colDecorData//project[@id][not(ancestor::decor/issues/@notifier='off')]
            let $issues           := $pa/ancestor::decor/issues
            let $projectprefix    := $pa/@prefix
            let $projectlanguage  := $pa/@defaultLanguage
            let $projectname      := $pa/name[@language=$projectlanguage]/text()
            (: 
                do the notifications per project
            :)
            return
            <project projectid="{$pa/@id}" projectname="{$projectname}" projectprefix="{$projectprefix}" projectlanguage="{$projectlanguage}" issuecount="{count($issues/issue)}" notifier="on">
            {
                (: go thru every user of this project with an email address :)
                for $pu in $pa/author[@email][@username][not(@username='guest')]
                (: store user name :)
                let $user               := $pu/@username
                (: store email of this user :)
                let $email              := if (starts-with($pu/@email, 'mailto:')) then substring-after($pu/@email, 'mailto:') else string($pu/@email)
                (: debug ************************* mail only to kh :)
                (: let $email        := 'hl7@kheitmann.de' :)
                (: debug ************************* mail only to kh :)
                (: when was the last time issues were notified, if never (or error) then assume "very long ago" :)
                let $lastissuenotify := 
                    if (aduser:getUserLastIssueNotify($user) castable as xs:dateTime)
                    then (aduser:getUserLastIssueNotify($user))
                    else (xs:dateTime('1981-01-01T00:00:00'))
                (: store notifications :)
                let $nfspu           :=
                    <notifies>
                    {
                        (: go thru every issue of this project :)
                        for $i at $issuecount in $issues/issue
                        let $issueid                 := $i/@id/string()
                        let $userissubscribed        := aduser:userHasIssueSubscription($user, $issueid)
                        (: only the issue # :)
                        let $issuenumber             := tokenize($issueid, '\.')[last()]
                        (: title of the issue :)
                        let $issuetitle              := $i/@displayName
                        let $lastTouchedObject       := $i//(tracking|assignment)[@effectiveDate=max($i//(tracking|assignment)/xs:dateTime(@effectiveDate))][last()]
                        let $lastTouchedObjectStatus := $lastTouchedObject/@statusCode
                        return
                            <issue issuenumber="{$issuenumber}" issuetitle="{$issuetitle}" laststatus="{$lastTouchedObjectStatus}">
                            {
                                (: return all issue's trackings or assignments touched after $lastissuenotify for this user :)
                                for $ii in $i//(tracking|assignment)
                                (: when tracking|assignment was last touched :)
                                let $thisTouch       := $ii/@effectiveDate
                                let $thisStatus      := $ii/@statusCode
                                (: last action taken :)
                                let $what            := if($ii/name()='tracking') then $resource/resources[@xml:lang=$projectlanguage]/tracking else if ($ii/name()='assignment') then $resource/resources[@xml:lang=$projectlanguage]/assignment else ''
                                (: touched by whome :)
                                let $modifiedby      :=
                                    if (string-length($ii/author/text())>0)
                                    then $ii/author/text()
                                    else if (string-length($ii/author/@id)>0)
                                    then $ii/author/@id
                                    else 'unknown'
                                return
                                    if ($userissubscribed and $lastissuenotify < $thisTouch) then
                                        <notify issueid="{$issueid}" issuenumber="{$issuenumber}" issuetitle="{$issuetitle}"
                                            modifier="{$modifiedby}" what="{$what}" assignmentto="{$ii/@name}" status="{$thisStatus}"
                                            touched="{datetime:format-dateTime($thisTouch, "yyyy-MM-dd' at 'HH:mm")}">
                                        {
                                             $ii/@statusCode,
                                             $ii
                                        }
                                        </notify>
                                    else ()
                             }
                             </issue>
                     }
                     </notifies>
                (: go thru all notifications for this user, prepare message and send email, one per project :)
                let $message :=
                    if (count($nfspu//notify)=0) then () else (
                        <mail>
                            <from>{$mysender}</from>
                            <to>{$email}</to>
                            <subject>{concat($resource/resources[@xml:lang=$projectlanguage]/changeonissues/text(), ' ', $projectname)}</subject>
                            <message>
                                <xhtml>
                                    <html>
                                        <head>
                                            <title>{concat($resource/resources[@xml:lang=$projectlanguage]/changeonissues/text(), ' ', $projectname)}</title>
                                        </head>
                                        <body>
                                        {
                                            <p>
                                                <h3>{concat($resource/resources[@xml:lang=$projectlanguage]/changeonissues/text(), ' ', $projectname, ' ', $resource/resources[@xml:lang=$projectlanguage]/as-of, ' ', $now)}</h3>
                                                <br/>{concat($resource/resources[@xml:lang=$projectlanguage]/compiledforuser, ' ', $user, ' (', $email, '). ', $resource/resources[@xml:lang=$projectlanguage]/dontreply)}
                                            </p>
                                        }
                                        {
                                            for $issue in $nfspu/issue[notify]
                                            let $iheading := concat($resource/resources[@xml:lang=$projectlanguage]/issue, ' #', $issue/@issuenumber, ': ', $issue/@issuetitle)
                                            let $istatus := if (string-length($issue/@laststatus)>0) then concat(' [', $resource/resources[@xml:lang=$projectlanguage]/issue-status ,': ', $issue/@laststatus, '].') else '.'
                                            return (
                                                <p>
                                                {
                                                    <hr/>,
                                                    <strong>{$iheading}{$istatus}</strong>,
                                                    <br/>,
                                                    $resource/resources[@xml:lang=$projectlanguage]/directlink1/text(), ' ',
                                                    <a href='{$deeplinkprefix}/decor-issues--{$projectprefix}?issueId={$issue/@issuenumber}&amp;serclosed=true&amp;language={$projectlanguage}'>{concat($resource/resources[@xml:lang=$projectlanguage]/directlink2/text(), '...')}</a>,
                                                    for $nf at $icnt in $issue/notify
                                                    let $txt := concat($resource/resources[@xml:lang=$projectlanguage]/anew, ' ', $nf/@what, ' ', $resource/resources[@xml:lang=$projectlanguage]/hasbeenadded, ' ', $nf/@modifier, 
                                                        ' on ', $nf/@touched, 
                                                        if ($nf/@what='assignment') then concat(', ', $resource/resources[@xml:lang=$projectlanguage]/nowassignedto,' ', $nf/@assignmentto) else '',
                                                        if ($nf/@statusCode) then concat(', ', $resource/resources[@xml:lang=$projectlanguage]/status,': ', $nf/@statusCode) else ()
                                                        )
                                                    let $backgroundcolor := if ($nf/@statusCode='closed') then '#F4FFF4' else if ($nf/@statusCode=('rejected','deferred','cancelled')) then 'D1DDFF' else '#FFEAEA'
                                                    return
                                                        <p>
                                                            {
                                                                <div style="background-color:{$backgroundcolor}; margin: 10px 0 0 10px; padding: 3px;">{$txt}</div>
                                                            }
                                                            {
                                                                for $nd in $nf/(tracking|assignment)/desc
                                                                return
                                                                    <div style="background-color:#EEEEEE; margin: 0 0 0 10px; padding: 3px;">{$nd}</div>
                                                            }
                                                        </p>
                                                    }
                                                </p>
                                            )
                                        }
                                        </body>
                                    </html>
                                </xhtml>
                            </message>
                        </mail>
                    )
                
                
                let $dummy1 := <disabled/>
                (: debug ************************* do send an email :)
                let $dummy1 := if (not(empty($message))) then if (mail:send-email($message, $smtp, "UTF-8")) then <success/> else <failure/> else ()
                (: debug ************************* do send an email :)
                
                let $test   := 
                    if (empty($message)) then () else (
                        <mail to="{$message/to/text()}" subject="{$message/subject/text()}" user="{$user}" >
                        {
                            for $nf in $nfspu//notify
                            return (
                                <notify>{$nf/@*}</notify>
                            ),
                            $dummy1
                        }
                        </mail>
                    )
                (: debug ************************* do not update the lastissuenotify of this user :)
                let $message := ()
                (: debug ************************* do not update the lastissuenotify of this user :)
                
                return $test
            }
            </project>
        }
        </notify>
    else
        <empty/>
        
return 
    <notifyresult>
    {
        $notifyresult
    }
    {
        for $up in $notifyresult//project/mail
        group by $upuser := $up/@user
        return
            (: set last notified if user exist :)
            let $updateUser         := if (empty(aduser:getUserInfo($upuser))) then '-missing-' else aduser:setUserLastIssueNotify($upuser,current-dateTime()) 
            let $newlastissuenotify := <lastissuenotify at="{aduser:getUserLastIssueNotify($upuser)}"/>
            return
                <userupdateon user="{$upuser}" mailsuccess="{count($notifyresult//project/mail/success)}" mailfailure="{count($notifyresult//project/mail/failure)}">
                {
                    if ($updateUser='-missing-') then attribute error { 'user-is-missing-on-this-system' } else ()
                }
                {
                    if ($updateUser='-missing-') then () else $newlastissuenotify
                }
                </userupdateon>
    }
    </notifyresult>