xquery version "3.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Santosh Chandak (santoshchandak@gmail.com), Marc de Graauw

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get         = "http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
import module namespace art         = "http://art-decor.org/ns/art" at "art-decor.xqm";
import module namespace aduser      = "http://art-decor.org/ns/art-decor-users" at "../api/api-user-settings.xqm";
import module namespace adserver    = "http://art-decor.org/ns/art-decor-server" at "../api/api-server-settings.xqm";

declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace response      = "http://exist-db.org/xquery/response";
declare namespace hl7           = "urn:hl7-org:v3";
declare namespace xmldb         = "http://exist-db.org/xquery/xmldb";
declare namespace ev            = "http://www.w3.org/2001/xml-events";
declare namespace xforms        = "http://www.w3.org/2002/xforms";
declare namespace xhtml         = "http://www.w3.org/1999/xhtml";
declare namespace fr            = "http://orbeon.org/oxf/xml/form-runner";
declare namespace xs            = "http://www.w3.org/2001/XMLSchema";
declare namespace xxforms       = "http://orbeon.org/oxf/xml/xforms";
declare namespace widget        = "http://orbeon.org/oxf/xml/widget";

declare variable $art-languages := art:getArtLanguages();
declare variable $decor-types   := art:getDecorTypes();

(: 
    This function generates nested repeat xforms structure for <concept/> node, 
    the nesting level depends on $arg1
:)
declare function local:generateNestedXFormBlock($deep as xs:integer) as element()* {
let $temp := $deep
return
if ($deep > 0) then
    <xforms:repeat nodeset="concept">
        <xforms:group ref=".[@type='item' and not(@absent)]">
            <xhtml:table style="width:100%">
                <xhtml:tr>
                    <xhtml:td class="item-label">
                        <xxforms:variable name="statusCode" select="@statusCode"/>
                        <xforms:output mediatype="image/*" value="concat('../img/node-s',$statusCode,'.png')">
                            <xforms:hint>
                                <xforms:output ref="$resources/status"/> = <xforms:output ref="instance('decor-types')/IssueStatusCodeLifeCycle/enumeration[@value=$statusCode]/label[@language=$resources/@xml:lang]"/>
                            </xforms:hint>
                        </xforms:output>
                        <xforms:output ref="name[@language=instance('language')]"/>
                        <xxforms:variable name="itemId" select="@id"/>
                        <xhtml:div class="buttons">
                            <xforms:trigger ref=".[$editor]" appearance="minimal">
                                <xforms:label>
                                    <xhtml:img src="/img/itemdelete.png" alt=""/>
                                </xforms:label>
                                <xforms:hint appearance="minimal">delete this item</xforms:hint>
                                <xforms:insert ev:event="DOMActivate" nodeset="@*" origin="instance('scratchpad')/@absent"/>
                                <!-- Note the dependancy on matching the concept id while deleting  -->
                                <xforms:delete ev:event="DOMActivate" if="count(../concept[@type='item' and @id=$itemId]) &gt; 1" nodeset="."/>
                            </xforms:trigger>
                        </xhtml:div>
                    </xhtml:td>
                    <xhtml:td width="5%">
                        <xforms:group ref=".[@conformance=('','R','M')]">
                            <xforms:input ref="@minimumMultiplicity" class="short-number">
                                <xforms:alert>
                                    <xforms:output ref="$resources/input-must-be-numeric"/>
                                </xforms:alert>
                            </xforms:input>
                        </xforms:group>
                    </xhtml:td>
                    <xhtml:td width="5%">
                        <xforms:group ref=".[@conformance=('','R','M')]">
                            <xforms:input ref="@maximumMultiplicity" class="short-number">
                                <xforms:alert>
                                    <xforms:output ref="$resources/input-must-be-numeric-or-star"/>, <xforms:output ref="$resources/maximum-must-be-greater-then-minimum"/>
                                </xforms:alert>
                            </xforms:input>
                        </xforms:group>
                    </xhtml:td>
                    <xhtml:td>
                        <xforms:select1 ref="@conformance" class="auto-width">
                            <xforms:itemset nodeset="instance('conformance')//enumeration">
                                <xforms:label ref="label[@language=instance('language')]"/>
                                <xforms:value ref="@value"/>
                            </xforms:itemset>
                            <xforms:hint>
                                <xforms:output ref="$resources/conformance"/>
                            </xforms:hint>
                            <xforms:action ev:event="xforms-value-changed">
                                <xxforms:variable name="current-value" select="."/>
                                <xforms:action if="$current-value='M' and ../@minimumMultiplicity=0">
                                    <xforms:setvalue ref="../@minimumMultiplicity" value="1"/>
                                </xforms:action>
                                <xforms:action if="count(../condition)=0">
                                    <xforms:insert ev:event="DOMActivate" context=".." nodeset="*" origin="xxforms:element('condition',(xxforms:attribute('minimumMultiplicity','0'),xxforms:attribute('maximumMultiplicity','1'),xxforms:attribute('conformance','R'),xxforms:attribute('isMandatory','false')))"/>
                                    <xforms:insert ev:event="DOMActivate" context=".." nodeset="*" origin="xxforms:element('condition',(xxforms:attribute('minimumMultiplicity','0'),xxforms:attribute('maximumMultiplicity','0'),xxforms:attribute('conformance','NP'),xxforms:attribute('isMandatory','false')))"/>
                                </xforms:action>
                            </xforms:action>
                        </xforms:select1>
                    </xhtml:td>
                    <xhtml:td>
                        <xforms:group ref=".[@conformance='C']">
                            <xhtml:table width="100%" style="background-color:#f0ebe4;">
                                <xforms:repeat nodeset="condition">
                                    <xhtml:tr class="not-selectable">
                                        <xhtml:td width="50%">
                                            <xxforms:variable name="isLast" select="position()=last()"/>
                                            <xforms:group ref=".[not($isLast)]">
                                                <xforms:input ref="." class="medium-text"/>
                                            </xforms:group>
                                            <xforms:group ref=".[$isLast]">
                                                <xforms:output ref="$resources/in-all-other-cases"/>
                                            </xforms:group>
                                        </xhtml:td>
                                        <xhtml:td width="10%">
                                            <xforms:group ref=".[@conformance=('','R','M')]">
                                                <xforms:input ref="@minimumMultiplicity" class="short-number">
                                                    <xforms:alert>
                                                        <xforms:output ref="$resources/input-must-be-numeric"/>
                                                    </xforms:alert>
                                                </xforms:input>
                                            </xforms:group>
                                        </xhtml:td>
                                        <xhtml:td width="10%">
                                            <xforms:group ref=".[@conformance=('','R','M')]">
                                                <xforms:input ref="@maximumMultiplicity" class="short-number">
                                                    <xforms:alert>
                                                        <xforms:output ref="$resources/input-must-be-numeric-or-star"/>
                                                        <xforms:output ref="$resources/maximum-must-be-greater-then-minimum"/>
                                                    </xforms:alert>
                                                </xforms:input>
                                            </xforms:group>
                                        </xhtml:td>
                                        <xhtml:td>
                                            <xforms:select1 ref="@conformance" class="auto-width">
                                                <xforms:itemset nodeset="instance('conformance')//enumeration[@value!='C']">
                                                    <xforms:label ref="label[@language=instance('language')]"/>
                                                    <xforms:value ref="@value"/>
                                                </xforms:itemset>
                                                <xforms:hint>
                                                    <xforms:output ref="$resources/conformance"/>
                                                </xforms:hint>
                                                <xforms:action ev:event="xforms-value-changed">
                                                    <xxforms:variable name="current-value" select="."/>
                                                    <xforms:action if="$current-value='M' and ../@minimumMultiplicity=0">
                                                        <xforms:setvalue ref="../@minimumMultiplicity" value="1"/>
                                                    </xforms:action>
                                                </xforms:action>
                                            </xforms:select1>
                                        </xhtml:td>
                                        <xhtml:td width="10%">
                                            <xhtml:div class="buttons">
                                                <xforms:button ref=".[$editor][not($isLast)][count(../condition)&gt;2]" appearance="minimal">
                                                    <xforms:label>
                                                        <xhtml:img src="/img/itemdelete.png" alt=""/>
                                                    </xforms:label>
                                                    <xforms:hint appearance="minimal">
                                                        <xforms:output ref="$resources/remove"/>
                                                    </xforms:hint>
                                                    <xforms:delete ev:event="DOMActivate" nodeset="."/>
                                                </xforms:button>
                                                <xforms:trigger ref=".[$editor][not($isLast)]" appearance="minimal">
                                                    <xforms:label>
                                                        <xhtml:img src="/img/itemadd.png" alt=""/>
                                                    </xforms:label>
                                                    <xforms:hint appearance="minimal">
                                                        <xforms:output ref="$resources/add"/>
                                                    </xforms:hint>
                                                    <xforms:insert ev:event="DOMActivate" nodeset="." origin="xxforms:element('condition',(xxforms:attribute('minimumMultiplicity','0'),xxforms:attribute('maximumMultiplicity','1'),xxforms:attribute('conformance',''),xxforms:attribute('isMandatory','false')))"/>
                                                </xforms:trigger>
                                            </xhtml:div>
                                        </xhtml:td>
                                    </xhtml:tr>
                                </xforms:repeat>
                            </xhtml:table>
                        </xforms:group>
                    </xhtml:td>
                </xhtml:tr>
            </xhtml:table>
        </xforms:group>
    
        <xforms:group ref=".[@type='group' and not(@absent)]">
            <fr:accordion class="fr-accordion-lnf">
                <fr:case selected="true">
                    <fr:label ref="name[@language=instance('language')]">
                        <xxforms:variable name="conceptId" select="@id"/>
                        <xforms:trigger ref=".[$editor]" appearance="minimal">
                            <xforms:label>
                                <xhtml:img src="/img/itemdelete.png" alt=""/>
                            </xforms:label>
                            <xforms:hint appearance="minimal">delete this group</xforms:hint>
                            <xforms:insert ev:event="DOMActivate" nodeset="@*" origin="instance('scratchpad')/@absent"/>
                            <!-- Note the dependancy on matching the concept id while deleting  -->
                            <xforms:delete ev:event="DOMActivate" if="count(../concept[@type='group' and @id=$conceptId]) &gt; 1" nodeset="."/>
                        </xforms:trigger>
                    </fr:label>
                    <xforms:group ref=".[not(@absent)]">
                        <xhtml:table style="width:100%">
                            <xhtml:tr>
                                <xhtml:td class="item-label">
                                    <xforms:output class="bold-text" ref="name[@language=instance('language')]"/>
                                    <xxforms:variable name="itemId" select="@id"/>
                                    <xhtml:div class="buttons">
                                        <xforms:trigger ref=".[$editor]" appearance="minimal">
                                            <xforms:label><xhtml:img src="/img/itemdelete.png" alt=""/></xforms:label>
                                            <xforms:hint appearance="minimal">delete this group</xforms:hint>
                                            <xforms:insert ev:event="DOMActivate" nodeset="@*" origin="instance('scratchpad')/@absent"/>
                                            <!-- Note the dependancy on matching the concept id while deleting  -->
                                            <xforms:delete ev:event="DOMActivate" if="count(../concept[@type='item' and @id=$itemId]) &gt; 1" nodeset="."/>
                                        </xforms:trigger>
                                    </xhtml:div>
                                </xhtml:td>
                                <xhtml:td width="5%">
                                    <xforms:group ref=".[@conformance=('','R','M')]">
                                        <xforms:input ref="@minimumMultiplicity" class="short-number">
                                            <xforms:alert>Alert</xforms:alert>
                                        </xforms:input>
                                    </xforms:group>
                                </xhtml:td>
                                <xhtml:td width="5%">
                                    <xforms:group ref=".[@conformance=('','R','M')]">
                                        <xforms:input ref="@maximumMultiplicity" class="short-number">
                                            <xforms:alert>Alert</xforms:alert>
                                        </xforms:input>
                                    </xforms:group>
                                </xhtml:td>
                                <xhtml:td>
                                    <xforms:select1 ref="@conformance" class="auto-width">
                                        <xforms:itemset nodeset="instance('conformance')//enumeration">
                                            <xforms:label ref="label[@language=instance('language')]"/>
                                            <xforms:value ref="@value"/>
                                        </xforms:itemset>
                                        <xforms:hint>
                                            <xforms:output ref="$resources/conformance"/>
                                        </xforms:hint>
                                        <xforms:action ev:event="xforms-value-changed">
                                            <xxforms:variable name="current-value" select="."/>
                                            <xforms:action if="$current-value='M' and ../@minimumMultiplicity=0">
                                                <xforms:setvalue ref="../@minimumMultiplicity" value="1"/>
                                            </xforms:action>
                                            <xforms:action if="count(../condition)=0">
                                                <xforms:insert ev:event="DOMActivate" context=".." nodeset="*" origin="xxforms:element('condition',(xxforms:attribute('minimumMultiplicity','0'),xxforms:attribute('maximumMultiplicity','1'),xxforms:attribute('conformance','R'),xxforms:attribute('isMandatory','false')))"/>
                                                <xforms:insert ev:event="DOMActivate" context=".." nodeset="*" origin="xxforms:element('condition',(xxforms:attribute('minimumMultiplicity','0'),xxforms:attribute('maximumMultiplicity','0'),xxforms:attribute('conformance','NP'),xxforms:attribute('isMandatory','false')))"/>
                                            </xforms:action>
                                        </xforms:action>
                                    </xforms:select1>
                                </xhtml:td>
                                <xhtml:td>
                                    <xforms:group ref=".[@conformance='C']">
                                        <xhtml:table width="100%" style="background-color:#f0ebe4;">
                                            <xforms:repeat nodeset="condition">
                                                <xhtml:tr class="not-selectable">
                                                    <xhtml:td width="50%">
                                                        <xxforms:variable name="isLast" select="position()=last()"/>
                                                        <xforms:group ref=".[not($isLast)]">
                                                            <xforms:input ref="." class="medium-text"/>
                                                        </xforms:group>
                                                        <xforms:group ref=".[$isLast]">
                                                            <xforms:output ref="$resources/in-all-other-cases"/>
                                                        </xforms:group>
                                                    </xhtml:td>
                                                    <xhtml:td width="10%">
                                                        <xforms:group ref=".[@conformance=('','R','M')]">
                                                            <xforms:input ref="@minimumMultiplicity" class="short-number">
                                                                <xforms:alert>
                                                                    <xforms:output ref="$resources/input-must-be-numeric"/>
                                                                </xforms:alert>
                                                            </xforms:input>
                                                        </xforms:group>
                                                    </xhtml:td>
                                                    <xhtml:td width="10%">
                                                        <xforms:group ref=".[@conformance=('','R','M')]">
                                                            <xforms:input ref="@maximumMultiplicity" class="short-number">
                                                                <xforms:alert>
                                                                    <xforms:output ref="$resources/input-must-be-numeric-or-star"/>
                                                                    <xforms:output ref="$resources/maximum-must-be-greater-then-minimum"/>
                                                                </xforms:alert>
                                                            </xforms:input>
                                                        </xforms:group>
                                                    </xhtml:td>
                                                    <xhtml:td>
                                                        <xforms:select1 ref="@conformance" class="auto-width">
                                                            <xforms:itemset nodeset="instance('conformance')//enumeration[@value!='C']">
                                                                <xforms:label ref="label[@language=instance('language')]"/>
                                                                <xforms:value ref="@value"/>
                                                            </xforms:itemset>
                                                            <xforms:hint>
                                                                <xforms:output ref="$resources/conformance"/>
                                                            </xforms:hint>
                                                            <xforms:action ev:event="xforms-value-changed">
                                                                <xxforms:variable name="current-value" select="."/>
                                                                <xforms:action if="$current-value='M' and ../@minimumMultiplicity=0">
                                                                    <xforms:setvalue ref="../@minimumMultiplicity" value="1"/>
                                                                </xforms:action>
                                                            </xforms:action>
                                                        </xforms:select1>
                                                    </xhtml:td>
                                                    <xhtml:td width="10%">
                                                        <xhtml:div class="buttons">
                                                            <xforms:trigger ref=".[$editor][not($isLast)][count(../condition)&gt;2]" appearance="minimal">
                                                                <xforms:label>
                                                                    <xhtml:img src="/img/itemdelete.png" alt=""/>
                                                                </xforms:label>
                                                                <xforms:hint appearance="minimal">
                                                                    <xforms:output ref="$resources/remove"/>
                                                                </xforms:hint>
                                                                <xforms:delete ev:event="DOMActivate" nodeset="."/>
                                                            </xforms:trigger>
                                                            <xforms:trigger ref=".[$editor][not($isLast)]" appearance="minimal">
                                                                <xforms:label>
                                                                    <xhtml:img src="/img/itemadd.png" alt=""/>
                                                                </xforms:label>
                                                                <xforms:hint appearance="minimal">
                                                                    <xforms:output ref="$resources/add"/>
                                                                </xforms:hint>
                                                                <xforms:insert ev:event="DOMActivate" nodeset="." origin="xxforms:element('condition',(xxforms:attribute('minimumMultiplicity','0'),xxforms:attribute('maximumMultiplicity','1'),xxforms:attribute('conformance',''),xxforms:attribute('isMandatory','false')))"/>
                                                            </xforms:trigger>
                                                        </xhtml:div>
                                                    </xhtml:td>
                                                </xhtml:tr>
                                            </xforms:repeat>
                                        </xhtml:table>
                                    </xforms:group>
                                </xhtml:td>
                            </xhtml:tr>
                        </xhtml:table>
                    </xforms:group>
                    <!-- Repeat the whole stuff here --> 
                    {
                        local:generateNestedXFormBlock($deep - 1)
                    }
                </fr:case>
            </fr:accordion>
        </xforms:group>
        <xforms:group ref=".[@absent]">
            <xhtml:table width="100%">
                <xforms:group ref=".[@type='group']">
                    <xhtml:tr>
                        <xhtml:td class="item-label">
                            <b>
                                <xxforms:variable name="statusCode" select="@statusCode"/>
                                <xforms:output mediatype="image/*" value="concat('../img/node-s',$statusCode,'.png')">
                                    <xforms:hint>
                                        <xforms:output ref="$resources/status"/> = <xforms:output ref="instance('decor-types')/IssueStatusCodeLifeCycle/enumeration[@value=$statusCode]/label[@language=$resources/@xml:lang]"/>
                                    </xforms:hint>
                                </xforms:output>
                                <xforms:output ref="name[@language=instance('language')]"/>
                            </b>
                            <xhtml:div class="buttons">
                                <xforms:trigger ref=".[$editor]" appearance="minimal">
                                    <xforms:label>
                                        <xhtml:img src="/img/itemadd.png" alt=""/>
                                    </xforms:label>
                                    <xforms:hint appearance="minimal">add this group</xforms:hint>
                                    <xforms:delete ev:event="DOMActivate" nodeset="@absent"/>
                                </xforms:trigger>
                            </xhtml:div>
                        </xhtml:td>
                        <xhtml:td/>
                    </xhtml:tr>
                </xforms:group>
                <xforms:group ref=".[@type='item']">
                    <xhtml:tr>
                        <xhtml:td class="item-label">
                            <xxforms:variable name="statusCode" select="@statusCode"/>
                            <xforms:output mediatype="image/*" value="concat('../img/node-s',$statusCode,'.png')">
                                <xforms:hint>
                                    <xforms:output ref="$resources/status"/> = <xforms:output ref="instance('decor-types')/IssueStatusCodeLifeCycle/enumeration[@value=$statusCode]/label[@language=$resources/@xml:lang]"/>
                                </xforms:hint>
                            </xforms:output>
                            <xforms:output ref="name[@language=instance('language')]"/>
                            <xhtml:div class="buttons">
                                <xforms:trigger ref=".[$editor]" appearance="minimal">
                                    <xforms:label>
                                        <xhtml:img src="/img/itemadd.png" alt=""/>
                                    </xforms:label>
                                    <xforms:hint appearance="minimal">add this item</xforms:hint>
                                    <xforms:delete ev:event="DOMActivate" nodeset="@absent"/>
                                </xforms:trigger>
                            </xhtml:div>
                        </xhtml:td>
                        <xhtml:td/>
                    </xhtml:tr>
                </xforms:group>
            </xhtml:table>
        </xforms:group>
    </xforms:repeat>
else()
};

(: 
    This function generates XForms stuff for transaction editor.It requires three arguments
    $arg1 is a count of nested <concept/>, $arg2 is default instance 
:)
declare function local:getXForms($deep as xs:integer, $defaultInstance as element(), $projectPrefix as xs:string?) as element()* {
let $temp := $deep
return
    <xhtml:html xmlns:f="http://orbeon.org/oxf/xml/formatting" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:fr="http://orbeon.org/oxf/xml/form-runner" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xxforms="http://orbeon.org/oxf/xml/xforms" xmlns:widget="http://orbeon.org/oxf/xml/widget" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/1999/xhtml ../../orbeon_schemas/xhtml1-transitional-orbeon.xsd">
        <xhtml:head>
        <xhtml:style type="text/css"><![CDATA[
        .medium-text input {width:20em;}
        .long-text input {width:40em;}
        .bold-text { font-weight: bold }
        .xforms-repeat-selected-item-1.not-selectable {
            font-weight: normal;
            background-color: inherit; 
            color : black
        }
        .xforms-repeat-selected-item-1 .not-selectable {
            font-weight: normal;
            background-color: inherit; 
            color : black
        }
        .xforms-repeat-template.not-selectable {
            font-weight: normal;
            background-color: inherit; 
            color : black
        }
        .xforms-repeat-template .not-selectable {
            font-weight: normal;
            background-color: inherit; 
            color : black
        }
        .xforms-repeat-selected-item-2 {
            font-weight: normal;
            background-color: inherit; 
            color : black
        }
        /* rules for navigation menu */
        /* ========================================== */
        ul#navmenu a {
            background-image:url('../img/menu_background.png'), url('../img/menu_background.png') !important;
        }
        ul#navmenu li:hover &gt; a {
            background-image:url('../img/menu_selected_background.png'), url('../img/menu_selected_background.png') !important;
        }
        ul#navmenu li:hover a:hover {
            background-image:url('../img/menu_selected_background.png'), url('../img/menu_selected_background.png') !important;
        }
        ]]>
        </xhtml:style>
        <xhtml:title>
            <xforms:output ref="if (instance('project-instance')/name[@language=$resources/@xml:lang]) then (instance('project-instance')/name[@language=$resources/@xml:lang]) else (instance('project-instance')/name[1])"/> - 
            <xforms:output ref="$resources/transaction"/>
        </xhtml:title>
        <xforms:model>
            <!-- Variable with path to art-exist for use by form -->
            <xxforms:variable name="art-exist" select="xxforms:property('art.exist.url')"/>
            <!-- Variable with path to decor-eXist used to pass to client as link for services (Diagrams in new window) -->
            <xxforms:variable name="decor-exist" select="xxforms:property('decor.exist.url')"/>
            <!-- Variable with path to terminology-eXist used to pass to client as link for services (SNOMED, LOINC) -->
            <xxforms:variable name="terminology-exist" select="xxforms:property('terminology.exist.url')"/>
            <!-- instance for user-agent, used to check if SVG links should be available -->
            <xforms:instance id="user-agent">
                <agent/>
            </xforms:instance>
            
            <!-- instance for document name -->
            <xforms:instance id="document">
                <name>{$projectPrefix}</name>
            </xforms:instance>
            <!-- instance for project information -->
            <xforms:instance id="project-instance">
                <dummy/>
            </xforms:instance>
            <!-- get decor project submission -->
            <xforms:submission id="get-decor-project-submission" serialization="none" method="get" resource="{{$art-exist}}/modules/get-decor-project.xq?project={{instance('document')}}" replace="instance" instance="project-instance" xxforms:readonly="true">
                <xforms:message ev:event="xforms-submit-error" level="modal">
                    A submission error occurred: <xforms:output value="event('error-type')"/>; Status: <xforms:output value="event('response-status-code')"/>; Reason: <xforms:output value="event('response-reason-phrase')"/>; URI: <xforms:output value="event('resource-uri')"/>; Headers: <xforms:output value="event('response-headers')"/>; Body: <xforms:output value="event('response-body')"/>
                </xforms:message>
            </xforms:submission>
            
            <!-- instance for DECOR Schema types -->
            <xforms:instance id="decor-types">
                <dummy/>
            </xforms:instance>
            <!-- get decor schema types -->
            <xforms:submission id="get-decor-types" serialization="none" method="get" resource="{{$art-exist}}/modules/get-decor-schema-types.xquery" replace="instance" instance="decor-types"/>

            <xforms:instance id="default" xxforms:readonly="false">
                {$defaultInstance}
            </xforms:instance>
            <xforms:bind nodeset="instance('default')" readonly="not($editor)"/>
            <xforms:instance id="scratchpad" xxforms:readonly="false">
                <dummy absent="true"/>
            </xforms:instance>
            <!-- language -->
            <xforms:instance id="language">
                <language/>
            </xforms:instance>
            <!-- resources for internationalization -->
            <xforms:instance id="resources-instance">
                <dummy/>
            </xforms:instance>
            <!-- submission for loading resources -->
            <xforms:submission id="get-resources-submission" serialization="none" method="get" resource="{{$art-exist}}/modules/get-form-resources.xquery" replace="instance" instance="resources-instance"/>
            <xforms:instance id="conformance"> <!-- TODO take it directly from schema :: 20140815 DONE -->
                <conformance>
                    <enumeration value="">
                    {
                        for $language in $art-languages
                        return
                            <label language="{$language}"></label>
                    }
                    </enumeration>
                    {
                        (: Takes care of R (required), C (conditional), NP (not present) :)
                        $decor-types//ConformanceType/enumeration[@value='NP'],
                        $decor-types//ConformanceType/enumeration[@value='C'],
                        $decor-types//ConformanceType/enumeration[@value='R']
                    }
                    <enumeration value="M">
                    {
                        for $element in art:getFormResourcesKey('art',$art-languages,'mandatory')
                        return
                            <label language="{$element/@xml:lang}">{$element/node()}</label>
                    }
                    </enumeration>
                </conformance>
            </xforms:instance>
            <!-- save dataset submission -->
            <xforms:submission id="save-transaction" ref="instance('default')" action="{{$art-exist}}/modules/save-transaction.xquery" method="post" replace="none" xxforms:username="{{xxforms:get-session-attribute('username')}}" xxforms:password="{{xxforms:get-session-attribute('password')}}">
                <xforms:message ev:event="xforms-submit-error" level="modal">A submission error occurred: <xforms:output value="event('error-type')"/>
                    <xforms:output value="event('response-body')"/>
                </xforms:message>
                <xforms:message ev:event="xforms-submit-done" level="modal">Successfully saved the data.</xforms:message>
            </xforms:submission>
            <xforms:bind nodeset="instance('default')">
                <!--TODO error handling min should be less that max-->
                <xforms:bind nodeset="//concept">
                    <xforms:bind nodeset="@minimumMultiplicity" constraint="matches(.,'^[0-9]*$')"/>
                    <xforms:bind nodeset="@maximumMultiplicity" constraint="matches(.,'^[0-9]*$|^\*$')"/>
                    <xforms:bind nodeset="@isMandatory" type="xforms:boolean"/>
                    <xforms:bind nodeset="condition">
                        <xforms:bind nodeset="@minimumMultiplicity" constraint="matches(.,'^[0-9]*$')"/>
                        <xforms:bind nodeset="@maximumMultiplicity" constraint="matches(.,'^[0-9]*$|^\*$')"/>
                        <xforms:bind nodeset="@isMandatory" type="xforms:boolean"/>
                    </xforms:bind>
                </xforms:bind>
                
                <!--xforms:bind nodeset="//concept/@minimumMultiplicity" calculate="if(string(.) = '0' and string(../@isMandatory)='true') then '1' else (.)"/-->
            </xforms:bind>
            <xforms:action ev:event="xforms-model-construct-done">
                <xforms:send submission="get-resources-submission"/>
                <xforms:send submission="get-decor-project-submission"/>
                <xforms:setvalue ref="instance('language')" value="if (string-length(xxforms:get-session-attribute('language'))&gt;0) then (xxforms:get-session-attribute('language')) else (instance('resources-instance')//resources[1]/@xml:lang/string())"/>
                <xforms:send submission="get-decor-types"/>
                <xforms:send submission="get-decor-project-submission"/>
            </xforms:action>
            <!-- relevant language is returned as first node, rest should be empty -->
            <xxforms:variable name="resources" select="instance('resources-instance')//resources[1]"/>
            <xxforms:variable name="editor" select="contains(xxforms:get-session-attribute('groups'),'editor') and instance('project-instance')/author[@username=xxforms:get-session-attribute('username')]"/>
        </xforms:model>
        </xhtml:head>
        <xhtml:body>
        <xhtml:table class="detail" width="100%">
        <xhtml:tr>
            <xhtml:td class="heading" colspan="2">
                <xhtml:div class="heading">
                    <xforms:output ref="instance('default')/name[@language=instance('language')]"/>
                </xhtml:div>
                <!-- div with buttons -->
                <xhtml:div class="buttons">
                    <fr:button ref=".[$editor]">
                        <xforms:label ref="$resources/cancel"/>
                        <xforms:hint appearance="minimal" ref="$resources/cancel"/>
                        <xforms:action ev:event="DOMActivate">
                            <xforms:action if="lock">
                                <xforms:send submission="clear-lock"/>
                                <xforms:setvalue ref="instance('data-safe')">true</xforms:setvalue>
                            </xforms:action>
                            <xforms:setvalue ref="instance('data-safe')">true</xforms:setvalue>
                            <xxforms:script>window.close();</xxforms:script>
                        </xforms:action>
                    </fr:button>
                    <fr:button ref=".[$editor]">
                        <xforms:label ref="$resources/save"/>
                        <xforms:hint appearance="minimal" ref="$resources/save-changes"/>
                        <xforms:send submission="save-transaction" ev:event="DOMActivate"/>
                    </fr:button>
                </xhtml:div>
            </xhtml:td>
        </xhtml:tr>
        <xhtml:tr>
            <xhtml:td class="item-label">
                <xforms:output ref="$resources/id"/>
            </xhtml:td>
            <xhtml:td>
                <xforms:output ref="instance('default')/@id"/>
            </xhtml:td>
        </xhtml:tr>
        <xhtml:tr>
            <xhtml:td class="item-label">
                <xforms:output ref="$resources/name"/>
            </xhtml:td>
            <xhtml:td>
                <xforms:output  ref="instance('default')/name[@language=instance('language')]"/>
            </xhtml:td>
        </xhtml:tr>
        <xhtml:tr>
            <xhtml:td class="item-label">
                <xforms:output ref="$resources/description"/>
            </xhtml:td>
            <xhtml:td>
                <xforms:output  mediatype="text/html" ref="instance('default')/desc[@language=instance('language')]"/>
            </xhtml:td>
        </xhtml:tr>
        <xforms:group ref="instance('default')/representingTemplate[count(concept/@absent)=count(concept)]">
            <xhtml:tr>
                <xhtml:td class="item-label">
                    <xforms:output ref="$resources/functions"/>
                </xhtml:td>
                <xhtml:td>
                    <fr:button ref=".[$editor]">
                        <xforms:label ref="$resources/all-one-one"/>
                        <xforms:action ev:event="DOMActivate">
                            <xforms:action xxforms:iterate=".//concept">
                                <xforms:setvalue ref="context()/@minimumMultiplicity" value="'1'"/>
                                <xforms:setvalue ref="context()/@maximumMultiplicity" value="'1'"/>
                                <xforms:delete context="context()/@absent"/>
                            </xforms:action>
                        </xforms:action>
                    </fr:button>
                    <fr:button ref=".[$editor]">
                        <xforms:label ref="$resources/all-zero-one"/>
                        <xforms:action ev:event="DOMActivate">
                            <xforms:action xxforms:iterate=".//concept">
                                <xforms:setvalue ref="context()/@minimumMultiplicity" value="'0'"/>
                                <xforms:setvalue ref="context()/@maximumMultiplicity" value="'1'"/>
                                <xforms:delete context="context()/@absent"/>
                            </xforms:action>
                        </xforms:action>
                    </fr:button>
                    <fr:button ref=".[$editor]">
                        <xforms:label ref="$resources/groups-zero-one-items-one-one"/>
                        <xforms:action ev:event="DOMActivate">
                            <xforms:action xxforms:iterate=".//concept">
                                <xforms:action if="context()/@type='group'">
                                    <xforms:setvalue ref="context()/@minimumMultiplicity" value="'0'"/>
                                    <xforms:setvalue ref="context()/@maximumMultiplicity" value="'1'"/>
                                    <xforms:delete context="context()/@absent"/>
                                </xforms:action>
                                <xforms:action if="context()/@type='item'">
                                    <xforms:setvalue ref="context()/@minimumMultiplicity" value="'1'"/>
                                    <xforms:setvalue ref="context()/@maximumMultiplicity" value="'1'"/>
                                    <xforms:delete context="context()/@absent"/>
                                </xforms:action>
                            </xforms:action>
                        </xforms:action>
                    </fr:button>
                </xhtml:td>
            </xhtml:tr>
        </xforms:group>
        <xhtml:tr>
            <xhtml:td colspan="2">
                <xforms:group ref="instance('default')/representingTemplate">
                { local:generateNestedXFormBlock($deep) }
                </xforms:group>
            </xhtml:td>
        </xhtml:tr>
    </xhtml:table>
<!--<fr:xforms-inspector/>-->
    </xhtml:body>
    </xhtml:html>

};

(:
   Recursive function for retrieving the basic concept info for a concept hierarchy.
   A reference to all concepts is required for the resolving of inheritance.
:)

(: 
    This function generates instance for a transaction, it merges things from transaction which are not present in the instance.
:)
declare function local:mergeAndGenerateInstance($transaction as element()) as element()* { 
    let $collection := $get:colDecorData
    let $representingTemplate := $transaction/representingTemplate
    let $dataset := $collection//dataset[@id=$representingTemplate/@sourceDataset]
   
    return
    <transaction id="{$transaction/@id}" type="{$transaction/@type}" model="{$transaction/@model}" label="{$transaction/@label}" effectiveDate="{$transaction/@effectiveDate}" statusCode="{$transaction/@statusCode}" expirationDate="{$transaction/@expirationDate}" versionLabel="{$transaction/@versionLabel}">
    {
        for $name in $transaction/name
        return
        art:serializeNode($name)
        ,
        for $desc in $transaction/desc
        return
        art:serializeNode($desc)
        ,
        if(not($transaction/actors/actor)) then
            <actors>
                <actor id="" role=""/>
            </actors>
        else ($transaction/actors)
        ,
        <representingTemplate ref="{$representingTemplate/@ref}" flexibility="{$representingTemplate/@flexibility}" displayName="{$representingTemplate/@displayName}" sourceDataset="{$representingTemplate/@sourceDataset}">
        {
            for $concept in $dataset/concept
            return
            art:transactionConceptBasics($concept, $representingTemplate)
        }
        </representingTemplate>
    }
    </transaction>
};

let $id                 := if (request:exists()) then request:get-parameter('id','') else ''
(:let $id := "2.16.840.1.113883.2.4.3.46.99.3.4.2":)
let $originalDocument   := ($get:colDecorData//transaction[@id=$id])[1] (: Adding [1] to select the first item, ideally ids should be unique:)
let $projectPrefix      := $originalDocument/ancestor::decor/project/@prefix/string()
let $defaultInstance    := if ($originalDocument) then local:mergeAndGenerateInstance($originalDocument) else ()
let $deep               := max($defaultInstance/descendant::concept[not(concept)]/count(ancestor::concept)) + 1 
(: $deep is a count of nested concept:)
let $form               := local:getXForms($deep, $defaultInstance, $projectPrefix)

(: Get user info for access control, user preferences and display :)
let $user               := xmldb:get-current-user()
let $userDisplayName    := 
    try {
        if ($user='guest' or aduser:getUserDisplayName($user)[string-length()=0]) then
            $user
        else (
            aduser:getUserDisplayName($user)
        )
    }
    catch * {
        $user
    }
let $groups             := sm:get-user-groups($user)
let $xsltParameters     := 
    <parameters>
        <param name="current-application" value="decor-transaction-editor"/>
        <param name="user" value="{$userDisplayName}"/>
        <param name="group" value="{$groups}"/>
        <param name="document" value="{$projectPrefix}"/>
        <param name="cameFromUri" value="''"/>
    </parameters>

let $xformStylesheet    := adserver:getServerXSLArt()
let $xformStylesheet    := if (string-length($xformStylesheet)=0) then 'apply-rules.xsl' else ($xformStylesheet)

return
transform:transform($form, xs:anyURI(concat('xmldb:exist://',$get:strArtResources,'/stylesheets/',$xformStylesheet)), $xsltParameters)
