<!-- 
    DISCLAIMER
    Deze stylesheet en de resulterende html weergave van xml berichten zijn uitsluitend bedoeld voor testdoeleinden.
    Zij zijn uitdrukkelijk niet bedoeld voor gebruik in de medische praktijk.
    
    Auteur: Gerrit Boers
    Copyright: Nictiz
    

--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/" xmlns:hl7="urn:hl7-org:v3" xmlns:UML="omg.org/UML1.3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" version="2.0"><xsl:output method="html" exclude-result-prefixes="#all" encoding="UTF-8"/><xsl:variable name="headingList"><item>Revision History</item><item>Concept</item><item>Purpose</item><item>Evidence Base</item><item>Instruction</item><item>Interpretation</item><item>Care Process</item><item>Example of the Instrument</item><item>Constraints</item><item>References</item><item>Traceability to other standards</item><item>Disclaimer</item><item>Terms of Use</item><item>Copyright</item></xsl:variable><xsl:template match="/"><html><head><style type="text/css" media="print, screen">
               body,
               form,
               table,
               tr,
               td,
               th,
               p{
                  font-family:"Verdana", "Arial", sans-serif;
                  font-size:12px;
                  font-weight:normal;
                  color:#333333;
               }
               h1{
                  font-size:20px;
                  font-weight:bold;
                  margin-left:0px;
                  margin-right:0px;
                  margin-top:10px;
                  margin-bottom:10px;
                  color:#e16e22;
               }
               h2{
                  font-size:18px;
                  font-weight:bold;
                  margin-left:0px;
                  margin-right:0px;
                  margin-top:4px;
                  margin-bottom:8px;
                  background-color:#ece9e4;
                  color:#e16e22;
                  width:auto;
               }
               td.value-label{
                  width:15%;
                  background-color:#ece9e4;
                  color:#7a6e62;
                  font-weight:bold;
                  padding:2px;
                  text-align:left;
                  vertical-align:top;
               }
               td.value{
                  /*	width : 80%;*/
                  text-align:left;
                  vertical-align:top;
                  font-weight:normal;
                  padding:1px;
               }</style></head><body><xsl:apply-templates/></body></html></xsl:template><xsl:template match="XMI.header">
      <!-- ignore header info --></xsl:template><xsl:template match="XMI.content"><h1><xsl:value-of select="UML:TaggedValue[@tag='DCM::Name']/@value"/></h1><table class="values"><xsl:for-each select="UML:TaggedValue"><tr><td class="value-label"><xsl:value-of select="@tag"/></td><td lass="value"><xsl:value-of select="@value"/></td></tr></xsl:for-each></table><table width="100%"><xsl:variable name="xmi"><xsl:copy-of select="."/></xsl:variable><xsl:for-each select="$headingList/item"><xsl:variable name="item" select="."/><tr><td><h2><xsl:value-of select="$item"/></h2></td></tr><tr><td>
                  <!--<xsl:value-of select="$xmi//UML:ClassifierRole[@name=$item]//UML:TaggedValue[@tag='documentation']/@value"/>--><xsl:apply-templates select="$xmi//UML:ClassifierRole[@name=$item]//UML:TaggedValue[@tag='documentation']/@value"/></td></tr></xsl:for-each></table></xsl:template><xsl:template match="@value"><xsl:for-each select="tokenize(.,'&#xA;')"><xsl:value-of select="."/><br/></xsl:for-each></xsl:template></xsl:stylesheet>