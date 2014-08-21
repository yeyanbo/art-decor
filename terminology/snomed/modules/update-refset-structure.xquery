xquery version "1.0";
(:
	Copyright (C) 2011-2013 Art Decor Expert Group art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace art ="http://art-decor.org/ns/art" at "xmldb:exist:///db/apps/art/modules/art-decor.xqm";
import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "xmldb:exist:///db/apps/art/modules/art-decor-settings.xqm";

let $oldRefsets := collection(concat($get:strTerminologyData,'/snomed-refsets/data'))//refset[not(ancestor::refsetProject)]

let $updatedRefsets :=
for $refset in $oldRefsets
   let $effectiveDate:=min($refset//member/@effectiveTime/xs:date(.))
   return
   <refsetProject id="{$refset/@id}" private="false">
         <project>
         {
         $refset/project/@*,
         $refset/project/name,
         $refset/desc,
         $refset/project/author
         }
         </project>
      {$refset/moduleDependency}
      <refsetVersions>
         <refset id="{$refset/@id}" effectiveDate="{$effectiveDate}" statusCode="{$refset/@statusCode}" versionLabel="">
            {
            for $member in $refset/members/member
            let $concept:= 
            collection(concat($get:strTerminologyData,'/snomed-data/en-GB'))//concept[@conceptId=$member/referencedComponent/@id]
            return
            <member>
            {
            $member/@*,
            $member/lastStatusChange,
            for $translation in $member/translation[string-length() gt 0]
               let $text := normalize-space($translation/text())
               return
               <desc statusCode="draft" type="pref" id="{util:uuid()}" count="{count(tokenize($text,'\s'))}" length="{string-length($text)}" effectiveTime="" moduleId="{$refset/moduleDependency/@referencedComponentId}" languageCode="nl" typeId="900000000000013009" caseSignificanceId="900000000000020002">{$text}</desc>
            }
            <concept>
            {
            $concept/@*,
            $concept/desc,
            $concept/ancestors,
            $concept/dest
            }
            <refsets>
               {
               for $set in $concept/refsets/refset
               return
               <refset refsetId="{$refset/@refsetId}"/>
               }
            </refsets>
            <maps>
               {
               for $map in $concept/maps/map
               return
               <map refsetId="{$map/@refsetId}"/>
               }
            </maps>
            </concept>
            </member>
            }
         </refset>
      </refsetVersions>
      {$refset/issues}
   </refsetProject>
  return
  <updated>
  {$updatedRefsets}
  </updated>
  
