xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

declare namespace sm      = "http://exist-db.org/xquery/securitymanager";
declare namespace request = "http://exist-db.org/xquery/request";

let $updatedInfo   := request:get-data()/pass
(:let $updatedInfo   :=
    <pass name="testuser" currpwd="1112" newpwd="ttt" newpwd-confirm="ttt"/>:)

let $userName      := 
    if ($updatedInfo[string-length(@name)>0]) 
    then ($updatedInfo/@name/string())
    else ()
let $userCurrPass  :=
    if ($updatedInfo[string-length(@currpwd)>0]) 
    then ($updatedInfo/@currpwd/string())
    else ()
let $userNewPass   := 
    if ($updatedInfo[@newpwd=@newpwd-confirm and string-length(@newpwd)>0]) 
    then ($updatedInfo/@newpwd/string()) 
    else ()

let $newpwd        := 
    if (not(empty($userName) or empty($userCurrPass) or empty($userNewPass))) 
    then (
        (:if (xmldb:login('/db',$userName,$userCurrPass)) 
        then 
            let $d := sm:passwd($userName,$userNewPass)
            return true()
        else (false()):)
        let $d := sm:passwd($userName,$userNewPass)
        return true()
     )
     else (false())

return
<data-safe>{$newpwd}</data-safe>
