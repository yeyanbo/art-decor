<!-- 
Copyright (C) 2013-2014  Marc de Graauw

This program is free software; you can redistribute it and/or modify it under the terms 
of the GNU General Public License as published by the Free Software Foundation; 
either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

See http://www.gnu.org/licenses/gpl.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fr="http://orbeon.org/oxf/xml/form-runner" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xxforms="http://orbeon.org/oxf/xml/xforms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/1999/xhtml http://www.w3.org/2002/08/xhtml/xhtml1-transitional.xsd     http://www.w3.org/2002/xforms http://www.w3.org/MarkUp/Forms/2002/XForms-Schema.xsd" version="2.0">
    <xsl:output method="text"/>
    <xsl:include href="ada-basics.xsl"/>
    <xsl:template match="/">
        <xsl:for-each select="//view[@type='index'][@target='xquery']">
            <xsl:variable name="href" select="concat($projectDiskRoot, 'modules/index.xquery')"/>
            <xsl:result-document href="{$href}" method="xml" omit-xml-declaration="yes" indent="yes">
                xquery version "1.0";
                declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
                <html>
                    <head>
                        <title>
                            <xsl:value-of select="name"/>
                        </title>
                        <link rel="stylesheet" type="text/css" href="{$existBaseUri}ada/resources/css/ada.css"/>
                    </head>
                    <body>
                        <h1>
                            <xsl:value-of select="name"/>
                        </h1>
                        <a href="{$orbeonBaseUri}{$projectUri}views/{indexOf/@shortName/string()}.xhtml?id=new">New</a>
                        <table>
                            <tr>
                                <xsl:for-each select="dataset/concept">
                                    <th><xsl:value-of select="name"/></th>
                                </xsl:for-each>
                                <th>User</th>
                                <th>Last updated</th>
                                <th/>
                            </tr>
                            { for $instance in collection('<xsl:value-of select="concat($existInternalBaseUri, $projectUri, 'data')"/>')//adaxml
                            order by $instance//@created-by, $instance//@last-update-date
                            return
                            <tr>
                                <xsl:for-each select="dataset/concept">
                                    <td>{$instance/data//*[@conceptId='<xsl:value-of select="@id"/>']/@value/string()}</td>
                                </xsl:for-each>
                                <td>{data($instance//@created-by)}</td>
                                <td>{data($instance//@last-update-date)}</td>
                                <td><a href="{$orbeonBaseUri}{$projectUri}views/{indexOf/@shortName/string()}.xhtml?id={{data($instance/data/*/@id)}}">Edit</a></td>
                            </tr>
                            }
                        </table>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>