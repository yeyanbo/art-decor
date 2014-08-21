xquery version "3.0";
(:
    Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
    
    Author: Marc de Graauw

    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../../art/modules/art-decor-settings.xqm";
import module namespace aduser  = "http://art-decor.org/ns/art-decor-users" at "../../art/api/api-user-settings.xqm";
declare namespace output        = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";

declare option exist:serialize "method=html5 media-type=text/html encoding=UTF-8";

let $id             := if (request:exists()) then request:get-parameter('id', '') else '' 
let $effectiveDate  := if (request:exists()) then request:get-parameter('effectiveDate', '') else ''
let $prefix         := if (request:exists()) then request:get-parameter('prefix', '') else ''
let $clone          := if (request:exists()) then request:get-parameter('clone', 'false') else 'false'
let $dataset        := if (request:exists()) then request:get-parameter('dataset', '') else ''
let $language       := if (request:exists()) then request:get-parameter('language', $get:strArtLanguage) else ''

let $decor          := collection('/db/apps/decor/data')//decor[project/@prefix=$prefix]
let $dataset        := if ($dataset) then $dataset else $decor//dataset[last()]/@id/string()
let $resources      := doc('../resources/form-resources.xml')/artXformResources/resources[@xml:lang=$language]

let $xml := if ($id = '') 
    then
<rules xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <!-- Temple will copy @id and @effectiveDate from template to templateAssociation --> 
  <templateAssociation/>
  <!-- Create an @id derived from a baseId to create a new template --> 
  <template id='' name='' displayName='' effectiveDate='' statusCode='new'>
    <desc language="{$decor/project/@defaultLanguage}"></desc>
  </template>
</rules>
    else
<rules xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">{
    <!-- Temple will copy @id and @effectiveDate from template to templateAssociation -->, 
    element templateAssociation {$decor//templateAssociation[@templateId=$id][@effectiveDate=$effectiveDate]/*},  
    $decor//template[@id=$id][@effectiveDate=$effectiveDate]}
</rules>

(: Create a clone, if desired :)
let $xml :=
    if ($clone='true') then
        <rules xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">{
            <!-- Temple will copy @id and @effectiveDate from template to templateAssociation -->, 
            $xml/templateAssociation,
              <!-- Create an @id derived from a baseId to create a new template -->, 
            element template {
                attribute id {''},
                attribute effectiveDate {''},
                $xml//template/(@* except (@id | @effectiveDate)),
                $xml//template/*
            }
        }</rules>
    else $xml

let $edit-blocked := (($xml//template/@statusCode='final') or ($xml//template/@statusCode='cancelled') or ($xml//template/@statusCode='rejected'))
let $html :=
    <html>
        <head>
            <title>Temple: {data($xml//template/@name)}</title>
            <meta charset="utf-8" />
        
            <link rel="stylesheet" href="../script/codemirror/lib/codemirror.css"/>
            <link rel="stylesheet" href="../script/codemirror/addon/hint/show-hint.css"/>
            <link rel="stylesheet" href="../script/codemirror/addon/fold/foldgutter.css" />
            <link rel="stylesheet" href="../css/temple.css"/>
            <script src="../script/codemirror/lib/codemirror.js"></script>
            <script src="../script/codemirror/addon/hint/show-hint.js"></script>
            <script src="../script/codemirror/addon/hint/xml-hint.js"></script>
            <script src="../script/codemirror/mode/xml/xml.js"></script>
            <script src="../script/codemirror/addon/edit/closetag.js"></script>
            <script src="../script/codemirror/addon/fold/foldcode.js"></script>
            <script src="../script/codemirror/addon/fold/foldgutter.js"></script>
            <script src="../script/codemirror/addon/fold/brace-fold.js"></script>
            <script src="../script/codemirror/addon/fold/xml-fold.js"></script>
            <script src="../script/codemirror/addon/fold/comment-fold.js"></script>
            <script src="/temple/modules/get-project-types.xquery?prefix={$prefix}&amp;id={$id}&amp;dataset={$dataset}"></script>
            <script src="../script/decor-types.js"></script>
            <script src="../script/common-types.js"></script>
            <script src="../script/decor-schema.js"></script>
            <script src="../script/create-editor.js"></script>
        </head>
        <body>
            <div id="header">
                <table>
                    <tr>
                        <td><img src="../img/temple.jpg" height="50" /></td>
                        <td><h1>Temple: Yet Another Art Decor Template Editor</h1></td>
                        <td><span class="meta-info">{$resources/logged-in-as/string()}: {aduser:getUserDisplayName()}</span></td>
                    </tr>
                </table>
            </div>
            <div id="main">
                <div id="explorer">
                    <!--ul class="templatelist">
                        {for $template in $decor//template
                        return <li><a href="temple.xquery?prefix={$prefix}&amp;id={$template/@id}&amp;effectiveDate={$template/@effectiveDate}&amp;" target="_blank">{data($template/@displayName)} ({data($template/@effectiveDate)})</a></li>
                        }
                    </ul-->
                </div>
                <div id="content">
                    {
                    if ($edit-blocked) then <h3>{$resources/status-is/string()}: {data($xml//template/@statusCode)}, {$resources/editing-is-not-allowed/string()}</h3> else ()
                    } 
                    <div id="editors">
                        <form name="editor" action="save-template.xquery?prefix={$prefix}&amp;id={$id}&amp;effectiveDate={$effectiveDate}" method="post">
                            <div id="menu">
                                <a class="linkbutton" href="temple.xquery?prefix={$prefix}" target="_blank">{$resources/new/string()}</a> 
                                {if ($edit-blocked) then <input type="submit" value="{$resources/save/string()}" disabled="disabled"/> else <input type="submit" value="{$resources/save/string()}" onclick='this.form.action="save-template.xquery?prefix={$prefix}&amp;id={$id}&amp;effectiveDate={$effectiveDate}";'/>}
                                {if ($edit-blocked) then <input type="submit" value="{$resources/validate/string()}" disabled="disabled"/> else <input type="submit" value="{$resources/validate/string()}" onclick='this.form.action="save-template.xquery?prefix={$prefix}&amp;id={$id}&amp;effectiveDate={$effectiveDate}&amp;reportOnly=true";'/>}
                                <a class="linkbutton" href="temple.xquery?prefix={$prefix}&amp;id={$id}&amp;effectiveDate={$effectiveDate}&amp;clone=true" target="_blank">{$resources/clone/string()}</a> 
                                <a class="linkbutton" href="http://www.art-decor.org/mediawiki/index.php/DECOR-rules" target="_blank">{$resources/help/string()}</a> 
                            </div>
                            <textarea id="code" name="code">{$xml}</textarea>
                        </form>
                    </div>
                    <div id="output">
                    </div>
                </div>
                <script>
                    createEditor("code")
                </script>
                <div id="helpers">
                </div>
            </div>    
            <div id="footer">
                <p>(c) 2014 Marc de Graauw <a href="http://www.art-decor.org">http://www.art-decor.org</a></p>
            </div>
        </body>
    </html>
return $html