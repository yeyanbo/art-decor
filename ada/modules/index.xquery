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
xquery version "3.0";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
import module namespace ada ="http://art-decor.org/ns/ada-common" at "ada-common.xqm";

<html>
   <head>
      <title>ADA Projects</title>
    </head>
    <body>
       <h1>ADA Projects</h1>
       <ol>{
         for $project in xmldb:get-child-collections($ada:strAdaProjects)
            return
               <li><a href="{concat(ada:getHttpUri($project, 'modules'), 'index.xquery')}">{$project}</a></li>
      }</ol>
    </body>
</html>