<!--
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers, Kai U. Heitmann, Alexander Henket

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet xmlns:f="http://orbeon.org/oxf/xml/formatting" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:atp="urn:nictiz.atp" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fr="http://orbeon.org/oxf/xml/form-runner" xmlns:xxforms="http://orbeon.org/oxf/xml/xforms" xmlns:widget="http://orbeon.org/oxf/xml/widget" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    <xsl:output method="xml"/>
    <xsl:strip-space elements="*"/>
   <!-- dummy parameter for 'touching' file to cause xinclude refresh -->
    <xsl:param name="lastRefresh" select="'2014-03-05T12:31:23.956+01:00'"/>
   <!-- parameter for user, default value is 'guest' -->
    <xsl:param name="user" select="'guest'"/>
   <!-- parameter for group, default value is 'guest' -->
    <xsl:param name="group" select="'guest'"/>
   <!-- parameter for document, default value is empty' -->
    <xsl:param name="document" select="''"/>
   <!-- parameter for current application, used to highlight current app in menu -->
    <xsl:param name="current-application" select="'actors'" as="xs:string"/>
   <!-- parameter for the URL the user came from when he clicked Login -->
    <xsl:param name="cameFromUri"/>
   <!-- parameter for art/resources path -->
    <xsl:param name="strArt" select="'/db/apps/art'"/>
   <!-- parameter for art-data path -->
    <xsl:param name="strArt-data" select="'/db/apps/art-data'"/>

   <!-- variables for default logo and url -->
    <xsl:variable name="defaultLogo" select="'nictiz-logo.png'"/>
    <xsl:variable name="defaultHref" select="'http://www.nictiz.nl'"/>
   <!-- application menu  -->
    <xsl:variable name="menu-template">
        <xi:include href="/db/apps/art/resources/terminology-menu-template.xml">
            <xi:fallback>
                <xhtml:p>Included document /db/apps/art/resources/art-menu-template.xml not found!</xhtml:p>
            </xi:fallback>
        </xi:include>
    </xsl:variable>
   <!-- variable for decor projects -->
    <xsl:variable name="decor-projects">
        <xi:include href="/db/apps/art/modules/get-art-menu.xquery">
            <xi:fallback>
                <xhtml:p>Included document /db/apps/art/modules/get-art-menu.xquery not found!</xhtml:p>
            </xi:fallback>
        </xi:include>
    </xsl:variable>
   <!-- variable for terminology -->
    <xsl:variable name="terminology">
        <xi:include href="/db/apps/art/modules/get-terminology-menu.xquery">
            <xi:fallback>
                <xhtml:p>Included document /db/apps/art/modules/get-terminology-menu.xquery not found!</xhtml:p>
            </xi:fallback>
        </xi:include>
    </xsl:variable>
    <xsl:variable name="isDecor" select="$current-application=('decor-project','decor-datasets','decor-scenarios','decor-transaction-editor','decor-codesystems','decor-codesystem-editor','decor-codesystem-ids','decor-terminology','decor-valuesets','decor-valueset-editor','decor-valueset-ids','decor-templates','decor-template-editor','decor-template-mapping','decor-template-ids','decor-issues','decor-mycommunity')"/>
   <!--   <xsl:variable name="isDecor" select="true()"/>-->
    <xsl:template match="/">
        <xhtml:html>
            <xsl:apply-templates select="/xhtml:html/@*"/>
            <xhtml:head>
                <xhtml:script type="text/javascript">
                    var YUI_RTE_CUSTOM_CONFIG = {
                        height: '150px',
                        width: '100%',
                        toolbar: {
                            titlebar: false,
                            buttons:[ {
                                group: 'textstyle', label: '',
                                buttons:[ {
                                    type: 'push', label: 'Bold', value: 'bold'
                                }, {
                                    type: 'push', label: 'Italic', value: 'italic'
                                }, {
                                    type: 'push', label: 'Underline', value: 'underline'
                                }, {
                                    type: 'separator'
                                }, {
                                    type: 'push', label: 'Subscript', value: 'subscript', disabled: true
                                }, {
                                    type: 'push', label: 'Superscript', value: 'superscript', disabled: true
                                }, {
                                    type: 'separator'
                                }, {
                                    type: 'push', label: 'Indent', value: 'indent', disabled: true
                                }, {
                                    type: 'push', label: 'Outdent', value: 'outdent', disabled: true
                                }, {
                                    type: 'push', label: 'Create an Unordered List', value: 'insertunorderedlist'
                                }, {
                                    type: 'push', label: 'Create an Ordered List', value: 'insertorderedlist'
                                }]
                            }, {
                                type: 'separator'
                            }, {
                                group: 'indentlist2', label: '',
                                buttons:[ {
                                    type: 'push', label: 'Remove Formatting', value: 'removeformat', disabled: true
                                }, {
                                    type: 'push', label: 'Undo', value: 'undo', disabled: true
                                }, {
                                    type: 'push', label: 'Redo', value: 'redo', disabled: true
                                }]
                            }, {
                                type: 'separator'
                            }, {
                                group: 'insertitem',
                                label: '',
                                buttons:[ {
                                    type: 'push',
                                    label: 'Insert Image',
                                    value: 'insertimage'
                                }, {
                                    type: 'push',
                                    label: 'HTML Link CTRL + SHIFT + L',
                                    value: 'createlink',
                                    disabled: true
                                }]
                            }]
                        }
                    }
                </xhtml:script>
                <xhtml:script type="text/javascript">
                    function toggle(toggled,toggler) {
                        if (document.getElementById) {
                            var toggled = document.getElementById(toggled);
                            var toggler = document.getElementById(toggler);
                            if (toggled.className == "toggled-open"){
                                toggled.setAttribute("class", "toggled-closed");
                                toggler.setAttribute("class", "tree-section-closed");
                            } else {
                                toggled.setAttribute("class", "toggled-open");
                                toggler.setAttribute("class", "tree-section-open");
                            }
                            return false;
                        } else {
                            return true;
                        }
                    }
                </xhtml:script>
                <!-- Add Nictiz Google analytics hook -->
                <xhtml:script type="text/javascript">
                    var _gaq = _gaq || [];
                    _gaq.push(['_setAccount', 'UA-20138515-1']);
                    _gaq.push(["_trackPageview"]);
                    (function() {
                    var ga = document.createElement("script");
                    ga.type = "text/javascript";
                    ga.async = true;
                    ga.src = ("https:" == document.location.protocol ? "https://ssl" : "http://www") + ".google-analytics.com/ga.js";
                    (document.getElementsByTagName("head")[0] || document.getElementsByTagName("body")[0]).appendChild(ga);
                    })();
                </xhtml:script>
                <xi:include href="/db/apps/art/resources/stylesheets/common-decor-style.xml"/>
                <xsl:copy>
                    <xsl:apply-templates select="/xhtml:html/xhtml:head/@*|/xhtml:html/xhtml:head/node()"/>
                </xsl:copy>
                <xforms:model id="art-menu">
               <!-- instance for menu -->
                    <xforms:instance id="menu">
                  <!--                  <dummy/>-->
                        <xsl:copy-of select="$menu-template"/>
                    </xforms:instance>
               <!-- instance for decor project menu -->
                    <xforms:instance id="decor-menu">
                        <xsl:copy-of select="$decor-projects"/>
                    </xforms:instance>
               <!-- instance for terminology menu -->
                    <xforms:instance id="terminology-menu">
                        <xsl:copy-of select="$terminology"/>
                    </xforms:instance>
                </xforms:model>
            </xhtml:head>
            <xhtml:body>
            <!-- Copy body attributes -->
                <xsl:apply-templates select="/xhtml:html/xhtml:body/@*"/>
                <xhtml:table id="maincontent" width="100%" style="background: transparent;">
               <!-- row with page heading and clickable logo -->
                    <xhtml:tr>
                        <xhtml:td class="page-heading">
                            <xsl:copy-of select="/xhtml:html/xhtml:head/xhtml:title/xforms:output"/>
                        </xhtml:td>
                        <xhtml:td>
                 <!--    <xsl:variable name="logo" select="if (string-length(//xforms:instance[@id='logo']) &gt;0) then //xforms:instance[@id='logo']/logo else $defaultLogo"/>
                     <xsl:variable name="logoHref" select="if (string-length(//xforms:instance[@id='logo']) &gt;0) then //xforms:instance[@id='logo']/logo/@href else $defaultHref"/>-->
                     <!--<xhtml:a href="{$logoHref}" target="_blank">
                                <xhtml:img src="/img/{$logo}" alt="" style="float:right;"/>
                     </xhtml:a>-->
                     <xsl:choose>
                        <xsl:when test="//xforms:instance[@id='logo']">
                           <xforms:trigger appearance="minimal">
                              <xforms:label>
                                 <xhtml:img src="{concat('/img/','{instance(''logo'')}')}" alt="" style="float:right;"/>
                              </xforms:label>
                              <xforms:action ev:event="DOMActivate">
                                 <!--<xforms:load resource="{concat('instance(''logo'')','/@href')}" xxforms:target="_blank"/>-->
                                 <xforms:load resource="{concat('{instance(''logo'')','/@href}')}" show="new"/>
                              </xforms:action>
                           </xforms:trigger>
                        </xsl:when>
                        <xsl:otherwise>
                           <xhtml:a href="{$defaultHref}" target="_blank">
                              <xhtml:img src="/img/{$defaultLogo}" alt="" style="float:right;"/>
                            </xhtml:a>
                        </xsl:otherwise>
                     </xsl:choose>
                        </xhtml:td>
                    </xhtml:tr>
               <!-- row with menu, login and language select flag buttons -->
                    <xhtml:tr>
                  <!-- menu -->
                        <xhtml:td align="left" style="margin:0;padding:0;vertical-align:text-bottom;">
                            <xhtml:ul id="navmenu">
                                <xsl:for-each select="$menu-template/menu/section">
                                    <xsl:choose>
                                        <xsl:when test="@id='terminology'">
                                            <xhtml:li>
                                                <xhtml:a href="home">
                                                    <xforms:output ref="{concat('xxforms:instance(''menu'')/section[@id=''',@id,''']/name[@language=$resources/@xml:lang]')}"/>
                                                </xhtml:a>
                                                <xhtml:ul class="sub1">
                                                    <xsl:for-each select="application">
                                                        <xsl:call-template name="makeApplicationItem">
                                                            <xsl:with-param name="item" select="."/>
                                                        </xsl:call-template>
                                                    </xsl:for-each>
                                       <!-- show menu items for available ClaML packages -->
                                                    <xsl:for-each select="$terminology//classification">
                                                        <xhtml:li>
                                                            <xhtml:a href="{concat('claml?collection=',@collection)}">
                                                                <xsl:value-of select="@displayName"/>
                                                            </xhtml:a>
                                                        </xhtml:li>
                                                    </xsl:for-each>
                                                </xhtml:ul>
                                            </xhtml:li>
                                        </xsl:when>
                                        <xsl:when test="@id='refsets'">
                                            <xhtml:li>
                                                <xhtml:a href="home">
                                                    <xforms:output ref="{concat('xxforms:instance(''menu'')/section[@id=''',@id,''']/name[@language=$resources/@xml:lang]')}"/>
                                                </xhtml:a>
                                                <xhtml:ul class="sub1">
                                       <!-- show menu items for available Snomed refsets -->
                                                    <xforms:group model="art-menu" ref="instance('terminology-menu')/refsets">
                                                        <xsl:for-each select="$terminology//refset">
                                                            <xhtml:li>
                                                                <xhtml:a href="{concat('refsets?id=',@id)}">
                                                                    <xforms:output ref="{concat('refset[@id=''',@id,''']/name[@language=$resources/@xml:lang]')}"/>
                                                                </xhtml:a>
                                                            </xhtml:li>
                                                        </xsl:for-each>
                                                    </xforms:group>
                                                    <xsl:for-each select="application">
                                                        <xsl:call-template name="makeApplicationItem">
                                                            <xsl:with-param name="item" select="."/>
                                                        </xsl:call-template>
                                                    </xsl:for-each>
                                                </xhtml:ul>
                                            </xhtml:li>
                                        </xsl:when>
                                        <xsl:when test="@id=('home','demo','tools','application','about')">
                                            <xsl:call-template name="makeSection">
                                                <xsl:with-param name="section" select="."/>
                                            </xsl:call-template>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xhtml:ul>
                        </xhtml:td>
                  <!-- login and language -->
                        <xhtml:td align="right" style="margin:0;padding:0;vertical-align:text-bottom;">
                            <xsl:if test="lower-case($user)!='guest'">
                                <xsl:element name="xforms:output">
                                    <xsl:attribute name="ref" select="concat('$resources/','logged-in-as')"/>
                                </xsl:element>
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="$user"/>
                                <xsl:text> </xsl:text>
                                <xhtml:a href="/session/logout">
                                    <xsl:element name="xforms:output">
                                        <xsl:attribute name="ref" select="'$resources/logout'"/>
                                    </xsl:element>
                                </xhtml:a>
                            </xsl:if>
                            <xsl:if test="lower-case($user)='guest'">
                                <xhtml:a href="/login?returnToUrl={encode-for-uri($cameFromUri)}">
                                    <xsl:element name="xforms:output">
                                        <xsl:attribute name="ref" select="'$resources/login'"/>
                                    </xsl:element>
                                </xhtml:a>
                            </xsl:if>
                     <!-- Only in multi language 'applications' are flags needed. -->
                            <xsl:if test="$isDecor">
                        <!-- Currently reads from the UI languages, but TODO is to get the actual languages 
                                    from a given DECOR project, there is no real method for that currently -->
                                <xforms:select1 ref="instance('language')" class="auto-width" id="content-language-select">
                                    <xforms:itemset nodeset="instance('resources-instance')/resources">
                                        <xforms:label ref="@displayName"/>
                                        <xforms:value ref="@xml:lang"/>
                                    </xforms:itemset>
                                </xforms:select1>
                                <xforms:action ev:observer="content-language-select" ev:event="DOMActivate">
                           <!--<xforms:setvalue ref="instance('language')" value="@xml:lang"/>-->
                                    <xforms:insert context="." origin="xxforms:set-session-attribute('language', instance('language'))"/>
                                    <xxforms:variable name="session-language" select="xxforms:get-session-attribute('language')"/>
                                    <xforms:dispatch target="main-model" name="load-resources"/>
                                </xforms:action>
                                <xhtml:img alt="" style="margin-right:0.5em;margin-left:0.5em;">
                                    <xsl:attribute name="src">/img/flags/{instance('language')/lower-case(substring(.,4,2))}.png</xsl:attribute>
                                    <xsl:attribute name="title">{instance('resources-instance')/resources[@xml:lang=instance('language')]/@displayName}</xsl:attribute>
                                </xhtml:img>

                        <!--<xforms:trigger appearance="minimal">
                                    <xforms:label>
                                        <img src="/img/flags/nl.png" alt="" style="margin-right:0.5em;margin-left:2em;padding-bottom:0.3em;"/>
                                    </xforms:label>
                                    <xforms:action ev:event="DOMActivate">
                                        <xforms:setvalue ref="instance('language')" value="'nl-NL'"/>
                                        <xforms:insert context="." origin="xxforms:set-session-attribute('language', instance('language'))"/>
                                        <xxforms:variable name="session-language" select="xxforms:get-session-attribute('language')"/>
                                        <xforms:dispatch target="main-model" name="load-resources"/>
                                    </xforms:action>
                                </xforms:trigger>
                                <xforms:trigger appearance="minimal">
                                    <xforms:label>
                                        <img src="/img/flags/de.png" alt="" style="margin-right:0.5em;margin-left:0.3em;padding-bottom:0.3em;"/>
                                    </xforms:label>
                                    <xforms:action ev:event="DOMActivate">
                                        <xforms:setvalue ref="instance('language')" value="'de-DE'"/>
                                        <xforms:insert context="." origin="xxforms:set-session-attribute('language', instance('language'))"/>
                                        <xxforms:variable name="session-language" select="xxforms:get-session-attribute('language')"/>
                                        <xforms:dispatch target="main-model" name="load-resources"/>
                                    </xforms:action>
                                </xforms:trigger>
                                <xforms:trigger appearance="minimal">
                                    <xforms:label>
                                        <img src="/img/flags/us.png" alt="" style="margin-right:1.2em;margin-left:0.3em;padding-bottom:0.3em;"/>
                                    </xforms:label>
                                    <xforms:action ev:event="DOMActivate">
                                        <xforms:setvalue ref="instance('language')" value="'en-US'"/>
                                        <xforms:insert context="." origin="xxforms:set-session-attribute('language', instance('language'))"/>
                                        <xxforms:variable name="session-language" select="xxforms:get-session-attribute('language')"/>
                                        <xforms:dispatch target="main-model" name="load-resources"/>
                                    </xforms:action>
                                </xforms:trigger>-->
                            </xsl:if>
                        </xhtml:td>
                    </xhtml:tr>
                    <xhtml:tr>
                        <xhtml:td class="form-content" colspan="2">
                            <xsl:apply-templates select="/xhtml:html/xhtml:body/*"/>
                     <!-- include xforms inspector if user is memeber of 'debug' group -->
                            <xsl:if test="contains($group,'debug')">
                                <fr:xforms-inspector/>
                            </xsl:if>
                        </xhtml:td>
                    </xhtml:tr>
                </xhtml:table>
            </xhtml:body>
        </xhtml:html>
    </xsl:template>
   <!-- named template for creating menu section -->
    <xsl:template name="makeSection">
        <xsl:param name="section"/>
        <xsl:choose>
            <xsl:when test="$section/@groups">
                <xsl:if test="some $test in tokenize($section/@groups,'\s') satisfies contains($group,$test)">
                    <xsl:call-template name="makeSectionItem">
                        <xsl:with-param name="item" select="$section"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="makeSectionItem">
                    <xsl:with-param name="item" select="$section"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   <!-- named template for creating menu section item -->
    <xsl:template name="makeSectionItem">
        <xsl:param name="item"/>
        <xhtml:li>
            <xhtml:a href="{{if ($item/@link) then $item/@link else('#')}}">
                <xforms:output ref="{concat('xxforms:instance(''menu'')/section[@id=''',@id,''']/name[@language=$resources/@xml:lang]')}"/>
            </xhtml:a>
            <xsl:if test="application">
                <xhtml:ul class="sub1">
                    <xsl:for-each select="application">
                        <xsl:call-template name="makeApplicationItem">
                            <xsl:with-param name="item" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xhtml:ul>
            </xsl:if>
        </xhtml:li>
    </xsl:template>
    <xsl:template name="makeApplicationItem">
        <xsl:param name="item"/>
        <xsl:choose>
            <xsl:when test="$item/@groups">
                <xsl:if test="some $test in tokenize($item/@groups,'\s') satisfies contains($group,$test)">
                    <xhtml:li>
                        <xhtml:a href="{@link}">
                            <xforms:output ref="{concat('xxforms:instance(''menu'')//application[@id=''',@id,''']/name[@language=$resources/@xml:lang]')}"/>
                        </xhtml:a>
                    </xhtml:li>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xhtml:li>
                    <xhtml:a href="{@link}">
                        <xforms:output ref="{concat('xxforms:instance(''menu'')//application[@id=''',@id,''']/name[@language=$resources/@xml:lang]')}"/>
                    </xhtml:a>
                </xhtml:li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

   <!-- match all elements and attributes, but not comment nodes -->
    <xsl:template match="@*|node()">
        <xsl:choose>
         <!-- insert requested document into document instance -->
            <xsl:when test="name(.)='xforms:instance' and @id='document' and string-length($document)&gt;1">
                <xforms:instance id="document">
                    <name>
                        <xsl:value-of select="$document"/>
                    </name>
                </xforms:instance>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>