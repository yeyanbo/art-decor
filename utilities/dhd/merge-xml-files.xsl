<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2011 Nictiz
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" exclude-result-prefixes="#all" encoding="UTF-8"/>
	<xsl:template match="/">
		<dhd>
		   <xsl:for-each select="doc('XML/20131006_163331_HT_Thesaurus.csv.xml')/rows/*">
				<mapping>
				  <xsl:for-each select="./*">
				  <xsl:attribute name="{name(.)}">
				     <xsl:value-of select="."/>
				  </xsl:attribute>
				  </xsl:for-each>
				</mapping>
			</xsl:for-each>
		   <xsl:for-each select="doc('XML/20131006_163331_HT_Interface.csv.xml')/rows/*">
		      <term>
		         <xsl:for-each select="./*">
		            <xsl:attribute name="{name(.)}">
		               <xsl:value-of select="."/>
		            </xsl:attribute>
		         </xsl:for-each>
		      </term>
		   </xsl:for-each>
		   <xsl:for-each select="doc('XML/20131006_163331_KT_Domeinen.csv.xml')/rows/*">
		      <thesaurusDomein>
		         <xsl:for-each select="./*">
		            <xsl:attribute name="{name(.)}">
		               <xsl:value-of select="."/>
		            </xsl:attribute>
		         </xsl:for-each>
		      </thesaurusDomein>
		   </xsl:for-each>
		   <xsl:for-each select="doc('XML/20131006_163331_RT_Specialisme.csv.xml')/rows/*">
		      <specialisme>
		         <xsl:for-each select="./*">
		            <xsl:attribute name="{name(.)}">
		               <xsl:value-of select="."/>
		            </xsl:attribute>
		         </xsl:for-each>
		      </specialisme>
		   </xsl:for-each>
		   <xsl:for-each select="doc('XML/20131006_163331_RT_ICD10.csv.xml')/rows/*">
		      <ICD>
		         <xsl:for-each select="./*">
		            <xsl:attribute name="{name(.)}">
		               <xsl:value-of select="."/>
		            </xsl:attribute>
		         </xsl:for-each>
		      </ICD>
		   </xsl:for-each>
		   <xsl:for-each select="doc('XML/20131006_163331_KT_ICD10.csv.xml')/rows/*">
		      <thesaurusICD>
		         <xsl:for-each select="./*">
		            <xsl:attribute name="{name(.)}">
		               <xsl:value-of select="."/>
		            </xsl:attribute>
		         </xsl:for-each>
		      </thesaurusICD>
		   </xsl:for-each>
		   <xsl:for-each select="doc('XML/20131006_163331_KT_DBC_Diagnose.csv.xml')/rows/*">
		      <diagnoseDBC>
		         <xsl:for-each select="./*">
		            <xsl:attribute name="{name(.)}">
		               <xsl:value-of select="."/>
		            </xsl:attribute>
		         </xsl:for-each>
		      </diagnoseDBC>
		   </xsl:for-each>
		   <xsl:for-each select="doc('XML/20131006_163331_RT_DBC_Diagnose.csv.xml')/rows/*">
		      <DBC>
		         <xsl:for-each select="./*">
		            <xsl:attribute name="{name(.)}">
		               <xsl:value-of select="."/>
		            </xsl:attribute>
		         </xsl:for-each>
		      </DBC>
		   </xsl:for-each>
		</dhd>
	</xsl:template>
</xsl:stylesheet>
