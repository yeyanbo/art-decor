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
   <!-- test -->
    <xsl:param name="test" select="'test'"/>
   <!-- parameter for user, default value is 'guest' -->
    <xsl:param name="user" select="'guest'"/>
   <!-- parameter for group, default value is 'guest' -->
    <xsl:param name="group" select="'guest'"/>
   <!-- parameter for document, default value is empty' -->
    <xsl:param name="document" select="''"/>
   <!-- parameter for list of groups allowed to edit -->
    <xsl:param name="editList" select="'dba editor'"/>
    <xsl:template match="/">
        <xhtml:html>
            <xsl:apply-templates select="/xhtml:html/@*"/>
            <xhtml:head>
                <xhtml:script type="text/javascript">
                    var YUI_RTE_CUSTOM_CONFIG = {
                        height: '150px',
                        width: 'inherit',
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
                <xi:include href="/db/apps/art/resources/stylesheets/common-decor-style.xml"/>
                <xsl:copy>
                    <xsl:apply-templates select="/xhtml:html/xhtml:head/@*|/xhtml:html/xhtml:head/node()"/>
                </xsl:copy>
            </xhtml:head>
            <xhtml:body>
            <!-- Copy body attributes -->
                <xsl:apply-templates select="/xhtml:html/xhtml:body/@*"/>
                <xhtml:table id="maincontent" width="100%" style="background: transparent;">
               <!-- row with login info and language select flag buttons -->
                    <xhtml:tr>
                        <xhtml:td colspan="2" align="right" style="margin:0;padding:0;vertical-align:text-bottom;">
                            <xsl:if test="lower-case($user)!='guest'">
                                <xsl:element name="xforms:output">
                                    <xsl:attribute name="ref" select="concat('$resources/','logged-in-as')"/>
                                </xsl:element>
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="$user"/>
                            </xsl:if>
                            <xforms:trigger appearance="minimal">
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
                            </xforms:trigger>
                        </xhtml:td>
                    </xhtml:tr>
                    <xhtml:tr>
                        <xhtml:td id="rightcontent" width="99%">
                            <xsl:apply-templates select="/xhtml:html/xhtml:body/*"/>
                        </xhtml:td>
                    </xhtml:tr>
                </xhtml:table>
            </xhtml:body>
        </xhtml:html>
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