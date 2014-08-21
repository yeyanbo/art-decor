<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="http://www.seanbdurkin.id.au/xslt/csv-to-xml.xslt" xmlns:File="java:java.io.File"
   xmlns:xcsvt="http://www.seanbdurkin.id.au/xslt/csv-to-xml.xslt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xcsv="http://www.seanbdurkin.id.au/xslt/xcsv.xsd"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
   <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
   <xsl:variable name="directoryName" select="'Source'"/>
   <xsl:variable name="charSet" select="'iso-8859-1'"/>

   <!-- Stylesheet parameters -->
   <!-- ************************************************************************<strong> -->
   <xsl:param name="url-of-csv" as="xs:string"/>
   <xsl:param name="lang" as="xs:string" select="'en'"/>
   <xsl:param name="url-of-messages" as="xs:string"/>

   <!-- Configurable constants -->
   <!-- ************************************************************************</strong> -->
   <xsl:variable name="quote" as="xs:string">"</xsl:variable>
   <xsl:variable name="error-messages-i18n">
      <xcsv:error error-code="1">
         <xcsv:message xml:lang="en">Uncategorised error.</xcsv:message>
      </xcsv:error>
      <xcsv:error error-code="2">
         <xcsv:message xml:lang="en">Quoted value not terminated.</xcsv:message>
      </xcsv:error>
      <xcsv:error error-code="3">
         <xcsv:message xml:lang="en">Quoted value incorrectly terminated.</xcsv:message>
      </xcsv:error>
      <xcsv:error error-code="5">
         <xcsv:message xml:lang="en">Could not open CSV resource.</xcsv:message>
      </xcsv:error>
   </xsl:variable>

   <!-- Non-configurable constants -->
   <!-- ************************************************************************<strong> -->
   <xsl:variable name="error-messages">
      <xsl:apply-templates select="$error-messages-i18n" mode="messages"/>
   </xsl:variable>

   <xsl:template match="@*|node()" mode="messages">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="messages"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="xcsv:message[
      not(@xml:lang=$lang) and
      (not(@xml:lang='en') or ../xcsv:message[@xml:lang=$lang])]" mode="messages"/>


   <xsl:function name="local:error-node" as="node()">
      <xsl:param name="error-code" as="xs:integer"/>
      <xsl:param name="data" as="xs:string"/>
      <xcsv:error error-code="{$error-code}">
         <xcsv:message xml:lang="{$error-messages/xcsv:error[@error-code=$error-code]/xcsv:message/@xml:lang}">
            <xsl:value-of select="$error-messages/xcsv:error[@error-code=$error-code]/xcsv:message"/>
         </xcsv:message>
         <xcsv:error-data>
            <xsl:value-of select="$data"/>
         </xcsv:error-data>
      </xcsv:error>
   </xsl:function>

   <xsl:function name="local:csv-to-xml" as="node()+">
      <xsl:param name="href" as="xs:string"/>
      
         <xsl:choose>
            <xsl:when test="fn:unparsed-text-available($href,$charSet)">
               <xsl:variable name="columns">
                  <xsl:analyze-string select="fn:concat(tokenize(unparsed-text($href,$charSet), '\r\n|\r|\n')[1], ',')" regex='(("[^"]*")+|[^,"]*),'>
                     <xsl:matching-substring>
                        <column>
                           <xsl:choose>
                              <xsl:when test="fn:starts-with( fn:regex-group(1), $quote)">
                                 <xsl:value-of select='fn:replace(fn:regex-group(1), "^""|""$|("")""", "$1" )'/>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:value-of select="regex-group(1)"/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </column>
                     </xsl:matching-substring>
                     <xsl:non-matching-substring>
                        <xsl:copy-of select="local:error-node(3,.)"/>
                        <!-- Quoted value incorrectly terminated. -->
                     </xsl:non-matching-substring>
                  </xsl:analyze-string>
               </xsl:variable>
               <xsl:for-each select="tokenize(unparsed-text($href,$charSet), '\r\n|\r|\n')[position() &gt; 1 and not(position()=last() and .='')]">
                  <row>
                     <xsl:variable name="row">
                        <xsl:analyze-string select="fn:concat(., ',')" regex='(("[^"]*")+|[^,"]*),'>
                           <xsl:matching-substring>
                              <value>
                                 <xsl:choose>
                                    <xsl:when test="fn:starts-with( fn:regex-group(1), $quote)">
                                       <xsl:value-of select='fn:replace(fn:regex-group(1), "^""|""$|("")""", "$1" )'/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                       <xsl:value-of select="regex-group(1)"/>
                                    </xsl:otherwise>
                                 </xsl:choose>
                              </value>
                           </xsl:matching-substring>
                           <xsl:non-matching-substring>
                              <xsl:copy-of select="local:error-node(3,.)"/>
                              <!-- Quoted value incorrectly terminated. -->
                           </xsl:non-matching-substring>
                        </xsl:analyze-string>
                     </xsl:variable>
                     <xsl:for-each select="$row/value">
                        <xsl:variable name="position" select="position()"/>
                        <xsl:element name="{if ($columns/column[$position]/text()) then $columns/column[$position]/text() else 'missing'}">
                           <xsl:value-of select="."/>
                        </xsl:element>

                     </xsl:for-each>
                  </row>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="local:error-node(5,$href)"/>
               <!-- Could not open CSV resource. -->
            </xsl:otherwise>
         </xsl:choose>
      
   </xsl:function>
   <xsl:template match="/">
      <xsl:variable name="directoryURI" select="resolve-uri($directoryName)"/>
      <xsl:variable name="directory" select="File:new($directoryURI)"/>
      <xsl:variable name="files" select="File:list($directory)"/>
      <xsl:for-each select="$files">
         <xsl:result-document indent="no" encoding="UTF-8" href="{concat('XML/',.,'.xml')}">
         <rows file="{.}">
            <xsl:copy-of select="local:csv-to-xml(concat($directoryName,'/',.))"/>
         </rows>
         </xsl:result-document>
      </xsl:for-each>



      <!--      <xsl:copy-of select="local:csv-to-xml($url-of-csv)"/>-->
   </xsl:template>
</xsl:stylesheet>
